#import "/src/utils/translate.typ": translate
#import "/src/components/legal-entity.typ": legal-entity

/// -> content
#let header(
  invoice-number,
  date,
  recipient: none,
  seller: none,
  logo: none,
) = {
  assert(
    type(seller) == dictionary and "business-id" in seller,
    message: "Missing seller Business ID",
  )

  grid(
    columns: (1fr, 1fr),
    align: (left, right),
    gutter: 2em,

    grid.cell(align: top)[
      = #translate("invoice") \##invoice-number
      #date.display()
    ],

    grid.cell(align: top, logo),

    grid.cell(align: bottom, legal-entity(recipient, translate("purchaser"))),

    grid.cell(align: bottom, legal-entity(seller, translate("seller"))),
  )
}
