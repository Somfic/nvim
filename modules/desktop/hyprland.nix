{ config, pkgs, inputs, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    # withUWSM = true;
    xwayland.enable = true;
    # portalPackage removed - managed centrally in portals.nix
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  # XDG Portal configuration - handled in modules/system/portals.nix
}
