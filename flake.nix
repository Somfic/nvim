{
  description = "nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprland-plugins, stylix
    , neovim-nightly-overlay, caelestia-shell, split-monitor-workspaces }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      # Helper function to create machine configurations
      mkMachine = hostname: machineModule: hardwareModule: systemModule: {
        "${hostname}" = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./configuration.nix
            hardwareModule
            systemModule
            inputs.home-manager.nixosModules.default
            stylix.nixosModules.stylix
            { home-manager.users.lucas = import machineModule; }
          ];
        };
      };

    in {
      nixosConfigurations = (mkMachine "home" ./machines/home/default.nix
        ./machines/home/hardware.nix ./machines/home/system.nix)
        // (mkMachine "work" ./machines/work/default.nix
          ./machines/work/hardware.nix ./machines/work/system.nix);
    };
}
