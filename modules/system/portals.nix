{ config, pkgs, lib, ... }:

{
  # XDG Desktop Portal configuration for screen sharing and file pickers
  xdg.portal = {
    enable = true;

    # Note: xdg-desktop-portal-hyprland is provided by programs.hyprland
    # Only add gtk portal here to avoid conflicts
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
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
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };

      # GNOME-specific configuration
      gnome = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };

      # Niri uses gnome portal (provided by programs.niri)
      niri = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
    };
  };

  # Note: xdg-desktop-portal-gtk must also be in home.packages (hyprland-base.nix)
  # so its .portal file is visible via NIX_XDG_DESKTOP_PORTAL_DIR
}
