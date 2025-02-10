#import "metadata-with-id.typ": get-metadata, id-metadata, metadata-with-id
#import "tag.typ": tag

#let get-notes(content) = {
  let notes = get-metadata(
    content
  ).filter(
    metadata-with-id
  ).map(metadata => {
    metadata.value
  }).filter(meta => {
    meta.id == tag("note")
  }).map(meta => {
    meta.data
  })

  if notes.len() == 0 {
    panic(repr(get-notes) + " called on file with no note metas:\n" + repr(content))
  }
  return notes
}

#let matching-note(query, note) = {
  let meta = note.meta
  return query.keys().all(qkey => {
    meta.keys().contains(qkey) and meta.at(qkey) == query.at(qkey)
  })
}

#let new-root(
  formatter: (),
  meta: (:),
  body,
) = {
  let formatter = formatter.with(meta: meta)
  let note-label = label(repr(meta))

  let inner-meta = id-metadata(
    tag("note"),
    (
      meta: meta,
      body: none,
    )
  )
  let outer-meta = id-metadata(
    tag("note"),
    (
      meta: meta,
      body: {
        show: formatter.with(root: false)
        [
          #inner-meta
          #note-label
        ]
        body
      },
    ),
  )

  show: formatter.with(root: true)
  [
    #outer-meta
    #note-label
  ]
  body
}

#let as-branch(content) = {
  return get-notes(content).first().body
}
