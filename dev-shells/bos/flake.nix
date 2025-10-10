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
            corretto21
            kotlin
            gradle
            docker
            docker-compose
            awscli2
          ];

          shellHook = ''
                        # Set Cofano AWS environment variables
                        export COFANO_AWS_CLI_COMMAND="aws"
                        export COFANO_AWS_CLI_PROFILE="cofano"

                        # Enable colors for Gradle and Spring Boot
                        export TERM="xterm-256color"
                        export FORCE_COLOR=1
                        export COLORTERM="truecolor"

                        # Spring Boot specific color settings
                        export SPRING_OUTPUT_ANSI_ENABLED="ALWAYS"

                        # Gradle JVM options for color support
                        export GRADLE_OPTS="-Dorg.gradle.console=rich -Dspring.output.ansi.enabled=ALWAYS"

                        # Create alias for gradle with rich console
                        alias gradle="./gradlew --console=rich"

                        # Fix gradlew permissions if it exists
                        if [ -f "./gradlew" ]; then
                            chmod +x ./gradlew
                            echo "✓ Made gradlew executable"
                        fi

                        # Auto-configure AWS SSO profile if not set up
                        if ! aws configure list --profile cofano &>/dev/null; then
                            echo "🔧 Auto-configuring AWS SSO profile 'cofano'..."

                            # Create the AWS config directory if it doesn't exist
                            mkdir -p ~/.aws

                            # Check if config file exists, create if not
                            if [ ! -f ~/.aws/config ]; then
                                touch ~/.aws/config
                            fi

                            # Check if cofano profile already exists in config
                            if ! grep -q "\[profile cofano\]" ~/.aws/config; then
                                cat >> ~/.aws/config << EOF

            [profile cofano]
            sso_session = cofano
            sso_account_id = 933071262868
            sso_role_name = Developer
            region = eu-central-1
            output = json

            [sso-session cofano]
            sso_start_url = https://cofano.awsapps.com/start
            sso_region = eu-central-1
            sso_registration_scopes = sso:account:access
            EOF
                                echo "✓ AWS SSO profile 'cofano' configured automatically"
                            else
                                echo "✓ AWS SSO profile 'cofano' already exists in config"
                            fi

                            # Check if currently logged in
                            if ! aws sts get-caller-identity --profile cofano &>/dev/null; then
                                echo "⚠️  Not logged in to AWS SSO. Run: aws sso login --profile cofano"
                                echo "This will open a browser window for authentication."
                            else
                                echo "✓ AWS SSO session is active"
                            fi
                        else
                            echo "✓ AWS SSO profile 'cofano' is configured"

                            # Check if currently logged in
                            if ! aws sts get-caller-identity --profile cofano &>/dev/null; then
                                echo "⚠️  Not logged in to AWS SSO. Run: aws sso login --profile cofano"
                            else
                                echo "✓ AWS SSO session is active"
                            fi
                        fi

                        echo "🚢 BOS development environment loaded!"
                        echo "Environment variables set:"
                        echo "  - COFANO_AWS_CLI_COMMAND=$COFANO_AWS_CLI_COMMAND"
                        echo "  - COFANO_AWS_CLI_PROFILE=$COFANO_AWS_CLI_PROFILE"
                        echo "  - TERM=$TERM (enables 256 colors)"
                        echo "  - COLORTERM=$COLORTERM (enables true colors)"
                        echo "  - FORCE_COLOR=$FORCE_COLOR (forces color output)"
                        echo "  - SPRING_OUTPUT_ANSI_ENABLED=$SPRING_OUTPUT_ANSI_ENABLED"
                        echo "  - GRADLE_OPTS=$GRADLE_OPTS"
                        echo ""
                        echo "Available language servers:"
                        echo "  - typescript-language-server (TypeScript/JavaScript)"
                        echo "  - jdtls (Java)"
                        echo "  - dockerfile-language-server-nodejs (Docker)"
                        echo "  - yaml-language-server (YAML)"
                        echo "  - vscode-json-languageserver (JSON)"
                        echo "  - graphql-lsp (GraphQL)"
                        echo "  - taplo (TOML)"
                        echo ""
                        echo "AWS CLI utilities:"
                        echo "  - aws configure sso --profile cofano (initial setup)"
                        echo "  - aws sso login --profile cofano (login/refresh)"
          '';
        };
      });
}
