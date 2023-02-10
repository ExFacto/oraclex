defmodule Oraclex.Utils do
  alias Bitcoinex.Utils
  alias Bitcoinex.{PrivateKey, Secp256k1}




  defp new_rand_int() do
    32
    |> :crypto.strong_rand_bytes()
    |> :binary.decode_unsigned()
  end

  defp new_private_key() do
    {:ok, sk} =
      new_rand_int.()
      |> PrivateKey.new()
    Secp256k1.force_even_y(sk)
  end
end
