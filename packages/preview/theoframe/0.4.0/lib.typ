// theoframe:0.4.0 A Typst package providing 19 theorem-like environments (e.g., Definition, Theorem, Proof)
// with multilingual localization, customizable style and color themes.

#let thm-dict = (
  definition: (en: "Definition", zh: "定义"),
  property: (en: "Property", zh: "性质"),
  axiom: (en: "Axiom", zh: "公理"),
  postulate: (en: "Postulate", zh: "公设"),
  assumption: (en: "Assumption", zh: "假设"),
  hypothesis: (en: "Hypothesis", zh: "假说"),
  conjecture: (en: "Conjecture", zh: "猜想"),
  proposition: (en: "Proposition", zh: "命题"),
  lemma: (en: "Lemma", zh: "引理"),
  theorem: (en: "Theorem", zh: "定理"),
  corollary: (en: "Corollary", zh: "推论"),
  remark: (en: "Remark", zh: "注记"),
  note: (en: "Note", zh: "注释"),
)

#let thm-array = thm-dict.values().map(v => lower(v.en))

#let support-dict = (
  proof: (en: "Proof", zh: "证明"),
  example: (en: "Example", zh: "例"),
  exercise: (en: "Exercise", zh: "练习"),
  problem: (en: "Problem", zh: "问题"),
  solution: (en: "Solution", zh: "解答"),
  conclusion: (en: "Conclusion", zh: "结论"),
)

#let support-array = support-dict.values().map(v => lower(v.en))

#let kind-array = thm-array + support-array

#let theoframe-theme = state("theoframe-theme", (style: "minimal", color: rgb("#000000")))

#let my-chapter-counter = counter("my-chapter")


// 然后在你的 fig-number 中使用：
#let fig-number(kind, loc) = context {
  let h-counter = my-chapter-counter.at(loc)
  let f-counter = counter(figure.where(kind: kind)).at(loc)
  numbering("1.", ..h-counter) + numbering("a", ..f-counter)
}


// Create a template function used to produce a figure with customizable style and color.
#let thmbox(trans-supplement: [], kind: "", color: auto, name: [], content) = figure(
  context {
    let computed-color = if (color != auto) { color } else { theoframe-theme.final().color }

    if (target() == "html" or target() == "bundle") {
      html.elem("div", attrs: (
        class: "thmbox",
        style: "border-left: 5px solid #aaaaaa; border-radius: 10px; background: #f1f1f1; padding: 0.8em;",
      ))[
        #strong()[#trans-supplement] #fig-number(kind, here()) #str(
          "  ",
        ) #name #linebreak() #linebreak()  #content
      ]
    } else {
      if theoframe-theme.final().style == "minimal" {
        block(
          width: 100%,
        )[
          #set align(left)
          #text(weight: 600)[#trans-supplement] #fig-number(kind, here())  #h(1em) #name  #h(
            1em,
          ) #linebreak() #content]
      } else if theoframe-theme.final().style == "box" {
        stack(
          block(
            width: 100%,
            inset: 1em,
            stroke: (
              left: (thickness: 2pt, paint: computed-color, join: "bevel"),
            ),
            fill: computed-color.lighten(20%).transparentize(90%),
          )[
            #set align(left)
            #text(weight: 600)[#trans-supplement]
            #fig-number(kind, here()) #h(1em)
            #name #linebreak()
          ],
          block(
            width: 100%,
            inset: 1em,
            stroke: (
              left: (thickness: 2pt, paint: computed-color, join: "bevel"),
            ),
            fill: computed-color.lighten(20%).transparentize(98%),
          )[
            #set align(left)
            #content
          ],
        )
      } else { panic("Unknown theme style. Available: 'minimal', 'box'") }
    }
  },
  kind: kind,
  supplement: trans-supplement,
  numbering: _ => fig-number(kind, here()),
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

#let remark(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.remark.at(text.lang, default: "Remark"),
  kind: "remark",
  color: color,
  name: name,
  content,
)

#let note(name: [], color: auto, content) = thmbox(
  trans-supplement: context thm-dict.note.at(text.lang, default: "Note"),
  kind: "note",
  color: color,
  name: name,
  content,
)


// Create another template function used to produce a figure with very plain appearance.
#let thmplain(trans-supplement: [], kind: "", color: auto, name: [], content) = figure(
  context {
    let computed-color = if (color != auto) { color } else { theoframe-theme.final().color }
    if (target() == "html" or target() == "bundle") {
      html.elem("div", attrs: (
        class: "thmplain",
        style: " border-left: 5px solid #aaaaaa; border-radius: 10px; background: #f1f1f1; padding: 0.8em;",
      ))[
        #strong()[#trans-supplement] #fig-number(kind, here()) #str("  ")
        #name #linebreak() #linebreak()
        #content
      ]
    } else {
      block(
        width: 100%,
        inset: 1em,
        fill: computed-color.lighten(10%).transparentize(95%),
        radius: 1em,
      )[
        #set align(left)
        #text(weight: 600)[ #trans-supplement] #fig-number(kind, here()) #h(1em)
        #name #h(1em) #linebreak()
        #content
      ]
    }
  },
  kind: kind,
  supplement: trans-supplement,
  numbering: _ => fig-number(kind, here()),
  outlined: false,
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

//reset the figure counter to zero when encountering a level1 heading
#let reset-fig-counter-per-level1-heading(h1) = {
  for k in kind-array {
    counter(figure.where(kind: k)).update(0)
  }
  h1
}


//customize document's style
#let theoframe-setup(theme: (style: "minimal", color: rgb("#000000")), doc) = {
  theoframe-theme.update((style: theme.style, color: theme.color))

  // 重置计数器，确保安全
  my-chapter-counter.update(0)

  show heading.where(level: 1): it => {
    my-chapter-counter.step()
    it
  }

  show heading.where(level: 1): h1 => reset-fig-counter-per-level1-heading(h1)

  set par(justify: true)

  set text(cjk-latin-spacing: auto, hyphenate: true)

  // set heading(numbering: "1.")

  show heading.where(level: 1): set text(fill: theme.color.darken(20%))

  show figure: set block(breakable: true)
  
  show figure.where(kind: "diagram"): it => {
    if (target() == "bundle" or target() == "html") {
      html.elem(
        "div",
        attrs: (
          style: "width: 100%; margin: 10pt auto; display: flex; justify-content: center",
          class: "typst-diagram",
        ),
        html.frame(it),
      )
    } else { it }
  }

  doc
}
