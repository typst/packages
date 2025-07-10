#import "@preview/tiaoma:0.3.0": code128
#import "/src/utils/get_bank_barcode_payload.typ": get_bank_barcode_payload

/// -> content
#let bank_barcode(
  amount,
  iban,
  reference_number,
  due_date,
  show_text: true,
) = {
  let barcode = get_bank_barcode_payload(
    amount,
    iban,
    reference_number,
    due_date,
  )

  set text(size: 10pt)

  align(center)[
    #if show_text {
      v(1em)
      barcode
    }

    #code128(barcode, options: (
      height: 33.0,
      text-gap: 10.0,
      show-hrt: false,
    ))]
}
