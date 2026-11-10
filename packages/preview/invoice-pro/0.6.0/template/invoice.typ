#import "@preview/invoice-pro:0.6.0": *

/*
 * invoice-pro by Leonie Ziechmann
 * Docs:   https://leonieziechmann.github.io/invoice-pro
 * GitHub: https://github.com/leonieziechmann/invoice-pro
 *         (ideas, questions and bugs are welcome as issues)
 *
 * E-INVOICE (ZUGFeRD / Factur-X, experimental)
 * With `zugferd` set, the invoice is attached to the PDF as XML. Download
 * the PDF as PDF/A-3b, the format an e-invoice needs:
 * - Web app: File > Export as > PDF, select "PDF/A-3b" under
 *   "PDF standard", then click the download icon next to "PDF".
 * - CLI: typst compile --pdf-standard=a-3b invoice.typ
 * While required data is missing, the invoice is a draft with markers and
 * a report page, and no XML is attached. `validation: "strict"` stops the
 * compilation instead, e.g. before sending.
 *
 * THEMES
 * `theme` sets the look: bold, classic, plain, corporate, elegant,
 * prestige, technical, soft, compact or boxed. All ten in the docs:
 * https://leonieziechmann.github.io/invoice-pro/themes
 * - Your brand color and logo:
 *     theme.bold.with(theme.custom.brand(
 *       color: rgb("#e4572e"),
 *       logo: image("logo.svg", alt: "Jane Doe"),
 *     ))
 * - For a window envelope: theme.bold.with(layout: theme.layout.din-5008-a)
 */

#show: invoice.with(
  theme: theme.bold, // the look, see THEMES above
  locale: locale.de-de,
  zugferd: "en16931", // the e-invoice profile; none: a PDF without XML
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

#payment-terms(days: 14)

#bank-details(
  bank: "Musterbank",
  iban: "DE07100202005821158846",
  bic: "EXAMPLEBICX",
)

#signature()
