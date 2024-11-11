{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ 
        "Monaspace"
        "FiraCode"
        # "JetBrainsMono"
        # "DroidSansMono" 
        ]; 
      })
      corefonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [  "Monaspace" ];
        sansSerif = [ "Monaspace" ];
        monospace = [ "Monaspace" ];
      };
    };
  };
}