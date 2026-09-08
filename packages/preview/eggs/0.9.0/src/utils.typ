#import "@preview/elembic:1.1.1" as e

#let auto-length = e.types.union(auto, length)

#let gen-get-function(it, ..args) = {
  for (field, default) in args.pos() {
    it.insert(
      "get-" + field,
      () => if it.at(field) == auto {
        default
      } else { it.at(field) }
    )
  }
  it
}

// in all text-type children,
// find `from` string and replace it with `to` content
// returning an array of content 
#let replace-text-with-content(it, from: " ", to: [ ]) = {
  if it.has("text") {
    it.text.split(from).map(text).intersperse(to)
  } else {
    (it,)
  }
}

// split content on `separator`s and `text-separator`s
#let split-content(it, separator: [ ], text-separator: " ") = {
  if type(it) == array {
    return it
  }
  assert(type(it) == content)

  // replace text separator with separator
  let replace-text-with-content = replace-text-with-content.with(from: text-separator, to: separator)
  let text-split = if text-separator == none {
    it.at("children", default: (it,))
  } else if it.has("children") {
    it.children.map(replace-text-with-content)
  } else {
    // one-word line
    replace-text-with-content(it)
  }

  // split on separator
  text-split.flatten().split(separator).filter(it => it != ()).map([].func())
}

// given a sequence,
// remove the initial space element
// or any initial spaces from the first element
#let trim-space(it) = {
  if type(it) == content {
    let (head, tail) = if it.has("children") {
      (it.children.first(), it.children.slice(1).join())
    } else {
      (it, [])
    }
    if type(head) == content {
      if head.func() == [ ].func() {
        return tail
      } else if head.func() == text {
        return text(head.text.trim(at: start)) + tail
      }
    }
  }
  return it
}

#let is-html() = "html" in dictionary(std) and target() == "html"

#let prefix = "eggs07"

// -> dictionary
#let html-style(..args) = {
  let parse-val(val) = (
    if type(val) == array {val.map(parse-val).join(" ")}
    // TODO: figure out a smarter way to pass lengths
    else if type(val) == length {repr(val)}
    else {str(val)}
  )

  args.named().filter(it => it != none).pairs().map(((key, val)) => {
    key + ": " + parse-val(val)
  }).join("; ")
}

// -> (:) | (style: ...)
#let html-style-maybe(none_: (:), basic: (:), full: (:), level: "full") = {
  assert(level in ("full", "basic", "none", auto), message: "`level` must be one of \"full\", \"basic\", and \"none\".")

  let style = html-style(
    ..(none_ + if level in ("basic", "full") {basic} + if level == "full" {full})
  )

  if style != none {(style: style)} else {(:)}
}

#let html-height(h) = if type(h) == length {h - 0.65em} else {h}
