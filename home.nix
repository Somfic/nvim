{ config, pkgs, inputs, lib, ... }:

{
  # Base home configuration shared across all machines
  programs.home-manager.enable = true;

  home = {
    username = "lucas";
    homeDirectory = "/home/lucas";
    stateVersion = "25.05";
  };

  # nixpkgs config handled by system when using useGlobalPkgs
}