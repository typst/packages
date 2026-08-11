#import "utils.typ": *

#let thesis(
  title: none,
  title-translation: none,
  author: none,
  gender: none,
  student-id: none,
  birth-date: none,
  study-group: "",
  semester: "",
  supervisors: none,
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
  variables-list: none,
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

  set document(author: if (author != none) { author } else { "" }, title: title, date: submission-date)

  set page(
    paper: "a4",
    margin: 2.5cm,
    number-align: right,
    binding: left,
  )

  // draft-based accents
  set cite(
    style: if draft {"springer-basic-author-date"} else {"ieee"}
  )
  show cite: set text(fill: if draft {orange} else {black})
  show footnote: set text(fill: if draft {purple} else {black})
  // ---

  set par(
    justify: true,
  )

  show heading.where(level: 1): set block(below: 0.5cm)
  show heading.where(level: 2): set block(below: 0.5cm)
  show heading.where(level: 3): set block(below: 0.5cm)

  set text(
    lang: lang,
    region: lang,
  )

  show: make-glossary

  // titlepage
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
    course-of-study: course-of-study,
    date-today: custom-date-format(datetime.today(), lang: lang, pattern: "long"),
  )

  // ---

  // blocking notice
  if blocking {
    import "components/blocking.typ": blocking-notice

    blocking-notice(
      gender: gender,
    )

    pagebreak()
  }

  // ---

  // declaration of independent writing

  import "components/declaration.typ": declaration

  declaration(
    submission-date: custom-date-format(submission-date, lang: lang, pattern: "long"),
    name: author,
    student-id: student-id,
    semester: semester,
    study-group: study-group,
    birth-date: if (birth-date != none) { custom-date-format(birth-date, lang: lang, pattern: "dd.MM.yyyy") },
  )

  pagebreak()

  // ---

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
          current-heading.body
          h(1fr)
          if draft {
            [
              #text(red)[ENTWURF -- Stand: #custom-date-format(datetime.today(), lang: lang, pattern: "dd.MM.y")]
            ]
          }
        }
      })
      v(-0.5em)
      line(length: 100%, stroke: 0.05em)
    },
  )

  register-glossary(variables-list)
  print-glossary(variables-list, invisible: true, disable-back-references: true)

  register-glossary(abbreviations-list)

  // pagebreak before every level 1 heading
  show heading.where(depth: 1): it => {
    pagebreak(weak: true)
    it
  }

  body

  set page(header: none)

  pagebreak()

  set page(
    numbering: "I",
  )
  counter(page).update(1)

  heading([Abkürzungsverzeichnis], level: 1)

  print-glossary(abbreviations-list, deduplicate-back-references: true)

  bib

  show link: it => {
    let ref = str(it.dest)
    if variables-list.any(v => v.key == ref) {
      it.body
    } else { it }
  }
}
