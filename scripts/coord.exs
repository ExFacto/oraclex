#  GIVEN

defmodule Coordinator do

  def main() do

  end


alice_init_addr = ""
{:ok, alice_init_script} = Script.from_address(alice_init_addr)
alice_init_txid = ""
alice_init_vout = 1
alice_init_amount = 0

alice_fund_amount = 100_000
alice_change_amount = alice_init_amount - alice_fund_amount

fund_fee = 2_000
settle_fee = 2_000

bob_init_addr = ""
{:ok, bob_init_script} = Script.from_address(bob_init_addr)
bob_init_txid = ""
bob_init_vout = 1
bob_init_amount = 0

bob_fund_amount = 102_000
bob_change_amount = bob_init_amount - bob_fund_amount - fund_fee

winner_gets = bob_fund_amount + alice_fund_amount - fund_fee - settle_fee -
loser_gets = 0

alice_fund_pk = Point.parse_public_key ""
bob_fund_pk = Point.parse_public_key ""

init_amounts = [alice_init_amount, bob_init_amount]
init_scriptpubkeys = [
  Script.serialize_with_compact_size(alice_init_script),
  Script.serialize_with_compact_size(bob_init_script)
]

# Setup

multisig_2_of_2_script = fn a, b ->
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

# First, Alice and Bob will create a 2-of-2 funding address
fund_script = multisig_2_of_2_script.(alice_fund_pk, bob_fund_pk)
fund_leaf = Taproot.TapLeaf.new(Taproot.bip342_leaf_version(), fund_script)
{:ok, fund_scriptpubkey, r} = Script.create_p2tr_script_only(fund_leaf, new_rand_int.())

fund_amount = alice_fund_amount + bob_fund_amount

fund_tx = %Transaction{
  version: 1,
  inputs: [
    %Transaction.In{
      prev_txid: alice_init_txid,
      prev_vout: alice_init_vout,
      script_sig: "",
      sequence_no: 2147483648
    },
    %Transaction.In{
      prev_txid: bob_init_txid,
      prev_vout: bob_init_vout,
      script_sig: "",
      sequence_no: 2147483648
    }
  ],
  outputs: [
    # the coin used in the contract
    %Transaction.Out{
      value: fund_amount,
      script_pub_key: Script.to_hex(fund_scriptpubkey)
    }
    # Change Amounts
    %Transaction.Out{
      value: alice_change_amount,
      script_pub_key: Script.to_hex(alice_change_script)
    },
    %Transaction.Out{
      value: bob_change_amount,
      script_pub_key: Script.to_hex(bob_change_script)
    }
  ],
  lock_time: 0
}

# Share with Alice & Bob
fund_txid = Transaction.transaction_id(fund_tx)
fund_vout = 0
fund_amounts = [fund_amount]
fund_scriptpubkeys = [Script.serialize_with_compact_size(fund_scriptpubkey)]


cet_hash_type = 0x00

# First CET: EAGLES, alice wins, and gets 75% of the funding tx (excluding fees)
eagles_cet = %Transaction{
  version: 1,
  inputs: [
    %Transaction.In{
      prev_txid: fund_txid,
      prev_vout: fund_vout,
      script_sig: "",
      sequence_no: 2147483648,
    }
  ],
  outputs: [
    # ALICE WINS! gets 150M sats from the 1M she put in
    %Transaction.Out{
      value: winner_gets,
      script_pub_key: Script.to_hex(alice_dest_script)
    },
    # BOB LOSES
    # %Transaction.Out{
    #   value: 50_000_000,
    #   script_pub_key: Script.to_hex(bob_dest_script)
    # }
  ],
  lock_time: 0
}
# calculate the sighash for the EAGLES CET
eagles_cet_sighash = Transaction.bip341_sighash(
  eagles_cet,
  cet_hash_type, # sighash_default (all)
  0x01, # we are using taproot scriptpath spend, so ext_flag must be 1
  0, # index we're going to sign
  fund_amounts, # list of amounts for each input being spent
  fund_scriptpubkeys, # list of prev scriptpubkeys for each input being spent
  tapleaf: fund_leaf
) |> :binary.decode_unsigned()

# Second CET: CHIEFS
chiefs_cet = %Transaction{
  version: 1,
  inputs: [
    # Notice this input is the same coin spent in the Eagles CET tx. So they can't both be valid.
    %Transaction.In{
      prev_txid: fund_txid,
      prev_vout: fund_vout,
      script_sig: "",
      sequence_no: 2147483648,
    }
  ],
  outputs: [
    # ALICE LOSES
    # %Transaction.Out{
    #   value: 50_000_000,
    #   script_pub_key: Script.to_hex(alice_dest_script)
    # },
    # BOB WINS!
    %Transaction.Out{
      value: winner_gets,
      script_pub_key: Script.to_hex(bob_dest_script)
    }
  ],
  lock_time: 0
}
# calculate the Sighash for the CHIEFS CET
chiefs_cet_sighash = Transaction.bip341_sighash(
  chiefs_cet,
  cet_hash_type, # sighash_default (all)
  0x01, # we are using taproot scriptpath spend, so ext_flag = 1
  0, # only one input in this tx
  fund_amounts, # list of amounts for each input being spent
  fund_scriptpubkeys, # list of prev scriptpubkeys for each input being spent
  tapleaf: fund_leaf
) |> :binary.decode_unsigned()


# SHARE with alice & bob
eagles_cet_sighash
chiefs_cet_sighash

end
