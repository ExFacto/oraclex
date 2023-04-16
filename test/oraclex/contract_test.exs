defmodule Oraclex.ContractTest do
  use ExUnit.Case
  doctest Oraclex.ContractTest

  alias Oraclex.Contract

  describe "contract_id" do
    test "calculate temp_contract_id" do
    end

    test "calculate contract_id" do
      filename = "dlcspec_vectors/contract_id_test.json"

      {:ok, data} = File.read(filename)
      {:ok, tests} = Poison.decode(data)
    end
  end
end
