#let config = state("__alexandria-config", (
  citations: (:),
  read: none,
))
#let bibliographies = state("__alexandria-bibliographies", (:))

#let set-read(read) = config.update(x => {
  x.read = read
  x
})

#let read(data) = {
  if type(data) == bytes {
    (path: none, data: str(data))
  } else if type(data) == str {
    let read = config.get().read
    assert.ne(read, none, message: "Alexandria is not configured. Make sure to use `#show: alexandria(...)`")
    (path: data, data: read(data))
  } else {
    panic("parameter must be a path string or data bytes")
  }
}

#let register-prefix(..prefixes) = {
  assert.eq(prefixes.named().len(), 0)
  let prefixes = prefixes.pos()

  config.update(x => {
    for prefix in prefixes {
      x.citations.insert(prefix, ())
    }
    x
  })

  bibliographies.update(x => {
    for prefix in prefixes {
      x.insert(prefix, none)
    }
    x
  })
}

#let get-citation-index(prefix) = config.get().citations.at(prefix).len()

#let add-citation(prefix, citation) = config.update(x => {
  x.citations.at(prefix).push(citation)
  x
})

#let get-only-prefix() = {
  let citations = config.get().citations
  if citations.len() != 1 {
    return none
  }
  citations.keys().first()
}

#let set-bibliography(prefix, hayagriva) = {
  let citations = config.final().citations.at(prefix)
  bibliographies.update(x => {
    if x.at(prefix) == none {
      x.at(prefix) = (prefix: prefix, ..hayagriva(citations))
    }
    x
  })
}

#let get-bibliography(prefix) = bibliographies.final().at(prefix)
#let get-citation(prefix, index) = get-bibliography(prefix).citations.at(index)
