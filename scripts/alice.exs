# Initial setup for this example: give Alice and bob one coin worth 100,010,000 sats each, in order to fund the DLC.
# these ouotputs will be simple keyspend-only P2TRs
# If Alice and Bob already have coins, skip

# alice_init_sk = new_privkey.()
# alice_init_pk = PrivateKey.to_point(alice_init_sk)
# alice_init_script_tree = nil
# {:ok, alice_init_script} = Script.create_p2tr(alice_init_pk, alice_init_script_tree)
# {:ok, alice_init_addr} = Script.to_address(alice_init_script, :regtest)

alice_init_addr = ""
{:ok, alice_init_script} = Script.from_address(alice_init_addr)
alice_init_txid = ""
alice_init_vout = 1
alice_init_amount = 0

alice_fund_amount = 100_000
alice_change_amount = alice_init_amount - alice_fund_amount
alice_change_addr = ""
{:ok, alice_change_script} = Script.from_address(alice_change_addr)
alice_dest_addr = ""
{:ok, alice_dest_script} = Script.from_address(alice_dest_addr)


# Alice verifies the funding output script given fund_scriptpubkey, fund_leaf, r
#

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

# RECEIVE CET sighashes from coordinator
eagles_cet_sighash = 0
chiefs_cet_sighash = 0

# Alice creates adaptor sig for Chiefs case (she loses)
aux_rand = new_rand_int.() # generate some entropy for this signature
{:ok, alice_chiefs_adaptor_sig, alice_chiefs_was_negated} = Schnorr.encrypted_sign(alice_fund_sk, chiefs_cet_sighash, aux_rand, chiefs_sig_point)

# Alice creates adatpro sig for Eagles case (she wins)
aux_rand = new_rand_int.() # generate some entropy for this signature
{:ok, alice_eagles_adaptor_sig, alice_eagles_was_negated} = Schnorr.encrypted_sign(alice_fund_sk, eagles_cet_sighash, aux_rand, eagles_sig_point)


# RECEIVES Alices's Adaptor Signatures
{alice_fund_pk, alice_chiefs_adaptor_sig, alice_chiefs_was_negated} = {}
{alice_fund_pk, alice_eagles_adaptor_sig, alice_eagles_was_negated} = {}

# alice verifies Bob's Chiefs signature
is_valid = Schnorr.verify_encrypted_signature(bob_chiefs_adaptor_sig, bob_fund_pk, chiefs_cet_sighash, chiefs_sig_point, bob_chiefs_was_negated)
# alice verifies Bob's eagles signature
is_valid = Schnorr.verify_encrypted_signature(bob_eagles_adaptor_sig, bob_fund_pk, eagles_cet_sighash, eagles_sig_point, bob_eagles_was_negated)

# Now Sign and broadcast Funding TX

# TODO create PSBT of fund_tx

alice_fund_sig = Signature.parse_signature ""
bob_fund_sig = Signature.parse_signature ""

# Wait for confirmation of fund_tx


# RESOLUTION

# RECEIVE: eagles_sig
eagles_sig = Signature.parse_signature ""
#  ## EAGLES

# Alice & Bob should make sure this is a valid Schnorr signature
is_valid = Schnorr.verify_signature(oracle_pk, :binary.decode_unsigned(eagles_sighash), eagles_sig)

%Signature{s: settlement_secret} = eagles_sig
{:ok, settlement_secret} = PrivateKey.new(settlement_secret)

cet_hash_byte =
  if cet_hash_type == 0x00 do
    <<>>
  else
    <<cet_hash_type>>
  end

# Then, Alice can decrypt Bob's Eagles signature
bob_eagles_sig = Schnorr.decrypt_signature(bob_eagles_adaptor_sig, settlement_secret, bob_eagles_was_negated)
# why not verify?
is_valid = Schnorr.verify_signature(bob_fund_pk, eagles_cet_sighash, bob_eagles_sig)

# Alice can also decrypt her own adaptor signature
alice_eagles_sig = Schnorr.decrypt_signature(alice_eagles_adaptor_sig, settlement_secret, alice_eagles_was_negated)
# Don't trust, verify
is_valid = Schnorr.verify_signature(alice_fund_pk, eagles_cet_sighash, alice_eagles_sig)

# fund_p is the internal taproot key. In this case, it is unsolvable, as verified earlier.
# we take fund_leaf, the script_tree from earlier, and select the index of the script we want to spend.
# Here, there is only 1 script in the tree, so idx must be 0
control_block = Taproot.build_control_block(fund_p, fund_leaf, 0)

# serialize everything for insertion into the tx
bob_eagles_sig_hex = Signature.serialize_signature(bob_eagles_sig) <> cet_hash_byte |> Base.encode16(case: :lower)
alice_eagles_sig_hex = Signature.serialize_signature(alice_eagles_sig) <> cet_hash_byte |> Base.encode16(case: :lower)
fund_script_hex = Script.to_hex(fund_script)
control_block_hex = control_block |> Base.encode16(case: :lower)

tx = %Transaction{eagles_cet | witnesses: [
  %Transaction.Witness{
    txinwitness: [alice_eagles_sig_hex, bob_eagles_sig_hex, fund_script_hex, control_block_hex]
  }
]
}

Transaction.Utils.serialize(tx) |> Base.encode16(case: :lower)
# Claim



# ##  ALTERNATIVE: CHIEFS

# RECEIVE: chiefs_sig

# see bob
