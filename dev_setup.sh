#!/usr/bin/env bash

# Start dependent services (prostgres)
docker-compose up -d postgres

# Wait for postgres to be available`
until docker-compose exec postgres psql -U "postgres" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done
>&2 echo "Postgres is up - executing command"

# Get elixir dependencies
mix deps.get

# Create DB
mix ecto.create
MIX_ENV=test mix ecto.create

# Migrate DB
mix ecto.migrate

# Run tests
mix test
