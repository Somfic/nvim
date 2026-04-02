{ config, pkgs, inputs, ... }:

let
  hyprlandPkg = inputs.hyprland.packages.${pkgs.system}.hyprland;

  # Script that assigns a random unique wallpaper to each connected monitor
  set-wallpaper = pkgs.writeShellScriptBin "set-wallpaper" ''
    WALLPAPER_DIR="''${1:-$HOME/dot/wallpapers}"

    # Wait for swww-daemon to be ready
    for i in $(seq 1 20); do
      ${pkgs.swww}/bin/swww query &>/dev/null && break
      sleep 0.25
    done

    # Get connected outputs
    mapfile -t outputs < <(${pkgs.swww}/bin/swww query | cut -d: -f1)

    # Get wallpapers and shuffle
    mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.webp' \) | shuf)

    # Assign one wallpaper per monitor (no duplicates)
    for i in "''${!outputs[@]}"; do
      if [[ $i -lt ''${#wallpapers[@]} ]]; then
        ${pkgs.swww}/bin/swww img --outputs "''${outputs[$i]}" "''${wallpapers[$i]}"
      fi
    done
  '';
in {
  home.packages = [
    set-wallpaper
    pkgs.xdg-desktop-portal-gtk  # Needed in user profile for FileChooser portal
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPkg;
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
      # Window rules for pop-ups and dialogs
      windowrule = [
        # JetBrains IDE popup windows - auto focus and keep visible
        "stay_focused on, match:class ^(jetbrains-.*)$, match:float yes"
      ];

      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];
      bindr = [
        "$mod, SUPER_L, exec, caelestia-shell ipc call drawers toggle launcher"
      ];
      bind = [
        "$mod, R, exec, caelestia-shell ipc call drawers toggle launcher"
        "$mod, P, exec, passbolt-rofi"
        "$mod, N, exec, vpn-rofi"
        "$mod, O, exec, monitor-config"
        "$mod, C, exec, code"
        "$mod, S, exec, spotify"
        "$mod, D, exec, vesktop"
        "$mod, T, exec, kitty"
        "$mod, J, togglesplit,"
        "$mod, L, exec, loginctl lock-session"
        "$mod, M, exec, hyprctl dispatch exit"

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
        "kitty --title hello -e bash -ic 'fastfetch; exec ${pkgs.nushell}/bin/nu'"
        "swww-daemon"
        "systemctl --user start hyprpolkitagent"
        "env QSG_RHI_BACKEND=vulkan caelestia-shell"
      ];
    };
  };
}
