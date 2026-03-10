// ---------------------------------------------
// Typst Thesis Template - Innopolis University
// ---------------------------------------------

// -----------------------<< title-page >>------------------------

#let title-page(
  program-code: "",
  program-ru: "",
  program-en: "",
  work-ru: "",
  work-en: "",
  specialty-ru: "",
  specialty-en: "",
  topic-ru: "",
  topic-en: "",
  author-ru: "",
  author-en: "",
  supervisor-ru: "",
  supervisor-en: "",
  consultants: "",
  year: "",
) = {
  set page(paper: "a4", margin: (top: 2.5cm, bottom: 1cm))
  set text(size: 14pt)

  align(center)[
    *Автономная некоммерческая организация высшего образования* \
    *«Университет Иннополис»* \
    *(АНО ВО «Университет Иннополис»)*

    *ВЫПУСКНАЯ КВАЛИФИКАЦИОННАЯ РАБОТА* \
    *(#work-ru)* \
    по направлению подготовки \
    *#program-code – «#program-ru»*

    *GRADUATION THESIS* \
    *(#work-en)* \
    *Field of Study* \
    *#program-code – “#program-en”*

    *Направленность (профиль) образовательной программы* \
    *«#specialty-ru»* \
    *Area of Specialization / Academic Program Title:* \
    *“#specialty-en”*

    #grid(
      columns: (0.5fr, 5fr),
      column-gutter: 7pt,
      [#box(inset: 4pt)[*Тема / Topic*]],
      [#align(left)[#box(stroke: 0.5pt + black, fill: silver, width: 100%, inset: 6pt)[
        *#topic-ru / #topic-en*
      ]]],
    ) \
    #grid(
      columns: (1fr, 1.5fr, 1fr),
      column-gutter: (20pt, 1pt, 1pt),
      [#box(inset: (left: 1pt, right: 1pt))[#align(left)[Работу выполнил / Thesis is executed by]]],
      [
        #align(left)[
          #box(stroke: 0.5pt + black, fill: silver, width: 100%, height: 30mm, inset: 6pt)[
            *#author-ru / #author-en*
          ]
        ]],

      [#box(stroke: 0.5pt + black, height: 30mm, fill: silver, inset: (bottom: 10pt, right: 20pt, left: 20pt))[
          #align(bottom)[#text(size: 8pt, fill: black)[подпись / signature]]]
      ],
    )
    #grid(
      columns: (1fr, 1.5fr, 1fr),
      column-gutter: (20pt, 1pt, 1pt),
      [#box(inset: (left: 1pt, right: 1pt))[#align(
        left,
      )[Руководитель выпускной квалификационной работы / Graduation Thesis Supervisor]]],
      [
        #align(left)[
          #box(stroke: 0.5pt + black, fill: silver, width: 100%, height: 35mm, inset: 6pt)[
            *#supervisor-ru / #supervisor-en*
          ]
        ]],

      [#box(stroke: 0.5pt + black, height: 35mm, fill: silver, inset: (bottom: 10pt, right: 20pt, left: 20pt))[
          #align(bottom)[#text(size: 8pt, fill: black)[подпись / signature]]]
      ],
    )

    #if (consultants != "") {
      grid(
        columns: (1fr, 1.5fr, 1fr),
        column-gutter: (20pt, 1pt, 1pt),
        [#box(inset: (left: 1pt, right: 100pt))[#align(left)[Консультанты / Consultants]]],
        [
          #align(left)[
            #box(stroke: 0.5pt + black, fill: silver, width: 100%, height: 30mm, inset: 6pt)[
              *#consultants*
            ]
          ]],

        [#box(stroke: 0.5pt + black, height: 30mm, fill: silver, inset: (bottom: 10pt, right: 20pt, left: 20pt))[
            #align(bottom)[#text(size: 8pt, fill: black)[подпись / signature]]]
        ],
      )
    }

    #align(bottom)[Иннополис, Innopolis, #year]
  ]
}

// ---------------------------<< math >>------------------------------
#let theorem(body) = {
  counter("theorem").step()
  block(
    inset: 8pt,
    radius: 4pt,
    context [*Theorem #counter("theorem").display().* #body],
  )
}

#let proof(body) = block(
  inset: (left: 8pt),
  [_Proof._ #body #h(1fr) $square$],
)

#let lemma(body) = {
  counter("lemma").step()
  block(
    inset: 8pt,
    context [*Lemma #counter("lemma").display().* _ #body _],
  )
}

#let corollary(body) = {
  counter("corollary").step()
  block(
    inset: 8pt,
    context [*Corollary #counter("corollary").display().* _ #body _],
  )
}

#let proposition(body) = {
  counter("proposition").step()
  block(
    inset: 8pt,
    context [*Proposition #counter("proposition").display().* _ #body _],
  )
}

#let remark(body) = block(
  inset: 8pt,
  [*Remark.* #body],
)

#let definition(body) = {
  counter("definition").step()
  block(
    inset: 8pt,
    context [*Definition #counter("definition").display().* #body],
  )
}

#let example(body) = block(
  inset: 8pt,
  [*Example.* #body],
)


// -----------------------<< needed globals >>-------------------------

// variable to detect when outline is being processed
#let in-outline = state("in-outline", false)

// variable to detect when page header is being processed
#let in-header = state("in-header", false)

// method for working with captions that have different representations in outlines
#let flex-title(long, short) = context {
  if in-outline.get() or in-header.get() {
    short
  } else {
    long
  }
}

// -----------------------<< main definition >>-------------------------
#let thesis(
  abstract: [],
  font-size: 14pt,
  font-family: "Liberation Serif",
  chap-title-size: 30pt,
  h1-size: 35pt,
  h2-size: 20pt,
  h3-size: 17pt,
  doc,
) = {
  // -------------------------<< essentials >>------------------------
  set text(
    size: font-size,
    font: font-family,
  )
  set page(
    paper: "a4",
    margin: (
      left: 2.5cm,
      top: 4cm,
      right: 2cm,
      bottom: 2cm,
    ),
  )
  set par(
    leading: 1.5em,
    first-line-indent: 1.25cm,
    justify: true,
    spacing: 1.5em,
  )

  set quote(block: true)
  show quote: set pad(x: 3em)

  // ---------------------<< helper methods >>--------------------------
  let numbering-h(c) = {
    return numbering(c.numbering, ..counter(heading).at(c.location()))
  }

  let current-h() = {
    let elems = query(selector(heading).after(here()))
    if elems.len() != 0 and elems.first().location().page() == here().page() {
      return [#numbering-h(elems.first()) #elems.first().body]
    } else {
      elems = query(selector(heading).before(here()))
      if elems.len() != 0 {
        return [#numbering-h(elems.last()) #elems.last().body]
      }
    }
    return ""
  }

  // ----------------------<< outlines >>------------------------------

  show outline.entry.where(level: 1): set block(above: 2em)

  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  show outline.entry: it => {
    if it.level == 1 and (it.element.supplement == [Section] or it.element.supplement == [Appendix]) {
      link(
        it.element.location(),
        it.indented(
          if it.element.body != [Bibliography cited] { strong(it.prefix()) },
          strong(it.body()) + h(1em) + box(width: 1fr, repeat([ ], gap: 0.5em)) + h(1em) + strong(it.page()),
        ),
      )
    } else if it.element.supplement == [Fig.] or it.element.supplement == [TABLE] {
      link(
        it.element.location(),
        it.indented(
          it.prefix().children.at(2),
          it.body() + h(1em) + box(width: 1fr, repeat([.], gap: 0.5em)) + h(1em) + it.page(),
        ),
      )
    } else {
      link(
        it.element.location(),
        it.indented(
          it.prefix(),
          it.body() + h(1em) + box(width: 1fr, repeat([.], gap: 0.4em)) + h(1em) + it.page(),
        ),
      )
    }
  }

  outline(
    indent: auto,
    title: [\ \ #text(size: h1-size)[Contents] #linebreak() #linebreak()],
    depth: 3,
  )
  pagebreak()

  context {
    let figures = query(figure.where(kind: image))
    if figures.len() > 0 {
      outline(
        target: figure.where(kind: image),
        indent: auto,
        title: [\ \ #text(size: h1-size)[List of Figures] #linebreak() #linebreak()],
      )
      pagebreak()
    }
  }

  context {
    let tables = query(figure.where(kind: table))
    if tables.len() > 0 {
      outline(
        target: figure.where(kind: table),
        indent: auto,
        title: [\ \ #text(size: h1-size)[List of Tables] #linebreak() #linebreak()],
      )
      pagebreak()
    }
  }

  // ----------------------<< abstract >>--------------------------------------

  align(center, text(font-size)[\ \ *Abstract* \ \ #abstract])
  pagebreak()

  // -------------------<< page headers >>-------------------------------------
  set page(
    header: context [
      #in-header.update(true)
      #let h1s = query(heading.where(level: 1))
      #let cover = h1s.any(h => h.location().page() == here().page())
      #if cover {
        none
      } else {
        [#set text(weight: "bold", hyphenate: false, top-edge: 1pt)
          #grid(
            columns: (1fr, auto),
            column-gutter: 10pt,
            [#current-h()],
            [#block(
              inset: (x: 8pt),
              [#counter(page).display()],
            )],
          )
          #line(length: 100%, stroke: 0.5pt)]
      }
      #in-header.update(false)
    ],
  )

  // ----------------------<< headings >>----------------------------
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): it => {
    set text(size: h1-size, weight: "bold")
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)

    pagebreak(weak: true)
    if it.body == [Bibliography cited] {
      align(left)[
        \ #it.body
      ]
    } else if it.supplement == [Appendix] {
      align(left)[
        \ #text(size: chap-title-size)[Appendix] #counter(heading).display("A") \ #it.body
      ]
    } else {
      align(left)[
        \ #text(size: chap-title-size)[Chapter] #counter(heading).display("1.1.1") \ #it.body
      ]
    }
  }

  show heading.where(level: 2): it => {
    set text(size: h2-size, weight: "bold")
    set par(first-line-indent: 0pt)
    align(left)[#counter(heading).display(it.numbering) #it.body]
  }

  show heading.where(level: 3): it => {
    set text(size: h3-size, weight: "bold")
    set par(first-line-indent: 0pt)
    align(left)[#counter(heading).display(it.numbering) #it.body]
  }

  show heading.where(level: 4): it => {
    set text(size: font-size, weight: "bold")
    set par(first-line-indent: 0pt)
    align(left)[#it.body]
  }

  show heading.where(level: 5): it => {
    set text(size: font-size, weight: "bold")
    set par(first-line-indent: 0pt)
    align(left)[#it.body]
  }

  // ----------------<< figures and tables >>----------------------
  set figure(
    gap: 1em,
    numbering: num => ((counter(heading).get().first(),) + (num,)).map(str).join("."),
    supplement: "Fig.",
  )

  set math.equation(
    numbering: num => "(" + ((counter(heading).get().first(),) + (num,)).map(str).join(".") + ")",
  )

  show figure.caption: it => {
    set text(size: font-size)
    set par(leading: 0.5em)
    it
  }

  show figure.where(
    kind: table,
  ): set figure.caption(position: top, separator: linebreak())
  show figure.where(kind: table): set block(breakable: true)

  show figure.where(
    kind: image,
  ): set figure.caption(position: bottom, separator: ". ")

  doc
}

//---------------------<< appendices >>-------------------------
#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  counter(heading).update(0)
  body
}
