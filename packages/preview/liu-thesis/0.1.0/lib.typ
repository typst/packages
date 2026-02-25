#import "src/strings.typ": get-string
#import "src/formats.typ": student-format, s5-format
#import "src/page-setup.typ": setup-page
#import "src/chapter-heading.typ": make-chapter-heading
#import "src/title-page.typ": make-title-page
#import "src/copyright-page.typ": make-copyright-page
#import "src/frontmatter.typ": make-abstract-page, make-acknowledgments-page, make-toc-page, make-graduate-abstract-page, make-swedish-summary-page
#import "src/faculty.typ": get-faculty-data
#import "src/graduate-title-page.typ": make-graduate-title-page
#import "src/permission-page.typ": make-permission-page

#let valid-languages = ("swedish", "english")
#let valid-student-levels = ("msc", "bachelor")
#let valid-graduate-levels = ("lic", "phd")
#let valid-faculties = ("lith", "filfak", "hu")
#let valid-graduate-faculties = ("lith", "filfak")

#let student-thesis(
  title: (swedish: none, english: none),
  subtitle: (swedish: none, english: none),
  author: none,
  examiner: none,
  supervisor: none,
  subject: none,
  department: (swedish: none, english: none),
  department-short: "IDA",
  publication-year: none,
  thesis-number: "001",
  language: "swedish",
  level: "msc",
  faculty: "lith",
  external-supervisor: none,
  abstract: none,
  acknowledgments: none,
  bibliography: none,
  body,
) = {
  assert(language in valid-languages, message: "language must be one of: " + valid-languages.join(", "))
  assert(level in valid-student-levels, message: "level must be one of: " + valid-student-levels.join(", "))
  assert(faculty in valid-faculties, message: "faculty must be one of: " + valid-faculties.join(", "))

  let chapter-heading = make-chapter-heading(student-format.type-block-width)

  setup-page(student-format, language, {
    show heading.where(level: 1): set block(above: 0pt, below: 0pt)
    show heading.where(level: 1): chapter-heading

    show heading.where(level: 2): it => {
      let number = if it.numbering != none {
        context {
          let nums = counter(heading).get()
          numbering("1.1", ..nums.slice(0, 2))
        }
      }
      block(above: 1.8em, below: 1.15em, {
        set text(size: 11.7pt, weight: "bold")
        if number != none {
          number
          h(1em)
        }
        it.body
      })
    }

    set enum(indent: 1.5em, spacing: 1.5em)
    set list(indent: 1.5em, spacing: 1.5em)
    show enum: set block(above: 1.5em, below: 1.5em)
    show list: set block(above: 1.5em, below: 1.5em)

    make-title-page(
      format: student-format,
      title: title,
      subtitle: subtitle,
      author: author,
      examiner: examiner,
      supervisor: supervisor,
      subject: subject,
      department: department,
      department-short: department-short,
      publication-year: publication-year,
      thesis-number: thesis-number,
      language: language,
      level: level,
      faculty: faculty,
      external-supervisor: external-supervisor,
    )

    make-copyright-page(author)

    // Title page = i, copyright = ii (both suppressed).
    counter(page).update(3)

    if abstract != none {
      make-abstract-page(language, abstract)
    }

    if acknowledgments != none {
      make-acknowledgments-page(language, acknowledgments)
    }

    make-toc-page(language)

    counter(page).update(1)

    set page(
      header-ascent: 40%,
      footer-descent: 10pt,
      header: context {
        let current-page = here().page()
        let chapter-pages = query(heading.where(level: 1)).map(h => h.location().page())
        if current-page in chapter-pages {
          return
        }

        // Use the most recent level-2 heading up to this page.
        let sections = query(heading.where(level: 2)).filter(h =>
          h.location().page() <= current-page
        )
        if sections.len() > 0 {
          let section = sections.last()
          let nums = counter(heading).at(section.location())
          let display-num = numbering("1.1.", ..nums.slice(0, 2))
          // Reset par spacing to prevent the global spacing from expanding
          // the gap between the text and the rule line.
          set par(spacing: 0pt)
          align(right, text(size: 10pt, display-num + h(0.9em) + section.body))
          v(2pt)
          line(length: 100%, stroke: 0.4pt)
        }
      },
      footer: context {
        let current-page = here().page()
        let chapter-pages = query(heading.where(level: 1)).map(h => h.location().page())
        if current-page in chapter-pages {
          align(center, counter(page).display())
        } else {
          align(right, counter(page).display())
        }
      },
      numbering: "1",
    )

    body

    if bibliography != none {
      let bib-title = get-string(language, "bibliography-title")
      heading(level: 1, numbering: none, bib-title)
      bibliography
    }
  })
}

#let graduate-thesis(
  title: (swedish: none, english: none),
  subtitle: (swedish: none, english: none),
  author: none,
  department: (swedish: none, english: none),
  division: none,
  publication-year: none,
  thesis-number: none,
  isbn-print: none,
  isbn-pdf: none,
  edition: none,
  doi: none,
  language: "swedish",
  level: "lic",
  faculty: "lith",
  degree-suffix: "Technology",
  abstract: none,
  swedish-summary: none,
  acknowledgments: none,
  bibliography: none,
  body,
) = {
  assert(language in valid-languages, message: "language must be one of: " + valid-languages.join(", "))
  assert(level in valid-graduate-levels, message: "level must be one of: " + valid-graduate-levels.join(", "))
  assert(faculty in valid-graduate-faculties, message: "faculty must be one of: " + valid-graduate-faculties.join(", "))

  let fac-data = get-faculty-data(faculty, level, thesis-number)
  let chapter-heading = make-chapter-heading(s5-format.type-block-width)

  setup-page(s5-format, language, {
    show heading.where(level: 1): set block(above: 0pt, below: 0pt)
    show heading.where(level: 1): chapter-heading

    show heading.where(level: 2): it => {
      let number = if it.numbering != none {
        context {
          let nums = counter(heading).get()
          numbering("1.1", ..nums.slice(0, 2))
        }
      }
      block(above: 1.8em, below: 1.15em, {
        set text(size: 11.7pt, weight: "bold")
        if number != none {
          number
          h(1em)
        }
        it.body
      })
    }

    set enum(indent: 1.5em, spacing: 1.5em)
    set list(indent: 1.5em, spacing: 1.5em)
    show enum: set block(above: 1.5em, below: 1.5em)
    show list: set block(above: 1.5em, below: 1.5em)

    make-graduate-title-page(
      title: title,
      subtitle: subtitle,
      author: author,
      language: language,
      level: level,
      faculty-data: fac-data,
      department: department,
      division: division,
      publication-year: publication-year,
      thesis-number: thesis-number,
    )

    make-permission-page(
      author: author,
      language: language,
      level: level,
      faculty: faculty,
      division: division,
      department-english: department.english,
      publication-year: publication-year,
      edition: edition,
      isbn-print: isbn-print,
      isbn-pdf: isbn-pdf,
      doi: doi,
      issn: fac-data.issn,
    )

    // Title page = i (hidden), permission page = ii (shown).
    // Abstract starts at iii.
    counter(page).update(3)

    // PhD: Swedish popular science summary before abstract
    if level == "phd" and swedish-summary != none {
      make-swedish-summary-page(swedish-summary)
    }

    if abstract != none {
      make-graduate-abstract-page(language, abstract)
    }

    // Two-sided layout: each section starts on a recto (odd) page.
    pagebreak(to: "odd", weak: true)

    if acknowledgments != none {
      make-acknowledgments-page(language, acknowledgments, footer-descent: 15pt)
    }

    pagebreak(to: "odd", weak: true)

    make-toc-page(language, footer-descent: 15pt)

    pagebreak(to: "odd", weak: true)
    counter(page).update(1)

    set page(
      header-ascent: 40%,
      footer-descent: 15pt,
      header: context {
        let current-page = here().page()
        let chapter-pages = query(heading.where(level: 1)).map(h => h.location().page())
        if current-page in chapter-pages {
          return
        }

        let sections = query(heading.where(level: 2)).filter(h =>
          h.location().page() <= current-page
        )
        if sections.len() > 0 {
          let section = sections.last()
          let nums = counter(heading).at(section.location())
          let display-num = numbering("1.1.", ..nums.slice(0, 2))
          set par(spacing: 0pt)
          align(right, text(size: 10pt, display-num + h(0.9em) + section.body))
          v(2pt)
          line(length: 100%, stroke: 0.4pt)
        }
      },
      footer: context {
        let current-page = here().page()
        let chapter-pages = query(heading.where(level: 1)).map(h => h.location().page())
        if current-page in chapter-pages {
          align(center, counter(page).display())
        } else {
          align(right, counter(page).display())
        }
      },
      numbering: "1",
    )

    body

    if bibliography != none {
      let bib-title = get-string(language, "bibliography-title")
      heading(level: 1, numbering: none, bib-title)
      bibliography
    }
  })
}
