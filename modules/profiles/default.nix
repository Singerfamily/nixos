{ den, lib, ... }:
{
  den.default =
    let
      stateVersion = "26.05";
    in
    {
      includes = lib.mkMerge (
        with den.aspects;
        [
          [
            sops
            openbao-agent
            openbao-ca
            docker
          ]
          (den.lib.policy.when ({ host, ... }: !!(host.wsl.enable or false)) (
            with den.aspects;
            [
              ssh
              sssd
              recovery-account
              authentik-ldap-outpost
            ]
          ))
        ]
      );

      nixos.system.stateVersion = stateVersion;
      homeManager.home.stateVersion = stateVersion;
    };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # host<->user provides
  den.schema.user.includes = [ den._.mutual-provider ];
}
