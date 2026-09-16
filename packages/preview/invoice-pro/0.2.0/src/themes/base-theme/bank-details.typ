#import "@preview/ibanator:0.1.0"
#import "@preview/sepay:0.1.1": epc-qr-code

#let render-bank-details(ctx, view) = {
  let qr-image = block(
    width: view.qr-code.size,
    height: view.qr-code.size,
    fill: black,
    align(
      center + horizon,
      text(fill: white, .8em, style: "italic")[EPC \ QR-CODE \ \<HERE\>],
    ),
  )

  if float(view.payment-amount) >= 0.1 {
    qr-image = epc-qr-code(
      view.sender.name,
      view.sender.iban,
      ..(
        bic: view.sender.bic,
        amount: float(view.payment-amount),
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
      Kontoinhaber:in: #view.sender.name \
      Kreditinstitut: #view.sender.bank \
      IBAN: *#ibanator.iban(view.sender.iban)* \
      BIC: #view.sender.bic \
      #if (
        view.show-reference and view.reference != none
      ) [Referenz: *#view.reference*] \
      #h(6.5cm)
    ][
      #if view.qr-code.display {
        block(width: view.qr-code.size, qr-image)
      }
    ],
  )
}
