#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/tiaoma:0.3.0": qrcode

/// -> str
#let get-bank-qr-payload(
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

  let payload = (
    "BCD",
    "001",
    "1",
    "SCT",
    bic,
    beneficiary,
    iban.replace(" ", ""),
    strfmt("EUR{:.2}", amount, fmt-decimal-separator: "."),
    "",
    reference-number.replace(" ", ""),
    "",
    due-date.display(
      "ReqdExctnDt/[year]-[month padding:zero]-[day padding:zero]",
    ),
  ).join("\n")

  let payload_length = bytes(payload).len()
  assert(
    payload_length <= 331,
    message: strfmt(
      "Cannot encode data with maximum QR version 13: payload length {} is greater than 331",
      payload_length,
    ),
  )

  payload
}
