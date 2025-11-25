{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    curl
    nixfmt-classic
    nix-output-monitor
    os-prober
    git
    git-lfs
  ];
}
