#import "@preview/payqr-swiss:0.4.0": swiss-qr-bill

#set page(paper: "a4", margin: 2.5cm)

#page[
  = Example 1: Basic QR bill with QR reference (German)

  #place(bottom + center, dy: 2.5cm)[
    #swiss-qr-bill(
      account: "CH4431999123000889012",
      creditor-name: "Max Muster & Söhne",
      creditor-street: "Musterstrasse",
      creditor-building: "123",
      creditor-postal-code: "8000",
      creditor-city: "Zürich",
      creditor-country: "CH",
      amount: 1949.75,
      currency: "CHF",
      debtor-name: "Simon Meier",
      debtor-street: "Bahnhofstrasse",
      debtor-building: "1",
      debtor-postal-code: "8001",
      debtor-city: "Zürich",
      debtor-country: "CH",
      reference-type: "QRR",
      reference: "210000000003139471430009017",
      additional-info: "Bestellung vom 15.10.2020",
      language: "de"
    )
  ]
]

#page[
  = Example 2: QR bill with Creditor Reference (French)
  
  #place(bottom + center, dy: 2.5cm)[
    #swiss-qr-bill(
      account: "CH5800791123000889012",
      creditor-name: "Assurance Maladie Léman SA",
      creditor-street: "Avenue de la Gare",
      creditor-building: "14",
      creditor-postal-code: "1003",
      creditor-city: "Lausanne",
      creditor-country: "CH",
      amount: 211.00,
      currency: "CHF",
      debtor-name: "Marie Dubois",
      debtor-street: "Rue du Lac",
      debtor-building: "23",
      debtor-postal-code: "1800",
      debtor-city: "Vevey",
      debtor-country: "CH",
      reference-type: "SCOR",
      reference: "RF720191230100405JSH0438",
      language: "fr"
    )
  ]
]

#page[
  = Example 3: QR bill without amount (Italian)
  
  #place(bottom + center, dy: 2.5cm)[
    #swiss-qr-bill(
      account: "CH5204835012345671000",
      creditor-name: "Fondazione Ticinese",
      creditor-street: "Casella Postale",
      creditor-postal-code: "6900",
      creditor-city: "Lugano",
      creditor-country: "CH",
      currency: "CHF",
      reference-type: "NON",
      language: "it"
    )
  ]
]

#page[
  = Example 4: QR bill with billing information (English)
  
  #place(bottom + center, dy: 2.5cm)[
    #swiss-qr-bill(
      account: "CH5800791123000889012",
      creditor-name: "International Services Ltd",
      creditor-street: "Bahnhofstrasse",
      creditor-building: "45",
      creditor-postal-code: "8001",
      creditor-city: "Zürich",
      creditor-country: "CH",
      amount: 199.95,
      currency: "CHF",
      debtor-name: "John Smith",
      debtor-street: "Seestrasse",
      debtor-building: "10",
      debtor-postal-code: "6300",
      debtor-city: "Zug",
      debtor-country: "CH",
      reference-type: "SCOR",
      reference: "RF18539007547034",
      billing-info: "//S1/10/10201409/11/190512/20/1400.000-53/30/106017086/31/180508/32/7.7/40/2:10;0:30",
      language: "en"
    )
  ]
]
