#import "@preview/letter-pro:3.0.0": letter-generic, address-duobox, address-tribox, sender-box, recipient-box, annotations-box, header-simple
#import "@preview/rustycure:0.2.0"
#import "@preview/ibanator:0.1.0"

#import "helper.typ": *

#let state-autor-name = state("autor", none)
#let state-tax-nr = state("tax-nr", none)
#let state-invoice-nr = state("tax-nr", none)
#let state-total-invoice-amount = state("total-invoice-amount", 0)
#let state-vat = state("vat", 0)
#let state-vat-exemption = state("vat-exemption", false)

/// Initializes the invoice document wrapper.
///
/// This function is designed to be used as a `show` rule:
/// ```typ
/// #show: invoice.with( ... )
/// ```
/// It sets up the page layout (DIN 5008), metadata, and the letter header.
///
/// -> content
#let invoice(
  /// The letter format standard to use.
  /// -> "DIN-5008-A" | "DIN-5008-B"
  format: "DIN-5008-B",

  /// Custom content for the header. If `auto`, the subject is used.
  /// -> auto | content
  header: auto,
  /// Custom content for the footer.
  /// -> none | content
  footer: none,

  /// Whether to display folding marks on the left margin.
  /// -> bool
  folding-marks: true,
  /// Whether to display the hole punch mark.
  /// -> bool
  hole-mark: true,

  /// Dictionary containing sender details. 
  /// 
  /// Structure: `(name: str, title: str | content, address: str | content, city: str | content, extra: (:))`
  ///
  /// -> dictionary
  sender: (
    name: "",
    title: none,
    address: none,
    city: none,
    extra: (:),
  ),

  /// Dictionary containing recipient details.
  /// 
  /// Structure: `(name: str | content, address: str | content, city: str | content)`
  ///
  /// -> dictionary | content
  recipient: (
    name: none,
    address: none,
    city: none
  ),
  /// Additional annotations above the address field (e.g., "Registered Mail").
  /// -> none | content
  annotations: none,

  /// Content for the information box on the right.
  /// If `auto`, it is generated from sender and metadata.
  /// -> auto | content
  information-box: auto,
  /// Additional custom fields for the information box.
  /// -> none | array
  reference-signs: none,

  /// The date of the invoice.
  /// -> none | datetime | content
  date: none,
  /// The unique invoice number.
  /// -> none | str | content
  invoice-nr: none,
  /// The subject line of the letter.
  /// -> str | content
  subject: "Rechnung",

  /// The tax number of the sender (displayed in the info box).
  /// -> none | str | content
  tax-nr: none,
  /// The default VAT rate (e.g., `0.19` for 19%).
  /// -> float
  vat: 0.19,
  /// If `true`, enables small business regulation (Kleinunternehmerregelung).
  /// No VAT will be calculated, and a legal notice will be added.
  /// -> bool
  vat-exempt-small-biz: false,

  /// The page numbering format.
  /// -> auto | str
  page-numbering: auto,

  /// Custom page margins.
  /// -> dictionary
  margin: (
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),

  /// The font family used for the document.
  /// -> str
  font: "Source Sans Pro",
  
  /// -> content
  body
) = {
  margin = (
    left:   margin.at("left",   default: 25mm),
    right:  margin.at("right",  default: 20mm),
    top:    margin.at("top",    default: 20mm),
    bottom: margin.at("bottom", default: 20mm),
  )

  sender = (
    name:    sender.at("name", default: none),
    title:   sender.at("title", default: none),
    address: sender.at("address", default: none),
    city:    sender.at("city", default: none),
    extra:   sender.at("extra", default: none),
  )
  
  state-autor-name.update(sender.name)
  state-invoice-nr.update(invoice-nr)
  state-tax-nr.update(tax-nr)
  state-vat-exemption.update(vat-exempt-small-biz)
  state-vat.update(vat)
  
  subject = [#subject #invoice-nr]

  set document(
    title: subject,
    author: sender.at("name", default: ""),
  )

  set text(font: font, hyphenate: false)

  if (header == auto) {
    header = pad(
      left: margin.left,
      right: margin.right,
      top: margin.top,
      bottom: 5mm,
      {
        set text(10pt)
        subject
        linebreak()
      }
    )
  }
  
  if type(recipient) == dictionary {
    recipient = {  
      if recipient.at("name", default: none) != none {
        [#recipient.name]
        linebreak()
      } else {
        box(fill: red)[Name Missing!]
        linebreak()
      }
  
      if recipient.at("address", default: none)!= none {
        [#recipient.address]
        linebreak()
      } else {
        box(fill: red)[Address Missing!]
        linebreak()
      }
  
      if recipient.at("city", default: none) != none {
        [#recipient.city]
      } else {
        box(fill: red)[City Missing!]
      }
    }
  }

  let sender-box = sender-box(name: sender.name, [#sender.address, #sender.city])
  let annotations-box = annotations-box(annotations)
  let recipient-box = recipient-box([#recipient])

  let address-box = address-tribox(sender-box, annotations-box, recipient-box)
  if annotations == none {
    address-box = address-duobox(align(bottom, pad(bottom: .65em, sender-box)), recipient-box)
  }

  if information-box == auto {
    information-box = align(right, text(.9em, {
      if sender.name != none {
        strong(sender.name)
        linebreak()
      }
      
      if sender.title != none {
        [#sender.title]
        linebreak()
      }
      
      if sender.address != none {
        [#sender.address]
        linebreak()
      }

      if sender.city != none {
        [#sender.city]
        linebreak()
      }

      if type(sender.extra) == content {
        sender.extra
      }
      if type(sender.extra) == dictionary {
        grid(
          columns: 2, 
          align: right, 
          gutter: .8em,
          ..sender.extra.pairs()
            .map(e => ([#e.at(0):], [#e.at(1)]))
            .flatten()
        )
      }
      if type(sender.extra) == array {
        sender.extra.map(e => [#e]).join(linebreak())
      }
    }))
  }

 if type(reference-signs) != array {
   reference-signs = ()
 }
 if tax-nr != none {
   reference-signs.insert(0, ("Steuernummer", tax-nr))
 }
  
  letter-generic(
    format: format,
  
    header: header,
    footer: footer,
  
    folding-marks: folding-marks,
    hole-mark: hole-mark,
  
    address-box: address-box,
    information-box: information-box,

    reference-signs: reference-signs,

    margin: margin,
  )[
    #grid(
      columns: (1fr, auto),
      heading(subject),
      {
        let cityname = extract-city-name(sender.at("city", default: none))
        if cityname != none {
          [#cityname, ]
        }
        
        if type(date) == datetime {
          strong(date.display("[day].[month].[year]"))
        } else {
          strong[#date]
        }
      }
    )
    
    #set text(hyphenate: true)
    #set par(justify: true)
    #body
  ]
}


/// Renders a block with bank details and an optional EPC-QR-Code (GiroCode).
///
/// Automatically retrieves the invoice total from the state for the QR code.
///
/// -> content
#let bank-details(
  /// The name of the account holder. If `none`, the sender name is used.
  /// -> auto | str | content
  name: auto,
  /// The name of the bank.
  /// -> str | content
  bank: none,
  /// The IBAN (will be formatted automatically).
  /// -> str
  iban: none,
  /// The BIC (Bank Identifier Code).
  /// -> str
  bic: none,
  /// The payment reference. If `none`, the invoice number is used.
  /// -> str | none
  reference: auto,
  /// The amount to transfer. If `none`, the calculated total is used.
  /// -> float | int | none
  payment-amount: auto,
  /// The label text for the account holder line.
  /// -> str | content
  account-holder-text: "Kontoinhaber:in",
  /// Configuration for the QR code.
  /// Structure: `(display: bool, size: length)`
  /// -> dictionary
  qr-code: (
    display: true,
    size: 4em,
  ),
) = context {
  let name_ = name
  if name == auto {
    name_ = state-autor-name.get()
  }

  let payment-amount_ = payment-amount
  if payment-amount == auto {
    payment-amount_ = state-total-invoice-amount.final()
  }

  let qr-code_ = (
    display: qr-code.at("display", default: true),
    size: qr-code.at("size", default: 4em),
  )

  let reference_ = reference
  if reference == auto {
    reference_ = state-invoice-nr.final()
  }
  if type(reference_) != str {
    reference_ = ""
  }

  let epc-qr-content = (
    "BCD\n" + "002\n" + "1\n" + "SCT\n" + bic + "\n" + name_ + "\n" + iban + "\n" + "EUR" + format-currency(payment-amount_, locale: "en") + "\n" + "\n" + reference_ + "\n" + "\n" + "\n"
  )

  let qr-image = rustycure.qr-code(epc-qr-content, width: qr-code_.size, quiet-zone: false)
  
  block(width: 100% - qr-code_.size, grid(
    columns: (auto, 1fr),
    align: top,
    gutter: 1em,
    stroke: none,
  )[ 
    #set par(leading: 0.40em)
    #set text(number-type: "lining")
    #account-holder-text: #name_ \
    Kreditinstitut: #bank \
    IBAN: *#ibanator.iban(iban)* \
    BIC: #bic \
    #h(6.5cm)
  ][#block(width: qr-code_.size, qr-image)])
}

/// Helper function to define a single line item.
///
/// This is used inside `invoice-line-items`.
/// You must specify either `price` (single unit) OR `price-total` (row total), but not both.
///
/// -> dictionary
#let item(
  /// The description of the product or service.
  /// -> content
  description,
  /// The quantity.
  /// -> int | float
  quantity: 1,
  /// The unit label (e.g., [pcs], [hrs]).
  /// -> content
  unit: [Stk.],
  /// The price per single unit gross
  /// -> float | int | none
  price: none,
  /// The total price for this line (Net/Gross). The single price is calculated automatically.
  /// -> float | int | none
  price-total: none,
  /// Whether the price is input as Net or Gross
  /// -> bool
  gross-price: true,
  /// The VAT rate for this item (e.g. `0.19`).
  /// -> float
  vat: 0.19,
) = {
  assert((price == none) or (price-total == none), message: "You can't specify the single item price and total item price at once.")
  
  if price-total != none {
    price = price-total / quantity
  }

  if price == none { price = 0 }
  
  let base-price = if gross-price { price / (1 + vat) } else { price }
  let final-price = base-price * (1 + vat)

  (
    description: description, 
    base-price: base-price,
    price: final-price, 
    unit: unit,
    quantity: quantity, 
    vat: vat,
  )
}

/// Renders the main invoice table.
///
/// Calculates subtotals, VAT amounts, and the final total.
/// It supports both B2B (net calculation) and B2C (gross display) logic.
///
/// -> content
#let invoice-line-items(
  /// If `true`, overrides the global VAT exemption setting. `auto` inherits from `invoice`.
  /// -> bool | auto
  vat-exemption: auto,
  /// Whether to show the quantity column. `auto` hides it if all quantities are 1.
  /// -> bool | auto
  show-quantity: auto,
  /// Whether to show the VAT column per item. `auto` shows it if VAT rates differ.
  /// -> bool | auto
  show-vat-per-item: auto,
  /// The currency symbol to display.
  /// -> content
  currency: [€],
  /// Controls the calculation mode.
  /// - `false` (Default, B2B): Displays net prices, rounds per line.
  /// - `true` (B2C): Displays gross prices, calculates internally with high precision to avoid rounding errors.
  /// -> bool
  show-gross-prices: false,
  /// The list of items created via the `item()` function.
  /// -> arguments
  ..items
) = context {
  let default-vat = state-vat.final()
  
  let vat-exemption_ = if vat-exemption == auto {
    state-vat-exemption.final()
  } else {
    vat-exemption
  }
  
  let use-exact-calculation = show-gross-prices
  
  let items_ = items.pos().map(item => {
    if vat-exemption_ {
      item.vat = 0
      item.base-price = item.price
    }
    
    item.base-price-exact = item.base-price
    item.base-price-display = calc.round(item.base-price, digits: 2)

    if not(use-exact-calculation) {
      item.base-price = item.base-price-display
    }
    
    item.price = calc.round(item.base-price * (1 + item.vat), digits: 2)
    return item
  })

  // Automatic Column Detection
  let show-quantity_ = show-quantity
  if show-quantity == auto {
    show-quantity_ = items_.find(item => item.quantity != 1) != none
  }

  let show-vat-per-item_ = show-vat-per-item
  if show-vat-per-item == auto {
    show-vat-per-item_ = not(vat-exemption_) and (items_.find(item => item.vat != default-vat) != none)
  }

  // --- Calculations ---

  let netto-price-sum = items_.map(item => item.base-price * item.quantity).sum()

  let vat-stages = items_.map(item => item.vat).dedup().map(vat-val => (
    vat: vat-val,
    total: items_.filter(item => item.vat == vat-val).map(item => item.base-price * item.quantity).sum() * vat-val
  ))
  
  let total-price = netto-price-sum + vat-stages.map(vat => vat.total).sum()
  
  state-total-invoice-amount.update(total-price)

  // --- Table Layout ---
  
  let table-align = (
    right,
    left,
    ..(if show-quantity_ { (right,) }),
    right,
    ..(if show-vat-per-item_ { (right,) }),
  )

  let tax-substring = if show-gross-prices [(brutto)] else [(netto)]
  if vat-exemption_ { tax-substring = none }

  let table-header = (
    [*Pos*],
    [*Beschreibung*],
    ..(if show-quantity_ {(
      [*Menge*],
      [*Einzelpreis #tax-substring*],
      [*Gesamt #tax-substring*],
    )} else {(
      [*Preis #tax-substring*],
    )}),
    ..(if show-vat-per-item_ { ([*MwSt.*],) })
  )

  let table-body = items_.enumerate().map(((pos, item)) => {
    let unit-price-display = if show-gross-prices { item.price } else { item.base-price-display }
    let total-row-price = unit-price-display * item.quantity
    
    (
      [#(pos + 1)],
      item.description,
      ..(if show-quantity_ {(
        [#item.quantity #item.unit],      
        [#format-currency(unit-price-display) #currency],
        [#format-currency(total-row-price) #currency],
      )} else {(
        [#format-currency(total-row-price) #currency],
      )}),
      ..(if show-vat-per-item_ { ([#calc.round(item.vat * 100, digits: 1)%],) }),
   )
  })

  // Footer Logic
  let total-col-idx = table-header.len() - if show-vat-per-item_ { 1 } else { 0 }
  let amount-line = table.hline.with(start: total-col-idx - 1, end: total-col-idx, stroke: .5pt + black)
  
  let left-spacer = (total-col-idx - 2) * ([],)
  let mwst-spacer = if show-vat-per-item_ { ([],) } else { () }
   
  let netto-table-footer = (
    ..left-spacer, align(right)[Summe:], [#format-currency(netto-price-sum) #currency], ..mwst-spacer,
    amount-line(),
    ..(if not(vat-exemption_) {
      vat-stages.sorted(key: it => it.vat).map(vs => (
        ..left-spacer,
        align(right, [#calc.round(vs.vat * 100, digits: 1)% Mehrwertsteuer:]),
        [#format-currency(vs.total) #currency],
        ..mwst-spacer,
      )).flatten()
    }),
    amount-line(),
    ..(table-header.len() * ([],)),
    ..left-spacer, align(right)[*Gesamt:*], [*#format-currency(total-price) #currency*],
    amount-line(stroke: 2pt + black),
  )
  
  let gross-table-footer = (
    ..(table-header.len() * ([],)),
    ..left-spacer, align(right)[*Gesamt:*], [*#format-currency(total-price) #currency*],
    ..mwst-spacer,
    amount-line(stroke: 2pt + black),
    ..(if not(vat-exemption_) {
      vat-stages.sorted(key: it => it.vat).map(vs => (
        ..left-spacer,
        align(right, [inkl. #calc.round(vs.vat * 100, digits: 1)% Mehrwertsteuer:]),
        [#format-currency(vs.total) #currency],
        ..mwst-spacer,
      )).flatten()
    }),
  )

  let table-footer = if show-gross-prices { gross-table-footer } else { netto-table-footer }
  

  table(
    stroke: none,
    columns: (auto, 1fr, ..((table-header.len() - 2) * (auto,))),
    align: table-align,
    table.header(
      repeat: true,
      table.hline(),
      ..table-header,
      table.hline(),
    ),
    ..table-body.flatten(),
    table.footer(
      table.hline(),
      repeat: false,
      ..table-footer
    )
  )

  if vat-exemption_ { block[Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.] }
}

/// Generates a sentence stating the payment deadline.
///
/// It automatically retrieves the total amount from the invoice state.
///
/// -> content
#let payment-goal(
  /// The number of days until payment is due.
  /// -> int
  days: 14, 
  /// The currency symbol to use in the text.
  /// -> content
  currency: [€]
) = {
  let sum-str = context format-currency(state-total-invoice-amount.final())

  [Bitte überweisen Sie den Gesamtbetrag von *#sum-str #currency* innerhalb von #days Tagen ohne Abzug auf das unten genannte Konto.]
}

/// Appends a closing greeting and a signature.
///
/// -> content
#let signature(
  /// The name of the signer. If `auto`, retrieves the sender name from the invoice.
  /// -> str | auto
  name: auto,
  /// The signature image or text.
  /// -> content | str | none
  signature: none,
) = context {
  let name_ = name
  if name == auto {
    name_ = state-autor-name.final()
  }

  block(breakable: false, {
    v(1em)
    [Mit freundlichen Grüßen]
    v(1em)

    if type(signature) == str {
      image("example_signature.png", height: 3em)
    } 
    if type(signature) == content {
      signature
    }
    name_
  })
}
