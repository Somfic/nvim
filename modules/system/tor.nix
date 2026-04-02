{ config, pkgs, lib, ... }:

let
  ghostUid = config.users.users.ghost.uid;
  torUid = config.users.users.tor.uid;
  transPort = 9040;
  dnsPort = 9053;
in {
  # Tor daemon with transparent proxy support
  services.tor = {
    enable = true;
    settings = {
      SOCKSPort = [{ addr = "127.0.0.1"; port = 9050; IsolateDestAddr = true; IsolateDestPort = true; }];
      TransPort = [{ addr = "127.0.0.1"; port = transPort; IsolateDestAddr = true; IsolateDestPort = true; }];
      DNSPort = [{ addr = "127.0.0.1"; port = dnsPort; }];
      VirtualAddrNetworkIPv4 = "10.192.0.0/10";
      AutomapHostsOnResolve = true;
    };
  };

  # Redirect all ghost user traffic through Tor via iptables
  networking.firewall.extraCommands = ''
    # Flush old ghost-tor rules (idempotent)
    iptables -t nat -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 53 -j REDIRECT --to-ports ${toString dnsPort} 2>/dev/null || true
    iptables -t nat -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp --dport 53 -j REDIRECT --to-ports ${toString dnsPort} 2>/dev/null || true
    iptables -t nat -D OUTPUT -m owner --uid-owner ${toString ghostUid} -d 127.0.0.0/8 -j RETURN 2>/dev/null || true
    iptables -t nat -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp -j REDIRECT --to-ports ${toString transPort} 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 5353 -j REJECT 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 5355 -j REJECT 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 53 -j ACCEPT 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp -j ACCEPT 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -j REJECT 2>/dev/null || true
    ip6tables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -j REJECT 2>/dev/null || true

    # DNS: redirect ghost's DNS queries to Tor's DNSPort
    # (must come BEFORE localhost RETURN so queries to systemd-resolved at 127.0.0.53:53 are also caught)
    iptables -t nat -A OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 53 -j REDIRECT --to-ports ${toString dnsPort}
    iptables -t nat -A OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp --dport 53 -j REDIRECT --to-ports ${toString dnsPort}

    # Allow localhost traffic (needed for Tor SOCKS/TransPort)
    iptables -t nat -A OUTPUT -m owner --uid-owner ${toString ghostUid} -d 127.0.0.0/8 -j RETURN

    # TCP: redirect all ghost TCP through Tor's TransPort
    iptables -t nat -A OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp -j REDIRECT --to-ports ${toString transPort}

    # Block mDNS/LLMNR for ghost (before general ACCEPT rules)
    iptables -A OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 5353 -j REJECT
    iptables -A OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 5355 -j REJECT

    # Allow ghost's DNS (already redirected in nat) and TCP
    iptables -A OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp -j ACCEPT

    # Block all other ghost traffic (UDP other than DNS can't go through Tor)
    iptables -A OUTPUT -m owner --uid-owner ${toString ghostUid} -j REJECT

    # Block all IPv6 traffic for ghost (prevents IPv6 leaks bypassing Tor)
    ip6tables -A OUTPUT -m owner --uid-owner ${toString ghostUid} -j REJECT
  '';

  networking.firewall.extraStopCommands = ''
    iptables -t nat -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 53 -j REDIRECT --to-ports ${toString dnsPort} 2>/dev/null || true
    iptables -t nat -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp --dport 53 -j REDIRECT --to-ports ${toString dnsPort} 2>/dev/null || true
    iptables -t nat -D OUTPUT -m owner --uid-owner ${toString ghostUid} -d 127.0.0.0/8 -j RETURN 2>/dev/null || true
    iptables -t nat -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp -j REDIRECT --to-ports ${toString transPort} 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 5353 -j REJECT 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 5355 -j REJECT 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p udp --dport 53 -j ACCEPT 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -p tcp -j ACCEPT 2>/dev/null || true
    iptables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -j REJECT 2>/dev/null || true
    ip6tables -D OUTPUT -m owner --uid-owner ${toString ghostUid} -j REJECT 2>/dev/null || true
  '';
}
