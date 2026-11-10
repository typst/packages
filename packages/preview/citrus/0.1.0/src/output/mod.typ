// citrus - Output Module
//
// Re-exports all output/rendering functionality.

#import "punctuation.typ": collapse-punctuation
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
