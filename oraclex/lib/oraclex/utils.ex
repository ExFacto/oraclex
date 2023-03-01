defmodule Oraclex.Utils do
  alias Bitcoinex.Utils
  alias Bitcoinex.{Script, Secp256k1.PrivateKey, Secp256k1}

  @type outpoint :: {String.t(), non_neg_integer()}

  def new_rand_int() do
    32
    |> :crypto.strong_rand_bytes()
    |> :binary.decode_unsigned()
  end

  def new_private_key() do
    {:ok, sk} =
      new_rand_int.()
      |> PrivateKey.new()

    Secp256k1.force_even_y(sk)
  end

  def big_size(compact_size) do
    cond do
      compact_size >= 0 and compact_size <= 0xFC ->
        <<compact_size::big-size(8)>>

      compact_size <= 0xFFFF ->
        <<0xFD>> <> <<compact_size::big-size(16)>>

      compact_size <= 0xFFFFFFFF ->
        <<0xFE>> <> <<compact_size::big-size(32)>>

      compact_size <= 0xFF ->
        <<0xFF>> <> <<compact_size::big-size(64)>>
    end
  end

  def with_big_size(data) do
    data
    |> byte_size()
    |> big_size()
    |> Kernel.<>(data)
  end

  def script_with_big_size(script = %Script{}) do
    script
    |> Script.serialize_script()
    |> with_big_size()
  end
end
