#let melt = plugin("./melt.wasm")

#let fonts-collection-info(data) = cbor(melt.fonts_collection_info(data))
#let font-info(data, index: 0) = fonts-collection-info(data).at(index)

#let contains(parsed-data, codepoint) = {
  let inside = false
  let cursor = 0
  let coverage = parsed-data.typst.coverage

  for run in coverage {
    if cursor <= codepoint and codepoint < cursor + run {
      return inside
    }
    cursor += run
    inside = not inside
  }
  false
}
