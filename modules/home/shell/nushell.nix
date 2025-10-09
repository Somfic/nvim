{ config, pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    shellAliases = {
      "cd" = "z";
      "cd.." = "z ..";
      ".." = "z ..";
      "g" = "git";
      "ll" = "ls -l";
      "cls" = "clear";
      "reload-debug" = "sudo nixos-rebuild switch --flake ~/dot#home";
      "reload" = "nh os switch ~/dot --hostname home";
      "reload-work" = "nh os switch ~/dot --hostname work";
      "reload-home" = "nh os switch ~/dot --hostname home";
      "update" = "sudo nix flake update --flake ~/dot";
      "clean" = "nh clean all --keep-since 7d";
      "clock" = "termdown -zsf roman";
      "dev" = "nix develop -c nu";
    };
    settings = { show_banner = false; };
  };

  programs.starship = {
    enable = true;
    settings = { add_newline = true; };
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
}