// convert dictionary to list
#let dict-values(d) = d.keys().map(k => d.at(k))


#let show-metadata(kind) = context {
  repr(
    query(selector(metadata))
      .filter(x => x.value.kind == kind)
  )
}
