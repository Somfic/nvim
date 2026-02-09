{ config, pkgs, ... }:

{
  # Enable nix-ld for running dynamically linked binaries (e.g., VS Code server)
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    curl
    nixfmt-classic
    nix-output-monitor
    os-prober
    git
    git-lfs
    nushell
  ];
}
