{ den, ... }:
{
  den.hosts.x86_64-linux.event-horizon.users.esinger = { };

  den.aspects.event-horizon = {
    includes = with den.aspects; [
      sops
      openbao-agent
      openbao-ca
      ssh
      sssd
      recovery-account
    ];

    nixos =
      _:
      {

      };
  };
}
