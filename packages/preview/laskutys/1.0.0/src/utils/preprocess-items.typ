/// Converts monetary values to decimal and calculates various prices
///
/// -> array
#let preprocess-items(
  items,
  default-vat-rate,
) = {
  assert(type(default-vat-rate) == decimal)

  for item in items {
    if "vat-rate" in items {
      assert(
        type(item.vat-rate) in (str, decimal),
        message: "Use decimal or str in vat-rate of items",
      )
    }

    assert(
      type(item.unit-price) in (str, decimal, int),
      message: "Use decimal, str or int in unit-price of items",
    )
  }

  items.map(item => {
    let vat-rate = decimal(item.at("vat-rate", default: default-vat-rate))
    let quantity = decimal(item.quantity)
    let unit-price-with-vat = decimal(item.unit-price)
    let unit-price-without-vat = decimal(item.unit-price) / (1 + vat-rate)
    let total-price = quantity * unit-price-with-vat

    (
      description: item.description,
      vat-rate: vat-rate,
      total-price: total-price,
      unit-price-with-vat: unit-price-with-vat,
      unit-price-without-vat: unit-price-without-vat,
      quantity: quantity,
    )
  })
}
