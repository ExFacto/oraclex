defmodule Oraclex.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query, warn: false
  alias Oraclex.Repo

  alias ExFacto.{Event, Oracle}
  alias Bitcoinex.Secp256k1.{PrivateKey, Signature}

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
    |> validate_length(:outcomes, min: 1)
    |> validate_length(:signature, is: 128)
    |> validate_length(:uid, is: 64)
    |> validate_length(:name, min: 6, max: 64)
    |> validate_length(:description, min: 6, max: 256)

    # TODO validate lengths
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
    {:ok, maturity, _} = DateTime.from_iso8601(maturity <> ":00Z")
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
    |> Repo.insert!()
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
