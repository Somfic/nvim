{ config, pkgs, ... }:

{
  programs = {
    fastfetch = { enable = true; };

    nh = {
      enable = true;
      clean.enable = true;
      flake = "${config.home.homeDirectory}/dot";
    };

    gh.enable = true;

    direnv = {
      enable = true;
      silent = true;
    };

    lazydocker.enable = true;
    lazygit.enable = true;
  };
}
