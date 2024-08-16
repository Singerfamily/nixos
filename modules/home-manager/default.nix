{ lib
, libx
, username
, inputs
, self
, stateVersion
, ...}: let 
in {
  imports = [(libx.autoImports ./.)];

  home-manager = {
    useGlobalPkgs     = true;
    useUserPackages   = true;

    extraSpecialArgs  = {
      inherit inputs self username;
    };

    users.${username} = {
      programs.home-manager.enable = true;

      home = {
        inherit username;
        inherit stateVersion;
      };
    };
  };
}