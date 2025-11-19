{ config, pkgs, lib, ... }:

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
    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    # };
    gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
    gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
  };

  # Qt configuration - use gtk2 platform theme so Qt apps use GTK settings
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "gtk2";
    style.name = lib.mkForce "adwaita-dark";
  };

  # Environment variables for icon and theme discovery
  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    # Ensure icon themes are discoverable
    ICON_THEME = "Papirus-Dark";
    # Force Qt to use GTK settings including icons
    QT_QPA_PLATFORMTHEME = "gtk2";
  };
}
