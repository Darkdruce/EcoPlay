#!/usr/bin/env bash
# dev-db.sh — start Postgres locally and optionally seed it
# Usage: ./scripts/dev-db.sh [--seed]

set -euo pipefail

COMPOSE="docker compose -f $(dirname "$0")/../docker/docker-compose.yml"

echo "Starting Postgres..."
$COMPOSE up postgres -d

echo "Waiting for Postgres to be healthy..."
until $COMPOSE exec postgres pg_isready -U ecoplay -d ecoplay > /dev/null 2>&1; do
  sleep 1
done
echo "Postgres is ready."

if [[ "${1:-}" == "--seed" ]]; then
  echo "Running seed..."
  $COMPOSE exec -T postgres psql -U ecoplay -d ecoplay < "$(dirname "$0")/seed.sql"
  echo "Seed complete."
fi
