#import "@preview/sepay:0.1.1": epc-qr-code
#import "../../utils/iban.typ": format-iban

// Stands in for an EPC-QR code that cannot be generated, with
// `zugferd-errors: "report"`.
#let _qr-placeholder(size, problems) = block(
  width: size,
  height: size,
  inset: 2pt,
  stroke: 1pt + rgb("#b91c1c"),
  clip: true,
  {
    set par(justify: false, leading: 0.3em)
    set text(size: 5pt, fill: rgb("#b91c1c"), hyphenate: false)
    align(center + horizon)[
      No EPC-QR code: #problems.map(problem => problem.short).join(", ")
    ]
  },
)

// Draws the bank details. `bank-details` prepares the view (see there): the
// IBAN and BIC in electronic format, and the EPC-QR code as its payload or
// the problems that prevent it.
#let render-bank-details(ctx, view) = {
  let strings = ctx.locale.strings
  let bd-str = strings.bank-details

  let remittance-text = view.at("text", default: none)
  let reference = view.at("reference", default: none)

  let iban = view.sender.iban
  let valid-iban = view.sender.at("iban-valid", default: true)
  let bic = view.sender.at("bic", default: "")

  let qr = view.qr-code
  let payload = qr.at("payload", default: none)
  let qr-image = if payload != none {
    epc-qr-code(
      payload.beneficiary,
      payload.iban,
      bic: payload.bic,
      amount: payload.amount,
      reference: payload.reference,
      text: payload.text,
      width: qr.size,
      height: qr.size,
    )
  } else if qr.at("problems", default: ()).len() > 0 {
    _qr-placeholder(qr.size, qr.problems)
  }

  block(
    width: 100% - view.qr-code.size,
    grid(
      columns: (auto, 1fr),
      align: top,
      gutter: 1em,
      stroke: none,
    )[
      #set par(leading: 0.4em)
      #set text(number-type: "lining")
      #bd-str.account-holder: #view.sender.name \
      #bd-str.bank: #view.sender.bank \
      #bd-str.iban: *#format-iban(iban)*#if not valid-iban {
        text(fill: rgb("#b91c1c"))[ (#if iban == "" [missing] else [invalid])]
      } \
      #if bic not in (none, "") [#bd-str.bic: #bic \ ]
      #if (
        view.show-reference and remittance-text != none
      ) [#bd-str.reference: *#remittance-text*] else if (
        view.show-reference and reference != none
      ) [#bd-str.reference: *#reference*] \
      #h(6.5cm)
    ][
      #if view.qr-code.display {
        block(width: view.qr-code.size, qr-image)
      }
    ],
  )
}
