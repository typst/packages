// Copyright 2024 Danny Seidel https://github.com/DannySeidel
// Copyright 2025 Felix Schladt https://github.com/FelixSchladt
// Copyright 2026 Marcel Hofmann <marcel@hofmania.de> https://sr.ht/~marcelhfm

#import "imports.typ": *

#let std-bibliography = bibliography

#let hm-template(
  title: none,
  subtitle: none,
  authors: "",
  doc-type: none,
  language: "de",
  font: "Roboto",
  text-size: 12pt, //textsize for non header & footer text
  version: "0.1",
  abstract: none,
  acknowledgements: none,
  glossary: none,
  bibliography: none,
  bib-style: "ieee",
  appendix: none,
  lastpage: none,
  toc-depth: 2,
  toc-pagebreak: false,
  list-of-tables: true,
  list-of-figures: true,
  list-of-code: false,
  titlepage-logo: image("assets/HM_Logo_RGB.png", width: 40%),
  project-logo: none,
  chapter-heading-pagebreak: true,
  show-thesis-title-page: false,
  student-id: none,
  submission-date: none,
  supervisor: none,
  faculty: "Faculty of Computer Science and Mathematics",
  study-course: "Computer Science",
  type-of-degree: "Master of Science",
  city: none,
  declaration-of-authorship: false,
  declaration-of-authorship-ai-usage: true,
  declaration-of-authorship-signature-img: none,
  top-remark: none,
  date: datetime.today(),
  date-format: auto,
  front-numbering: "i",
  main-numbering: "1 / 1",
  back-numbering: "a / a",
  appendix-numbering: "a / a",
  text-size-template: 10pt,
  body,
) = {
  // Page Numbering
  set page(numbering: none)

  // Setup glossary
  show: make-glossary
  if glossary != none {
    register-glossary(glossary)
  }

  // Default to subtitle but enable manual setting
  if top-remark == none {
    top-remark = subtitle
  }

  // Design  configurations
  let accent_line = line(length: 100%, stroke: (paint: hm-black, thickness: 1pt));

  // Fonts
  let body-font = font
  let heading-font = font

  set text(
    font: body-font,
    lang: language,
    size: text-size-template
  ) //template text
  set par(justify: true)
  show heading: set text(weight: "semibold", font: heading-font, fill: black)

  set page(
    margin: (
      top: 6em,
      bottom: 6em,
      rest: 6em, // Side margins
    ),
  )

  // Common Stuff
  let toc-title = linguify("base_table_of_contents", from: lang-db)
  let current-h1 = state(
    "current-h1",
    if toc-depth != none {
      toc-title
    } else {
      top-remark
    },
  )

  let hm-header = context {
    set text(size: text-size-template)

    grid(
      columns: (40%, 20%, 40%),
      align(left)[#doc-type],
      align(center)[
        #if project-logo != none {
          project-logo
        }
      ],
      align(right)[
        #text(style: "italic")[
          #current-h1.get()
        ]
      ],
    )

    accent_line
  }

  // booktab tables
  set table(
    stroke: none,
    inset: (x: 0.6em, y: 0.3em),
  )
  show table.cell.where(y: 0): strong

  let footer(display, end-label, show-total: true, show-accent: true) = context {
    set text(size: text-size-template)

    if show-accent {
      accent_line
    }

    grid(
      columns: (1fr, 1fr),
      align(left)[
        #if version != none [
          #authors #date.display("[year]")\
          Version #version
        ] else [#authors]
      ],
      align(right)[
        #context {
          let p = counter(page).get()
          let l = counter(page).at(end-label)
          if show-total {
            numbering(display, ..p, ..l)
          } else {
            numbering(display, ..p)
          }
        }
      ],
    )
  }

  // begin contents

  titlepage(
    title: title,
    subtitle: subtitle,
    authors: authors,
    logo: titlepage-logo,
    date: date,
    language: language,
    doc-type: doc-type,
    student-id: student-id,
    study-course: study-course,
    submission-date: submission-date,
    supervisor: supervisor,
    type-of-degree: type-of-degree,
    date-format: date-format,
    faculty: faculty,
    show-thesis-title-page: show-thesis-title-page,
    pagebreak-after: show-thesis-title-page or toc-pagebreak or toc-depth == none,
  )

  // ------------- Setup Front Matter Lettering --------------

  set page(
    numbering: front-numbering,
    header: hm-header,
    footer: footer(front-numbering, <end_front>, show-total: false),
  )

  counter(page).update(1)

  // contents
  set text(size: text-size)

  // TOC
  if toc-depth != none {
    {
      show heading.where(level: 1): it => {
        current-h1.update([
          #if it.numbering != none {
            [
              #counter(heading).display(it.numbering)
            ]
          }
          #it.body
        ])

        text(size: 20pt, it)
        v(1.25em)
      }
      show outline.entry.where(
        level: 1,
      ): it => {
        v(15pt, weak: true)
        strong(it)
      }

      outline(title: toc-title, indent: auto, depth: toc-depth)
    }
  }

  // Heading settings
  show heading.where(level: 1): it => {
    current-h1.update([
      #if it.numbering != none {
        [
          #counter(heading).display(it.numbering)
        ]
      }
      #it.body
    ])

    if chapter-heading-pagebreak {
      pagebreak()
    } else {
      v(2em)
    }
    text(size: 20pt, it)
    v(1.25em)
  }

  show heading.where(level: 2): it => v(1em) + it + v(1em)
  show heading.where(level: 3): it => v(1em) + it + v(0.75em)

  set text(size: text-size)

  // --------- Space for Glossary Abstract etc ----------

  if (declaration-of-authorship) {
    make-declaration-of-authorship(
      declaration-of-authorship-ai-usage,
      authors,
      date,
      language,
      city,
      date-format,
      declaration-of-authorship-signature-img,
    )
  }

  if (acknowledgements != none) {
    context {
    set par(justify: true, leading: 1em)
    set block(spacing: 2em)

    align(
      center + horizon,
      heading(level: 1, numbering: none)[
        #linguify("base_acknowledgements", from: lang-db)
      ])
      text(acknowledgements)
    }
  }

  if (abstract != none) {
    context {
    set par(justify: true, leading: 1em)
    set block(spacing: 2em)

    align(
      center + horizon,
      heading(level: 1, numbering: none)[
        #linguify("base_abstract", from: lang-db)
      ])
      text(abstract)
    }
  }

  if (list-of-tables) {
    heading(level: 1, linguify("base_list_of_tables", from: lang-db))
    outline(
      title: none,
      target: figure.where(kind: table),
    )
  }

  if (list-of-figures) {
    heading(level: 1, linguify("base_list_of_figures", from: lang-db))
    outline(
      title: none,
      target: figure.where(kind: image),
    )
  }

  if (list-of-code) {
    heading(level: 1, linguify("base_list_of_code", from: lang-db))
    outline(
      title: none,
      target: figure.where(kind: raw),
    )

  }

  // Display glossary.
  if glossary != none {
    heading(level: 1, linguify("base_glossary", from: lang-db))
    set par(justify: false)
    set list(spacing: 0.2em)
    set block(spacing: 0.2em)
    print-glossary(
      glossary,
      disable-back-references: true
    )
  }

  if not chapter-heading-pagebreak {
    pagebreak()
  }

  [
    #metadata(none)<end_front>
  ]

  // ---------- Setup Chapter Headings -------------------

  // Do numbered headings
  set heading(numbering: "1.")

  // ------------- Setup Arabic Lettering --------------

  set page(
    numbering: main-numbering,
    header: hm-header,
    footer: footer(main-numbering, <end_body>),
  )

  counter(page).update(1)

  // ----------- Setup Completed - Content ---------------

  body

  // ----------- Other stuff - Bib gloss appendix etc ----

  // Non numbered headings
  set heading(numbering: none)

  // Lettered back matter.
  [#metadata(none)<end_body>]

  show heading.where(level: 1): it => {
    text(size: 20pt, it)
    v(1.25em)
  }

  set page(
    numbering: back-numbering,
    header: hm-header,
    footer: footer(back-numbering, <end_back>),
  )

  counter(page).update(1)

  // Display bibliography.
  if bibliography != none {
    heading(level: 1, linguify("base_references", from: lang-db))
    set std-bibliography(
      title: none,
      style: bib-style
      )
    bibliography
  }

  // Continue the back-matter page counter for the appendix.
  set page(
    numbering: appendix-numbering,
    footer: footer(appendix-numbering, <end_back>),
  )

  // Display appendix.
  if appendix != none {
    if not chapter-heading-pagebreak {
      pagebreak()
    }

    appendix
  }

  // Last Page, possible for reference, versioning & contact information
  if lastpage != none {
    if not chapter-heading-pagebreak {
      pagebreak()
    }

    lastpage
  }

  [#metadata(none)<end_back>]
}
