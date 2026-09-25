/// Deterministic BCP 47 locale-ID casting and vendor code mapping.
///
/// Typst port of the cbcp Rust crate: the same `tests/vectors/*.json`
/// contract. Case mapping is ASCII-gated (like cgreet's Typst facade) so
/// non-ASCII input passes through untouched; trimming uses the explicit
/// six-character ASCII set, never the default Unicode trim.

// Explicit trim set: space, tab, LF, CR, VT, FF — plus CRLF, which Unicode
// segmentation yields as a single grapheme cluster.
#let _ws = (" ", "\t", "\n", "\r", "\u{0B}", "\u{0C}", "\r\n")

#let _join(arr, sep) = if arr.len() == 0 { "" } else { arr.join(sep) }

#let _trim-ws(s) = {
  let cs = s.clusters()
  let a = 0
  while a < cs.len() and cs.at(a) in _ws { a += 1 }
  let b = cs.len()
  while b > a and cs.at(b - 1) in _ws { b -= 1 }
  if a >= b { "" } else { _join(cs.slice(a, b), "") }
}

#let _lower-ascii(s) = {
  _join(s.clusters().map(c => if c >= "A" and c <= "Z" { lower(c) } else { c }), "")
}

#let _upper-ascii(s) = {
  _join(s.clusters().map(c => if c >= "a" and c <= "z" { upper(c) } else { c }), "")
}

/// Normalize an explicit locale ID: trim ASCII whitespace, `_` → `-`,
/// ASCII lowercase. No inference, no fallback, no validation.
#let normalize-locale-id(input) = {
  _lower-ascii(_trim-ws(input.replace("_", "-")))
}

#let _bcp47-subtag(first, subtag) = {
  if first { _lower-ascii(subtag) }
  else if subtag.len() == 4 and subtag.match(regex("^[A-Za-z]+$")) != none {
    _upper-ascii(subtag.slice(0, 1)) + _lower-ascii(subtag.slice(1))
  } else if (
    (subtag.len() == 2 and subtag.match(regex("^[A-Za-z]+$")) != none)
      or (subtag.len() == 3 and subtag.match(regex("^[0-9]+$")) != none)
  ) {
    _upper-ascii(subtag)
  } else {
    _lower-ascii(subtag)
  }
}

/// Project into BCP 47 display casing: `EN_CH` → `en-CH`.
#let to-bcp47(code) = {
  normalize-locale-id(code).split("-").enumerate().map(((i, s)) => _bcp47-subtag(i == 0, s)).join("-")
}

/// Base ISO 639 language, lowercased: `DE-CH` → `de`.
#let base-language(code) = {
  _lower-ascii(normalize-locale-id(code).split("-").at(0, default: ""))
}

/// Structural well-formedness only; no registry involved.
#let is-well-formed(code) = {
  code.match(regex("^[A-Za-z]{2,3}(-[A-Za-z0-9]{2,8})*$")) != none
}

/// Case- and separator-insensitive locale equality.
#let locale-eq(a, b) = normalize-locale-id(a) == normalize-locale-id(b)

/// DeepL source code: uppercase base. `de-CH` → `DE`.
#let deepl-source(code) = _upper-ascii(base-language(code))

#let _deepl-defaults = (
  "en": "EN-GB",
  "en-gb": "EN-GB",
  "en-us": "EN-US",
  "pt": "PT-PT",
  "pt-br": "PT-BR",
  "zh": "ZH-HANS",
)

/// DeepL target code; unmapped codes fall back to the uppercase base.
#let deepl-target(code) = {
  _deepl-defaults.at(normalize-locale-id(code), default: _upper-ascii(base-language(code)))
}

/// Google language code: lowercase base. `de-CH` → `de`.
#let google-language(code) = base-language(code)
