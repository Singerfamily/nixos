{ libx
, username
, inputs
, self
, stateVersion
, ...}: {
  imports = (libx.autoImport ./.);

  home-manager = {
    useGlobalPkgs     = true;
    useUserPackages   = true;

    extraSpecialArgs  = {
      inherit inputs self username;
    };

    users.${username} = {
      programs.home-manager.enable = true;

      home = {
        homeDirectory = "/home/${username}";
        
        inherit username;
        inherit stateVersion;
      };
    };
  };
}