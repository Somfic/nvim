{ config, pkgs, inputs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      controlMaster = "auto";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "10m";
    };
  };
  programs.java = { enable = true; };

  home.packages = with pkgs; [
    ripgrep # fast grep for telescope.nvim
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default # neovim nightly
    inputs.caelestia-shell.packages.${pkgs.system}.default # caelestia shell
    jetbrains-toolbox
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
  ];
}
