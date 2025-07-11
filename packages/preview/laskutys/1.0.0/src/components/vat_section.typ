#import "/src/components/vat_row.typ": vat_row
#import "/src/utils/translate.typ": translate
#import "/src/utils/vat_calculation.typ": get_sum_row, preprocess
#import "/src/config.typ": CURRENCY, DEFAULT_COLORS, FONT_SIZES

/// -> content
#let vat_section(items, colors: DEFAULT_COLORS) = {
  let result = preprocess(items)
  let sum_row = get_sum_row(result)

  set text(size: FONT_SIZES.SMALL)

  table(
    columns: 4,
    inset: 0.5em,
    align: (right, right, right, right),
    stroke: none,

    table.header(
      [#translate("vat")~(%)],
      [#translate("price_without_vat")~(#CURRENCY)],
      [#translate("vat")~(#CURRENCY)],
      [#translate("price_with_vat")~(#CURRENCY)],
    ),
    table.hline(stroke: colors.passive),

    ..for entry in result {
      vat_row(..entry)
    },

    table.hline(stroke: colors.active),
    strong(translate("total")), ..sum_row.map(strong),
  )
}
