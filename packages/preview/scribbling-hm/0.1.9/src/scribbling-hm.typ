#import "utils.typ": *
#import "study-info.typ": study-name

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
  examiner-gender: none,
  submission-date: none,
  abstract: none,
  abstract-translation: none,
  blocking: false,
  enable-header: true,
  draft: true,
  bib: none,
  abbreviations-list: none,
  study-name: study-name.IFB,
  variables-list: none,
  print: false,
  language: "de",
  appendix: none,
  body,
) = {
  if gender != none and gender not in ("m", "w", "d") {
    panic("Gender must be one of: 'm', 'w', 'd', or none")
  }
  if examiner-gender != none and examiner-gender not in ("m", "w", "d") {
    panic("Supervisor's gender must be one of: 'm', 'w', 'd', or none")
  }

  import "translations.typ": *

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
    lang: language,
    region: language,
  )

  set list(
    tight: false,
    indent: 10pt,
  )

  set enum(
    tight: false,
    indent: 10pt,
  )

  show: make-glossary.with(figure-caption-always-first: false, outline-always-first: false)

  register-glossary(variables-list)
  print-glossary(variables-list, invisible: true, disable-back-references: true)

  register-glossary(abbreviations-list)

  show: zebraw.with(
    background-color: rgb(251, 251, 251, 255),
    numbering-separator: true,
    lang-color: hm-color.lighten(50%),
  )
  show raw.where(block: true): set text(0.9em)

  import "study-info.typ": get-study-info
  let info = get-study-info(study-name)

  // titlepage
  import "components/titlepage.typ": titlepage

  titlepage(
    title: title,
    title-translation: title-translation,
    author: author,
    supervisors: supervisors,
    date: custom-date-format(submission-date, lang: language, pattern: "long"),
    id: student-id,
    gender: gender,
    examiner-gender: examiner-gender,
    draft: draft,
    study-info: info,
    date-today: custom-date-format(datetime.today(), lang: language, pattern: "long"),
  )
  if (print) { pagebreak(to: "odd") }
  // ---

  // blocking notice
  if blocking {
    import "components/blocking.typ": blocking-notice

    blocking-notice(
      gender: gender,
      thesis-type: info.thesis-type
    )

    pagebreak()
    if (print) { pagebreak(to: "odd") }
  }


  // ---

  // declaration of independent writing

  import "components/declaration.typ": declaration

  declaration(
    submission-date: custom-date-format(submission-date, lang: language, pattern: "long"),
    name: author,
    student-id: student-id,
    semester: semester,
    study-group: study-group,
    birth-date: if (birth-date != none) { custom-date-format(birth-date, lang: language, pattern: "dd.MM.yyyy") },
    thesis-type: info.thesis-type
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

  [
    // pagebreak before every level 1 heading
    #show heading.where(level: 1): it => {
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
    #import "components/abstract.typ": abstract-page

    #abstract-page(
      abstract: abstract,
      abstract-translation: abstract-translation,
    )
    // -- abstract

    #set page(
      numbering: "1",
      header: if (enable-header) { formatted-header(draft: draft, lang: language, print: print) },
      footer: formatted-footer(print: print, numbering: "1"),
    )

    #counter(page).update(1)

    #show heading.where(level: 1): set heading(numbering: "1")
    #show heading.where(level: 2): set heading(numbering: "1.1")
    #show heading.where(level: 3): set heading(numbering: "1.1.1")
    #show heading.where(level: 4): set heading(numbering: "1.1.1.1")
    #show heading: set heading(supplement: [#translations.chapter])

    #let variables-keys = variables-list.map(e => e.key).filter(k => k != none).dedup()
    #show link: it => {
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

    #body
  ]

  if print {
    set page(footer: none)
    pagebreak(to: "odd", weak: true)
  }

  set page(
    header: none,
    footer: formatted-footer(print: print, numbering: "I"),
    numbering: "I",
  )

  show heading.where(level: 1): set heading(numbering: none)

  if print {
    pagebreak(to: "odd", weak: true)
  }
  counter(page).update(1)

  heading([#translations.abbreviations], level: 1)

  print-glossary(abbreviations-list, deduplicate-back-references: true, minimum-refs: 2, shorthands: (
    "plural",
    "capitalize",
    "capitalize-plural",
    "short",
    "long",
    "longplural",
  ))

  pagebreak(weak: true)

  context {
    let images = figure.where(kind: image)
    
    if (query(images).len() > 0) {
      heading(level: 1)[#translations.list-of-figures]
      outline(
        target: images,
        title: none,
      )
    }
  }

  context {
    let listings = figure.where(kind: raw)
    
    if (query(listings).len() > 0) {
      heading(level: 1)[#translations.list-of-listings]
      outline(
        target: listings,
        title: none,
      )
    }
  }

  context {
    let tables = figure.where(kind: table)

    if (query(tables).len() > 0) {
      heading(level: 1)[#translations.list-of-tables]
      outline(
        target: tables,
        title: none,
      )
    }
  }

  pagebreak(weak: true)

  heading(level: 1)[#translations.bibliography]
  bib

  pagebreak(weak: true)

  counter(heading).update(0)
  show heading.where(level: 1): set heading(numbering: "A")
  show heading.where(level: 2): set heading(numbering: "A.1")

  if (appendix != none and appendix != []) {
    heading(level: 1)[#translations.appendix]
    appendix
  }
}
