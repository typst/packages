#import "@preview/tieflang:0.1.0": tr
#import "letter_preset.typ": letter-preset
#import "../core/utils.typ": format-currency, resolve-currency
#import "../core/i18n.typ": setup-i18n

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
  currency: (
    currency-comma-separator: none,
    currency-symbol: none,
    currency-thousands-separator: none,
  ),
  custom-salutation: none,
) = {
  setup-i18n()

  context {
    let currency-resolved = resolve-currency(currency, tr().currency)

    show: letter-preset.with(
      sender: seller,
      footer-left: box(width: 1fr, align(center, seller.name + "\n" + seller.tel + "\n" + seller.email)),
      footer-middle: footer-middle,
      footer-right: footer-right,
      banner-image: banner-image,
      addressee: client,
      header-left: [#tr().offer.offer #offer-number],
      header-right: [#tr().offer.offer-date: #offer-date],
    )

    let salutation = if custom-salutation != none {
      custom-salutation
    } else if client.gender-marker == "f" or client.gender-marker == "F" {
      tr().letter.salutation-f
    } else if client.gender-marker == "m" or client.gender-marker == "M" {
      tr().letter.salutation-m
    } else if client.gender-marker == "o" or client.gender-marker == "O" {
      tr().letter.salutation-o
    }

    [
      #salutation #client.short-name,

      #(tr().offer.pre-offer)(offer-number)

      #offer-text

      #tr().offer.pre-table

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
            tr().table-base.table-label.item-number,
            tr().table-base.table-label.description,
            tr().table-base.table-label.quantity,
            tr().table-base.table-label.single-price,
            tr().table-base.table-label.total-price,
            table.hline(stroke: 0.5pt),
          )
        } else {
          table.header(
            table.hline(stroke: 0.5pt),
            tr().table-base.table-label.item-number,
            tr().table-base.table-label.description,
            tr().table-base.table-label.quantity,
            tr().table-base.table-label.single-price,
            tr().table-base.table-label.vat-rate,
            tr().table-base.table-label.vat-price,
            tr().table-base.table-label.total-price,
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
                  currency-resolved.currency-thousands-separator,
                  currency-resolved.currency-comma-separator,
                  currency-resolved.currency-symbol,
                ),
                format-currency(
                  (row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity,
                  currency-resolved.currency-thousands-separator,
                  currency-resolved.currency-comma-separator,
                  currency-resolved.currency-symbol,
                ),
              )
            } else {
              (
                index + 1,
                row.description,
                str(row.at("quantity", default: "1")),
                format-currency(row.unit-price),
                str(item-vat-rate) + "%",
                format-currency(
                  row.at("quantity", default: 1) * (item-vat-rate / 100) * row.unit-price,
                  currency-resolved.currency-thousands-separator,
                  currency-resolved.currency-comma-separator,
                  currency-resolved.currency-symbol,
                ),
                format-currency(
                  (row.unit-price + (item-vat-rate / 100) * row.unit-price) * row.quantity,
                  currency-resolved.currency-thousands-separator,
                  currency-resolved.currency-comma-separator,
                  currency-resolved.currency-symbol,
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
        tr().table-base.total-no-vat,
        format-currency(
          total-no-vat,
          currency-resolved.currency-thousands-separator,
          currency-resolved.currency-comma-separator,
          currency-resolved.currency-symbol,
        ),
        ..if not is-kleinunternehmer {
          (
            tr().table-base.total-vat,
            format-currency(
              total-vat,
              currency-resolved.currency-thousands-separator,
              currency-resolved.currency-comma-separator,
              currency-resolved.currency-symbol,
            ),
            table.hline(stroke: 0.5pt),
            tr().table-base.total-with-vat,
            format-currency(
              total-with-vat,
              currency-resolved.currency-thousands-separator,
              currency-resolved.currency-comma-separator,
              currency-resolved.currency-symbol,
            ),
          )
        },
      ))

      #after-table-text

      #set text(number-type: "lining")

      #if is-kleinunternehmer {
        tr().kleinunternehmer-regelung
      }

      #(tr().offer.post-table)(
        total-with-vat,
        pre-payment-amount,
        proforma-invoice,
        offer-valid-until,
        n => format-currency(
          n,
          currency-resolved.currency-thousands-separator,
          currency-resolved.currency-comma-separator,
          currency-resolved.currency-symbol,
        ),
      )
    ]
  }
}

