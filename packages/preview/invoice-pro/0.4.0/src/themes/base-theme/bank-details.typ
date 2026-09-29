#import "@preview/ibanator:0.1.0"
#import "@preview/sepay:0.1.1": epc-qr-code

#let render-bank-details(ctx, view) = {
  let strings = ctx.locale.strings
  let bd-str = strings.bank-details
  let currency-code = ctx.locale.currency.code

  let qr-image = none

  if currency-code == "EUR" {
    qr-image = epc-qr-code(
      view.sender.name,
      view.sender.iban,
      ..(
        bic: view.sender.bic,
        amount: if float(view.payment-amount) >= 0.1 {
          float(view.payment-amount)
        },
        width: view.qr-code.size,
        height: view.qr-code.size,
      )
        + if view.reference != none { (reference: view.reference) },
    )
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
      #bd-str.iban: *#ibanator.iban(view.sender.iban)* \
      #bd-str.bic: #view.sender.bic \
      #if (
        view.show-reference and view.reference != none
      ) [#bd-str.reference: *#view.reference*] \
      #h(6.5cm)
    ][
      #if view.qr-code.display {
        block(width: view.qr-code.size, qr-image)
      }
    ],
  )
}
