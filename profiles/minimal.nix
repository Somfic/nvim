{ config, ... }:

{
  # Minimal profile for work/server environments
  imports = [
    # Essential shell
    ../modules/home/shell/nushell.nix
    ../modules/home/shell/tools.nix

    # Core development tools
    ../modules/home/development/core.nix
    ../modules/home/development/dotfiles.nix

    # Basic browser for work
    ../modules/home/productivity/browser.nix
  ];
}