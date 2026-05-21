# testuser — portable shell home-manager config. Verification account for the
# LDAP home-provisioning path; safe to delete once no longer needed.
{ ... }:
{
  programs.git.userName = "Test User";

  home.file.".ldap-home-marker".text = "provisioned by home-manager\n";
}
