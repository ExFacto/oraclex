# Oraclex

## First Time Setup
1. Install Postgres, ensure it is exposed at port `5432` and that the `postgres` users exists
2. If the password for the `postgres` user is not `postgres`, put the password in `config/dev.exs`:
```
config :oraclex, Oraclex.Repo,
  username: "postgres",
  password: "<POSTGRES_PASSWORD>",
  hostname: "localhost",
  database: "oraclex_dev",
```
2. Log Into Postgres
- `psql -h localhost -p 5432 -U postgres -d postgres`
3. Create dev DB
- `CREATE DATABASE oraclex_dev;`

4. In this repo:
5. Populate a Pirvate Key for the Oracle.
  - To generate a random one, run `echo "export ORACLEX_PRIVATE_KEY=$(openssl rand 32 | xxd -c 256 -p)" > .env`
  - If you want to use your own, run: `echo "export ORACLEX_PRIVATE_KEY=<32-byte-hex>" > .env`
6. run `source .env` 
7. run `mix deps.get`
8. run `mix ecto.setup`
9. run `mix ecto.migrate`
10. run `cd assets && npm install`

## Recurring Startup

1. run `source .env`
2. if there are new migrations, run `mix ecto.migrate`
3. run `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
