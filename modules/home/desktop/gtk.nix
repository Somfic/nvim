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

<<<<<<< HEAD
  # Ensure XDG environment variables are set for icon discovery
  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    # QML/Qt icon theme fallback
    QT_QUICK_CONTROLS_ICON_THEME = "Papirus-Dark";
  };

  # Create Qt configuration file for icon theme
  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    icon_theme=Papirus-Dark
  '';

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    icon_theme=Papirus-Dark
  '';
=======
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
>>>>>>> 9a3d9e7 (stuff)
}
