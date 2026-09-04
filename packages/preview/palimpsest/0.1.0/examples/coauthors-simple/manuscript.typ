// The "no letter at all" workflow: several co-authors editing one shared
// draft, with no reviewer, no response document, no bundle export —
// just an ordinary Typst file compiled twice. No `revisions()`, no
// `#document(...)`, no `--features bundle` needed anywhere: `add`/`del`/
// `rep`/`passage`/`change-list` all work as plain functions on their
// own. See compile.sh for the two plain `typst compile` invocations.

#import "@preview/palimpsest:0.1.0": *

#set page(width: 14cm, height: auto, margin: 1.5cm)
#set text(size: 10pt)
#set heading(numbering: "1.")

#set-revisions(authors: (
  bob: (name: "Bobby Fischer", color: rgb("#c026d3")),
  alice: "Alice Smith",
))

#align(center, text(size: 1.4em, weight: "bold")[Shared Project Proposal])
#v(1.5em)

// Placed near the top, self-hides in the clean compile — see
// change-list's own doc comment (src/change-list.typ).
#change-list()

= Introduction

#lorem(15)

#added(<bob>)[Bobby added a paragraph motivating the approach taken
below, after the team's kickoff call.]

#passage(<alice>)[The scope #rep[was left open-ended][is now restricted
to the three use cases agreed on last week].]

= Methods

#added(<carol>)[Carol contributed this whole subsection on the
evaluation protocol — nobody registered her name or a color in
`set-revisions`, so she still gets an automatic, distinct color and
displays under her raw id, "carol".]

#deleted(<bob>, summary: [an early draft of the risk assessment,
superseded by the section below])[
  An earlier, informal risk assessment that the team agreed to drop in
  favor of a structured one.
]

#touched(<alice>)[This paragraph is unchanged — Alice reviewed it and
confirmed it's still accurate, worth marking so nobody re-checks it
again.]

= Budget

// A numbered anchor works too, without a comments file to answer it —
// `require-exchange: false` (see below) turns off the warning that
// would otherwise appear in the tracked version for a numbered anchor
// with nothing answering it.
#set-revisions(require-exchange: false)

#added(<dave-1>)[Dave added a line item for external review costs,
flagged with a number in case the team wants to discuss it later even
though there's no response document here to discuss it in.]
