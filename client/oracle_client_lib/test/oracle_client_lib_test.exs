defmodule OracleClientLibTest do
  use ExUnit.Case
  doctest OracleClientLib

  test "greets the world" do
    assert OracleClientLib.hello() == :world
  end
end
