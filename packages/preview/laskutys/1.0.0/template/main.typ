#import "@preview/laskutys:1.0.0": *

#let data = yaml("data.yaml")

#invoice(
  date: datetime(year: 2025, month: 09, day: 30),
  logo: image("logo.svg", height: 4em),
  iban: "FI2112345600000785",
  bic: "NDEAFIHH",
  seller: (
    name: "Yritys Oy",
    business-id: "1234567-8",
    address: [Talousosasto\ PL 12\ 00100 Helsinki],
  ),
  recipient: (
    name: "Kuluttaja Nimi",
    address: [Kotikatu 1\ 00100 Helsinki],
  ),
  lang: "fi",
  footnotes: [Company Oy, Phone: +358 123 4567, Email: sales.person\@company.com],
  data,
)
