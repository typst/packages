# Changelog

## [0.2.0] – 2026

Major rewrite of the core.

### Fixed
- **Jump-to-source preserved.** Feature #1 no longer rebuilds text with
  `it.text.replace(" ", "~")` (which moved the source position of the affected
  glyphs to the package). Both short words and titles now wrap the **original**
  matched content in `#box(..)`, so clicking a glyph in the PDF jumps back to
  the document, not to the package code.
- Title alternation is ordered **longest-first**, so multi-word titles match
  correctly (`Ing. arch.`, `dr. h. c.`, `pplk. gšt.` no longer lose to their
  shorter prefixes).
- Typo `plk` → `plk.` in the list of titles.
- Non-period abbreviations get a trailing word boundary, so `viz` no longer
  matches inside `vize` and `PhD` no longer matches the start of `PhDr.`.

### Added
- **Titles after a name** (`Ph.D.`, `PhD.`, `Th.D.`, `CSc.`, `DrSc.`, `DSc.`,
  `DiS.`, `MBA`, `LL.M.`, `MSc.`) are bound to the preceding word.
- **Chaining** of short words and titles into a single non-breaking run
  (`k s bratrem`, `plk. gšt. doc. Mgr. et Mgr. Ing. Libor Kutěj`) — a unified
  prefix run prevents adjacent rules from competing for the boundary word
  (e.g. `za tzv. postup`).
- **Two-letter words** with a lowercase second letter (`na`, `po`, `je`, `se`,
  …) in addition to single letters.
- `debug: true` mode that outlines every glued block.

### Changed
- Public API is unchanged: `#show: apply-vlna` still works. `apply-vlna` now
  also accepts `debug: false`.

## [0.1.1] – 2025-04-30
- Short-word regex narrowed to `(\<\p{Lowercase}{1,2}\>)+ `.
- Experimental list of titles/abbreviations before a name.

## [0.1.0] – 2025-03-03
- Initial non-breaking spaces after short prepositions/conjunctions.
