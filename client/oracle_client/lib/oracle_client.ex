defmodule OracleClient do
  def start(_, _args) do
    {:ok, _socket} = OracleClientLib.start_socket()
    io_handler = spawn(fn -> handle_io() end)

    {:ok, io_handler}
  end

  def handle_io() do
    new_message = IO.gets("> ")

    :ok = OracleClientLib.Socket.publish_message(new_message)

    handle_io()
  end
end
