#import "diagnostics.typ": diagnose

/// Like `@label` / `ref(label)` (which already resolve cross-document —
/// `@tab-sensi` from a satellite document renders the manuscript's real
/// "Tableau 3"), but appends the real page number: "Tableau 3, p. 14".
/// Explicit rather than a bare `@label`, so it stays correct even if a
/// future document duplicates the same label — `ref` alone would then be
/// ambiguous between the two copies.
///
/// Operates on plain Typst labels (figures, headings, equations...), not
/// on `contexture.anchor()` — promoted here from typst-palimpsest
/// unchanged because it never depended on anything revision-specific in
/// the first place.
#let xref(lbl) = context {
  let hits = query(lbl)
  if hits.len() == 0 {
    diagnose("xref(" + repr(lbl) + "): not found", always: true)
  } else {
    [#ref(lbl), p. #hits.first().location().page()]
  }
}
