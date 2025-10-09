{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code # ai
    termdown # terminal clock
    font-awesome # icons
    papirus-icon-theme # icons for rofi
    godot # game engine
  ];
}