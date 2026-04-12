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
      nix-direnv.enable = true;
    };

    lazydocker.enable = true;
    lazygit = {
      enable = true;
      settings = {
        promptToReturnFromSubprocess = false;
        git.pagers.diff = "difft --color=always";
        git.pagers.show = "difft --color=always";
        git.pagers.log = "difft --color=always";
        customCommands = [
          {
            key = "C";
            description = "Commit with committer";
            command = "committer";
            context = "files";
            output = "terminal";
          }
          {
            key = "A";
            description = "AI-assisted commit";
            command = ''git commit -e -m "$(committer generate)"'';
            context = "files";
            output = "terminal";
          }
        ];
      };
    };
  };
}
