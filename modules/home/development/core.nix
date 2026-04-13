{ config, pkgs, inputs, ... }:

{
  programs.git = {
    enable = true;
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
      format = "ssh";
    };
    settings = {
      user.name = "Lucas";
      user.email = "lucas@somfic.dev";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      core.hooksPath = "~/.config/git/hooks";
    };
  };

  home.file.".config/git/hooks/prepare-commit-msg" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Prefix commit messages with the Jira ticket from the branch name.
      case "$2" in message|commit|merge|squash) exit 0 ;; esac
      branch=$(git symbolic-ref --short HEAD 2>/dev/null) || exit 0
      ticket=$(printf '%s' "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
      [ -z "$ticket" ] && exit 0
      grep -qE "^$ticket[: ]" "$1" && exit 0
      tmp=$(mktemp)
      printf '%s: ' "$ticket" > "$tmp"
      cat "$1" >> "$tmp"
      mv "$tmp" "$1"
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      controlMaster = "auto";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "10m";
      identityFile = ["~/.ssh/id_ed25519_sk"];
      extraOptions = {
        IdentityAgent = "none";
      };
    };
  };
  programs.java = { enable = true; };

  home.packages = [
    inputs.committer.packages.${pkgs.system}.default
  ] ++ (with pkgs; [
    ripgrep # fast grep for telescope.nvim
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default # neovim nightly
    (inputs.caelestia-shell.packages.${pkgs.system}.default.override {
      app2unit = (pkgs.app2unit.override { withTerminalSupport = false; }).overrideAttrs (final: prev: rec {
        version = "1.0.3";
        src = pkgs.fetchFromGitHub {
          owner = "Vladimir-csp";
          repo = "app2unit";
          tag = "v${version}";
          hash = "sha256-7eEVjgs+8k+/NLteSBKgn4gPaPLHC+3Uzlmz6XB0930=";
        };
      });
    })
    jetbrains.idea
    just # running commands
    mprocs # running multiple processes
    difftastic # structural diff tool

    # Network tools
    sshfs
    sshpass
    filezilla
    openvpn
    networkmanagerapplet # NetworkManager GUI for VPN management
    httpie # HTTP client for API testing
  ]);
}
