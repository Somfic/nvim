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
    };
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
