#import "@preview/invoice-pro:0.3.1": *

/*
 * Invoice Pro by Leonie Ziechmann
 *
 * GitHub: https://github.com/leonieziechmann/invoice-pro
 * If you have feature requests or find outdated information,
 * please create an Issue or Pull Request on GitHub.
 */


#show: invoice.with(
  theme: themes.DIN-5008(form: "A"),
  locale: locale.en-de,
  sender: (
    name: "Your Company / Name",
    address: "123 Example Street",
    city: "12345 Example City",
    extra: (
      "Tel": "+49 123 4567890",
      "E-Mail": "my-mail@domain.com",
    ),
  ),
  recipient: (
    name: "Customer Name",
    address: "5 Customer Street",
    city: "98765 Customer City",
  ),
  invoice-nr: "2026-01",
  tax-nr: "123/456/789",
)
#set text(10pt)


#line-items[
  #bundle(
    [Website Relaunch 2026],
    date: (date(10, 2, 2026), date(5, 3, 2026)),
    unit: "flat",
  )[
    #item(
      [Concept & Wireframing],
      price: 1200.00,
      quantity: 1,
      unit: "flat",
    )
    #item([UI/UX Design], price: 85.00, quantity: 15, unit: "hrs")
    #item(
      [Frontend & Backend Development],
      price: 95.00,
      quantity: 40,
      unit: "hrs",
    )

    #discount([Package Discount (10% on development services)], amount: 10%)

    #bundle([SEO & Tracking Setup])[
      #item(
        [Keyword Research & Strategy],
        price: 90.00,
        quantity: 5,
        unit: "hrs",
      )
      #item([Setup Google Analytics & Tag Manager], price: 150.00, quantity: 1)
    ]
  ]

  #apply(tax: tax.lower-rate(7%))[
    #item(
      [Textbook: "Modern Web Design"],
      price: 49.90,
      quantity: 2,
      unit: "pcs",
    )
    #item(
      [Textbook: "SEO for Beginners"],
      price: 29.90,
      quantity: 1,
      unit: "pcs",
    )
  ]

  #item(
    [Premium Hosting],
    price: 15.00,
    quantity: 12,
    unit: "months",
    date: datetime.today(),
  )

  #item(
    [Domain Registration (.com)],
    total: 11.90,
    input-gross: true,
    unit: "flat",
  )

  #item(
    [Email Inbox Setup],
    price: 0,
    tax: tax.zero(),
    description: "Included service as per framework agreement",
    unit: "flat",
  )

  #discount([Promo Voucher "NEWCUSTOMER50"], amount: 50)
  #surcharge([Processing and Service Fee], amount: 15.00)
]

#payment-goal(days: 14)

#bank-details(
  bank: "Example Bank",
  iban: "DE07100202005821158846",
  bic: "EXAMPLEBICX",
)

#v(-.5em)

#signature()
