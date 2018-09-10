FROM elixir:latest
MAINTAINER Colin Harris <col.w.harris@gmail.com>

# Install the postgres client library
RUN apt-get update && apt-get install -y postgresql-client

# Configure required environment
ENV MIX_ENV prod

# Set and expose PORT environmental variable
ENV PORT ${PORT:-5000}
EXPOSE $PORT

# Install hex (Elixir package manager)
RUN mix local.hex --force

# Install rebar (Erlang build tool)
RUN mix local.rebar --force

# Install app source
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install all production dependencies
RUN mix deps.get --only prod

# Compile all dependencies
RUN mix deps.compile

# Compile the entire project
RUN mix compile

CMD ["/app/entrypoint.sh"]
