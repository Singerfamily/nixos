{ lib, den, ... }:
{
  den.default = {
    nixos.system.stateVersion = "26.05";
    homeManager.home.stateVersion = "26.05";

    includes = (
      with (den.provides);
      [
        define-user
        hostname
        inputs'
        self'
      ]
    );
  };

  # enable hm by default
  den.schema.user.classes =  [ "homeManager" ];

  # host<->user provides
  den.ctx.user.includes = [ den._.mutual-provider ];
}
