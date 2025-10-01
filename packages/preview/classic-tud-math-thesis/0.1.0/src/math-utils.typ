#import "@preview/great-theorems:0.1.2": *
#import "@preview/rich-counters:0.2.1": *

// Define theorem counting environment
#let mathcounter = rich-counter(
  identifier: "mathblocks",
  inherited_levels: 1,
)

// numbered theorem environments
#let definition = mathblock(
  blocktitle: "Definition",
  counter: mathcounter,
)
#let satz = mathblock(
  blocktitle: "Satz",
  counter: mathcounter,
)
#let theorem = mathblock(
  blocktitle: "Theorem",
  counter: mathcounter,
)
#let lemma = mathblock(
  blocktitle: "Lemma",
  counter: mathcounter,
)
#let korollar = mathblock(
  blocktitle: "Korollar",
  counter: mathcounter,
)
#let bemerkung = mathblock(
  blocktitle: "Bemerkung",
  counter: mathcounter,
)
#let beispiel = mathblock(
  blocktitle: "Beispiel",
  counter: mathcounter,
)

// Proof Environment
#let beweis = proofblock(
  blocktitle: "Beweis",
  prefix: [_Beweis._#h(4pt)],
)

// unnumbered theorem Environments
#let _definition = mathblock(
  blocktitle: "Definition",
  counter: none,
)
#let _satz = mathblock(
  blocktitle: "Satz",
  counter: none,
)
#let _theorem = mathblock(
  blocktitle: "Theorem",
  counter: none,
)
#let _lemma = mathblock(
  blocktitle: "Lemma",
  counter: none,
)
#let _korollar = mathblock(
  blocktitle: "Korollar",
  counter: none,
)
#let bemerkung = mathblock(
  blocktitle: "Bemerkung",
  counter: none,
)
#let _beispiel = mathblock(
  blocktitle: "Beispiel",
  counter: none,
)

// Only number Equations with a label



#let setup-equate(
  breakable: auto,
  sub-numbering: true,
  number-mode: "label",
  body,
) = {
  import "@preview/equate:0.3.2": equate
  equate(
    breakable: breakable,
    sub-numbering: sub-numbering,
    number-mode: number-mode,
  )[#body]
}
