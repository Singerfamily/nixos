_:
{
  # Sunshine game-streaming server. Captures input via uinput, so the
  # udev rule below is required for non-root operation.
  den.aspects.sunshine.nixos = {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    '';
  };
}
