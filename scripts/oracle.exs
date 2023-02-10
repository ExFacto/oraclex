alias Bitcoinex.{Secp256k1,Transaction, Script, Utils, Taproot}
alias Bitcoinex.Secp256k1.{Point, PrivateKey, Signature, Schnorr}

new_rand_int = fn ->
  32
  |> :crypto.strong_rand_bytes()
  |> :binary.decode_unsigned()
end

new_privkey = fn ->
  {:ok, sk} =
    new_rand_int.()
    |> PrivateKey.new()
  Secp256k1.force_even_y(sk)
end

oracle_sk = new_privkey.()
oracle_pk = PrivateKey.to_point(oracle_sk)

# The bet will be a simple EAGLES or CHIEFS bet.

# the same nonce must be used for both outcomes in order to guarantee that the Oracle
# cannot sign both events without leaking their own private key. In a more trust-minimized
# example, the Oracle should prove ownership of a UTXO with the public key they use for
# the signing, in order to prove that they have something at stake if they should sign both events.

# Oracle does not use the standard BIP340 method for generating a nonce.
# This is because the nonce must not commit to the message, so that it can
# be reused for either outcome.
oracle_event_nonce = new_privkey.()
event_nonce_point = PrivateKey.to_point(oracle_event_nonce)

eagles_msg = "EAGLES"
chiefs_msg = "CHIEFS"

# PUBLISH to alice, bob
public = %{
  oracle_pk: oracle_pk,
  event_nonce_point: event_nonce_point,
  case1: eagles_msg,
  case2: chiefs_msg
}

eagles_sighash = Utils.double_sha256(public.case1)
chiefs_sighash = Utils.double_sha256(public.case2)


eagles_sig_point = Schnorr.calculate_signature_point(public.event_nonce_point, oracle_pk, eagles_sighash)
chiefs_sig_point = Schnorr.calculate_signature_point(public.event_nonce_point, oracle_pk, chiefs_sighash)


#  RESOLUTION

# ## EAGLES WIN
eagles_sig = Schnorr.sign_with_nonce(oracle_sk, oracle_event_nonce, :binary.decode_unsigned(eagles_sighash))

# BROADCAST
eagles_sig
