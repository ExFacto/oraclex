defmodule Oraclex.Oracle.Event do

  @type t :: %__MODULE__{
    nonce: PrivateKey.t(),
    nonce_point: Point.t(),
    outcomes: list(String.t())
  }

  @spec new_event(list(String.t())) :: t()
  def new_event(outcomes) do
    oracle_event_nonce = Utils.new_privkey()
    event_nonce_point = PrivateKey.to_point(oracle_event_nonce)

    %__MODULE__{
      nonce: oracle_event_nonce,
      nonce_point: event_nonce_point,
      outcomes: outcomes
    }
  end

  @type announcement :: %{
    pubkey: Point.t(),
    public_nonce: Point.t(),
    outcomes: list(String.t())
  }

  @spec calculate_all_signature_points(announcement()) :: list(Point.t())
  def calculate_all_signature_points(%{pubkey: pk, public_nonce: r_point, outcomes: outcomes}) do
    Enum.map(outcomes, fn outcome -> calculate_all_signature_points(pk, r_point, outcome) end)
  end

  @spec calculate_signature_point(Point.t(), Point.t(), String.t())
  def calculate_signature_point(pk, r_point, outcome) do
      z = Bitcoinex.Utils.double_sha256(outcome)
      Schnorr.calculate_signature_point(r_point, pk, z)
  end

  @spec announce(Oraclex.Oracle.t(), t()) :: announcement()
  def announce(oracle, event) do
    %{
      pubkey: oracle.pk
      public_nonce: event.nonce_point,
      outcomes: event.outcomes
    }
  end

  def get_outcome_sighash(%__MODULE__{outcomes: outcomes}, idx) do
    outcomes
    |> Enum.at(idx)
    |> Bitcoinex.Utils.double_sha256()
    |> :binary.decode_unsigned()
  end

  @type resolution :: %{
    pubkey: Point.t(),
    signature: Signature.t(),
    outcome: String.t()
  }

  def resolve(event, outcome_idx, oracle, signature) do
    %{
      pubkey: oracle.pk,
      signature: signature,
      outcome: Enum.at(event, outcome_idx)
    }
  end

  def get_secret_from_resolution(%{signature: %Signature{s: s}}), do: PrivateKey.new(s)

end
