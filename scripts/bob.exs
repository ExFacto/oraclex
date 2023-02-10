# Initial setup for this example: give Alice and bob one coin worth 100,010,000 sats each, in order to fund the DLC.
# these ouotputs will be simple keyspend-only P2TRs
# Skip if already have a coin

# bob_init_sk = new_privkey.()
# bob_init_pk = PrivateKey.to_point(bob_init_sk)
# bob_init_script_tree = nil
# {:ok, bob_init_script} = Script.create_p2tr(bob_init_pk, bob_init_script_tree)
# {:ok, bob_init_addr} = Script.to_address(bob_init_script, :regtest)

bob_init_addr = "bcrt1qlngckh2q6vlufupgwj20h0en90n5l7jkdyy33j"
{:ok, bob_init_script} = Script.from_address(bob_init_addr)
bob_init_txid = "bcrt1qemp092epglvrmzjr598n3ah88l7ht8n465xuz6"
bob_init_vout = 1
bob_init_amount = 0

# Agree with Alice on fee for funding tx
fund_fee = 2_000


bob_fund_amount = 102_000 # bob will also pay for the CET tx fees
bob_change_amount = bob_init_amount - bob_fund_amount - fund_fee
bob_change_addr = "bcrt1qlngckh2q6vlufupgwj20h0en90n5l7jkdyy33j"
{:ok, bob_change_script} = Script.from_address(bob_change_addr)
bob_dest_addr = "bcrt1qj4zlyyrrguhlf8set879vqwev7jxs2gzq9x6p2"
{:ok, bob_dest_script} = Script.from_address(bob_dest_addr)

# Bob verifies the funding output script given r

fund_p = Script.calculate_unsolvable_internal_key(r)
is_correct_p2tr = Script.validate_unsolvable_internal_key(fund_scriptpubkey, fund_leaf, r)
{:ok, fund_addr} = Script.to_address(fund_scriptpubkey, :regtest)


# RECEIVE FROM COORD
fund_txid = ""
fund_vout = 0
fund_amounts = [fund_amount]
fund_scriptpubkeys = [Script.serialize_with_compact_size(fund_scriptpubkey)]

# RECEIVE FROM ORACLE
public = %{
  oracle_pk: oracle_pk,
  event_nonce_point: event_nonce_point,
  case1: eagles_msg,
  case2: chiefs_msg
}

# calculate
eagles_sighash = Utils.double_sha256(public.case1)
chiefs_sighash = Utils.double_sha256(public.case2)

eagles_sig_point = Schnorr.calculate_signature_point(public.event_nonce_point, oracle_pk, eagles_sighash)
chiefs_sig_point = Schnorr.calculate_signature_point(public.event_nonce_point, oracle_pk, chiefs_sighash)


# bob creates adaptor sig for Chiefs case (he wins)
aux_rand = new_rand_int.() # generate some entropy for this signature
{:ok, bob_chiefs_adaptor_sig, bob_chiefs_was_negated} = Schnorr.encrypted_sign(bob_fund_sk, chiefs_cet_sighash, aux_rand, chiefs_sig_point)

# bob creates adatpro sig for Eagles case (he loses)
aux_rand = new_rand_int.() # generate some entropy for this signature
{:ok, bob_eagles_adaptor_sig, bob_eagles_was_negated} = Schnorr.encrypted_sign(bob_fund_sk, eagles_cet_sighash, aux_rand, eagles_sig_point)


# RECEIVES Alices's Adaptor Signatures
{alice_fund_pk, alice_chiefs_adaptor_sig, alice_chiefs_was_negated} = {}
{alice_fund_pk, alice_eagles_adaptor_sig, alice_eagles_was_negated} = {}

# Bob verifies Alice's Chiefs signature
is_valid = Schnorr.verify_encrypted_signature(alice_chiefs_adaptor_sig, alice_fund_pk, chiefs_cet_sighash, chiefs_sig_point, alice_chiefs_was_negated)
# Bob verifies Alice's eagles signature
is_valid = Schnorr.verify_encrypted_signature(alice_eagles_adaptor_sig, alice_fund_pk, eagles_cet_sighash, eagles_sig_point, alice_eagles_was_negated)


# Now Sign and broadcast Funding TX

# TODO create PSBT of fund_tx

alice_fund_sig = Signature.parse_signature ""
bob_fund_sig = Signature.parse_signature ""

# Wait for confirmation of fund_tx


# RESOLUTION

# RECEIVE: chiefs_sig
chiefs_sig = Signature.parse_signature ""
#  ## CHIEFS WIN!

is_valid = Schnorr.verify_signature(oracle_pk, :binary.decode_unsigned(chiefs_sighash), chiefs_sig)


%Signature{s: settlement_secret} = chiefs_sig
{:ok, settlement_secret} = PrivateKey.new(settlement_secret)

cet_hash_byte =
  if cet_hash_type == 0x00 do
    <<>>
  else
    <<cet_hash_type>>
  end


# Then, Bob can decrypt Alice's Chiefs signature
alice_eagles_sig = Schnorr.decrypt_signature(alice_chiefs_adaptor_sig, settlement_secret, alice_chiefs_was_negated)
# why not verify?
is_valid = Schnorr.verify_signature(alice_fund_pk, chiefs_cet_sighash, alice_chiefs_sig)


# Bob can also decrypt his own chiefs adaptor signature
bob_chiefs_sig = Schnorr.decrypt_signature(bob_chiefs_adaptor_sig, settlement_secret, bob_chiefs_was_negated)
# Don't trust, verify
is_valid = Schnorr.verify_signature(bob_fund_pk, chiefs_cet_sighash, bob_chiefs_sig)


# fund_p is the internal taproot key. In this case, it is unsolvable, as verified earlier.
# we take fund_leaf, the script_tree from earlier, and select the index of the script we want to spend.
# Here, there is only 1 script in the tree, so idx must be 0
control_block = Taproot.build_control_block(fund_p, fund_leaf, 0)

# serialize everything for insertion into the tx
bob_chiefs_sig_hex = Signature.serialize_signature(bob_chiefs_sig) <> cet_hash_byte |> Base.encode16(case: :lower)
alice_chiefs_sig_hex = Signature.serialize_signature(alice_chiefs_sig) <> cet_hash_byte |> Base.encode16(case: :lower)
fund_script_hex = Script.to_hex(fund_script)
control_block_hex = control_block |> Base.encode16(case: :lower)

tx = %Transaction{chiefs_cet | witnesses: [
  %Transaction.Witness{
    txinwitness: [alice_chiefs_sig_hex, bob_chiefs_sig_hex, fund_script_hex, control_block_hex]
  }
]
}

Transaction.Utils.serialize(tx) |> Base.encode16(case: :lower)
