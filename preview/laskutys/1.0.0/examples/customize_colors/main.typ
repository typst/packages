#import "@preview/laskutys:1.0.0": DEFAULT_COLORS, invoice

#let data = yaml("data.yaml")

#invoice(
  iban: "FI2112345600000785",
  bic: "OKOYFIHH",
  seller: (
    name: "Company Oy",
    business_id: "1234567-8",
    address: [Street 123\ 01234 City],
  ),
  recipient: (
    name: "Recipient Name",
    address: [Street 123\ 01234 City],
  ),
  colors: (
    ..DEFAULT_COLORS,
    active: blue,
    bg_passive: teal.lighten(85%),
    passive: teal,
  ),
  data,
)
