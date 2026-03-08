#import plugin("/rust_tools/rust_tools.wasm"): get_bank_barcode
#import "/src/utils/call-wasm.typ": call-wasm

/// -> str
#let get-bank-barcode-payload(amount, iban, reference-number, due-date) = {
  assert(type(due-date) == datetime)

  assert(
    iban.starts-with("FI"),
    message: "Bank barcode supports only Finnish IBAN",
  )

  call-wasm(get_bank_barcode, (
    str(amount),
    iban,
    reference-number.replace(" ", ""),
    due-date.year(),
    due-date.month(),
    due-date.day(),
  ))
}
