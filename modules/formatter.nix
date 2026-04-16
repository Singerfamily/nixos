{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          shfmt.enable = true;
          prettier.enable = true;
          statix.enable = true;
          deadnix.enable = true;
        };
        settings.formatter.prettier.includes = [
          "*.md"
          "*.yaml"
          "*.yml"
          "*.json"
        ];
        settings.formatter.prettier.excludes = [
          "flake.lock"
        ];
      };
    };
}
