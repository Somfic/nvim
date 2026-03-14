{ config, pkgs, inputs, ... }:

{
  stylix = {
    enable = true;
    base16Scheme = {
      base00 = "1e1e2e"; # base
      base01 = "181825"; # mantle
      base02 = "313244"; # surface0
      base03 = "45475a"; # surface1
      base04 = "585b70"; # surface2
      base05 = "cdd6f4"; # text
      base06 = "f5e0dc"; # rosewater
      base07 = "b4befe"; # lavender
      base08 = "f38ba8"; # red
      base09 = "fab387"; # peach
      base0A = "f9e2af"; # yellow
      base0B = "a6e3a1"; # green
      base0C = "94e2d5"; # teal
      base0D = "89b4fa"; # blue
      base0E = "cba6f7"; # mauve
      base0F = "f2cdcd"; # flamingo
    };
    polarity = "dark";
    opacity = {
      applications = 0.0;
      desktop = 0.0;
      terminal = 0.0;
      popups = 0.0;
    };
    autoEnable = true;
    targets.spicetify.enable = false;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 8;
    };
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
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

  # Additional nerd fonts available system-wide
  fonts.fontconfig.enable = true;
  environment.systemPackages = with pkgs.nerd-fonts; [
    jetbrains-mono
    symbols-only # Pure icon font with all nerd font symbols
  ];
}
