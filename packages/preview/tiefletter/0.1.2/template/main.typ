#import "@preview/tiefletter:0.1.2": invoice

#invoice(
  invoice-number: "2025-001",
  invoice-date: "07.04.2025",
  seller: (
    name: "Tiefseetauchner",
    address: "Schottenring 12\n1010, Wien",
    uid: "ATUxxxxxxx",
    email: "email-address@example.com",
    tel: "+43 123 456 789",
  ),
  footer-middle: none,
  footer-right: [GISA Nr.: 12345678\
    Mitglied der WKÖ und WK Wien],
  banner-image: image("header.svg"),
  iban: "AT92 1234 1412 1245 3928",
  bic: "XXXXXXXXXXX",
  client: (
    gender-marker: "O",
    full-name: "Muster GesmbH",
    short-name: "Aron Schlosser",
    address: "Liselottenstraße 42c\n6049, Gamsagadorf",
  ),
  items: (
    (quantity: 2, description: "Beispiel 1", unit-price: 400.0),
    (quantity: 1, description: "Beispiel 2", unit-price: 300.0),
    (quantity: 1, description: "Beispiel 3", unit-price: 50.0, vat-rate: 10),
  ),
  payment-due-date: "21.04.2025",
  after-table-text: none,
  lang: "de",
)
