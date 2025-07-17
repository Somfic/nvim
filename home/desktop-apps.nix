{ config, pkgs, ... }:

{
  programs = {
    vscode.enable = true;
    firefox.enable = true;

    kitty = {
      enable = true;
      settings = { window_padding_width = 14; };
    };

    waybar.enable = true;
    rofi.enable = true;
  };
}
