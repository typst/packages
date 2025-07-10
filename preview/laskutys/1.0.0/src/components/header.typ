#import "/src/utils/translate.typ": translate
#import "/src/components/legal_entity.typ": legal_entity

/// -> content
#let header(
  invoice_number,
  date,
  recipient: none,
  seller: none,
  logo: none,
) = {
  assert(
    type(seller) == dictionary and "business_id" in seller,
    message: "Missing seller Business ID",
  )

  grid(
    columns: (1fr, 1fr),
    align: (left, right),
    gutter: 2em,

    grid.cell(align: top)[
      = #translate("invoice") \##invoice_number
      #date.display()
    ],

    grid.cell(align: top, logo),

    grid.cell(align: bottom, legal_entity(recipient, translate("purchaser"))),

    grid.cell(align: bottom, legal_entity(seller, translate("seller"))),
  )
}
