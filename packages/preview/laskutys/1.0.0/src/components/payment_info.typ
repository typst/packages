#import "/src/utils/translate.typ": translate
#import "/src/utils/formatter.typ": formatter
#import plugin("/rust_tools/rust_tools.wasm"): (
  check_reference_number, iban as iban_constructor,
)
#import "/src/utils/call_wasm.typ": call_wasm
#import "/src/config.typ": CURRENCY, DEFAULT_COLORS, FONT_SIZES
#import "/src/components/bank_barcode.typ": bank_barcode
#import "/src/components/bank_qrcode.typ": bank_qr_code

/// Payment info: IBAN, BIC, amount to pay, etc.
///
/// -> content
#let payment_info(
  beneficiary: none,
  amount: none,
  iban: none,
  bic: none,
  due_date: none,
  reference_number: none,
  // Show bank barcode
  barcode: true,
  show_barcode_text: true,
  // Show EPC QR code
  qrcode: true,
  colors: DEFAULT_COLORS,
) = {
  assert(beneficiary != none, message: "Missing beneficiary")
  assert(amount != none, message: "Missing amount")
  assert(due_date != none, message: "Missing due date")
  assert(reference_number != none, message: "Missing reference number")
  assert(iban != none, message: "Missing IBAN")
  assert(bic != none, message: "Missing BIC")

  assert(amount != none, message: "Missing amount")
  assert(type(amount) == decimal, message: "Pass amount as decimal")
  assert(amount > decimal("0"), message: "Amount must be greater than zero")

  assert(
    call_wasm(check_reference_number, reference_number),
    message: "Invalid reference number",
  )

  let iban = call_wasm(iban_constructor, iban)

  let payment_block = [
    #set text(size: FONT_SIZES.SMALL)

    #grid(
      columns: 2,
      row-gutter: 0.5em,
      column-gutter: 1em,
      [#translate("beneficiary"):], beneficiary,
      [IBAN:], iban,
      [BIC:], bic,
      [#translate("reference_number"):], reference_number,
    )]
  let amount_block = [
    #set text(size: 1.3em)

    #grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 0.5em,
      [#translate("to_pay"):], [*#formatter("{:.2}", amount) #CURRENCY*],

      [#translate("due_date"):],
      due_date.display("[year]-[month padding:zero]-[day padding:zero]"),
    )]

  box(stroke: colors.active, radius: 0.5em, inset: 2em, grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    column-gutter: 1em,

    grid.cell(
      colspan: 2,
      align: left,
      payment_block,
    ),
    grid.cell(
      colspan: 2,
      align: right,
      amount_block,
    ),

    grid.cell(colspan: 3, align: left + bottom, if barcode {
      bank_barcode(
        amount,
        iban,
        reference_number,
        due_date,
        show_text: show_barcode_text,
      )
    }),

    grid.cell(align: right + bottom, if qrcode {
      bank_qr_code(
        amount,
        beneficiary,
        iban,
        bic,
        reference_number,
        due_date,
      )
    }),
  ))
}
