#!/bin/bash
set -eo pipefail

# Define PostgreSQL connection parameters
host="localhost"  # Use 'localhost' directly to avoid ECS hostname resolution issues
user="${POSTGRES_USER:-postgres}"
db="${POSTGRES_DB:-$POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD:-}"

args=(
    --host "$host"
    --username "$user"
    --dbname "$db"
    --quiet --no-align --tuples-only
)

# Retry loop to check PostgreSQL health with logging
for i in {1..5}; do
    echo "Attempt $i: Checking PostgreSQL health..."

    if select="$(echo 'SELECT 1' | psql "${args[@]}")" && [ "$select" = '1' ]; then
        echo "Postgres is healthy"
        exit 0
    fi

    echo "Postgres is not ready, retrying in 5 seconds..."
    sleep 5
done

echo "Postgres health check failed after multiple attempts"
exit 1
