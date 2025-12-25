{ config, pkgs, inputs, ... }:

{
  stylix = {
    enable = true;
    base16Scheme = {
      base00 = "16181a"; # bg
      base01 = "1e2124"; # bg_alt
      base02 = "3c4048"; # bg_highlight
      base03 = "7b8496"; # grey (comments)
      base04 = "7b8496"; # grey
      base05 = "ffffff"; # fg
      base06 = "ffffff"; # fg
      base07 = "ffffff"; # fg
      base08 = "ff6e5e"; # red
      base09 = "ffbd5e"; # orange
      base0A = "f1ff5e"; # yellow
      base0B = "5eff6c"; # green
      base0C = "5ef1ff"; # cyan
      base0D = "5ea1ff"; # blue
      base0E = "bd5eff"; # purple
      base0F = "ff5ea0"; # pink
    };
    # image = ./../../wallpapers/neon3.jpg;  # Disabled for slideshow
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
    iconTheme = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
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
