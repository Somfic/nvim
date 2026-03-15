{ config, ... }:

{
  # Work machine monitor configuration
  # Monitors are now configured via GUI (nwg-displays)
  # Press Super+O to open monitor settings, or run: nwg-displays
  # Configuration is saved to ~/.config/hypr/monitors.conf

  # Fallback monitor configuration (if monitors.conf doesn't exist)
  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 1920x1080@60, 0x0, 1.25"
    # Add work-specific monitors here
  ];

  # Wallpaper: random unique wallpaper per monitor
  wayland.windowManager.hyprland.settings.exec-once = [ "set-wallpaper" ];

  # Niri monitor configuration
  xdg.configFile."niri/monitors.kdl".text = ''
    output "eDP-1" {
        mode "1920x1080@60.000"
        scale 1.25
        position x=0 y=0
    }

    // Random unique wallpaper per monitor
    spawn-at-startup "set-wallpaper"
  '';
}
