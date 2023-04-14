defmodule Oraclex.Oracle do
  alias ExFacto.{Oracle}

  def new() do
    # TODO - use a better key generation method: BIP32
    sk = ExFacto.Utils.new_private_key()
    Oracle.new_oracle(sk)
  end
end
