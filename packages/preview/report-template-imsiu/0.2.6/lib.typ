#let IMAGE_BOX_MAX_WIDTH = 120pt
#let IMAGE_BOX_MAX_HEIGHT = 50pt
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#let supported-langs = ("en", "fr", "ar")
#let project(
  title: "",
  subtitle: none,
  header: none,
  school-logo: none,
  Department-logo: none,
  authors: (),
  mentors: (),
  jury: (),
  branch: none,
  academic-year: none,
  lang: none,
  figure-index: (enabled: false, title: ""),
  table-index: (enabled: false, title: ""),
  listing-index: (enabled: false, title: ""),
  bibliography: none,
  arabic: false,
  footer-text: "IMSIU",
  features: (),
  heading-numbering: "1.1",
  accent-color: rgb("#ff4136"),
  defense-date: none,
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set page(
    numbering: "1",
    number-align: center,
    footer: context {
      // Omit page number on the first page
      let page-number = counter(page).get().at(0)
      if page-number > 1 {
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
    },
  )

  if lang == none {
    // Fallback by the time the param gets removed after deprecation
    if arabic {
      lang = "ar"
    } else {
      lang = "en"
    }
  }


  if not supported-langs.contains(lang) {
    panic("Unsupported `lang` value. Supported languages: " + supported-langs.join(","))
  }

  let dict = json("resources/i18n/" + lang + ".json")

  set text(lang: lang, size: 13pt)
  set heading(numbering: heading-numbering)

  show heading: it => {
    if it.level == 1 and it.numbering != none {
      if features.contains("full-page-chapter-title") {
        pagebreak()

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
        v(40pt)
        text(size: 30pt)[#dict.chapter #counter(heading).display() #linebreak() #it.body ]
        v(60pt)
      }
    } else {
      v(5pt)
      [#it]
      v(12pt)
    }
  }

  if features.contains("header-chapter-name") {
    set page(header: context {
      let all-headings = query(heading.where(level: 1))
      let current-page-headings = all-headings.filter(h => h.location().page() == here().page())
      if current-page-headings.len() > 0 {
        return none
      }
      let headings = all-headings.filter(h => h.location().page() < here().page())
      if headings != () {
        let current-heading = headings.last()
        let count = counter(heading).at(current-heading.location()).at(0)
        if count < 1 or current-heading.numbering == none {
          return none
        }
        [
          #h(1fr)
          #text(accent-color, weight: "bold")[
            #dict.chapter #count:
          ]
          #current-heading.body
          #line(length: 100%)
        ]
      }
    })
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
          image("images/IMSIU_Logo.png")
        } else {
          school-logo
        }
      ]
    ]
    #h(1fr)
    #box(height: IMAGE_BOX_MAX_HEIGHT, width: IMAGE_BOX_MAX_WIDTH)[
      #align(end + horizon)[
        #if Department-logo == none {
          image("images/CCIS_Logo.png")
        } else {
          Department-logo
        }
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
    ],
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


  // Table of contents: render only if more than 3 headings exist.
  context {
    let heading-count = query(heading).len()
    if heading-count > 3 {
      pagebreak()

      outline(depth: 3, indent: auto)
    }
  }

  // Conditionally enable fancy code blocks and codly show rules
  let fancy = features.contains("fancy-codeblocks")

  // Make the show rule conditional by choosing the function to apply
  let codly_init_fn = if fancy { codly-init.with() } else { it => it }
  show: codly_init_fn

  // Activate fancy code blocks only when the feature flag is enabled
  if fancy {
    codly(languages: codly-languages)
  }

  // Main body.
  body

  // Display bibliography.
  if bibliography != none {
    pagebreak()
    show std-bibliography: set text(0.85em)
    // Use default paragraph properties for bibliography.
    show std-bibliography: set par(leading: 0.65em, justify: false, linebreaks: auto)
    bibliography
  }

  // Display indices of figures, tables, and listings.
  let fig-t(kind) = figure.where(kind: kind)
  let has-fig(kind) = counter(fig-t(kind)).get().at(0) > 0
  if figure-index.enabled or table-index.enabled or listing-index.enabled {
    show outline: set heading(outlined: true)
    context {
      let imgs = figure-index.enabled and has-fig(image)
      let tbls = table-index.enabled and has-fig(table)
      let lsts = listing-index.enabled and has-fig(raw)
      if imgs or tbls or lsts {
        // Note that we pagebreak only once instead of each each individual index. This is
        // because for documents that only have a couple of figures, starting each index
        // on new page would result in superfluous whitespace.
        pagebreak()
      }

      if imgs {
        outline(
          title: figure-index.at("title", default: "Index of Figures"),
          target: fig-t(image),
        )
      }
      if tbls {
        outline(
          title: table-index.at("title", default: "Index of Tables"),
          target: fig-t(table),
        )
      }
      if lsts {
        outline(
          title: listing-index.at("title", default: "Index of Listings"),
          target: fig-t(raw),
        )
      }
    }
  }
}


