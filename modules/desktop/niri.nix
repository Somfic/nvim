{ pkgs, ... }:

{
  programs.niri.enable = true;

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    LD_LIBRARY_PATH = "${pkgs.wayland}/lib";
  };
}
