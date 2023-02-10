defmodule Oraclex.Repo do
  use Ecto.Repo,
    otp_app: :oraclex,
    adapter: Ecto.Adapters.Postgres
end
