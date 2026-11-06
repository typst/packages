#import "resolve.typ": resolve-item
#import "@preview/contexture:0.1.0" as contexture

/// Re-emits the real content anchored to `id` by `check()` — one block
/// per occurrence (an item checked at several locations yields several
/// excerpts, joined by `parbreak()`, unlike `pages-of` which dedups by
/// page: two occurrences on the same page are still two distinct excerpts
/// here). `contexture.strip-labels` guarantees a figure/table/heading the
/// manuscript also cross-references by label can still be shown here
/// without planting a second, ambiguous copy of that label.
///
/// `quotes: true` wraps a textual excerpt in real quotation marks
/// (`quote()`) — silently declines on anything `contexture.is-textual`
/// flags as non-text (a figure, a table, a block equation), same
/// reasoning as palimpsest's `pinpoint(quotes: true)`.
///
/// `on-empty` (default `none`, i.e. render nothing) is deliberately not a
/// diagnostic the way palimpsest's `pinpoint` defaults to one: this
/// function can be called from inside the manuscript itself (a
/// supplementary compliance appendix, say), where no diagnostic may ever
/// render (`contexture.diagnose`'s `always:` convention) — an uncovered
/// item is already flagged exactly once, safely, in `checklist.pdf`'s
/// coverage table.
#let excerpt-of(id, quotes: false, show-page: false, on-empty: none) = context {
  // A bare check(id) (point-marker form, no body) resolves a page but
  // has nothing to quote — filtered out here rather than in
  // resolve-item itself, since resolve-item/pages-of still need every
  // hit, body or not, for correct page resolution.
  let hits = resolve-item(id).filter(h => h.value.raw-body != none)
  if hits.len() == 0 {
    on-empty
  } else {
    hits.map(h => {
      let v = h.value
      let stripped = contexture.strip-labels(v.raw-body)
      let content = if quotes and contexture.is-textual(stripped) { quote(stripped) } else { stripped }
      if show-page {
        [*p. #h.location().page()* --- #content]
      } else {
        content
      }
    }).join(parbreak())
  }
}
