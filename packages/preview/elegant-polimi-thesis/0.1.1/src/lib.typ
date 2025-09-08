// LaTeX sizes to match original template
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

// the current state (title page, front-,main-,backmatter...)
#let document-state = state("init", "TITLE_PAGE")

#let localization = yaml("locale.yaml")

/// Custom PoliMi colour (#box(baseline: 0.1em, rect(height: 0.7em, width: 0.7em, fill: rgb("#5f859f")))).
/// -> color
#let bluepoli = rgb("#5f859f")

/// Main formatting function of the template.
/// -> content
#let polimi-thesis(
  /// Title of the thesis
  /// -> str
  title: "Thesis Title",
  /// Author of the name (Name Surname).
  /// -> str
  author: "Name Surname",
  /// Advisor of the thesis.
  /// -> str
  advisor: "",
  /// Coadvisor of the thesis.
  /// -> str
  coadvisor: "",
  /// Tutor of the thesis.
  /// -> str
  tutor: "",
  /// Deprecated attribute. Academic year. If empty, defaults to the current one: "#str(datetime.today().year() - 1) --- #str(datetime.today().year())".
  /// -> str
  phdcycle: "",
  /// If empty, defaults to the current one: "#str(datetime.today().year() - 1)".
  /// -> str
  academic-year: "",
  /// Cycle of the thesis.
  /// -> str
  cycle: none,
  /// Chair of the thesis (not used).
  /// -> str
  chair: none,
  /// Language of the thesis.
  /// -> str
  language: "en",
  /// Whether to activate the colored headings or not.
  /// -> bool
  colored-headings: true,
  /// Path of the main logo of the thesis (default: "Scuola di Ingegneria Industriale e dell'Informazione").
  /// -> path
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
    footer: {},
  )

  // FIGURE

  set figure(gap: 1.5em)
  show figure: set block(breakable: true)

  // figures caption
  // bold[Figure Chapter.Num]: ""
  show figure.caption: it => context {
    if (it.kind != "lists" and it.kind != "_blank-toc") {
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

  let raggiera-image(width) = (
    image(
      "img/raggiera.svg",
      width: width,
    )
      + place(top, rect(
        width: 100%,
        height: 100%,
        fill: white.transparentize(22%), // similar to the correct #DFE6EA
      ))
  )

  // --------------------- [ TITLE PAGE ] ---------------------

  // Logo
  v(0.6fr)

  place(dx: 44%, dy: -28%, raggiera-image(90%))
  place(dx: 1.5%, dy: -1%, image(main-logo, width: 73%))

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

  align(end, context {
    set text(size: sizes.Large)
    localization.at(text.lang).dissertation + ":\n" + text(weight: "bold", author)
  })

  v(1fr)

  if (phdcycle == "") {
    phdcycle = str(datetime.today().year() - 1) + " - " + str(datetime.today().year())
  }
  if (academic-year == "") {
    academic-year = phdcycle
  }

  // helper function to detect whether a field is present
  let isPresent(before, string, after: linebreak()) = {
    if (string != none and string != "") {
      return before + string + after
    } else {
      return none
    }
  }

  align(start, context {
    set text(size: sizes.large)
    isPresent(localization.at(text.lang).advisor + ": Prof. ", advisor)
    isPresent(localization.at(text.lang).coadvisor + ": Prof. ", coadvisor)
    isPresent(localization.at(text.lang).tutor + ": Prof. ", tutor)
    isPresent(localization.at(text.lang).advisor + ": Prof. ", advisor)
    isPresent(localization.at(text.lang).year + " ", academic-year, after: none)
    isPresent(" - ", cycle, after: " " + localization.at(text.lang).cycle)
  })

  // Document

  show heading: it => {
    if (colored-headings) {
      text(fill: bluepoli, it)
    }
  }

  // --------------------- [ CHAPTER STYLE ] ---------------------

  // let raggera = {
  //   v(1fr)
  //   place(dx: -7cm, dy: -16.25cm, raggiera-image(0.85 * 24cm))
  // }

  show heading.where(level: 1): it => context {
    // checks if the page is empty: the cursor is at the same height from the top as the top margin
    if (calc.even(here().page()) and here().position().y.cm() == page.margin.top.length.cm()) {
      set page(header: {})
    } else if (calc.odd(here().page()) and here().position().y.cm() == page.margin.top.length.cm()) {} else if (
      calc.odd(here().page())
    ) {
      set page(
        header: {},
        background: {
          v(1fr)
          place(dx: -7cm, dy: -16.25cm, raggiera-image(0.85 * 24cm))
        },
      )
      pagebreak(to: "odd")
    }
    // v(120pt)
    v(4cm)
    set text(weight: "bold", fill: if (colored-headings) { bluepoli } else { black })

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

    // counters reset
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    // counter(figure.where(kind: "theorem")).update(1)
    // counter(figure.where(kind: "proposition")).update(1)
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

  // chapter are bold and don't have "..."
  show outline.entry.where(level: 1): it => context {
    v(19pt, weak: true)
    link(it.element.location(), strong(it.indented(it.prefix(), it.element.body + h(1fr) + it.page())))
  }

  show outline.entry: it => context {
    v(1em)
    if it.level > 1 {
      v(1em, weak: true)
      let spacing = it.level - 1
      h(2em) * spacing
      // link(it.element.location(), it)
      link(it.element.location(), it.indented(
        it.prefix(),
        it.element.body + box(width: 1fr, repeat([\u{0009} . \u{0009} \u{0009}])) + it.page(),
      ))
    } else if (
      it.element.func() == figure and it.element.at("kind") == "_blank-toc"
    ) {
      // v(1em) //
      v(it.element.at("gap")) // \addtocontents{toc}{\vspace{1em}}
      return
    } else {
      it
    }
  }

  // custom figure alignment
  show figure
    .where(kind: "lists")
    .or(figure.where(kind: "_blank-toc"))
    .or(figure.where(kind: "theorem"))
    .or(figure.where(kind: "proposition")): it => {
    align(start, it)
  }

  show outline: set heading(bookmarked: true)

  // show ref: it => text(
  //   fill: if (colored-headings) { bluepoli } else { black },
  //   it,
  // )

  set list(indent: 1.2em)

  set enum(indent: 1.2em)

  body
}

/// Helper function to manually add blank space above an outline entry (similar to LaTeX's ```tex \addtocontents{toc}{\vspace{1em}}```).
/// -> content
#let _blank-toc(
  /// Vertical space to add before the next outline entry.
  /// -> length
  space: 1em,
) = {
  let _blank-toc-figure = figure.with(
    kind: "_blank-toc",
    numbering: none,
    supplement: none,
    outlined: true,
    gap: space,
    caption: [],
  )

  {
    show heading: none
    show figure: none
    _blank-toc-figure("")
  }
}

// Document sections

/// Frontmatter section. Similar to LaTeX's ```tex \frontmatter```. It sets the page numbering to `"i"` and ```typc numbering: none``` for headings.
/// -> content
#let frontmatter(body) = {
  document-state.update("FRONTMATTER")
  // counter(page).update(0)
  set page(numbering: "i")
  set heading(numbering: none)

  body
}

/// Acknowledgements section. It sets ```typc numbering: none``` for headings.
/// -> content
#let acknowledgements(body) = {
  _blank-toc()
  document-state.update("ACKNOWLEDGEMENTS")
  set heading(numbering: none)

  body
}

/// Mainmatter section. Similar to LaTeX's ```tex \mainmatter```.  It sets to page numbering to `"1"`, ```typc numbering: "1.1"``` for headings and resets the page counter.
/// -> content
#let mainmatter(body) = {
  _blank-toc()
  document-state.update("MAINMATTER")
  set heading(numbering: "1.1")
  set page(numbering: "1")
  counter(page).update(0)

  body
}

/// Appendix section. Similar to LaTeX's ```tex \appendix```.  It sets ```typc numbering: "A.1"``` for headings and resets their counter.
/// -> content
#let appendix(body) = context {
  _blank-toc()
  document-state.update("APPENDIX")
  counter(heading).update(0)
  set heading(numbering: "A.1")

  body
}

/// Backmatter section. Similar to LaTeX's ```tex \backmatter```. It sets ```typc numbering: none``` for headings.
/// -> content
#let backmatter(body) = context {
  _blank-toc()
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
    .or(figure.where(kind: "_blank-toc", outlined: true))
    .or(heading.where(outlined: true))
)

// lists figure to make the list of tables, list of figures to appear in the table of contents
#let lists = figure.with(kind: "lists", numbering: none, supplement: none, outlined: true, caption: [])

/// Table of contents. It's a custom built upon ```typc outline()```.
#let toc = context {
  outline(
    title: lists(localization.at(text.lang).toc),
    indent: 1.2em,
    target: target,
  )
}

/// Internal helper function to create the custom lists of figures and table.
/// -> content
#let _lists-entries-style(
  /// Outline entry to edit.
  /// -> outline-entry
  outline-entry,
  /// The kind of the outline entry element (image or table)
  /// -> function
  kind,
) = {
  let count = (
    str(counter(heading.where(level: 1)).at(outline-entry.element.location()).at(0))
      + "."
      + str(counter(figure.where(kind: kind)).at(outline-entry.element.location()).at(0))
  )
  link(outline-entry.element.location(), {
    count
    h(1em)
    outline-entry.element.at("caption").body
    box(width: 1fr, repeat([. \u{0009} \u{0009}])) // \u{0009} = Tab
    str(counter(page).at(outline-entry.element.location()).at(0))
  })
  linebreak()
}

/// List of figures. Similar to LaTeX's ```tex \listoffigures```.
/// -> content
#let list-of-figures = context {
  show outline.entry: it => {
    _lists-entries-style(it, image)
  }
  outline(title: lists(localization.at(text.lang).list-of-figures), target: figure.where(kind: image))
}

/// List of tables. Similar to LaTeX's ```tex \listoftables```.
/// -> content
#let list-of-tables = context {
  show outline.entry: it => {
    _lists-entries-style(it, table)
  }
  outline(title: lists(localization.at(text.lang).list-of-tables), target: figure.where(kind: table))
}

/// Nomenclature function.
/// -> content
#let nomenclature(
  /// Dictionary that hold keys and values.
  /// -> dictionary
  dict,
  /// Whether to indent or not the nomenclature.
  /// -> bool
  indented: true,
) = context {
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


// #let theorem(body, numbered: true) = {
//   let theorem-figure = figure(
//     body,
//     kind: "theorem",
//     supplement: context localization.at(text.lang).theorem,
//     numbering: if numbered { "1" },
//   )

//   strong(context {
//     localization.at(text.lang).theorem
//     if numbered != none {
//       [ ]
//       str(counter(heading.where(level: 1)).at(here()).at(0))
//       [.]
//       str(counter(figure.where(kind: "theorem")).at(here()).at(0))
//     }
//     [. ]
//   })
//   emph(body)
// }

// #let proposition(body, numbered: true) = context {
//   let proposition-figure = figure(
//     body,
//     kind: "proposition",
//     supplement: context localization.at(text.lang).proposition,
//     numbering: if numbered { "1" },
//   )

//   strong({
//     localization.at(text.lang).proposition
//     if numbered != none {
//       [ ]
//       str(counter(heading.where(level: 1)).at(here()).at(0))
//       [.]
//       str(counter(figure.where(kind: "proposition")).at(here()).at(0))
//     }
//     [. ]
//   })
//   emph(body)
// }

// #let proof(body) = context {
//   emph(localization.at(text.lang).proof + ".")
//   [ ] + body
//   h(1fr)
//   box(scale(160%, origin: bottom + right, sym.square.stroked))
}


// ctheorems implementation (doesn't work properly)

// #import "@preview/ctheorems:1.1.3": *
// #show: thmrules.with(qed-symbol: $square$)

// #let theorem = thmbox("theorem", "Theorem")
// #let corollary = thmplain(
//   "corollary",
//   "Corollary",
//   base: "theorem",
//   titlefmt: strong,
// )


// #let definition = thmbox("definition", "Definition", inset: (x: 1.2em, top: 1em))

// #let example = thmplain("example", "Example").with(numbering: none)
// #let proof = thmproof("proof", "Proof")
// #let proposition = thmproof("proposition", "Proposition")

#import "@preview/great-theorems:0.1.2": *
#import "@preview/headcount:0.1.0": *

#let thm-cnt = counter("thm")
#let prop-cnt = counter("prop")
#let lemma-cnt = counter("lemma")
#let remark-cnt = counter("remark")

#let theorem = mathblock(
  blocktitle: context localization.at(text.lang).theorem,
  counter: thm-cnt,
  bodyfmt: text.with(style: "italic"),
  numbering: dependent-numbering("1.1", levels: 1),
)

#let proposition = mathblock(
  blocktitle: context localization.at(text.lang).proposition,
  counter: prop-cnt,
  bodyfmt: text.with(style: "italic"),
  numbering: dependent-numbering("1.1", levels: 1),
)

#let lemma = mathblock(
  blocktitle: context localization.at(text.lang).lemma,
  counter: lemma-cnt,
  bodyfmt: text.with(style: "italic"),
  numbering: dependent-numbering("1.1", levels: 1),
)

#let remark = mathblock(
  blocktitle: context localization.at(text.lang).remark,
  counter: remark-cnt,
  bodyfmt: text.with(style: "italic"),
  numbering: dependent-numbering("1.1", levels: 1),
)

#let proof = proofblock()

/// Utility function to initialized the various theorem environments -- which are:
/// - theorem
/// - proposition
/// - lemma
/// - remark
/// -> content
#let theorems-init(body) = {
  show: great-theorems-init
  show heading.where(level: 1): reset-counter(thm-cnt, levels: 1)
  show heading.where(level: 1): reset-counter(prop-cnt, levels: 1)
  show heading.where(level: 1): reset-counter(lemma-cnt, levels: 1)
  show heading.where(level: 1): reset-counter(remark-cnt, levels: 1)

  body
}
