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

end
