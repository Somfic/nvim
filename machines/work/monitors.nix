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

  # Work machine wallpaper setup
  wayland.windowManager.hyprland.settings.exec-once = [
    "sleep 1 && swww img --outputs eDP-1 /home/lucas/dot/wallpapers/neon1.jpg"
  ];
}
