#import "@preview/tiaoma:0.3.0": qrcode

#let languages = (
  de: (
    payment-part: "Zahlteil",
    receipt: "Empfangsschein",
    account-payable-to: "Konto / Zahlbar an",
    reference: "Referenz",
    additional-information: "Zusätzliche Informationen",
    payable-by: "Zahlbar durch",
    payable-by-name-address: "Zahlbar durch (Name/Adresse)",
    currency: "Währung",
    amount: "Betrag",
    acceptance-point: "Annahmestelle",
    separate-before-paying: "Vor der Einzahlung abzutrennen"
  ),
  fr: (
    payment-part: "Section paiement",
    receipt: "Récépissé",
    account-payable-to: "Compte / Payable à",
    reference: "Référence",
    additional-information: "Informations supplémentaires",
    payable-by: "Payable par",
    payable-by-name-address: "Payable par (nom/adresse)",
    currency: "Monnaie",
    amount: "Montant",
    acceptance-point: "Point de dépôt",
    separate-before-paying: "A détacher avant le versement"
  ),
  it: (
    payment-part: "Sezione pagamento",
    receipt: "Ricevuta",
    account-payable-to: "Conto / Pagabile a",
    reference: "Riferimento",
    additional-information: "Informazioni supplementari",
    payable-by: "Pagabile da",
    payable-by-name-address: "Pagabile da (nome/indirizzo)",
    currency: "Valuta",
    amount: "Importo",
    acceptance-point: "Punto di accettazione",
    separate-before-paying: "Da staccare prima del versamento"
  ),
  en: (
    payment-part: "Payment part",
    receipt: "Receipt",
    account-payable-to: "Account / Payable to",
    reference: "Reference",
    additional-information: "Additional information",
    payable-by: "Payable by",
    payable-by-name-address: "Payable by (name/address)",
    currency: "Currency",
    amount: "Amount",
    acceptance-point: "Acceptance point",
    separate-before-paying: "Separate before paying in"
  )
)

#let format-currency(number, separator: " ") = {
  let precision = 2
  
  // Round the number and convert to string
  let s = str(calc.round(number, digits: precision))
  
  let parts = s.split(".")
  let whole = parts.at(0)
  let fraction = if parts.len() > 1 { parts.at(1) } else { "" }
  
  // Add thousands separators to the whole part
  let result = ""
  let len = whole.len()
  
  for i in range(len) {
    if i > 0 and calc.rem(len - i, 3) == 0 {
      result += separator
    }
    result += whole.at(i)
  }
  
  // Ensure the correct number of decimal places
  if fraction.len() < precision {
    fraction += "0" * (precision - fraction.len())
  }
  
  result + "." + fraction
}

#let remove-whitespaces(str) = {
  if str == none {
    return
  }
  str.split("").filter(x => x != " ").join("")
}

#let format-reference(reference, ref-type) = {
  if reference == none {
    return
  }
  
  let result = ""
  let refWithoutSpaces = remove-whitespaces(reference)
  let len = refWithoutSpaces.len()
    
  if ref-type == "QRR" {
    // Begin with 2 chars, 5x5 chars
    for i in range(len) {
      if i == 0 {
        result += refWithoutSpaces.at(i)
      } else if i == 1 {
        result += refWithoutSpaces.at(i)
      } else {
        if i > 0 and calc.rem(i - 2, 5) == 0 {
          result += " "
        }
        
        result += refWithoutSpaces.at(i)
      }
    }
  } else {
    // 4 groups and the rest just at the end
    for i in range(len) {
      if i > 0 and calc.rem(i, 4) == 0 {
        result += " "
      }
      
      result += refWithoutSpaces.at(i)
    }
  }
  
  result
}

#let format-iban(iban) = {
  // Fake the ref type just for the right formatting, could be done nicer, I know
  format-reference(iban, "NON")
}

// Swiss QR Bill function that returns a content element
#let swiss-qr-bill(
  account: "",
  creditor-name: "",
  creditor-street: "",
  creditor-building: "",
  creditor-postal-code: "",
  creditor-city: "",
  creditor-country: "CH",
  amount: 0,
  currency: "CHF",
  debtor-name: "",
  debtor-street: "",
  debtor-building: "",
  debtor-postal-code: "",
  debtor-city: "",
  debtor-country: "CH",
  reference-type: "NON",  // QRR, SCOR, or NON
  reference: none,
  additional-info: none,
  billing-info: none,
  language: "de",  // de, fr, it, or en
  standalone: false,  // false: floating element (default), true: force new page
  font: "auto"  // "auto": use spec-compliant fonts, "page": inherit from page, or specify font name
) = {
  // If amount = 0 then it's a bill with a blank field for the amount
  if (amount < 0.01 or amount > 999999999.99) and amount != 0 {
    panic("Amount must be between 0.01 and 999999999.99")
  }

  let accountWithoutSpaces = remove-whitespaces(account)
  
  if accountWithoutSpaces.len() != 21 {
    panic("IBAN must be exactly 21 characters long")
  }
  
  if currency != "CHF" and currency != "EUR" {
    panic("Currency must be either CHF or EUR")
  }

  let lang = languages.at(language, default: languages.en)

  let compliant-fonts = (
     "arial", "frutiger", "helvetica", "liberation sans"
  )

  let font-to-use = if font == "auto" {
    // Default spec-compliant font stack
    ("Helvetica", "Frutiger", "Arial", "Liberation Sans")
  } else if font == "page" {
    // Don't set font, inherit from page context
    none
  } else {
    // User-specified font - check compliance
    // When Typst gets a function to generate compiler warnings, we can use it here to inform the user of non-compliance
    
    // let font-names = if type(font) == array { font } else { (font,) }
    // let non-compliant = font-names.filter(f => not compliant-fonts.contains(lower(f)))
    //
    // if non-compliant.len() > 0 {
    //   panic("Warning: Font(s) '" + non-compliant.join(", ") + "' may not be compliant with Swiss QR bill specifications. Consider using: Arial, Frutiger, Helvetica or Liberation Sans.")
    // }

    font
  }

  // QR code data according to Swiss QR bill standard
  // QR Type + Version + Coding Type + IBAN/QR-IBAN
  let qr-data = "SPC\n" + "0200\n" + "1\n" + accountWithoutSpaces + "\n" 
  
  // Creditor information (Address Type + Name + Address)
  qr-data += "S\n" + creditor-name + "\n" + creditor-street + "\n" + creditor-building + "\n"
  qr-data += creditor-postal-code + "\n" + creditor-city + "\n" + creditor-country + "\n"
  
  // Ultimate Creditor fields (empty placeholders)
  qr-data += "\n\n\n\n\n\n\n"
  
  // Amount and Currency
  qr-data += format-currency(amount, separator: "") + "\n" + currency + "\n"
  
  // Ultimate Debtor fields
  if debtor-name != "" {
    qr-data += "S\n" + debtor-name + "\n" + debtor-street + "\n" + debtor-building + "\n"
    qr-data += debtor-postal-code + "\n" + debtor-city + "\n" + debtor-country + "\n"
  } else {
    qr-data += "\n\n\n\n\n\n\n"
  }

  // Reference information
  qr-data += reference-type + "\n" + remove-whitespaces(reference) + "\n"
  
  // Additional information, Trailer, and Billing information
  qr-data += additional-info + "\n" + "EPD\n" + billing-info
  
  let qr-bill-content = [
    #box(
    // fixed Swiss standard dimensions
    width: 210mm,
    height: 105mm,
    [
      // Horizontal dotted line
      #place(
        top + center,
        dx: -10mm,
        dy: -1.75mm,
        text(font: ("Zapf Dingbats", "DejaVu Sans", "Segoe UI Symbol", "Arial Unicode MS"), size: 12pt)[✂]
      )

      #place(
        top + center,
        dx: 0mm,
        line(
          start: (0mm, 0mm),
          end: (100%, 0mm),
          stroke: stroke(dash: "dotted", thickness: 0.5pt)
        )
      )
      
      // Vertical dotted line
      #place(
        top,
        dx: 62mm,
        line(
          start: (0mm, 0mm),
          end: (0mm, 105mm),
          stroke: stroke(dash: "dotted", thickness: 0.5pt)
        )
      )

      #place(
        top,
        dy: 12mm,
        dx: 60.1mm,
        rotate(90deg)[#text(font: ("Zapf Dingbats", "DejaVu Sans", "Segoe UI Symbol", "Arial Unicode MS"), size: 12pt)[✂]]
      )
      
      // Receipt (left side)
      #place(
        top + left,
        dx: 5mm,
        dy: 5mm,
        block(
          width: 62mm,
          [
            #text(weight: "bold", size: 11pt)[#lang.receipt]

            #set par(leading: 3pt)
            
            #text(weight: "bold", size: 6pt)[#lang.account-payable-to]
            #linebreak()
            #text(size: 8pt)[#format-iban(account)]
            #linebreak()
            #text(size: 8pt)[#creditor-name]
            #linebreak()
            #text(size: 8pt)[#creditor-street #creditor-building]
            #linebreak()
            #if creditor-country != "CH" {
              text(size: 8pt)[#creditor-country - #creditor-postal-code #creditor-city]
            } else {
              text(size: 8pt)[#creditor-postal-code #creditor-city]
            }
            
            #if reference != none {
              text(weight: "bold", size: 6pt)[#lang.reference]
              linebreak()
              text(size: 8pt)[#format-reference(reference, reference-type)]
            }
            
            
            #if debtor-name != "" {
              text(weight: "bold", size: 6pt)[#lang.payable-by]
              linebreak()
              text(size: 8pt)[#debtor-name]
              linebreak()
              text(size: 8pt)[#debtor-street #debtor-building]
              linebreak()
              if debtor-country != "CH" {
                text(size: 8pt)[#debtor-country - #debtor-postal-code #debtor-city]
              } else {
                text(size: 8pt)[#debtor-postal-code #debtor-city]
              }
            } else {
              text(weight: "bold", size: 8pt)[#lang.payable-by-name-address]
              v(-3mm)
              image("assets/receipt_payable_by.svg", height: 20mm, width: 52mm)
            }
            
            #v(14mm)
            
            #grid(
              columns: if amount == 0 { (13mm, auto) } else { (26mm, 26mm) },
              rows: 3mm,
              text(weight: "bold", size: 6pt)[#lang.currency],
              text(weight: "bold", size: 6pt)[#lang.amount],
              text(size: 8pt)[#currency],
              if amount == 0 {
                place(
                  dx: 9mm,
                  dy: -3mm,
                  image("assets/receipt_amount.svg", height: 10mm, width: 30mm)
                )
              } else {
                text(size: 8pt)[#format-currency(amount)]
              }
            )
            
            #v(8mm)
            
            #place(
              right,
              dx: -8mm,
              text(weight: "bold", size: 6pt)[#lang.acceptance-point]
            )
          ]
        )
      )
      
      // Payment part (right side)
      #place(
        top + left,
        dx: 68mm,
        dy: 5mm,
        block(
          width: 148mm,
          [
            
            #grid(
              columns: (55mm, auto),
              rows: (auto),
              
              // QR code
              place(
                left,
                block(
                  width: 50mm,
                  height: 100mm,
                  align(left)[
                    #stack(
                      dir: ttb,
                      text(weight: "bold", size: 11pt)[#lang.payment-part],
                      v(8mm),
                      qrcode(qr-data, options: ( option-1: 2 ), width: 46mm, height: 46mm),
                      // Swiss cross in the center
                      place(
                        dx: 19.5mm, // 46 / 2 - 7 / 2 = 19.5
                        dy: -26.5mm, // 46 / 2 + 7 / 2 = 26.5
                        block(
                          width: 7mm,
                          height: 7mm,
                          image("assets/ch_cross_7mm.svg", width: 7mm, height: 7mm),
                        )
                      ),

                      v(5mm),
                      grid(
                        // Width is 46mm + 5mm margin on the right that can be used.
                        // So I give the currency half the official width and the amount the rest with margin.
                        columns: (23mm, 28mm),
                        rows: 3mm,
                        text(weight: "bold", size: 8pt)[#lang.currency],
                        text(weight: "bold", size: 8pt)[#lang.amount],
                        text(size: 10pt)[#currency],

                        if amount == 0 {
                            place(
                              dx: -9mm,
                              block(
                                width: 40mm,
                                height: 15mm,
                                image("assets/payment_amount.svg", height: 15mm, width: 40mm),
                              )
                            )
                        } else {
                          text(size: 10pt)[#format-currency(amount)]
                        }
                      )
                    )
                  ]
                )
              ),
              
              // Payment information
              block(
                width: 100%,
                [
                  #set par(leading: 3pt)
                  
                  #text(weight: "bold", size: 8pt)[#lang.account-payable-to]
                  #linebreak()
                  #text(size: 10pt)[#format-iban(account)]
                  #linebreak()
                  #text(size: 10pt)[#creditor-name]
                  #linebreak()
                  #text(size: 10pt)[#creditor-street #creditor-building]
                  #linebreak()
                  #if creditor-country != "CH" {
                    text(size: 10pt)[#creditor-country - #creditor-postal-code #creditor-city]
                  } else {
                    text(size: 10pt)[#creditor-postal-code #creditor-city]
                  }
                  
                  #if reference != none {
                    text(weight: "bold", size: 8pt)[#lang.reference]
                    linebreak()
                    text(size: 9pt)[#format-reference(reference, reference-type)]
                  }
                   
                  #if additional-info != none {
                    text(weight: "bold", size: 8pt)[#lang.additional-information]
                    linebreak()
                    text(size: 10pt)[#additional-info]
                  }
                  
                  #if debtor-name != "" {
                    text(weight: "bold", size: 8pt)[#lang.payable-by]
                    linebreak()
                    text(size: 10pt)[#debtor-name]
                    linebreak()
                    text(size: 10pt)[#debtor-street #debtor-building]
                    linebreak()
                    if debtor-country != "CH" {
                      text(size: 10pt)[#debtor-country - #debtor-postal-code #debtor-city]
                    } else {
                      text(size: 10pt)[#debtor-postal-code #debtor-city]
                    }
                  } else {
                    text(weight: "bold", size: 8pt)[#lang.payable-by-name-address]
                    v(-3mm)
                    image("assets/payment_payable_by.svg", height: 25mm, width: 65mm)
                  }
                ]
              )
            )
          ]
        )
      )
    ]
  )
  ]
  
  if standalone {
    // Standalone mode: force new page
    set page(paper: "a4", margin: 0cm)
    if font-to-use != none {
      set text(font: font-to-use, size: 10pt)
    } else {
      set text(size: 10pt)
    }

    place(
      bottom + center,
      qr-bill-content
    )
  } else {
    // Return QR bill as floating content block
    if font-to-use != none {
      set text(font: font-to-use, size: 10pt)
      qr-bill-content
    } else {
      // Don't set font, inherit from page context
      set text(size: 10pt)
      qr-bill-content
    }
  }
}
