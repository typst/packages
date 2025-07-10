#import plugin("/rust_tools/rust_tools.wasm"): consolidate_vat
#import "/src/utils/call_wasm.typ": call_wasm
#import "/src/utils/formatter.typ": formatter

/// -> array
#let preprocess(items) = {
  let items = items.map(((vat_rate, total_price)) => (
    vat_rate,
    total_price,
  ).map(str))

  let result = call_wasm(consolidate_vat, items)
    .pairs()
    .sorted()
    .map(pair => pair.map(decimal))
    .map(((vat_rate, total_with_vat)) => {
      let total_without_vat = total_with_vat / (1 + vat_rate)
      let vat = total_with_vat - total_without_vat

      (vat_rate, vat, total_with_vat, total_without_vat)
    })

  result
}

#let get_sum_row(data) = {
  let vat = data.map(row => row.at(1)).sum()
  let total_with_vat = data.map(row => row.at(2)).sum()
  let total_without_vat = total_with_vat - vat

  (
    total_without_vat,
    vat,
    total_with_vat,
  ).map(x => formatter("{:.2}", x))
}
