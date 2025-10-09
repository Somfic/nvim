{ config, ... }:

{
  # Home machine monitor configuration
  wayland.windowManager.hyprland.settings.monitor = [
    "DP-1, 3440x1440@144, 0x0, 1.25"
    "DP-2, preferred, auto-right, 1.25"
    "DP-3, preferred, auto-left, 1.25"
  ];

  # Home machine wallpaper setup
  wayland.windowManager.hyprland.settings.exec-once = [
    "sleep 1 && swww img --outputs DP-1 /home/lucas/dot/wallpapers/neon4.jpg"
    "sleep 1 && swww img --outputs DP-2 /home/lucas/dot/wallpapers/neon1.jpg"
    "sleep 1 && swww img --outputs DP-3 /home/lucas/dot/wallpapers/neon1.jpg"
  ];
}
