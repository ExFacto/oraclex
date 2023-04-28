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

  def to_exfacto_attestation(announcement = %{uid: uid, attestation: attestation}) do
    pubkey = Oraclex.get_point()
    sigs = Enum.map(attestation.signatures, fn sig_hex ->
      {:ok, sig} = Signature.parse_signature(sig_hex)
      sig
    end)

    %Oracle.Attestation{
      event_id: uid,
      public_key: pubkey,
      signatures: sigs,
      outcomes: [attestation.outcome]
    }
  end

  def serialize(announcement) do
    announcement
    |> to_exfacto_attestation()
    |> Oracle.Attestation.serialize()
  end

  def to_hex(announcement) do
    announcement
    |> serialize()
    |> Base.encode16(case: :lower)
  end

  @spec to_base64(__MODULE__) :: binary
  def to_base64(announcement) do
    announcement
    |> serialize()
    |> Base.encode64()
  end


end
