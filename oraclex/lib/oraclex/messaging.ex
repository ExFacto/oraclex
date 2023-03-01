defmodule Oraclex.Messaging do
  def ser(false, :bool), do: <<0x00>>
  def ser(true, :bool), do: <<0x01>>
  def ser(i, :u8), do: <<i::big-size(8)>>
  def ser(i, :u16), do: <<i::big-size(16)>>
  def ser(i, :u32), do: <<i::big-size(32)>>
  def ser(i, :u64), do: <<i::big-size(64)>>
  def ser(utf8_str, :utf8), do: utf_str |> String.normalize(:nfc) |> with_big_size()
  def ser(nil, :spk), do: <<0x00>>

  def ser(script, :spk) do
    # TODO: ensure this is what they mean by ASM.
    script = Script.serialize_script(script)
    with_big_size(script)
  end

  @type sha256(<<_::binary-size(32)>>)

  @type outcome(%{
          data: String.t(),
          payout: non_neg_integer()
        })

  def ser_enumerated_contract_descriptor(outcomes) do
    {ct, ser_outcomes} =
      Enum.reduce(outcomes, {0, <<>>}, fn outcome, {ct, ser_outcomes} ->
        {ct + 1, acc <> serialize_enumerated_outcome(outcome)}
      end)

    Utils.big_size(ct) <> ser_outcomes
  end

  defp serialize_enumerated_outcome(%{data: data, payout: payout}) do
    ser(data, :utf8) <> ser(payout, :u64)
  end

  @type numeric_outcome_contract(%{
          num_digits: non_neg_integer(),
          payout_function: payout_function(),
          rounding_intervals: rounding_intervals()
        })

  def ser_numeric_outcome_contract_descriptor(contract) do
    ser(contract.num_digits, :u16) <>
      serialize_payout_function(contract.payout_function) <>
      serialize_rouding_intervals(contract.rounding_intervals)
  end

  def ser_single_oracle_info(announcement) do
    serialize_oracle_announcement(announcement)
  end

  # SKIP: multi_oracle_info

  @type funding_input_info(%{
          serial_id: integer(),
          prev_tx: Transaction.t()
        })

  def ser_funding_input() do
    prev_tx_bytes = Transaction.serialize(prev_tx)

    ser(input_serial_id, :u64) <>
      Utils.with_big_size(prev_tx_bytes)

    ser(prev_vout, :u32) <>
      ser(sequence, :u32) <>
      ser(max_witness_len, :u16) <>
      ser(redeem_script, :script)
  end

  # might not be needed
  @spec ser_cets(list(String.t()), list(Transaction.t())) :: binary
  def ser_cets(outcomes, cets) do
    {ct, ser_outcomes} =
      Enum.reduce(outcomes, {0, <<>>}, fn outcome, {ct, acc} ->
        {ct + 1, acc <> ser(outcome, :utf8)}
      end)
  end

  @type cet_adaptor_signature(%{
          # BREAK WITH DLC Spec
          txid: sha256(),
          pubkey: Point.t(),
          adaptor_signature: Signature.t()
        })

  def ser_cet_adaptor_signatures(cet_adaptor_signatures) do
    {ct, ser_sigs} =
      Enum.reduce(cet_adaptor_signatures, {0, <<>>}, fn cas, {ct, acc} ->
        {ct + 1,
         acc <>
           cas.txid <>
           Point.x_bytes(cas.pubkey) <> Signature.serialize_signature(cas.adaptor_signature)}
      end)

    Utils.big_size(ct) <> ser_sigs
  end

  # funding signatures will ride along with PSBTs. SKIP

  @type enum_event_descriptor(list(String.t()))

  def ser_enum_event_descriptor(outcomes) do
    {ct, ser_outcomes} =
      Enum.reduce(outcomes, {0, <<>>}, fn outcome, {ct, acc} ->
        {ct + 1, acc <> ser(outcome, :utf8)}
      end)

    ser(ct, :u16) <> ser_outcomes
  end

  # @type numeric_event_descriptor(%{
  #         base: integer(),
  #         signed: boolean(),
  #         unit: String.t(),
  #         precision: integer(),
  #         digit_count: integer()
  #       })

  # def numeric_event_descriptor(event) do
  #   Utils.big_size(event.base) <>
  #     ser(event.is_signed, :bool) <>
  #     ser(event.unit, :utf8) <>
  #     ser(event.precision, :i32) <>
  #     ser(event.digit_count, :u16)
  # end

  @type oracle_event(%{
          nonces: list(Point.t()),
          maturity_epoch: non_neg_integer(),
          descriptor: event_descriptor(),
          id: String.t()
        })

  def ser_oracle_event(event) do
    {ct, ser_nonces} =
      Enum.reduce(event.nonces, {0, <<>>}, fn nonce, {ct, acc} ->
        {ct + 1, acc <> Point.x_bytes(nonce)}
      end)

    ser(ct, :u16) <>
      ser_nonces <>
      ser(event.maturity_epoch, :u32) <>
      ser_event_descriptor(event.descriptor) <> ser(event.id, :utf8)
  end

  def ser_oracle_announcement(event, pubkey, signature) do
    Signature.serialize_signature(signature) <>
      Point.x_bytes(pubkey) <> ser_oracle_event(event)
  end

  @oracle_attestation_type 55400
  def oracle_attestation(event_id, pubkey, signatures, outcomes) do
    {sig_ct, ser_sigs} =
      Enum.reduce(signatures, {0, <<>>}, fn sig, {ct, acc} ->
        {ct + 1, acc <> Signature.serialize_signature(sig)}
      end)

    ser_outcomes = Enum.reduce(outcomes, <<>>, fn outcome, acc -> acc <> ser(outcome, :utf8) end)

    ser(event_id, :utf8) <>
      Point.x_bytes(pubkey) <>
      ser(sig_ct, :u16) <>
      ser_sigs <>
      ser_outcomes
  end



end
