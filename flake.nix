{
  description = "NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote } @ inputs:
    let
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        thinkpad-p53 = lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; }; # this is the important part
          modules = [ 
            ./hosts/thinkpad-p53/configuration.nix

             lanzaboote.nixosModules.lanzaboote

              ({ pkgs, lib, ... }: {

                environment.systemPackages = [
                  # For debugging and troubleshooting Secure Boot.
                  pkgs.sbctl
                ];

                # Lanzaboote currently replaces the systemd-boot module.
                # This setting is usually set to true in configuration.nix
                # generated at installation time. So we force it to false
                # for now.
                boot.loader.systemd-boot.enable = lib.mkForce false;

                boot.lanzaboote = {
                  enable = true;
                  pkiBundle = "/etc/secureboot";
                  package = lib.mkForce (pkgs.writeShellApplication {
                  name = "lzbt";
                  runtimeInputs = with pkgs; [ coreutils binutils vim openssl jq ];
                  text = ''
                    set -o pipefail

                    "${lanzaboote.packages."${pkgs.system}".tool}/bin/lzbt" "$@"

                    work_dir="$(mktemp -d)"
                    pushd "$work_dir" > /dev/null

                    hash_algo=sha256
                    hash_len="$(openssl "$hash_algo" -binary /dev/null | wc -c)"
                    stub_path="$(bootctl list --json pretty | jq -r '.[] | select(.isDefault) | .path')"
                    section_names=".linux .osrel .cmdline .initrd .splash .dtb .pcrsig .pcrpkey"
                    head -c "$hash_len" /dev/zero > pcr
                    for section_name in $section_names; do
                      objcopy -O binary --dump-section "$section_name=section$section_name" "$stub_path" /dev/null
                      if [ ! -f "section$section_name" ]; then
                        continue
                      fi
                      cat pcr <(openssl "$hash_algo" -binary "section$section_name") | openssl "$hash_algo" -binary -out pcr_new
                      echo "pcr old=$(xxd -p -c0 pcr) new=$(xxd -p -c0 pcr_new)"
                      mv pcr_new pcr
                    done
                    "/run/current-system/sw/bin/systemd-cryptenroll" \
                      "${boot.initrd.luks.devices."cryptroot".device}" \
                      --wipe-slot tpm2 --tpm2-device auto --tpm2-pcrs "7+11:$hash_algo=$(xxd -p -c0 pcr)" \
                      --unlock-key-file /etc/nixos/credentials/luks/root

                    popd > /dev/null
                    rm -rf "$work_dir"
                  '';
                });
                };
              })
          ];
        };
      };
    };
}
