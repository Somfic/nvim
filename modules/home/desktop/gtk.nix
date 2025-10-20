{ config, pkgs, ... }:

{
  # Install icon theme for desktop apps
  home.packages = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme # Fallback icon theme
    libsForQt5.qt5ct # Qt configuration tool
  ];

  # GTK configuration (Stylix handles theming)
  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt configuration (Stylix manages theming via qtct)
  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  # Environment variables for icon and theme discovery
  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    # Ensure icon themes are discoverable
    ICON_THEME = "Papirus-Dark";
  };
}
