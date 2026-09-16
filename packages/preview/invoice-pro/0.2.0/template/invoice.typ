#import "@preview/invoice-pro:0.2.0": *

/*
 * Invoice Pro by Leonie Ziechmann
 *
 * GitHub: https://github.com/leonieziechmann/invoice-pro
 * If you have feature requests or find outdated information,
 * please create an Issue or Pull Request on GitHub.
 */

#show: invoice.with(
  theme: themes.DIN-5008(form: "A"),
  sender: (
    name: "Deine Firma / Name",
    address: "Musterstraße 1",
    city: "12345 Musterstadt",
  ),
  recipient: (
    name: "Kunden Name",
    address: "Kundenstraße 5",
    city: "98765 Kundenstadt",
  ),
  invoice-nr: "2026-01",
  tax-nr: "123/456/789",
)

#set text(10pt)

#line-items[
  #bundle(
    [Webseiten Relaunch 2026],
    date: (date(10, 2, 2026), date(5, 3, 2026)),
    unit: "Pausch.",
  )[
    #item(
      [Konzeption & Wireframing],
      price: 1200.00,
      quantity: 1,
      unit: "Pauschale",
    )
    #item([UI/UX Design], price: 85.00, quantity: 15, unit: "Std.")
    #item(
      [Frontend & Backend Entwicklung],
      price: 95.00,
      quantity: 40,
      unit: "Std.",
    )

    #discount([Paketrabatt (10% auf Entwicklungsleistungen)], amount: 10%)

    #bundle([SEO & Tracking Setup])[
      #item(
        [Keyword-Recherche & Strategie],
        price: 90.00,
        quantity: 5,
        unit: "Std.",
      )
      #item([Setup Google Analytics & Tag Manager], price: 150.00, quantity: 1)
    ]
  ]

  #apply(tax: 7%)[
    #item(
      [Fachbuch: "Modernes Webdesign"],
      price: 49.90,
      quantity: 2,
      unit: "Stk.",
    )
    #item(
      [Fachbuch: "SEO für Anfänger"],
      price: 29.90,
      quantity: 1,
      unit: "Stk.",
    )
  ]

  #item(
    [Premium Hosting],
    price: 15.00,
    quantity: 12,
    unit: "Monate",
    date: datetime.today(),
  )

  #item(
    [Domainregistrierung (.de)],
    total: 11.90,
    input-gross: true,
    unit: "Pausch.",
  )

  #item(
    [Einrichtung der E-Mail-Postfächer],
    price: 0,
    tax: tax.zero(),
    description: "Inklusivleistung gemäß Rahmenvertrag",
    unit: "Pausch.",
  )

  #discount([Aktionsgutschein "NEUKUNDE50"], amount: 50)
  #surcharge([Bearbeitungs- und Servicegebühr], amount: 15.00)
]

#payment-goal(days: 14)

#bank-details(
  bank: "Musterbank",
  iban: "DE07100202005821158846",
  bic: "MUSTERBICXX",
)

#v(-.5em)

#signature()
