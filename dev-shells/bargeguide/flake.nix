{
  description = "BargeGuide development environment";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/e643668fd71b949c53f8626614b21ff71a07379d";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        # Android SDK configuration for React Native
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          platformVersions = [ "35" "34" "33" ];
          buildToolsVersions = [ "34.0.0" "33.0.0" ];
          includeEmulator = true;
          includeNDK = true;
          ndkVersions = [ "25.1.8937393" ];
        };

        androidSdk = androidComposition.androidsdk;

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Language servers for neovim
            typescript-language-server # TypeScript/JavaScript
            eslint_d # ESLint daemon for fast linting
            vscode-langservers-extracted # JSON language server
            graphql-language-service-cli # GraphQL
            yaml-language-server # YAML

            # React Native / Expo development
            nodejs_20
            yarn
            watchman # File watching service for React Native

            # Android development
            jdk17
            androidSdk

            # AWS tools
            awscli2

            # Additional tools
            docker
            docker-compose
          ];

          shellHook = ''
                        # Create wrapper scripts directory in user cache
                        DEVSHELL_BIN="$HOME/.cache/nix-devshell-bin/bargeguide"
                        mkdir -p "$DEVSHELL_BIN"

                        # Store current directory for scripts to use
                        PROJECT_DIR="$PWD"

                        # Set up Android SDK environment variables
                        export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
                        export ANDROID_SDK_ROOT="$ANDROID_HOME"
                        export PATH="$ANDROID_HOME/platform-tools:$PATH"
                        export PATH="$ANDROID_HOME/tools:$PATH"
                        export PATH="$ANDROID_HOME/tools/bin:$PATH"
                        export PATH="$ANDROID_HOME/build-tools/34.0.0:$PATH"

                        # Java home for Android builds
                        export JAVA_HOME="${pkgs.jdk17}"

                        # Create yarn wrapper
                        cat > "$DEVSHELL_BIN/y" << 'YARN_EOF'
            #!/usr/bin/env bash
            cd "''${PROJECT_DIR:-$PWD}"
            exec yarn "$@"
            YARN_EOF
                        chmod +x "$DEVSHELL_BIN/y"

                        # Create start shortcut
                        cat > "$DEVSHELL_BIN/start" << 'START_EOF'
            #!/usr/bin/env bash
            cd "''${PROJECT_DIR:-$PWD}"
            exec yarn start "$@"
            START_EOF
                        chmod +x "$DEVSHELL_BIN/start"

                        # Create android shortcut
                        cat > "$DEVSHELL_BIN/android" << 'ANDROID_EOF'
            #!/usr/bin/env bash
            cd "''${PROJECT_DIR:-$PWD}"
            exec yarn android "$@"
            ANDROID_EOF
                        chmod +x "$DEVSHELL_BIN/android"

                        # Create generate shortcut for GraphQL codegen
                        cat > "$DEVSHELL_BIN/generate" << 'GENERATE_EOF'
            #!/usr/bin/env bash
            cd "''${PROJECT_DIR:-$PWD}"
            exec yarn generate "$@"
            GENERATE_EOF
                        chmod +x "$DEVSHELL_BIN/generate"

                        # Export variables for scripts
                        export PROJECT_DIR
                        export DEVSHELL_BIN

                        # Add to PATH
                        export PATH="$DEVSHELL_BIN:$PATH"

                        # aws env variables
                        export COFANO_AWS_CLI_COMMAND="aws"
                        export COFANO_AWS_CLI_PROFILE="cofano"
                        export COFANO_AWS_SSO_PROFILE="cofano"

                        # terminal colors env variables
                        export TERM="xterm-256color"
                        export FORCE_COLOR=1
                        export COLORTERM="truecolor"

                        # Expo backend host - dynamically detect local IP
                        export EXPO_PUBLIC_BACKEND_HOST="http://localhost:3000"
                        echo "📡 Backend host: $EXPO_PUBLIC_BACKEND_HOST"

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
                                echo "✅ AWS SSO profile 'cofano' configured automatically"
                            else
                                echo "✅ AWS SSO profile 'cofano' already exists in config"
                            fi
                        fi

                        # log in to aws
                        if ! aws sts get-caller-identity --profile cofano &>/dev/null; then
                            echo "⚠️  Not logged in to AWS SSO. Opening browser for login..."
                            aws sso login --profile cofano
                        else
                            echo "✅ AWS SSO session is active"
                        fi

                        # configure yarn with CodeArtifact using the project's authentication script
                        echo "🧶 Configuring Yarn authentication with CodeArtifact..."

                        # The awsCodeArtifactCredentials.cjs script handles authentication for both npm and yarn
                        # It reads COFANO_AWS_CLI_PROFILE which we already set above
                        if [ -f "awsCodeArtifactCredentials.cjs" ]; then
                            node awsCodeArtifactCredentials.cjs
                            echo "✅ Yarn authentication configured"
                        else
                            echo "⚠️  awsCodeArtifactCredentials.cjs not found"
                            echo "  Make sure you're in the bargeguide project directory"
                        fi

                        echo "📱 BargeGuide development environment loaded!"
                        echo ""
                        echo "Available commands:"
                        echo "  start      - Start Expo dev server (yarn start)"
                        echo "  android    - Run on Android (yarn android)"
                        echo "  generate   - Generate GraphQL types (yarn generate)"
                        echo "  y          - Yarn shortcut"
                        echo ""
                        echo "Android SDK: $ANDROID_HOME"
                        echo "Node: $(node --version)"
                        echo "Yarn: $(yarn --version)"
                        echo ""
          '';
        };
      });
}
