defmodule Oraclex.Contract do
end

defmodule Oraclex.Contract.Offer do
  @protocol_version_v0 0

  @type t :: %__MODULE__{
          version: non_neg_integer(),
          chain_hash: <<_::binary-size(32)>>,
          contract_flags: non_neg_integer(),
          temp_contract_id: String.t(),
          funding_pubkey: Point.t(),
          payout_script: Script.t(),
          payout_serial_id: non_neg_integer(),
          change_script: Script.t(),
          offer_collateral_amount: non_neg_integer(),
          funding_inputs: list(input),
          fund_output_serial_id: non_neg_integer(),
          feerate: non_neg_integer(),
          cet_locktime: non_neg_integer()
        }

  def new(
        chain_hash,
        contract_info,
        offer_collateral_amount,
        funding_inputs,
        funding_pubkey,
        payout_script,
        change_script,
        offer_collateral_amount,
        funding_inputs,
        feerate,
        cet_locktime
      ) do
    version = @protocol_version_v0
    contract_flags = 0

    temp_contract_id = new_temp_contract_id()

    payout_serial_id = new_serial_id()

    fund_output_serial_id = new_serial_id()

    %__MODULE__{
      version: version,
      chain_hash: chain_hash,
      contract_flags: contract_flags,
      temp_contract_id: temp_contract_id,
      funding_pubkey: funding_pubkey,
      payout_script: payout_script,
      payout_serial_id: payout_serial_id,
      change_script: change_script,
      offer_collateral_amount: offer_collateral_amount,
      funding_inputs: funding_inputs,
      fund_output_serial_id: fund_output_serial_id,
      feerate: feerate,
      cet_locktime: cet_locktime
    }
  end

  def serialize(o = %Offer{}) do
    ser(o.version, :u32) <>
      ser(o.contract_flags, :u8) <>
      o.chain_hash <>
      o.temp_contract_id <>
      serialize_contract_info(o.contract_info) <>
      Point.x_bytes(o.funding_pubkey) <>
      Utils.script_with_big_size(o.payout_script) <>
      ser(o.payout_serial_id, :u64) <>
      ser(o.offer_collateral_amount, :u64) <>
      serialize_funding_inputs(o.funding_inputs) <>
      Utils.script_with_big_size(o.change_script) <>
      ser(o.fund_output_serial_id, :u64) <>
      ser(o.feerate, :u64) <>
      ser(o.cet_locktime, :u32) <>
      ser(o.refund_locktime, :u32) <>
      serialize_offer_tlvs(o.tlvs)
  end
end

defmodule Oraclex.Contract.Accept do
  @type t :: %__MODULE__{
    version: non_neg_integer(),
    chain_hash: <<_::binary-size(32)>>,
    temp_contract_id: String.t(),
    funding_pubkey: Point.t(),
    payout_script: Script.t(),
    payout_serial_id: non_neg_integer(),
    change_script: Script.t(),
    change_serial_id: non_neg_integer(),
    collateral_amount: non_neg_integer(),
    funding_inputs: list(input),
    fund_output_serial_id: non_neg_integer(),
    cet_adaptor_signatures: list({Signature.t(), bool}),
    refund_signature: Signature.t(),
    negotiation_fields: list(), # unused
    tlvs: list(), # unused
  }

  def new(chain_hash, funding_pubkey, payout_script, change_script, collateral_amount, funding_inputs, cet_adaptor_signatures, refund_signature) do
    version = @protocol_version_v0
    contract_flags = 0

    temp_contract_id = new_temp_contract_id()

    payout_serial_id = new_serial_id()

    fund_output_serial_id = new_serial_id()

    %__MODULE__{
      version: version,
      chain_hash: chain_hash,
      temp_contract_id: temp_contract_id,
      funding_pubkey: funding_pubkey,
      payout_script: payout_script,
      payout_serial_id: payout_serial_id,
    }
  end

  def serialize(a = %Accept{}) do
    ser(a.version, :u32) <>
      a.temp_contract_id <>
      ser(a.collateral_amount, :u64) <>
      Point.x_bytes(funding_pubkey) <>
      Utils.script_with_big_size(a.payout_script) <>
      ser(a.payout_serial_id, :u64) <>
      serialize_funding_inputs(a.funding_inputs) <>
      Utils.script_with_big_size(a.change_script) <>
      ser(a.change_serial_id, :u64) <>
      serialize_cet_adaptor_signatures(a.cet_adaptor_signatures) <>
      Signature.serialize_signature(a.refund_signature) <>
      serialize_negotiation_fields(a.negotiation_fields) <>
      serialize_accept_tlvs(a.tlvs)
  end
end
