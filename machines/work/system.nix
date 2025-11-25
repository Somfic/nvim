{ config, ... }:

{
  networking.hostName = "work";

  # Enable ClamAV antivirus for work machine
  security.clamav.enable = true;
}