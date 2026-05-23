{ den, ... }:
{
  den.aspects.profile-managed = {
    includes = with den.aspects; [
      sops
      openbao-cli
      openbao-agent
      openbao-secrets
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
