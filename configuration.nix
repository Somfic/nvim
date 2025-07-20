{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
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
    users.lucas = import ./home.nix;
    backupFileExtension = "backup";
    sharedModules = [
      inputs.spicetify-nix.homeManagerModules.spicetify
      {
        stylix.autoEnable = true;
        stylix.targets.spicetify.enable = false;
        stylix.targets.vscode.enable = false;
      }
    ];
  };

  # General NixOS settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}
