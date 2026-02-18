#import "/src/components/vat-row.typ": vat-row
#import "/src/utils/translate.typ": translate
#import "/src/utils/vat-calculation.typ": get-sum-row, preprocess
#import "/src/config.typ": CURRENCY, DEFAULT-COLORS, FONT-SIZES

/// -> content
#let vat-section(items, colors: DEFAULT-COLORS) = {
  let result = preprocess(items)
  let sum-row = get-sum-row(result)

  set text(size: FONT-SIZES.SMALL)

  table(
    columns: 4,
    inset: 0.5em,
    align: (right, right, right, right),
    stroke: none,

    table.header(
      [#translate("vat")~(%)],
      [#translate("price-without-vat")~(#CURRENCY)],
      [#translate("vat")~(#CURRENCY)],
      [#translate("price-with-vat")~(#CURRENCY)],
    ),
    table.hline(stroke: colors.passive),

    ..for entry in result {
      vat-row(..entry)
    },

    table.hline(stroke: colors.active),
    strong(translate("total")), ..sum-row.map(strong),
  )
}
