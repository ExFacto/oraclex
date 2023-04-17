defmodule Oraclex do
  @moduledoc """
  Oraclex keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Bitcoinex.{Secp256k1, Secp256k1.PrivateKey}

  def get_privkey() do
    {:ok, privkey} =
      Application.get_env(:oraclex, :private_key)
      |> hex_to_int()
      |> PrivateKey.new()

    Secp256k1.force_even_y(privkey)
  end

  def get_point() do
    PrivateKey.to_point(get_privkey())
  end

  defp hex_to_int(data), do: Base.decode16!(data, case: :lower) |> :binary.decode_unsigned()
end
