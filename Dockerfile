FROM elixir:1.13.4

# APT update and install
RUN apt update
RUN apt install -y build-essential

WORKDIR /app

# Project Dependencies
COPY mix.exs mix.exs
COPY mix.lock mix.lock

RUN mix local.hex --force
RUN mix deps.get
RUN mix local.rebar --force

# Compile App
COPY . /app
RUN mix compile


EXPOSE 4000

CMD ["mix", "phx.server"]
