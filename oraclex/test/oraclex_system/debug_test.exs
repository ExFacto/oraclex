defmodule OraclexSystem.DebugTest do
  use Oraclex.DataCase

  import Mock

  describe "[unit] log/2" do
    @tag :unit
    test "prints the input on console returns the input" do
      with_mocks [
        {Mix, [:passthrough], env: fn -> :dev end},
        {IO, [:passthrough], write: fn _ -> :ok end}
      ] do
        input = true
        result = Debug.log(input)

        assert result === input
      end
    end
  end
end
