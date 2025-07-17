{ config, pkgs, inputs, ... }:

{
  stylix = {
    enable = true;
    image = ./../../wallpapers/neon1.jpg;
    polarity = "dark";
    opacity = {
      applications = 0.9;
      desktop = 0.5;
      terminal = 0.9;
      popups = 0.9;
    };
    autoEnable = true;
    targets.spicetify.enable = false;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 18;
    };
    fonts = {
      monospace = {
        package = pkgs.monocraft;
        name = "Monocraft";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };
  };
}
