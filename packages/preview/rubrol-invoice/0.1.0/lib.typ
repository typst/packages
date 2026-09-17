// Rubrol Invoice Package for Typst Universe
// Turnkey modern European B2B electronic invoice layout

#let invoice(
  title: "INVOICE",
  invoice_number: "INV-2026-0001",
  issued_date: "2026-09-17",
  due_date: "2026-10-17",
  status: "PAID",
  currency: "EUR",
  currency_symbol: "€",
  seller: (:),
  buyer: (:),
  items: (),
  tax_rate: 0.20,
  payment_details: (:),
  notes: none,
  body,
) = {
  let seller_name = seller.at("name", default: "Seller Company")
  let seller_tax = seller.at("vat_id", default: seller.at("tax_id", default: "N/A"))
  let seller_addr = seller.at("address", default: "")
  let seller_city = seller.at("city", default: "")
  let seller_email = seller.at("email", default: "")

  let buyer_name = buyer.at("name", default: "Client Company")
  let buyer_tax = buyer.at("vat_id", default: buyer.at("tax_id", default: "N/A"))
  let buyer_addr = buyer.at("address", default: "")
  let buyer_city = buyer.at("city", default: "")

  let subtotal = items.fold(0.0, (sum, item) => sum + (float(item.at("qty", default: 1)) * float(item.at("unit_price", default: 0.0))))
  let tax_amount = subtotal * float(tax_rate)
  let grand_total = subtotal + tax_amount

  set page(
    paper: "a4",
    margin: (x: 2cm, top: 2.2cm, bottom: 2.2cm),
    footer: [
      #set text(size: 8pt, fill: rgb("#94a3b8"))
      #line(length: 100%, stroke: 0.5pt + rgb("#e2e8f0"))
      #v(1.5mm)
      #grid(
        columns: (1fr, 1fr),
        align(left)[#seller_name | VAT ID: #seller_tax],
        context align(right)[Page #counter(page).display("1 of 1", both: true)]
      )
    ]
  )

  set text(font: ("Inter", "Helvetica", "Arial"), size: 9pt, fill: rgb("#1e293b"))

  // Top header
  grid(
    columns: (1fr, 1fr),
    align(left)[
      #text(size: 18pt, weight: "bold", fill: rgb("#0f172a"))[#seller_name]
      #v(1mm)
      #text(size: 8.5pt, fill: rgb("#64748b"))[
        #seller_addr \
        #seller_city \
        #seller_email
      ]
    ],
    align(right)[
      #rect(
        fill: if status == "PAID" { rgb("#f0fdf4") } else { rgb("#fffbeb") },
        stroke: 0.8pt + if status == "PAID" { rgb("#86efac") } else { rgb("#fde68a") },
        radius: 4pt,
        inset: (x: 8pt, y: 4pt)
      )[
        #text(weight: "bold", size: 8pt, fill: if status == "PAID" { rgb("#15803d") } else { rgb("#b45309") })[#status]
      ]
      #v(2mm)
      #text(size: 13pt, weight: "bold", fill: rgb("#334155"))[#title]
      #v(1mm)
      #text(size: 8.5pt, fill: rgb("#64748b"))[
        *Invoice No:* #invoice_number \
        *Issued:* #issued_date \
        *Due Date:* #due_date
      ]
    ]
  )

  v(6mm)

  // Parties info
  grid(
    columns: (1fr, 1fr),
    gutter: 1.5cm,
    rect(width: 100%, fill: rgb("#f8fafc"), stroke: 0.5pt + rgb("#e2e8f0"), radius: 5pt, inset: 10pt)[
      #text(size: 7pt, weight: "bold", fill: rgb("#94a3b8"))[BILLED FROM]
      #v(1mm)
      #text(weight: "bold", fill: rgb("#0f172a"))[#seller_name]\
      #text(size: 8pt, fill: rgb("#475569"))[
        #seller_addr \
        #seller_city \
        VAT ID: #seller_tax
      ]
    ],
    rect(width: 100%, fill: rgb("#f8fafc"), stroke: 0.5pt + rgb("#e2e8f0"), radius: 5pt, inset: 10pt)[
      #text(size: 7pt, weight: "bold", fill: rgb("#94a3b8"))[BILLED TO]
      #v(1mm)
      #text(weight: "bold", fill: rgb("#0f172a"))[#buyer_name]\
      #text(size: 8pt, fill: rgb("#475569"))[
        #buyer_addr \
        #buyer_city \
        VAT ID: #buyer_tax
      ]
    ]
  )

  v(6mm)

  // Line items table
  table(
    columns: (3fr, 1fr, 1.2fr, 1.2fr),
    stroke: none,
    fill: (x, y) => if y == 0 { rgb("#0f172a") } else if calc.odd(y) { rgb("#f8fafc") } else { none },
    inset: (x: 8pt, y: 7pt),
    align: (left, center, right, right),
    table.header(
      text(weight: "bold", size: 8pt, fill: white)[DESCRIPTION],
      text(weight: "bold", size: 8pt, fill: white)[QTY],
      text(weight: "bold", size: 8pt, fill: white)[UNIT PRICE],
      text(weight: "bold", size: 8pt, fill: white)[TOTAL]
    ),
    ..items.map(item => (
      text(weight: "medium")[#item.at("name", default: "Item")],
      str(item.at("qty", default: 1)),
      currency_symbol + str(item.at("unit_price", default: 0.0)),
      currency_symbol + str(float(item.at("qty", default: 1)) * float(item.at("unit_price", default: 0.0)))
    )).flatten()
  )

  v(4mm)

  // Settlement totals
  align(right)[
    #block(width: 45%)[
      #grid(
        columns: (1fr, 1fr),
        gutter: 6pt,
        align(left)[Subtotal:], align(right)[#currency_symbol #calc.round(subtotal, digits: 2)],
        align(left)[VAT (#int(tax_rate * 100)%):], align(right)[#currency_symbol #calc.round(tax_amount, digits: 2)],
        line(length: 100%, stroke: 0.8pt + rgb("#cbd5e1")), line(length: 100%, stroke: 0.8pt + rgb("#cbd5e1")),
        align(left)[#text(weight: "bold", size: 10pt)[Grand Total:]],
        align(right)[#text(weight: "bold", size: 10pt, fill: rgb("#0f172a"))[#currency_symbol #calc.round(grand_total, digits: 2)]]
      )
    ]
  ]

  if payment_details != (:) {
    v(6mm)
    rect(width: 100%, stroke: 0.5pt + rgb("#e2e8f0"), radius: 5pt, inset: 10pt)[
      #text(weight: "bold", size: 8.5pt, fill: rgb("#0f172a"))[Bank & Payment Details] \
      #v(1mm)
      #text(size: 8pt, fill: rgb("#475569"))[
        *Bank:* #payment_details.at("bank", default: "European Merchant Bank") \
        *IBAN:* #payment_details.at("iban", default: "N/A") \
        *BIC/SWIFT:* #payment_details.at("bic", default: "N/A") \
        *Reference:* #invoice_number
      ]
    ]
  }

  if notes != none {
    v(4mm)
    text(size: 8pt, fill: rgb("#64748b"))[#notes]
  }

  body
}
