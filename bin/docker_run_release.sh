#! /usr/bin/env bash

# This will run `mix release` inside a docker container with elixir installed
docker run -v $(pwd):/opt/build --rm -it elixir:1.9.1 /opt/build/bin/release.sh