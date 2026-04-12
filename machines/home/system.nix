{ config, pkgs, ... }:

{
  imports = [
    ../../modules/programs/gaming.nix
    ../../modules/system/tor.nix
  ];

  networking.hostName = "home";

  # Flatpak for apps not available in nixpkgs (e.g., Stremio)
  services.flatpak.enable = true;

  # NVIDIA GPU configuration
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia-container-toolkit.enable = true;
}