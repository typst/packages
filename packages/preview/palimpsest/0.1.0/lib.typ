#import "src/marks.typ"
#import "src/style.typ"
#import "src/diagnostics.typ"
#import "src/exchange.typ"
#import "src/pinpoint.typ"
#import "src/letter.typ"
#import "src/xref.typ"
#import "src/revisions.typ"
#import "src/change-list.typ"

// Marking
#let mode = marks.mode
#let passage = marks.passage
#let add = marks.add
#let del = marks.del
#let rep = marks.rep
#let added = marks.added
#let deleted = marks.deleted
#let replaced = marks.replaced
#let touched = marks.touched
#let suppress = marks.suppress
#let suppressed = marks.suppressed

// Style
#let set-revisions = style.set-revisions

// Diagnostics
#let set-strict = diagnostics.set-strict

// Exchanges
#let reviewer = exchange.reviewer
#let editor = exchange.editor
#let author = exchange.author
#let xcomment = exchange.xcomment
#let note = exchange.note
#let exchange = exchange.exchange

// Letter
#let pinpoint = pinpoint.pinpoint
#let letter-bibliography = letter.letter-bibliography
#let default-letter-template = letter.default-letter-template
#let xref = xref.xref

// Pilot
#let revisions = revisions.revisions

// Change list
#let change-list = change-list.change-list
