#import "@preview/tiaoma:0.3.0": qrcode

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
  billing-info: none
) = {
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
  
  set text(font: "Helvetica", size: 10pt)
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
        text(font: "Zapf Dingbats", size: 12pt)[✂]
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
        rotate(90deg)[#text(font: "Zapf Dingbats", size: 12pt)[✂]]
      )
      
      // Receipt (left side)
      #place(
        top + left,
        dx: 5mm,
        dy: 5mm,
        block(
          width: 62mm,
          [
            #text(weight: "bold", size: 11pt)[Empfangsschein]
            
            #v(3mm)
            #text(weight: "bold", size: 6pt)[Konto / Zahlbar an]
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
              text(weight: "bold", size: 6pt)[Reference]
              linebreak()
              text(size: 8pt)[#reference]
            }
            
            #v(3mm)
            #text(weight: "bold", size: 6pt)[Zahlbar durch (Name/Adresse)]
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
              text(weight: "bold", size: 6pt)[Währung],
              text(weight: "bold", size: 6pt)[Betrag],
              text(size: 8pt)[#currency],
              text(size: 8pt)[#format-currency(amount)]
            )
            
            #v(5mm)
            #place(
              right,
              dx: -8mm,
              text(weight: "bold", size: 6pt)[Annahmestelle]
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
                      text(weight: "bold", size: 11pt)[Zahlteil],
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
                        text(weight: "bold", size: 8pt)[Währung],
                        text(weight: "bold", size: 8pt)[Betrag],
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
                  #text(weight: "bold", size: 8pt)[Konto / Zahlbar an]
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
                    text(weight: "bold", size: 8pt)[Referenz]
                    linebreak()
                    text(size: 9pt)[#reference]
                  }
                   
                  #if additional-info != none {
                    v(3mm)
                    text(weight: "bold", size: 8pt)[Zusätzliche Informationen]
                    linebreak()
                    text(size: 10pt)[#additional-info]
                  }
                  
                  #v(3mm)
                  #text(weight: "bold", size: 8pt)[Zahlbar durch (Name/Adresse)]
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
