{ lib, den, ... }:
{
  den.default = {
    nixos.system.stateVersion = "26.05";
    homeManager.home.stateVersion = "26.05";

    includes = lib.mkMerge [
      (with (den.aspects); [
        den.aspects.core
      ])
      (with (den.provides); [
        define-user
        hostname
        inputs'
        self'
      ])
    ];
  };

  # Core system fundamentals aspect - includes all basic system setup
  # Applied globally to all hosts except special cases like WSL
  den.aspects.core = {
    includes = with (den.aspects); [
      fonts
      locale
      nix
      network
      users
    ];
  };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # host<->user provides
  den.ctx.user.includes = [ den._.mutual-provider ];
}
