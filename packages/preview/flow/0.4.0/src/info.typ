//! Typecheck infrastructure for metadata.
//!
//! There are keys that have a conventional shape.
//! For example, a content warning _should_ be a string or a set/list of strings,
//! but probably not a number, as that doesn't make semantic sense in that context.
//! This module verifies some of these conventions.

#import "effect.typ"
#import "palette.typ": *
#import "tyck.typ"
#import "util/small.typ": maybe-do

// Panics if known typo'd metadata fields are contained.
#let _check-typos(it) = {
  let typos = (
    "alias": "aliases",
    "aliase": "aliases",
    "content-warning": "cw",
    "content-warnings": "cw",
    "language": "lang",
  )

  for key in it.keys() {
    if key in typos.keys() {
      panic(
        "Key `"
          + key
          + "` passed to template metadata, which is marked as a typo. "
          + "You might meant to use `"
          + typos.at(key)
          + "` instead.",
      )
    }
  }
}

// TODO: add function that goes through value and converts it into a schema using the functions above

#let _schema = {
  import tyck: *
  _attrs(
    author: _any(str, _array(str)),
    cw: _any(str, _array(str)),
    lang: str,

    slug: str,
    aliases: _any(str, _array(str)),
    translation: _dict(str, _any(str, _array(str))),

    keywords: _any(
      // shorthand for bolding all listed keywords
      _array(str),
      // the explicit version which allows using any function for modification
      _dict(str, function),
    ),
    meta: _attrs(
      share: int,
      publish: bool,
      id: _any(str, int),
      creation: str,
    ),
  )
}

#let _check(it) = {
  _check-typos(it)
  tyck.validate(it, _schema)
}

// Puts some well-known metadata fields into an array if they stand alone.
// Returns the modified metadata.
#let _normalize(it) = {
  let arrayize = ("aliases", "author", "cw", "tags")

  for (name, data) in it {
    if type(data) != array and name in arrayize {
      it.at(name) = (data,)
    }
  }

  it
}

#let preprocess(it) = {
  _check(it)
  _normalize(it)
}

#let queryize(it) = [
  #metadata(it) <info>
]

#let _render-cw(data, _name, _render) = {
  par(leading: 1.5em, data.map(effect.invert).join(h(0.5em)))
}

#let _render-collection(data, name, render) = {
  if data.len() == 0 {
    return
  }

  // convert into an array of duplits with (key, value)
  let data = if type(data) == array {
    // just treat the index as key
    data.enumerate().map(((idx, value)) => (str(idx), value))
  } else if type(data) == dictionary {
    data.pairs()
  } else {
    panic("unknown collection type: `" + str(type(data)) + "`")
  }

  show: maybe-do(name != none, grid.cell.with(
    stroke: (
      left: (gamut.sample(20%)),
    ),
    inset: (y: 0.5em),
  ))

  grid(
    columns: 2,
    align: (right, left),
    inset: (x, y) => {
      if x == 0 {
        (right: 0.5em)
      } else {
        (left: 0.5em)
      }
    },
    row-gutter: 1em,
    ..data
      .map(((name, data)) => (
        fade(name),
        render(data, name: name),
      ))
      .join()
  )
}

#let _render-bool(data, _name, _render) = {
  if data {
    text(fill: status.idle)[true]
  } else {
    text(fill: status.urgent)[false]
  }
}

#let _render-id(data, _name, _render) = {
  fade[#data]
}

#let _render-fallback(data, _name, _render) = [#data]

/// Renders data in a best-effort pretty way. Returns opaque content.
/// Accepts dictionaries, lists, almost any data structure.
///
/// `ctx` is used for recursion, it is the most recent field key.
/// You can set it to denote the name this is in
/// for context but you don't need to.
#let render(data, name: none) = {
  let handler = if (
    name != none and "cw" in lower(name) and type(data) == array
  ) {
    _render-cw
  } else if type(data) in (array, dictionary) {
    _render-collection
  } else if type(data) == bool {
    _render-bool
  } else if name == "id" {
    _render-id
  } else {
    // content/int/string/function
    _render-fallback
  }

  handler(data, name, render)
}

