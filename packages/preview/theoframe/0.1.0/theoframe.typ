

#let theoframe(framename: [], theoframe_counter, name: [], color: blue, it) = block(
  width: 100%,
  stroke: (left: 2pt + color),
  inset: 0em,
)[
  #theoframe_counter.step(level: 1)
  #let counter_content = context {
    let heading_counter_str = numbering("1.", counter(heading).get().first())
    let theoframe_counter_str = theoframe_counter.display("a")
    box(heading_counter_str + theoframe_counter_str)
  }
  #block(width: 100%, inset: 1em, outset: 0em, below: 0em, fill: color.lighten(80%).transparentize(70%))[
    #text(fill: color, weight: 700)[#framename #counter_content #h(1em) ] #text(weight: 500)[#name]
  ]
  #block(width: 100%, inset: 1em, outset: 0em, above: 0em, fill: color.lighten(80%).transparentize(90%))[
    #it
  ]
]

#let Definition_counter = counter("Definition")
#let Lemma_counter = counter("Lemma")
#let Proof_counter = counter("Proof")
#let Theorem_counter = counter("Theorem")
#let Example_counter = counter("Example")


#let translation = (
  Definition: (en: "Definition", fr: "Définition", ko: "정의", ja: "定義", zh: "定义"),
  Lemma: (en: "Lemma", fr: "Lemme", ko: "보조정리", ja: "補題", zh: "引理"),
  Proof: (en: "Proof", fr: "Démonstration", ko: "증명", ja: "証明", zh: "证明"),
  Theorem: (en: "Theorem", fr: "Théorème", ko: "정리", ja: "定理", zh: "定理"),
  Example: (en: "Example", fr: "Exemple", ko: "예제", ja: "示例", zh: "示例"),
)

#let Definition(name: [], color: rgb("#794e04"), it) = theoframe(
  framename: [#context translation.Definition.at(text.lang, default: "Definition")],
  Definition_counter,
  name: [#name],
  color: color,
  it,
)

#let Lemma(name: [], color: rgb("#020202"), it) = theoframe(
  framename: [#context translation.Lemma.at(text.lang, default: "Lemma")],
  Lemma_counter,
  name: [#name],
  color: color,
  it,
)

#let Proof(name: [], color: rgb("#050505"), it) = theoframe(
  framename: [#context translation.Proof.at(text.lang, default: "Proof")],
  Proof_counter,
  name: [#name],
  color: color,
  it,
)

#let Theorem(name: [], color: rgb("#09658a"), it) = theoframe(
  framename: [#context translation.Theorem.at(text.lang, default: "Theorem")],
  Theorem_counter,
  name: [#name],
  color: color,
  it,
)

#let Example(name: [], color: rgb("#030303"), it) = theoframe(
  framename: [#context translation.Example.at(text.lang, default: "Example")],
  Example_counter,
  name: [#name],
  color: color,
  it,
)

#show heading.where(level: 1): it => {
  Definition_counter.update(0)
  Lemma_counter.update(0)
  Theorem_counter.update(0)
  Proof_counter.update(0)
  Example_counter.update(0)
  it
}


