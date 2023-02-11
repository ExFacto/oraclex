defmodule OracleClientTest do
  use ExUnit.Case
  doctest OracleClient

  test "greets the world" do
    assert OracleClient.hello() == :world
  end
end
