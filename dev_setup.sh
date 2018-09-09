#!/usr/bin/env bash

# Start dependent services (prostgres)
docker-compose up -d

# Wait for postgres to be available`
until docker-compose exec postgres psql -U "postgres" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done
>&2 echo "Postgres is up - executing command"

# Create dev and test databases
for db_name in "whos_in_bot_dev" "whos_in_bot_test"; do
    if docker-compose exec postgres psql -Upostgres -lqt | cut -d \| -f 1 | grep -qw $db_name; then
        echo "Database $db_name already exists"
    else
        echo "Database $db_name does not exist"
        echo "Creating ..."
        docker-compose exec postgres psql -Upostgres -c "create database $db_name"
        echo "Done"
    fi
done

# Get elixir dependencies
mix deps.get

# Setup db
mix ecto.create && mix ecto.migrate

# Run tests
mix test
