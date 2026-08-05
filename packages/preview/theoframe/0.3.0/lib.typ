// thmbox: A Typst package providing 19 theorem-like environments (e.g., Definition, Theorem, Proof)
// with automatic section-based numbering, multilingual localization, and customizable color themes.
// Implemented on top of native figure and counter primitives.

#import "./src/translations.typ":*

//====================================================================================================
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


//=====================================================================================================

#let thmbox(trans-supplement: [], kind: "", color: rgb("#000000"), name: [], content) = figure(
  block(
    width: 100%,
    stroke: none,
    inset: 0em,
  )[
    #block(width: 100%, inset: 0em, outset: 0em, below: 0em)[
      #align(left)[#text(fill: color.darken(30%))[ #text(weight: 500)[#trans-supplement]  #context fig-number(
            kind,
            here(),
          ) #h(
            1em,
          ) ] #emph(name)  #h(2em) #content]
    ]
  ],
  kind: kind,
  supplement: trans-supplement,
  numbering: _ => context fig-number(kind, here()),
  outlined: true,
  caption: none,
)


#let definition(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.definition.at(text.lang, default: "Definition"),
  kind: "definition",
  color: color,
  name: name,
  content,
)


#let property(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.property.at(text.lang, default: "Property"),
  kind: "property",
  color: color,
  name: name,
  content,
)


#let axiom(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.axiom.at(text.lang, default: "Axiom"),
  kind: "axiom",
  color: color,
  name: name,
  content,
)


#let postulate(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.postulate.at(text.lang, default: "Postulate"),
  kind: "postulate",
  color: color,
  name: name,
  content,
)


#let assumption(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.assumption.at(text.lang, default: "Assumption"),
  kind: "assumption",
  color: color,
  name: name,
  content,
)


#let hypothesis(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.hypothesis.at(text.lang, default: "Hypothesis"),
  kind: "hypothesis",
  color: color,
  name: name,
  content,
)


#let conjecture(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.conjecture.at(text.lang, default: "Conjecture"),
  kind: "conjecture",
  color: color,
  name: name,
  content,
)


#let proposition(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.proposition.at(text.lang, default: "Proposition"),
  kind: "proposition",
  color: color,
  name: name,
  content,
)


#let lemma(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.lemma.at(text.lang, default: "Lemma"),
  kind: "lemma",
  color: color,
  name: name,
  content,
)


#let theorem(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.theorem.at(text.lang, default: "Theorem"),
  kind: "theorem",
  color: color,
  name: name,
  content,
)


#let corollary(name: [], color: rgb("#000000"), content) = thmbox(
  trans-supplement: context thm-dict.corollary.at(text.lang, default: "Corollary"),
  kind: "corollary",
  color: color,
  name: name,
  content,
)

//=====================================================================================================

#let thmplain(trans-supplement: [], kind: "", color: black, name: [], content) = figure(
  block(
    width: 100%,
    inset: 0em,
    stroke: none,
  )[
    #align(left)[
      #text(weight: 500)[ #text(weight: 500)[#trans-supplement] #context fig-number(kind, here()) #h(1em) ]
      #emph(name) #h(2em)
      #content
      // #text(fill:color.darken(90%))[#sym.square.filled]
    ]
  ],
  kind: kind,
  supplement: trans-supplement,
  numbering: _ => fig-number(kind, here()),
  outlined: true,
  caption: none,
)



#let proof(name: [], color: rgb("#000000"), content) = thmplain(
  trans-supplement: context support-dict.proof.at(text.lang, default: "Proof"),
  kind: "proof",
  color: color,
  name: name,
  content,
)


#let example(name: [], color: rgb("#000000"), content) = thmplain(
  trans-supplement: context support-dict.example.at(text.lang, default: "Example"),
  kind: "example",
  color: color,
  name: name,
  content,
)


#let exercise(name: [], color: rgb("#000000"), content) = thmplain(
  trans-supplement: context support-dict.exercise.at(text.lang, default: "Exercise"),
  kind: "exercise",
  color: color,
  name: name,
  content,
)


#let problem(name: [], color: rgb("#000000"), content) = thmplain(
  trans-supplement: context support-dict.problem.at(text.lang, default: "Problem"),
  kind: "problem",
  color: color,
  name: name,
  content,
)


#let solution(name: [], color: rgb("#000000"), content) = thmplain(
  trans-supplement: context support-dict.solution.at(text.lang, default: "Solution"),
  kind: "solution",
  color: color,
  name: name,
  content,
)


#let conclusion(name: [], color: rgb("#000000"), content) = thmplain(
  trans-supplement: context support-dict.conclusion.at(text.lang, default: "Conclusion"),
  kind: "conclusion",
  color: color,
  name: name,
  content,
)


//=====================================================================================================

#let notebox(trans-supplement: [], kind: "", color: black, name: [], content) = figure(
  block(
    width: 100%,
    stroke: (left: 2pt + color),
    inset: 0em,
  )[
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
  ],
  kind: kind,
  supplement: trans-supplement,
  numbering: _ => fig-number(kind, here()),
  outlined: true,
  caption: none,
)


#let remark(name: [], color: rgb("#000000"), content) = notebox(
  trans-supplement: context note-dict.remark.at(text.lang, default: "Remark"),
  kind: "remark",
  color: color,
  name: name,
  content,
)


#let note(name: [], color: rgb("#000000"), content) = notebox(
  trans-supplement: context note-dict.note.at(text.lang, default: "Note"),
  kind: "note",
  color: color,
  name: name,
  content,
)


//=====================================================================================================

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



//=====================================================================================================
#let reset(style: "minimal", theme-color: rgb("#e7975f"), doc) = {
  set heading(numbering: "1.1")

  set par(leading: 0.8em, spacing: 2em)

  show heading.where(level: 1): h1 => reset-fig-counter-per-level1-heading(h1)

  show ref: it => refer(it)

  show outline.entry: it => outline-entry(it)

  doc
}

