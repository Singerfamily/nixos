{
  self,
  lib,
  modulesPath,
  config,
  hostname,
  pkgs,
  ...
}:
let
  nixRev = if self.inputs.nixpkgs ? rev then self.inputs.nixpkgs.shortRev else "dirty";
  selfRev = if self ? rev then self.shortRev else "dirty";
in
{
  imports = [
    # base profiles
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/all-hardware.nix"

    # Let's get it booted in here
    "${modulesPath}/installer/cd-dvd/iso-image.nix"

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    "${modulesPath}/installer/cd-dvd/channel.nix"
  ];

  # Run through tor because finger printing or something? Supposed to be
  # relatively amnesiac.
  services.tor = {
    enable = true;
    client = {
      enable = true;
      dns.enable = true;
      transparentProxy.enable = true;
    };
  };

  users.mutableUsers = lib.mkForce false;

  # ISO naming.
  isoImage.isoName = "${hostname}-${nixRev}-${selfRev}.iso";

  # EFI + USB bootable
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # Other cases
  isoImage.appendToMenuLabel = " live";

  # Add Memtest86+ to the ISO.
  boot.loader.grub.memtest86.enable = true;

  # An installation media cannot tolerate a host config defined file
  # system layout on a fresh machine, before it has been formatted.
  swapDevices = lib.mkImageMediaOverride [ ];
  fileSystems = lib.mkImageMediaOverride config.lib.isoFileSystems;
}
