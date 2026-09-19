#let get-column-metadata(data, column-order) = {
  let layout = data.layout-information

  let cols = ()
  let active-keys = ()

  // Left fixed columns
  if layout.show-pos {
    cols.push(auto)
  }
  cols.push(1fr) // Description

  let available-cols = (
    "quantity": layout.show-quantity,
    "unit-price": layout.show-unit-price,
    "tax-rate": layout.show-tax-rates,
    "total-price": layout.show-total-price,
  )

  for key in column-order {
    if available-cols.at(key, default: false) {
      cols.push(auto)
      active-keys.push(key)
    }
  }

  let total-cols = cols.len()
  let colspan-left = if layout.show-pos { 1 } else { 0 }
  let desc-idx = colspan-left

  let total-price-idx = active-keys.position(k => k == "total-price")
  let abs-total-idx = if total-price-idx != none {
    desc-idx + 1 + total-price-idx
  } else {
    none
  }

  let abs-percent-idx = if total-price-idx != none and total-price-idx > 0 {
    abs-total-idx - 1
  } else {
    none
  }

  (
    cols: cols,
    active-keys: active-keys,
    total-count: total-cols,
    desc-idx: desc-idx,
    total-idx: abs-total-idx,
    percent-idx: abs-percent-idx,
    left-count: colspan-left,
  )
}
