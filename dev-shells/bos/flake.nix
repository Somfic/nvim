{
  description = "BOS development environment";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/e643668fd71b949c53f8626614b21ff71a07379d";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Language servers for neovim
            typescript-language-server # TypeScript/JavaScript
            eslint_d # ESLint daemon for fast linting
            jdt-language-server # Java
            dockerfile-language-server-nodejs # Docker
            yaml-language-server # YAML
            vscode-langservers-extracted # JSON language server
            graphql-language-service-cli # GraphQL
            taplo # TOML language server

            # Additional development tools for BOS project
            nodejs_20
            yarn
            jdk17
            kotlin
            gradle
            docker
            docker-compose
            awscli2
          ];

          shellHook = ''
                        # Fix gradlew permissions if it exists
                        if [ -f "./gradlew" ]; then
                            chmod +x ./gradlew
                            echo "✓ Made gradlew executable"
                        fi

            echo "🚢 BOS development environment loaded!"
                               echo "Available language servers:"
                               echo "  - typescript-language-server (TypeScript/JavaScript)"
                               echo "  - jdtls (Java)"
                               echo "  - dockerfile-language-server-nodejs (Docker)"
                               echo "  - yaml-language-server (YAML)"
                               echo "  - vscode-json-languageserver (JSON)"
                               echo "  - graphql-lsp (GraphQL)"
                               echo "  - taplo (TOML)"
                               echo ""
                               echo "Usage: cd ~/bos && nix develop ~/dot/dev-shells/bos"
          '';
        };
      });
}
