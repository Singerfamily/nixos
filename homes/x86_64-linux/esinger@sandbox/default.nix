{ pkgs, ... }:
{
  users.users."esinger" = {
    hashedPassword = "$y$j9T$Y9uPcCDrepfHHZkw.r6wM1$5oEosCGb3J2R6024/AGYg/lgekaAiGoEMFk/h6GHXGC";
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
  };
}
