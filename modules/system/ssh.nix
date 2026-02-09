{ config, pkgs, ... }:

let
  sshNotify = pkgs.writeShellScript "ssh-notify" ''
    export DISPLAY=:0
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

    if [ "$PAM_TYPE" = "open_session" ]; then
      ${pkgs.libnotify}/bin/notify-send "SSH Login" "$PAM_USER connected from $PAM_RHOST"
    elif [ "$PAM_TYPE" = "close_session" ]; then
      ${pkgs.libnotify}/bin/notify-send "SSH Logout" "$PAM_USER disconnected from $PAM_RHOST"
    fi
  '';
in
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  security.pam.services.sshd.rules.session.notify = {
    order = 12500;
    control = "optional";
    modulePath = "${pkgs.pam}/lib/security/pam_exec.so";
    args = [ "seteuid" (toString sshNotify) ];
  };

  users.users.lucas.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6CPzUXNeFyJWtAoTXlToGe5Fa8PDvSLl+apbC8tUHS somfic@gmail.com"
  ];
}
