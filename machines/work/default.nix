{ config, pkgs, ... }:

{
  imports = [ ../../home.nix ../../profiles/desktop-full.nix ./monitors.nix ];

  # Work profile uses Chrome instead of Brave
  programs.brave.enable = false;
  programs.google-chrome.enable = true;

  # Override Super+F to open Chrome
  wayland.windowManager.hyprland.settings.bind = [
    "$mod, F, exec, google-chrome-stable"
  ];
}
