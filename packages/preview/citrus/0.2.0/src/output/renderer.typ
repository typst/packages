// citrus - Entry and Citation Renderer
//
// This file is kept for backward compatibility.
// All functionality has been split into focused modules:
// - layout.typ: Layout selection (CSL-M multilingual)
// - helpers.typ: Node traversal and content conversion utilities
// - names-render.typ: Names rendering for grouping, display, bibliography
// - entry.typ: Bibliography entry rendering
// - citation.typ: In-text citation rendering
// - pipeline.typ: IR processing pipeline

// Re-export all public functions for backward compatibility
#import "layout.typ": select-layout
#import "helpers.typ": (
  content-to-string, find-first-names-macro, find-first-names-node,
  node-uses-citation-number, style-uses-citation-number,
)
#import "names-render.typ": (
  get-first-bib-names-node, render-names-for-bibliography,
  render-names-for-citation-display, render-names-for-grouping,
)
#import "entry.typ": render-citation-number, render-entry, render-entry-ir
#import "citation.typ": render-citation
#import "pipeline.typ": get-rendered-entries, process-entries
