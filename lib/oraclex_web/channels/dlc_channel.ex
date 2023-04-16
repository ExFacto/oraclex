defmodule OraclexWeb.DLCChannel do
  use Phoenix.Channel

  require Logger

  def join(topic, _params, socket) do
    Logger.info("====== #{topic}")
    Logger.info("New user joined!")
    {:ok, socket}
  end

  def handle_in("new_message", %{"message" => message}, socket) do
    Logger.info("Rec: #{message}")
    {:noreply, socket}
  end
end
