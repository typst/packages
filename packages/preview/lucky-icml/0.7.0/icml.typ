/**
 * icml.typ
 *
 * International Conference on Machine Learning (ICML).
 */

// Reexport styling rule.
#import "/icml2024.typ": icml2024
#import "/icml2025.typ": icml2025

// Reexport utility routine.
#import "/icml2024.typ": vruler

// Reexport constants and definitions.
#import "/icml2024.typ": font

// Tickness values are taken from booktabs.
#let toprule = table.hline(stroke: (thickness: 0.08em))
#let bottomrule = toprule
#let midrule = table.hline(stroke: (thickness: 0.05em))

/**
 * Initialize and customize @preview/lemmify package.
 */

#import "@preview/lemmify:0.1.7": (
  default-theorems, new-theorems, thm-numbering-heading)

#let thm-styling(
  thm-type,
  name,
  number,
  body
) = block(width: 100%, breakable: true, {
  set align(left)
  let numbering = if number != none {
    " " + number + "."
  } else {
    "."
  }
  if thm-type in ("Remark", ) {
    emph(thm-type + numbering) + " "
  } else {
    strong(thm-type + numbering) + " "
  }
  if name != none {
    emph[(#name)] + " "
  }
  if thm-type in ("Corollary", "Proposition", "Lemma", "Theorem") {
    emph(body)
  } else {
    body
  }
})

#let (
  corollary, proposition, lemma, theorem, // strong + emph
  definition,                             // strong + plain
  remark,                                 // emph + plain
  proof,
  rules: thm-rule,
) = default-theorems(
  "thm-group",
  thm-styling: thm-styling,
  thm-numbering: thm-numbering-heading.with(max-heading-level: 1))

#let (assumption, rules: thm-rule-aux) = new-theorems(
  "thm-group", ("assumption": "Assumption"),
  thm-styling: thm-styling,
  thm-numbering: thm-numbering-heading.with(max-heading-level: 1))

#let lemmify(body) = {
  show: thm-rule
  show: thm-rule-aux
  body
}
