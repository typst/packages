// RFC 6901 JSON Pointer: the public path <-> pointer pair, and below
// it the reading the translator's `$ref` needs (percent-decoding a URI
// fragment, looking a path up in a document). Path tuples used by lenses
// (`("basics", "email")`) and validator error reports (`("work",
// 0, "highlights", 1)`) <-> the "/basics/email" / "/work/0/
// highlights/1" form external tooling (editor extensions, schema
// linters, JSON Schema doc generators) expects.
//
// Two kinds of path share the same encoder:
//   - Validator error paths address INTO data (str keys, non-negative
//     int indices) and encode to a real RFC 6901 pointer a data-aware
//     tool can dereference.
//   - Lens / introspect paths address INTO a schema, in this
//     package's own segments (`"items"`, `"additionalProperties"`,
//     `"not"`, an int union index) and with no `properties` segment,
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
//     `(0,)`). Validator + lens code never emit numeric strings, so
//     this isn't a concern in practice.

// Order matters: `~1` → `/` first would let an `~1` token round-
// trip wrong (e.g. `~01` should decode to `~1`, not `/0`). Encode
// `~` first so subsequent `/` encodes don't see the new `~0` we
// just introduced. Decode mirrors: `~1` before `~0`.
#import "error.typ": _bail

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

// Convert a path tuple to an RFC 6901 JSON Pointer string. Empty
// path → empty string (whole-document reference per spec).
/// Writes a path as an RFC 6901 JSON Pointer: `("basics", "email")`
/// becomes `"/basics/email"`. `()` becomes `""`. Panics on a segment that
/// is not a `str` or a non-negative `int`.
///
/// - path (array): Field names and array indices.
/// -> str
#let path-to-pointer(path) = {
  if path.len() == 0 { return "" }
  let parts = path.map(seg => {
    if type(seg) == str { _escape-token(seg) } else if type(seg) == int {
      // RFC 6901 array-index ABNF is non-negative only — emitting
      // "/-1" would round-trip back to the string "-1" (regex
      // rejects the minus sign), silently breaking the round-trip
      // property REFERENCE.md promises.
      if seg < 0 {
        _bail(
          "path-to-pointer",
          "expected a non-negative integer "
            + "(RFC 6901 array indices), got: "
            + str(seg)
            + ".",
        )
      }
      str(seg)
    } else {
      _bail(
        "path-to-pointer",
        "expected a str or int segment, got: "
          + repr(seg)
          + " ("
          + repr(type(seg))
          + ").",
      )
    }
  })
  "/" + parts.join("/")
}

// Inverse. Empty string → empty path. A bare "/" decodes to a
// single empty-string segment (RFC 6901: "/" means "the empty
// string key at root"). Otherwise the pointer must start with "/".
/// Reads an RFC 6901 JSON Pointer as a path: `"/work/0/highlights/1"`
/// becomes `("work", 0, "highlights", 1)`. `""` becomes `()`. Panics on a
/// pointer that does not start with `/` or has a bad `~` escape.
///
/// - pointer (str): The pointer.
/// -> array
#let pointer-to-path(pointer) = {
  if pointer == "" { return () }
  if not pointer.starts-with("/") {
    _bail(
      "pointer-to-path",
      "expected \"\" or a pointer starting with \"/\", got: "
        + repr(pointer)
        + ".",
    )
  }
  let read = _read-pointer(pointer)
  if read.bad != none {
    _bail(
      "pointer-to-path",
      "got an invalid escape sequence in token: "
        + repr(read.bad)
        + ". RFC 6901 only allows `~0` (tilde) and `~1` (slash).",
    )
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
