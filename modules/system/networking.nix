{ config, pkgs, ... }:

{
  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
    firewall.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    networkmanager.dns = "systemd-resolved";
  };

  # Encrypted DNS via DNS-over-TLS (benefits all users)
  services.resolved = {
    enable = true;
    settings.Resolve = {
      FallbackDNS = [ "1.1.1.1#cloudflare-dns.com" ];
      DNS = [ "9.9.9.9#dns.quad9.net" "149.112.112.112#dns.quad9.net" ];
      DNSOverTLS = "yes";
    };
  };
}
