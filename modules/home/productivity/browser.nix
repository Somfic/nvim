{ config, pkgs, lib, ... }:

{
  # Default browser is Brave, but can be overridden per-machine
  programs.brave.enable = lib.mkDefault true;
  programs.firefox.enable = lib.mkDefault false;
  programs.google-chrome.enable = lib.mkDefault false;
}
