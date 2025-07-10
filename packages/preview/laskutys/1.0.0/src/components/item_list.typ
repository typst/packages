#import "/src/utils/translate.typ": translate
#import "/src/components/item_row.typ": item_row
#import "/src/config.typ": CURRENCY, DEFAULT_COLORS

#let item_list(items, colors: DEFAULT_COLORS) = {
  table(
    columns: 5,
    align: (left, right, right, right, right),
    fill: (_, y) => if calc.even(y) and y > 0 {
      colors.bg_passive
    },
    stroke: none,
    inset: (x: 0.75em, y: 0.5em),

    table.header(
      translate("item"),
      [#translate("unit_price_without_vat")~(#CURRENCY)],
      translate(
        "quantity",
      ),
      [#translate("vat")~(%)],
      [#translate("price_with_vat")~(#CURRENCY)],
    ),
    table.hline(stroke: colors.active),

    ..for item in items {
      item_row(item)
    },
  )
}
