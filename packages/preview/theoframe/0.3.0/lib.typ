// theoframe: A Typst package providing 13 theorem-like environments (e.g., Definition, Theorem, Proof)
// with automatic section-based numbering, multilingual localization, and customizable color themes.
// Implemented on top of native figure and counter primitives.

#let trans = (
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

#let trans-array = trans.values().map(v => v.en)

// Generate a composite figure numbering for the given figure kind and location
#let theo-number(kind, loc) = context {
  let h-counter = counter(heading.where(level: 1)).at(loc)
  let f-counter = counter(figure.where(kind: kind)).at(loc)
  numbering("1.", ..h-counter) + numbering("a", ..f-counter)
}

// Generate the full caption string for the given figure element
// By combining the element's supplement with its  composite numbering at the element location.
#let theo-cap-title(element) = context {
  let loc = element.location()
  element.supplement + " " + theo-number(element.kind, loc)
}


// Bordered theorem environment: renders a rectangular frame with a colored left stroke,
// a tinted header bar displaying the title and number, and a dedicated content area.
#let theoframe(name: [], framename: [], kind: "", color: none, it) = figure(
  block(
    width: 100%,
    stroke: (left: 2pt + color),
    inset: 0em,
  )[
      #block(width: 100%, inset: 1em, outset: 0em, below: 0em, fill: color.lighten(80%).transparentize(70%))[
        #align(left)[#text(fill: color, weight: 700)[#framename #context theo-number(kind, here()) #h(1em) ] #text(
            weight: 500,
          )[#name]]
      ]
      #block(width: 100%, inset: 1em, outset: 0em, above:0em, fill: color.lighten(80%).transparentize(90%))[
        #align(left)[#it]
      ]

  ],
  kind: kind,
  supplement: framename,
  numbering: _ => context theo-number(kind, here()),
  outlined: true,
  caption: none,
)


// Minimal theorem environment: presents the heading and content inline without a surrounding border,
// appending a customizable trailing symbol (e.g., a Q.E.D. marker).
#let theocolor(name: [], framename: [], kind: "", color: none, sym, it) = figure(
  rect(
    width: 100%,
    inset: 0em,
    stroke: none,
  )[
    #align(left)[
      #text(fill: color, weight: 700)[#framename #context theo-number(kind, here()) #h(1em) ]
      #text(weight: 500)[#name]
      #linebreak()
      #it #text(fill: color)[#sym]
    ]
  ],
  kind: kind,
  supplement: framename,
  numbering: _ => context theo-number(kind, here()),
  outlined: true,
  caption: none,
)


#let definition(name: [], color: rgb("#794e04"), it) = theoframe(
  name: [#name],
  framename: context trans.definition.at(text.lang, default: "Definition"),
  kind: "Definition",
  color: color,
  it,
)

#let postulate(name: [], color: rgb("#5a3d00"), it) = theoframe(
  name: [#name],
  framename: context trans.postulate.at(text.lang, default: "Postulate"),
  kind: "Postulate",
  color: color,
  it,
)

#let assumption(name: [], color: rgb("#4a4a4a"), it) = theoframe(
  name: [#name],
  framename: context trans.assumption.at(text.lang, default: "Assumption"),
  kind: "Assumption",
  color: color,
  it,
)

#let conjecture(name: [], color: rgb("#6a1b9a"), it) = theoframe(
  name: [#name],
  framename: context trans.conjecture.at(text.lang, default: "Conjecture"),
  kind: "Conjecture",
  color: color,
  it,
)

#let proposition(name: [], color: rgb("#1b5e20"), it) = theoframe(
  name: [#name],
  framename: context trans.proposition.at(text.lang, default: "Proposition"),
  kind: "Proposition",
  color: color,
  it,
)

#let lemma(name: [], color: rgb("#020202"), it) = theoframe(
  name: [#name],
  framename: context trans.lemma.at(text.lang, default: "Lemma"),
  kind: "Lemma",
  color: color,
  it,
)

#let proof(name: [], color: rgb("#050505"), it) = theocolor(
  name: [#name],
  framename: context trans.proof.at(text.lang, default: "Proof"),
  kind: "Proof",
  color: color,
  sym.square.filled,
  it,
)

#let theorem(name: [], color: rgb("#09658a"), it) = theoframe(
  name: [#name],
  framename: context trans.theorem.at(text.lang, default: "Theorem"),
  kind: "Theorem",
  color: color,
  it,
)

#let corollary(name: [], color: rgb("#0d47a1"), it) = theoframe(
  name: [#name],
  framename: context trans.corollary.at(text.lang, default: "Corollary"),
  kind: "Corollary",
  color: color,
  it,
)

#let example(name: [], color: rgb("#030303"), it) = theocolor(
  name: [#name],
  framename: context trans.example.at(text.lang, default: "Example"),
  kind: "Example",
  color: color,
  sym.square.filled,
  it,
)

#let problem(name: [], color: rgb("#b71c1c"), it) = theocolor(
  name: [#name],
  framename: context trans.problem.at(text.lang, default: "Problem"),
  kind: "Problem",
  color: color,
  sym.square.filled,
  it,
)

#let solution(name: [], color: rgb("#1a237e"), it) = theocolor(
  name: [#name],
  framename: context trans.solution.at(text.lang, default: "Solution"),
  kind: "Solution",
  color: color,
  sym.square.filled,
  it,
)

#let conclusion(name: [], color: rgb("#004d40"), it) = theoframe(
  name: [#name],
  framename: context trans.conclusion.at(text.lang, default: "Conclusion"),
  kind: "Conclusion",
  color: color,
  it,
)


#let reset-fig-counter-per-level1-heading(it) = {
  for k in trans-array {
    counter(figure.where(kind: k)).update(0)
  }
  it
}

#let refer(it) = {
  set text(fill: blue)
  if (it.element.func() != figure) {
    return it
  } else if (it.element.kind not in trans-array) { return it } else {
    link(
      it.element.location(),
      theo-cap-title(it.element),
    )
  }
}

#let outline-entry(it) = if (it.element.func() != figure) { return it } else if (
  it.element.kind not in trans-array
) { return it } else {
  link(
    it.element.location(),
    it.indented(theo-cap-title(it.element), it.inner()),
  )
}

#let reset(doc) = {
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => reset-fig-counter-per-level1-heading(it)

  show ref: it => refer(it)

  show outline.entry: it => outline-entry(it)

  doc
}