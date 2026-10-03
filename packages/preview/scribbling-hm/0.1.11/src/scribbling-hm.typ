#import "utils.typ": *
#import "study-info.typ": study-name

#let _document(
  title: none,
  title-translation: none,
  document-type: "thesis",
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
  language: "de",
  appendix: none,
  layout-mode: "screen",
  subject: none,
  project-description: none,
  print-abbreviations-list: true,
  print-list-of-listings: true,
  print-list-of-tables: true,
  print-list-of-figures: true,
  body,
) = {
  if gender != none and gender not in ("m", "w", "d") {
    panic("Gender must be one of: 'm', 'w', 'd', or none")
  }
  if examiner-gender != none and examiner-gender not in ("m", "w", "d") {
    panic("Supervisor's gender must be one of: 'm', 'w', 'd', or none")
  }
  if layout-mode not in ("screen", "duplex", "bound") {
    panic("layout-mode must be one of: 'screen', 'duplex', 'bound'")
  }

  let is-duplex = layout-mode == "duplex"
  let is-bound = layout-mode == "bound"
  let force-odd = is-duplex

  import "translations.typ": create-translations
  let t = create-translations(language)

  state("draft", draft).update(draft)

  set document(author: if (author != none) { author } else { "" }, title: title, date: submission-date)

  set page(
    paper: "a4",
    margin: if is-duplex {
      (inside: 3cm, outside: 2cm)
    } else if is-bound {
      (left: 3cm, right: 2cm)
    } else {
      2.5cm
    },
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

  if (variables-list.len() > 0) {
    register-glossary(variables-list)
    print-glossary(variables-list, invisible: true, disable-back-references: true)
  }

  if abbreviations-list.len() > 0 {
    register-glossary(abbreviations-list)
  }

  show: zebraw.with(
    background-color: rgb(251, 251, 251, 255),
    numbering-separator: true,
    lang-color: hm-color.lighten(50%),
  )
  show raw.where(block: true): set text(0.9em)

  import "study-info.typ": get-study-info
  let info = get-study-info(study-name, lang: language)

  // titlepage
  import "components/titlepage.typ": thesis-titlepage

  if document-type == "modularbeit" {
    import "components/titlepage.typ": modularbeit-titlepage

    modularbeit-titlepage(
      subject: subject,
      authors: author,
      project-description: project-description,
      draft: draft,
      study-info: info,
      date-today: custom-date-format(datetime.today(), lang: language, pattern: "long"),
      t: t,
    )
  } else if document-type == "thesis" {
    import "components/titlepage.typ": thesis-titlepage

    thesis-titlepage(
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
      t: t,
    )
  }
  if (force-odd) { pagebreak(to: "odd") }
  // ---

  // blocking notice
  if blocking and document-type == "thesis" {
    import "components/blocking.typ": blocking-notice

    blocking-notice(
      gender: gender,
      thesis-type: info.thesis-type,
      t: t,
    )

    pagebreak()
    if (force-odd) { pagebreak(to: "odd") }
  }

  // ---

  // declaration of independent writing

  if document-type == "thesis" {
    import "components/declaration.typ": declaration

    declaration(
      submission-date: custom-date-format(submission-date, lang: language, pattern: "long"),
      name: author,
      student-id: student-id,
      semester: semester,
      study-group: study-group,
      birth-date: if (birth-date != none) { custom-date-format(birth-date, lang: language, pattern: "dd.MM.yyyy") },
      thesis-type: info.thesis-type,
      t: t,
    )

    pagebreak()

    if (force-odd) { pagebreak(to: "odd") }
  }

  // ---

  import "formatting.typ": formatted-footer, formatted-header
  set page(
    numbering: "i",
    footer: formatted-footer(print: is-duplex, numbering: "i"),
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
      if (force-odd) {
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
    #if document-type == "thesis" {
      import "components/abstract.typ": abstract-page

      abstract-page(
        abstract: abstract,
        abstract-translation: abstract-translation,
      )
    }
    // -- abstract

    #set page(
      numbering: "1",
      header: if (enable-header) { formatted-header(draft: draft, lang: language, print: is-duplex, t: t) },
      footer: formatted-footer(print: is-duplex, numbering: "1"),
    )

    #counter(page).update(1)

    #show heading.where(level: 1): set heading(numbering: "1")
    #show heading.where(level: 2): set heading(numbering: "1.1")
    #show heading.where(level: 3): set heading(numbering: "1.1.1")
    #show heading.where(level: 4): set heading(numbering: "1.1.1.1")
    #show heading: set heading(supplement: t.chapter)

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

    // todo: adjust link without abbreviations-list

    #body
  ]

  if force-odd {
    set page(footer: none)
    pagebreak(to: "odd", weak: true)
  }

  set page(
    header: none,
    footer: formatted-footer(print: is-duplex, numbering: "I"),
    numbering: "I",
  )

  show heading.where(level: 1): set heading(numbering: none)

  if force-odd {
    pagebreak(to: "odd", weak: true)
  }
  counter(page).update(1)

  if (print-abbreviations-list) {
    heading(t.abbreviations, level: 1)

    print-glossary(abbreviations-list, deduplicate-back-references: true, minimum-refs: 2, shorthands: (
      "plural",
      "capitalize",
      "capitalize-plural",
      "short",
      "long",
      "longplural",
    ))

    pagebreak(weak: true)
  } else {
    print-glossary(
      abbreviations-list,
      invisible: true,
      disable-back-references: true,
    )
  }

  if print-list-of-figures {
    context {
      let images = figure.where(kind: image)

      if (query(images).len() > 0) {
        heading(level: 1)[#t.list-of-figures]
        outline(
          target: images,
          title: none,
        )
      }
    }
  }

  if print-list-of-listings {
    context {
      let listings = figure.where(kind: raw)

      if (query(listings).len() > 0) {
        heading(level: 1)[#t.list-of-listings]
        outline(
          target: listings,
          title: none,
        )
      }
    }
  }

  if print-list-of-tables {
    context {
      let tables = figure.where(kind: table)

      if (query(tables).len() > 0) {
        heading(level: 1)[#t.list-of-tables]
        outline(
          target: tables,
          title: none,
        )
      }
    }
  }

  pagebreak(weak: true)

  heading(level: 1)[#t.bibliography]
  bib

  pagebreak(weak: true)

  counter(heading).update(0)
  show heading.where(level: 1): set heading(numbering: "A")
  show heading.where(level: 2): set heading(numbering: "A.1")

  if (appendix != none and appendix != []) {
    heading(level: 1)[#t.appendix]
    appendix
  }
}

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
  language: "de",
  appendix: none,
  layout-mode: "screen",
  print-abbreviations-list: true,
  print-list-of-listings: true,
  print-list-of-tables: true,
  print-list-of-figures: true,
  body,
) = {
  _document(
    document-type: "thesis",
    title: title,
    title-translation: title-translation,
    author: author,
    gender: gender,
    student-id: student-id,
    birth-date: birth-date,
    study-group: study-group,
    semester: semester,
    supervisors: supervisors,
    examiner-gender: examiner-gender,
    submission-date: submission-date,
    abstract: abstract,
    abstract-translation: abstract-translation,
    blocking: blocking,
    enable-header: enable-header,
    draft: draft,
    bib: bib,
    abbreviations-list: if (abbreviations-list != none) { abbreviations-list } else { () },
    study-name: study-name,
    variables-list: if (variables-list != none) { variables-list } else { () },
    language: language,
    appendix: appendix,
    layout-mode: layout-mode,
    print-abbreviations-list: if (abbreviations-list != none) { print-abbreviations-list } else { false },
    print-list-of-listings: print-list-of-listings,
    print-list-of-tables: print-list-of-tables,
    print-list-of-figures: print-list-of-figures,
    body,
  )
}

#let modularbeit-documentation(
  subject: none,
  authors: none,
  enable-header: true,
  draft: true,
  bib: none,
  abbreviations-list: none,
  print-abbreviations-list: false,
  study-name: study-name.IFB,
  variables-list: none,
  language: "de",
  appendix: none,
  layout-mode: "screen",
  project-description: none,
  print-list-of-listings: false,
  print-list-of-tables: false,
  print-list-of-figures: false,
  body,
) = {
  _document(
    document-type: "modularbeit",
    author: authors,
    enable-header: enable-header,
    draft: draft,
    bib: bib,
    abbreviations-list: if (abbreviations-list != none) { abbreviations-list } else { () },
    study-name: study-name,
    variables-list: if (variables-list != none) { variables-list } else { () },
    language: language,
    appendix: appendix,
    layout-mode: layout-mode,
    subject: subject,
    project-description: project-description,
    print-abbreviations-list: if (abbreviations-list != none) { print-abbreviations-list } else { false },
    print-list-of-listings: print-list-of-listings,
    print-list-of-tables: print-list-of-tables,
    print-list-of-figures: print-list-of-figures,
    body,
  )
}
