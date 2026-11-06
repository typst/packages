#import "@preview/invar:0.1.0"

#show: invar.invoice.with(
  sender: (
    name: "SENDER NAME",
    address: "SENDER ADDRESS",
    // "Phone": "+61-3-9000-1234",
    // "Email": "hello@northstar.example",
  ),
  recipient: (
    name: "RECIPIENT NAME",
    address: "SENDER ADDRESS",
  ),
  date: (
    datetime(
      year: 2026,
      month: 9,
      day: 1,
    ),
    "[day] [month repr:long] [year]",
  ),
  number: "INVOICE NUMBER",
  due: 14,
  currency: (
    name: "USD",
    symbol: "$",
  ),
  items: (
    "Item 1": 0,
  ),
  taxes: (
    "VAT": 10,
  ),
  payment: (
    (
      "FIELD": "ENTRY",
    ),
  ),
)

