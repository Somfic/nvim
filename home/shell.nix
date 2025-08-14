{ config, pkgs, ... }:

{
  programs = {
    nushell = {
      enable = true;
      shellAliases = {
        "cd" = "z";
        "cd.." = "z ..";
        ".." = "z ..";
        "g" = "git";
        "ll" = "ls -l";
        "cls" = "clear";
        "reload-debug" = "sudo nixos-rebuild switch --flake ~/dot";
        "reload" = "nh os switch ~/dot";
        "update" = "sudo nix flake update --flake ~/dot";
        "clean" = "nh clean all --keep-since 7d";
        "clock" = "termdown -zsf roman";
        "dev" = "nix develop -c nu";
      };
      settings = { show_banner = false; };
    };

    # carapace = {
    #   enable = true;
    #   enableNushellIntegration = true;
    # };

    starship = {
      enable = true;
      settings = { add_newline = true; };
    };

    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };

    fastfetch.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      flake = "/home/lucas/dot";
    };

    git = {
      enable = true;
      userEmail = "lucas@somfic.dev";
      userName = "Lucas";
    };

    gh.enable = true;
    direnv = {
      enable = true;
      silent = true;
    };
    lazydocker.enable = true;
  };
}
