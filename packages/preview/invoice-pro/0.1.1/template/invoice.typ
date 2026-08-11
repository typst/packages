#import "@preview/invoice-pro:0.1.1": *

// Set language to German for correct date/number formatting
#set text(lang: "de")

#show: invoice.with(
  format: "DIN-5008-A", // or "DIN-5008-B"

  sender: (
    name: "Deine Firma / Name",
    address: "Musterstraße 1",
    city: "12345 Musterstadt",
    extra: (
      "Tel": [+49 123 4567890],
      "Web": [#link("https://www.example.com")[www.example.com]],
    ),
  ),

  recipient: (
    name: "Kunden Name",
    address: "Kundenstraße 5",
    city: "98765 Kundenstadt",
  ),

  invoice-nr: "2024-001",
  date: datetime.today(),
  tax-nr: "123/456/789",
)

// Add Invoice Items
#invoice-line-items(
  item([Consulting Service], quantity: 4, unit: [hrs], price: 80),
  item([Software License], price: 150),
)

// Payment Terms
#payment-goal(days: 14)

// Bank Details with QR Code
#bank-details(
  bank: "Musterbank",
  iban: "DE07100202005821158846",
  bic: "MUSTERBIC",
)

#signature(signature: block[Your Signature])
