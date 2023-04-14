defmodule Oraclex.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  import Ecto.Query, warn: false
  alias Oraclex.Repo

  alias ExFacto.{Event, Oracle}

  schema "announcements" do
    field :uid, :string
    field :name, :string
    field :description, :string
    field :maturity, :utc_datetime_usec
    field :outcomes, {:array, :string}
    field :private_nonces, {:array, :string}
    field :signature, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [
      :event_uid,
      :name,
      :description,
      :private_nonces,
      :outcomes,
      :maturity,
      :signature
    ])
    |> validate_required([
      :event_uid,
      :name,
      :description,
      :private_nonces,
      :outcomes,
      :maturity,
      :signature
    ])

    # TODO validate lengths
  end

  def create_announcement(o = %Oracle{}, %{
        "name" => name,
        "description" => description,
        "outcomes" => outcomes,
        "maturity" => maturity
      }) do
    {announcement, nonce_sk} = new_announcement(o, outcomes, maturity)

    changeset(
      %__MODULE__{},
      %{
        "name" => name,
        "description" => description,
        "uid" => announcement.event.id,
        "private_nonces" => [nonce_sk],
        "outcomes" => announcement.event.descriptor.outcomes,
        "maturity" => announcement.event.maturity_epoch,
        "signature" => announcement.signature
      }
    )
    |> Repo.insert!()
  end

  # @spec new_announcement(Oracle.t(), list(String.t()), DateTime.t()) :: Oraclex.Announcement.t()
  def new_announcement(o = %Oracle{}, outcomes, maturity) do
    event_descriptor = %{outcomes: outcomes}

    {nonce_sk, event} =
      Event.new_event_from_enum_descriptor(
        event_descriptor,
        maturity,
        &ExFacto.Utils.new_private_key/0
      )

    {Oracle.sign_event(o, event), nonce_sk}
  end

  def get_all_announcements() do
    query = from(a in __MODULE__,
      order_by: [desc: a.inserted_at],
      select: a
    )
    # __MODULE__
    query
    |> Repo.all()
  end
end
