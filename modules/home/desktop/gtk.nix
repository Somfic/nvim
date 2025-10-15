{ config, pkgs, ... }:

{
  # Install icon theme for desktop apps
  home.packages = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme # Fallback icon theme
  ];

  # Configure GTK to use Papirus icons (QML apps respect GTK settings)
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Ensure XDG environment variables are set for icon discovery
  home.sessionVariables = { XCURSOR_THEME = "Bibata-Modern-Classic"; };
}
