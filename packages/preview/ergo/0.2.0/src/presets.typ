#import "main.typ": (
  ergo-solution,
  ergo-statement
)






//-----Preset Solution Environments-----//
#let theorem     = ergo-solution.with(
  [Theorem],
  "theorem",
  true
)

#let lemma       = ergo-solution.with(
  [Lemma],
  "lemma",
  true
)

#let corollary   = ergo-solution.with(
  [Corollary],
  "corollary",
  true
)

#let proposition = ergo-solution.with(
  [Proposition],
  "proposition",
  true
)

#let problem     = ergo-solution.with(
  [Problem],
  "problem",
  false
)

#let exercise    = ergo-solution.with(
  [Exercise],
  "exercise",
  true
)






//-----Preset Statement Environments-----//
#let note                  = ergo-statement.with(
  [Note],
  "note"
)

#let definition            = ergo-statement.with(
  [Definition],
  "definition"
)

#let remark                = ergo-statement.with(
  [Remark],
  "remark"
)

#let notation              = ergo-statement.with(
  [Notation],
  "notation"
)

#let example               = ergo-statement.with(
  [Example],
  "example"
)

#let concept               = ergo-statement.with(
  [Concept],
  "concept"
)

#let computational-problem = ergo-statement.with(
  [Computational Problem],
  "computational-problem"
)

#let algorithm             = ergo-statement.with(
  [Algorithm],
  "algorithm"
)

#let runtime               = ergo-statement.with(
  [Runtime Analysis],
  "runtime"
)
