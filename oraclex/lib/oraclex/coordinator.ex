defmodule Oraclex.Coordinator do
  alias Oraclex.Oracle
  alias Oraclex.Oracle.{Event}
  alias Bitcoinex.{Script, Transaction}
  alias Bitcoinex.Secp256k1.{Point}

  @type contract :: %{
          event: any()
        }

  # steps 1-4 of forms.md
  @spec handle_maker(
          Event.announcement(),
          String.t(),
          non_neg_integer(),
          non_neg_integer(),
          {String.t(), String.t(), non_neg_integer(), non_neg_integer(), String.t()}
        ) :: any()
  def handle_maker(
        oracle_announcement,
        maker_outcome,
        fund_fee,
        cet_fee,
        {prev_outpoint, prev_address, prev_amount, fund_pubkey, fund_amount, dest_address}
      ) do
    # TODO maker_outcome must be an announcement outcome
    {prev_txid, prev_vout, prev_scriptpubkey, prev_amount} =
      handle_input_coin_info(prev_outpoint, prev_address, prev_amount)

    {fund_pk, fund_amount} = handle_funding_info(fund_pubkey, fund_amount)
    ## TODO: dest_address
    # dest_script = handle_settlement_info(nil)

    change_amount = prev_amount - fund_amount - fund_fee
    winner_amount = fund_amount - cet_fee
    loser_amount = 0
    true
    # send bet summary back to maker
  end

  # TODO probably need someway to specific which offer to take
  # @spec handle_taker({String.t(), String.t(), non_neg_integer(), non_neg_integer(), String.t()}) ::
  #         any()
  def handle_taker(
        oracle_announcement,
        taker_outcome,
        {prev_outpoint, prev_address, prev_amount, fund_pubkey, fund_amount, dest_address}
      ) do
    {prev_txid, prev_vout, prev_scriptpubkey, prev_amount} =
      handle_input_coin_info(prev_outpoint, prev_address, prev_amount)

    {fund_pk, fund_amount} = handle_funding_info(fund_pubkey, fund_amount)
    # dest_script = handle_settlement_info(dest_address)
    true
    # Notify both maker & taker with bet summary & Funding TX, r, & CETs
  end

  defp handle_join_offer() do
    # TODO we must ensure only 2 people join an offer.
    # Should we use optional names or label first Maker and second Taker
  end

  @spec handle_input_coin_info(String.t(), String.t(), String.t()) ::
          {any(), Transaction.Out.t()}
  defp handle_input_coin_info(prev_outpoint, prev_address, prev_amount) do
    # TODO: how should we set app-wide network & check against returned network
    {:ok, prev_scriptpubkey, _network} = Script.from_address(String.trim(prev_address))
    [prev_txid, vout] = String.split(String.trim(prev_outpoint), ":")
    prev_vout = String.to_integer(vout)
    prev_amount = String.to_integer(String.trim(prev_amount))

    {{prev_txid, prev_vout},
     %Transaction.Out{script_pub_key: prev_scriptpubkey, value: prev_amount}}
  end

  defp handle_funding_info(pubkey, amount) do
    amount = String.to_integer(amount)

    case Point.lift_x(pubkey) do
      {:error, msg} ->
        {:error, msg}

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
    # %{
    #   fund_amount: fund_amount,
    #   winner_gets: winner_amount,
    #   outcomes: event.outcomes,
    #   dest_scripts: dest_scripts
    # }
    %{}
  end

  # steps 6-7 of forms.md

  def send_funding_tx_info(
        prev_outputs,
        outpoints,
        alice_fund_pk,
        bob_fund_pk,
        fund_amount,
        change_outputs
      ) do
    # FUTURE USE alice_prev_out = Enum.at(prev_outputs, 0)
    # FUTURE USE bob_prev_out = Enum.at(prev_outputs, 1)
    # FUTURE USE # TODO put this in the PSBT
    # FUTURE USE init_amounts = [alice_prev_out.amount, bob_prev_out.amount]
    # FUTURE USE init_scriptpubkeys = [
    # FUTURE USE   Script.serialize_with_compact_size(alice_prev_out.script_pub_key),
    # FUTURE USE   Script.serialize_with_compact_size(bob_prev_out.script_pub_key)
    # FUTURE USE ]

    {alice_txid, alice_vout} = Enum.at(outpoints, 0)
    {bob_txid, bob_vout} = Enum.at(outpoints, 1)

    inputs = [
      build_input(alice_txid, alice_vout),
      build_input(bob_txid, bob_vout)
    ]

    # construct funding output
    ## TODO: support building funding output
    # fund_output = build_funding_output(alice_fund_pk, bob_fund_pk, fund_amount)

    outputs = [nil | change_outputs]

    tx = build_tx(inputs, outputs)

    # Share fund_tx with Alice & Bob for later
    # TODO: get fund_tx arg
    fund_txid = Transaction.transaction_id(nil)
    fund_vout = 0

    fund_outpoint = {fund_txid, fund_vout}

    # FUTURE USE fund_amounts = [fund_amount]
    # FUTURE USE fund_scriptpubkeys = [Script.serialize_with_compact_size(fund_scriptpubkey)]
  end

  @spec build_funding_output(Point.t(), Point.t()) :: {:ok, Script.t(), non_neg_integer()}
  defp build_funding_output(alice_fund_pk, bob_fund_pk) do
    multisig_2_of_2_script = fn _, _ -> "" end
    fund_script = multisig_2_of_2_script.(alice_fund_pk, bob_fund_pk)
    fund_leaf = Taproot.TapLeaf.new(Taproot.bip342_leaf_version(), fund_script)
    {:ok, fund_scriptpubkey, r} = Script.create_p2tr_script_only(fund_leaf, Utils.new_rand_int())
    ## TODO: fund_amount
    %Transaction.Out{value: nil, script_pub_key: Script.to_hex(fund_scriptpubkey)}
  end

  def send_cets(fund_outpoint, winner_amount, outcomes, dest_scripts)
      when length(outcomes) == length(dest_scripts) do
    ## TODO: implment build_all_certs/3
    # cets = build_all_cets(fund_outpoint, winner_amount, Enum.zip(outcomes, dest_scripts))
    # return map to client to be stored until resolution comes
  end

  defp build_all_cets({fund_outpoint, winner_amount, outcomes_scripts}) do
    # map of outcome -> CET
    Enum.reduce(outcomes_scripts, %{}, fn {outcome, script}, acc ->
      %{acc | outcome => build_cet(fund_outpoint, winner_amount, script)}
    end)
  end

  defp build_cet({fund_txid, fund_vout}, winner_amount, dest_script) do
    cet_hash_type = 0x00

    inputs = [build_input(fund_txid, fund_vout)]
    outputs = [%Transaction.Out{value: winner_amount, script_pub_key: Script.to_hex(dest_script)}]

    # TODO: get found_input arg
    build_tx(nil, outputs)
  end

  #  HELPER FUNCS

  defp build_input(txid, vout) do
    %Transaction.In{
      prev_txid: txid,
      prev_vout: vout,
      script_sig: "",
      sequence_no: 2_147_483_648
    }
  end

  defp build_tx(inputs, outputs) do
    %Transaction{
      version: 1,
      inputs: inputs,
      outputs: outputs,
      lock_time: 0
    }
  end

  @spec multisig_2_of_2_script(Point.t(), Point.t()) :: Script.t()
  def multisig_2_of_2_script(a, b) do
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
