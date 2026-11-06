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

#let localization = yaml("utils/locale.yaml")

#let project(
  // Name of the university
  university: "Università degli Studi di Milano",
  // Path of the logo of the university
  unilogo: "img/unimi.svg",
  // Faculty, departament and course in which you are enrolled
  faculty: [Facoltà di Scienze e Tecnologie],
  department: [Dipartimento di Informatica \ Giovanni degli Antoni],
  cdl: [Corsi di Laurea Triennale in \ Corso di Laurea],
  // Title to be printed on the thesis
  printedtitle: "",
  // Title to be left on metadata
  title: "Un template meraviglioso",
  // Type of thesis
  typeofthesis: "Elaborato Finale",
  // Author and corresponding fullname, serial number
  author: (
    name: "Nome Cognome",
    serial_number: "123456",
  ),
  // Language of the thesis. This will change some prefixex (see utils/locale.yaml)
  language: "it",
  // Supervisors and cosupervisors
  supervisors: (
    "Prof. Enrico Fermi",
  ),
  cosupervisors: (
    "Prof. Ezio Auditore da Firenze",
    "Prof. Francesco Bianchi",
  ),
  // The academic year of the gradutation; defaults to the current year
  academicyear: "",
  // The chosen monospaced font (default: "JetBrainsMono NF")
  // monospaced-font: "JetBrainsMono NF",
  body,
) = {
  set document(
    title: title,
    author: author.name,
  )

  set text(lang: language)
  set par(
    justify: true,
    spacing: 0.8em,
    first-line-indent: 1.2em,
  )

  let paper = (
    height: 24cm,
    width: 17cm,
  )

  set page(
    // height: 24cm,
    // width: 17cm,
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 3.1cm,
      left: 3.5cm,
      right: 2.5cm,
    ),
    numbering: "i",

    // TODO is this actually correct?
    header-ascent: 1.03cm,
    header: context {
      if (
        document-state.get() == "TITLE_PAGE"
          or document-state.get() == "FRONTMATTER"
          or document-state.get() == "ACKNOWLEDGEMENTS"
          or document-state.get() == "BACKMATTER"
      ) {
        none
      } else if (
        document-state.get() == "MAINMATTER"
      ) {
        // Queries the heading FOR THE CURRENT PAGE
        let headings1 = query(selector(heading.where(level: 1))).filter(h1 => here().page() == h1.location().page())
        let before = query(selector(heading.where(level: 1)).before(here()))

        // if there is a lvl 1 heading on the same page, the header must be empty
        if (headings1.len() != 0) {
          return
        }

        let prefix = localization.at(text.lang).chapter

        let number = counter(heading.where(level: 1)).display()
        // if there is no level 1 heading on the current page, print the last lvl 1 heading
        let string = if (before.len() != 0) {
          before.last().body
        }

        // combinining all
        upper(
          text(
            style: "italic",
            prefix + " " + str(number) + ". " + string,
          ),
        )
        h(1fr) + counter(page).display()
      } else if (document-state.get() == "APPENDIX") {
        // Queries the heading FOR THE CURRENT PAGE
        let headings1 = query(selector(heading.where(level: 1))).filter(h1 => here().page() == h1.location().page())
        let before = query(selector(heading.where(level: 1)).before(here()))

        // if there is a lvl 1 heading on the same page, the header must be empty
        if (headings1.len() != 0) {
          return
        }

        let prefix = localization.at(text.lang).appendix

        // number :: [a-Z].[d] -> [a-Z]
        let number = str(counter(heading).display()).split(".").at(0)
        // if there is no level 1 heading on the current page, print the last lvl 1 heading
        let string = before.last().body

        // combinining all
        upper(
          text(
            style: "italic",
            prefix + " " + str(number) + ". " + string,
          ),
        )
        h(1fr) + counter(page).display()
      }
    },
    footer: context {
      let headings1 = query(selector(heading.where(level: 1))).filter(h1 => here().page() == h1.location().page())
      let before = query(selector(heading.where(level: 1)).before(here()))

      // if there is a lvl 1 heading on the same page, the footer must display the page numbering at the bottom center
      if (headings1.len() != 0) {
        align(center, counter(page).display())
      } else {
        return
      }
    },
  )

  // TITLE PAGE
  // name of university, department, logo, course
  let logo(imagepath, height: 30mm) = {
    set align(center)
    image(
      height: height,
      imagepath,
    )
  }

  align(
    center,
    {
      text(size: sizes.LARGE, university) + linebreak()
      upper(faculty)
      v(0.0135 * paper.height)
      upper(department)
      v(0.02 * paper.height)
      logo(unilogo)
      v(0.0135 * paper.height)
      upper(cdl)
    },
  )

  // v(0.0168 * paper.height)
  v(1fr)

  if (printedtitle == "") {
    printedtitle = title
  }

  // thesis printed title
  align(
    center,
    text(size: sizes.Large, upper(printedtitle)),
  )

  // v(0.0673 * paper.height)
  v(1fr)

  set text(size: sizes.large)

  // supervisors & co
  align(
    left,
    context {
      let relatori = ()
      for name in supervisors {
        let arr = (localization.at(text.lang).supervisor + ":", name)
        relatori.push(arr)
      }
      for name in cosupervisors {
        let arr = (localization.at(text.lang).cosupervisor + ":", name)
        relatori.push(arr)
      }
      grid(
        columns: 2,
        align: left,
        column-gutter: 0.5cm,
        row-gutter: 0.2cm,
        ..relatori.flatten()
      )
    },
  )

  v(0.0168 * paper.height)
  // v(1fr)

  // final composition
  align(
    right,
    box({
      context {
        set align(left)
        typeofthesis + " "
        localization.at(text.lang).type_of_thesis
        ":" + linebreak()
        author.name + linebreak()
        localization.at(text.lang).serial_number + " "
        author.serial_number
      }
    }),
  )

  // v(0.0337 * paper.height)
  v(1fr)

  // Default academic year = current year
  if (academicyear == "") {
    let current_year = datetime.today().year()
    academicyear = str(current_year) + [ -- ] + str(current_year + 1)
  }

  align(
    center,
    context {
      smallcaps({
        localization.at(text.lang).academic_year
        " "
        academicyear
      })
    },
  )

  // Table of contents
  show outline.entry.where(level: 1): it => {
    v(19pt, weak: true)
    link(
      it.element.location(),
      strong(it.indented(it.prefix(), it.element.body + h(1fr) + it.page())),
    )
  }

  // Page break before each heading 1, which is begin treated as a LaTeX's Chapter
  show heading.where(level: 1): it => {
    pagebreak()
    v(3cm)
    if (it.numbering != none) {
      if (document-state.get() == "MAINMATTER") {
        localization.at(text.lang).chapter
      } else if (document-state.get() == "APPENDIX") {
        localization.at(text.lang).appendix
      }
      " "
      counter(selector(heading)).display()
    }
    v(10pt)
    set par(first-line-indent: 0em)
    it.body
  }

  // Heading sizes
  show heading: it => {
    if (it.level == 1) {
      text(size: sizes.Large, it)
    }
    if (it.level == 2) {
      text(size: sizes.large, it)
    }
    if (it.level >= 3) {
      text(size: sizes.normalsize, it)
    }
    v(8pt)
  }

  // Itemize and Enumerate settings
  set list(
    indent: 1.2em,
    tight: false,
    marker: (
      [•],
      [--],
      [\*],
    ),
  )

  show list: it => {
    set par(spacing: 1.2em)
    it
  }

  set enum(
    indent: 1.2em,
    tight: true,
    numbering: "1.a.i.",
  )

  show enum: it => {
    set par(spacing: 1.2em)
    it
  }

  let monospaced-font = "JetBrainsMono NF"

  show raw.where(block: true): it => {
    set text(font: monospaced-font, weight: "light")
    align(
      center,
      block(
        // width: 100%,
        fill: rgb("#ebf1f5"),
        inset: 10pt,
        stroke: rgb("#9cc9e7"),
        // radius: 4pt,
        align(center, it),
      ),
    )
  }

  show figure.where(kind: "toc"): it => {
    align(start, it.body + v(1em))
  }

  // Workaround to print links in monospaced font
  // show link: set text(font: monospaced-font, size: 0.8em)

  // Body
  body
}

#let frontmatter(body) = {
  document-state.update("FRONTMATTER")
  set heading(numbering: none)

  body
}

#let dedication(body) = {
  document-state.update("DEDICATION")
  pagebreak()
  set align(right)
  set text(style: "italic")

  body
}

#let acknowledgements(body) = {
  document-state.update("ACKNOWLEDGEMENTS")
  set page(numbering: "i")

  body
}

#let mainmatter(body) = {
  document-state.update("MAINMATTER")
  set page(numbering: "1")
  set heading(numbering: "1.1")
  counter(page).update(1)

  // Workaround to print links in monospaced font
  // after the TOC because the lvl. 1 headings are all links
  show link: set text(font: "JetBrainsMono NF", size: 0.8em)

  body
}

#let appendix(body) = context {
  document-state.update("APPENDIX")
  counter(heading).update(0)
  set heading(numbering: "A.1")

  body
}

#let backmatter(body) = context {
  document-state.update("BACKMATTER")
  set heading(numbering: none)
  set page(footer: align(center, counter(page).display()))

  body
}

// TOC in the TOC

#let list = figure.with(
  kind: "toc",
  numbering: none,
  supplement: none,
  outlined: true,
  caption: [],
)

#let target = (
  figure
    .where(
      kind: "toc",
      outlined: true,
    )
    .or(heading.where(outlined: true))
)

#let toc = context {
  set page(footer: align(center, counter(page).display()))
  outline(
    title: list(localization.at(text.lang).toc),
    indent: 1em,
    target: target,
  )
}

// Laboratories

#let labsizes = (
  space: 1mm,
  size: 25mm,
)

#let laboratories = yaml("utils/laboratories.yaml")

#let closingpage(name, laboratories: laboratories) = context {
  set page(footer: none)
  // pagebreak()
  v(1fr)
  set align(center)
  image(
    laboratories.at(name).logo,
    height: labsizes.size,
    width: labsizes.size,
  )

  localization.at(text.lang).lab_prefix + " "
  laboratories.at(name).name + linebreak()
  // laboratories.at(name).company + linebreak()
  link("", laboratories.at(name).url)
}
