#import "@preview/tiaoma:0.3.0": code128
#import "/src/utils/get-bank-barcode-payload.typ": get-bank-barcode-payload

/// -> content
#let bank-barcode(
  amount,
  iban,
  reference-number,
  due-date,
  show-text: true,
) = {
  let barcode = get-bank-barcode-payload(
    amount,
    iban,
    reference-number,
    due-date,
  )

  set text(size: 10pt)

  align(center)[
    #if show-text {
      v(1em)
      barcode
    }

    #code128(barcode, options: (
      height: 33.0,
      text-gap: 10.0,
      show-hrt: false,
    ))]
}
