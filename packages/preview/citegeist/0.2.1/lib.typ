

#let load-bibliography(bibtex-string) = {
  let p = plugin("citegeist.wasm")
  let serialized = p.get_bib_map(bytes(bibtex-string))
  let bib-map = cbor(serialized)

  bib-map
}

