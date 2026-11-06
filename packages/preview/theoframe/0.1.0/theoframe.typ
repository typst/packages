
#let theoframe(framename: [], theoframe-counter, name: [], color: blue, it) = block(
  width: 100%,
  stroke: (left: 2pt + color),
  inset: 0em,
)[
  #theoframe-counter.step(level: 1)
  #let counter-content = context {
    let heading-counter-str = numbering("1.", counter(heading).get().first())
    let theoframe-counter-str = theoframe-counter.display("a")
    box(heading-counter-str + theoframe-counter-str)
  }
  #block(width: 100%, inset: 1em, outset: 0em, below: 0em, fill: color.lighten(80%).transparentize(70%))[
    #text(fill: color, weight: 700)[#framename #counter-content #h(1em) ] #text(weight: 500)[#name]
  ]
  #block(width: 100%, inset: 1em, outset: 0em, above: 0em, fill: color.lighten(80%).transparentize(90%))[
    #it
  ]
]

#let definition-counter = counter("definition")
#let postulate-counter = counter("postulate")
#let assumption-counter = counter("assumption")
#let conjecture-counter = counter("conjecture")
#let proposition-counter = counter("proposition")
#let lemma-counter = counter("lemma")
#let proof-counter = counter("proof")
#let theorem-counter = counter("theorem")
#let corollary-counter = counter("corollary")
#let example-counter = counter("example")
#let problem-counter = counter("problem")
#let solution-counter = counter("solution")
#let conclusion-counter = counter("conclusion")


#let translation = (
  definition: (en: "Definition", fr: "Définition", ko: "정의", ja: "定義", zh: "定义"),
  postulate: (en: "Postulate", fr: "Postulat", ko: "공준", ja: "公準", zh: "公设"),
  assumption: (en: "Assumption", fr: "Hypothèse", ko: "가정", ja: "仮定", zh: "假设"),
  conjecture: (en: "Conjecture", fr: "Conjecture", ko: "추측", ja: "予想", zh: "猜想"),
  proposition: (en: "Proposition", fr: "Proposition", ko: "명제", ja: "命題", zh: "命题"),
  lemma: (en: "Lemma", fr: "Lemme", ko: "보조정리", ja: "補題", zh: "引理"),
  proof: (en: "Proof", fr: "Démonstration", ko: "증명", ja: "証明", zh: "证明"),
  theorem: (en: "Theorem", fr: "Théorème", ko: "정리", ja: "定理", zh: "定理"),
  corollary: (en: "Corollary", fr: "Corollaire", ko: "따름정리", ja: "系", zh: "推论"),
  example: (en: "Example", fr: "Exemple", ko: "예제", ja: "示例", zh: "示例"),
  problem: (en: "Problem", fr: "Problème", ko: "문제", ja: "問題", zh: "问题"),
  solution: (en: "Solution", fr: "Solution", ko: "풀이", ja: "解答", zh: "解答"),
  conclusion: (en: "Conclusion", fr: "Conclusion", ko: "결론", ja: "結論", zh: "结论"),
)

#let definition(name: [], color: rgb("#794e04"), it) = theoframe(
  framename: [#context translation.definition.at(text.lang, default: "Definition")],
  definition-counter,
  name: [#name],
  color: color,
  it,
)

#let postulate(name: [], color: rgb("#5a3d00"), it) = theoframe(
  framename: [#context translation.postulate.at(text.lang, default: "Postulate")],
  postulate-counter,
  name: [#name],
  color: color,
  it,
)

#let assumption(name: [], color: rgb("#4a4a4a"), it) = theoframe(
  framename: [#context translation.assumption.at(text.lang, default: "Assumption")],
  assumption-counter,
  name: [#name],
  color: color,
  it,
)

#let conjecture(name: [], color: rgb("#6a1b9a"), it) = theoframe(
  framename: [#context translation.conjecture.at(text.lang, default: "Conjecture")],
  conjecture-counter,
  name: [#name],
  color: color,
  it,
)

#let proposition(name: [], color: rgb("#1b5e20"), it) = theoframe(
  framename: [#context translation.proposition.at(text.lang, default: "Proposition")],
  proposition-counter,
  name: [#name],
  color: color,
  it,
)

#let lemma(name: [], color: rgb("#020202"), it) = theoframe(
  framename: [#context translation.lemma.at(text.lang, default: "Lemma")],
  lemma-counter,
  name: [#name],
  color: color,
  it,
)

#let proof(name: [], color: rgb("#050505"), it) = theoframe(
  framename: [#context translation.proof.at(text.lang, default: "Proof")],
  proof-counter,
  name: [#name],
  color: color,
  it,
)

#let theorem(name: [], color: rgb("#09658a"), it) = theoframe(
  framename: [#context translation.theorem.at(text.lang, default: "Theorem")],
  theorem-counter,
  name: [#name],
  color: color,
  it,
)

#let corollary(name: [], color: rgb("#0d47a1"), it) = theoframe(
  framename: [#context translation.corollary.at(text.lang, default: "Corollary")],
  corollary-counter,
  name: [#name],
  color: color,
  it,
)

#let example(name: [], color: rgb("#030303"), it) = theoframe(
  framename: [#context translation.example.at(text.lang, default: "Example")],
  example-counter,
  name: [#name],
  color: color,
  it,
)

#let problem(name: [], color: rgb("#b71c1c"), it) = theoframe(
  framename: [#context translation.problem.at(text.lang, default: "Problem")],
  problem-counter,
  name: [#name],
  color: color,
  it,
)

#let solution(name: [], color: rgb("#1a237e"), it) = theoframe(
  framename: [#context translation.solution.at(text.lang, default: "Solution")],
  solution-counter,
  name: [#name],
  color: color,
  it,
)

#let conclusion(name: [], color: rgb("#004d40"), it) = theoframe(
  framename: [#context translation.conclusion.at(text.lang, default: "Conclusion")],
  conclusion-counter,
  name: [#name],
  color: color,
  it,
)

#show heading.where(level: 1): it => {
  definition-counter.update(0)
  postulate-counter.update(0)
  assumption-counter.update(0)
  conjecture-counter.update(0)
  proposition-counter.update(0)
  lemma-counter.update(0)
  proof-counter.update(0)
  theorem-counter.update(0)
  corollary-counter.update(0)
  example-counter.update(0)
  problem-counter.update(0)
  solution-counter.update(0)
  conclusion-counter.update(0)
  it
}