#import plugin("/rust_tools/rust_tools.wasm"): consolidate_vat
#import "/src/utils/call-wasm.typ": call-wasm
#import "/src/utils/formatter.typ": formatter

/// -> array
#let preprocess(items) = {
  let items = items.map(((vat-rate, total-price)) => (
    vat-rate,
    total-price,
  ).map(str))

  let result = call-wasm(consolidate_vat, items)
    .map(pair => pair.map(decimal))
    .map(((vat-rate, total-with-vat)) => {
      let total-without-vat = total-with-vat / (1 + vat-rate)
      let vat = total-with-vat - total-without-vat

      (vat-rate, vat, total-with-vat, total-without-vat)
    })

  result
}

#let get-sum-row(data) = {
  let vat = data.map(row => row.at(1)).sum()
  let total-with-vat = data.map(row => row.at(2)).sum()
  let total-without-vat = total-with-vat - vat

  (
    total-without-vat,
    vat,
    total-with-vat,
  ).map(x => formatter("{:.2}", x))
}
