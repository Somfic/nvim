{ config, pkgs, lib, inputs, ... }:

let
  astalPkgs = inputs.astal-niri.packages.${pkgs.system};
  delta-shell-src = pkgs.fetchFromGitHub {
    owner = "Sinomor";
    repo = "delta-shell";
    rev = "d0a93f9efc576b12f4983554353a7ab222fa13ac";
    hash = "sha256-zZhkP284YlC3dH/8/EqlhBoc9imIXv+27ZPHpq5wZI0=";
  };
  c = config.lib.stylix.colors;
in
{
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    grim
    slurp
    swaylock
  ];

  programs.ags = {
    enable = true;
    configDir = delta-shell-src;
    extraPackages = [
      astalPkgs.apps
      astalPkgs.battery
      astalPkgs.bluetooth
      astalPkgs.mpris
      astalPkgs.network
      astalPkgs.notifd
      astalPkgs.powerprofiles
      astalPkgs.tray
      astalPkgs.wireplumber
      astalPkgs.niri
      astalPkgs.hyprland
      pkgs.libadwaita
      pkgs.dart-sass
      pkgs.ddcutil
      pkgs.brightnessctl
    ];
  };

  # Delta Shell theme — colors from stylix
  xdg.configFile."delta-shell/theme.json".text = builtins.toJSON {
    font = {
      size = 14;
      name = config.stylix.fonts.sansSerif.name;
    };
    colors = {
      bg = {
        "0" = "#${c.base00}";
        "1" = "#${c.base01}";
        "2" = "#${c.base02}";
        "3" = "#${c.base03}";
      };
      fg = {
        "0" = "#${c.base05}";
        "1" = "#${c.base04}";
        "2" = "#${c.base03}";
      };
      accent = "#${c.base0D}";
      blue = "#${c.base0D}";
      cyan = "#${c.base0C}";
      green = "#${c.base0B}";
      yellow = "#${c.base0A}";
      orange = "#${c.base09}";
      red = "#${c.base08}";
      purple = "#${c.base0E}";
    };
    spacing = 10;
    shadow = true;
    radius = 12;
    icon-size = {
      normal = 20;
      small = 16;
      large = 32;
    };
    window = {
      padding = 15;
      opacity = 0.85;
      margin = 10;
      border = {
        width = 2;
        color = "$bg2";
      };
      outline = {
        width = 0;
        color = "$bg2";
      };
      shadow = {
        offset = [ 0 0 ];
        blur = 15;
        spread = 0;
        color = "black";
        opacity = 0.5;
      };
    };
    bar = {
      bg = "$bg0";
      opacity = 0.85;
      margin = [ 6 6 0 6 ];
      padding = 6;
      spacing = 6;
      border = {
        width = 0;
        color = "$bg2";
      };
      shadow = {
        offset = [ 0 2 ];
        blur = 10;
        spread = 0;
        color = "black";
        opacity = 0.3;
      };
      separator = {
        width = 2;
        color = "$bg2";
      };
      button = {
        fg = "$fg0";
        padding = [ 0 8 ];
        bg = {
          default = "$bg0";
          hover = "$bg1";
          active = "$bg2";
        };
        opacity = 1;
        border = {
          width = 0;
          color = "$bg2";
        };
      };
    };
  };

  # Delta Shell config
  xdg.configFile."delta-shell/config.json".text = builtins.toJSON {
    transition = 0.2;
    bar = {
      size = 40;
      position = "top";
      modules = {
        start = [ "launcher" "workspaces" ];
        center = [ "clock" ];
        end = [ "recordindicator" "tray" "volume" "network" "notifications" "quicksettings" ];
        launcher = {
          format = "{icon}";
          on-click = "toggle-launcher";
        };
        clock = {
          format = "%b %d  %H:%M";
          on-click = "toggle-calendar";
        };
        workspaces = {
          workspace-format = "{id}";
          hide-empty = true;
        };
        volume = {
          format = "{icon}";
          on-click = "toggle-volume";
          on-click-middle = "volume-toggle";
          on-scroll-up = "volume-up";
          on-scroll-down = "volume-down";
        };
        network = {
          format = "{icon}";
          on-click = "toggle-network";
        };
        notifications = {
          format = "{icon}";
          on-click = "toggle-notifs";
        };
        quicksettings = {
          format = "{icon}";
          on-click = "toggle-qs";
        };
        tray = { compact = true; };
        recordindicator = {
          format = "{icon}";
          on-click = "screenrecord-toggle";
        };
      };
    };
    quicksettings = {
      buttons = [ "network" "bluetooth" "notifications" "screenrecord" ];
      sliders = [ "volume" "brightness" ];
    };
    launcher = {
      width = 500;
      height = 600;
      centered = true;
      columns = 1;
      sort-type = "frequency";
    };
    clipboard = {
      enabled = true;
      max-items = 50;
      image-preview = true;
      width = 400;
      height = 500;
    };
    osd = {
      enabled = true;
      vertical = false;
      width = 300;
      height = 56;
      position = "bottom";
      timeout = 3;
    };
    notifications = {
      position = "top-right";
      enabled = true;
      timeout = 5;
      width = 400;
      list.height = 500;
    };
    weather.enabled = false;
  };

  # Niri KDL configuration
  xdg.configFile."niri/config.kdl".text = ''
    // Machine-specific monitor config
    include "monitors.kdl"
    // Machine-specific keybind overrides
    include "machine.kdl"

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            tap
            natural-scroll
        }

        focus-follows-mouse max-scroll-amount="0%"
    }

    cursor {
        xcursor-theme "Bibata-Modern-Classic"
        xcursor-size 24
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    layout {
        gaps 6

        focus-ring {
            off
        }

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width {
            proportion 0.5
        }
    }

    // Rounded corners for all windows
    window-rule {
        geometry-corner-radius 20
        clip-to-geometry true
    }

    // Force kitty opaque (no compositor blur available)
    window-rule {
        match app-id="kitty"
        opacity 1.0
    }

    // Window rules
    window-rule {
        match app-id=r#"^org\.gnome\."#
        opacity 0.85
    }

    window-rule {
        match app-id="nautilus"
        opacity 0.85
    }

    window-rule {
        match app-id=r#"^(codium|Codium|vscodium|VSCodium|code|Code)$"#
        opacity 0.85
    }

    // Startup applications
    spawn-at-startup "swww-daemon"
    spawn-at-startup "ags" "run" "--define" "DATADIR=null"
    spawn-at-startup "kitty" "--title" "hello" "-e" "bash" "-ic" "fastfetch; exec ${pkgs.nushell}/bin/nu"

    binds {
        // Application launchers
        Mod+R { spawn "ags" "-i" "delta-shell" "request" "toggle" "applauncher"; }
        Mod+C { spawn "code"; }
        Mod+S { spawn "spotify"; }
        Mod+D { spawn "vesktop"; }
        Mod+T { spawn "kitty"; }
        Mod+P { spawn "passbolt-rofi"; }
        Mod+N { spawn "vpn-rofi"; }

        // Window management
        Mod+Q { close-window; }
        Mod+V { toggle-window-floating; }
        Mod+Shift+V { fullscreen-window; }

        // Focus movement (columns = horizontal, windows = vertical within column)
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up { focus-window-up; }
        Mod+Down { focus-window-down; }

        // Move windows
        Mod+Shift+Left { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up { move-window-up; }
        Mod+Shift+Down { move-window-down; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        // Screenshots
        Print { screenshot; }
        Mod+Shift+S { screenshot; }

        // Lock and session
        Mod+L { spawn "swaylock"; }
        Mod+M { spawn "bash" "-c" "loginctl terminate-session $XDG_SESSION_ID"; }

        // Clipboard
        Mod+Shift+C { spawn "clipboard-rofi"; }

        // Niri-specific: exit compositor
        Mod+Shift+E { quit; }

        // Niri-specific: cycle preset column widths
        Mod+W { switch-preset-column-width; }

        // Niri-specific: column management
        Mod+BracketLeft { consume-window-into-column; }
        Mod+BracketRight { expel-window-from-column; }

        // Niri-specific: resize
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        // Niri-specific: maximize column
        Mod+Shift+F { maximize-column; }

        // Pan columns with Mod + scroll wheel
        Mod+WheelScrollDown { focus-column-right; }
        Mod+WheelScrollUp { focus-column-left; }
        Mod+WheelScrollRight { focus-column-right; }
        Mod+WheelScrollLeft { focus-column-left; }

        // Audio controls
        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
    }
  '';

  # Swaylock config
  xdg.configFile."swaylock/config".text = ''
    daemonize
    show-failed-attempts
    color=${config.lib.stylix.colors.base00}
    inside-color=${config.lib.stylix.colors.base01}
    ring-color=${config.lib.stylix.colors.base0D}
    key-hl-color=${config.lib.stylix.colors.base0B}
    bs-hl-color=${config.lib.stylix.colors.base08}
    text-color=${config.lib.stylix.colors.base05}
    indicator-radius=100
    indicator-thickness=10
  '';

  # Ensure Screenshots directory exists
  home.activation.ensureNiriScreenshotDir =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/Pictures/Screenshots"
    '';

  # Ensure machine.kdl exists (empty default if not overridden)
  home.activation.ensureNiriMachineKdl =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.config/niri/machine.kdl" ]; then
        $DRY_RUN_CMD mkdir -p "$HOME/.config/niri"
        $DRY_RUN_CMD touch "$HOME/.config/niri/machine.kdl"
      fi
    '';

  # Ensure monitors.kdl exists (empty default if not overridden)
  home.activation.ensureNiriMonitorsKdl =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/.config/niri/monitors.kdl" ]; then
        $DRY_RUN_CMD mkdir -p "$HOME/.config/niri"
        $DRY_RUN_CMD touch "$HOME/.config/niri/monitors.kdl"
      fi
    '';
}
