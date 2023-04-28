defmodule Oraclex.Repo.Migrations.CreateAttestations do
  use Ecto.Migration

  def change do
    create table(:attestations) do
      add :outcome, :string
      add :signatures, {:array, :string}
      add :announcement_id, references(:announcements, on_delete: :delete_all)

      timestamps()
    end

    create index(:attestations, [:announcement_id])
  end
end
