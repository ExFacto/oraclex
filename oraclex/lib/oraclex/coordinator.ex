defmodule Oraclex.Coordinator do
  alias Oraclex.Oracle
  alias Oraclex.Oracle.{Announcement, Resolution}
  alias Bitcoinex.{Script}
  alias Bitcoinex.Secp256k1.{Point}


  @spec handle_maker(Announcement.t(), non_neg_integer(), non_neg_integer(), {String.t(), String.t(), non_neg_integer(), non_neg_integer(), String.t()})
  def handle_maker(oracle_announcement, fund_fee, cet_fee, {prev_outpoint, prev_address, prev_amount, fund_pubkey, fund_amount, dest_address}) do

    {prev_txid, prev_vout, prev_scriptpubkey, prev_amount} = handle_input_coin_info(prev_outpoint, prev_address, prev_amount)
    {fund_pk, fund_amount} = handle_funding_info(fund_pubkey, fund_amount)
    dest_script = handle_settlement_info(dest_address)

    change_amount = prev_amount - fund_amount - fund_fee
    winner_amount = fund_amount - cet_fee
    true
    # send bet summary back to maker
  end

  @spec handle_taker({String.t(), String.t(), non_neg_integer(), non_neg_integer(), String.t()})
  def handle_taker({prev_outpoint, prev_address, prev_amount, fund_pubkey, fund_amount, dest_address}) do
    {prev_txid, prev_vout, prev_scriptpubkey, prev_amount} = handle_input_coin_info(prev_outpoint, prev_address, prev_amount)
    {fund_pk, fund_amount} = handle_funding_info(fund_pubkey, fund_amount)
    dest_script = handle_settlement_info(dest_address)
    true
  end

  defp handle_join_offer() do
    # TODO we must ensure only 2 people join an offer.
    # Should we use optional names or label first Maker and second Taker
  end

  @spec handle_input_coin_info(String.t(), String.t(), non_neg_integer())
  defp handle_input_coin_info(prev_outpoint, prev_address,  prev_amount) do
    # TODO: how should we set app-wide network & check against returned network
    {:ok, prev_scriptpubkey, _network} = Script.from_address(String.trim(prev_address))
    [prev_txid, vout] = String.split(String.trim(prev_outpoint), ":")
    prev_vout = String.to_integer(vout)
    prev_amount = String.to_integer(String.trim(prev_amount))
    { prev_txid, prev_vout, prev_scriptpubkey, prev_amount}
  end

  defp handle_funding_info(pubkey, amount) do
    amount = String.to_integer(amount)
    case Point.lift_x(pubkey) do
      {:error, msg} -> {:error, msg}

      {:ok, pk} ->
        {pk, amount}
    end
  end

  defp handle_settlement_info(winner_amount, address) do
    winner_amount = String.to_integer(winner_amount)
    {:ok, dest_script, _network} = Script.from_address(String.trim(address))
    dest_script
  end

  def send_bet_summary() do
    %{

      fund_amount: fund_amount,
      winner_gets: winner_amount,
    }
  end

  #  HELPER FUNCS
  @spec multisig_2_of_2_script(Point.t(), Point.t()) :: Script.t()
  def multisig_2_of_2_script(a, b) ->
    # Script will be pseudo-multisig:
    # <BOB_PK> OP_CHECKSIGVERIFY <ALICE_PK> OP_CHECKSIG
    # Scripts are stacks, so must be inserted in reverse order.
    # This also means Alices Signature must come first in the witness_script
    s = Script.new()
    {:ok, s} = Script.push_op(s, :op_checksig)
    {:ok, s} = Script.push_data(s, Point.x_bytes(a))
    {:ok, s} = Script.push_op(s, :op_checksigverify)
    {:ok, s} = Script.push_data(s, Point.x_bytes(b))
    s
  end


end
