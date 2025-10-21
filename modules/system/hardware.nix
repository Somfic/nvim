{ config, pkgs, ... }:

{
  # General graphics support (works for both Intel and NVIDIA)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA-specific settings moved to machines/home/system.nix
}
