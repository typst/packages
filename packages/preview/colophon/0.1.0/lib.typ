#import "src/instrument.typ"
#import "src/words.typ"
#import "src/inventory.typ"
#import "src/labels.typ"
#import "src/citations.typ"
// Imported under an alias: this module's own exported function is also
// named `abstract`, which would otherwise shadow the module binding
// itself partway through this file, the same hazard contexture's own
// lib.typ documents for `anchor` -- verified directly, "cannot access
// fields on user-defined functions" on the very next line otherwise.
#import "src/abstract.typ" as abstract-mod
#import "src/report.typ"

// Wiring
#let instrument = instrument.instrument

// Word counting, exposed for use outside the bundle if ever needed.
#let extract-text = words.extract-text
#let count-words = words.count-words
#let word-counts-by-section = words.word-counts-by-section

// Figure/table inventory, exposed for the same reason.
#let figure-inventory = inventory.figure-inventory

// Structural anomalies, exposed for the same reason.
#let orphan-labels = labels.orphan-labels
#let bib-keys = citations.bib-keys
#let uncited-references = citations.uncited-references

// The abstract marker.
#let abstract = abstract-mod.abstract
#let abstract-word-count = abstract-mod.abstract-word-count

// The audit document.
#let render-report = report.render-report
#let report = report.report
