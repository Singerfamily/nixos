{}

# {pkgs, ...}: {
#    fonts = {
#     enableDefaultPackages = true;
#     packages = with pkgs; [
#       nerd-fonts.monaspace
#       # monaspace
#       # fira-code
#       # (nerd-fonts.override { fonts = [ 
#       #   "Monaspace"
#       #   "FiraCode"
#       #   # "JetBrainsMono"
#       #   # "DroidSansMono" 
#       #   ]; 
#       # })
#       corefonts
#     ];

#     fontconfig = {
#       defaultFonts = {
#         serif = [  "Monaspace" ];
#         sansSerif = [ "Monaspace" ];
#         monospace = [ "Monaspace" ];
#       };
#     };
#   };
# }