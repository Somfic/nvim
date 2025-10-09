{ config, pkgs, ... }:

{
  programs = {
    fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = "nixos";
          type = "auto";
        };
      };
    };

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