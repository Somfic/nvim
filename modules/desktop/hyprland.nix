{ config, pkgs, inputs, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    # withUWSM = true;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    # Required for localsearch (file indexer) to start.
    # Without this, GTK file picker search hangs/crashes.
    XDG_SESSION_CLASS = "user";
  };

  # XDG Portal configuration - handled in modules/system/portals.nix
}
