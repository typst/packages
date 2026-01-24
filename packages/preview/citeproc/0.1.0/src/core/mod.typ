// citeproc-typst - Core Module
//
// Re-exports all core functionality.

#import "constants.typ": (
  CITE-FORM, COLLAPSE, POSITION, RENDER-CONTEXT, STYLE-CLASS, VERTICAL-ALIGN,
)

#import "utils.typ": (
  capitalize-first-char, is-empty, join-with-delimiter, strip-periods-from-str,
  zero-pad,
)

#import "formatting.typ": apply-formatting, finalize

#import "context.typ": (
  create-context, with-author-substitute, with-citation-et-al,
  with-disambiguation, with-first-note-number, with-locale, with-position,
  with-render-context, with-year-suffix,
)

#import "state.typ": (
  _abbreviations, _bib-data, _cite-global-idx, _config, _csl-style, cite-marker,
  collect-citations, create-entry-ir, get-entry-year, get-first-author-family,
)
