#import "diagnostics.typ": diagnose

/// Like `@label` / `ref(label)` (which already resolve cross-document —
/// `@tab-sensi` from the letter renders the manuscript's real "Tableau
/// 3"), but appends the manuscript's real page number: "Tableau 3, p.
/// 14". Explicit rather than a bare `@label`, so it stays correct even
/// if a future version duplicates the manuscript in the bundle (§9) —
/// `ref` alone would then be ambiguous between the two copies.
#let xref(lbl) = context {
  let hits = query(lbl)
  if hits.len() == 0 {
    diagnose("xref(" + repr(lbl) + "): not found", always: true)
  } else {
    [#ref(lbl), p. #hits.first().location().page()]
  }
}
