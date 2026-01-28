{
  lib,
  pkgs,
  config,
  ...
}:
{
  snowfallorg.users = {
    "csinger".admin = true;
  };

  snowfall = {
    boot = {
      type = "uefi";
    };

    docker = {
      enable = true;
    };

    flatpak.enable = true;

    hardware = {
      bluetooth.enable = true;
      gpu = {
        intel = {
          enable = true;
          busID = "PCI:0:2:0";
        };
        nvidia = {
          enable = true;
          busID = "PCI:1:0:0";
        };
      };
    };

    qemu.enable = true;

    net.ssh = {
      enable = true;
      server = true; # Allow SSH'ing into this machine
    };

    # FIXME: Snowfall Lib isn't auto-discovering the dotnetCerts module
    # security.dotnetCerts = {
    #   enable = true;
    #   users = [ "csinger" ];
    # };
  };

  # Trust .NET development certificates system-wide
  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIID0zCCArugAwIBAgIJANev/yxgN20YMA0GCSqGSIb3DQEBCwUAMBQxEjAQBgNV
      BAMTCWxvY2FsaG9zdDAeFw0yNjAxMjYyMzI2MDNaFw0yNzAxMjYyMzI2MDNaMBQx
      EjAQBgNVBAMTCWxvY2FsaG9zdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
      ggEBAMSt3Hcn5TRNxN3SZ+hjcq8EgmlOHIm20Wn+QHYU20Pae6GOwnGqaNf+GpjK
      o7j8HFOiDC8qOV4/mpAzfdx0jOciRopawPIYoo77ez94tNZnppz3aguN9khPLxTZ
      23TVCpgLudW2NR9geS2PWrOrvjn0EZ50+eoqgiAGTyjVlxJVi7xxXnOosnMbx1JH
      eH9m05/FTjCLprKv2X6b9Sg+MHbSHTQUkffCUXaMpTcbXtb+Qtm72unsTdtS0yx6
      NYaPiKdbui9BlVDpfsQ4ACScR7d4kU8YOZG0drOC2BUOzFMvATKPzuvv+Ojwq3/Z
      lIpoM+MlgQ1aKHLsmpVIMomr500CAwEAAaOCASYwggEiMAwGA1UdEwEB/wQCMAAw
      DgYDVR0PAQH/BAQDAgWgMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMBMIGABgNVHREB
      Af8EdjB0gglsb2NhbGhvc3SCDyouZGV2LmxvY2FsaG9zdIIOKi5kZXYuaW50ZXJu
      YWyCFGhvc3QuZG9ja2VyLmludGVybmFsghhob3N0LmNvbnRhaW5lcnMuaW50ZXJu
      YWyHBH8AAAGHEAAAAAAAAAAAAAAAAAAAAAEwDwYKKwYBBAGCN1QBAQQBBjApBgNV
      HQ4EIgQgvzXnZd1GZunTtRZo8Dx+ujeeDJyjyzQqQAw7EobZauYwKwYDVR0jBCQw
      IoAgvzXnZd1GZunTtRZo8Dx+ujeeDJyjyzQqQAw7EobZauYwDQYJKoZIhvcNAQEL
      BQADggEBAC1ZAwrz7zxMVMVj9aTFw9iu72zMV6YZFedAcw4IcAqjrEj9wFE8j2Wa
      vmf+5b0gTUD5A8xXEuMjXsn3kxn9vYNnCv3himNJklgu5CuoYNjqzEjINeBXKQnh
      Z3NR9ujlcR6mnCdcYjWekAXjWEl3DS7D1Y+ib4N56AzRCYsWJUJ3QS2LXftlcgqe
      N2cOwZGw4iV4gymn+s/xhX7gTVx1WQIxswmVrNtTWuyoETcIPS/6BO9D6yUoFvHZ
      nrCJMpm0P68j0Gpyc5uOf7JG8vJFlNsCDtHTEqCXM5SzQr7yGp0NRgW2PcTWBLLr
      r6AG4vf8Byxdg4OYZAEDDFjHOA619R4=
      -----END CERTIFICATE-----
    ''
  ];

  # environment =
  #   let
  #     dotnet = (with pkgs.dotnetCorePackages; combinePackages [ dotnet_9.sdk ]);
  #   in
  #   {
  #     sessionVariables = {
  #       DOTNET_PATH = "${dotnet}/bin/dotnet";
  #       DOTNET_ROOT = "${dotnet}/share/dotnet";
  #     };

  #     systemPackages = with pkgs; [
  #       dotnet
  #     ];
  #   };

  # fileSystems."/mnt/nfs/clint" = {
  #   device = "192.168.1.3:/mnt/stuff/clint";
  #   fsType = "nfs";
  # };

  # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/backup" = {
    device = "//192.168.1.3/clint";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in
      [ "${automount_opts},credentials=/etc/nixos/.secret-smb" ];
  };

  # DANGER - Do not Modify Below!
  boot.initrd.availableKernelModules = [
    "vmd"
    "xhci_pci"
    "ahci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.extraModprobeConfig = "options kvm-intel nested=1";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5ce2ae63-604b-4e22-9923-4dc1f479ade6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1454-A232";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/9e72bc8a-7a48-4c4d-b180-6cd63a6aa1bd"; }
  ];

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/f54eca10-f82e-4531-a24f-af500a7e45bf";
    fsType = "ext4";
    # options = [ "subvol=log" "compress=zstd" "noatime" ];
    # neededForBoot = false;
  };

  environment = {
    variables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };
  };

  system.stateVersion = "24.11";
}
