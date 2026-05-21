{ den, ... }:
{
  den.aspects.profile-managed = {
    includes = with den.aspects; [
      sops
      openbao-ca
      openbao-agent
      ssh
      sssd
      ldap-home
      recovery-account
      authentik-ldap-outpost
    ];
  };
}
