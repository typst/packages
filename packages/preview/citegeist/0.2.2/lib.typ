

#let load-bibliography(bibtex-string, keep-raw-names: true, sentence-case-titles: true) = {
  let p = plugin("citegeist.wasm")
  let raw-names-opt = if keep-raw-names { bytes((1,)) } else { bytes((0,)) }
  let sentence-opt = if sentence-case-titles { bytes((1,)) } else { bytes((0,)) }
  let serialized = p.get_bib_map(bytes(bibtex-string), raw-names-opt, sentence-opt)
  let bib-map = cbor(serialized)

  bib-map
}
