#import "@preview/classy-german-invoice:0.2.0": invoice

#show: invoice(
  // Invoice number
  "2023-001",
  // Invoice date
  datetime(year: 2024, month: 09, day: 03),
  // Items
  (
    (
      description: "The first service provided. The first service provided. The first service provided", price: 200,
    ), (description: "The second service provided", price: 150.2),
  ),
  // Author
  (
    name: "Kerstin Humm", street: "Straße der Privatsphäre und Stille 1", zip: "54321", city: "Potsdam", tax_nr: "12345/67890",
  ),
  // Recipient
  (
    name: "Erika Mustermann", street: "Musterallee", zip: "12345", city: "Musterstadt",
  ),
  // Bank account
  (
    name: "Todd Name", bank: "Deutsche Postbank AG", iban: "DE89370400440532013000", bic: "PBNKDEFF",
  ), 
  // Umsatzsteuersatz (VAT)
  vat: 0.19,
  kleinunternehmer: true,
)

