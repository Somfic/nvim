{ config, pkgs, lib, ... }:

{
  # XDG Desktop Portal configuration for screen sharing and file pickers
  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];

    # Configure which portal to use for which interface
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };

      # Hyprland-specific configuration
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
      };

      # GNOME-specific configuration
      gnome = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
    };
  };

  # Ensure PipeWire is available for screen sharing
  # (already configured in audio.nix, but explicitly noted here)
}
