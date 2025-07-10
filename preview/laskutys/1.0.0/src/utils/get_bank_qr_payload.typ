#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/tiaoma:0.3.0": qrcode

/// -> str
#let get_bank_qr_payload(
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

  (
    "BCD",
    "001",
    "1",
    "SCT",
    bic,
    beneficiary,
    iban.replace(" ", ""),
    strfmt("EUR{:.2}", amount, decimal_separator: "."),
    "",
    reference_number.replace(" ", ""),
    "",
    due_date.display(
      "ReqdExctnDt/[year]-[month padding:zero]-[day padding:zero]",
    ),
  ).join("\n")
}
