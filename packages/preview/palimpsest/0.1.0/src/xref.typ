#import "@preview/contexture:0.1.0" as contexture

/// `xref` was fully generic from the start (it only ever operated on
/// plain Typst labels, never on anything revision-specific) — promoted
/// to `contexture` unchanged, re-exported here so
/// `#import "@preview/palimpsest:..."` keeps working exactly as before.
#let xref = contexture.xref
