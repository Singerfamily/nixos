_:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos-config";
        packages = with pkgs; [
          nixfmt-tree
          statix
          deadnix
          sops
          age
          nh
          git
          jq
          pre-commit
        ];
        shellHook = ''
          echo "nixos-config devshell"
          echo "  rebuild     - nixos-rebuild switch --flake .#\$(hostname)"
          echo "  check       - nix flake check --no-build"
          echo "  fmt         - nix fmt"
          echo "  write       - nix run .#write-flake"
          echo "  setup-hooks - scripts/setup-hooks.sh (installs git hooks)"
          echo "  new-aspect  - scripts/new-aspect.sh <domain> <name>"
        '';
      };
    };
}
