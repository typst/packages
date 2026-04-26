#import "error-handling.typ": check-required-argument
#import "metadata-with-id.typ": get-metadata, id-metadata, metadata-with-id
#import "tag.typ": tag

#let get-notes(body) = {
  check-required-argument(get-notes, body, "body", content)

  let notes = get-metadata(
    body
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
    panic(repr(get-notes) + " called on file with no note metas:\n" + repr(body))
  }

  return notes
}

#let matching-note(query, note) = {
  check-required-argument(matching-note, query, "query", arguments)
  check-required-argument(matching-note, note, "note", dictionary)

  let (qnamed, mnamed) = (query.named(), note.meta.named())
  let (qpos, mpos) = (query.pos(), note.meta.pos())
  
  return qnamed.keys().all(qkey => {
    mnamed.keys().contains(qkey) and mnamed.at(qkey) == qnamed.at(qkey)
  }) and qpos.all(qval => {
    mpos.contains(qval)
  })
}

#let make-note(
  root: bool,
  meta: arguments,
  formatter: function,
  body: content,
) = {
  check-required-argument(make-note, root, "root", bool)
  check-required-argument(make-note, meta, "meta", arguments)
  check-required-argument(make-note, formatter, "formatter", function)
  check-required-argument(make-note, body, "body", content)

  show: formatter.with(
    root: root,
    meta: meta,
  )
  [
    #id-metadata(
      tag("note"),
      (
        meta: meta,
        body: make-note.with(
          root: root,
          meta: meta,
          formatter: formatter,
          body: body,
        )
      ),
    )
    #label(repr(meta))
  ]
  body
}

#let as-branch(body) = {
  check-required-argument(as-branch, body, "body", content)

  return (get-notes(body).first().body)(root: false)
}
