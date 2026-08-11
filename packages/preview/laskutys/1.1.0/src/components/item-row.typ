#import "/src/utils/formatter.typ": formatter

#let item-row(data) = {
  (
    [#data.description],
    [#formatter("{:.2}", data.unit-price-without-vat)],
    [#data.quantity],
    [#formatter("{:.2}", data.vat-rate * 100)],
    [#formatter("{:.2}", data.total-price)],
  )
}
