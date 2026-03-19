{ config, pkgs, lib, ... }:

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

  # Use YubiKey GPG key for Git signing on home machine
  programs.git.signing = {
    key = lib.mkForce "C3F0BAC5B5186FAE60D3B747F643BFAAB0E1BF9A";
    format = lib.mkForce "openpgp";
  };

  # Niri: override browser to Firefox
  xdg.configFile."niri/machine.kdl".text = ''
    binds {
        Mod+F { spawn "firefox"; }
    }
  '';
}
