/// State carrying the manuscript's own body -- the content passed to
/// `contexture.bundle(template: ..., body)`, captured *before* layout --
/// so `report()`, a separate document in the same bundle, can walk it
/// structurally for word counts. Propagates across documents exactly
/// like `query`/`metadata` (verified directly: a `state.update()` call
/// inside one `#document(...)` is visible via `context` from another).
#let captured-body = state("colophon-manuscript-body", none)

/// Wraps a manuscript `template:` so `report()` can find both the
/// manuscript's real page span and its own, pre-layout body. Two things,
/// both necessary for different reasons:
///
/// - the body is captured in `captured-body` *before* `template` ever
///   sees it -- the exact content Typst is about to lay out, still
///   holding `ref`/`cite` as their own nodes rather than the rendered
///   bracket-and-number text citation resolution rewrites them into.
///   Verified directly: walking the *laid-out*, queried version of this
///   same content counts citation/cross-reference numbers as stray
///   words; walking the pre-layout version captured here doesn't,
///   because nothing has been resolved into visible text yet at this
///   point (see `words.typ`'s `extract-text`);
/// - `<colophon-manuscript-start>`/`<colophon-manuscript-end>` bracket
///   the real, rendered output, so `report()` can scope every `query()`
///   it runs (page count today; figure/label/reference queries in a
///   later phase) to just the manuscript document. Without this, a
///   query from the report's own document also matches the report's
///   own content -- confirmed directly to cause a genuine
///   non-converging compile when the report renders any `par`/`heading`
///   of its own, which it does the moment it prints its own results.
#let instrument(template: body => body) = body => {
  captured-body.update(body)
  [#metadata(none) <colophon-manuscript-start>]
  template(body)
  [#metadata(none) <colophon-manuscript-end>]
}
