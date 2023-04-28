defmodule Oraclex.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query, warn: false
  alias Oraclex.{Repo, Utils}

  alias ExFacto
  alias ExFacto.{Event, Oracle}
  alias Bitcoinex.Secp256k1.{PrivateKey, Signature}

  @min_outcomes 1

  schema "announcements" do
    field :uid, :string
    field :name, :string
    field :description, :string
    field :maturity, :utc_datetime_usec
    field :outcomes, {:array, :string}
    field :private_nonces, {:array, :string}
    field :signature, :string

    has_one :attestation, Oraclex.Attestation

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [
      :uid,
      :name,
      :description,
      :private_nonces,
      :outcomes,
      :maturity,
      :signature
    ])
    |> validate_required([
      :uid,
      :name,
      :description,
      :private_nonces,
      :outcomes,
      :maturity,
      :signature
    ])
    |> validate_length(:private_nonces, is: 1)
    |> validate_length(:signature, is: 128)
    |> validate_length(:uid, is: 64)
    |> validate_length(:name, min: 6, max: 64)
    |> validate_length(:description, min: 6, max: 256)
    |> validate_length(:outcomes, min: 1)
    |> validate_unique_outcomes()

    # TODO validate lengths
  end

  def validate_unique_outcomes(changeset) do
    validate_change(changeset, :outcomes, fn :outcomes, outcomes ->
      cond do
        length(outcomes) < @min_outcomes ->
          [outcomes: "must have at least #{@min_outcomes} outcomes"]
        !ensure_unique_outcomes(outcomes) ->
          [outcomes: "outcomes must be unique"]
        true ->
          []
      end
    end)
  end

  defp ensure_unique_outcomes(outcomes) do
    normalized_outcomes = Enum.map(outcomes, &String.normalize(&1, :nfc))
    length(Enum.uniq(normalized_outcomes)) == length(outcomes)
  end

  def empty_changeset() do
    changeset(%__MODULE__{}, %{})
  end

  def create_announcement(o = %Oracle{}, %{
        "name" => name,
        "description" => description,
        "outcomes" => outcomes,
        "maturity" => maturity
      }) do
        # correct for weird browser time fmt
    {%{announcement: announcement}, nonce_sk} = new_announcement(o, outcomes, maturity)

    nonce_hex = PrivateKey.to_hex(nonce_sk)
    sig_hex = Signature.to_hex(announcement.signature)

    changeset(
      %__MODULE__{},
      %{
        "uid" => announcement.event.id,
        "name" => name,
        "description" => description,
        "private_nonces" => [nonce_hex],
        "outcomes" => announcement.event.descriptor.outcomes,
        "maturity" => maturity,
        "signature" => sig_hex
      }
    )
    |> Repo.insert()
  end

  # @spec new_announcement(Oracle.t(), list(String.t()), DateTime.t()) :: Oraclex.Announcement.t()
  def new_announcement(o = %Oracle{}, outcomes, maturity) do
    event_descriptor = %{outcomes: outcomes}

    maturity = DateTime.to_unix(maturity)
    {nonce_sk, event} =
      Event.new_event_from_enum_event_descriptor(
        event_descriptor,
        maturity,
        &ExFacto.Utils.new_private_key/0
      )

    {Oracle.sign_event(o, event), nonce_sk}
  end

  def get_announcement(id) do
    query = from(a in __MODULE__,
      where: a.id == ^id,
      select: a
    )
    query
    |> Repo.one()
    # |> Repo.preload(:attestation)
  end

  def to_exfacto_announcement(announcement) do
        {:ok, sig} = Signature.parse_signature(announcement.signature)
        public_key = Oraclex.get_point()
        nonce_points = nonce_privkeys_to_points(announcement.private_nonces)
        descriptor = Event.new_event_descriptor(announcement.outcomes)
        maturity = DateTime.to_unix(announcement.maturity)
        event = Event.new(announcement.uid, nonce_points, descriptor, maturity)
        Oracle.Announcement.new(sig, public_key, event)
  end

  @spec serialize(__MODULE__) :: binary
  def serialize(announcement) do
    Oracle.Announcement.serialize(to_exfacto_announcement(announcement))
  end

  @spec to_hex(__MODULE__) :: binary
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

  defp nonce_privkeys_to_points(nonce_privkeys) do
    Enum.map(nonce_privkeys, fn nonce_privkey ->
      {:ok, nonce_sk} =
        nonce_privkey
        |> Utils.hex_to_int()
        |> PrivateKey.new()
      PrivateKey.to_point(nonce_sk)
    end)
  end

  def get_all_announcements() do
    query = from(a in __MODULE__,
      order_by: [desc: a.inserted_at],
      select: a
    )
    # __MODULE__
    query
    |> Repo.all()
    |> Repo.preload(:attestation)
  end
end
