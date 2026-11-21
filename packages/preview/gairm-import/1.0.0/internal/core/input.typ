// The input forms every entry point shares. A path or bytes decodes as
// json() does; null is rejected; any other value, a string included,
// is returned as the value itself, whose root the schema judges.
//
// A string path (#132) resolves from the package root inside a package,
// so it could never find the caller's file. A string is still a value
// (a scalar schema such as string(format: "date") takes one), so
// validate, coerce and parse refuse it only when it looks like a path
// and the schema's root does not take it: _refuse-path, after the walk.
// The translator, whose input is never a string, refuses every one
// (`str-is-data` false).
#import "error.typ": _bail

// A string holding a JSON object or array: read() without
// `encoding: none` returns the file's text.
#let _looks-like-json(s) = s.trim().starts-with(regex("[{\\[]"))

#let _path-hint(fn-name, data) = _bail(
  fn-name,
  if _looks-like-json(data) {
    "does not take JSON text: decode it with json(bytes(..)), or read the file with read(.., encoding: none)."
  } else {
    let shown = repr(data)
    (
      "does not take a string path: inside a package it resolves from the package, not your project. Pass path("
        + shown
        + ") or json("
        + shown
        + ") instead."
    )
  },
)

// `null-ok` leaves a null for the caller's own type check, for a caller
// whose input is not a document root (a schema).
#let _decode-input(fn-name, data, str-is-data: false, null-ok: false) = {
  if type(data) == str and not str-is-data { _path-hint(fn-name, data) }
  let value = if type(data) in (path, bytes) { json(data) } else { data }
  if value == none and not null-ok {
    _bail(
      fn-name,
      "data must not be null: the document root has to be a value the schema accepts.",
    )
  }
  value
}

// A string that names a JSON file. Only a `.json` suffix counts, so no
// date, URI or free text reads as one.
#let _looks-like-path(s) = lower(s).ends-with(".json")

// Panics with the path(..) hint when `data` was a string that looks
// like a path, or JSON text, and the walk `r` over it found the wrong
// type at the root: the caller meant the file, not the string.
#let _refuse-path(fn-name, data, r) = {
  if (
    type(data) == str
      and r.errors.any(e => e.code == "type" and e.path == ())
      and (_looks-like-path(data) or _looks-like-json(data))
  ) { _path-hint(fn-name, data) }
}
