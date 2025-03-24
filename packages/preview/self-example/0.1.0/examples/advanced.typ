#import "../lib.typ": *
#import "@preview/codly:1.1.1": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#let code="= Hello,World!
== I love typst
+ fast
+ easy
+ beautiful"

#let myRaw(code) = {
  "This is the code to generate the example."
  code 
}
#let myEval(code) = {
  "This is the result."
  code 
}
#let myMerge(raw, eval) = {
  grid(columns:(3fr,1fr),gutter:30pt)[#raw][#eval]
}
#getExample(code,raw_handler: myRaw, eval_handler: myEval, merge_handler: myMerge)
