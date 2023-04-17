defmodule Oraclex.Oracle do
  alias ExFacto.{Oracle}

  @spec new :: ExFacto.Oracle.t()
  def new() do
    # TODO - use a better key generation method: BIP32
    sk = ExFacto.Utils.new_private_key()
    Oracle.new(sk)
  end

  @spec load_oracle :: ExFacto.Oracle.t()
  def load_oracle() do
    sk = Oraclex.get_privkey()
    Oracle.new(sk)
  end
end
