#let config = state("__alexandria-config", (
  prefixes: (:),
  group-state: "none",
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
      x.prefixes.insert(prefix, (
        citations: (),
      ))
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

#let get-citation-info(prefix) = {
  let (prefixes, group-state) = config.get()
  let index = prefixes.at(prefix).citations.len()
  if group-state == "open" {
    // if a citegroup is open, the index is not the next one to be inserted,
    // but the already existing last one
    index -= 1
  }
  let group = group-state != "none"
  (index: index, group: group)
}

#let start-citation-group() = config.update(x => {
  assert.eq(
    x.group-state, "none",
    message: "can't start a citation group while one is open",
  )
  x.group-state = "initial"
  x
})

#let add-citation(prefix, citation) = config.update(x => {
  if x.group-state == "none" {
    // add a new citation group with only one element
    x.prefixes.at(prefix).citations.push((citation,))
  } else if x.group-state == "initial" {
    x.group-state = "open"
    // start the citation group with this citation
    x.prefixes.at(prefix).citations.push((citation,))
  } else {
    // add a citation to the currently open group
    x.prefixes.at(prefix).citations.last().push(citation)
  }
  x
})

#let end-citation-group() = config.update(x => {
  assert.ne(
    x.group-state, "none",
    message: "can't end a citation group while none is open",
  )
  // TODO doesn't work, because the citations are only later added through a show rule
  // assert.ne(
  //   x.group-state, "initial",
  //   message: "citation group must not be empty",
  // )
  x.group-state = "none"
  x
})

#let get-only-prefix() = {
  let prefixes = config.get().prefixes
  if prefixes.len() != 1 {
    return none
  }
  prefixes.keys().first()
}

#let set-bibliography(prefix, hayagriva) = {
  let config = config.final().prefixes.at(prefix)
  bibliographies.update(x => {
    if x.at(prefix) == none {
      x.at(prefix) = (prefix: prefix, ..hayagriva(config.citations))
    }
    x
  })
}

#let get-bibliography(prefix) = bibliographies.final().at(prefix)
#let get-citation(prefix, index) = {
  let body = get-bibliography(prefix).citations.at(index)
  let supplements = config.final().prefixes.at(prefix).citations.at(index)
    .map(citation => citation.supplement)

  (body: body, supplements: supplements)
}
