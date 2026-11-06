#let masonry-wasm = plugin("./masonry-layout-helper.wasm")

#let calc-col-widths(
  width,
  aspect-ratio-sums,
  column-gutter-sum,
  row-gutter-sums,
) = {
  // convert `length`s to `pt` to be consistent with Rust data types
  let input-data = (
    width: width.to-absolute().pt(),
    aspect_ratios: aspect-ratio-sums,
    col_gap: column-gutter-sum.to-absolute().pt(),
    row_gaps: row-gutter-sums.map(item => item.to-absolute().pt()),
  )
  let input-bytes = cbor.encode(input-data)
  let result-bytes = masonry-wasm.masonry_col_widths(input-bytes)
  // convert back to lengths
  cbor(result-bytes).map(item => item * 1pt)
}
