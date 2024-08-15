{...}: {
  imports =
    [
      ./hardware-configuration.nix
    ];

  system.stateVersion = "24.11"; # Did you read the comment?
}
