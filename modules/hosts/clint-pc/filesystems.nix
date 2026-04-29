_:
{
  den.aspects.clint-pc.nixos = _: {
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/5ce2ae63-604b-4e22-9923-4dc1f479ade6";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/1454-A232";
      fsType = "vfat";
    };
    fileSystems."/mnt/data" = {
      device = "/dev/disk/by-uuid/f54eca10-f82e-4531-a24f-af500a7e45bf";
      fsType = "ext4";
    };
    swapDevices = [
      { device = "/dev/disk/by-uuid/9e72bc8a-7a48-4c4d-b180-6cd63a6aa1bd"; }
    ];

    # SMB share — tooling from samba-client aspect; credentials currently
    # plaintext at /etc/nixos/.secret-smb (Phase 5 will SOPS-ize).
    fileSystems."/mnt/backup" = {
      device = "//10.200.0.3/clint";
      fsType = "cifs";
      options = [
        "x-systemd.automount"
        "noauto"
        "x-systemd.idle-timeout=60"
        "x-systemd.device-timeout=5s"
        "x-systemd.mount-timeout=5s"
        "credentials=/etc/nixos/.secret-smb"
      ];
    };
  };
}
