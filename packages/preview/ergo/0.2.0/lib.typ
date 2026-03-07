#import "src/main.typ": (
  ergo-init,
  ergo-colors,
  ergo-styles,

  // Misc.
  bookmark,
  equation-box,

  // Custom
  ergo-solution,
  ergo-statement,
)

#import "src/style/helpers.typ": (
  ergo-title-selector,
)

#import "src/style/cosmetic-envs.typ": (
  correction,
  proof,
  solution
)

#import "src/presets.typ": (
  theorem,
  lemma,
  corollary,
  proposition,
  note,
  definition,
  remark,
  notation,
  example,
  concept,
  computational-problem,
  algorithm,
  runtime,
  problem,
  exercise,
)

#let eqbox     = equation-box

#let thm       = theorem
#let lem       = lemma
#let cor       = corollary
#let prop      = proposition

#let defn      = definition
#let rem       = remark
#let rmk       = remark
#let notn      = notation
#let ex        = example
#let conc      = concept
#let comp-prob = computational-problem
#let algo      = algorithm

#let prob      = problem
#let excs      = exercise

#let pf        = proof
#let sol       = solution
