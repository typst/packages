#import "@preview/tiaoma:0.3.0"

#set page(margin: 2cm)

#let letter-preset(
  t,
  lang: "en",
  seller: (
    name: none,
    address: none,
    uid: none,
    tel: none,
    email: none,
    is-kleinunternehmer: false,
  ),
  footer-middle: none,
  footer-right: none,
  banner-image: none,
  client: (
    gender-marker: none,
    full-name: none,
    short-name: none,
    address: none,
    uid: none,
  ),
  header-left: none,
  header-right: none,
  content: t => { [] },
) = {
  assert(lang in ("en", "de"), message: "Currently, only en and de are supported.")

  let t = if lang == "en" {
    (
      ..t,
      salutation-f: [Dear Ms.],
      salutation-m: [Dear Mr.],
      salutation-o: [Dear],
      table-label: (
        item-number: [*No.*],
        description: [*Description*],
        quantity: [*Qty.*],
        single-price: [*€ / Pcs.*],
        vat-rate: [*VAT Rate*],
        vat-price: [*€ VAT*],
        total-price: [*€ Total*],
      ),
      total-no-vat: [Total excl. VAT],
      total-vat: [VAT],
      total-with-vat: [Total incl. VAT],
    )
  } else if lang == "de" {
    (
      ..t,
      salutation-f: [Sehr geehrte Frau],
      salutation-m: [Sehr geehrter Herr],
      salutation-o: [Guten Tag],
      table-label: (
        item-number: [*Pos.*],
        description: [*Bezeichnung*],
        quantity: [*Menge*],
        single-price: [*€ / Stk*],
        vat-rate: [*USt. Satz*],
        vat-price: [*€ USt.*],
        total-price: [*€ Ges.*],
      ),
      total-no-vat: [€ Netto:],
      total-vat: [USt. Gesamt:],
      total-with-vat: [€ Brutto:],
    )
  }

  set page(paper: "a4", margin: 2cm, footer-descent: -0.5cm, footer: context {
    set text(size: 9pt)
    box(width: 100%, inset: 10pt, grid(
      align: center,
      columns: 3,
      box(width: 1fr, align(center, seller.name + "\n" + seller.tel + "\n" + seller.email)),
      grid.vline(stroke: 0.3pt),
      if footer-middle != none {
        box(width: 1fr, align(center, footer-middle))
      },
      grid.vline(stroke: 0.3pt),
      if footer-right != none {
        box(width: 1fr, align(center, footer-right))
      },
    ))
  })

  set text(font: "Cormorant Garamond", number-type: "lining", size: 12pt)

  place(top + right, dx: -0.5cm, dy: 1cm)[
    #set text(size: 14pt)
    #seller.name\
    #seller.address\
    #v(0.5em)
    #if seller.at("is-kleinunternehmer", default: false) and seller.at("uid", default: none) != none { [UID: #seller.uid] }
  ]

  place(top + left, dx: 0.5cm, dy: 4cm, [
    #set text(size: 14pt)
    #client.full-name\
    #client.address\
    #v(0.5em)
    #if client.at("uid", default: none) != none { [UID: #client.uid] }
  ])

  context {
    box(width: page.width, place(top + left, dx: -here().position().x, dy: -here().position().y, [
      #banner-image
    ]))
  }
  v(7cm)

  place(left, dx: 1.2cm, dy: -1.4em, header-left)
  place(right, dx: -1.2cm, dy: -1.4em, header-right)

  line(start: (1cm, 0cm), length: 100% - 2cm)

  assert(
    client.gender-marker in ("f", "F", "m", "M", "o", "O"),
    message: "Gender Marker not recognized. Use only \"[fFmMoO]\"",
  )

  let salutation = if client.gender-marker == "f" or client.gender-marker == "F" {
    t.salutation-f
  } else if client.gender-marker == "m" or client.gender-marker == "M" {
    t.salutation-m
  } else if client.gender-marker == "o" or client.gender-marker == "O" {
    t.salutation-o
  }

  set text(number-type: "old-style")

  [#salutation #client.short-name,

    #content(t)

    #t.closing\
    #seller.name]
}

#let invoice(
  invoice-number: none,
  invoice-date: none,
  delivery-date: none,
  seller: (
    name: none,
    address: none,
    uid: none,
    is-kleinunternehmer: false,
    tel: none,
    email: none,
  ),
  footer-middle: none,
  footer-right: none,
  banner-image: none,
  client: (
    gender-marker: none,
    full-name: none,
    short-name: none,
    address: none,
  ),
  items: none,
  after-table-text: none,
  payment-due-date: none,
  iban: none,
  bic: none,
  lang: "en",
) = {
  let format-currency(number) = {
    let precision = 2

    let s = str(calc.round(number, digits: precision))
    let after-dot = s.find(regex("\..*"))

    if after-dot == none {
      s = s + "."
      after-dot = "."
    }

    for i in range(precision - after-dot.len() + 1) {
      s = s + "0"
    }

    s
  }

  assert(lang in ("en", "de"), message: "Currently, only en and de are supported.")

  let t = if lang == "en" {
    (
      invoice: [Invoice],
      invoice-date: [Invoice Date],
      pre-table: [We hereby submit to you our invoice with No. #invoice-number\. Please find the invoiced items below:],
      request-payment: total-with-vat => {
        [Please pay the amount of #format-currency(total-with-vat) until #payment-due-date at the latest to the following account with reference #invoice-number:]
      },
      payment: (
        recipient: [Recipient:],
        iban: [IBAN:],
        bic: [BIC:],
        amount: [Amount:],
        reference: [Reference:],
        pay-via-qr: [Payment by QR code],
      ),
      kleinunternehmer-regelung: [In accordance with § 6. Abs. 1 Z 27 (Kleinunternehmerregelung) relieved of VAT.],
      delivery-date: if delivery-date == none {
        [The delivery date is, unless otherwise specified, equivalent to the invoice date.]
      } else { [The delivery date is, unless otherwise specified, on or in #delivery-date.] },
      closing: [Thank you for your business and with kind regards,],
    )
  } else if lang == "de" {
    (
      invoice: [Rechnung],
      invoice-date: [Rechnungsdatum],
      pre-table: [Hiermit übermitteln wir Ihnen Ihre Rechnung Nr. #invoice-number\. Zudem nachfolgend die verrechneten Positionen:],
      request-payment: total-with-vat => {
        [Es wird um Leistung der Zahlung von #format-currency(total-with-vat) bis spätestens #payment-due-date auf unser Bankkonto unter Angabe der Rechnungsnummer '#invoice-number' gebeten.]
      },
      payment: (
        recipient: [Empfänger:],
        iban: [IBAN:],
        bic: [BIC:],
        amount: [Betrag:],
        reference: [Zahlungsreferenz:],
        pay-via-qr: [Zahlung via QR Code],
      ),
      kleinunternehmer-regelung: [Gemäß § 6. Abs. 1 Z 27 UStG (Kleinunternehmerregelung) von der USt. ausgenommen.],
      delivery-date: if delivery-date == none {
        [Der Lieferzeitpunkt ist, falls nicht anders angegeben, das Rechnungsdatum.]
      } else { [Der Lieferzeitpunkt/Lieferzeitraum ist, falls nicht anders angegeben, am/im #delivery-date.] },
      closing: [Mit vielem Dank für Ihr Vertrauen und freundlichen Grüßen,],
    )
  }

  letter-preset(
    t,
    lang: lang,
    seller: seller,
    footer-middle: footer-middle,
    footer-right: footer-right,
    banner-image: banner-image,
    client: client,
    header-left: [#t.invoice #invoice-number],
    header-right: [#t.invoice-date: #invoice-date],
    content: t => {
      [
        #t.pre-table

        #set table(stroke: none)

        #let is-kleinunternehmer = seller.at("is-kleinunternehmer", default: false)
        #let default-vat-rate = if is-kleinunternehmer { 0 } else { 20 }

        #table(
          columns: if is-kleinunternehmer {
            (auto, 1fr, auto, auto, auto)
          } else {
            (auto, 1fr, auto, auto, auto, auto, auto)
          },
          align: (col, row) => if row == 0 {
            (right, left, center, center, center, center, center).at(col)
          } else {
            (right, left, right, right, right, right, right).at(col)
          },
          inset: 6pt,
          if is-kleinunternehmer {
            table.header(
              table.hline(stroke: 0.5pt),
              t.table-label.item-number,
              t.table-label.description,
              t.table-label.quantity,
              t.table-label.single-price,
              t.table-label.total-price,
              table.hline(stroke: 0.5pt),
            )
          } else {
            table.header(
              table.hline(stroke: 0.5pt),
              t.table-label.item-number,
              t.table-label.description,
              t.table-label.quantity,
              t.table-label.single-price,
              t.table-label.vat-rate,
              t.table-label.vat-price,
              t.table-label.total-price,
              table.hline(stroke: 0.5pt),
            )
          },
          ..items
            .enumerate()
            .map(((index, row)) => {
              let item-vat-rate = row.at("vat-rate", default: default-vat-rate)

              if is-kleinunternehmer {
                (
                  index + 1,
                  row.description,
                  str(row.at("quantity", default: "1")),
                  format-currency(row.unit-price),
                  format-currency((row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity),
                )
              } else {
                (
                  index + 1,
                  row.description,
                  str(row.at("quantity", default: "1")),
                  format-currency(row.unit-price),
                  str(item-vat-rate) + "%",
                  format-currency(row.at("quantity", default: 1) * (item-vat-rate / 100) * row.unit-price),
                  format-currency((row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity),
                )
              }
            })
            .flatten()
            .map(str),
          table.hline(stroke: 0.5pt),
        )

        #let total-no-vat = items.map(row => row.unit-price * row.at("quantity", default: 1)).sum()
        #let total-vat = (
          items
            .map(row => (
              row.unit-price * row.at("quantity", default: 1) * row.at("vat-rate", default: default-vat-rate) / 100
            ))
            .sum()
        )
        #let total-with-vat = total-no-vat + total-vat

        #align(right, table(
          columns: 2,
          t.total-no-vat, format-currency(total-no-vat),
          ..if not is-kleinunternehmer {
            (
              t.total-vat,
              format-currency(total-vat),
              table.hline(stroke: 0.5pt),
              t.total-with-vat,
              format-currency(total-with-vat),
            )
          },
        ))

        #let epc-qr-content = (
          "BCD\n"
            + "002\n"
            + "1\n"
            + "SCT\n"
            + bic
            + "\n"
            + seller.name
            + "\n"
            + iban
            + "\n"
            + "EUR"
            + format-currency(total-with-vat)
            + "\n"
            + "\n"
            + invoice-number
            + "\n"
            + "\n"
            + "\n"
        )

        #after-table-text

        #t.delivery-date

        #if is-kleinunternehmer {
          t.kleinunternehmer-regelung
        }

        #set text(number-type: "lining")

        #t.at("request-payment")(total-with-vat)

        #box(inset: 10pt, radius: 2pt, stroke: 0.3pt, width: 100%, fill: cmyk(5%, 0%, 0%, 5%), [
          #place(right, dx: -0.25cm, dy: -0.1cm, box(
            inset: 4pt,
            height: 2.8cm,
            fill: luma(95%),
            radius: 10pt,
            stroke: 1pt,
            tiaoma.qrcode(epc-qr-content, options: (
              scale: 1.1,
              bg-color: luma(95%),
              fg-color: luma(0%),
            )),
          ))

          #place(right, dx: -0.25cm, dy: 2.3cm, box(
            inset: 4pt,
            fill: luma(95%),
            radius: 10pt,
            stroke: 0.5pt,
            [#set text(size: 8pt); #t.payment.pay-via-qr],
          ))

          #grid(
            align: left,
            columns: 2,
            gutter: 9pt,
            t.payment.recipient, seller.name,
            t.payment.iban, iban,
            t.payment.bic, bic,
            t.payment.amount, "€ " + format-currency(total-with-vat),
            t.payment.reference, invoice-number,
          )
        ])
      ]
    },
  )
}

#let offer(
  offer-number: none,
  offer-date: none,
  offer-valid-until: none,
  seller: (
    name: none,
    address: none,
    uid: none,
    is-kleinunternehmer: none,
    tel: none,
    email: none,
  ),
  footer-middle: none,
  footer-right: none,
  banner-image: none,
  client: (
    gender-marker: none,
    full-name: none,
    short-name: none,
    address: none,
  ),
  items: none,
  offer-text: none,
  pre-payment-amount: 20,
  proforma-invoice: true,
  lang: "en",
) = {
  let format-currency(number) = {
    let precision = 2

    let s = str(calc.round(number, digits: precision))
    let after-dot = s.find(regex("\..*"))

    if after-dot == none {
      s = s + "."
      after-dot = "."
    }

    for i in range(precision - after-dot.len() + 1) {
      s = s + "0"
    }

    s
  }

  assert(lang in ("en", "de"), message: "Currently, only en and de are supported.")

  let t = if lang == "en" {
    (
      offer: [Offer],
      offer-date: [Offer Date],
      pre-offer: [We hereby submit to you our offer with No. #offer-number\.],
      pre-table: [Please find the offered items below, individually orderable:],
      post-table: total => {
        [
          #if pre-payment-amount == none or pre-payment-amount == 0 {
            if proforma-invoice { [Upon acceptance of this offer, we will send you a proforma invoice.] } else { [] }
          } else {
            [Upon acceptance of this offer, we will send you #if proforma-invoice { [both] } an invoice for a prepayment of #pre-payment-amount % of the total amount (€ #format-currency(total * (pre-payment-amount / 100))) #if proforma-invoice { [and a proforma invoice] }. The prepayment is to be made before the start of the project. The remaining amount is to be paid 14 days after delivery.]
          }

          #if offer-valid-until == none {
            [The offer is valid for 30 days from the date of issue.]
          } else {
            [The offer is valid until #offer-valid-until.]
          }

        ]
      },
      kleinunternehmer-regelung: [In accordance with § 6. Abs. 1 Z 27 (Kleinunternehmerregelung) relieved of VAT.],
      closing: [I am looking forward to your response, and am always available for further questions.

        With kind regards,],
    )
  } else if lang == "de" {
    (
      offer: [Angebot],
      offer-date: [Angebotsdatum],
      pre-offer: [Hiermit übermitteln wir Ihnen unser Angebot Nr. #offer-number\.],
      pre-table: [Zudem nachfolgend die angebotenen Positionen, einzeln beauftragbar:],
      post-table: total => {
        [
          #if pre-payment-amount == none or pre-payment-amount == 0 {
            if proforma-invoice {
              [Mit Annahme dieses Angebots werden wir Ihnen eine Proformarechnung übermitteln.]
            } else { [] }
          } else {
            [Mit Annahme dieses Angebots werden wir Ihnen #if proforma-invoice { [sowohl] } eine Rechnung zur Vorauszahlung über #pre-payment-amount % des Gesamtbetrages (€ #format-currency(total * (pre-payment-amount / 100))) #if proforma-invoice { [als auch eine Proformarechnung ] }übermitteln. Die Vorauszahlung ist vor Beginn des Projektes zu leisten. Die Restzahlung ist binnen 14 Tagen nach Lieferung zu leisten.]
          }

          #if offer-valid-until == none {
            [Dieses Angebot ist für 30 Tage ab Erstellung gültig.]
          } else {
            [Dieses Angebot ist maximal Gültig bis #offer-valid-until.]
          }

        ]
      },
      kleinunternehmer-regelung: [Gemäß § 6. Abs. 1 Z 27 UStG (Kleinunternehmerregelung) von der USt. ausgenommen.],
      closing: [Ich freue mich auf Ihre Antwort, und stehe stets für Rückfragen zur Verfügung.

        Mit freundlichen Grüßen,],
    )
  }

  letter-preset(
    t,
    lang: lang,
    seller: seller,
    footer-middle: footer-middle,
    footer-right: footer-right,
    banner-image: banner-image,
    client: client,
    header-left: [#t.offer #offer-number],
    header-right: [#t.offer-date: #offer-date],
    content: t => {
      [
        #t.pre-offer

        #offer-text

        #t.pre-table

        #set table(stroke: none)

        #let is-kleinunternehmer = seller.at("is-kleinunternehmer", default: false)
        #let default-vat-rate = if is-kleinunternehmer { 0 } else { 20 }

        #table(
          columns: if is-kleinunternehmer {
            (auto, 1fr, auto, auto, auto)
          } else {
            (auto, 1fr, auto, auto, auto, auto, auto)
          },
          align: (col, row) => if row == 0 {
            (right, left, center, center, center, center, center).at(col)
          } else {
            (right, left, right, right, right, right, right).at(col)
          },
          inset: 6pt,
          if is-kleinunternehmer {
            table.header(
              table.hline(stroke: 0.5pt),
              t.table-label.item-number,
              t.table-label.description,
              t.table-label.quantity,
              t.table-label.single-price,
              t.table-label.total-price,
              table.hline(stroke: 0.5pt),
            )
          } else {
            table.header(
              table.hline(stroke: 0.5pt),
              t.table-label.item-number,
              t.table-label.description,
              t.table-label.quantity,
              t.table-label.single-price,
              t.table-label.vat-rate,
              t.table-label.vat-price,
              t.table-label.total-price,
              table.hline(stroke: 0.5pt),
            )
          },
          ..items
            .enumerate()
            .map(((index, row)) => {
              let item-vat-rate = row.at("vat-rate", default: default-vat-rate)

              if is-kleinunternehmer {
                (
                  index + 1,
                  row.description,
                  str(row.at("quantity", default: "1")),
                  format-currency(row.unit-price),
                  format-currency((row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity),
                )
              } else {
                (
                  index + 1,
                  row.description,
                  str(row.at("quantity", default: "1")),
                  format-currency(row.unit-price),
                  str(item-vat-rate) + "%",
                  format-currency(row.at("quantity", default: 1) * (item-vat-rate / 100) * row.unit-price),
                  format-currency((row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity),
                )
              }
            })
            .flatten()
            .map(str),
          table.hline(stroke: 0.5pt),
        )

        #let total-no-vat = items.map(row => row.unit-price * row.at("quantity", default: 1)).sum()
        #let total-vat = (
          items
            .map(row => (
              row.unit-price * row.at("quantity", default: 1) * row.at("vat-rate", default: default-vat-rate) / 100
            ))
            .sum()
        )
        #let total-with-vat = total-no-vat + total-vat

        #align(right, table(
          columns: 2,
          t.total-no-vat, format-currency(total-no-vat),
          ..if not is-kleinunternehmer {
            (
              t.total-vat,
              format-currency(total-vat),
              table.hline(stroke: 0.5pt),
              t.total-with-vat,
              format-currency(total-with-vat),
            )
          },
        ))

        #set text(number-type: "lining")

        #if is-kleinunternehmer {
          t.kleinunternehmer-regelung
        }



        #t.at("post-table")(total-with-vat)
      ]
    },
  )
}
