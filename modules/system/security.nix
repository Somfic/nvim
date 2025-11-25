{ config, pkgs, lib, ... }:

{
  options = {
    security.clamav.enable = lib.mkEnableOption "ClamAV antivirus";
  };

  config = {
    environment.systemPackages = with pkgs; [
      cryptsetup
      gnupg
      # veracrypt
    ] ++ lib.optionals config.security.clamav.enable [
      clamav
    ];

    # Enable cryptsetup service for LUKS encryption
    services.udisks2.enable = true;

    # Enable GPG agent for key management
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # ClamAV antivirus configuration
    services.clamav = lib.mkIf config.security.clamav.enable {
      daemon.enable = true;
      updater.enable = true;
      updater.frequency = 12; # Update virus definitions every 12 hours
      updater.interval = "hourly";
    };
  };
}
