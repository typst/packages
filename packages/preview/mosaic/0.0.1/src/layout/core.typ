// Shared record shape and validation primitives for semantic layouts.
#import "../shared.typ": (
  tag, fail, validate-keys, is-path, validate-scrim,
)

#let layout-field-keys = (
  content: ("columns", "tracks", "variant"),
  image: ("caption", "fit", "image", "tracks", "variant"),
  title: (
    "accent", "authors", "date", "image", "position", "rule", "subtitle",
    "title", "tracks", "variant",
  ),
  section: (
    "accent", "image", "number", "subtitle", "tracks", "variant",
  ),
)

#let make-layout(name, fields) = (
  mosaic: tag,
  kind: "layout",
  name: name,
  fields: fields,
)

#let validate-accent(fields, name, allow-auto: false) = {
  if type(fields.accent) != color and not (allow-auto and fields.accent == auto) {
    fail("layout " + repr(name) + " accent must be a color")
  }
  fields
}

#let validate-variant(value, allowed, name) = {
  if type(value) != str or value not in allowed {
    fail(
      name + " has unsupported variant " + repr(value)
        + "; expected one of " + repr(allowed),
    )
  }
  value
}

#let is-layout(value) = if (
  type(value) != dictionary
    or value.keys().sorted()
      != ("fields", "kind", "mosaic", "name")
    or value.mosaic != tag
    or value.kind != "layout"
    or type(value.name) != str
    or value.name not in layout-field-keys
    or type(value.fields) != dictionary
) {
  false
} else {
  value.fields.keys().sorted() == layout-field-keys.at(value.name)
}


// The fitting vocabulary Mosaic validates, shared by every place a picture
// dictionary is checked so the spelling cannot drift. Native `image` also accepts
// `"stretch"`; a design that truly wants distortion passes ready-made content
// built on the native element instead.
#let image-fit-modes = ("cover", "contain")

#let validate-image(
  value,
  name,
  allow-size: true,
) = {
  if type(value) == content {
    return value
  }
  let value = if is-path(value) {
    (path: value)
  } else if type(value) == dictionary {
    value
  } else {
    fail(
      name
        + " must be content, a non-empty path string, a native path, or a path dictionary",
    )
  }
  let allowed = if allow-size {
    ("path", "alt", "width", "height", "fit", "scrim")
  } else {
    ("path", "alt", "fit", "scrim")
  }
  _ = validate-keys(value, allowed, name)
  if "path" not in value or not is-path(value.path) {
    fail(name + " path must be a non-empty string or native path")
  }
  let alt = value.at("alt", default: none)
  if alt != none and type(alt) != str {
    fail(name + " alt must be a string or none")
  }
  let fit = value.at("fit", default: "cover")
  if type(fit) != str or fit not in image-fit-modes {
    fail(name + " fit must be \"cover\" or \"contain\"")
  }
  _ = validate-scrim(value.at("scrim", default: none), name)
  value
}
