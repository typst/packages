#import "@preview/cades:0.3.1": qr-code
#import "@preview/ibanator:0.1.0": iban

// Generates an invoice
#let invoice(
  // The invoice number
  invoice-nr,
  // The date on which the invoice was created
  invoice-date,
  // A list of items
  items,
  // Name and postal address of the author
  author,
  // Name and postal address of the recipient
  recipient,
  // Name and bank account details of the entity receiving the money
  bank-account,
  // The title of the invoice (e.g., "Rechnung", "Grant Invoice")
  invoice-title: "Rechnung",
  // The text to display below the items
  invoice-text: "Vielen Dank für die Zusammenarbeit. Die Rechnungssumme überweisen Sie bitte
    innerhalb von 14 Tagen ohne Abzug auf mein unten genanntes Konto unter Nennung
    der Rechnungsnummer.",
  // Optional VAT
  vat: 0.19,
  // Check if the german § 19 UStG applies
  kleinunternehmer: false,
  // Reverse charge for foreign customers (EU B2B)
  reverse-charge: false,
  // Is the price of items including Vat or excluding vat? Default is B2C, inclusive.
  includes-vat: true,
  // Invoice currency
  currency: "EUR",
  // FX rate to EUR per ECB rate (e.g., 0.93 means 1 USD = 0.93 EUR)
  fx-rate: none,
  // Show QR code (for non-EUR invoices, requires fx-rate to calculate EUR amount)
  show-qr: true,
) = {
  set text(lang: "de", region: "DE")

  set page(paper: "a4", margin: (x: 15%, y: 15%, top: 15%, bottom: 15%))

  // Typst can't format numbers yet, so we use this from here:
  // https://github.com/typst/typst/issues/180#issuecomment-1484069775
  let format_currency(number, locale: "de") = {
    let precision = 2
    assert(precision > 0)
    let s = str(calc.round(number, digits: precision))
    let after_dot = s.find(regex("\..*"))
    if after_dot == none {
      s = s + "."
      after_dot = "."
    }
    for i in range(precision - after_dot.len() + 1){
      s = s + "0"
    }
    // fake de locale
    if locale == "de" {
      s.replace(".", ",")
    } else {
      s
    }
  }

  set text(number-type: "old-style")

  smallcaps[
    *#author.name* •
    #author.street •
    #author.zip #author.city
  ]

  v(1em)

  [
    #set par(leading: 0.40em)
    #set text(size: 1.2em)
    #recipient.name \
    #if "co" in recipient [
      #recipient.co \
    ]
    #recipient.street \
    #recipient.zip
    #recipient.city
    #if "vat_id" in recipient [
      \ USt-IdNr: #recipient.vat_id
    ]
  ]

  v(4em)

  grid(columns: (1fr, 1fr), align: bottom, heading[
    #invoice-title \##invoice-nr
  ], [
    #set align(right)
    #author.city, *#invoice-date.display("[day].[month].[year]")*
  ])

  let no-vat = kleinunternehmer or reverse-charge

  let currency-symbol = if currency == "EUR" { "€" }
    else if currency == "USD" { "$" }
    else if currency == "GBP" { "£" }
    else { currency }

  // EUR uses comma as decimal separator, other currencies use dot
  let currency-locale = if currency == "EUR" { "de" } else { "en" }

  let base_price_f = if no-vat {
    1.0
  } else if includes-vat {
    1.0 / (1.0 + vat)
  } else {
    1.0
  }

  let total_f = if no-vat {
    1.0
  } else if includes-vat {
    1.0
  } else {
    1.0 + vat
  }

  let vat_f = if no-vat {
    0.0
  } else if includes-vat {
    vat / (1.0 + vat)
  } else {
    vat
  }

  let base_price = base_price_f * items.map((item) => item.price).sum()
  let total_vat = items.map((item) => item.price * vat_f).sum()
  let total = items.map((item) => item.price * total_f).sum()

  let items = items.enumerate().map(
    ((id, item)) => ([#str(id + 1).], [#item.description], [#format_currency(item.price * base_price_f, locale: currency-locale)#currency-symbol],),
  ).flatten()

  [
    #set text(number-type: "lining")
    #table(
      stroke: none,
      columns: (auto, 10fr, auto),
      align: ((column, row) => if column == 1 { left } else { right }),
      table.hline(stroke: (thickness: 0.5pt)),
      [*Pos.*], [*Beschreibung*], [*Preis*],
      table.hline(),
      ..items, table.hline(),
      [],
      [
        #set align(end)
        Summe:
      ],
      [#format_currency(base_price, locale: currency-locale)#currency-symbol],
      table.hline(start: 2),
      ..if not no-vat {(
        [],
        [
          #set text(number-type: "old-style")
          #set align(end)
          #str(vat * 100)% Mehrwertsteuer:
        ],
        [#format_currency(total_vat, locale: currency-locale)#currency-symbol],
        table.hline(start: 2),
        [],
      )} else {([], [], [], [])},
      [
        #set align(end)
        *Gesamt:*
      ],
      [*#format_currency(total, locale: currency-locale)#currency-symbol*],
      table.hline(start: 2),
    )
  ]

  v(1.5em)

  [
    #set text(size: 0.8em)
    #invoice-text
    #if kleinunternehmer [
      Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.
    ]
    #if reverse-charge [
      Steuerschuldnerschaft des Leistungsempfängers (§13b UStG).
    ]
  ]

  v(0.5em)

  // Bank details block (shared between EUR and non-EUR)
  let bank-details = [
    #set par(leading: 0.40em)
    #set text(number-type: "lining")
    #(bank-account
      .at("gender", default: (:))
      .at("account_holder", default: "Kontoinhaberin")): #bank-account.name \
    Kreditinstitut: #bank-account.bank \
    IBAN: *#iban(bank-account.iban)* \
    BIC: #bank-account.bic
    #if currency != "EUR" and fx-rate != none [
      \ Rechnungsbetrag in EUR: #format_currency(total * fx-rate)€ \
      ECB Exchange Rate *#invoice-date.display("[day].[month repr:short]")* USD / EUR: #fx-rate
    ]
  ]

  // Determine EUR amount for QR code (SEPA standard requires EUR)
  let qr-eur-amount = if currency == "EUR" { total }
    else if fx-rate != none { total * fx-rate }
    else { none }

  if show-qr and qr-eur-amount != none {
    // EPC QR code (SEPA standard, always in EUR)
    // https://en.wikipedia.org/wiki/EPC_QR_code version 002
    let epc-qr-content = (
      "BCD\n" + "002\n" + "1\n" + "SCT\n" + bank-account.bic + "\n" + bank-account.name + "\n" + bank-account.iban + "\n" + "EUR" + format_currency(qr-eur-amount, locale: "en") + "\n" + "\n" + invoice-nr + "\n" + "\n" + "\n"
    )
    grid(columns: (2fr, 2fr), gutter: 1em, align: top, bank-details, qr-code(epc-qr-content, height: 6em))
  } else {
    // No QR code
    bank-details
  }

  block(breakable: false)[
    Steuernummer: #author.tax_nr \
    #if "vat_id" in author [
      USt - IdNr: #author.vat_id
    ]

    #v(0.3em)

    Mit freundlichen Grüßen

    #author.name

    #if "signature" in author [
      #scale(origin: left, x: 400%, y: 400%, author.signature)
    ] else [
      #v(1em)
    ]
  ]
}
