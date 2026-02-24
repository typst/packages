#import "error-handling.typ": check-required-argument
#import "tag.typ": tag
#import "metadata-with-id.typ": get-metadata, id-metadata, metadata-with-id
#import "note.typ": matching-note, get-notes

#let xlink(..args) = {
  let body = args.pos().last()
  let meta = arguments(..args.named(), ..args.pos().slice(0, -1))

  return id-metadata(tag("xlink"), (meta, body))
}

#let resolve-xlink(include-from-vault, note-paths, body, target) = {
  check-required-argument(resolve-xlink, include-from-vault, "include-from-vault", function)
  check-required-argument(resolve-xlink, note-paths, "note-paths", array)
  check-required-argument(resolve-xlink, body, "body", content)
  check-required-argument(resolve-xlink, target, "target", arguments)

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
    panic(
      "xlinks should match at most a single note in the current document, but this xlink matched " + str(local-matches.len()) + "." +
      "\nTarget: " + repr(target)
    )
  }
  if local-matches.len() == 1 {
    return label(repr(local-matches.first().meta))
  }

  let global-matches = note-paths.map(path => {
    (path, get-notes(include-from-vault(path)).first())
  }).filter(path--note => {
    matching-note(target, path--note.last())
  }).map(path--note => {
    path--note.first()
  })

  if global-matches.len() != 1 {
    panic(
      "xlinks should match a single note in the vault, but this xlink matched " + str(global-matches.len()) + "." +
      "\nTarget: " + repr(target)
    )
  }
  return global-matches.first().trim(".typ", at: end) + ".pdf"
}

#let format-xlinks(include-from-vault, note-paths, body, root: false, ..sink) = {
  check-required-argument(format-xlinks, include-from-vault, "include-from-vault", function)
  check-required-argument(format-xlinks, note-paths, "note-paths", array)
  check-required-argument(format-xlinks, body, "body", content)
  check-required-argument(format-xlinks, root, "root", bool)

  if not root {
    return body
  }

  show metadata: metadata => {
    if not metadata-with-id(metadata) or metadata.value.id != tag("xlink") {
      return metadata
    }

    let (target, link-body) = metadata.value.data
    let matching-location = resolve-xlink(include-from-vault, note-paths, body, target)
    return link(matching-location, link-body)
  }

  body
}
