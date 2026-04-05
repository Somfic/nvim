{ config, pkgs, lib, ... }:

{
  options = {
    security.clamav.enable = lib.mkEnableOption "ClamAV antivirus";
  };

  config = {
    # Fail2ban for SSH brute-force protection
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
    };

    # Auditd — records security-relevant kernel events to /var/log/audit/audit.log
    security.auditd.enable = true;
    security.audit = {
      enable = true;
      rules = [
        "-a exit,always -F arch=b64 -S execve"
      ];
    };

    environment.systemPackages = with pkgs; [
      cryptsetup
      gnupg
      yubikey-manager
      # veracrypt
    ] ++ lib.optionals config.security.clamav.enable [
      clamav
    ];

    # Enable cryptsetup service for LUKS encryption
    services.udisks2.enable = true;

    # Enable GNOME Keyring for secret storage and auto-unlock on login
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
    security.pam.services.gdm-password.enableGnomeKeyring = true;

    # Enable smart card daemon for YubiKey
    services.pcscd.enable = true;

    # Enable GPG agent for key management
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };


    # Restrict polkit for ghost — deny system-level actions
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "ghost" && action.id.indexOf("org.freedesktop.systemd1") === 0) {
          return polkit.Result.NO;
        }
        if (subject.user == "ghost" && action.id.indexOf("org.freedesktop.login1") === 0) {
          return polkit.Result.AUTH_ADMIN;
        }
      });
    '';

    # ClamAV antivirus configuration
    services.clamav = lib.mkIf config.security.clamav.enable {
      daemon.enable = true;
      updater.enable = true;
      updater.frequency = 12; # Update virus definitions every 12 hours
      updater.interval = "hourly";
    };
  };
}
