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
  print: false,
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
    margin: if (print) { (inside: 3cm, outside: 2cm) } else { 2.5cm },
    number-align: right,
    binding: left,
  )

  // draft-based accents
  set cite(
    style: if draft { "springer-basic-author-date" } else { "ieee" },
  )
  show cite: set text(fill: if draft { orange } else { black })
  show footnote: set text(fill: if draft { purple } else { black })
  // ---

  set par(
    justify: true,
  )

  show heading.where(level: 1): set block(below: 0.5cm)
  show heading.where(level: 2): set block(below: 0.5cm)
  show heading.where(level: 3): it => {
    set block(below: 0.5cm)
    set text(size: 1.1em)
    it
  }
  show heading.where(level: 5): set text(weight: "semibold")

  set text(
    lang: lang,
    region: lang,
  )

  set list(
    tight: false,
    indent: 10pt,
  )

  set enum(
    tight: false,
    indent: 10pt,
  )

  show: make-glossary

  register-glossary(variables-list)
  print-glossary(variables-list, invisible: true, disable-back-references: true)

  register-glossary(abbreviations-list)

  show: zebraw.with(
    background-color: rgb(251, 251, 251, 255),
    numbering-separator: true,
    lang-color: hm-color.lighten(50%),
  )
  show raw.where(block: true): set text(0.9em)

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
  if (print) { pagebreak(to: "odd") }
  // ---

  // blocking notice
  if blocking {
    import "components/blocking.typ": blocking-notice

    blocking-notice(
      gender: gender,
    )

    pagebreak()
    if (print) { pagebreak(to: "odd") }
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

  if (print) { pagebreak(to: "odd") }

  // ---

  import "formatting.typ": formatted-footer, formatted-header
  set page(
    numbering: "i",
    footer: formatted-footer(print: print, numbering: "i"),
  )
  counter(page).update(1)

  // toc
  import "components/outline.typ": outline-page

  outline-page()
  // -- toc

  // pagebreak before every level 1 heading
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    if (print) {
      set page(footer: none, header: none)
      pagebreak(to: "odd")
      let previous = query(selector(heading.where(level: 1, numbering: "1")).before(here()))

      if previous.len() == 1 {
        counter(page).update(1)
      }
    }
    it
  }

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
    header: if (enable-header) { formatted-header(draft: draft, lang: lang, print: print) },
    footer: formatted-footer(print: print, numbering: "1"),
  )

  counter(page).update(1)

  show heading.where(level: 1): set heading(numbering: "1")
  show heading.where(level: 2): set heading(numbering: "1.1")
  show heading.where(level: 3): set heading(numbering: "1.1.1")
  show heading.where(level: 4): set heading(numbering: "1.1.1.1")
  show heading: set heading(supplement: [Kapitel])

  let variables-keys = variables-list.map(e => e.key).filter(k => k != none).dedup()
  show link: it => {
    if (type(it.dest) == str) {
      it
    } else {
      if (variables-keys.any(k => repr(it.dest).contains(k))) {
        it.body
      } else {
        it
      }
    }
  }

  body

  set page(
    header: none,
    footer: context {
      let page-number = here().page()
      let next-headings = query(selector(heading.where(level: 1)).after(here()))

      if print and next-headings.len() > 0 {
        let next = next-headings.first()
        if next.location().page() == page-number + 1 and calc.rem(page-number, 2) == 0 {
          return none
        }
      }

      formatted-footer(print: print, numbering: "I")
    },
    numbering: "I",
  )

  show heading.where(level: 1): set heading(numbering: none)

  if print {
    pagebreak(to: "odd", weak: true)
  }
  counter(page).update(1)

  heading([Abkürzungsverzeichnis], level: 1)

  print-glossary(abbreviations-list, deduplicate-back-references: true, shorthands: (
    "plural",
    "capitalize",
    "capitalize-plural",
    "short",
    "long",
    "longplural",
  ))

  bib
}
