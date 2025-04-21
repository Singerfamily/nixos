{
  self,
  pkgs,
  lib,
  inputs,
  homeModules,
  generalModules,
  hostname,
  platform,
  isWorkstation,
  username,
  stateVersion,
  libx,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
  isRoot = if (username == "root") then true else false;
  homeDirectory =
    if isDarwin then
      "/Users/${username}"
    else if isRoot then
      "/root"
    else
      "/home/${username}";
  userConfigurationPath = "${self}/home/users/${username}";
  userConfigurationPathExist = builtins.pathExists userConfigurationPath;

  userCfgPath = userConfigurationPath;
in
{

  imports = lib.optional userConfigurationPathExist userConfigurationPath;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";

    extraSpecialArgs = {
      inherit
        inputs
        self
        homeModules
        generalModules
        hostname
        username
        platform
        stateVersion
        isWorkstation
        userCfgPath
        ;
    };

    users.${username} = {
      programs.home-manager.enable = true;

      imports =
        (libx.autoImport { path = ./modules; })
        ++ lib.optional userConfigurationPathExist "${userConfigurationPath}/home.nix";

      home = {
        inherit username;
        inherit stateVersion;
        inherit homeDirectory;
      };
    };
  };
}
