{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cryptsetup
    gnupg
    veracrypt
  ];

  # Enable cryptsetup service for LUKS encryption
  services.udisks2.enable = true;
  
  # Enable GPG agent for key management
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}