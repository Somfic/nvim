{
  description = "nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
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
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hyprland-plugins, stylix
    , spicetify-nix }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./configuration.nix
            inputs.home-manager.nixosModules.default
            stylix.nixosModules.stylix
            spicetify-nix.nixosModules.spicetify
          ];
        };
      };
      homeConfigurations = {
        nixos = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            {
              wayland.windowManager.hyprland = {
                enable = true;
                package =
                  inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
              };
            }
          ];
          extraSpecialArgs = { inherit inputs; };
        };
      };
      devShells.${system} = {
        rust = pkgs.mkShell {
          buildInputs = [
            pkgs.rustc
            pkgs.cargo
            pkgs.clippy
            pkgs.rustfmt
            pkgs.rust-analyzer
            pkgs.pkg-config
            pkgs.openssl
            pkgs.bacon
            pkgs.bun
          ];
          shellHook = ''
            export RUST_LOG=info
          '';
        };
      };
    };
}
