// Small text predicates, `custom.altacv` access, label templates and
// the `styled-link` helper. `_present` is the canonical "is this field
// set" check.

#import "state.typ": _accent_state

// The three ways a field can be effectively absent.
#let _present(v) = v != none and v != "" and v != []

// A field's value, or `none` when it's absent in any of those forms.
#let _field(obj, key) = {
  let v = obj.at(key, default: none)
  if _present(v) { v }
}

// A `references[]` entry's flag: only a real boolean counts, so a
// stray `"yes"` doesn't hide a quote.
#let _on_request(r) = r.at("availableOnRequest", default: false) == true

// A reference worth rendering: a quote, or the on-request flag.
#let _reference_usable(r) = _on_request(r) or _field(r, "reference") != none

// The non-`none` parts joined by `sep`; `none` when no part is left,
// so callers can skip the whole line.
#let _join_present(parts, sep) = parts.filter(p => p != none).join(sep)

#let _dict_or_empty(v) = if type(v) == dictionary { v } else { (:) }

// `(:)` when either level is missing or not a dictionary.
#let _altacv_ns(obj) = _dict_or_empty(
  _dict_or_empty(obj.at("custom", default: none)).at("altacv", default: none),
)

// One of altacv's non-spec fields (`focusAreas`, `languages[].rating`,
// `awards[].url`) from its own `custom` namespace (#242), on the CV
// root or an entry. `_canonical_cv` has already lifted the deprecated
// top-level forms there.
#let _altacv(obj, key, default: none) = _altacv_ns(obj).at(
  key,
  default: default,
)

// Stricter than `_present` where a plain string is required (PDF
// metadata, grouping keys).
#let _present_str(v) = type(v) == str and v != ""

#let _string_at(obj, key) = {
  let v = obj.at(key, default: none)
  if _present_str(v) { v }
}

// Entry titles look the same linked or not. `_present` rather than
// `!= none` so an empty `url` doesn't become a dead link.
#let styled-link(content, dest: none) = context {
  let accent = _accent_state.get()
  let styled = emph(text(fill: accent, content))
  if _present(dest) { link(dest, styled) } else { styled }
}

// `{key}` label templates. One regex pass, so a substituted value
// containing `{…}` (e.g. a name) is never re-expanded. Unknown
// placeholders are rejected by `_validate_labels`.
#let _placeholder_re = regex("\{(\w+)\}")
#let _fill_template(template, values) = template.replace(
  _placeholder_re,
  m => values.at(m.captures.first()),
)
