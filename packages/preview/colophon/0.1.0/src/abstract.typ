#import "words.typ": extract-text, count-words

/// Wraps `body` -- typically what's passed to a template's own
/// `abstract:` parameter, though it works exactly the same written
/// directly in the manuscript, under its own heading -- with an
/// invisible marker `report()` can find later, so the abstract gets
/// its own word count instead of either vanishing (most templates take
/// it as a template argument, evaluated before `instrument()`'s
/// `template:` ever runs, so it's never part of the manuscript `body`
/// `contexture.bundle` sees at all) or silently inflating the main
/// body total (if it's written directly in the manuscript instead).
///
/// Renders `body` completely unchanged -- no visual difference between
/// `abstract: colophon.abstract(my-text)` and `abstract: my-text`.
///
/// `context body`, not bare `body` -- tried first, and wrong: an
/// unrecognized `metadata` tag already contributes zero words on its
/// own (see `words.typ`'s dispatch), but `body` here is a *separate*
/// sibling right after it, not something the metadata's presence
/// shields from the generic walker -- it was still being walked and
/// counted normally, on top of (not instead of) the dedicated count
/// below, found directly by getting a body total that hadn't shrunk at
/// all. Wrapping the visible render in `context` -- exactly the trick
/// `@preview/palimpsest`'s own marks already rely on for the reverse
/// reason (see `palimpsest-clean-text`, above) -- makes it structurally
/// opaque to `words.typ`'s pre-layout walk (verified directly:
/// `context [...]`'s own `.fields()` is `(:)`, empty, so the generic
/// walker's fallback already treats it as contributing nothing, no
/// special case needed) while rendering byte-for-byte the same content
/// at layout time either way.
#let abstract(body) = {
  [#metadata((tag: "colophon-abstract", raw-body: body)) <colophon-abstract>]
  context body
}

/// The abstract's word count, if `abstract(...)` was used anywhere in
/// the manuscript span `start`..`end` (see `instrument.typ`) --
/// `none` if it wasn't, which isn't an error: most manuscripts in this
/// package's own tests have none, and not every document needs one.
/// Several `abstract(...)` calls (unusual, but not prevented) are
/// summed together rather than only the first one counted.
#let abstract-word-count(start, end, count-captions: false) = {
  let hits = query(selector(<colophon-abstract>).after(start).before(end))
  if hits.len() == 0 {
    none
  } else {
    hits
      .map(h => extract-text(h.value.raw-body, count-captions: count-captions))
      .map(count-words)
      .sum()
  }
}
