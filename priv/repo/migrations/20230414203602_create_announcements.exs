defmodule Oraclex.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add :uid, :string
      add :name, :string
      add :description, :string
      add :private_nonces, {:array, :string}
      add :outcomes, {:array, :string}
      add :maturity, :utc_datetime_usec
      add :signature, :string

      timestamps()
    end
  end
end
