{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code
    gemini-cli
    termdown # terminal clock
    font-awesome # icons
  ];
}
