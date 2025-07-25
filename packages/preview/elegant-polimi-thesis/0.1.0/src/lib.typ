#let sizes = (
  tiny: 0.5em,
  scriptsize: 0.7em,
  footnotesize: 0.8em,
  small: 0.9em,
  normalsize: 1em,
  large: 1.2em,
  Large: 1.44em,
  LARGE: 1.728em,
  huge: 2.074em,
  Huge: 2.488em,
)

#let document-state = state("init", "TITLE_PAGE")

#let localization = yaml("locale.yaml")

#let bluepoli = rgb("#5f859f")

#let polimi-thesis(
  title: "Thesis Title",
  author: "Name Surname",
  advisor: "",
  coadvisor: "",
  tutor: "",
  phdcycle: "", // {Year ... - ... Cycle}
  cycle: none,
  chair: none,
  language: "en",
  colored-headings: true,
  main-logo: "img/logo_ingegneria.svg",
  body,
) = {
  set document(
    title: title,
    author: author,
  )

  set text(
    lang: language,
    size: 12pt,
    font: "New Computer Modern",
  )
  show math.equation: set text(font: "New Computer Modern Math")
  
  set par(
    justify: true,
    linebreaks: "optimized",
    spacing: 1.7em,
  )

  set page(
    paper: "a4",
    margin: (
      top: 2.5cm,
      bottom: 2.5cm,
      inside: 3.0cm,
      outside: 2.0cm,
    ),
    numbering: "i",
    header: context {
      if (
        document-state.get() == "TITLE_PAGE"
      ) {
        none
      } else if (
        document-state.get() == "FRONTMATTER" or document-state.get() == "BACKMATTER"
      ) {
        if (calc.even(here().page())) {
          counter(page).display()
          h(1fr)
        } else {
          h(1fr)
          counter(page).display()
        }
      } else if (
        document-state.get() == "MAINMATTER"
          or document-state.get() == "APPENDIX"
          or document-state.get() == "ACKNOWLEDGEMENTS"
      ) {
        let isThereH1 = query(heading.where(level: 1)).filter(h1 => h1.location().page() == here().page())
        let before = query(selector(heading.where(level: 1)).before(here()))

        let output = if not (isThereH1.len() != 0) {
          set text(weight: "bold")
          let heading-num = if (heading.numbering != none) {
            str(counter(heading).display()).split(".").at(0) + "| "
          }
          text(
            fill: if (colored-headings) { bluepoli } else { black },
            heading-num,
          )
          before.last().body
        }

        if (calc.even(here().page())) {
          counter(page).display()
          h(1fr)
          output
        } else {
          output
          h(1fr)
          counter(page).display()
        }
      }
    },
    footer: { },
  )

  // FIGURE

  set figure(gap: 1.5em)

  // Didascalia delle figure
  show figure.caption: it => context {
    if (it.kind != "lists" and it.kind != "blank-toc") {
      let heading_num = counter(heading).get().first()
      text(
        weight: "bold",
        fill: if (colored-headings) { bluepoli } else { black },
        {
          it.supplement
          if it.numbering != none {
            [ ]
            str(heading_num)
            [.]
            if (it.kind == image) {
              counter(figure.where(kind: image)).display()
            } else if (it.kind == table) {
              counter(figure.where(kind: table)).display()
            }
          }
          it.separator
        },
      )
      it.body
    } else {
      it
    }
  }

  // Theorems.
  show figure.where(kind: "theorem"): it => {
    strong({
      it.supplement
      if it.numbering != none {
        [ ]
        str(counter(heading.where(level: 1)).at(it.location()).at(0))
        [.]
        str(counter(figure.where(kind: "theorem")).at(it.location()).at(0))
      }
      [. ]
    })
    emph(it.body)
  }

  // Propositions
  show figure.where(kind: "proposition"): it => {
    strong({
      it.supplement
      if it.numbering != none {
        [ ]
        str(counter(heading.where(level: 1)).at(it.location()).at(0))
        [.]
        str(counter(figure.where(kind: "proposition")).at(it.location()).at(0))
      }
      [. ]
    })
    emph(it.body)
  }

  // show figure.where(kind: "theorem"): it => block(
  //   above: 11.5pt,
  //   below: 11.5pt,
  //   {
  //     strong({
  //       it.supplement
  //       if it.numbering != none {
  //         [ ]
  //         str(counter(heading.where(level: 1)).at(it.location()).at(0))
  //         [.]
  //         str(counter(figure.where(kind: "theorem")).at(it.location()).at(0))
  //       }
  //       [. ]
  //     })

  //     emph(it.body)
  //   },
  // )

  // --------------------- [ TITOLAZIONE ] ---------------------
  // Logo
  v(0.6fr)
  place(
    dx: 44%,
    dy: -28%,
    image("img/raggiera_chiara.svg", width: 90%),
  )
  place(
    dx: 1.5%,
    dy: -1%,
    image(main-logo, width: 73%),
  )

  v(4.20fr)

  // Titolazione
  text(
    size: sizes.huge,
    weight: 700,
    fill: if (colored-headings) { bluepoli } else { black },
    title,
  )
  // v(1.2em, weak: true)
  // text(1.1em, style: "italic", subtitle)

  v(1.5cm)

  align(end)[
    #set text(size: sizes.Large)
    Doctoral Dissertation of: \
    *#author*
  ]

  v(1fr)

  if (phdcycle == "") {
    phdcycle = str(datetime.today().year()) + " - " + str(datetime.today().year() + 1)
  }

  let isPresent(before, string, after: none) = {
    if (string != none and string != "") {
      return before + string + after + linebreak()
    } else {
      return none
    }
  }

  align(
    start,
    {
      set text(size: sizes.large)
      isPresent("Advisor: Prof. ", advisor)
      isPresent("Coadvisor: Prof. ", coadvisor)
      isPresent("Tutor: Prof. ", tutor)
      isPresent("Advisor: Prof. ", advisor)
      isPresent("Year ", phdcycle, after: " Cycle")
    }
  )

  // Document

  show heading: it => {
    if (colored-headings) {
      text(fill: bluepoli, it)
    }
  }
  // --------------------- [ STILE DEI CAPITOLI ] ---------------------

  let raggera = {
    v(1fr)
    place(
      dx: -7cm,
      dy: -16.25cm,
      image(
        "img/raggiera_chiara.svg",
        width: 0.85 * 24cm,
      ),
    )
  }

  show heading.where(level: 1): it => context {
    // checks if the page is empty: the cursor is at the same length from the top as the top margin
    if (calc.even(here().page()) and here().position().y.cm() == page.margin.top.length.cm()) {
      set page(header: { })
    } else if (calc.odd(here().page()) and here().position().y.cm() == page.margin.top.length.cm()) { } else if (
      calc.odd(here().page())
    ) {
      set page(header: { }, background: raggera)
      pagebreak(to: "odd")
    }
    // v(120pt)
    v(4cm)
    set text(
      weight: "bold",
      fill: if (colored-headings) { bluepoli } else { black },
    )

    let heading-num = counter(selector(heading)).display()
    if (
      it.numbering != none and (document-state.get() == "MAINMATTER" or document-state.get() == "APPENDIX")
    ) {
      text(
        size: 50pt,
        weight: "regular",
        text(
          weight: "bold",
          heading-num,
        )
          + h(2mm)
          + "| ",
      )
    }
    text(
      size: 1.5em,
      it.body,
    )
    v(10pt)

    // reset contatori
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "theorem")).update(0)
    counter(figure.where(kind: "proposition")).update(0)
  }

  show heading: it => context {
    if (it.level == 1) {
      it
    } else if (it.level == 2) {
      text(size: sizes.large, it)
    } else if (it.level >= 3) {
      text(size: sizes.large, it)
    }
    v(0.5em)
  }

  // ----------- [ TABLE OF CONTENTS ] -----------
  // I Capitoli sono in grassetto e non hanno le righe
  show outline.entry.where(level: 1): it => context {
    v(19pt, weak: true)
    link(
      it.element.location(),
      strong(it.indented(it.prefix(), it.element.body + h(1fr) + it.page())),
    )
  }

  show outline.entry: it => context {
    v(1em)
    if it.level > 1 {
      v(1em, weak: true)
      let spacing = it.level - 1
      h(2em) * spacing
      // link(it.element.location(), it)
      link(
        it.element.location(),
        it.indented(
          it.prefix(),
          it.element.body + box(width: 1fr, repeat([\u{0009} . \u{0009} \u{0009}])) + it.page(),
        ),
      )
    } else if (
      it.element.func() == figure and it.element.at("kind") == "blank-toc"
    ) {
      v(1em) // \addtocontents{toc}{\vspace{2em}}
    } else {
      it
    }
  }

  // NUMERO -> Body ... pagenum

  // (
  //   body: image(source: "../../src/img/logo_ingegneria.svg"),
  //   placement: none,
  //   scope: "column",
  //   caption: caption(
  //     separator: [: ],
  //     body: [That will appear in the List of Figures.],
  //     kind: image,
  //     supplement: [Figure],
  //     numbering: "1",
  //     counter: counter(figure.where(kind: image)),
  //   ),
  //   kind: image,
  //   supplement: [Figure],
  //   numbering: "1",
  //   gap: 0.65em,
  //   outlined: true,
  //   counter: counter(figure.where(kind: image)),
  // )

  show figure
    .where(kind: "lists")
    .or(figure.where(kind: "blank-toc"))
    .or(figure.where(kind: "theorem"))
    .or(figure.where(kind: "proposition")): it => {
    align(start, it)
  }

  show outline: set heading(bookmarked: true)

  show ref: it => text(
    fill: if (colored-headings) { bluepoli } else { black },
    it,
  )

  set list(indent: 1.2em)

  set enum(indent: 1.2em)

  body
}

#let blank-toc = figure.with(
  kind: "blank-toc",
  numbering: none,
  supplement: none,
  outlined: true,
  caption: [],
)

// Document sections
#let frontmatter(body) = {
  document-state.update("FRONTMATTER")
  // counter(page).update(0)
  set page(numbering: "i")
  set heading(numbering: none)

  body
}

#let acknowledgements(body) = {
  {
    show heading: none
    blank-toc("")
  }
  document-state.update("ACKNOWLEDGEMENTS")
  set heading(numbering: none)

  body
}

#let mainmatter(body) = {
  {
    show heading: none
    blank-toc("")
  }
  document-state.update("MAINMATTER")
  set heading(numbering: "1.1")
  set page(numbering: "1")
  counter(page).update(0)

  body
}

#let appendix(body) = context {
  {
    show heading: none
    blank-toc("")
  }
  document-state.update("APPENDIX")
  counter(heading).update(0)
  set heading(numbering: "A.1")

  body
}

#let backmatter(body) = context {
  {
    show heading: none
    blank-toc("")
  }
  document-state.update("BACKMATTER")
  set heading(numbering: none)

  body
}

// Table of contents

#let target = (
  figure
    .where(
      kind: "lists",
      outlined: true,
    )
    .or(figure.where(kind: "blank-toc", outlined: true))
    .or(heading.where(outlined: true))
)

#let lists = figure.with(
  kind: "lists",
  numbering: none,
  supplement: none,
  outlined: true,
  caption: [],
)

#let toc = context {
  outline(
    title: lists(localization.at(text.lang).toc),
    indent: 1.2em,
    target: target,
  )
}

// Table of contents
#let list-of-figures = context {
  show outline.entry: it => {
    let count = (
      str(counter(heading.where(level: 1)).at(it.element.location()).at(0))
        + "."
        + str(counter(figure.where(kind: image)).at(it.element.location()).at(0))
    )
    link(
      it.element.location(),
      {
        count
        h(1em)
        it.element.at("caption").body
        box(width: 1fr, repeat([. \u{0009} \u{0009}])) // \u{0009} = Tab
        str(counter(page).at(it.element.location()).at(0))
      },
    )
    linebreak()
  }
  outline(
    title: lists(localization.at(text.lang).list-of-figures),
    target: figure.where(kind: image),
  )
}

#let list-of-tables = context {
  show outline.entry: it => {
    let count = (
      str(counter(heading.where(level: 1)).at(it.element.location()).at(0))
        + "."
        + str(counter(figure.where(kind: table)).at(it.element.location()).at(0))
    )
    link(
      it.element.location(),
      {
        count
        h(1em)
        it.element.at("caption").body
        box(width: 1fr, repeat([. \u{0009} \u{0009}])) // \u{0009} = Tab
        str(counter(page).at(it.element.location()).at(0))
      },
    )
    linebreak()
  }
  outline(
    title: lists(localization.at(text.lang).list-of-tables),
    target: figure.where(kind: table),
  )
}

// Nomenclature
#let nomenclature(dict, indented: true) = context {
  heading(
    lists(localization.at(text.lang).nomenclature),
    outlined: false,
  )
  if (indented) {
    show grid.cell: it => {
      if (it.x == 0) {
        text(style: "oblique", upper(it))
      } else {
        it
      }
    }
    grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 1em,
      ..dict.pairs().flatten()
    )
  } else {
    for (key, value) in dict {
      text(style: "oblique", upper(key))
      h(1.5em)
      value
      parbreak()
    }
  }
}

#let theorem(body, numbered: true) = figure(
  body,
  kind: "theorem",
  supplement: context localization.at(text.lang).theorem,
  numbering: if numbered { "1" },
)

#let proposition(body, numbered: true) = figure(
  body,
  kind: "proposition",
  supplement: context localization.at(text.lang).proposition,
  numbering: if numbered { "1" },
)

// And a function for a proof.
#let proof(body) = context {
  emph(localization.at(text.lang).proof + ".")
  [ ] + body
  h(1fr)
  box(scale(160%, origin: bottom + right, sym.square.stroked))
}
