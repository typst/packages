#import "../../core/vocabulary.typ"

#let emit = metadata

/// Walk sequences and styles, optionally descending into rendered bodies.
#let elements(body, deep: false) = {
  if type(body) == array {
    return body.map(elements.with(deep: deep)).flatten()
  }
  if type(body) != content { return () }
  // References and metadata are leaves; payloads and supplements are not bodies.
  if body.func() in (ref, emit) { return (body,) }
  let fields = body.fields()
  // Keep this hot path inline instead of calling a selector per element.
  let nested = if "children" in fields { fields.children } else if (
    (deep or "styles" in fields) and "child" in fields
  ) { fields.child } else if deep and "body" in fields { fields.body }
  if nested == none { (body,) } else { elements(nested, deep: deep) }
}

#let declarations(body, protocol, deep: false) = {
  let found = ()
  for element in elements(body, deep: deep) {
    if element.func() != emit { continue }
    let value = element.value
    if (
      type(value) == dictionary
        and value.at("protocol", default: none) == protocol
        and value.at("version", default: none) == 1
    ) { found.push(value) }
  }
  found
}

#let references(body) = {
  let found = ()
  for element in elements(body, deep: true) {
    if element.func() == ref { found.push(element) }
  }
  found
}

/// Remove the root label through sequences and styles, preserving other bodies.
#let without-root(body, id) = {
  if type(body) != content { return body }
  if body.func() == heading and body.at("label", default: none) == label(id) {
    return []
  }
  let fields = body.fields()
  if "children" in fields {
    return fields.children.map(it => without-root(it, id)).join()
  }
  if "styles" in fields and "child" in fields {
    return (body.func())(without-root(fields.child, id), fields.styles)
  }
  body
}

#let text-fragment(element) = (
  (space: " ", linebreak: "\n", parbreak: "\n").at(
    repr(element.func()),
    default: element.fields().at("text", default: repr(element)),
  )
)

/// Display enum payloads without imposing a vocabulary or a naming scheme.
#let display-value(value) = {
  if vocabulary.enum-value(value) { return display-value(value.value) }
  if type(value) == content {
    return elements(value, deep: true)
      .map(text-fragment)
      .map(display-value)
      .join()
  }
  if type(value) == array { return value.map(display-value).join(", ") }
  if type(value) in (str, label) { str(value) } else { repr(value) }
}
