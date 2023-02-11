defmodule OracleClientLib.Socket do
  @moduledoc """

  """

  use Slipstream

  require Logger

  # we might have to expand this based of a particular DLC or something
  @topic "dlc:messages"

  def start_link(args) do
    Slipstream.start_link(__MODULE__, args, name: __MODULE__)
  end

  def publish_message(message) do
    GenServer.call(__MODULE__, {:publish_message, message})
  end

  @impl Slipstream
  def init(__init_args) do
    {:ok, connect!(uri: "ws://localhost:4000/dlc/websocket")}
  end

  @impl Slipstream
  def handle_connect(socket) do
    Logger.debug("Connected to oracle")
    {:ok, join(socket, @topic)}
  end

  @impl Slipstream
  def handle_join(@topic, _join_response, socket) do
    Logger.debug("Joined topic: #{@topic}")
    {:ok, socket}
  end

  @impl Slipstream
  def handle_call({:publish_message, message}, _from, socket) do
    push(socket, @topic, "new_message", %{message: message})
    {:reply, :ok, socket}
  end
end
