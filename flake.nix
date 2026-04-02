{
  description = "nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland/v0.54.2";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces/34c266b";
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
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    caelestia-shell = {
      url = "github:caelestia-dots/shell/v1.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    astal-niri = {
      url = "github:sameoldlab/astal/feat/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal-niri";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    committer = {
      url = "github:somfic/committer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprland-plugins, stylix
    , neovim-nightly-overlay, caelestia-shell, split-monitor-workspaces
    , astal-niri, ags, spicetify-nix, committer }@inputs:
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
      nixosConfigurations = {
        home = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./configuration.nix
            ./machines/home/hardware.nix
            ./machines/home/system.nix
            inputs.home-manager.nixosModules.default
            stylix.nixosModules.stylix
            { home-manager.users.lucas = import ./machines/home/default.nix; }
            { home-manager.users.ghost = import ./machines/home/ghost.nix; }
          ];
        };
      } // (mkMachine "work" ./machines/work/default.nix
          ./machines/work/hardware.nix ./machines/work/system.nix);
    };
}
