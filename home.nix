{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./home/shell.nix
    ./home/desktop-apps.nix
    ./home/spicetify.nix
    ./home/hyprland.nix
    ./home/packages.nix
    ./home/dotfiles.nix
    ./home/caelestia.nix
    ./home/launcher.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = "lucas";
    homeDirectory = "/home/lucas";
    stateVersion = "25.05";
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
}
 