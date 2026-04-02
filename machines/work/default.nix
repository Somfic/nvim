{ config, pkgs, ... }:

{
  imports = [ ../../home.nix ../../profiles/desktop-full.nix ./monitors.nix ];

  # Work profile uses Chrome instead of Brave
  programs.brave.enable = false;
  programs.firefox.enable = true;
  programs.google-chrome.enable = true;

  # Override Super+F to open Chrome
  wayland.windowManager.hyprland.settings.bind =
    [ "$mod, F, exec, google-chrome-stable" ];

  # GNOME: override browser to Chrome
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4".command = "google-chrome-stable";

  # Niri: override browser to Chrome
  xdg.configFile."niri/machine.kdl".text = ''
    binds {
        Mod+F { spawn "google-chrome-stable"; }
    }
  '';
}
