{ den, ... }:
{
  den.aspects.profile-managed = {
    includes = with den.aspects; [
      sops
      openbao-cli
      openbao-agent
      ssh
      sssd
      ldap-home
      login-groups
      auto-update
      recovery-account
      authentik-ldap-outpost
    ];
  };
}
