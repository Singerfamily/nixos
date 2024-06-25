{ pkgs,... }: {
  users.mutableUsers = true;
  users.users.esinger = {
    isNormalUser = true;
    name = "esinger";
    shell = pkgs.zsh;
    description = "Eric Singer";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager" 
      "docker"
      "tss"
    ];
  };
}