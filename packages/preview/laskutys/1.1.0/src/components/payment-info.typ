#import "/src/utils/translate.typ": translate
#import "/src/utils/formatter.typ": formatter
#import plugin("/rust_tools/rust_tools.wasm"): (
  check_reference_number, iban as iban-constructor,
)
#import "/src/utils/call-wasm.typ": call-wasm
#import "/src/config.typ": CURRENCY, DEFAULT-COLORS, FONT-SIZES
#import "/src/components/bank-barcode.typ": bank-barcode
#import "/src/components/bank-qrcode.typ": bank-qr-code

/// Payment info: IBAN, BIC, amount to pay, etc.
///
/// -> content
#let payment-info(
  beneficiary: none,
  amount: none,
  iban: none,
  bic: none,
  due-date: none,
  reference-number: none,
  // Show bank barcode
  barcode: true,
  show-barcode-text: true,
  // Show EPC QR code
  qrcode: true,
  colors: DEFAULT-COLORS,
) = {
  assert(beneficiary != none, message: "Missing beneficiary")
  assert(amount != none, message: "Missing amount")
  assert(due-date != none, message: "Missing due date")
  assert(reference-number != none, message: "Missing reference number")
  assert(iban != none, message: "Missing IBAN")
  assert(bic != none, message: "Missing BIC")

  assert(amount != none, message: "Missing amount")
  assert(type(amount) == decimal, message: "Pass amount as decimal")
  assert(amount > decimal("0"), message: "Amount must be greater than zero")

  assert(
    call-wasm(check_reference_number, reference-number),
    message: "Invalid reference number",
  )

  let iban = call-wasm(iban-constructor, iban)

  let payment-block = [
    #set text(size: FONT-SIZES.SMALL)

    #grid(
      columns: 2,
      row-gutter: 0.5em,
      column-gutter: 1em,
      [#translate("beneficiary"):], beneficiary,
      [IBAN:], iban,
      [BIC:], bic,
      [#translate("reference-number"):], reference-number,
    )]
  let amount-block = [
    #set text(size: 1.3em)

    #grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 0.5em,
      [#translate("to-pay"):], [*#formatter("{:.2}", amount) #CURRENCY*],

      [#translate("due-date"):],
      due-date.display("[year]-[month padding:zero]-[day padding:zero]"),
    )]

  box(stroke: colors.active, radius: 0.5em, inset: 2em, grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    column-gutter: 1em,

    grid.cell(
      colspan: 2,
      align: left,
      payment-block,
    ),
    grid.cell(
      colspan: 2,
      align: right,
      amount-block,
    ),

    grid.cell(colspan: 3, align: left + bottom, if barcode {
      bank-barcode(
        amount,
        iban,
        reference-number,
        due-date,
        show-text: show-barcode-text,
      )
    }),

    grid.cell(align: right + bottom, if qrcode {
      bank-qr-code(
        amount,
        beneficiary,
        iban,
        bic,
        reference-number,
        due-date,
      )
    }),
  ))
}
