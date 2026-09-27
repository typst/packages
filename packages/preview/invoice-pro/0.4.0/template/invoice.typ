#import "@preview/invoice-pro:0.4.0": *

/*
 * Invoice Pro by Leonie Ziechmann
 *
 * GitHub: https://github.com/leonieziechmann/invoice-pro
 * If you have feature requests or find outdated information,
 * please create an Issue or Pull Request on GitHub.
 *
 * ZUGFeRD (experimental): Export as PDF/A-3B to embed XML.
 * - Web App: File > Export As -> PDF -> PDF/A-3B -> download icon
 * - CLI: typst compile --pdf-standard a-3b file.typ
 */


#show: invoice.with(
  theme: themes.DIN-5008(form: "A"),
  locale: locale.de-de,
  zugferd: "en16931",
  sender: (
    name: "Jane Doe",
    address: "Musterstraße 1",
    city: "12345 Musterstadt",
    tax-nr: "123/456/78901",
    vat-id: "DE123456789",
    contact: (
      name: "Jane Doe",
      phone: "+49 123 4567890",
      email: "jane.doe@example.com",
    ),
    extra: (
      "Tel": "+49 123 4567890",
      "E-Mail": "jane.doe@example.com",
    ),
  ),
  recipient: (
    name: "Client Corp",
    address: "Kundenweg 5",
    city: "54321 Kundenstadt",
    vat-id: "DE987654321",
    buyer-reference: "DE123456789-12345-12",
  ),
  invoice-nr: "2026-01",
)
#set text(10pt)

#line-items[
  #bundle(
    [Website Relaunch 2026],
    date: (date(10, 2, 2026), date(5, 3, 2026)),
    unit: unit.flat,
  )[
    #item(
      [Concept & Wireframing],
      price: 1200.00,
      quantity: 1,
      unit: unit.flat,
    )
    #item([UI/UX Design], price: 85.00, quantity: 15, unit: unit.flat)
    #item(
      [Frontend & Backend Development],
      price: 95.00,
      quantity: 40,
      unit: unit.h,
    )

    #discount([Package Discount (10% on development services)], amount: 10%)

    #bundle([SEO & Tracking Setup])[
      #item(
        [Keyword Research & Strategy],
        price: 90.00,
        quantity: 5,
        unit: unit.h,
      )
      #item([Setup Google Analytics & Tag Manager], price: 150.00, quantity: 1)
    ]
  ]

  #apply(tax: tax.vat(7%))[
    #item(
      [Textbook: "Modern Web Design"],
      price: 49.90,
      quantity: 2,
      unit: unit.pcs,
    )
  ]

  #item(
    [Premium Hosting],
    price: 15.00,
    quantity: 12,
    unit: unit.mo,
    date: datetime.today(),
  )

  #item(
    [Domain Registration (.com)],
    total: 11.90,
    input-gross: true,
    unit: unit.flat,
  )

  #item(
    [Email Inbox Setup],
    price: 0,
    tax: tax.zero(),
    description: "Included service as per framework agreement",
    unit: unit.flat,
  )

  #discount([Promo Voucher "NEWCUSTOMER50"], amount: 50)
  #surcharge([Processing and Service Fee], amount: 15.00)
]

#payment-goal(days: 14)

#bank-details(
  bank: "Musterbank",
  iban: "DE07100202005821158846",
  bic: "EXAMPLEBICX",
)

#signature()
