{ den, lib, ... }:
{
  den.default =
    let
      stateVersion = "26.05";
    in
    {
      nixos.system.stateVersion = stateVersion;
      homeManager.home.stateVersion = stateVersion;
    };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # host<->user provides
  den.schema.user.includes = [ den._.mutual-provider ];
}
