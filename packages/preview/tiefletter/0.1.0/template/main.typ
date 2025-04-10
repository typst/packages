#import "@preview/tiefletter:0.1.0": invoice, offer

#invoice(
  invoice_number: "2025-001",
  invoice_date: "07.04.2025",
  seller: (
    name: "Tiefseetauchner",
    address: "Schottenring 12\n1010, Wien",
    uid: "ATUxxxxxxx",
    email: "email-address@example.com",
    tel: "+43 123 456 789",
  ),
  footer_middle: none,
  footer_right: [GISA Nr.: 12345678\
Mitglied der WKÖ und WK Wien],
  banner-image: image("header.svg"),
  iban: "AT92 1234 1412 1245 3928",
  bic: "XXXXXXXXXXX",
  client: (
    gender_marker: "O",
    full_name: "Muster GesmbH",
    short_name: "Aron Schlosser",
    address: "Liselottenstraße 42c\n6049, Gamsagadorf",
  ),
  items: (
    (quantity: 2, description: "Beispiel 1", unit_price: 400.0),
    (quantity: 1, description: "Beispiel 2", unit_price: 300.0),
    (quantity: 1, description: "Beispiel 3", unit_price: 50.0, vat_rate: 10),
  ),
  payment_due_date: "21.04.2025",
  after_table_text: none,
  lang: "de",
)
