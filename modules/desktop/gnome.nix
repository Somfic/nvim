{ config, pkgs, lib, ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    # libinput.enable = true; # mouse and touchpad support (enabled by default in most desktopManager)
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.printing.enable = true;

  services.flatpak.enable = true;

  # Override qt platform theme to use gtk2 instead of deprecated gnome
  qt = {
    enable = true;
    platformTheme = lib.mkForce "gtk2";
  };

  # XDG Portal is automatically enabled by GNOME and Hyprland
}
