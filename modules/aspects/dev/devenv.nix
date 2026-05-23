_:
{
  den.aspects.devenv.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        devenv
      ];

      programs.zsh.initContent = ''
        eval "$(devenv hook zsh)"
      '';
    };

  flake-file.inputs.devenv = {
    url = "github:cachix/devenv";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}