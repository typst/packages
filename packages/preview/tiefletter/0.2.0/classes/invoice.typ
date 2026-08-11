#import "@preview/tiaoma:0.3.0"
#import "letter_preset.typ": letter-preset
#import "../core/utils.typ": format-currency, resolve-currency, sign
#import "../core/i18n.typ": i18n

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
  currency: (
    currency-thousands-separator: none,
    currency-comma-separator: none,
    currency-symbol: none,
  ),
) = {
  context {
    let currency-resolved = resolve-currency(currency, i18n())

    show: letter-preset.with(
      sender: seller,
      footer-left: box(width: 1fr, align(center, seller.name + "\n" + seller.tel + "\n" + seller.email)),
      footer-middle: footer-middle,
      footer-right: footer-right,
      banner-image: banner-image,
      addressee: client,
      header-left: [#i18n().invoice.invoice #invoice-number],
      header-right: [#i18n().invoice.invoice-date: #invoice-date],
    )

    [
      #(i18n().invoice.pre-table)(invoice-number)

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
            i18n().table-base.table-label.item-number,
            i18n().table-base.table-label.description,
            i18n().table-base.table-label.quantity,
            i18n().table-base.table-label.single-price,
            i18n().table-base.table-label.total-price,
            table.hline(stroke: 0.5pt),
          )
        } else {
          table.header(
            table.hline(stroke: 0.5pt),
            i18n().table-base.table-label.item-number,
            i18n().table-base.table-label.description,
            i18n().table-base.table-label.quantity,
            i18n().table-base.table-label.single-price,
            i18n().table-base.table-label.vat-rate,
            i18n().table-base.table-label.vat-price,
            i18n().table-base.table-label.total-price,
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
                format-currency(
                  row.unit-price,
                  i18n().currency.currency-thousands-separator,
                  i18n().currency.currency-comma-separator,
                  i18n().currency.currency-symbol,
                ),
                format-currency(
                  (row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity,
                  i18n().currency.currency-thousands-separator,
                  i18n().currency.currency-comma-separator,
                  i18n().currency.currency-symbol,
                ),
              )
            } else {
              (
                index + 1,
                row.description,
                str(row.at("quantity", default: "1")),
                format-currency(
                  row.unit-price,
                  i18n().currency.currency-thousands-separator,
                  i18n().currency.currency-comma-separator,
                  i18n().currency.currency-symbol,
                ),
                str(item-vat-rate) + "%",
                format-currency(
                  row.at("quantity", default: 1) * (item-vat-rate / 100) * row.unit-price,
                  i18n().currency.currency-thousands-separator,
                  i18n().currency.currency-comma-separator,
                  i18n().currency.currency-symbol,
                ),
                format-currency(
                  (row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity,
                  i18n().currency.currency-thousands-separator,
                  i18n().currency.currency-comma-separator,
                  i18n().currency.currency-symbol,
                ),
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
        i18n().table-base.total-no-vat,
        format-currency(
          total-no-vat,
          i18n().currency.currency-thousands-separator,
          i18n().currency.currency-comma-separator,
          i18n().currency.currency-symbol,
        ),
        ..if not is-kleinunternehmer {
          (
            i18n().table-base.total-vat,
            format-currency(
              total-vat,
              i18n().currency.currency-thousands-separator,
              i18n().currency.currency-comma-separator,
              i18n().currency.currency-symbol,
            ),
            table.hline(stroke: 0.5pt),
            i18n().table-base.total-with-vat,
            format-currency(
              total-with-vat,
              i18n().currency.currency-thousands-separator,
              i18n().currency.currency-comma-separator,
              i18n().currency.currency-symbol,
            ),
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
          + format-currency(total-with-vat, "", ".", "")
          + "\n"
          + "\n"
          + invoice-number
          + "\n"
          + "\n"
          + "\n"
      )

      #after-table-text

      #(i18n().invoice.delivery-date)(delivery-date)

      #if is-kleinunternehmer {
        i18n().kleinunternehmer-regelung
      }

      #set text(number-type: "lining")

      #(i18n().invoice.request-payment)(total-with-vat, payment-due-date, invoice-number, n => format-currency(
        n,
        currency-resolved.currency-thousands-separator,
        currency-resolved.currency-comma-separator,
        currency-resolved.currency-symbol,
      ))

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
          [#set text(size: 8pt); #i18n().invoice.payment.pay-via-qr],
        ))

        #grid(
          align: left,
          columns: 2,
          gutter: 9pt,
          i18n().invoice.payment.recipient, seller.name,
          i18n().invoice.payment.iban, iban,
          i18n().invoice.payment.bic, bic,
          i18n().invoice.payment.amount,
          format-currency(
            total-with-vat,
            currency-resolved.currency-thousands-separator,
            currency-resolved.currency-comma-separator,
            currency-resolved.currency-symbol,
          ),

          i18n().invoice.payment.reference, invoice-number,
        )
      ])

      #i18n().invoice.closing

      #box(
        width: 100%,
        grid(
          columns: (1fr, 1fr),
          gutter: 5em,
          align: (col, row) => if col == 0 { left } else { right },
          if seller.at("signature", default: false) {
            v(1em)
            [#sign(seller.name)]
          } else {
            [#seller.name]
          },
          if client.at("signature", default: false) {
            v(1em)
            [#sign(client.full-name)]
          },
        ),
      )
    ]
  }
}
