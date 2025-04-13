#import "tag.typ": tag
#import "metadata-with-id.typ": get-metadata, id-metadata, metadata-with-id
#import "note.typ": matching-note, get-notes

#let xlink(body, ..meta) = {
  return id-metadata(tag("xlink"), (meta.named(), body))
}

#let resolve-xlink(include-from-vault, note-paths, body, target) = {
  let local-matches = get-metadata(body).filter(
    metadata-with-id
  ).map(metadata => {
    metadata.value
  }).filter(meta => {
    meta.id == tag("note")
  }).map(meta => {
    meta.data
  }).filter(note => {
    matching-note(target, note)
  })
  if local-matches.len() > 1 {
    panic(repr(resolve-xlink) + " should have no more than 1 local match, but has " + str(local-matches.len()))
  }
  if local-matches.len() == 1 {
    return label(repr(local-matches.first().meta))
  }

  let global-matches = note-paths.map(note-path => {
    (note-path, get-notes(include-from-vault(note-path)).first())
  }).filter(path--note => {
    matching-note(target, path--note.last())
  }).map(path--note => {
    path--note.first()
  })

  if global-matches.len() != 1 {
    panic(repr(resolve-xlink) + " should have exactly 1 match, but has " + str(global-matches.len()) + " instead")
  }
  return global-matches.first().trim(".typ", at: end) + ".pdf"
}

#let format-xlinks(include-from-vault, note-paths, body, root: false, ..sink) = {
  if not root {
    return body
  }

  show metadata: metadata => {
    if {
      not metadata-with-id(metadata)
    } or {
      metadata.value.id != tag("xlink")
    } {
      return metadata
    }

    let (target, link-body) = metadata.value.data
    let matching-location = resolve-xlink(include-from-vault, note-paths, body, target)
    return link(matching-location, link-body)
  }

  body
}
