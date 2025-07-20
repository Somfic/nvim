{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 35;
        spacing = 5;
        margin-top = 7;
        margin-left = 14;
        margin-right = 14;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          warp-on-scroll = false;
          format = "{icon}";
          format-icons = {
            "1" = "󰲠";
            "2" = "󰲢";
            "3" = "󰲤";
            "4" = "󰲦";
            "5" = "󰲨";
            "6" = "󰲪";
            "7" = "󰲬";
            "8" = "󰲮";
            "9" = "󰲰";
            default = "󰊠";
            urgent = "󰀧";
          };
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 50;
          separate-outputs = true;
        };

        clock = {
          timezone = "Europe/Brussels";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d}";
        };

        cpu = {
          format = "  {usage}%";
          tooltip = false;
          interval = 2;
        };

        memory = {
          format = "  {}%";
          tooltip-format = "Memory: {used:0.1f}G/{total:0.1f}G";
          interval = 2;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "  {capacity}%";
          format-plugged = "  {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        network = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = "  Connected";
          tooltip-format = "{ifname} via {gwaddr}";
          format-linked = "  {ifname} (No IP)";
          format-disconnected = "  Disconnected";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}%";
          format-bluetooth-muted = "󰖁 {icon}";
          format-muted = "󰖁";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
          scroll-step = 5;
        };

        tray = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "Monocraft", "Font Awesome 6 Free";
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: #cdd6f4;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: rgba(30, 30, 46, 0.8);
        border-radius: 15px;
        margin: 0 5px;
        padding: 0 10px;
      }

      /* Workspaces */
      #workspaces {
        background: transparent;
        margin: 0;
        padding: 0;
      }

      #workspaces button {
        background: transparent;
        color: #6c7086;
        border-radius: 10px;
        margin: 2px;
        padding: 5px 8px;
        transition: all 0.3s ease;
      }

      #workspaces button.active {
        background: #89b4fa;
        color: #1e1e2e;
      }

      #workspaces button.urgent {
        background: #f38ba8;
        color: #1e1e2e;
      }

      #workspaces button:hover {
        background: #45475a;
        color: #cdd6f4;
      }

      /* Window title */
      #window {
        background: transparent;
        color: #cdd6f4;
        font-weight: bold;
        margin-left: 10px;
      }

      /* Clock */
      #clock {
        background: transparent;
        color: #cdd6f4;
        font-weight: bold;
        font-size: 14px;
      }

      /* System info modules */
      #cpu,
      #memory,
      #battery,
      #network,
      #pulseaudio {
        background: transparent;
        color: #cdd6f4;
        margin: 0 3px;
        padding: 0 5px;
      }

      #cpu {
        color: #94e2d5;
      }

      #memory {
        color: #f9e2af;
      }

      #battery {
        color: #a6e3a1;
      }

      #battery.warning {
        color: #f9e2af;
      }

      #battery.critical {
        color: #f38ba8;
        animation: blink 1s linear infinite;
      }

      @keyframes blink {
        to {
          opacity: 0.5;
        }
      }

      #network {
        color: #89b4fa;
      }

      #network.disconnected {
        color: #f38ba8;
      }

      #pulseaudio {
        color: #cba6f7;
      }

      #pulseaudio.muted {
        color: #6c7086;
      }

      /* System tray */
      #tray {
        background: transparent;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #f38ba8;
        border-radius: 10px;
      }

      /* Tooltips */
      tooltip {
        background: rgba(30, 30, 46, 0.9);
        border: 1px solid #45475a;
        border-radius: 10px;
        color: #cdd6f4;
      }

      tooltip label {
        color: #cdd6f4;
      }
    '';
  };
}
