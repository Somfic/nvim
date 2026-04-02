{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../modules/home/desktop/hyprland-minimal.nix
    ../modules/home/shell/nushell.nix
    ../modules/home/shell/tools.nix
    ../modules/home/productivity/browser-private.nix
  ];
}
