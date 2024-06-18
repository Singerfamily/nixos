{config, pkgs, ...}:

{
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  users.users.esinger = {
    isNormalUser = true;
    description = "Eric Singer";
    extraGroups = [ 
      "networkmanager" 
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    uid = 1000;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
