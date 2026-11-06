#import "/src/utils/translate.typ": translate
#import "/src/components/item-row.typ": item-row
#import "/src/config.typ": CURRENCY, DEFAULT-COLORS

#let item-list(items, colors: DEFAULT-COLORS) = {
  table(
    columns: 5,
    align: (left, right, right, right, right),
    fill: (_, y) => if calc.even(y) and y > 0 {
      colors.bg-passive
    },
    stroke: none,
    inset: (x: 0.75em, y: 0.5em),

    table.header(
      translate("item"),
      [#translate("unit-price-without-vat")~(#CURRENCY)],
      translate(
        "quantity",
      ),
      [#translate("vat")~(%)],
      [#translate("price-with-vat")~(#CURRENCY)],
    ),
    table.hline(stroke: colors.active),

    ..for item in items {
      item-row(item)
    },
  )
}
