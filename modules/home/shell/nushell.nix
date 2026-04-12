{ config, pkgs, ... }:

{
  services.ssh-agent.enable = true;

  # Use bash as login shell but launch nushell for interactive sessions
  # This allows VS Code Remote SSH to work (needs POSIX shell for setup)
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $- == *i* ]] && [[ -z "$VSCODE_IPC_HOOK_CLI" ]]; then
        exec ${pkgs.nushell}/bin/nu
      fi
    '';
  };

  programs.nushell = {
    enable = true;
    shellAliases = {
      "cd" = "z";
      "cd.." = "z ..";
      ".." = "z ..";
      "g" = "git";
      "ll" = "ls -l";
      "c" = "lazygit";
      "ff" = "fastfetch";
      "bos" = "z ~/bos";
      "cls" = "clear";
      "diff" = "difft";
      "reload-debug" = "sudo nixos-rebuild switch --flake ~/dot#home";
      "reload" = "nh os switch ~/dot --hostname home";
      "reload-work" = "nh os switch ~/dot --hostname work";
      "reload-home" = "nh os switch ~/dot --hostname home";
      "update" = "sudo nix flake update --flake ~/dot";
      "clean" = "nh clean all --keep-since 7d";
      "clock" = "termdown -zsf roman";
      "dev" = "nix develop -c nu";
      "q" = "exit";
      ":q" = "exit";
    };
    extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME | path join ".cargo" "bin"))
    '';
    settings = {
      show_banner = false;
      completions = {
        algorithm = "fuzzy";
        quick = true;
        partial = true;
      };
    };
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
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