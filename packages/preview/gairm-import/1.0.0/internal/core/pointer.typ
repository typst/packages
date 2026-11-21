// RFC 6901 JSON Pointer: the public path <-> pointer pair, and below
// it the reading the translator's `$ref` needs (percent-decoding a URI
// fragment, looking a path up in a document). Schema paths
// (`("basics", "email")`) and validator error reports (`("work",
// 0, "highlights", 1)`) <-> the "/basics/email" / "/work/0/
// highlights/1" form external tooling (editor extensions, schema
// linters, JSON Schema doc generators) expects.
//
// Two kinds of path share the same encoder:
//   - Validator error paths address INTO data (str keys, non-negative
//     int indices) and encode to a real RFC 6901 pointer a data-aware
//     tool can dereference.
//   - Schema paths address INTO a schema, in this
//     package's own segments (`"items"`, `"additionalProperties"`,
//     `"not"`, `"if"` / `"then"` / `"else"`, an int union index) and
//     with no `properties` segment,
//     so they encode segment for segment: `("work", "items")` is
//     `/work/items`. That is neither a data pointer nor a JSON Schema
//     location (`/properties/work/items`).
// The encoder doesn't distinguish; the caller knows which path it has.
//
// Encoding accepts str (object key) or int (non-negative array
// index) segments; other types and negative ints panic. Decoding
// parses tokens matching JSON Pointer's array-index ABNF (`0` |
// `[1-9][0-9]*`) back to int; everything else stays str.
//
// Round-trip directions are asymmetric:
//   - pointer → path → pointer is lossless for any well-formed
//     pointer (the new path's segment types are determined by the
//     decode regex, and the encoder reproduces the same bytes).
//   - path → pointer → path is lossless EXCEPT when a str segment
//     looks like an array index (e.g. `("0",)` decodes back as
//     `(0,)`). Data paths do carry such keys (a `"2024"` key in a
//     year-keyed object), so a decoded path is not always the one
//     encoded, though both name the same place in the document.

#import "error.typ": _fail, _problem

// Order matters. Encode `~` first, so its pass doesn't rewrite the
// `~1` the `/` pass writes. Decode (_read-pointer) mirrors it: `~1` before
// `~0`, so `~01` decodes to `~1`; `~0` first would turn it into `~1`
// and then `/`.
#let _escape-token(s) = s.replace("~", "~0").replace("/", "~1")

// RFC 6901 only defines two escape sequences: `~0` and `~1`. A
// bare `~` or any `~<other>` is malformed and rejected — silently
// passing it through would mask round-trip bugs in callers.
#let _invalid-escape-re = regex("~($|[^01])")

// RFC 6901 array-index ABNF: `0` | `[1-9][0-9]*` — leading zeros
// (other than "0" itself) aren't valid array indices, so e.g. "01"
// round-trips as the string "01" rather than becoming int 1. An index
// past Typst's 64-bit int stays a string too, rather than overflowing.
#let _int-token-re = regex("^(0|[1-9][0-9]*)$")
#let _int-max = str(9223372036854775807)
#let _try-int(token) = if (
  token.match(_int-token-re) != none
    and (
      token.len() < _int-max.len()
        or (token.len() == _int-max.len() and token <= _int-max)
    )
) {
  int(token)
} else { token }

// The path a pointer starting with "/" names, as `(path, bad)`: `bad`
// is the first token with an escape RFC 6901 does not define (and
// `path` none), or none. Each caller words a bad escape its own way.
#let _read-pointer(pointer) = {
  let tokens = pointer.slice(1).split("/")
  let bad = tokens.find(t => t.match(_invalid-escape-re) != none)
  if bad != none { return (path: none, bad: bad) }
  let path = tokens.map(t => _try-int(t.replace("~1", "/").replace("~0", "~")))
  (path: path, bad: none)
}

/// Writes a path as an RFC 6901 JSON Pointer: `("basics", "email")`
/// becomes `"/basics/email"`. `()` becomes `""`. Panics on a segment that
/// is not a `str` or a non-negative `int`.
///
/// - path (array): Field names and array indices.
/// -> str
#let path-to-pointer(path) = {
  if type(path) != array {
    _fail("path-to-pointer", _problem(
      "path",
      "an array of keys and indices",
      repr(path),
    ))
  }
  if path.len() == 0 { return "" }
  let parts = path.map(seg => {
    if type(seg) == str { return _escape-token(seg) }
    // RFC 6901's array-index ABNF is non-negative only: "/-1" would
    // read back as the string "-1", breaking the round trip
    // REFERENCE.md promises.
    if type(seg) != int or seg < 0 {
      _fail("path-to-pointer", _problem(
        "path segment",
        "a string or a non-negative integer (an RFC 6901 array index)",
        repr(seg),
      ))
    }
    str(seg)
  })
  "/" + parts.join("/")
}

/// Reads an RFC 6901 JSON Pointer as a path: `"/work/0/highlights/1"`
/// becomes `("work", 0, "highlights", 1)`. `""` becomes `()`, and `"/"`
/// the one empty-string key, `("",)`. Panics on a
/// pointer that does not start with `/` or has a bad `~` escape.
///
/// - pointer (str): The pointer.
/// -> array
#let pointer-to-path(pointer) = {
  if type(pointer) != str {
    _fail("pointer-to-path", _problem("pointer", "a string", repr(pointer)))
  }
  if pointer == "" { return () }
  if not pointer.starts-with("/") {
    _fail("pointer-to-path", _problem(
      "pointer",
      "\"\" or a pointer starting with \"/\"",
      repr(pointer),
      // A $ref's URI fragment: `#/definitions/a`.
      hint: if pointer.starts-with("#") {
        " Drop the \"#\" a URI fragment starts with."
      },
    ))
  }
  let read = _read-pointer(pointer)
  if read.bad != none {
    _fail("pointer-to-path", _problem(
      "pointer token",
      "escaped only as RFC 6901 allows, `~0` (tilde) and `~1` (slash)",
      repr(read.bad),
    ))
  }
  read.path
}

// RFC 3986 percent-decoding of a `$ref` fragment, as UTF-8; none when
// a `%` is not followed by two hex digits or the bytes are not
// well-formed UTF-8 (RFC 3629).
#let _hex-digits = "0123456789abcdef"
#let _utf8-length(lead) = if lead < 0x80 { 1 } else if (
  lead >= 0xC2 and lead < 0xE0
) { 2 } else if lead >= 0xE0 and lead < 0xF0 { 3 } else if (
  lead >= 0xF0 and lead < 0xF5
) { 4 }
// The range a lead byte's second byte must fall in (RFC 3629 §4), as
// (low, high) inclusive: these leads narrow 0x80–0xBF to rule out an
// overlong encoding (E0, F0), a UTF-16 surrogate (ED) or a code point
// past U+10FFFF (F4), which `str(bytes(…))` would reject with a raw
// Typst error.
#let _second-byte-range(lead) = if lead == 0xE0 { (0xA0, 0xBF) } else if (
  lead == 0xED
) { (0x80, 0x9F) } else if lead == 0xF0 { (0x90, 0xBF) } else if (
  lead == 0xF4
) { (0x80, 0x8F) } else { (0x80, 0xBF) }
#let _percent-decode(s) = {
  if "%" not in s { return s }
  let parts = s.split("%")
  let out = array(bytes(parts.first()))
  for part in parts.slice(1) {
    let digits = part
      .codepoints()
      .slice(0, calc.min(2, part.codepoints().len()))
    let values = digits.map(d => _hex-digits.position(lower(d)))
    if values.len() < 2 or none in values { return none }
    out.push(values.at(0) * 16 + values.at(1))
    out += array(bytes(part.slice(2)))
  }
  let i = 0
  while i < out.len() {
    let n = _utf8-length(out.at(i))
    if n == none or i + n > out.len() { return none }
    if out.slice(i + 1, i + n).any(b => b < 0x80 or b >= 0xC0) { return none }
    if n > 1 {
      let (low, high) = _second-byte-range(out.at(i))
      if out.at(i + 1) < low or out.at(i + 1) > high { return none }
    }
    i += n
  }
  str(bytes(out))
}

// The value at `path` in `doc`, as `(value, missing)`: `missing` is the
// first segment that names nothing (and `value` none), or none. A
// segment names a key of an object (a numeric one too, as its string)
// or an index of an array.
#let _pointer-get(doc, path) = {
  let at = doc
  for seg in path {
    let key = if type(at) == dictionary { str(seg) } else { seg }
    let found = if type(at) == dictionary { key in at } else {
      type(at) == array and type(seg) == int and seg < at.len()
    }
    if not found { return (value: none, missing: seg) }
    at = at.at(key)
  }
  (value: at, missing: none)
}
