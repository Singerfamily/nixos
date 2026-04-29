_:
{
  den.aspects.clint-pc.nixos = _: {
    # KASM compatibility — relaxed SSH MACs.
    services.openssh.settings.Macs = [
      "hmac-sha2-256-etm@openssh.com"
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256"
      "hmac-sha2-512"
    ];

    # Per-host values consumed by the azure-devops aspect.
    den.azureDevOps = {
      organization = "https://dev.azure.com/nueradev";
      project = "ProjectVicious";
    };

    # libvirt default connection (host-specific).
    environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";
  };
}
