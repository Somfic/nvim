{ config, pkgs, lib, ... }:

{
  # Install icon theme for desktop apps
  home.packages = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme
    libsForQt5.qt5ct
  ];

  # GTK configuration - Stylix provides the dark theme
  gtk = {
    enable = true;
  };

  # Append transparency to Stylix's GTK CSS
  stylix.targets.gtk.extraCss = ''
    window, window.background, .background { background: transparent; }
    .sidebar, .navigation-sidebar, placessidebar { background: transparent; }
    .view, scrolledwindow, viewport { background: transparent; }

    /* Keep dialogs and popovers readable */
    popover, popover.background, .popover, .popover.background { background: @popover_bg_color; }
    dialog, dialog.background, .dialog, messagedialog { background: @dialog_bg_color; }
    menu, .menu, .context-menu { background: @popover_bg_color; }
  '';


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
