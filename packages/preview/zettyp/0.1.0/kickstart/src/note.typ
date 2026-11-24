#import "../../core/knowledge/lib.typ" as knowledge
#import "../../core/vocabulary.typ"
#import "metadata.typ": checked, metadata as make-metadata
#import "content.typ": declarations, elements, emit, references

// Ordinary references have a fixed protocol identity.
#let reference-color = vocabulary.register("relation", ref: <zk.ref>).ref

#let root-heading(body) = {
  let roots = elements(body).filter(it => {
    if it.func() != heading { return false }
    let level = it.at("level", default: auto)
    if level == auto { level = it.at("depth", default: none) }
    level == 1
  })
  assert.eq(
    roots.len(),
    1,
    message: "note requires exactly one level-one root heading",
  )
  let root = roots.first()
  assert(
    type(root.at("label", default: none)) == label,
    message: "note root heading requires a persistent label",
  )
  root
}

#let outgoing(body) = {
  let colored(body, color) = references(body).map(origin => (
    origin: origin,
    color: color,
  ))
  (
    colored(body, reference-color)
      + declarations(body, "zettyp.dependency", deep: true)
        .map(marker => colored(marker.body, marker.color))
        .flatten()
  )
}

/// Observe a note using the declared metadata schema.
#let read-note(schema, body, metadata: none) = {
  assert(type(body) == content, message: "note body must be content")
  let metadata = if metadata == none { make-metadata(schema) } else {
    checked(schema, metadata)
  }
  let root = root-heading(body)
  let id = str(root.label)
  let links = outgoing(body)
  assert(
    links.all(item => (
      vocabulary.enum-value(item.color)
        and vocabulary.contains(schema.registry, item.color)
    )),
    message: "note references require registered relation colors",
  )
  knowledge.local(
    id,
    value: metadata.value,
    // Protocol data and user metadata occupy separate namespaces.
    data: (title: root.body, metadata: metadata.data),
    origin: root,
    references: links
      .enumerate()
      .map(((index, item)) => knowledge.reference(
        str(id.len()) + ":" + id + "/ref/" + str(index),
        target: str(item.origin.target),
        value: (relation: item.color),
        origin: item.origin,
      )),
  )
}

/// Emit a declaration without rendering or loading other notes.
#let zettel(schema, metadata: () => none, body) = {
  assert(
    type(metadata) == function,
    message: "zettel metadata must be a configured function",
  )
  emit((
    protocol: "zettyp.note",
    version: 1,
    local: read-note(schema, body, metadata: metadata()),
    body: body,
  ))
}

#let observations(body) = declarations(body, "zettyp.note")
