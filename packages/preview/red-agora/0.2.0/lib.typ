#let IMAGE_BOX_MAX_WIDTH = 120pt
#let IMAGE_BOX_MAX_HEIGHT = 50pt

#let supported-langs = ("en", "fr", "ar")

#let full-page-chapter = state("full-page-chapter", false)

#let project(
  title: "",
  subtitle: none,
  header: none,
  school-logo: none,
  company-logo: none,
  authors: (),
  mentors: (),
  jury: (),
  branch: none,
  academic-year: none,
  french: false,
  lang: none,
  footer-text: "ENSIAS",
  features: (),
  heading-numbering: "1.1",
  accent-color: rgb("#ff4136"),
  defense-date: none,
  body
) = {
  if lang == none {
    // Fallback by the time the param gets removed after deprecation
    if french {
      lang = "fr"
    } else {
      lang = "en"
    }
  }

  if not supported-langs.contains(lang) {
    panic("Unsupported `lang` value. Supported languages: " + supported-langs.join(","))
  }

  let dict = json("resources/i18n/" + lang + ".json")

  // Set the document's basic properties.
  set document(author: authors, title: title)

  set page(header: context {
    let headings = query(heading.where(level: 1).before(here()))
    let current-page-headings = query(heading.where(level: 1).after(here())).filter(h => h.location().page() == here().page())
    if headings == () {
      []
    } else {
      let current-chapter = headings.last()
      if current-chapter.level == 1 and current-chapter.numbering != none {
        let in-page-heading = if current-page-headings.len() > 0 { current-page-headings.first() } else { none }
        if in-page-heading == none or in-page-heading.level != 1 or in-page-heading.numbering == none {
          let count = counter(heading).at(current-chapter.location()).at(0)
          align(end)[
            #text(accent-color, weight: "bold")[
              #dict.chapter #count:
            ]
            #current-chapter.body
            #line(length: 100%)
          ]
        }
      }
    }
  }) if features.contains("header-chapter-name")

  set page(
    numbering: "1",
    number-align: center,
    footer: context {
      // Omit page number on the first page
      let page-number = counter(page).get().at(0);

      if page-number > 1 and not full-page-chapter.get() {
        line(length: 100%, stroke: 0.5pt)
        v(-2pt)
        text(size: 12pt, weight: "regular")[
          #footer-text
          #h(1fr)
          #page-number
          #h(1fr)
          #academic-year
        ]
      }
      full-page-chapter.update(false)
    }
  )

  set text(lang: lang, size: 13pt)
  set heading(numbering: heading-numbering)

  show heading: it => {
      if it.level == 1 and it.numbering != none {
        if features.contains("full-page-chapter-title") {
          pagebreak()
          full-page-chapter.update(true)

          v(1fr)
          [
            #text(weight: "regular", size: 30pt)[
              #dict.chapter #counter(heading).display()
            ]
            #linebreak()
            #text(weight: "bold", size: 36pt)[
              #it.body
            ]
            #line(start: (0%, -1%), end: (15%, -1%), stroke: 2pt + accent-color)
          ]
          v(1fr)

          pagebreak()
        } else {
          pagebreak()
          full-page-chapter.update(false)
          v(40pt)
          text(size: 30pt)[#dict.chapter #counter(heading).display() #linebreak() #it.body ]
          v(60pt)
        }
      } else {
        full-page-chapter.update(false)
        v(5pt)
        [#it]
        v(12pt)
      }
  }

  if header != none {
    h(1fr)
    box(width: 60%)[
      #align(center)[
        #text(weight: "medium")[
          #header
        ]
      ]
    ]
    h(1fr)
  }

  block[
    #box(height: IMAGE_BOX_MAX_HEIGHT, width: IMAGE_BOX_MAX_WIDTH)[
      #align(start + horizon)[
        #if school-logo == none {
          image("images/ENSIAS.svg")
        } else {
          school-logo
        }
      ]
    ]
    #h(1fr)
    #box(height: IMAGE_BOX_MAX_HEIGHT, width: IMAGE_BOX_MAX_WIDTH)[
      #align(end + horizon)[
        #company-logo
      ]
    ]
  ]

  // Title box
  align(center + horizon)[
    #if subtitle != none {
      text(size: 14pt, tracking: 2pt)[
        #smallcaps[
          #subtitle
        ]
      ]
    }
    #line(length: 100%, stroke: 0.5pt)
    #text(size: 20pt, weight: "bold")[#title]
    #line(length: 100%, stroke: 0.5pt)
  ]

  // Credits
  box()
  h(1fr)
  grid(
    columns: (auto, 1fr, auto),
    [
      // Authors
      #if authors.len() > 0 {
        [
          #text(weight: "bold")[
            #if authors.len() > 1 {
              dict.author_plural
            } else {
              dict.author
            }
            #linebreak()
          ]
          #for author in authors {
            [#author #linebreak()]
          }
        ]
      }
    ],
    [
      // Mentor
      #if mentors != none and mentors.len() > 0 {
        align(end)[
          #text(weight: "bold")[
            #if mentors.len() > 1 {
              dict.mentor_plural
            } else {
              dict.mentor
            }
            #linebreak()
          ]
          #for mentor in mentors {
            mentor
            linebreak()
          }
        ]
      }
      // Jury
      #if defense-date == none and jury != none and jury.len() > 0 {
        align(end)[
          *#dict.jury* #linebreak()
          #for prof in jury {
            [#prof #linebreak()]
          }
        ]
      }
    ]
  )

  align(center + bottom)[
    #if defense-date != none and jury != none and jury.len() > 0 {
      [*#dict.defended_on_pre_date #defense-date #dict.defended_on_post_date:*]
      // Jury
      align(center)[
        #for prof in jury {
          [#prof #linebreak()]
        }
      ]
      v(60pt)
    }
    #if branch != none {
      branch
      linebreak()
    }
    #if academic-year != none {
      [#dict.academic_year: #academic-year]
    }
  ]

  pagebreak()

  // Table of contents.
  outline(depth: 3, indent: auto)

  pagebreak()

  // Table of figures.
  outline(
    title: dict.figures_table,
    target: figure.where(kind: image)
  )

  pagebreak()

  outline(
    title: dict.tables_table,
    target: figure.where(kind: table)
  )

  pagebreak()

  // Main body.
  body
}
