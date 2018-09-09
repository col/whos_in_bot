FROM elixir:latest
MAINTAINER Colin Harris <col.w.harris@gmail.com>

RUN mkdir /app
COPY . /app
WORKDIR /app

# Configure required environment
ENV MIX_ENV prod

# Install hex (Elixir package manager)
RUN mix local.hex --force

# Install rebar (Erlang build tool)
RUN mix local.rebar --force

# Install all production dependencies
RUN mix deps.get --only prod

# Compile all dependencies
RUN mix deps.compile

# Compile the entire project
RUN mix compile
