{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    vesktop # discord client
    # google-chrome
  ];
}