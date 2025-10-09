{ config, pkgs, ... }:

{
  programs = {
    vscode.enable = true;

    kitty = {
      enable = true;
      settings = { window_padding_width = 14; };
    };
  };

  home.packages = with pkgs; [
    github-desktop
  ];
}