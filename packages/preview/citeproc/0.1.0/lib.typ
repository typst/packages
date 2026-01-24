// citeproc-typst - CSL (Citation Style Language) processor for Typst
//
// Usage with BibTeX:
//   #import "@preview/citeproc-typst:0.1.0": init-csl, csl-bibliography
//   #show: init-csl.with(
//     read("refs.bib"),
//     read("style.csl"),
//   )
//   Use @key in text to cite...
//   #csl-bibliography()
//
// Usage with CSL-JSON:
//   #import "@preview/citeproc-typst:0.1.0": init-csl-json, csl-bibliography
//   #show: init-csl-json.with(
//     read("refs.json"),
//     read("style.csl"),
//   )
//   Use @key in text to cite...
//   #csl-bibliography()

// =============================================================================
// Public API Exports
// =============================================================================
//
// This file serves as the main entry point, re-exporting all public functions
// from their respective modules for a clean import experience.

// Initialization functions
#import "src/init/mod.typ": init-csl, init-csl-json, load-csl, load-locale

// Bibliography and citation API
#import "src/api/mod.typ": csl-bibliography, get-cited-entries, multicite
