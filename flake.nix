{
  description = "nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = { url = "github:Gerg-L/spicetify-nix"; };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprland-plugins, stylix
    , spicetify-nix, neovim-nightly-overlay, caelestia-shell, vicinae }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      # Helper function to create machine configurations
      mkMachine = hostname: machineModule: hardwareModule: {
        "${hostname}" = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./configuration.nix
            hardwareModule
            inputs.home-manager.nixosModules.default
            stylix.nixosModules.stylix
            spicetify-nix.nixosModules.spicetify
            {
              home-manager.users.lucas = import machineModule;
            }
          ];
        };
      };

    in {
      nixosConfigurations =
        (mkMachine "home" ./machines/home/default.nix ./machines/home/hardware.nix) //
        (mkMachine "work" ./machines/work/default.nix ./machines/work/hardware.nix);
    };
}
