{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    termdown # terminal clock
    font-awesome # icons
    papirus-icon-theme # icons for rofi
  ];
}
