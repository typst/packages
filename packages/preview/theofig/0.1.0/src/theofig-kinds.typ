#import "theofig.typ": *

/// List of default kinds of environments defined by this package:
///
/// #theofig-kinds.map(s => raw("\"" + s + "\"")).join(", ", last: ", and ").
/// 
/// The purpose to this variable is to be used together with
/// selector `figure-where-kind-in()` for styling:
/// #code-example-row(```typ
/// #show figure-where-kind-in(
///   theofig-kinds
/// ): block.with(
///     stroke: 1pt, radius: 3pt, inset: 5pt,
/// )
/// #definition[]
/// #theorem[]
/// #proof[]
/// ```)
#let theofig-kinds = (
  "algorithm",
  "corollary",
  "definition",
  "example",
  "lemma",
  "problem",
  "proof",
  "remark", 
  "solution",
  "statement",
  "theorem", 
)

/// #code-example-row(```typst #algorithm[Note][#lorem(3)]```)
#let algorithm   = theofig.with(kind: "algorithm",   supplement: "Algorithm",   translate-supplement: true)
/// #code-example-row(```typst #corollary[Note][#lorem(3)]```)
#let corollary   = theofig.with(kind: "corollary",   supplement: "Corollary",   translate-supplement: true, numbering: none)
/// #code-example-row(```typst #definition[Note][#lorem(3)]```)
#let definition  = theofig.with(kind: "definition",  supplement: "Definition",  translate-supplement: true)
/// #code-example-row(```typst #example[Note][#lorem(3)]```)
#let example     = theofig.with(kind: "example",     supplement: "Example",     translate-supplement: true)
/// #code-example-row(```typst #lemma[Note][#lorem(3)]```)
#let lemma       = theofig.with(kind: "lemma",       supplement: "Lemma",       translate-supplement: true)
/// #code-example-row(```typst #problem[Note][#lorem(3)]```)
#let problem     = theofig.with(kind: "problem",     supplement: "Problem",     translate-supplement: true)
/// #code-example-row(```typst #proof[Note][#lorem(3)]```)
#let proof       = theofig.with(kind: "proof",       supplement: "Proof",       translate-supplement: true, numbering: none, qed: true)
/// #code-example-row(```typst #proposition[Note][#lorem(3)]```)
#let proposition = theofig.with(kind: "proposition", supplement: "Proposition", translate-supplement: true)
/// #code-example-row(```typst #remark[Note][#lorem(3)]```)
#let remark      = theofig.with(kind: "remark",      supplement: "Remark",      translate-supplement: true)
/// #code-example-row(```typst #solution[Note][#lorem(3)]```)
#let solution    = theofig.with(kind: "solution",    supplement: "Solution",    translate-supplement: true, numbering: none)
/// #code-example-row(```typst #statement[Note][#lorem(3)]```)
#let statement   = theofig.with(kind: "statement",   supplement: "Statement",   translate-supplement: true)
/// #code-example-row(```typst #theorem[Note][#lorem(3)]```)
#let theorem     = theofig.with(kind: "theorem",     supplement: "Theorem",     translate-supplement: true)
