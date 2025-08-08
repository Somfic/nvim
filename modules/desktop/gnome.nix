{ config, pkgs, ... }:

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
}
