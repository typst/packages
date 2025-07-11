#import "/src/utils/formatter.typ": formatter

#let item_row(data) = {
  (
    [#data.description],
    [#formatter("{:.2}", data.unit_price_without_vat)],
    [#data.quantity],
    [#formatter("{:.2}", data.vat_rate * 100)],
    [#formatter("{:.2}", data.total_price)],
  )
}
