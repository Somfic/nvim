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
            dockerfile-language-server # Docker
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
            # aws env variables
            export COFANO_AWS_CLI_COMMAND="aws"
            export COFANO_AWS_CLI_PROFILE="cofano"

            # terminal colors env variables
            export TERM="xterm-256color"
            export FORCE_COLOR=1
            export COLORTERM="truecolor"
            export SPRING_OUTPUT_ANSI_ENABLED="ALWAYS"
            export GRADLE_OPTS="-Dorg.gradle.console=rich -Dspring.output.ansi.enabled=ALWAYS"

            # aliases
            alias gradle="./gradlew --console=rich"
            alias run="./gradlew bootRun --console=rich"

            # make ./gradlew executable
            if [ -f "./gradlew" ]; then
                chmod +x ./gradlew
            fi

            # aws sso
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
                    cat >> ~/.aws/config << 'EOF'
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
            fi

            # log in to aws
            if ! aws sts get-caller-identity --profile cofano &>/dev/null; then
                echo "⚠️  Not logged in to AWS SSO. Opening browser for login..."
                aws sso login --profile cofano
            else
                echo "✓ AWS SSO session is active"
            fi

            echo "🚢 BOS development environment loaded!"
          '';
        };
      });
}
