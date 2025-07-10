#import "/src/utils/formatter.typ": formatter

#let vat_row(vat_rate, vat, total_with_vat, total_without_vat) = {
  (
    [#formatter("{:.2}", vat_rate * 100)],
    [#formatter("{:.2}", total_without_vat)],
    [#formatter("{:.2}", vat)],
    [#formatter("{:.2}", total_with_vat)],
  )
}
