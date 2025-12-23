#import "letter_preset.typ": letter-preset
#import "../core/utils.typ": format-currency
#import "../core/i18n.typ": offer-translations

/// Offer template: letter layout with free-text offer body, item table,
/// optional pre-payment and proforma-invoice wording, and locale-aware clauses.
/// Parameters:
/// - offer-number/offer-date/offer-valid-until
/// - seller/client: contact dictionaries; seller.is-kleinunternehmer toggles VAT columns
/// - items: sequence of rows with description, quantity, unit-price, optional vat-rate
/// - offer-text/after-table-text: optional text blocks around the table
/// - pre-payment-amount (percent) and proforma-invoice (bool)
/// - footer-middle/footer-right/banner-image: optional visuals
/// - lang: locale code (en-at, en-de, en-us, de-at, de-de)
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
  offer-text: none,
  after-table-text: none,
  pre-payment-amount: 20,
  proforma-invoice: true,
  lang: none,
) = {
  context {
    let t = offer-translations(
      language: lang,
      offer-number: offer-number,
      offer-valid-until: offer-valid-until,
      pre-payment-amount: pre-payment-amount,
      proforma-invoice: proforma-invoice,
    )

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

          #after-table-text

          #set text(number-type: "lining")

          #if is-kleinunternehmer {
            t.kleinunternehmer-regelung
          }

          #t.at("post-table")(total-with-vat)
        ]
      },
    )
  }
}
