// thmbox: A Typst package providing 19 theorem-like environments (e.g., Definition, Theorem, Proof)
// with automatic section-based numbering, multilingual localization, and customizable color themes.
// Implemented on top of native figure and counter primitives.

#let theme_ = state("theme_", (style: "minimal", color: rgb("#0048ff")))


//=============================================================================
//Generate a composite figure numbering for the given figure kind and location
#let fig-number(kind, loc) = context {
  let h-counter = counter(heading.where(level: 1)).at(loc)
  let f-counter = counter(figure.where(kind: kind)).at(loc)
  numbering("1.", ..h-counter) + numbering("a", ..f-counter)
}

// Generate a composite figure supplement for the given figure element
#let fig-supplement(fig) = context {
  fig.supplement + " " + fig-number(fig.kind, fig.location())
}

#let cap(str) = upper(str.at(0)) + str.slice(1)


//=============================================================================
#let thm-dict = (
  definition: (en: "Definition", fr: "Définition", ko: "정의", ja: "定義", zh: "定义"),
  property: (en: "Property", fr: "Propriété", ko: "성질", ja: "性質", zh: "性质"),
  axiom: (en: "Axiom", fr: "Axiome", ko: "공리", ja: "公理", zh: "公理"),
  postulate: (en: "Postulate", fr: "Postulat", ko: "공준", ja: "公準", zh: "公设"),
  assumption: (en: "Assumption", fr: "Hypothèse", ko: "가정", ja: "仮定", zh: "假设"),
  hypothesis: (en: "Hypothesis", fr: "Hypothèse", ko: "가설", ja: "仮説", zh: "假说"),
  conjecture: (en: "Conjecture", fr: "Conjecture", ko: "추측", ja: "予想", zh: "猜想"),
  proposition: (en: "Proposition", fr: "Proposition", ko: "명제", ja: "命題", zh: "命题"),
  lemma: (en: "Lemma", fr: "Lemme", ko: "보조정리", ja: "補題", zh: "引理"),
  theorem: (en: "Theorem", fr: "Théorème", ko: "정리", ja: "定理", zh: "定理"),
  corollary: (en: "Corollary", fr: "Corollaire", ko: "따름정리", ja: "系", zh: "推论"),
)

#let thm-array = thm-dict.values().map(v => lower(v.en))


#let thmbox(trans-supplement: [], kind: "", color: auto, name: [], content) = figure(
  context {
    let computed-color = if color == auto { theme_.final().color } else { color }
    if theme_.final().style == "minimal" {
      block(
        width: 100%,
      )[
        #align(left)[
            #trans-supplement #context fig-number(kind, here())
            #h(1em)
            #emph(name)
            #h(1em)
            #content
        ]
      ]
    } else if theme_.final().style == "box" {
      block(
        width: 100%,
        stroke: (left: 0.2pt + computed-color),
        inset: 0em,
      )[
        #block(
          width: 100%,
          inset: 1em,
          below: 0em,
          fill: computed-color.lighten(80%).transparentize(70%),
        )[
          #align(left)[#text(fill: computed-color.darken(50%), weight: 700)[#trans-supplement #context fig-number(
                kind,
                here(),
              ) #h(1em) ] #text(
              weight: 500,
            )[#name]]
        ]
        #block(
          width: 100%,
          inset: 1em,
          above: 0em,
          fill: computed-color.lighten(80%).transparentize(90%),
        )[
          #align(left)[#content]
        ]
      ]
    }
  },
  kind: kind,
  supplement: trans-supplement,
  numbering: _ => context fig-number(kind, here()),
  outlined: true,
  caption: none,
)

#let definition(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.definition.at(text.lang, default: "Definition"),
  kind: "definition",
  color: color,
  name: name,
  content,
)


#let property(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.property.at(text.lang, default: "Property"),
  kind: "property",
  color: color,
  name: name,
  content,
)


#let axiom(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.axiom.at(text.lang, default: "Axiom"),
  kind: "axiom",
  color: color,
  name: name,
  content,
)


#let postulate(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.postulate.at(text.lang, default: "Postulate"),
  kind: "postulate",
  color: color,
  name: name,
  content,
)


#let assumption(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.assumption.at(text.lang, default: "Assumption"),
  kind: "assumption",
  color: color,
  name: name,
  content,
)


#let hypothesis(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.hypothesis.at(text.lang, default: "Hypothesis"),
  kind: "hypothesis",
  color: color,
  name: name,
  content,
)


#let conjecture(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.conjecture.at(text.lang, default: "Conjecture"),
  kind: "conjecture",
  color: color,
  name: name,
  content,
)


#let proposition(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.proposition.at(text.lang, default: "Proposition"),
  kind: "proposition",
  color: color,
  name: name,
  content,
)


#let lemma(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.lemma.at(text.lang, default: "Lemma"),
  kind: "lemma",
  color: color,
  name: name,
  content,
)


#let theorem(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.theorem.at(text.lang, default: "Theorem"),
  kind: "theorem",
  color: color,
  name: name,
  content,
)


#let corollary(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.corollary.at(text.lang, default: "Corollary"),
  kind: "corollary",
  color: color,
  name: name,
  content,
)

//=============================================================================
#let support-dict = (
  proof: (en: "Proof", fr: "Démonstration", ko: "증명", ja: "証明", zh: "证明"),
  example: (en: "Example", fr: "Exemple", ko: "예제", ja: "示例", zh: "示例"),
  exercise: (en: "Exercise", fr: "Exercice", ko: "연습", ja: "演習", zh: "练习"),
  problem: (en: "Problem", fr: "Problème", ko: "문제", ja: "問題", zh: "问题"),
  solution: (en: "Solution", fr: "Solution", ko: "풀이", ja: "解答", zh: "解答"),
  conclusion: (en: "Conclusion", fr: "Conclusion", ko: "결론", ja: "結論", zh: "结论"),
)


#let support-array = support-dict.values().map(v => lower(v.en))


#let thmplain(trans-supplement: [], kind: "", color: auto, name: [], content) = figure(
  block(
    width: 100%,
    inset: 0em,
    stroke: none,
  )[
    #align(left)[
      #text(weight: 500)[ #trans-supplement #context fig-number(kind, here()) #h(1em) ]
      #emph(name) #h(1em)
      #content
    ]

  ],
  kind: kind,
  supplement: trans-supplement,
  numbering: _ => fig-number(kind, here()),
  outlined: true,
  caption: none,
)



#let proof(name: [], color: auto, content) = thmplain(
  trans-supplement: context support-dict.proof.at(text.lang, default: "Proof"),
  kind: "proof",
  color: color,
  name: name,
  content,
)


#let example(name: [], color: auto, content) = thmplain(
  trans-supplement: context support-dict.example.at(text.lang, default: "Example"),
  kind: "example",
  color: color,
  name: name,
  content,
)


#let exercise(name: [], color: auto, content) = thmplain(
  trans-supplement: context support-dict.exercise.at(text.lang, default: "Exercise"),
  kind: "exercise",
  color: color,
  name: name,
  content,
)


#let problem(name: [], color: auto, content) = thmplain(
  trans-supplement: context support-dict.problem.at(text.lang, default: "Problem"),
  kind: "problem",
  color: color,
  name: name,
  content,
)


#let solution(name: [], color: auto, content) = thmplain(
  trans-supplement: context support-dict.solution.at(text.lang, default: "Solution"),
  kind: "solution",
  color: color,
  name: name,
  content,
)


#let conclusion(name: [], color: auto, content) = thmplain(
  trans-supplement: context support-dict.conclusion.at(text.lang, default: "Conclusion"),
  kind: "conclusion",
  color: color,
  name: name,
  content,
)


//=============================================================================
#let note-dict = (
  remark: (en: "Remark", fr: "Remarque", ko: "주의", ja: "注意", zh: "注记"),
  note: (en: "Note", fr: "Note", ko: "노트", ja: "ノート", zh: "注释"),
)

#let note-array = note-dict.values().map(v => lower(v.en))

#let notebox(trans-supplement: [], kind: "", color: auto, name: [], content) = figure(
  block(
    width: 100%,
    stroke: (left: 2pt + color),
    inset: 0em,
  )[
    #context [
      #let computed-color = if color == auto {theme_.final().color} else {color}
      #block(width: 100%, inset: 1em, outset: 0em, below: 0em, fill: color.lighten(80%).transparentize(70%))[
        #align(left)[#text(fill: color.darken(90%), weight: 700)[#trans-supplement #fig-number(kind, here()) #h(
              1em,
            ) ] #text(
            weight: 500,
          )[#name]]
      ]
      #block(width: 100%, inset: 1em, outset: 0em, above: 0em, fill: color.lighten(80%).transparentize(90%))[
        #align(left)[#content]
      ]
    ]
  ],
  kind: kind,
  supplement: trans-supplement,
  numbering: _ => fig-number(kind, here()),
  outlined: true,
  caption: none,
)


#let remark(name: [], color: auto, content) = notebox(
  trans-supplement: context note-dict.remark.at(text.lang, default: "Remark"),
  kind: "remark",
  color: color,
  name: name,
  content,
)


#let note(name: [], color: auto, content) = notebox(
  trans-supplement: context note-dict.note.at(text.lang, default: "Note"),
  kind: "note",
  color: color,
  name: name,
  content,
)

//=============================================================================

#let kind-array = thm-array + support-array + note-array

#let reset-fig-counter-per-level1-heading(h1) = {
  for k in kind-array {
    counter(figure.where(kind: k)).update(0)
  }
  h1
}

#let refer(it) = {
  if (it.element == none or it.element.func() != figure) {
    return it
  } else if (it.element.kind not in kind-array) { return it } else {
    link(
      it.element.location(),
      [#h(0.2em) #emph(fig-supplement(it.element))  #h(0.2em)],
    )
  }
}

#let outline-entry(it) = if (it.element == none or it.element.func() != figure) { return it } else if (
  it.element.kind not in kind-array
) { return it } else {
  link(
    it.element.location(),
    it.indented(fig-supplement(it.element), it.inner()),
  )
}

//=============================================================================
#let reset(theme: (style: "box", color: rgb("#000000")), doc) = {
  theme_.update((style: theme.style, color: theme.color))

  set heading(numbering: "1.1")

  set par(leading: 0.8em, spacing: 2em)

  show heading.where(level: 1): h1 => reset-fig-counter-per-level1-heading(h1)

  show ref: it => refer(it)

  show outline.entry: it => outline-entry(it)

  doc
}




