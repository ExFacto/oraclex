defmodule OracleClientLib.SocketSupervisor do
  use DynamicSupervisor

  alias OracleClientLib.Socket

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_socket() do
    DynamicSupervisor.start_child(__MODULE__, Socket)
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
