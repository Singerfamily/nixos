{ pkgs, inputs, ... }: {

  imports = [
    ./waybar.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    
    plugins = [
      # inputs.hyprland-plugins.packages."${pkgs.system}".hyprbars
      # inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
    ];


    settings = {
      "$mod" = "SUPER";

      animation = [
        "workspaces,1,2,default"
        "windows,1,2,default,slide"
        "fade,0"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      bind =
        [
          "$mod, W, exec, microsoft-edge-dev"
          ", Print, exec, grimblast copy area"
          "$mod, Q, exec, kitty"
          "$mod, L, exec"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
      };
  };
}