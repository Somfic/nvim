{ config, pkgs, ... }:

{
  imports = [
    ../../home.nix
    ../../profiles/desktop-full.nix
    ./monitors.nix
    ../../modules/home/gaming/packages.nix
  ];
}
