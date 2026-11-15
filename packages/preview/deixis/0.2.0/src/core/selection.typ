#import "query.typ": _deixis-pin-index, _deixis-select-pins

// A scalar selects one literal name; an array is a union, including the empty
// union. Normalize once before traversing records or claiming printer ownership.
#let _deixis-selection-filter(value, name, allow-auto: true) = {
  assert((allow-auto and value == auto) or type(value) == str or
    (type(value) == array and value.all(item => type(item) == str)),
    message: "deixis: " + name + " must be " + if allow-auto {
      "auto, a string, or an array of strings."
    } else { "a string or an array of strings." })
  if type(value) == str { (value,) } else { value }
}

#let _deixis-selection-matches(value, filter) = filter == auto or value in filter

// Both collection consumers use strict native source-order boundaries. Strings
// and records select pins; labels retain their native document-label meaning.
// Native selectors keep their existing first-match behavior too.
#let _deixis-selection-boundaries(after, before, pins: none) = {
  let needs-pins = (after, before).any(value => type(value) in (str, dictionary))
  let pins = if needs-pins and pins == none { _deixis-pin-index() } else { pins }
  let resolve(value, name) = {
    assert(value == none or type(value) in (location, label, str, dictionary, selector, function),
      message: "deixis: Collection boundary " + name + " must be none, a location, a native label/selector/element function, or a pin name/record.")
    if value == none or type(value) == location { return value }
    if type(value) in (str, dictionary) {
      return _deixis-select-pins(pins, value, default: "first", single: true, required: true).first().location()
    }
    let matches = query(value)
    assert(matches.len() > 0,
      message: "deixis: No document element matches " + repr(value) + " for collection boundary " + name + ".")
    matches.first().location()
  }
  (after: resolve(after, "after"), before: resolve(before, "before"))
}
