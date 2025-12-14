#import "@preview/tiaoma:0.3.0"
#import "letter_preset.typ": letter-preset
#import "../core/utils.typ": format-currency
#import "../core/i18n.typ": invoice-translations

/// Invoice template: letter layout with item table, totals, EPC QR payment block,
/// delivery date notice, and Kleinunternehmer handling per locale.
/// Parameters:
/// - invoice-number/invoice-date/delivery-date
/// - seller/client: contact dictionaries; seller.is-kleinunternehmer toggles VAT columns
/// - items: sequence of rows with description, quantity, unit-price, optional vat-rate
/// - after-table-text: optional text block after table
/// - payment-due-date, iban, bic
/// - footer-middle/footer-right/banner-image: optional visuals
/// - lang: locale code (en-at, en-de, en-us, de-at, de-de)
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
    signature: false,
  ),
  footer-middle: none,
  footer-right: none,
  banner-image: none,
  client: (
    gender-marker: none,
    full-name: none,
    short-name: none,
    address: none,
    signature: false,
  ),
  items: none,
  after-table-text: none,
  payment-due-date: none,
  iban: none,
  bic: none,
  lang: none,
) = {
  context {
    let t = invoice-translations(
      language: lang,
      invoice-number: invoice-number,
      delivery-date: delivery-date,
      payment-due-date: payment-due-date,
    )

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
}
