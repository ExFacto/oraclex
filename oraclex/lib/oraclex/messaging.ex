defmodule Oraclex.Messaging do
  alias Oraclex.Utils
  alias Bitcoinex.{Script, Transaction}

  def ser(false, :bool), do: <<0x00>>
  def ser(true, :bool), do: <<0x01>>
  def ser(i, :u8), do: <<i::big-size(8)>>
  def ser(i, :u16), do: <<i::big-size(16)>>
  def ser(i, :u32), do: <<i::big-size(32)>>
  def ser(i, :u64), do: <<i::big-size(64)>>
  def ser(utf8_str, :utf8), do: utf8_str |> String.normalize(:nfc) |> Utils.with_big_size()
  def ser(nil, :spk), do: <<0x00>>

  def ser(script, :spk) do
    # TODO: ensure this is what they mean by ASM.
    script = Script.serialize_script(script)
    Utils.with_big_size(script)
  end

  @type sha256 :: <<_::256>>

  @type outcome :: %{
          data: String.t(),
          payout: non_neg_integer()
        }

  def ser_enumerated_contract_descriptor(outcomes) do
    {ct, ser_outcomes} = Utils.serialize_with_count(outcomes, &serialize_enumerated_outcome/1)
    Utils.big_size(ct) <> ser_outcomes
  end

  defp serialize_enumerated_outcome(%{data: data, payout: payout}) do
    ser(data, :utf8) <> ser(payout, :u64)
  end

  # @type numeric_outcome_contract :: %{
  #         num_digits: non_neg_integer(),
  #         payout_function: payout_function(),
  #         rounding_intervals: rounding_intervals()
  #       }

  # def ser_numeric_outcome_contract_descriptor(contract) do
  #   ser(contract.num_digits, :u16) <>
  #     serialize_payout_function(contract.payout_function) <>
  #     serialize_rouding_intervals(contract.rounding_intervals)
  # end

  # def ser_single_oracle_info(announcement) do
  #   Announcement.serialize(announcement)
  # end

  # SKIP: multi_oracle_info

  @type funding_input_info :: %{
          serial_id: integer(),
          prev_tx: Transaction.t(),
          prev_vout: non_neg_integer(),
          sequence: non_neg_integer(),
          max_witness_len: non_neg_integer(),
          redeem_script: Script.t()
        }

  def serialize_funding_inputs(inputs) do
    {ct, ser_inputs} = Utils.serialize_with_count(inputs, &ser_funding_input/1)
    Utils.big_size(ct) <> ser_inputs
  end

  def ser_funding_input(input) do
    prev_tx_bytes = Transaction.Utils.serialize(input.prev_tx)

    ser(input.serial_id, :u64) <>
      Utils.with_big_size(prev_tx_bytes)

    ser(input.prev_vout, :u32) <>
      ser(input.sequence, :u32) <>
      ser(input.max_witness_len, :u16) <>
      ser(input.redeem_script, :script)
  end

  def serialize_outcome(outcome), do: ser(outcome, :utf8)



  # funding signatures will ride along with PSBTs. SKIP

  @type enum_event_descriptor :: list(String.t())

  def ser_enum_event_descriptor(outcomes) do
    {ct, ser_outcomes} = Utils.serialize_with_count(outcomes, &serialize_outcome/1)
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





end
