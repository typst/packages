/// Converts monetary values to decimal and calculates various prices
///
/// -> array
#let preprocess_items(
  items,
  default_vat_rate,
) = {
  assert(type(default_vat_rate) == decimal)

  for item in items {
    if "vat_rate" in items {
      assert(
        type(item.vat_rate) in (str, decimal),
        message: "Use decimal or str in vat_rate of items",
      )
    }

    assert(
      type(item.unit_price) in (str, decimal, int),
      message: "Use decimal, str or int in unit_price of items",
    )
  }

  items.map(item => {
    let vat_rate = decimal(item.at("vat_rate", default: default_vat_rate))
    let quantity = decimal(item.quantity)
    let unit_price_with_vat = decimal(item.unit_price)
    let unit_price_without_vat = decimal(item.unit_price) / (1 + vat_rate)
    let total_price = quantity * unit_price_with_vat

    (
      description: item.description,
      vat_rate: vat_rate,
      total_price: total_price,
      unit_price_with_vat: unit_price_with_vat,
      unit_price_without_vat: unit_price_without_vat,
      quantity: quantity,
    )
  })
}
