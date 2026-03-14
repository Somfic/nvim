{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code
    termdown # terminal clock
    font-awesome # icons
  ];
}
