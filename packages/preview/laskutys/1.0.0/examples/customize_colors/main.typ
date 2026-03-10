#import "@preview/laskutys:1.0.0": DEFAULT-COLORS, invoice

#let data = yaml("data.yaml")

#invoice(
  iban: "FI2112345600000785",
  bic: "OKOYFIHH",
  seller: (
    name: "Company Oy",
    business-id: "1234567-8",
    address: [Street 123\ 01234 City],
  ),
  recipient: (
    name: "Recipient Name",
    address: [Street 123\ 01234 City],
  ),
  colors: (
    ..DEFAULT-COLORS,
    active: blue,
    bg-passive: teal.lighten(85%),
    passive: teal,
  ),
  data,
)
