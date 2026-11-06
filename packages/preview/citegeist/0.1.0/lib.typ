

#let load-bibliography(bibtex_string) = {
  let p = plugin("citegeist.wasm")
  let serialized = p.get_bib_map(bytes(bibtex_string))
  let bib_map = cbor(serialized)

  bib_map
}

