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
  language: "de"  // de, fr, it, or en
) = {
  let lang = languages.at(language, default: languages.en)
  
  // QR code data according to Swiss QR bill standard
  // QR Type + Version + Coding Type + IBAN/QR-IBAN
  let qr-data = "SPC\n" + "0200\n" + "1\n" + account + "\n" 
  
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
  qr-data += reference-type + "\n" + reference + "\n"
  
  // Additional information, Trailer, and Billing information
  qr-data += additional-info + "\n" + "EPD\n" + billing-info
  
  let font-stack = (
    "Helvetica", 
    "Arial", 
    "Liberation Sans", 
    "Nimbus Sans L", 
    "Roboto", 
    "sans-serif"
  )
  
  set text(font: font-stack, size: 10pt)
  set page(paper: "a4", margin: 0cm)
  
  place(
    bottom + center,
    [
    #box(
    width: 100%,
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
            
            #v(3mm)
            #text(weight: "bold", size: 6pt)[#lang.account-payable-to]
            #linebreak()
            #text(size: 8pt)[#account]
            #linebreak()
            #text(size: 8pt)[#creditor-name]
            #linebreak()
            #text(size: 8pt)[#creditor-street #creditor-building]
            #linebreak()
            #text(size: 8pt)[#creditor-postal-code #creditor-city]
            
            #if reference != none {
              v(3mm)
              text(weight: "bold", size: 6pt)[#lang.reference]
              linebreak()
              text(size: 8pt)[#reference]
            }
            
            #v(3mm)
            #text(weight: "bold", size: 6pt)[#lang.payable-by-name-address]
            #linebreak()
            #text(size: 8pt)[#debtor-name]
            #linebreak()
            #text(size: 8pt)[#debtor-street #debtor-building]
            #linebreak()
            #text(size: 8pt)[#debtor-postal-code #debtor-city]
            
            #v(3mm)
            #grid(
              columns: (20mm,) * 2,
              rows: 5mm,
              text(weight: "bold", size: 6pt)[#lang.currency],
              text(weight: "bold", size: 6pt)[#lang.amount],
              text(size: 8pt)[#currency],
              text(size: 8pt)[#format-currency(amount)]
            )
            
            #v(5mm)
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
                      v(5mm),
                      qrcode(qr-data, options: ( option-1: 2 ), width: 46mm, height: 46mm),
                      // Swiss cross in the center
                      place(
                        dx: 20.5mm,
                        dy: -25.5mm,
                        block(
                          width: 7mm,
                          height: 7mm,
                            image("CH-Kreuz_7mm.svg"),
                        )
                      ),

                      v(5mm),
                      grid(
                        columns: (20mm,) * 2,
                        rows: 5mm,
                        text(weight: "bold", size: 8pt)[#lang.currency],
                        text(weight: "bold", size: 8pt)[#lang.amount],
                        text(size: 10pt)[#currency],
                        text(size: 10pt)[#format-currency(amount)]
                      )
                    )
                  ]
                )
              ),
              
              // Payment information
              block(
                width: 100%,
                [
                  #text(weight: "bold", size: 8pt)[#lang.account-payable-to]
                  #linebreak()
                  #text(size: 10pt)[#account]
                  #linebreak()
                  #text(size: 10pt)[#creditor-name]
                  #linebreak()
                  #text(size: 10pt)[#creditor-street #creditor-building]
                  #linebreak()
                  #text(size: 10pt)[#creditor-postal-code #creditor-city]
                  
                  #if reference != none {
                    v(3mm)
                    text(weight: "bold", size: 8pt)[#lang.reference]
                    linebreak()
                    text(size: 9pt)[#reference]
                  }
                   
                  #if additional-info != none {
                    v(3mm)
                    text(weight: "bold", size: 8pt)[#lang.additional-information]
                    linebreak()
                    text(size: 10pt)[#additional-info]
                  }
                  
                  #v(3mm)
                  #text(weight: "bold", size: 8pt)[#lang.payable-by-name-address]
                  #linebreak()
                  #text(size: 10pt)[#debtor-name]
                  #linebreak()
                  #text(size: 10pt)[#debtor-street #debtor-building]
                  #linebreak()
                  #text(size: 10pt)[#debtor-postal-code #debtor-city]
                ]
              )
            )
          ]
        )
      )
    ]
  )
  ])
}
