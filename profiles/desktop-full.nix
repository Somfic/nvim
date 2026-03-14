{ config, ... }:

{
  # Full desktop environment profile
  imports = [
    # Desktop environment
    ../modules/home/desktop/hyprland-base.nix
    ../modules/home/desktop/caelestia.nix
    ../modules/home/desktop/niri.nix
    ../modules/home/desktop/launcher.nix
    ../modules/home/desktop/clipboard.nix
    ../modules/home/desktop/gtk.nix
    ../modules/home/desktop/monitor-config.nix

    # Shell and terminal
    ../modules/home/shell/nushell.nix
    ../modules/home/shell/tools.nix

    # Development tools
    ../modules/home/development/core.nix
    ../modules/home/development/editors.nix
    ../modules/home/development/dotfiles.nix

    # Media and entertainment
    ../modules/home/media/packages.nix
    ../modules/home/media/spicetify.nix

    # Productivity
    ../modules/home/productivity/communication.nix
    ../modules/home/productivity/tools.nix
    ../modules/home/productivity/browser.nix
  ];
}
