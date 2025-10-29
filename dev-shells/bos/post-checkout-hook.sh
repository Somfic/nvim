#!/usr/bin/env bash
# Post-checkout hook: Automatically create and switch to branch-specific database

PREV_HEAD=$1
NEW_HEAD=$2
BRANCH_SWITCH=$3

# Only run on branch switches (not file checkouts)
if [ "$BRANCH_SWITCH" != "1" ]; then
    exit 0
fi

# MySQL connection details
MYSQL_HOST="127.0.0.1"
MYSQL_PORT="3308"
MYSQL_USER="root"
MYSQL_PASS="root"
SOURCE_DB="develop"
CONFIG_FILE="webapp/src/main/resources/application-personal.yml"

# Get the current branch name
BRANCH_NAME=$(git branch --show-current)

# Skip if no branch name (detached HEAD state)
if [ -z "$BRANCH_NAME" ]; then
    exit 0
fi

# Sanitize branch name for MySQL database name
# - Convert to lowercase
# - Replace special characters (/, -, .) with underscore
DB_NAME=$(echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]' | tr '/.-' '_')

echo "🔄 Branch switched to: $BRANCH_NAME"
echo "📊 Target database: $DB_NAME"

# Set password via environment variable to avoid warnings
export MYSQL_PWD="$MYSQL_PASS"

# Check if MySQL is running (retry up to 10 times with 1 second wait)
MYSQL_READY=false
for i in {1..10}; do
    if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -e "SELECT 1;" 2>/dev/null 1>&2; then
        MYSQL_READY=true
        break
    fi
    if [ $i -lt 10 ]; then
        if [ $i -eq 1 ]; then
            echo "  ⏳ Waiting for MySQL to accept connections..."
        fi
        sleep 1
    fi
done

if [ "$MYSQL_READY" = false ]; then
    echo "⚠️  MySQL is not ready after 10 seconds, skipping database switch"
    echo "  💡 You can manually run the hook later: .git/hooks/post-checkout '' '' 1"
    exit 0
fi

# Check if database exists
if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -e "USE $DB_NAME;" 2>/dev/null; then
    echo "✅ Database $DB_NAME already exists"
else
    echo "🔨 Creating new database: $DB_NAME"
    mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null

    echo "📋 Copying schema and data from $SOURCE_DB..."
    # Use flags to handle MySQL 8.x features: column statistics, GTID, and generated columns
    # Password is set via MYSQL_PWD env var to avoid warnings being piped to mysql
    if mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" \
        --column-statistics=0 \
        --set-gtid-purged=OFF \
        --no-tablespaces \
        "$SOURCE_DB" 2>/dev/null | mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" "$DB_NAME"; then
        echo "✅ Database copied successfully"

        # Clean Flyway schema history to avoid migration validation errors when switching branches
        echo "🧹 Cleaning Flyway schema history for branch-specific database..."
        mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" "$DB_NAME" \
            -e "DELETE FROM flyway_schema_history WHERE success = 1 AND script NOT IN (SELECT CONCAT('V', version, '__', description, '.sql') FROM (SELECT * FROM flyway_schema_history) as temp);" 2>/dev/null || true
        mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" "$DB_NAME" \
            -e "TRUNCATE TABLE flyway_schema_history;" 2>/dev/null || true
        echo "✅ Flyway history cleared - migrations will be revalidated on startup"
    else
        echo "❌ Failed to copy database"
        echo "ℹ️  Check if source database '$SOURCE_DB' exists and has data"
        exit 1
    fi
fi

# Update application-personal.yml if it exists
if [ -f "$CONFIG_FILE" ]; then
    echo "🔧 Updating $CONFIG_FILE..."
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

    # Update the jdbcurl using yq
    if command -v yq &>/dev/null; then
        yq eval ".spring.datasource.jdbcurl = \"jdbc:mysql://localhost:3308/$DB_NAME?serverTimezone=UTC\"" -i "$CONFIG_FILE"
        echo "✅ Configuration updated"
    else
        # Fallback to sed if yq is not available
        sed -i "s|jdbcurl: jdbc:mysql://localhost:3308/[^?]*|jdbcurl: jdbc:mysql://localhost:3308/$DB_NAME|" "$CONFIG_FILE"
        echo "✅ Configuration updated (using sed)"
    fi

    rm -f "$CONFIG_FILE.bak"
else
    echo "⚠️  Configuration file not found: $CONFIG_FILE"
fi

echo "✨ Database switch complete!"
