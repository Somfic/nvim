{ config, pkgs, ... }:

{
  imports = [
    ../../home.nix
    ../../profiles/desktop-full.nix
    ./monitors.nix
    ../../modules/home/gaming/packages.nix
  ];

  # Home profile uses Firefox and Chrome instead of Brave
  programs.brave.enable = false;
  programs.firefox.enable = true;
  programs.google-chrome.enable = true;

  # Override Super+F to open Firefox
  wayland.windowManager.hyprland.settings.bind = [
    "$mod, F, exec, firefox"
  ];

  # Niri: override browser to Firefox
  xdg.configFile."niri/machine.kdl".text = ''
    binds {
        Mod+F { spawn "firefox"; }
    }
  '';
}
