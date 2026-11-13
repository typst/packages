// Checks for theme tokens, beside the tokens they check (`theme.typ`):
// a theme (`altacv.with(theme: ..)`) and the preferences that override
// standalone `alta()`'s tokens (`font`, the internal `colours`) may set
// any of `_tokens`, any subset, each of its default's kind.

#import "../util/checks.typ": (
  _check, _check-keys, _check-type, _list-rule, _type-rule,
)
#import "theme.typ": _tokens

// A family name, or a fallback list of names / `(name, covers)` dicts.
// A dictionary entry is Typst's `(name: …, covers: …)`; a stray key,
// or a missing or non-string `name`, would otherwise fail only at
// `set text`.
#let _is-font-entry(f) = (
  type(f) == str
    or (
      type(f) == dictionary
        and type(f.at("name", default: none)) == str
        and f.keys().all(k => k in ("name", "covers"))
    )
)
#let _is-font-list(v) = (
  type(v) == array and v.len() > 0 and v.all(_is-font-entry)
)
#let _is-font(v) = type(v) == str or _is-font-list(v)

// Only a colour supports `lighten` / `darken`; a palette name string
// is the common slip.
#let _colour-rule = _type-rule(
  (color,),
  "a colour (e.g. rgb(\"#1A3A6C\"))",
)

#let _font-rule = (_is-font, "a font family name or a non-empty array of them")
// Typst's weight names, or a number from 100 to 900, as `text` takes.
#let _weight-names = (
  "thin",
  "extralight",
  "light",
  "regular",
  "medium",
  "semibold",
  "bold",
  "extrabold",
  "black",
)
#let _weight-rule = (
  v => v in _weight-names or (type(v) == int and v >= 100 and v <= 900),
  "a font weight (\"regular\", \"bold\", … or 100 to 900)",
)
// The scales: sizes, leading and strokes must be positive; a space may
// be zero.
#let _positive-number-rule = (
  v => type(v) in (int, float) and v > 0,
  "a positive number",
)
#let _space-rule = (
  v => type(v) in (int, float) and v >= 0,
  "a number, zero or more",
)
// Joined into content, so a separator may be content or a symbol too
// (`[ | ]`, `sym.bullet`).
#let _separator-rule = _type-rule(
  (str, content, symbol),
  "a string, content or a symbol",
)

// Tokens whose rule isn't their default's kind, by the first segment
// of their path (`treatment`), else by its last (`weight`).
#let _token-rules = (
  font: _font-rule,
  treatment: _type-rule(
    (function,),
    "a function of the content (e.g. emph, strong, upper)",
  ),
  separator: _separator-rule,
  font-weight: _weight-rule,
  weight: _weight-rule,
  space: _space-rule,
)

// A token of `default`'s kind: a colour, a positive number, strings as
// many as its own (the citation's issue brackets), or a string.
#let _kind-rule(default) = if type(default) == color { _colour-rule } else if (
  type(default) in (int, float)
) { _positive-number-rule } else if type(default) == array {
  let (is-strings, _) = _list-rule((str,), "")
  (
    v => is-strings(v) and v.len() == default.len(),
    "an array of " + str(default.len()) + " strings",
  )
} else { _type-rule((str,), "a string") }

#let _token-rule(path, default) = _token-rules.at(
  path.first(),
  default: _token-rules.at(path.last(), default: _kind-rule(default)),
)

// `value` as overrides of `defaults` (some of `_tokens`, at `path`), any
// subset at any depth: no key `defaults` lacks, a dictionary where it
// has one, and each value by `_token-rule`. `prefix` leads the path in
// messages (`theme.type.title.size`).
#let _check-tokens(value, defaults, prefix, path: ()) = {
  let name(at) = ((prefix,) + at).filter(s => s != "").join(".")
  _check-keys(name(path), value, defaults.keys())
  for (key, v) in value {
    let at = path + (key,)
    let default = defaults.at(key)
    if type(default) == dictionary {
      _check-tokens(v, default, prefix, path: at)
    } else { _check(name(at), v, _token-rule(at, default)) }
  }
}

// `altacv`'s `theme`, checked: `_tokens` overrides, any of them.
#let _checked-theme(theme) = {
  _check-type("theme", theme, (dictionary,), "a theme (e.g. themes.altacv)")
  _check-tokens(theme, _tokens, "theme")
  theme
}
