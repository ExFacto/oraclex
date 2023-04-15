defmodule Oraclex.Oracle do
  alias ExFacto.{Oracle}

  def new() do
    # TODO - use a better key generation method: BIP32
    sk = ExFacto.Utils.new_private_key()
    Oracle.new(sk)
  end

  def load_oracle() do
    # TODO - load from env / memory / disk
    new()
  end
end
