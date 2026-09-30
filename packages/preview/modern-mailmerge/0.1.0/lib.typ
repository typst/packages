// lib.typ - Main Public Entrypoint for Typst Mail Merge Package

#import "src/core.typ": mail-merge, mail-merge-labels
#import "src/presets.typ": presets
#import "src/utils.typ": (
  read-csv-data,
  field,
  fmt-field,
  bind-field,
  join-fields,
  if-field,
  is-empty,
  is-non-empty,
  record-index,
  record-total,
  is-first-record,
  is-last-record,
)
#import "src/stats.typ": mail-merge-stats, mail-merge-preview
