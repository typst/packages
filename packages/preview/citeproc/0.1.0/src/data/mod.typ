// citeproc-typst - Data Processing Module
//
// Re-exports all data processing functionality.

#import "variables.typ": get-variable, has-variable

#import "conditions.typ": eval-condition, eval-nested-conditions

#import "sorting.typ": (
  compare-entries, extract-sort-key, extract-sort-keys,
  sort-bibliography-entries, sort-entries,
)

#import "disambiguation.typ": (
  apply-disambiguation, compute-name-disambiguation, compute-year-suffixes,
)

#import "collapsing.typ": (
  apply-cite-grouping, apply-collapse, collapse-numeric-ranges,
  collapse-year-suffix, collapse-year-suffix-ranged, format-collapsed-numeric,
)
