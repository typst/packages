#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/tiaoma:0.3.0": qrcode
#import "/src/utils/get_bank_qr_payload.typ": get_bank_qr_payload

/// -> content
#let bank_qr_code(
  amount,
  beneficiary,
  iban,
  bic,
  reference_number,
  due_date,
) = {
  assert(
    beneficiary.len() <= 70,
    message: "Name of beneficiary can be at most 70 characters",
  )
  assert(
    decimal("0.01") <= amount and amount <= decimal("999999999.99"),
    message: "Amount must be between 0.01 and 999999999.99",
  )

  let payload = get_bank_qr_payload(
    amount,
    beneficiary,
    iban,
    bic,
    reference_number,
    due_date,
  )

  qrcode(payload, options: (
    // error level M
    option_1: "M",
    // QR code version 13
    option_2: 13,
  ))
}
