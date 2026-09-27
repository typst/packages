#import "@preview/contexture:0.1.0" as contexture

/// Every `check()` hit whose `id` matches, in document order. Same
/// query+filter shape as palimpsest's `pinpoint`, applied to a plain
/// dictionary-field match instead of a Typst label — built on
/// `contexture.anchors`, which already handles the cross-document query.
/// Must be called from within a `context`.
#let resolve-item(id) = contexture.anchors("checkitoff-item").filter(el => el.value.id == id)

/// Every `na()` hit whose `id` matches. In practice at most one —
/// `grid.typ` treats more than one `na()` for the same id as its own
/// diagnostic — but returned as a list for symmetry with `resolve-item`
/// and so the caller decides what "more than one" means rather than this
/// silently keeping only the first. Must be called from within a
/// `context`.
#let resolve-na(id) = contexture.anchors("checkitoff-na").filter(el => el.value.id == id)

/// Page numbers `resolve-item(id)` renders onto, deduplicated but
/// otherwise in document order — an item appearing on the same page twice
/// (two `check()` calls that land on one page) collapses to one entry,
/// two calls that land on different pages (including the "straddles a
/// page break" idiom: one `check()` at the start of a passage, one right
/// after the break, same id) each contribute their own page.
#let pages-of(id) = resolve-item(id).map(h => h.location().page()).dedup()
