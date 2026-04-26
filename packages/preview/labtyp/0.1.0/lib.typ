// State to track the current headings hierarchy
#let current-headings = state("current-headings", ())

// State for document metadata
#let document-metadata = state("document-metadata", (:))

// Function to update document metadata
#let mset(values: (:)) = {
  document-metadata.update(old => {
    let updated = old
    for (k, v) in values {
      updated.insert(k, v)
    }
    updated
  })
}

// Function to create a label with underlined text, footnote, and metadata
#let lab(key, text, note) = {
  context [
    #let meta = document-metadata.at(here())
    #underline(stroke: blue)[#text]#footnote[#key: #note]#hide[
      #metadata( meta + (
        key: key,
        text: text,
        note: note,
        page: counter(page).at(here()).first(),
      )) <lab>
    ]
  ]
}

// Function to list all labels in a table with hyperlinks
#let lablist() = {
  context {
    let labels = query(selector(<lab>))
    if labels.len() == 0 {
      [No labels found.]
    } else {
      table(
        columns: (auto, auto, auto, auto, auto, auto, auto, auto),
        [*Key*], [*Text*], [*Note*], [*Page*], [*Original Page*], [*Title*], [*Author*], [*Date*],
        ..labels.map(l => {
          let data = l.value
          (
            link(l.location(), data.at("key", default: [Undefined])),
            link(l.location(), data.at("text", default: [Undefined])),
            link(l.location(), data.at("note", default: [Undefined])),
            link(l.location(), str(data.at("page", default: 0))),
            link(l.location(), if data.at("page", default: none) != none { str(data.at("page")) } else { [Undefined] }),
            link(l.location(), data.at("title", default: [Undefined])),
            link(l.location(), data.at("author", default: [Undefined])),
            link(l.location(), data.at("date", default: [Undefined]))
          )
        }).flatten()
      )
    }
  }
}
