#import "@preview/payqr-swiss:0.1.0": swiss-qr-bill

// Example 1: Basic QR bill with QR-IBAN
#page[
  = Example 1: Basic QR bill with QR reference

  #swiss-qr-bill(
    account: "CH4431999123000889012",
    creditor-name: "Max Muster & Söhne",
    creditor-street: "Musterstrasse",
    creditor-building: "123",
    creditor-postal-code: "8000",
    creditor-city: "Seldwyla",
    creditor-country: "CH",
    amount: 1949.75,
    currency: "CHF",
    debtor-name: "Simon Muster",
    debtor-street: "Musterstrasse",
    debtor-building: "1",
    debtor-postal-code: "8000",
    debtor-city: "Seldwyla",
    debtor-country: "CH",
    reference-type: "QRR",
    reference: "210000000003139471430009017",
    additional-info: "Bestellung vom 15.10.2020"
  )
]

// Example 2: QR bill with Creditor Reference
#page[
  = Example 2: QR bill with Creditor Reference
  
  #swiss-qr-bill(
    account: "CH5800791123000889012",
    creditor-name: "Muster Krankenkasse",
    creditor-street: "Musterstrasse",
    creditor-building: "12",
    creditor-postal-code: "8000",
    creditor-city: "Seldwyla",
    creditor-country: "CH",
    amount: 211.00,
    currency: "CHF",
    debtor-name: "Sarah Beispiel",
    debtor-street: "Musterstrasse",
    debtor-building: "1",
    debtor-postal-code: "8000",
    debtor-city: "Seldwyla",
    debtor-country: "CH",
    reference-type: "SCOR",
    reference: "RF720191230100405JSH0438"
  )
]

// Example 3: QR bill without amount (e.g., for donations)
#page[
  = Example 3: QR bill without amount (e.g., for donations)
  
  #swiss-qr-bill(
    account: "CH5204835012345671000",
    creditor-name: "Muster Stiftung",
    creditor-street: "P.O. Box",
    creditor-postal-code: "3001",
    creditor-city: "Bern",
    creditor-country: "CH",
    currency: "CHF",
    reference-type: "NON"
  )
]

// Example 4: QR bill with billing information
#page[
  = Example 4: QR bill with billing information
  
  #swiss-qr-bill(
    account: "CH5800791123000889012",
    creditor-name: "Max Muster & Söhne",
    creditor-street: "Musterstrasse",
    creditor-building: "123",
    creditor-postal-code: "8000",
    creditor-city: "Seldwyla",
    creditor-country: "CH",
    amount: 199.95,
    currency: "CHF",
    debtor-name: "Sarah Beispiel",
    debtor-street: "Musterstrasse",
    debtor-building: "1",
    debtor-postal-code: "8000",
    debtor-city: "Seldwyla",
    debtor-country: "CH",
    reference-type: "SCOR",
    reference: "RF18539007547034",
    billing-info: "//S1/10/10201409/11/190512/20/1400.000-53/30/106017086/31/180508/32/7.7/40/2:10;0:30"
  )
]
