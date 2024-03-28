#import "theorem.typ": theorem
#import "definition.typ": definition
#import "proposition.typ": proposition
#import "lemma.typ": lemma
#import "corollary.typ": corollary

#import "proof.typ": proof
#import "solution.typ": solution
#import "example.typ": example
#import "exercise.typ": exercise
#import "note.typ": note

#let theorem-rules(body) = {
  show figure.where(kind: "Theorem"): it => it.body
  show figure.where(kind: "Proposition"): it => it.body
  show figure.where(kind: "Lemma"): it => it.body
  show figure.where(kind: "Corollary"): it => it.body
  show figure.where(kind: "Definition"): it => it.body
  show figure.where(kind: "Example"): it => it.body
  show figure.where(kind: "Exercise"): it => it.body
  show figure.where(kind: "Note"): it => it.body

  // The rest of the document
  body
}