{ config, pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
      cursor = {
        inactive_timeout = 10;
        no_hardware_cursors = true;
        hide_on_key_press = false;
      };
      monitor = [
        ", preferred, auto, auto"
        "DP-2, preferred, auto-right, 1"
        "DP-3, preferred, auto-left, 1"
      ];
      general = {
        border_size = 0;
        gaps_in = 7;
        gaps_out = 14;
      };
      decoration = {
        rounding = 15;
        blur = {
          size = 24;
          passes = 3;
          brightness = 0.45;
          vibrancy = 1.0;
          noise = 5.0e-2;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          range = 8;
        };
      };
      windowrulev2 = [
        "float,move 10 10,title:^(initialkitty)$"
        "opacity 0.85 override 0.85 override, class:.*"
      ];
      # windowrule = [ "opacity 0.5,class:vesktop" ];
      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
      bind = [
        "$mod, R, exec, rofi -show drun -show-icons"
        "$mod, V, togglefloating"
        "$mod, F, exec, firefox"
        "$mod, C, exec, code"
        "$mod, S, exec, spotify"
        "$mod, D, exec, vesktop"
        "$mod, T, exec, kitty"
        "$mod, J, togglesplit,"
        "$mod, M, exit"

        # moving focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # moving windows
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # closing windows
        "$mod, mouse:274, killactive"
        "$mod, Q, killactive"

        ", Print, exec, grimblast copy area"
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]) 9));

      exec-once = [
        "kitty --title initialkitty -e bash -ic 'fastfetch; exec nu' & waybar"
      ];
    };
  };
}
