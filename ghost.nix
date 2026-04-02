{ config, pkgs, inputs, lib, ... }:

{
  # Base home configuration for ghost user
  programs.home-manager.enable = true;

  home = {
    username = "ghost";
    homeDirectory = "/home/ghost";
    stateVersion = "25.05";
  };
}
