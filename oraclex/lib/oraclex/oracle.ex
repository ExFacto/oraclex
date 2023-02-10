defmodule Oraclex.Oracle do
  alias Oraclex.Oracle.Utils

  @type t :: %__MODULE__{
    sk: PrivateKey.t(),
    pk: Point.t(),
  }

  @enforce_keys [:sk]

  defstruct [
    :sk,
    :pk
  ]

  def new() do
    sk = Utils.new_privkey()
    pk = PrivateKey.to_point(sk)

    %__MODULE__{
      sk: sk,
      pk: pk
    }
  end

  def resolve_event(oracle, event, outcome_idx) do
    outcome_sighash = Event.get_outcome_sighash(event, outcome_idx)
    sig = Schnorr.sign_with_nonce(oracle.sk, event.nonce, outcome_sighash)

    Event.resolve(event, outcome_idx, oracle, sig)
  end

end
