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

    # Desktop modules
    ./modules/desktop/hyprland.nix
    ./modules/desktop/gnome.nix
    ./modules/desktop/stylix.nix

    # Program modules
    ./modules/programs/gaming.nix
    ./modules/programs/virtualization.nix
    ./modules/programs/obsidian.nix
  ];

  # Home Manager configuration
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      inputs.spicetify-nix.homeManagerModules.spicetify
      inputs.vicinae.homeManagerModules.default
      {
        stylix.autoEnable = true;
        stylix.targets.spicetify.enable = false;
        stylix.targets.vscode.enable = false;
      }
    ];
  };

  # General NixOS settings
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ];

  # Nix settings including Hyprland binary cache
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys =
      [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  system.stateVersion = "25.05";

  # security
  security.polkit.enable = true;
  environment.systemPackages = [ pkgs.hyprpolkitagent ];
}
