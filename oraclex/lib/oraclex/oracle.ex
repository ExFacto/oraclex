defmodule Oraclex.Oracle do
  alias Oraclex.Utils
  # alias Oraclex.Oracle.Announcement
  alias Oraclex.Event
  alias Bitcoinex.Utils, as: BtcUtils
  alias Bitcoinex.Secp256k1.{Schnorr, PrivateKey}

  @type t :: %__MODULE__{
          sk: PrivateKey.t(),
          pk: Point.t()
        }

  @enforce_keys [:sk]

  defstruct [
    :sk,
    :pk
  ]

  def new() do
    sk = Utils.new_private_key()
    pk = PrivateKey.to_point(sk)

    %__MODULE__{
      sk: sk,
      pk: pk
    }
  end

  def new_event_from_descriptor(_o = %__MODULE__{}, _event_descriptor) do

  end

  @doc """
    sign_event returns an oracle_announcement
  """
  def sign_event(o = %__MODULE__{}, event) do
    sighash = announcement_sighash(event)
    aux = Utils.new_rand_int()
    {:ok, sig} = Schnorr.sign(o.sk, sighash, aux)

    # TODO make this an Announcement
    %{
      signature: sig,
      public_key: o.pk,
      event: event
    }
  end

  # a single_oracle_info is just a wrapped oracle_announcement
  # https://github.com/discreetlogcontracts/dlcspecs/blob/master/Messaging.md#single_oracle_info
  def new_single_oracle_info(o = %__MODULE__{}, event) do
    sign_event(o, event)
  end

  # used for signing events (structs)
  def announcement_sighash(event) do
    event
    |> Event.serialize()
    |> oracle_tagged_hash("announcement/v0")
  end

  # used for signing outcomes (strings)
  def attestation_sighash(attestation), do: oracle_tagged_hash(attestation, "attestation/v0")

  def oracle_tagged_hash(msg, tag) do
    BtcUtils.tagged_hash("DLC/oracle/#{tag}", msg) |> :binary.decode_unsigned()
  end

  def sign_attestation(msg, sk) do
    aux = Utils.new_rand_int()
    sighash = attestation_sighash(msg)
    Schnorr.sign(sk, sighash, aux)
  end
end

defmodule Oraclex.Oracle.Announcement do
  @moduledoc """
    an announcement is simply an Event signed by an Oracle
  """
  alias Bitcoinex.Secp256k1.{Signature, Point}
  alias Oraclex.Event

  @type t :: %__MODULE__{
    signature: Signature.t(),
    public_key: Point.t(),
    event: Event.t()
  }

  defstruct [
    :signature,
    :public_key,
    :event
  ]

  def new(sig = %Signature{}, public_key = %Point{}, event = %Event{}) do
    %__MODULE__{
      signature: sig,
      public_key: public_key,
      event: event
    }
  end

  def serialize(a) do
    Signature.serialize_signature(a.signature) <>
    Point.x_bytes(a.public_key) <>
    Event.serialize(a.event)
  end
end

defmodule Oraclex.Oracle.Attestation do

  alias Oraclex.Utils
  alias Bitcoinex.Secp256k1.{Signature, Point}
  alias Oraclex.Messaging

  @type t :: %__MODULE__{
    event_id: String.t(),
    public_key: Point.t(),
    signatures: list(Signature.t()),
    outcomes: list(String.t())
  }

  defstruct [
    :event_id,
    :public_key,
    :signatures,
    :outcomes
  ]

  def new(event_id, public_key = %Point{}, signatures, outcomes)
    when length(signatures) == length(outcomes) do

      %__MODULE__{
        event_id: event_id,
        public_key: public_key,
        signatures: signatures,
        outcomes: outcomes
      }
  end

  # https://github.com/discreetlogcontracts/dlcspecs/blob/master/Messaging.md#oracle_attestation
  # @oracle_attestation_type 55400
  def serialize(event_id, pubkey, signatures, outcomes) do
    {sig_ct, ser_sigs} = Utils.serialize_with_count(signatures, &Signature.serialize_signature/1)
    # ensure same number of sigs as outcomes
    {^sig_ct, ser_outcomes} = Utils.serialize_with_count(outcomes, &Messaging.serialize_outcome/1)

    Messaging.ser(event_id, :utf8) <>
      Point.x_bytes(pubkey) <>
      Messaging.ser(sig_ct, :u16) <>
      ser_sigs <>
      ser_outcomes
  end
end
