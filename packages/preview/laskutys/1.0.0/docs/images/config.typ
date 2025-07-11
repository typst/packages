#let config = (
  date: datetime(year: 2025, month: 09, day: 30),
  logo: image("/template/logo.svg", height: 4em),
  iban: "FI2112345600000785",
  bic: "OKOYFIHH",
  seller: (
    name: "Company Oy",
    business_id: "1234567-8",
    address: [Street 123\ 01234 City],
  ),
  recipient: (
    name: "Recipient Name",
    address: [Talousosasto\ PL 55\ 01000 Helsinki],
  ),
  lang: "fi",
  footnotes: [Company Oy, Phone: +358 123 4567, Email: sales.person\@company.com],
)
