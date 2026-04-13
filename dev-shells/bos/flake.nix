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

            # Database tools
            mysql80 # MySQL 8.0 client (compatible with MySQL 8.3 server)
            mycli # Pretty MySQL CLI with syntax highlighting and auto-completion
            dbeaver-bin # Universal SQL database GUI
            gobang # Cross-platform TUI database management tool
            yq-go # YAML processor for config file updates
          ];

          shellHook = ''
                                                # Create wrapper scripts directory in user cache
                                                DEVSHELL_BIN="$HOME/.cache/nix-devshell-bin/bos"
                                                mkdir -p "$DEVSHELL_BIN"

                                                # Store current directory for scripts to use
                                                PROJECT_DIR="$PWD"

                                                # Create gradle wrapper with error summary
                                                cat > "$DEVSHELL_BIN/gradle" << 'GRADLE_EOF'
            #!/usr/bin/env bash
            cd "''${PROJECT_DIR:-$PWD}"
            output_file=$(mktemp)
            if ./gradlew --console=rich "$@" 2>&1 | tee "$output_file"; then
                rm "$output_file"
                exit 0
            else
                exit_code=$?
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "📋 ERROR SUMMARY:"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                grep -A 5 "FAILURE:" "$output_file" || true
                grep "^.*Exception:" "$output_file" | head -5 || true
                grep "^Caused by:" "$output_file" | head -5 || true
                grep "execution failed" "$output_file" -i | head -3 || true
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                rm "$output_file"
                exit $exit_code
            fi
            GRADLE_EOF
                                                chmod +x "$DEVSHELL_BIN/gradle"

                                                # Create run shortcut (runs database setup first)
                                                cat > "$DEVSHELL_BIN/run" << 'RUN_EOF'
            #!/usr/bin/env bash
            # Run database setup for current branch before starting
            if [ -f "$DEVSHELL_BIN/db-setup" ]; then
                "$DEVSHELL_BIN/db-setup"
            fi
            # Expose JDWP on :5005 (server=y, suspend=n) so the debugger can attach on demand
            exec "$DEVSHELL_BIN/gradle" bootRun \
                "-Dspring-boot.run.jvmArguments=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" \
                "$@"
            RUN_EOF
                                                chmod +x "$DEVSHELL_BIN/run"

                                                # Create database setup script (extracted from post-checkout hook)
                                                cat > "$DEVSHELL_BIN/db-setup" << 'DBSETUP_EOF'
            #!/usr/bin/env bash
            # Database setup: Create and switch to branch-specific database

            # MySQL connection details
            MYSQL_HOST="127.0.0.1"
            MYSQL_PORT="3308"
            MYSQL_USER="root"
            MYSQL_PASS="root"
            SOURCE_DB="develop"
            CONFIG_FILE="webapp/src/main/resources/application-personal.yml"

            # Get the current branch name
            BRANCH_NAME=$(git branch --show-current 2>/dev/null)

            # Skip if no branch name (detached HEAD state or not in git repo)
            if [ -z "$BRANCH_NAME" ]; then
                echo "⚠️  Not on a branch, skipping database setup"
                exit 0
            fi

            # Sanitize branch name for MySQL database name
            DB_NAME=$(echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]' | tr '/.-' '_')

            echo "🔄 Current branch: $BRANCH_NAME"
            echo "📊 Target database: $DB_NAME"

            # Set password via environment variable to avoid warnings
            export MYSQL_PWD="$MYSQL_PASS"

            # Check if MySQL is running
            if ! mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -e "SELECT 1;" 2>/dev/null 1>&2; then
                echo "⚠️  MySQL is not running, skipping database setup"
                exit 0
            fi

            # Check if database exists
            if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -e "USE $DB_NAME;" 2>/dev/null; then
                echo "✅ Database $DB_NAME already exists"
            else
                echo "🔨 Creating new database: $DB_NAME"
                mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null

                echo "📋 Copying schema and data from $SOURCE_DB..."
                if mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" \
                    --column-statistics=0 \
                    --set-gtid-purged=OFF \
                    --no-tablespaces \
                    "$SOURCE_DB" 2>/dev/null | mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" "$DB_NAME"; then
                    echo "✅ Database copied successfully"

                    echo "🧹 Cleaning Flyway schema history..."
                    mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" "$DB_NAME" \
                        -e "TRUNCATE TABLE flyway_schema_history;" 2>/dev/null || true
                    echo "✅ Flyway history cleared"
                else
                    echo "❌ Failed to copy database"
                    exit 1
                fi
            fi

            # Update application-personal.yml if it exists
            if [ -f "$CONFIG_FILE" ]; then
                # Check if already configured for this database
                if grep -q "jdbcurl:.*$DB_NAME" "$CONFIG_FILE" 2>/dev/null; then
                    echo "✅ Config already set to $DB_NAME"
                else
                    echo "🔧 Updating $CONFIG_FILE..."
                    if command -v yq &>/dev/null; then
                        yq eval ".spring.datasource.jdbcurl = \"jdbc:mysql://localhost:3308/$DB_NAME\"" -i "$CONFIG_FILE"
                    else
                        sed -i "s|jdbcurl: jdbc:mysql://localhost:3308/[^?]*|jdbcurl: jdbc:mysql://localhost:3308/$DB_NAME|" "$CONFIG_FILE"
                    fi
                    echo "✅ Configuration updated"
                fi
            fi

            echo "✨ Database ready!"
            DBSETUP_EOF
                                                chmod +x "$DEVSHELL_BIN/db-setup"

                                                # Create database connection shortcut
                                                cat > "$DEVSHELL_BIN/db" << 'DB_EOF'
            #!/usr/bin/env bash
            exec mycli -h localhost -P 3308 -u root -p root bos_test_varo "$@"
            DB_EOF
                                                chmod +x "$DEVSHELL_BIN/db"

                                                # Create sql alias
                                                cat > "$DEVSHELL_BIN/sql" << 'SQL_EOF'
            #!/usr/bin/env bash
            exec mycli -h localhost -P 3308 -u root -p root "$@"
            SQL_EOF
                                                chmod +x "$DEVSHELL_BIN/sql"

                                                # Export variables for scripts
                                                export PROJECT_DIR
                                                export DEVSHELL_BIN

                                                # Add to PATH
                                                export PATH="$DEVSHELL_BIN:$PATH"

                                                # aws env variables
                                                export COFANO_AWS_CLI_COMMAND="aws"
                                                export COFANO_AWS_CLI_PROFILE="cofano"
                                                export COFANO_AWS_SSO_PROFILE="cofano"

                                                # java env variables
                                                export SPRING_PROFILES_ACTIVE="standard,dev,personal"                       

                                                # terminal colors env variables
                                                export TERM="xterm-256color"
                                                export FORCE_COLOR=1
                                                export COLORTERM="truecolor"
                                                export SPRING_OUTPUT_ANSI_ENABLED="ALWAYS"
                                                export GRADLE_OPTS="-Dorg.gradle.console=rich -Dspring.output.ansi.enabled=ALWAYS"

                                                # Simplified Spring Boot logging pattern: LEVEL ClassName : message
                                                export LOGGING_PATTERN_CONSOLE="%clr(%logger{0}){grey}%clr(:){faint} %clr(%m){WARN=yellow,ERROR=red,DEBUG=magenta,TRACE=blue,INFO=faint}%n"

                                                # make ./gradlew executable
                                                if [ -f "./gradlew" ]; then
                                                    chmod +x ./gradlew
                                                    git update-index --skip-worktree gradlew
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
                                                if [ -f "frontend/awsCodeArtifactCredentials.cjs" ]; then
                                                    cd frontend
                                                    node awsCodeArtifactCredentials.cjs
                                                    cd ..
                                                    echo "✅ Yarn authentication configured"
                                                elif [ -f "awsCodeArtifactCredentials.cjs" ]; then
                                                    node awsCodeArtifactCredentials.cjs
                                                    echo "✅ Yarn authentication configured"
                                                else
                                                    echo "⚠️  awsCodeArtifactCredentials.cjs not found"
                                                    echo "  Make sure you're in the bos project directory"
                                                fi

                                                # Login to AWS ECR for Docker
                                                echo "🔐 Logging in to AWS ECR for Docker..."
                                                if aws ecr get-login-password --region eu-central-1 --profile cofano 2>/dev/null | docker login --username AWS --password-stdin 933071262868.dkr.ecr.eu-central-1.amazonaws.com &>/dev/null; then
                                                    echo "✅ Docker logged in to AWS ECR"
                                                else
                                                    echo "⚠️  Failed to log in to AWS ECR, Docker images may not pull correctly"
                                                fi

                                                # Start Docker services
                                                echo "🐳 Starting Docker services..."
                                                if command -v docker-compose &>/dev/null; then
                                                    # Use --project-name to ensure consistent container naming across worktrees
                                                    if docker-compose --project-name bos ps mysql-bos 2>/dev/null | grep -q "Up"; then
                                                        echo "✅ Docker services already running"
                                                    else
                                                        docker-compose --project-name bos up -d mysql-bos rabbitmq mailhog
                                                        echo "✅ Docker services started (mysql-bos, rabbitmq, mailhog)"
                                                    fi
                                                else
                                                    echo "⚠️  docker-compose not found, skipping Docker service startup"
                                                fi

                                                echo "🚢 BOS development environment loaded!"
                                                echo "💡 Use 'run' to start the app (automatically sets up branch database)"
                                                echo "💡 Use 'db-setup' to manually set up the database for current branch"
          '';
        };
      });
}
