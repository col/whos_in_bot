#! /usr/bin/env bash

set -e

ELIXIR_VERSION=1.9.1
ELIXIR_CACHE_KEY=kiex-elixir-$ELIXIR_VERSION-erl-22

if cache has_key "$ELIXIR_CACHE_KEY"; then
  cache restore $ELIXIR_CACHE_KEY
else
  kiex install $ELIXIR_VERSION
  cache store $ELIXIR_CACHE_KEY $HOME/.kiex/elixirs
fi

kiex default $ELIXIR_VERSION
kiex use $ELIXIR_VERSION
source $HOME/.kiex/elixirs/elixir-$ELIXIR_VERSION.env

elixir --version

mix local.hex --force
mix local.rebar --force