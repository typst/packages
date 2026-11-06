#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/tiaoma:0.3.0": qrcode
#import "/src/utils/get-bank-qr-payload.typ": get-bank-qr-payload

/// -> content
#let bank-qr-code(
  amount,
  beneficiary,
  iban,
  bic,
  reference-number,
  due-date,
) = {
  assert(
    beneficiary.len() <= 70,
    message: "Name of beneficiary can be at most 70 characters",
  )
  assert(
    decimal("0.01") <= amount and amount <= decimal("999999999.99"),
    message: "Amount must be between 0.01 and 999999999.99",
  )

  let payload = get-bank-qr-payload(
    amount,
    beneficiary,
    iban,
    bic,
    reference-number,
    due-date,
  )

  qrcode(payload, options: (
    // error level M
    option-1: 2,
    // QR code version 13
    option-2: 13,
  ))
}
