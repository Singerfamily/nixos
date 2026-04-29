_:
{
  # Global assertions applied to every host via den.default.nixos.
  # Guards against host configs that evaluate cleanly but would produce
  # a system that can't boot, can't mount /, or can't be logged into.
  #
  # Each assertion uses `or` defaults when accessing options that may be
  # undefined (e.g. config.wsl on non-WSL hosts) so the assertion runs
  # rather than throwing during evaluation.
  den.default.nixos =
    { config, lib, ... }:
    let
      hostName = config.networking.hostName;
      isWsl = config.wsl.enable or false;
      isContainer = config.boot.isContainer or false;

      bootloaderEnabled =
        (config.boot.loader.systemd-boot.enable or false)
        || (config.boot.loader.grub.enable or false)
        || (config.boot.loader.generic-extlinux-compatible.enable or false)
        || (config.boot.loader.raspberryPi.enable or false);

      rootFs = config.fileSystems."/" or null;
      rootDefined = rootFs != null;
      rootDevice = if rootDefined then rootFs.device or null else null;
      rootFsType = if rootDefined then rootFs.fsType or null else null;

      bootFs = config.fileSystems."/boot" or null;
      bootRequired =
        (config.boot.loader.systemd-boot.enable or false)
        || ((config.boot.loader.grub.enable or false) && (config.boot.loader.grub.efiSupport or false));

      # Users that should be able to log in: normal users plus root.
      loginUsers = lib.filterAttrs
        (n: u: (u.isNormalUser or false) || n == "root")
        config.users.users;
      userHasPassword =
        u:
        (u.hashedPasswordFile or null) != null
        || (u.hashedPassword or null) != null
        || (u.passwordFile or null) != null
        || (u.password or null) != null
        || (u.initialHashedPassword or null) != null
        || (u.initialPassword or null) != null;
      usersWithoutPassword =
        lib.attrNames (lib.filterAttrs (_: u: !userHasPassword u) loginUsers);

      # Stateless containers and WSL handle boot/root differently.
      bootSafetyApplies = !isContainer;
    in
    {
      assertions = [
        {
          assertion = !bootSafetyApplies || isWsl || bootloaderEnabled;
          message = ''
            boot-safety: host '${hostName}' has no bootloader enabled.
            Enable one of boot.loader.{systemd-boot, grub,
            generic-extlinux-compatible, raspberryPi}.enable, or set
            wsl.enable = true / boot.isContainer = true for hosts that
            don't need a bootloader.
          '';
        }
        {
          assertion = !bootSafetyApplies || isWsl || rootDefined;
          message = ''
            boot-safety: host '${hostName}' has no fileSystems."/"
            defined. Declare a root filesystem (or set wsl.enable = true
            / boot.isContainer = true for hosts that don't mount one).
          '';
        }
        {
          assertion = !bootSafetyApplies || isWsl || !rootDefined || rootDevice != null;
          message = ''
            boot-safety: host '${hostName}' has fileSystems."/" but no
            .device set.
          '';
        }
        {
          assertion = !bootSafetyApplies || isWsl || !rootDefined || rootFsType != null;
          message = ''
            boot-safety: host '${hostName}' has fileSystems."/" but no
            .fsType set. Add e.g. fsType = "ext4" / "btrfs" / "xfs".
          '';
        }
        {
          assertion = !bootSafetyApplies || isWsl || !bootRequired || bootFs != null;
          message = ''
            boot-safety: host '${hostName}' uses an EFI bootloader
            (systemd-boot or grub.efiSupport) but has no
            fileSystems."/boot" mount declared.
          '';
        }
        {
          assertion =
            (config.users.mutableUsers or true)
            || isContainer
            || usersWithoutPassword == [ ];
          message = ''
            boot-safety: host '${hostName}' has users.mutableUsers = false
            but these login-eligible users have no password configured
            (no hashedPassword, hashedPasswordFile, password, passwordFile,
            initialPassword, or initialHashedPassword):
              ${lib.concatStringsSep ", " usersWithoutPassword}
            Wire each user's hashedPasswordFile to a sops secret.
          '';
        }
      ];
    };
}
