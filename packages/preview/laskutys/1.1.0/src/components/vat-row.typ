#import "/src/utils/formatter.typ": formatter

#let vat-row(vat-rate, vat, total-with-vat, total-without-vat) = {
  (
    [#formatter("{:.2}", vat-rate * 100)],
    [#formatter("{:.2}", total-without-vat)],
    [#formatter("{:.2}", vat)],
    [#formatter("{:.2}", total-with-vat)],
  )
}
