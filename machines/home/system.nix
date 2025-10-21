{ config, ... }:

{
  imports = [
    ../../modules/programs/gaming.nix
  ];

  networking.hostName = "home";

  # NVIDIA GPU configuration
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia-container-toolkit.enable = true;
}