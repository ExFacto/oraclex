defmodule OraclexWeb.SettingsController do
  use OraclexWeb, :controller

  def index(conn, _params) do
    render(conn, "settings.html")
  end
end
