{ config, pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];

    # Source dynamic monitor configuration from nwg-displays
    extraConfig = ''
      # Source monitor config if it exists (created by nwg-displays)
      exec-once = mkdir -p ~/.config/hypr && touch ~/.config/hypr/monitors.conf
      source = ~/.config/hypr/monitors.conf
    '';

    settings = {
      "$mod" = "SUPER";

      # split-monitor-workspaces plugin configuration
      plugin = { split-monitor-workspaces = { count = 10; }; };

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
      # Window rules for pop-ups and dialogs
      # windowrule = [
      #   "noinitialfocus, class:^(jetbrains-.*), title:^(win.*)"
      #   "opacity 0.85 override 0.85 override, class:.*"
      # ];

      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
      bindr = [
        "$mod, SUPER_L, exec, caelestia-shell ipc call drawers toggle launcher"
      ];
      bind = [
        "$mod, R, exec, caelestia-shell ipc call drawers toggle launcher"
        "$mod, P, exec, passbolt-rofi"
        "$mod, N, exec, vpn-rofi"
        "$mod, O, exec, monitor-config"
        "$mod, F, exec, brave"
        "$mod, C, exec, code"
        "$mod, S, exec, flatpak run --env=WAYLAND_DISPLAY=wayland-1 --socket=wayland com.spotify.Client --enable-features=UseOzonePlatform --ozone-platform=wayland"
        "$mod, D, exec, vesktop"
        "$mod, T, exec, kitty"
        "$mod, J, togglesplit,"
        "$mod, L, exec, loginctl lock-session"
        "$mod, M, exit"

        # screenshot
        ", Print, exec, caelestia-shell ipc call picker openFreeze"
        "$mod SHIFT, S, exec, caelestia-shell ipc call picker openFreeze"

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
        # binds $mod + [shift +] {1..9} to [move to] split-workspace {1..9}
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, ${toString ws}, split-workspace, ${toString ws}"
            "$mod SHIFT, ${toString ws}, split-movetoworkspace, ${toString ws}"
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
