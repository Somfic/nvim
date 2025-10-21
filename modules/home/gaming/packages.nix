{ config, pkgs, ... }:

{
  # Gaming-related applications and utilities
  home.packages = with pkgs; [
    # Minecraft
    prismlauncher

    # Game launchers
    heroic # Epic Games, GOG, Amazon Prime Gaming launcher
    lutris # General purpose game launcher

    # Gaming utilities
    # mangohud is installed at system level via gaming.nix
    # gamemode is installed at system level via gaming.nix

    # Additional gaming tools can be added here
  ];
}
