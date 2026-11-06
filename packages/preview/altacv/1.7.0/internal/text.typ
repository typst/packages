// Small text predicates and the styled-link helper.
//
// Empty-string normalisation: callers receive `none` for any field
// that's effectively absent (none / "" / empty content). `_present`
// is the canonical predicate; data-shape normalisers (location,
// url-encode) live with the header that consumes them.

#import "state.typ": _accent_state

// Rejects `none`, the empty string, and the empty content block —
// the three ways a section field can be effectively absent.
#let _present(v) = v != none and v != "" and v != []

// Stricter than `_present` for fields that must be plain strings —
// PDF metadata, grouping keys — where a content block or a number
// would either be rejected downstream or render as a nonsense key.
#let _present_str(v) = type(v) == str and v != ""

// Accent-coloured italic styling for entry titles. When `dest` is
// present the styled content is wrapped in a `link()`, giving every
// linked + unlinked title a uniform visual — URL presence is purely
// a clickability concern, not a styling one. `_present` (rather than
// `!= none`) so an empty-string `url` doesn't become a dead link.
#let styled-link(content, dest: none) = context {
  let accent = _accent_state.get()
  let styled = emph(text(fill: accent, content))
  if _present(dest) { link(dest, styled) } else { styled }
}

// `{key}` placeholders in a label template (`labels.pageNumber`,
// `labels.documentTitle`). A single regex pass, so a substituted value
// that itself contains `{…}` (e.g. a name) is never re-expanded.
// Unknown placeholders are rejected up front by `_validate_labels`.
#let _placeholder_re = regex("\{(\w+)\}")
#let _fill_template(template, values) = template.replace(
  _placeholder_re,
  m => values.at(m.captures.first()),
)
