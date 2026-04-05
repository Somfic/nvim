{ config, pkgs, ... }:

{
  # Enable nix-ld for running dynamically linked binaries (e.g., VS Code server)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ glibc zlib openssl stdenv.cc.cc.lib ];
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    nixfmt-classic
    nix-output-monitor
    os-prober
    git
    git-lfs
    nushell
    ntfs3g
    nwg-displays
    android-tools
  ];
}
