defmodule OraclexWeb.SettingsController do
  use OraclexWeb, :controller

  alias Bitcoinex.Secp256k1.Point

  def index(conn, _params) do
    pubkey = Oraclex.get_point() |> Point.serialize_public_key()
    render(conn, "settings.html", pubkey: pubkey)
  end
end
