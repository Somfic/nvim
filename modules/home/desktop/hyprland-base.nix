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
      input = {
        touchpad = { natural_scroll = true; };
        float_switch_override_focus = 0;
      };
      general = {
        border_size = 0;
        gaps_in = 4;
        gaps_out = 8;
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
      # windowrulev2 = [ "opacity 0.85 override 0.85 override, class:.*" ];

      # Window rules for pop-ups and dialogs
      windowrulev2 =
        [ "noinitialfocus, class:^(jetbrains-.*), title:^(win.*)" ];

      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
      bindr =
        [ "$mod, SUPER_L, exec, caelestia-shell ipc call drawers toggle launcher" ];
      bind = [
        "$mod, R, exec, caelestia-shell ipc call drawers toggle launcher"
        "$mod, P, exec, passbolt-rofi"
        "$mod, N, exec, vpn-rofi"
        "$mod, F, exec, firefox"
        "$mod, C, exec, code"
        "$mod, S, exec, flatpak run --env=WAYLAND_DISPLAY=wayland-1 --socket=wayland com.spotify.Client --enable-features=UseOzonePlatform --ozone-platform=wayland"
        "$mod, D, exec, vesktop"
        "$mod, T, exec, kitty"
        "$mod, J, togglesplit,"
        "$mod, L, exec, loginctl lock-session"
        "$mod, M, exit"

        # floating and fullscreen
        "$mod, V, togglefloating"
        "$mod SHIFT, V, fullscreen"

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
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, ${toString ws}, workspace, ${toString ws}"
            "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
          ]) 9));

      exec-once = [
        "kitty --title hello -e bash -ic 'fastfetch; exec nu'"
        "swww-daemon"
        "systemctl --user start hyprpolkitagent"
        "caelestia-shell"
      ];
    };
  };
}
