{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default

    # System modules
    ./modules/system/boot.nix
    ./modules/system/hardware.nix
    ./modules/system/networking.nix
    ./modules/system/locale.nix
    ./modules/system/users.nix
    ./modules/system/audio.nix
    ./modules/system/packages.nix
    ./modules/system/bluetooth.nix
    ./modules/system/security.nix
    ./modules/system/portals.nix
    ./modules/system/ssh.nix

    # Desktop modules
    ./modules/desktop/hyprland.nix
    ./modules/desktop/gnome.nix
    ./modules/desktop/stylix.nix

    # Program modules
    ./modules/programs/virtualization.nix
    ./modules/programs/obsidian.nix
    # gaming.nix moved to machines/home/system.nix
  ];

  # Home Manager configuration
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      {
        stylix.autoEnable = true;
        stylix.targets.vscode.enable = false;
        stylix.targets.rofi.enable = false;  # Use custom rofi theme
        stylix.targets.firefox.profileNames = [ "default" ];
        stylix.targets.qt.platform = "qtct";
      }
    ];
  };

  # General NixOS settings
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ];

  # Nix settings including binary caches
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  system.stateVersion = "25.05";

  # security
  security.polkit.enable = true;
  environment.systemPackages = [ pkgs.hyprpolkitagent ];
}
