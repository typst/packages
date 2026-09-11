#import "section-cover.typ": title-slide as base-title-slide
#import "slide-functions.typ": outline-item as base-outline-item, card as base-card, conclusion-card as base-conclusion-card, result-conclusion as base-result-conclusion, metric as base-metric, soft-note as base-soft-note, small-title as base-small-title, issue-row as base-issue-row, slide-table as base-slide-table, figure-caption as base-figure-caption, table-caption as base-table-caption

// Compatibility shim: custom function implementations live in slide-functions.typ.
#let outline-item = base-outline-item
#let card = base-card
#let conclusion-card = base-conclusion-card
#let result-conclusion = base-result-conclusion
#let metric = base-metric
#let soft-note = base-soft-note
#let small-title = base-small-title
#let issue-row = base-issue-row
#let slide-table = base-slide-table
#let figure-caption = base-figure-caption
#let table-caption = base-table-caption
#let title-slide = base-title-slide
