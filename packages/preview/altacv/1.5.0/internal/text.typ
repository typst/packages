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

// Accent-coloured italic styling for entry titles. When `dest` is
// non-none the styled content is wrapped in a `link()`, giving every
// linked + unlinked title a uniform visual — URL presence is purely
// a clickability concern, not a styling one.
#let styled-link(content, dest: none) = context {
  let accent = _accent_state.get()
  let styled = emph(text(fill: accent, content))
  if dest == none { styled } else { link(dest, styled) }
}
