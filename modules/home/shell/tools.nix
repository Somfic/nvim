{ config, pkgs, ... }:

{
  programs = {
    fastfetch = { enable = true; };

    nh = {
      enable = true;
      clean.enable = true;
      flake = "/home/lucas/dot";
    };

    gh.enable = true;

    direnv = {
      enable = true;
      silent = true;
    };

    lazydocker.enable = true;
  };
}
