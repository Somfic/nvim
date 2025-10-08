{ config, pkgs, ... }:

{
  services.vicinae = {
    enable = true;
    autoStart = true;
  };

  home.packages = with pkgs; [
    rofi
  ];
}
