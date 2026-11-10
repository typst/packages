#import "@preview/theorion:0.6.0" as theorion
#import theorion.cosmos: fancy
#import "theme.typ": ink

// Theorion figures keep native labels, references, restatement and outlines.
#let theorem = fancy.theorem.with(breakable: false)
#let definition = fancy.definition.with(breakable: false)
#let example = fancy.example.with(breakable: false)
#let lemma = fancy.lemma.with(breakable: false)
#let proposition = fancy.proposition.with(breakable: false)
#let corollary = fancy.corollary.with(breakable: false)
#let axiom = fancy.axiom.with(breakable: false)
#let postulate = fancy.postulate.with(breakable: false)
#let assumption = fancy.assumption.with(breakable: false)
#let property = fancy.property.with(breakable: false)
#let conjecture = fancy.conjecture.with(breakable: false)
#let remark = fancy.remark.with(breakable: false)
#let note = fancy.note.with(breakable: false)
#let exercise = fancy.exercise.with(breakable: false)
#let problem = fancy.problem.with(breakable: false)

#let result-frame(body) = block(
  width: 100%, breakable: true,
  inset: (x: 12pt, y: 7pt),
  stroke: (left: .8pt + ink.lighten(65%)),
  body,
)
/// Unnumbered proof, always ending with an open square. No title required.
#let proof(body) = result-frame(theorion.proof(qed: [#sym.square.stroked], body))
/// Unnumbered solution with the same open-square ending as proof.
#let solution(body) = result-frame(theorion.solution(
  title: (zh: "解答", en: "Solution", ja: "解答", ko: "풀이"),
  qed: [#sym.square.stroked], body,
))
#let conclusion(body) = result-frame(theorion.conclusion(qed: [#sym.square.stroked], body))
#let qedhere = theorion.qedhere
#let note-block = theorion.note-block
#let tip-block = theorion.tip-block
#let important-block = theorion.important-block
#let warning-block = theorion.warning-block
#let caution-block = theorion.caution-block
#let remark-block = theorion.remark-block
#let quote-block = theorion.quote-block
#let emph-block = theorion.emph-block

#let setup-theorems(accent) = {
  fancy.set-inherited-levels(1)
  fancy.set-zero-fill(true)
  fancy.set-leading-zero(true)
  theorion.set-theorion-numbering("1.1")
  theorion.set-qed-symbol([#sym.square.stroked])
  theorion.set-indent-mode(none)
  fancy.set-primary-border-color(accent)
  fancy.set-primary-body-color(accent.lighten(95%))
  fancy.set-secondary-border-color(rgb("A56A2B"))
  fancy.set-secondary-body-color(rgb("FCF7EF"))
  fancy.set-tertiary-border-color(rgb("41618C"))
  fancy.set-tertiary-body-color(rgb("F2F5FA"))
  fancy.set-quaternary-border-color(rgb("795777"))
  fancy.set-quaternary-body-color(rgb("F8F3F8"))
  fancy.set-primary-symbol(none)
  fancy.set-secondary-symbol(none)
  fancy.set-tertiary-symbol(none)
  fancy.set-quaternary-symbol(none)
  fancy.set-fancy-radius(3pt)
}
#let show-theorems = fancy.show-theorion
