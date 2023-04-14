defmodule Oraclex.Attestation do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExFacto.{Oracle}
  alias Bitcoinex.Secp256k1.Signature

  schema "attestations" do
    field :outcome, :string
    field :signatures, {:array, :string}

    belongs_to :announcement, Oraclex.Announcement

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(attestation, attrs) do
    attestation
    |> cast(attrs, [:outcome, :signatures])
    |> validate_required([:outcome, :signatures])
  end

  def create_attestation(o = %Oracle{}, announcement_uid, outcome) do
    case Repo.get_by(Oraclex.Announcement, uid: announcement_uid) do
      nil ->
        {:error, "announcement not found"}

      announcement ->
        if Enum.member?(announcement.outcomes, outcome) do
          signature =
            Oracle.sign_outcome(o.sk, outcome)
            |> Signature.to_hex()

          changeset(
            %__MODULE__{},
            %{
              "outcome" => outcome,
              "signatures" => [signature],
              "announcement_id" => announcement.uid
            }
          )
        end
    end
  end


end
