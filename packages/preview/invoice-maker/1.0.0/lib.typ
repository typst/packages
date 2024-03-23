#let nbh = "‑"

// Truncate a number to 2 decimal places
// and add trailing zeros if necessary
// E.g. 1.234 -> 1.23, 1.2 -> 1.20
#let add_zeros = (num) => {
    // Can't use trunc and fract due to rounding errors
    let frags = str(num).split(".")
    let (intp, decp) = if frags.len() == 2 { frags } else { (num, "00") }
    str(intp) + "." + (str(decp) + "00").slice(0, 2)
  }

// From https://stackoverflow.com/a/57080936/1850340
#let verify_iban = (country, iban) => {
    let iban_regexes = (
        DE: regex(
          "^DE[a-zA-Z0-9]{2}\s?([0-9]{4}\s?){4}([0-9]{2})$"
        ),
        GB: regex(
          "^GB[a-zA-Z0-9]{2}\s?([a-zA-Z]{4}\s?){1}([0-9]{4}\s?){3}([0-9]{2})$"
        ),
      )

    if country == none or not country in iban_regexes {
      true
    }
    else {
      iban.find(iban_regexes.at(country)) != none
    }
}

#let TODO = box(
  inset: (x: 0.5em),
  outset: (y: 0.2em),
  radius: 0.2em,
  fill: rgb(255,180,170),
)[
  #text(
    font: "Arial",
    size: 8pt,
    weight: 600,
    fill: rgb(100,68,64)
  )[TODO]
]

#let horizontalrule = [
  #v(8mm)
  #line(
    start: (20%,0%),
    end: (80%,0%),
    stroke: 0.8pt + gray,
  )
  #v(8mm)
]

#let signature_line = line(length: 5cm, stroke: 0.4pt)

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#let languages = (
    en: (
      country: "GB",
      recipient: "Recipient",
      biller: "Biller",
      invoice: "Invoice",
      cancellation_invoice: "Cancellation Invoice",
      cancellation_notice: (id, issuing_date) => [
        As agreed, you will receive a credit note
        for the invoice *#id* dated *#issuing_date*.
      ],
      invoice_id: "Invoice ID",
      issuing_date: "Issuing Date",
      delivery_date: "Delivery Date",
      items: "Items",
      closing: "Thank you for the good cooperation!",
      number: "№",
      date: "Date",
      description: "Description",
      duration: "Duration",
      quantity: "Quantity",
      price: "Price",
      total_time: "Total working time",
      subtotal: "Subtotal",
      vat: "VAT of",
      reverse_charge: "Reverse Charge",
      total: "Total",
      due_text: val =>
        [Please transfer the money onto following bank account due to *#val*:],
      owner: "Owner",
      iban: "IBAN",
    ),
    de: (
      country: "DE",
      recipient: "Empfänger",
      biller: "Aussteller",
      invoice: "Rechnung",
      cancellation_invoice: "Stornorechnung",
      cancellation_notice: (id, issuing_date) => [
        Vereinbarungsgemäß erhalten Sie hiermit eine Gutschrift
        zur Rechnung *#id* vom *#issuing_date*.
      ],
      invoice_id: "Rechnungsnummer",
      issuing_date: "Ausstellungsdatum",
      delivery_date: "Lieferdatum",
      items: "Leistungen",
      closing: "Vielen Dank für die gute Zusammenarbeit!",
      number: "Nr",
      date: "Datum",
      description: "Beschreibung",
      duration: "Dauer",
      quantity: "Menge",
      price: "Preis",
      total_time: "Gesamtarbeitszeit",
      subtotal: "Zwischensumme",
      vat: "Umsatzsteuer von",
      reverse_charge: "Steuerschuldnerschaft des\nLeistungsempfängers",
      total: "Gesamt",
      due_text: val =>
        [Bitte überweise den Betrag bis *#val* auf folgendes Konto:],
      owner: "Inhaber",
      iban: "IBAN",
    ),
  )

#let invoice(
  language: "en",
  country: none,
  title: none,
  banner_image: none,
  invoice_id: none,
  cancellation_id: none,
  issuing_date: none,
  delivery_date: none,
  due_date: none,
  biller: (),
  recipient: (),
  keywords: (),
  hourly_rate: none,
  styling: (
    font: "Arial",
    fontsize: 11pt,
    margin: (
      top: 20mm,
      right: 25mm,
      bottom: 20mm,
      left: 25mm
    ),
  ),
  items: [],
  discount: none,
  vat: 0.19,
  data: none,
  doc,
) = {
  if data != none {
    language = data.at("language", default: language)
    country = data.at("country", default: languages.at(language).country)
    title = data.at("title", default: title)
    banner_image = data.at("banner_image", default: banner_image)
    invoice_id = data.at("invoice_id", default: invoice_id)
    cancellation_id = data.at("cancellation_id", default: cancellation_id)
    issuing_date = data.at("issuing_date", default: issuing_date)
    delivery_date = data.at("delivery_date", default: delivery_date)
    due_date = data.at("due_date", default: due_date)
    biller = data.at("biller", default: biller)
    recipient = data.at("recipient", default: recipient)
    keywords = data.at("keywords", default: keywords)
    hourly_rate = data.at("hourly_rate", default: hourly_rate)
    styling = data.at("styling", default: styling)
    items = data.at("items", default: items)
    discount = data.at("discount", default: discount)
    vat = data.at("vat", default: vat)
  }

  // Verify inputs
  assert(
    verify_iban(country, biller.iban),
    message: "Invalid IBAN " + biller.iban + " for country " + country
  )

  let t = languages.at(language)
  let signature = ""

  set document(
    title: title,
    keywords: keywords,
  )
  set page(
    margin: styling.margin,
    numbering: none,
  )
  set par(justify: true)
  set text(
    lang: language,
    font: styling.font,
    size: styling.fontsize,
  )
  set table(stroke: none)

  // Offset page top margin for banner image
  [#pad(top: -20mm, banner_image)]

  align(center)[#block(inset: 2em)[
    #text(font: "Arial", weight: "bold", size: 2em)[
      #(if title != none { title } else {
        if cancellation_id != none { t.cancellation_invoice }
        else { t.invoice }
      })
    ]
  ]]

  let invoice_id_norm_ = if invoice_id != none {
          if cancellation_id != none { cancellation_id }
          else { invoice_id }
        }
        else {
          TODO
          // TODO: Reactivate after Typst supports hour, minute, and second
          // datetime
          //   .today()
          //   .display("[year]-[month]-[day]t[hour][minute][second]")
        }

  let issuing_date = if issuing_date != none { issuing_date }
        else { datetime.today().display("[year]-[month]-[day]") }

  let delivery_date = if delivery_date != none { delivery_date }
        else { TODO }

  align(center,
    table(
      columns: 2,
      align: (right, left),
      inset: 4pt,
      [#t.invoice_id:], [*#invoice_id_norm_*],
      [#t.issuing_date:], [*#issuing_date*],
      [#t.delivery_date:], [*#delivery_date*],
    )
  )

  v(2em)

  box(height: 10em)[
    #columns(2, gutter: 4em)[
      === #t.recipient
      #v(0.5em)
      #recipient.name \
      #{if "title" in recipient { [#recipient.title \ ] }}
      #recipient.address.city #recipient.address.postal_code \
      #recipient.address.street \
      #{if recipient.vat_id.starts-with("DE"){"USt-IdNr.:"}}
        #recipient.vat_id


      === #t.biller
      #v(0.5em)
      #biller.name \
      #{if "title" in biller { [#biller.title \ ] }}
      #biller.address.city #biller.address.postal_code \
      #biller.address.street \
      #{if biller.vat_id.starts-with("DE"){"USt-IdNr.:"}}
        #biller.vat_id
    ]
  ]

  if cancellation_id != none {
    (t.cancellation_notice)(invoice_id, issuing_date)
  }

  [== #t.items]

  v(1em)

  let getRowTotal = row => {
    if row.at("dur_min", default: 0) == 0 {
      row.price * row.at("quantity", default: 1)
    }
    else {
      calc.round(hourly_rate * (row.dur_min / 60), digits: 2)
    }
  }

  let cancel_neg = if cancellation_id != none { -1 } else { 1 }

  table(
    columns: (auto, auto, 1fr, auto, auto, auto, auto),
    align: (col, row) =>
        if row == 0 {
          (right,left,left,center,center,center,center,).at(col)
        }
        else {
          (right,left,left,right,right,right,right,).at(col)
        },
    inset: 6pt,
    table.header(
      // TODO: Add after https://github.com/typst/typst/issues/3734
      // align: (right,left,left,center,center,center,center,),
      table.hline(stroke: 0.5pt),
      [*#t.number*],
      [*#t.date*],
      [*#t.description*],
      [*#t.duration*\ #text(size: 0.8em)[( min )]],
      [*#t.quantity*],
      [*#t.price*\ #text(size: 0.8em)[( € )]],
      [*#t.total*\ #text(size: 0.8em)[( € )]],
      table.hline(stroke: 0.5pt),
    ),
    ..items
      .enumerate()
      .map(((index, row)) => {
        let dur_min = row.at("dur_min", default: 0)
        let dur_hour = dur_min / 60

        (
          row.at("number", default: index + 1),
          row.date,
          row.description,
          str(if dur_min == 0 { "" } else { dur_min }),
          str(row.at("quantity", default: if dur_min == 0 { "1" } else { "" })),
          str(add_zeros(cancel_neg *
           row.at("price", default: calc.round(hourly_rate * dur_hour, digits: 2))
          )),
          str(add_zeros(cancel_neg * getRowTotal(row))),
        )
      })
      .flatten()
      .map(str),
    table.hline(stroke: 0.5pt),
  )

  let subTotal = items
        .map(getRowTotal)
        .sum()

  let totalDuration = items
        .map(row => int(row.at("dur_min", default: 0)))
        .sum()

  let discountValue = if discount == none { 0 }
    else {
      if (discount.type == "fixed") {
        discount.value
      }
      else if discount.type == "proportionate" {
        subTotal * discount.value
      }
      else {
        panic(["#discount.type" is no valid discount type])
      }
    }
  let tax = subTotal * vat
  let total = subTotal - discountValue + tax

  let table_entries = (
    if totalDuration != 0 {
      ([#t.total_time:], [*#totalDuration min*])
    },
    if (discountValue != 0) or (vat != 0) {
      ([#t.subtotal:],
      [#{add_zeros(cancel_neg * subTotal)} €])
    },
    if discountValue != 0 {
      (
        [Discount of #discountValue
          #{if discount.reason != "" { discount.reason }}],
        [#{nbh}#add_zeros(cancel_neg * discount.value)  €]
      )
    },
    if recipient.vat_id.starts-with("DE") and (vat != 0) {
      ([#t.vat #{vat * 100} %:],
        [#{add_zeros(cancel_neg * tax)} €]
      )
    },
    if (not recipient.vat_id.starts-with("DE")) {
      ([#t.vat:], text(0.9em)[#t.reverse_charge])
    },
    (
      [*#t.total*:],
      [*#add_zeros(cancel_neg * total) €*]
    ),
  )
  .filter(entry => entry != none)

  let grayish = luma(245)

  align(right,
    table(
      columns: 2,
      fill: (col, row) => // if last row
        if row == table_entries.len() - 1 { grayish }
        else { none },
      stroke: (col, row) => // if last row
        if row == table_entries.len() - 1 { (y: 0.5pt, x: 0pt) }
        else { none },
      ..table_entries
        .flatten(),
    )
  )

  v(1em)

  if cancellation_id == none {
    let due_date = if due_date != none { due_date }
          else {
            TODO
            // TODO: Reactivate after Typst supports adding dates
            // datetime.today().add(days: 14).
            //   display("[year]-[month]-[day]")
          }

    (t.due_text)(due_date)

    v(1em)
    align(center)[
      #table(
        fill: grayish,
        // stroke: 1pt + blue,
        // columns: 2, // TODO: Doesn't work for unknown reason
        columns: (8em, auto),
        inset: (col, row) =>
          if col == 0 {
            if row == 0 { (top: 1.2em, right: 0.6em, bottom: 0.6em) }
            else { (top: 0.6em, right: 0.6em, bottom: 1.2em) }
          }
          else {
            if row == 0 { (top: 1.2em, right: 2em, bottom: 0.6em, left: 0.6em) }
            else { (top: 0.6em, right: 2em, bottom: 1.2em, left: 0.6em) }
          },
        align: (col, row) => (right,left,).at(col),
        table.hline(stroke: 0.5pt),
        [#t.owner:], [*#biller.name*],
        [#t.iban:], [*#biller.iban*],
        table.hline(stroke: 0.5pt),
      )
    ]
    v(1em)

    t.closing
  }
  else {
    v(1em)
    align(center, strong(t.closing))
  }

  doc
}
