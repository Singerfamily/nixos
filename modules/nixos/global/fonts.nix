{...}: {
  fonts.package = with pkgs; [
    (nerdfonts.override { fonts = [ 
      "FiraCode"
      "JetBrainsMono"
      "DroidSansMono" 
      ]; 
    })
  ]
}