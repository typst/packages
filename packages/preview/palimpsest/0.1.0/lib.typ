#import "src/marks.typ"
#import "src/style.typ"
#import "src/exchange.typ"
#import "src/pinpoint.typ"
#import "src/letter.typ"
#import "src/xref.typ"
#import "src/pilot.typ"
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

// Satellite constructor — list this under `documents:` in
// `#show: contexture.bundle.with(...)`. No pilot of its own: see
// `src/pilot.typ` and MULTI-DOCUMENT-BUNDLE-DESIGN.md. `strict:` and
// `--input variant=`/`preview=` are contexture's, not palimpsest's —
// set them via `contexture.bundle(strict: true, ...)` / on the command
// line.
#let letter = pilot.letter

// Change list
#let change-list = change-list.change-list
