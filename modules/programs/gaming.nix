{ config, pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
  };

  environment.systemPackages = with pkgs; [ mangohud protonup-ng ];
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATH =
      "/home/lucas/.steam/root/compatibilitytools.d";
    STEAM_FORCE_DESKTOPUI_SCALING = "1.25";
  };
}
