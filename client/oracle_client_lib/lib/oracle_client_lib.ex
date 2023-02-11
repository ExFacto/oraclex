defmodule OracleClientLib do
  alias OracleClientLib.SocketSupervisor

  @doc """
  Start a socket
  """
  def start_socket() do
    SocketSupervisor.start_socket()
  end
end
