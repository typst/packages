#import "utils.typ": *

#let thesis(
  title: "",
  title-translation: "",
  author: "",
  gender: none,
  student-id: none,
  birth-date: none,
  study-group: "",
  semester: "",
  supervisors: (),
  supervisor-gender: none,
  submission-date: none,
  abstract-two-langs: true,
  abstract: none,
  abstract-translation: none,
  blocking: false,
  enable-header: true,
  draft: true,
  bib: none,
  abbreviations-list: none,
  course-of-study: none,
  body,
) = {
  if gender != none and gender not in ("m", "w", "d") {
    panic("Gender must be one of: 'm', 'w', 'd', or none")
  }
  if supervisor-gender != none and supervisor-gender not in ("m", "w", "d") {
    panic("Supervisor's gender must be one of: 'm', 'w', 'd', or none")
  }

  let lang = "de"

  state("draft", draft).update(draft)

  set document(author: author, title: title, date: submission-date)

  set page(
    paper: "a4",
    margin: 2.5cm,
    number-align: right,
    binding: left,
  )

  if draft {
    show cite: set text(fill: blue)
    show footnote: set text(fill: purple)
    set cite(style: "chicago-author-date")
  }

  set par(
    justify: true,
  )

  show heading.where(level: 1): set block(below: 0.5cm)
  show heading.where(level: 2): set block(below: 0.5cm)
  show heading.where(level: 3): set block(below: 0.5cm)

  set text(
    size: 10pt,
    lang: lang,
    region: lang,
    font: "Arial",
  )

  show: make-glossary

  import "components/titlepage.typ": titlepage

  titlepage(
    title: title,
    title-translation: title-translation,
    author: author,
    supervisors: supervisors,
    date: custom-date-format(submission-date, lang: lang, pattern: "long"),
    id: student-id,
    gender: gender,
    supervisor-gender: supervisor-gender,
    draft: draft,
    course-of-study: course-of-study
  )

  if blocking {
    import "components/blocking.typ": blocking-notice

    blocking-notice(
      gender: gender,
    )

    pagebreak()
  }

  import "components/declaration.typ": declaration

  declaration(
    submission-date: custom-date-format(submission-date, lang: lang, pattern: "long"),
    name: author,
    student-id: student-id,
    semester: semester,
    study-group: study-group,
    birth-date: custom-date-format(birth-date, lang: lang, pattern: "dd.MM.yyyy"),
  )

  pagebreak()

  set page(
    numbering: "i",
  )
  counter(page).update(1)

  // toc
  import "components/outline.typ": outline-page

  outline-page()
  // -- toc

  // abstract
  import "components/abstract.typ": abstract-page

  abstract-page(
    two-langs: abstract-two-langs,
    abstract: abstract,
    abstract-translation: abstract-translation,
  )
  // -- abstract

  set page(
    numbering: "1",
  )
  counter(page).update(1)

  set page(
    header: if enable-header {
      grid(
        columns: (1fr, 1fr),
        align: (left, right),
        text(context {
          let headings = query(heading.where(level: 1))
          let current-page = here().page()

          let current-heading = none
          for h in headings {
            if h.location().page() == current-page {
              current-heading = h
              break
            } else if h.location().page() > current-page {
              break
            }
          }

          if current-heading == none {
            for h in headings {
              if h.location().page() < current-page {
                current-heading = h
              } else {
                break
              }
            }
          }

          if current-heading != none {
            if draft {
              emph(text()[ENTWURF - ])
            }
            current-heading.body
          }
        }),
        [#author],
      )
      v(-0.5em)
      line(length: 100%, stroke: 0.05em)
    },
  )

  body

  set page(header: none)

  pagebreak()

  set page(
    numbering: "I",
  )
  counter(page).update(1)

  heading([Abkürzungsverzeichnis], level: 1)
  print-glossary(abbreviations-list, disable-back-references: true)

  if bib != none {
    pagebreak()

    bib
  }
}
