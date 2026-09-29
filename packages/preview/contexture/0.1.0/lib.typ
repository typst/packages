#import "src/mode.typ"
#import "src/diagnostics.typ"
#import "src/anchor.typ" as anchor-mod
#import "src/xref.typ"
#import "src/satellite.typ" as satellite-mod
#import "src/pilot.typ"
#import "src/utils.typ"

// Mode
#let variant = mode.variant
#let preview = mode.preview

// Diagnostics
#let diagnose = diagnostics.diagnose
#let set-strict = diagnostics.set-strict

// Anchors — imported under an alias above: this module's own exported
// function is also named `anchor`, which would otherwise shadow the
// module binding itself partway through this file (verified directly —
// `#let anchor = anchor.anchor` then `anchor.anchors` on the next line
// fails with "cannot access fields on user-defined functions", since the
// first line's `#let` already rebound the name `anchor` to a plain
// function before the second line tries to read a field off it).
#let anchor = anchor-mod.anchor
#let anchors = anchor-mod.anchors
#let collect-anchors = anchor-mod.collect-anchors
#let reemit = anchor-mod.reemit

// Cross-referencing
#let xref = xref.xref

// Satellite documents + pilot — same shadowing hazard as `anchor` above,
// same fix.
#let satellite = satellite-mod.satellite
#let bundle = pilot.bundle

// Structural utilities, shared by any package that needs to re-emit
// stored content into a second document (an excerpt, a quoted passage).
#let collect-metadata = utils.collect-metadata
#let is-blank = utils.is-blank
#let is-textual = utils.is-textual
#let collect-labels = utils.collect-labels
#let strip-labels = utils.strip-labels
