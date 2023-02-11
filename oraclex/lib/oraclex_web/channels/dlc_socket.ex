defmodule OraclexWeb.DLCSocket do
  use Phoenix.Socket

  ## channels
  channel "dlc:*", OraclexWeb.DLCChannel

  def connect(_, socket) do
    {:ok, socket}
  end

  def id(_socket) do
    nil
  end
end
