// citrus - CSL-JSON Initialization Module
//
// Provides init-csl-json() for CSL-JSON bibliography loading.

#import "../core/mod.typ": _abbreviations, _bib-data
#import "../parsing/mod.typ": _csl-json-mode, generate-stub-bib, parse-csl-json
#import "core.typ": _init-csl-core

/// Initialize the CSL citation system with CSL-JSON input
///
/// CSL-JSON is the native format for CSL processors. Properties map directly
/// to CSL variables, avoiding translation losses from BibTeX.
///
/// - json-data: CSL-JSON content (use `read("refs.json")`)
/// - style: CSL file content (use `read("style.csl")`)
/// - locales: Optional dict of lang -> locale content for external locales
/// - show-url: Whether to show URLs in bibliography
/// - show-doi: Whether to show DOIs in bibliography
/// - show-accessed: Whether to show access dates in bibliography
/// - auto-links: Whether to auto-link DOI/URL/PMID/PMCID (default: true)
/// - abbreviations: Optional abbreviation lookup table (jurisdiction -> variable -> value -> abbrev)
/// - doc: Document content
#let init-csl-json(
  json-data,
  style,
  locales: (:),
  show-url: true,
  show-doi: true,
  show-accessed: true,
  auto-links: true,
  abbreviations: (:),
  doc,
) = {
  // Parse CSL-JSON and convert to internal format
  let entries = parse-csl-json(json-data)
  _bib-data.update(entries)
  _csl-json-mode.update(true)

  // Store abbreviations
  _abbreviations.update(abbreviations)

  // Generate stub BibTeX immediately (before doc processing)
  let stub-bib = generate-stub-bib(entries)

  _init-csl-core(
    style,
    locales: locales,
    show-url: show-url,
    show-doi: show-doi,
    show-accessed: show-accessed,
    auto-links: auto-links,
    doc,
    stub-bib,
  )
}
