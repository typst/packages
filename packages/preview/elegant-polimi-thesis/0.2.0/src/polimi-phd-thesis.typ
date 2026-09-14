#import "utils.typ": *
#import "figures.typ": *

#let language = "en"

// https://typst.app/universe/package/smartaref
#import "@preview/smartaref:0.1.0": Cref, cref

/// The main thesis formatting function.
/// -> content
#let polimi-thesis(
  /// Title of the thesis.
  /// -> str
  title: "Thesis Title",
  /// Author of the thesis.
  /// -> str
  author: "Name Surname",
  /// Advisor of the thesis.
  /// -> str
  advisor: "Advisor",
  /// Coadvisor(s) of the thesis.
  /// -> str | arr
  coadvisor: "Coadvisor",
  /// Academic year of the thesis. If empty, defaults to "#{str(std.datetime.today().year() - 1) + "-" + str(std.datetime.today().year())}".
  /// -> str
  academic-year: "",
  /// Tutor of the thesis.
  /// -> str
  tutor: "Tutor",
  /// Cycle of the thesis.
  /// -> str
  cycle: "XXV",
  /// Chair of the thesis.
  /// -> str
  chair: "Chair",
  /// Student ID.
  /// -> str
  student-id: "00000000",
  /// Student course.
  /// -> str
  course: "Course Engineering",
  /// Frontispiece of the thesis. Can be either: `phd`, `deib-phd`, `cs-eng-master` or `classical-master`.
  /// -> "phd" | "deib-phd" | "cs-eng-master" | "classical-master"
  frontispiece: "phd",
  /// Custom logo of the thesis.
  /// -> image
  custom-logo: none,
  body,
) = {
  let colored-headings = false
  if frontispiece == "deib-phd" {
    colored-headings = true
  }
  _document-type.update(frontispiece)

  set document(
    title: title,
    author: author,
  )

  set text(
    lang: language,
    size: 12pt,
    font: "New Computer Modern",
    hyphenate: true,
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
      inside: 3cm,
      outside: 2cm,
    ),
    numbering: "i",
    header: context {
      if (
        _is-page-empty() or _document-state.get() == "TITLE_PAGE"
      ) {
        return
      } else if (
        ("FRONTMATTER", "BACKMATTER").contains(_document-state.get())
      ) {
        let page-counter = counter(page).display()
        if (calc.even(here().page())) {
          page-counter + h(1fr)
        } else {
          h(1fr) + page-counter
        }
      } else if (
        ("MAINMATTER", "APPENDIX", "ACKNOWLEDGEMENTS").contains(_document-state.get())
      ) {
        let h1-current-page = (
          query(heading.where(level: 1)).filter(h1 => h1.location().page() == here().page()).len() != 0
        )
        let last-h1 = query(selector(heading.where(level: 1)).before(here())).last().body
        let page-counter = counter(page).display()

        let chapter-info = if not (h1-current-page) {
          set text(weight: "bold")
          let heading-num = if (heading.numbering != none) {
            counter(heading.where(level: 1)).display(header-number)
          }
          text(
            fill: if (colored-headings) { bluepoli } else { black },
            heading-num,
          )
          last-h1
        }

        if (calc.even(here().page())) {
          page-counter + h(1fr) + chapter-info
        } else {
          chapter-info + h(1fr) + page-counter
        }
      }
    },
    footer: none,
    background: context {
      if _is-page-empty() {
        v(1fr)
        place(dx: -7cm, dy: -16.25cm, _raggiera-image(0.85 * 24cm))
      }
    },
  )

  // FIGURES SETTINGS

  set figure(gap: 1.5em)
  show figure: set block(breakable: true)
  show: _style-figures.with(
    colored-caption: colored-headings,
    heading-levels: if frontispiece == "phd" { 0 } else { 1 },
  )

  // --------------------- [ TITLE PAGE ] ---------------------

  import "frontispiece.typ": *

  if academic-year == "" {
    academic-year = str(std.datetime.today().year() - 1) + "-" + str(std.datetime.today().year()).slice(2) // 20XX-XX
  }

  let shared-attributes = (title, author, advisor, coadvisor, academic-year)

  let logos = ()
  if custom-logo == none {
    logos = (
      image("img/logo_ingegneria.svg", width: 112mm),
      image("img/logo_deib.svg", height: 38mm),
      image("img/logo_ingegneria.svg", width: 93mm),
      image("img/logo_ingegneria.svg", width: 93mm),
    )
  } else {
    logos = (custom-logo,) * 4
  }

  let frontispieces = (
    "phd": frontispiece-phd(..shared-attributes, logos.at(0), cycle, chair, tutor),
    "deib-phd": frontispiece-deib-phd(..shared-attributes, logos.at(1), cycle, chair, tutor),
    "classical-master": frontispiece-classical-master(..shared-attributes, logos.at(2), course, student-id),
    "cs-eng-master": frontispiece-cs-eng-master(..shared-attributes, logos.at(3), student-id),
  )

  if frontispieces.keys().contains(frontispiece) {
    frontispieces.at(frontispiece)
  } else {
    panic("The frontispiece must be either one of: `phd`, `deib-phd`, `cs-eng-master` or `classical-master`.")
  }

  // Document

  show heading: it => {
    if (colored-headings) {
      text(fill: bluepoli, it)
    } else {
      it
    }
  }

  // --------------------- [ CHAPTER STYLE ] ---------------------

  show heading.where(level: 1): it => context {
    _empty-page()
    v(4cm)
    set text(weight: "bold", fill: if (colored-headings) { bluepoli } else { black })

    let heading-num = counter(selector(heading)).display(chapter-numbering)
    if (
      it.numbering != none and (_document-state.get() == "MAINMATTER" or _document-state.get() == "APPENDIX")
    ) {
      text(
        size: 50pt,
        weight: "regular",
        text(
          // weight: "bold",
          heading-num,
        ),
      )
    }
    text(
      size: 1.5em,
      it.body,
    )
    v(10pt)

    // reset all figures counter
    context {
      for e in query(figure).map(e => e.kind).dedup() {
        counter(figure.where(kind: e)).update(0)
      }
    }
  }

  show heading: it => context {
    if (it.level == 1) {
      it
    } else if (it.level == 2) {
      text(
        size: _sizes.at("12pt").Large,
        counter(heading).display(tab-numbering) + it.body,
      )
    } else if (it.level >= 3) {
      text(
        size: _sizes.at("12pt").large,
        counter(heading).display(tab-numbering) + it.body,
      )
    }
    // v(0.5em)
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

/// The thesis article format styling function.
/// -> content
#let polimi-article-format-thesis(
  /// Title of the thesis.
  /// -> str
  title: "Thesis Title",
  /// Author of the thesis.
  /// -> str
  author: "Name Surname",
  /// Advisor of the thesis.
  /// -> str
  advisor: "Prof. Name Surname",
  /// Coadvisor(s) of the thesis.
  /// -> str | array
  coadvisor: "Prof. Name Surname",
  /// Academic year of the thesis. If empty, defaults to "#{str(std.datetime.today().year() - 1) + "-" + str(std.datetime.today().year())}".
  /// -> str
  academic-year: "",
  /// Student ID.
  /// -> str
  student-id: "00000000",
  /// Student course.
  /// -> str
  course: "Xxxxxxxxxxxx Engineering - Ingegneria Xxxxxxxxxxxx",
  /// Abstract.
  /// -> content
  abstract: [],
  /// Keywords, that appear below the abstract (and in the PDF metadata).
  /// -> str
  keywords: "word, word, word",
  /// Logo of the thesis.
  /// -> path
  logo: image("img/logo_ingegneria.svg", width: 83mm),
  body,
) = {
  set document(
    title: title,
    author: author,
    keywords: keywords,
  )
  _document-type.update("article-format")

  set text(
    lang: language,
    size: 11pt,
    font: "New Computer Modern",
    hyphenate: true,
  )
  show math.equation: set text(font: "New Computer Modern Math")

  set par(
    justify: true,
    linebreaks: "optimized",
    spacing: 0.65em,
    first-line-indent: 0pt,
  )

  set page(
    margin: (
      top: 2cm,
      right: 2cm,
      bottom: 2cm,
      left: 2cm,
    ),
    numbering: "1",
    number-align: bottom + center,
    background: context if here().page() == 1 {
      place(
        dx: 135mm,
        dy: -30mm,
        _raggiera-image(105mm),
      )
    },
  )

  set list(indent: 1.2em, tight: true, marker: ($bullet$, $circle$, $-$))
  set enum(indent: 1.2em, tight: true)

  set heading(numbering: "1.1.")
  show heading: it => {
    set text(fill: bluepoli)
    v(0.45cm)
    if it.numbering != none { counter(heading).display() + h(1em) }
    it.body
    v(0.45cm)
  }

  set figure(gap: 1.5em)
  show figure: set block(breakable: true)
  show: _style-figures.with(colored-caption: true)

  {
    set text(size: _sizes.at("11pt").small)
    {
      // Title
      set text(size: 0.3cm, weight: "bold")
      set par(spacing: 0.5cm)

      v(0.8cm)

      logo

      v(0.7cm)

      {
        set text(fill: bluepoli)

        text(size: _sizes.at("11pt").Large, title)

        v(0.25cm)

        smallcaps(
          "Tesi di Laurea Magistrale in" + linebreak() + course,
        )
      }

      v(0.15cm)

      (author, student-id).map(e => text(size: _sizes.at("11pt").large, e)).join(", ")
    }

    v(0.25cm)

    line(length: 100%, stroke: 0.4pt)

    v(0.25cm)

    grid(
      columns: (22%, 1fr),
      align: (horizon + left, left),
      grid.cell(
        inset: 5%,
        [
          #set text(size: _sizes.at("11pt").scriptsize)
          #set par(justify: false, spacing: 1.7em)

          #text(weight: "bold", "Advisor:") \
          Prof. #advisor

          #if type(coadvisor) == str or (type(coadvisor) == array and coadvisor.len() == 1) {
            text(weight: "bold", "Co-advisor:") + linebreak()
            coadvisor
          } else {
            text(weight: "bold", "Co-advisors:") + linebreak()
            coadvisor.join("\n")
          }

          #text(weight: "bold", "Academic year:") \
          #if academic-year == "" {
            academic-year = str(std.datetime.today().year() - 1) + "-" + str(std.datetime.today().year())
          }
          #academic-year
        ],
      ),
      text(fill: bluepoli, "Abstract: ") + abstract,
    )

    v(1em)

    banner(strong("Keywords: ") + keywords)
  }

  // this must be an error from the original template...
  // set text(size: _sizes.at("11pt").small)

  v(0.4cm)

  body
}

/// The executive summary styling function.
/// -> content
#let polimi-executive-summary(
  /// Title of the thesis.
  /// -> str
  title: "Thesis Title",
  /// Author of the thesis.
  /// -> str
  author: "Name Surname",
  /// Advisor of the thesis.
  /// -> str
  advisor: "Prof. Name Surname",
  /// Coadvisor(s) of the thesis.
  /// -> str | array
  coadvisor: "Prof. Name Surname",
  /// Academic year of the thesis. If empty, defaults to "#{str(std.datetime.today().year() - 1) + "-" + str(std.datetime.today().year())}".
  /// -> str
  academic-year: "",
  /// Student course.
  /// -> str
  course: "Xxxxxxxxxxxx Engineering - Ingegneria Xxxxxxxxxxxx",
  /// Logo of the thesis.
  /// -> path
  logo: image("img/logo_ingegneria.svg", width: 83mm),
  body,
) = {
  set document(
    title: title,
    author: author,
  )
  _document-type.update("executive-summary")

  set text(
    lang: language,
    size: 10.5pt, // it should be 11pt, though due to how LaTeX originally handles it this size seems to be best for an adaptation
    font: "New Computer Modern",
    hyphenate: true,
  )
  show math.equation: set text(font: "New Computer Modern Math")

  set par(
    justify: true,
    linebreaks: "optimized",
    spacing: 0.7em,
    first-line-indent: 0pt,
  )

  set page(
    margin: (
      top: 3cm,
      left: 2cm,
      right: 2cm,
      bottom: 2cm,
    ),
    numbering: "1",
    number-align: bottom + center,
    columns: 2,
    header: context if here().page() > 1 {
      banner(strong("Executive Summary" + h(1fr) + author))
    },
    background: context if here().page() == 1 {
      place(
        dx: 135mm,
        dy: -30mm,
        _raggiera-image(105mm),
      )
    },
  )
  set columns(gutter: 30pt)

  // Title
  {
    place(
      top + left,
      float: true,
      scope: "parent",
      {
        set text(weight: "bold", size: 0.3cm)
        set par(spacing: 0.5cm)

        v(0.8cm)

        logo

        v(0.7cm)

        {
          set text(fill: bluepoli)

          smallcaps(
            "Executive Summary of the Thesis",
          )

          v(0.1cm)

          text(size: _sizes.at("11pt").Large, title)

          v(0.25cm)

          smallcaps(
            "Laurea Magistrale in " + course,
          )
        }

        v(0.1cm)

        "Author: " + smallcaps(author) + v(-0.3em)
        "Advisor: Prof. " + smallcaps(advisor) + v(-0.3em)
        (
          if type(coadvisor) == str or (type(coadvisor) == array and coadvisor.len() == 1) {
            "Co-advisor: " + smallcaps(coadvisor)
          } else {
            "Co-advisors: " + coadvisor.map(smallcaps).join(", ")
          }
            + v(-0.3em)
        )
        if academic-year == "" {
          academic-year = str(std.datetime.today().year() - 1) + "-" + str(std.datetime.today().year())
        }
        "Academic year: " + smallcaps(academic-year)

        v(0.25cm)

        line(length: 100%, stroke: 0.4pt)
      },
    )
  }

  set list(indent: 1.2em, tight: true, marker: ($bullet$, $circle$, $-$))
  set enum(indent: 1.2em, tight: true)

  set heading(numbering: tab-numbering)
  show heading: it => {
    set text(fill: bluepoli)
    v(1em, weak: true)
    // if it.numbering != none { counter(heading).display() + h(1em) }
    // it.body
    it
    v(0.75em, weak: true)
  }

  set figure(gap: 1.5em)
  show figure: set block(breakable: true)
  show: _style-figures.with(colored-caption: true)

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

/// Frontmatter section. Similar to LaTeX's ```tex \frontmatter```, it is meant to be only used in the thesis. It sets the page numbering to `"i"` and ```typc numbering: none``` for headings.
/// -> content
#let frontmatter(body) = {
  _document-state.update("FRONTMATTER")
  // counter(page).update(0)
  _empty-page()
  set page(numbering: "i")
  set heading(numbering: none)

  body
}

/// Acknowledgements section. It sets ```typc numbering: none``` for headings.
/// -> content
#let acknowledgements(body) = {
  _blank-toc()
  _document-state.update("ACKNOWLEDGEMENTS")
  set heading(numbering: none)

  body
}

/// Mainmatter section. Similar to LaTeX's ```tex \mainmatter```, it is meant to be only used in the thesis. It sets to page numbering to `"1"`, heading numbering to ```typc "1.1" + h()``` and resets the page counter.
/// -> content
#let mainmatter(body) = {
  _blank-toc()
  _document-state.update("MAINMATTER")
  set heading(numbering: "1.1.")
  _empty-page()
  set page(numbering: "1")
  counter(page).update(1)

  body
}

/// Appendix section. Similar to LaTeX's ```tex \appendix```. It sets heading numbering to ```typc"A.1"``` and resets their counter.
/// -> content
#let appendix(body) = context {
  _blank-toc()
  _document-state.update("APPENDIX")
  counter(heading).update(0)
  set heading(numbering: "A.1.")

  body
}

/// Backmatter section. Similar to LaTeX's ```tex \backmatter```, it is meant to be only used in the thesis. It sets heading numbering to ```typc none```.
/// -> content
#let backmatter(body) = context {
  _blank-toc()
  _document-state.update("BACKMATTER")
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

/// Lists figure to make the list of tables, list of figures to appear in the table of
/// contents.
/// -> content
#let _lists = figure.with(kind: "lists", numbering: none, supplement: none, outlined: true, caption: [])

/// Custom-built ```typc outline()```.
/// -> content
#let toc = context {
  outline(
    title: _lists(_localization.at(text.lang).toc),
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
    box(width: 1fr, repeat([\u{0009} \u{0009} . \u{0009}])) // \u{0009} = Tab
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
  outline(title: _lists(_localization.at(text.lang).list-of-figures), target: figure.where(kind: image))
}

/// List of tables. Similar to LaTeX's ```tex \listoftables```.
/// -> content
#let list-of-tables = context {
  show outline.entry: it => {
    _lists-entries-style(it, table)
  }
  outline(title: _lists(_localization.at(text.lang).list-of-tables), target: figure.where(kind: table))
}

/// Displays a simple nomenclature with keys and values.
/// ```example
///
/// #nomenclature((
///     "Polimi": "Politecnico di Milano",
///     "CdL": "Corso di Laurea",
///     "CCS": "Consigli di Corsi di Studio",
///     "CFU": "Crediti Formativi Universitari",
/// ))
/// ```
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
    _lists(_localization.at(text.lang).nomenclature),
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

// Theorems implementation

#import "@preview/great-theorems:0.1.2": *
#import "@preview/headcount:0.1.0": *

#let thm-cnt = counter("thm")
#let prop-cnt = counter("prop")
#let lemma-cnt = counter("lemma")
#let remark-cnt = counter("remark")

/// Theorem block.
/// -> content
#let theorem = mathblock(
  blocktitle: context _localization.at(text.lang).theorem,
  prefix: count => [
    #context {
      set text(weight: "bold", fill: if ("executive-summary", "article-format").contains(_document-type.get()) {
        bluepoli
      } else { black })
      _localization.at(text.lang).theorem + " " + count + "."
    }
  ],
  counter: thm-cnt,
  bodyfmt: text.with(style: "italic"),
  numbering: dependent-numbering("1.1", levels: 1),
  suffix: context { if _document-type.get() == "executive-summary" { v(0.2cm) } },
)

/// Proposition block.
/// -> content
#let proposition = mathblock(
  blocktitle: context _localization.at(text.lang).proposition,
  prefix: count => [
    #context {
      set text(weight: "bold", fill: if ("executive-summary", "article-format").contains(_document-type.get()) {
        bluepoli
      } else { black })
      _localization.at(text.lang).proposition + " " + count + "."
    }
  ],
  counter: prop-cnt,
  bodyfmt: text.with(style: "italic"),
  numbering: dependent-numbering("1.1", levels: 1),
  suffix: context { if _document-type.get() == "executive-summary" { v(0.2cm) } },
)

/// Lemma block.
/// -> content
#let lemma = mathblock(
  blocktitle: context _localization.at(text.lang).lemma,
  prefix: count => [
    #context {
      set text(weight: "bold", fill: if ("executive-summary", "article-format").contains(_document-type.get()) {
        bluepoli
      })
      _localization.at(text.lang).lemma + " " + count + "."
    }
  ],
  counter: lemma-cnt,
  bodyfmt: text.with(style: "italic"),
  numbering: dependent-numbering("1.1", levels: 1),
  suffix: context { if _document-type.get() == "executive-summary" { v(0.2cm) } },
)

/// Remark block.
/// -> content
#let remark = mathblock(
  blocktitle: context _localization.at(text.lang).remark,
  prefix: count => [
    #context {
      set text(weight: "bold", fill: if ("executive-summary", "article-format").contains(_document-type.get()) {
        bluepoli
      })
      _localization.at(text.lang).remark + " " + count + "."
    }
  ],
  counter: remark-cnt,
  bodyfmt: text.with(style: "italic"),
  numbering: dependent-numbering("1.1", levels: 1),
  suffix: context { if _document-type.get() == "executive-summary" { v(0.2cm) } },
)

/// Proof block.
/// -> content
#let proof = proofblock(
  suffix: context { if _document-type.get() == "executive-summary" { v(0.2cm) } },
)

/// Utility function to initialize the theorem environments#footnote[Provided by #link("https://typst.app/universe/package/great-theorems", "great-theorems") package.]:
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

/// Creates a new subfigure with the given arguments and an optional label. From #link("https://github.com/mewmew/hallon-typ", "hallon") package.
/// -> content
#let subfigure(
  ..args,
  /// Whether to outline this subfigure or not.
  /// -> bool
  outlined: false,
  /// Unique label to reference this subfigure
  /// -> str
  label: none,
  body,
) = {
  let fig = figure(body, kind: "subfigure", outlined: outlined, ..args)
  if label == none {
    return fig
  }
  [ #fig #label ]
}
