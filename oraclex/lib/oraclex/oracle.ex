defmodule Oraclex.Oracle do



  defmodule Announcement do
    alias Bitcoinex.Secp256k1.Point

    @type t :: %__MODULE__{
      pubkey: Point.t(),
      public_nonce: Point.t(),
      cases: list(String.t())
    }

    @enforce_keys [:pubkey, :public_nonce, :cases]

    defstruct [
      :pubkey,
      :public_nonce,
      :cases
    ]
    def calculate_all_signature_points(%__MODULE__{pubkey: pk, public_nonce: r_point, cases: cases}) do
      Enum.map(cases, fn c -> calculate_all_signature_points(pk, r_point, c) end)
    end

    def calculate_signature_point(pk, r_point, c) do
        z = Bitcoinex.Utils.double_sha256(c)
        Schnorr.calculate_signature_point(r_point, pk, z)
    end
  end

  defmodule Resolution do
    alias Bitcoinex.Secp256k1.Signature

    @type t :: %__MODULE__{
      signature: Signature.t(),
      case: String.t() # not strictly necessary but helpful, especially for display
    }

    @enforce_keys [:signature]

    defstruct [
      :signature,
      :case
    ]

    def get_secret(%__MODULE__{signature: %Signature{s: s}}), do: PrivateKey.new(s)
  end
end
