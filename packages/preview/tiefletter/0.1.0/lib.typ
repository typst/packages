#import "@preview/cades:0.3.0": qr-code

#set page(margin: 2cm)

#let letter_preset(
  t,
  lang: "en",
  seller: (
    name: none,
    address: none,
    uid: none,
    tel: none,
    email: none,
  ),
  footer_middle: none,
  footer_right: none,
  banner-image: none,
  client: (
    gender_marker: none,
    full_name: none,
    short_name: none,
    address: none,
  ),
  header_left: none,
  header_right: none,
  content: (t) => {[]},
) = {
  assert(lang in ("en", "de"), message: "Currently, only en and de are supported.")

  let t = if lang == "en" {(
    ..t,
    salutation_f: [Dear Ms.],
    salutation_m: [Dear Mr.],
    salutation_o: [Dear],
    table_label: (
      item_number: [*No.*],
      description: [*Description*],
      quantity: [*Qty.*],
      single_price: [*€ / Pcs.*],
      vat_rate: [*VAT Rate*],
      vat_price: [*€ VAT*],
      total_price: [*€ Total*],
    ),
    total_no_vat: [Total excl. VAT],
    total_vat: [VAT],
    total_with_vat: [Total incl. VAT],
  )} else if lang == "de" {(
    ..t,
    salutation_f: [Sehr geehrte Frau],
    salutation_m: [Sehr geehrter Herr],
    salutation_o: [Guten Tag],
    table_label: (
      item_number: [*Pos.*],
      description: [*Bezeichnung*],
      quantity: [*Menge*],
      single_price: [*€ / Stk*],
      vat_rate: [*USt. Satz*],
      vat_price: [*€ USt.*],
      total_price: [*€ Ges.*],
    ),
    total_no_vat: [€ Netto:],
    total_vat: [USt. Gesamt:],
    total_with_vat: [€ Brutto:],
  )}

  set page(paper: "a4", margin: 2cm, footer-descent: -0.5cm, footer:
    context {
      set text(size: 9pt)
      box(width: 100%, inset: 10pt,
        grid(align: center, columns: 3,
          box(width: 1fr, align(center, seller.name + "\n" + seller.tel + "\n" + seller.email)),
          grid.vline(stroke: 0.3pt),
          if footer_middle != none {
            box(width: 1fr, align(center, footer_middle))
          },
          grid.vline(stroke: 0.3pt),
          if footer_right != none {
            box(width: 1fr, align(center, footer_right))
          } ))
    }
  )

  set text(font: "Cormorant Garamond", number-type: "lining", size: 12pt)

  place(top + right, dx: -0.5cm, dy: 1cm)[
    #set text(size: 14pt)
    #seller.name\
    #seller.address\
    #v(0.5em)
    UID: #seller.uid
  ]

  place(top + left, dx: 0.5cm, dy: 4cm, [
    #set text(size: 14pt)
    #client.full_name\
    #client.address
  ])

  context {
    box(width: page.width,
      place(top + left, dx: - here().position().x, dy: - here().position().y, [
        #banner-image
      ])
    )
  }
  v(7cm)

  place(left, dx: 1.2cm, dy: -1.4em, header_left)
  place(right, dx: -1.2cm, dy: -1.4em, header_right)

  line(start: (1cm, 0cm), length: 100% - 2cm)

  assert(client.gender_marker in ("f", "F", "m", "M", "o", "O"), message:  "Gender Marker not recognized. Use only \"[fFmMoO]\"")

  let salutation = if client.gender_marker == "f" or client.gender_marker == "F" {
    t.salutation_f
  } else if client.gender_marker == "m" or client.gender_marker == "M" {
    t.salutation_m
  } else if client.gender_marker == "o" or client.gender_marker == "O" {
    t.salutation_o
  }

  set text(number-type: "old-style")

  [#salutation #client.short_name,
  
  #content(t)]
}

#let invoice(
  invoice_number: none,
  invoice_date: none,
  seller: (
    name: none,
    address: none,
    uid: none,
    tel: none,
    email: none,
  ),
  footer_middle: none,
  footer_right: none,
  banner-image: none,
  client: (
    gender_marker: none,
    full_name: none,
    short_name: none,
    address: none,
  ),
  items: none,
  after_table_text: none,
  payment_due_date: none,
  iban: none,
  bic: none,
  lang: "en",
) = {
  let format_currency(number) = {
    let precision = 2

    let s = str(calc.round(number, digits: precision))
    let after_dot = s.find(regex("\..*"))

    if after_dot == none {
      s = s + "."
      after_dot = "."
    }

    for i in range(precision - after_dot.len() + 1){
      s = s + "0"
    }

    s
  }

  assert(lang in ("en", "de"), message: "Currently, only en and de are supported.")

  let t = if lang == "en" {(
    invoice: [Invoice],
    invoice_date: [Invoice Date],
    pre_table: [We hereby submit to you our invoice with No. #invoice_number\. Please find the invoiced items below:],
    request_payment: (total_with_vat) => {[Please pay the amount of #format_currency(total_with_vat) until #payment_due_date at the latest to the following account with reference #invoice_number:]},
    payment: (
      recipient: [Recipient:],
      iban: [IBAN:],
      bic: [BIC:],
      amount: [Amount:],
      reference: [Reference:],
    ),
    closing: [Thank you for your business and with kind regards,],
  )} else if lang == "de" {(
    invoice: [Rechnung],
    invoice_date: [Rechnungsdatum],
    pre_table: [Hiermit übermitteln wir Ihnen Ihre Rechnung Nr. #invoice_number\. Zudem nachfolgend die verrechneten Positionen:],
    request_payment: (total_with_vat) => {[Es wird um Leistung der Zahlung von #format_currency(total_with_vat) bis spätestens #payment_due_date auf unser Bankkonto unter Angabe der Rechnungsnummer '#invoice_number' gebeten.]},
    payment: (
      recipient: [Empfänger:],
      iban: [IBAN:],
      bic: [BIC:],
      amount: [Betrag:],
      reference: [Zahlungsreferenz:],
    ),
    closing: [Mit vielem Dank für Ihr Vertrauen und freundlichen Grüßen,],
  )}

  letter_preset(
    t,
    lang: lang,
    seller: seller,
    footer_middle: footer_middle,
    footer_right: footer_right,
    banner-image: banner-image,
    client: client,
    header_left: [#t.invoice #invoice_number],
    header_right: [#t.invoice_date: #invoice_date],
    content: (t) => {[
      #t.pre_table

      #set table(stroke: none)

      #table(
        columns: (auto, 1fr, auto, auto, auto, auto, auto),
        align: (col, row) =>
            if row == 0 {
              (right,left,center,center,center,center,center).at(col)
            }
            else {
              (right,left,right,right,right,right,right).at(col)
            },
        inset: 6pt,
        table.header(
          table.hline(stroke: 0.5pt),
          t.table_label.item_number,
          t.table_label.description,
          t.table_label.quantity,
          t.table_label.single_price,
          t.table_label.vat_rate,
          t.table_label.vat_price,
          t.table_label.total_price,
          table.hline(stroke: 0.5pt),
        ),
        ..items
          .enumerate()
          .map(((index, row)) => {
            let item_vat_rate = row.at("vat_rate", default: 20)

            (
              index + 1,
              row.description,
              str(row.at("quantity", default: "1")),
              format_currency(row.unit_price),
              str(item_vat_rate) + "%",
              format_currency(row.at("quantity", default: 1) * (item_vat_rate / 100) * row.unit_price),
              format_currency((row.unit_price + (item_vat_rate / 100) * row.unit_price) * row.quantity),
            )
          })
          .flatten()
          .map(str),
          table.hline(stroke: 0.5pt),
      )

      #let total_no_vat = items.map(row => row.unit_price * row.at("quantity", default: 1)).sum()
      #let total_vat = items.map(row => row.unit_price * row.at("quantity", default: 1) * row.at("vat_rate", default: 20) / 100).sum()
      #let total_with_vat = total_no_vat + total_vat

      #align(right,
        table(
          columns: 2,
          t.total_no_vat, format_currency(total_no_vat),
          t.total_vat, format_currency(total_vat), table.hline(stroke: 0.5pt),
          t.total_with_vat, format_currency(total_with_vat),
        )
      )

      #let epc-qr-content = (
        "BCD\n" + "002\n" + "1\n" + "SCT\n" + bic + "\n" + seller.name + "\n" + iban + "\n" + "EUR" + format_currency(total_with_vat) + "\n" + "\n" + invoice_number + "\n" + "\n" + "\n"
      )

      #after_table_text

      #set text(number-type: "lining")

      #t.at("request_payment")(total_with_vat)

      #box(inset: 10pt, radius: 2pt, stroke: 0.3pt, width: 100%, fill: cmyk(5%, 0%, 0%, 5%), [
        #place(right, dx: -0.25cm,
          box(inset: 4pt, fill: luma(95%), radius: 10pt, stroke: 1pt,
            qr-code(epc-qr-content, height: 4em, background: luma(95%))))

        #grid(align: left,
          columns: 2,
          gutter: 9pt,
          t.payment.recipient, seller.name,
          t.payment.iban, iban,
          t.payment.bic, bic,
          t.payment.amount, "€ " + format_currency(total_with_vat),
          t.payment.reference, invoice_number,
        )
      ])

      #t.closing\
      #seller.name
    ]}
  )
}

#let offer(
  offer_number: none,
  offer_date: none,
  offer_valid_until: none,
  seller: (
    name: none,
    address: none,
    uid: none,
    tel: none,
    email: none,
  ),
  footer_middle: none,
  footer_right: none,
  banner-image: none,
  client: (
    gender_marker: none,
    full_name: none,
    short_name: none,
    address: none,
  ),
  items: none,
  offer_text: none,
  pre_payment_amount: 20,
  lang: "en",
) = {
  let format_currency(number) = {
    let precision = 2

    let s = str(calc.round(number, digits: precision))
    let after_dot = s.find(regex("\..*"))

    if after_dot == none {
      s = s + "."
      after_dot = "."
    }

    for i in range(precision - after_dot.len() + 1){
      s = s + "0"
    }

    s
  }

  assert(lang in ("en", "de"), message: "Currently, only en and de are supported.")

  let t = if lang == "en" {(
    offer: [Offer],
    offer_date: [Offer Date],
    pre_offer: [We hereby submit to you our offer with No. #offer_number\.],
    pre_table: [Please find the offered items below, individually orderable:],
    post_table: (total) => {
      if pre_payment_amount == none or pre_payment_amount == 0 {
        [Upon acceptance of this offer, we will send you a proforma invoice.]} 
      else {
        [Upon acceptance of this offer, we will send you both an invoice for a prepayment of #pre_payment_amount % of the total amount (€ #format_currency(total * (pre_payment_amount / 100))) and a proforma invoice. The prepayment is to be made before the start of the project. The remaining amount is to be paid 14 days after delivery.]
      }

      if offer_valid_until == none {
        [The offer is valid for 30 days from the date of issue.]
      } else {
        [The offer is valid until #offer_valid_until.]
      }
    },
    closing: [I am looking forward to your response, and am always available for further questions.
    
    With kind regards,],
  )} else if lang == "de" {(
    offer: [Rechnung],
    offer_date: [Rechnungsdatum],
    pre_offer: [Hiermit übermitteln wir Ihnen unser Angebot Nr. #offer_number\.],
    pre_table: [Zudem nachfolgend die angebotenen Positionen, einzeln beauftragbar:],
    post_table: (total) => {
      if pre_payment_amount == none or pre_payment_amount == 0 {
        [Mit Annahme dieses Angebots werden wir Ihnen eine Proformarechnung übermitteln.
        
        ]} 
      else {
        [Mit Annahme dieses Angebots werden wir Ihnen sowohl eine Rechnung zur Vorauszahlung über #pre_payment_amount % des Gesamtbetrages (€ #format_currency(total * (pre_payment_amount / 100))) als auch eine Proformarechnung übermitteln. Die Vorauszahlung ist vor Beginn des Projektes zu leisten. Die Restzahlung ist binnen 14 Tagen nach Lieferung zu leisten.
        
        ]
      }

      if offer_valid_until == none {
        [Dieses Angebot ist für 30 Tage ab Erstellung gültig.]
      } else {
        [Dieses Angebot ist maximal Gültig bis #offer_valid_until.]
      }
      []
    },
    closing: [Ich freue mich auf Ihre Antwort, und stehe stets für Rückfragen zur Verfügung.
    
    Mit freundlichen Grüßen,],
  )}

  letter_preset(
    t,
    lang: lang,
    seller: seller,
    footer_middle: footer_middle,
    footer_right: footer_right,
    banner-image: banner-image,
    client: client,
    header_left: [#t.offer #offer_number],
    header_right: [#t.offer_date: #offer_date],
    content: (t) => {[
      #t.pre_offer

      #offer_text

      #t.pre_table

      #set table(stroke: none)

      #table(
        columns: (auto, 1fr, auto, auto, auto, auto, auto),
        align: (col, row) =>
            if row == 0 {
              (right,left,center,center,center,center,center).at(col)
            }
            else {
              (right,left,right,right,right,right,right).at(col)
            },
        inset: 6pt,
        table.header(
          table.hline(stroke: 0.5pt),
          t.table_label.item_number,
          t.table_label.description,
          t.table_label.quantity,
          t.table_label.single_price,
          t.table_label.vat_rate,
          t.table_label.vat_price,
          t.table_label.total_price,
          table.hline(stroke: 0.5pt),
        ),
        ..items
          .enumerate()
          .map(((index, row)) => {
            let item_vat_rate = row.at("vat_rate", default: 20)

            (
              index + 1,
              row.description,
              str(row.at("quantity", default: "1")),
              format_currency(row.unit_price),
              str(item_vat_rate) + "%",
              format_currency(row.at("quantity", default: 1) * (item_vat_rate / 100) * row.unit_price),
              format_currency((row.unit_price + (item_vat_rate / 100) * row.unit_price) * row.quantity),
            )
          })
          .flatten()
          .map(str),
          table.hline(stroke: 0.5pt),
      )

      #let total_no_vat = items.map(row => row.unit_price * row.at("quantity", default: 1)).sum()
      #let total_vat = items.map(row => row.unit_price * row.at("quantity", default: 1) * row.at("vat_rate", default: 20) / 100).sum()
      #let total_with_vat = total_no_vat + total_vat

      #align(right,
        table(
          columns: 2,
          t.total_no_vat, format_currency(total_no_vat),
          t.total_vat, format_currency(total_vat), table.hline(stroke: 0.5pt),
          t.total_with_vat, format_currency(total_with_vat),
        )
      )

      #set text(number-type: "lining")

      #t.at("post_table")(total_with_vat)

      #t.closing\
      #seller.name
    ]}
  )
}
