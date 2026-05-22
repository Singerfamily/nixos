# Pull admin users into privileged host groups.
#
# LDAP/Authentik users have no local /etc/passwd entry, so they cannot be
# static `users.users.<n>.extraGroups` members. But a group's *member list*
# in /etc/group is matched by name — `getgrouplist()` picks up every
# /etc/group entry naming the user, whether that user is local or LDAP.
# So listing the admins in `users.groups.<g>.members` gives them real NSS
# membership at the host group's real GID.
#
# This is deliberately NOT pam_group: OpenSSH rebuilds the supplementary
# group list from NSS when dropping privileges, discarding anything
# pam_group adds — so pam_group silently does nothing over SSH. Real
# /etc/group membership survives that, and works for SSH, SDDM and console
# alike.
#
# SECURITY: `docker` membership is root-equivalent (the docker socket
# trivially grants root). Keep the admin list tight.
{ ... }:
let
  adminUsers = [
    "eric"
    "clint"
  ];
in
{
  den.aspects.login-groups = {
    nixos =
      { config, lib, ... }:
      let
        # group → whether this host actually provides it. Guard on the
        # enabling service so we never materialise a phantom empty group.
        # (No `adb`: `programs.adb` was removed from nixpkgs — systemd 258
        # grants Android device access via uaccess, no group needed.)
        guards = {
          wheel = true;
          networkmanager = config.networking.networkmanager.enable;
          docker = config.virtualisation.docker.enable;
          libvirtd = config.virtualisation.libvirtd.enable;
        };
        present = builtins.attrNames (lib.filterAttrs (_: enabled: enabled) guards);
      in
      {
        users.groups = builtins.listToAttrs (
          map (g: {
            name = g;
            value.members = adminUsers;
          }) present
        );
      };
  };
}
