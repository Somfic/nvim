{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # vesktop # discord client
    google-chat-linux # google chat desktop client
    google-chrome
  ];
}
