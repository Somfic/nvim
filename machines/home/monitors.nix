{ config, ... }:

{
  # Home machine monitor configuration
  # Monitors are now configured via GUI (nwg-displays)
  # Press Super+O to open monitor settings, or run: nwg-displays
  # Configuration is saved to ~/.config/hypr/monitors.conf

  # Fallback monitor configuration (if monitors.conf doesn't exist)
  wayland.windowManager.hyprland.settings.monitor = [
    "DP-1, 3440x1440@144, 0x0, 1.25"
    "DP-2, preferred, auto-right, 1.25"
    "DP-3, preferred, auto-left, 1.25"
  ];

  # Home machine wallpaper setup
  wayland.windowManager.hyprland.settings.exec-once = [
    "sleep 1 && swww img --outputs DP-1 ${config.home.homeDirectory}/dot/wallpapers/neon4.jpg"
    "sleep 1 && swww img --outputs DP-2 ${config.home.homeDirectory}/dot/wallpapers/neon1.jpg"
    "sleep 1 && swww img --outputs DP-3 ${config.home.homeDirectory}/dot/wallpapers/neon1.jpg"
  ];

  # Niri monitor configuration
  xdg.configFile."niri/monitors.kdl".text = ''
    output "DP-1" {
        mode "3440x1440@143.998"
        scale 1.25
        position x=0 y=0
    }

    output "DP-2" {
        scale 1.25
        position x=2752 y=0
    }

    output "DP-3" {
        scale 1.25
        position x=-1536 y=0
    }

    // Wallpapers per monitor
    spawn-at-startup "bash" "-c" "sleep 1 && swww img --outputs DP-1 ${config.home.homeDirectory}/dot/wallpapers/neon4.jpg"
    spawn-at-startup "bash" "-c" "sleep 1 && swww img --outputs DP-2 ${config.home.homeDirectory}/dot/wallpapers/neon1.jpg"
    spawn-at-startup "bash" "-c" "sleep 1 && swww img --outputs DP-3 ${config.home.homeDirectory}/dot/wallpapers/neon1.jpg"
  '';
}
