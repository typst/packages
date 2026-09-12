

#let load-bibliography(
  bibtex-string,
  keep-raw-names: true,
  sentence-case-titles: true,
  on-duplicate: "error",
  source: none,
) = {
  let p = plugin("citegeist.wasm")
  let raw-names-opt = if keep-raw-names { bytes((1,)) } else { bytes((0,)) }
  let sentence-opt = if sentence-case-titles { bytes((1,)) } else { bytes((0,)) }
  let source-opt = if source == none { bytes(()) } else { bytes(source) }

  // on-duplicate: "error" (0, default) / "keep-first" (1) / "keep-last" (2)
  let dup-opt = bytes((
    if on-duplicate == "keep-first" { 1 }
    else if on-duplicate == "keep-last" { 2 }
    else { 0 },
  ))

  let serialized = p.get_bib_map(bytes(bibtex-string), raw-names-opt, sentence-opt, dup-opt, source-opt)
  let bib-map = cbor(serialized)

  bib-map
}
