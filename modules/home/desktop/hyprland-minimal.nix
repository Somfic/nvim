{ config, pkgs, inputs, ... }:

let
  hyprlandPkg = inputs.hyprland.packages.${pkgs.system}.hyprland;
in {
  home.packages = with pkgs; [
    rofi
    grim
    slurp
    wl-clipboard
    xdg-desktop-portal-gtk
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPkg;
    xwayland.enable = true;
    systemd.enable = true;

    extraConfig = ''
      exec-once = mkdir -p ~/.config/hypr && touch ~/.config/hypr/monitors.conf
      source = ~/.config/hypr/monitors.conf
    '';

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
        gaps_in = 3;
        gaps_out = 6;
      };
      decoration = {
        rounding = 20;
        blur = {
          size = 12;
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

      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
      bind = [
        "$mod, R, exec, rofi -show drun"
        "$mod, T, exec, kitty"
        "$mod, L, exec, loginctl lock-session"
        "$mod, M, exec, hyprctl dispatch exit"

        # screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"

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
        # workspaces — standard workspace binds (no split-monitor-workspaces)
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, ${toString ws}, workspace, ${toString ws}"
            "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
          ]) 9));

      exec-once = [
        "kitty"
        "systemctl --user start hyprpolkitagent"
      ];
    };
  };
}
