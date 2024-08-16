{ pkgs, ... }: {
  users = {
    mutableUsers = true;

    users.esinger = {
      isNormalUser = true;
      name = "esinger";
      shell = pkgs.zsh;
      description = "Eric Singer";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "networkmanager"
        "tss"
      ];

      hashedPassword =
        "$y$j9T$mboI3SZPrs3PANp77OkRQ1$804/B42apAF5ef7J70Shkw7t3qmYKCZLx2xym1/hUH8";
    };
  };
}
