#import "@preview/payqr-swiss:0.4.0": swiss-qr-bill

#set page(paper: "a4", margin: 2cm)
#set text(font: "Helvetica", size: 11pt)

#page[
  // Company Header
  #grid(
    columns: (1fr, auto),
    gutter: 2cm,
    [
      #text(size: 24pt, weight: "bold", fill: rgb("#1f4e79"))[
        Muster Consulting AG
      ]
      #v(0.3cm)
      #text(size: 10pt, fill: rgb("#666666"))[
        Bahnhofstrasse 45 • 8001 Zürich • Switzerland
        #linebreak()
        Tel: +41 44 123 45 67 • Email: info\@muster-consulting.ch
      ]
    ],
    [
      #rect(
        width: 4cm,
        height: 2cm,
        stroke: 1pt + gray,
        fill: rgb("#f8f9fa"),
        align(center + horizon)[
          #text(size: 8pt, fill: gray)[Firmenlogo]
        ]
      )
    ]
  )
  
  #v(1cm)
  
  // Invoice details
  #grid(
    columns: (2fr, 3fr),
    gutter: 3cm,
    [
      #text(size: 9pt, fill: gray)[Rechnungsadresse:]
      #v(0.2cm)
      #text(weight: "medium")[
        Beispiel Kunden AG
        #linebreak()
        Herr Max Beispiel
        #linebreak()
        Seestrasse 12
        #linebreak()
        6003 Luzern
      ]
    ],
    [
      #rect(
        width: 100%,
        stroke: 1pt + rgb("#e9ecef"),
        fill: rgb("#f8f9fa"),
        inset: 12pt,
        [
          #text(size: 14pt, weight: "bold")[RECHNUNG]
          #v(0.3cm)
          #grid(
            columns: (auto, 1fr),
            row-gutter: 0.15cm,
            column-gutter: 0.5cm,
            [Rechnung Nr.:], [*2025-0842*],
            [Datum:], [15. August 2025],
            [Fällig am:], [*14. September 2025*],
          )
        ]
      )
    ]
  )
  
  #v(1cm)
  
  // Services table
  #table(
    columns: (3fr, 0.5fr, 1fr, 1fr),
    stroke: (bottom: 1pt),
    [*Beschreibung*], [*Std.*], [*Ansatz*], [*Betrag*],
    [Software-Entwicklung Backend], [40], [CHF 180.00], [CHF 7'200.00],
    [Frontend-Integration], [24], [CHF 165.00], [CHF 3'960.00],
    [Deployment & DevOps], [8], [CHF 200.00], [CHF 1'600.00],
    table.hline(),
    [*Gesamtbetrag*], [], [], [*CHF 12'760.00*]
  )
  
  #v(0.5cm)
  
  // Payment terms
  #rect(
    width: 100%,
    stroke: 1pt + rgb("#ffc107"),
    fill: rgb("#fff3cd"),
    inset: 12pt,
    [
      #text(weight: "bold")[Zahlungsbedingungen:]
      #v(0.2cm)
      Bitte verwenden Sie den QR-Code unten für die Zahlung.
    ]
  )
  
  // Position floating QR bill at bottom of page
  #place(
    bottom + center,
    dy: 2cm,   // Extend beyond bottom margin to reach paper edge
    swiss-qr-bill(
      account: "CH4431999123000889012",
      creditor-name: "Muster Consulting AG",
      creditor-street: "Bahnhofstrasse",
      creditor-building: "45",
      creditor-postal-code: "8001",
      creditor-city: "Zürich",
      creditor-country: "CH",
      amount: 12760.00,
      currency: "CHF",
      debtor-name: "Beispiel Kunden AG",
      debtor-street: "Seestrasse",
      debtor-building: "12",
      debtor-postal-code: "6003",
      debtor-city: "Luzern",
      debtor-country: "CH",
      reference-type: "QRR",
      reference: "210000000003139471430009017",
      additional-info: "Rechnung 2025-0842",
      language: "de"
    )
  )
]

