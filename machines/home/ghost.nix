{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../../ghost.nix
    ../../profiles/privacy.nix
  ];

  # Disable SSH agent — ghost should not maintain key material
  services.ssh-agent.enable = lib.mkForce false;

  # Privacy-focused git config
  programs.git = {
    enable = true;
    settings.user = {
      name = "ghost";
      email = "ghost@localhost";
    };
  };

  # Neovim from nightly overlay
  home.packages = [
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
  ];

  # Clean ghost cache/temp on logout
  systemd.user.services.ghost-cleanup = {
    Unit.Description = "Clean ghost cache on logout";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "ghost-cleanup" ''
        rm -rf ~/.cache ~/.local/share/recently-used.xbel
      ''}";
    };
    Install.WantedBy = [ "exit.target" ];
  };

  # Firefox keybind
  wayland.windowManager.hyprland.settings.bind = [
    "$mod, F, exec, firefox"
  ];

  # Kitty with same padding as lucas
  programs.kitty = {
    enable = true;
    settings = { window_padding_width = 14; };
  };
}
