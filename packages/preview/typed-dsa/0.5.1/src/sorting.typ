// Sorting domain facade.
//
// Shared trace representations are separated from merge-sort, quick-sort, and
// elementary sorting algorithm implementations.

#import "sorting-common.typ": sort-sequence as _sort-sequence
#import "sorting-merge.typ": merge-sort as _merge-sort, merge-operation as _merge-operation
#import "sorting-quick.typ": quick-sort as _quick-sort, partition-step as _partition-step
#import "sorting-elementary.typ": (
  bubble-sort as _bubble-sort, insertion-sort as _insertion-sort,
  selection-sort as _selection-sort,
)

#let merge-sort = _merge-sort
#let merge-operation = _merge-operation
#let partition-step = _partition-step
#let quick-sort = _quick-sort
#let bubble-sort = _bubble-sort
#let insertion-sort = _insertion-sort
#let selection-sort = _selection-sort
#let sort-sequence = _sort-sequence
