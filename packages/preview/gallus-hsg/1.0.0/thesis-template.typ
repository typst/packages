#import "/layout/titlepage.typ": *
#import "/layout/disclaimer.typ": *
#import "/layout/writing-aids-directory.typ": writing-aids-directory as writing-aids-directory-layout
#import "/layout/abstract.typ": abstract as abstract_layout
#import "/utils/print-pagebreak.typ": *
#import "/utils/todo.typ": *
#import "/utils/formfield.typ": *


#let thesis(
  title: "",
  subtitle: "",
  type: "",
  professor: "",
  author: "",
  matriculation-number: "",
  submission-date: datetime,
  abstract: "",
  language: "en",
  acknowledgement: "",
  writing-aids-directory: "",
  appendix: "",
  is-print: false,
  bibliography-as-bytes: bytes(""),
  body,
) = {
  assert(language in ("de", "en"), message: "The language supported are only 'de' and 'en'.")

  titlepage(
    title: title,
    subtitle: subtitle,
    type: type,
    professor: professor,
    author: author,
    matriculation-number: matriculation-number,
    submission-date: submission-date,
    language: language,
  )

  print-pagebreak(print: is-print, to: "even")


  if abstract != "" {
    abstract_layout(lang: language)[#abstract]
  }

  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    numbering: none,
  )

  set page(
    header: context {
      // Find first level-1 heading on this page (if any).
      let h = query(heading.where(level: 1).after(here()))
        .filter(h => h.location().page() == here().page())
        .at(
          0,
          default: {
            // Fall back to last previous heading.
            query(heading.where(level: 1).before(here())).at(-1, default: none)
          },
        )

      if h != none {
        // Create number from counter value and numbering.

        [
          #align(end, text(size: 11pt, weight: 400, h.body))
          #v(2mm)
        ]
      }
    },
  )

  let body-font = "Libertinus Serif"

  set text(
    font: body-font,
    size: 12pt,
    lang: language,
  )

  show math.equation: set text(weight: 400)

  set table(
    stroke: (x, y) => (
      y: if y == 1 {
        2pt + gray
      } else {
        1pt + gray
      },
      x: 1pt + gray,
    ),

    fill: (x, y) => if y == 0 {
      rgb(55, 126, 57)
    },
  )
  show table.cell: it => {
    if it.y == 0 {
      set text(white)
      strong(it)
    } else {
      it
    }
  }

  // --- Headings ---
  show heading: set block(below: 0.85em, above: 1.75em)
  show heading: set text(font: body-font)
  set heading(numbering: "1.1")
  // Reference first-level headings as "chapters"
  let chapter = (en: "Chapter", de: "Kapitel")
  show ref.where(form: "normal"): it => {
    let el = it.element
    if el != none and el.func() == heading and el.level == 1 {
      chapter.at(language) + " "
      numbering(
        el.numbering,
        ..counter(heading).at(el.location()),
      )
    } else {
      it
    }
  }

  // --- Paragraphs ---
  set par(leading: 1em)

  // --- Citations ---
  set cite(style: "alphanumeric")

  // --- Figures ---
  show figure: set text(size: 0.85em)

  // --- Table of Contents ---
  let tocTitle = (en: "Table of Contents", de: "Inhaltsverzeichnis")

  show outline.entry.where(level: 1): it => {
    strong(text(size: 12pt, it))
  }
  show outline.entry.where(level: 2): it => {
    text(size: 11pt, it)
  }
  show outline.entry.where(level: 3): it => {
    text(size: 10.5pt, it)
  }
  show outline.entry.where(level: 4): it => {
    text(size: 10pt, it)
  }

  outline(
    title: tocTitle.at(language),
    indent: 2em,
  )


  v(2.4fr)
  pagebreak()

  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
    numbering: "1",
    number-align: right,
  )

  counter(page).update(1)

  // List of figures.
  let figureListTitle = (en: "List of Figures", de: "Abbildungsverzeichnis")
  heading(numbering: none)[#figureListTitle.at(language)]
  outline(
    title: "",
    target: figure.where(kind: image),
  )

  // List of tables.
  print-pagebreak(print: is-print)
  let tableListTitle = (en: "List of Tables", de: "Tabellenverzeichnis")
  heading(numbering: none)[#tableListTitle.at(language)]
  outline(
    title: "",
    target: figure.where(kind: table),
  )
  pagebreak()


  // Main body.
  set par(justify: true)

  body


  if acknowledgement != "" {
    pagebreak()
    let acknowledgementTitle = (en: "Acknowledgement", de: "Danksagung")
    heading(numbering: none)[#acknowledgementTitle.at(language)]
    acknowledgement
  }

  // Appendix.
  if appendix != "" {
    pagebreak()
    let appendixTitle = (en: "Appendix", de: "Anhang")
    heading(numbering: none)[#appendixTitle.at(language)]
    appendix
  }

  if bibliography-as-bytes != bytes("") {
    pagebreak()
    let bibliographyTitle = (en: "References", de: "Literaturverzeichnis")
    bibliography(bibliography-as-bytes, style: "apa", title: bibliographyTitle.at(language))
  }
 

  print-pagebreak(print: is-print)

  disclaimer(
    title: title,
    author: author,
    language: language,
    submission-date: submission-date,
  )


  print-pagebreak(print: is-print)

  writing-aids-directory-layout(language: language, writing-aids-directory)
}
