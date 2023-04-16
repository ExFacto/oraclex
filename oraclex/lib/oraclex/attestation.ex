defmodule Oraclex.Attestation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Oraclex.Repo

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

  def empty_changeset() do
    changeset(%__MODULE__{}, %{})
  end

  def create_attestation(o = %Oracle{}, resolution = %{
    "event_id" => announcement_id,
    "outcome" => outcome
    }) do
    case Repo.get_by(Oraclex.Announcement, id: String.to_integer(announcement_id)) do
      nil ->
        {:error, "announcement not found"}

      announcement ->
        if Enum.member?(announcement.outcomes, outcome) do
          {:ok, signature} = Oracle.sign_outcome(o.sk, outcome)
          sig_hex = Signature.to_hex(signature)

          Ecto.build_assoc(announcement, :attestation, outcome: outcome, signatures: [sig_hex])
          |> Repo.insert!()
        end
    end
  end


end
