#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *
#import "@preview/glossarium:0.5.9": gls, glspl, make-glossary, print-glossary, register-glossary
#import "@preview/in-dexter:0.7.2": *
#import "@preview/hydra:0.6.2": hydra

#let fontys-purple-1 = rgb("663366")
#let fontys-purple-2 = rgb("B59DB5")
#let fontys-pink-1 = rgb("E5007D")
#let fontys-blue-1 = rgb("1F3763")
#let fontys-blue-2 = rgb("2F5496")
#let code-name-color = fontys-purple-1
#let code-zebra-color = fontys-purple-1.lighten(85%)

// States
#let censored-state = state("style", "0")
#let appendices-state = state("separator", "0")

// Misc functions
#let hlink(url, content: none) = {
  link(url)[
    #underline[#text(
      [
        #if content == none {
          url
        } else {
          content
        }
      ],
      fill: fontys-blue-2,
    )]
  ]
}

#let sensitive(textl) = {
  context [
    #if (censored-state.at(here()) == 1) {
      text(
        textl.replace(regex("."), "█"),
        fill: black,
        font: "Arial",
      )
    } else {
      textl
    }
  ]
}

// 1: Fill the top row and left column
// 2: Fill the top row
// 3: Fill the left column
// 4: No fill
// 5: Fill the top row and left column w/ border
// 6: Fill the top row w/ border
// 7: Fill the left column w/ border
// 8: No fill w/ border
#let ftable(style: 2, columns: none, ..tablec) = {
  set table(
    inset: 8pt
      - if (style > 4) {
        1pt
      } else {
        0pt
      },
    gutter: -1pt
      + if (style > 4) {
        1pt
      } else {
        0pt
      },
    align: horizon,
    stroke: if (style <= 4) {
      none
    } else {
      1pt + black
    },
    fill: (x, y) => if (x == 0 and (style == 1 or style == 3 or style == 5 or style == 7))
      or (
        y == 0 and (style == 1 or style == 2 or style == 5 or style == 6)
      ) {
      fontys-purple-1
    } else if (calc.even(y) and style <= 4) {
      code-zebra-color
    } else {
      white
    },
  )

  show table.cell: it => {
    if (
      (it.x == 0 and (style == 1 or style == 3 or style == 5 or style == 7))
        or (
          it.y == 0 and (style == 1 or style == 2 or style == 5 or style == 6)
        )
    ) {
      set text(white)
      strong(it)
    } else {
      it
    }
  }

  table(
    columns: columns,
    ..tablec
  )
}

#let set-code-line-nr(start: 1) = {
  if (start == -1) {
    codly(number-format: none)
  } else {
    codly(number-format: number => [ #(number + start - 1) ])
  }
}

#let text-box(background-color: luma(240), stroke-color: black, text-color: black, content) = {
  rect(fill: background-color, width: 100%, stroke: (left: 0.25em + stroke-color))[
    #text(
      fill: text-color,
      content,
    )
  ]
}

#let lined-box(title, body, line-color: red) = block(
  above: 2em,
  stroke: 0.5pt + line-color,
  width: 100%,
  inset: 14pt,
  breakable: false,
)[
  #set text(font: "Roboto", fill: line-color)
  #place(
    top + left,
    dy: -6pt - 14pt,
    dx: 6pt - 14pt,
    block(fill: white, inset: 2pt)[*#title*],
  )
  #body
]

#let page-intentionally-left-blank-sub(newpage, force) = {
  block(height: 100%, width: 100%)[
    #align(center + horizon)[
      #text(fill: black, font: "Arial", size: 12pt)[
        *This page is intentionally left blank.*
      ]
    ]
  ]
  if newpage {
    pagebreak()
  }
}

#let page-intentionally-left-blank(newpage: true, force: false, odd: true) = {
  context [
    #if odd == true {
      if calc.odd(counter(page).get().at(0)) or force == true {
        page-intentionally-left-blank-sub(newpage, force)
      }
    } else {
      if calc.even(counter(page).get().at(0)) or force == true {
        page-intentionally-left-blank-sub(newpage, force)
      }
    }
  ]
}

// Document
#let fhict-doc(
  title: "Document Title",
  subtitle: none,
  language: "en",
  available-languages: none,
  date: none,
  authors-title: none,
  authors: none,
  assessors-title: none,
  assessors: none,
  version-history: none,
  distribution-history: none,
  glossary-terms: none,
  glossary-front: false,
  bibliography-file: none,
  citation-style: "ieee",
  toc-depth: 3,
  disable-toc: false,
  disable-chapter-numbering: false,
  disable-version-on-cover: false,
  chapter-on-new-page: false,
  pre-toc: none,
  table-of-figures: none,
  table-of-listings: none,
  table-of-tables: none,
  appendix: none,
  watermark: none,
  censored: 0,
  line-numbering: false,
  line-numbering-scope: "page",
  print-extra-white-page: false,
  secondary-organisation-color: none,
  secondary-organisation-logo: none,
  secondary-organisation-footer-logo: none,
  secondary-organisation-logo-cover-size: 3.5cm,
  secondary-organisation-logo-footer-size: 0.6cm,
  disable-secondary-organisation-logo-footer: false,
  enable-index: false,
  index-columns: 2,
  header-content-spacing: (50%, 50%),
  body,
) = {
  // Init states
  appendices-state.update(0)
  censored-state.update(censored)

  show: make-glossary
  if glossary-terms != none {
    register-glossary(glossary-terms)
  }

  let meta-authors = ""
  let index-main(..args) = index(fmt: strong, ..args)

  // Load language data
  let language-data = yaml("assets/language.yml")
  let language-dict = language-data.at(upper(language)).at("localization")
  set text(lang: language)

  // Set metadata
  if authors != none and censored == 0 {
    if type(authors.at(0).name) == dictionary {
      meta-authors = authors.map(author => author.name.string)
    } else {
      meta-authors = authors.map(author => author.name)
    }
  }

  set document(
    title: title,
    author: meta-authors,
  )

  // Set the document's style
  set text(font: "Roboto", size: 11pt, fill: black)
  set cite(style: citation-style)

  // Set inline block style
  show raw.where(block: false): it => (
    h(0.5em) + box(fill: code-zebra-color, radius: 0.2em, outset: 0.2em, it) + h(0.5em)
  )

  // Set the header style
  let numbering-set = none
  if disable-chapter-numbering == false {
    numbering-set = "1.1"
  } else {
    numbering-set = none
  }

  set heading(numbering: numbering-set)

  show heading.where(level: 1): h => (
    if (chapter-on-new-page == true) {
      pagebreak(weak: true)
    }
      + {
        text(strong(upper(h)), size: 18pt, fill: fontys-purple-1)
      }
  )
  show heading.where(level: 2): h => {
    text(strong(upper(h)), size: 14pt, fill: fontys-pink-1)
  }
  show heading.where(level: 3): h => {
    text(upper(h), size: 12pt, fill: fontys-blue-1)
  }
  show heading.where(level: 4): h => {
    text(upper(h), size: 11pt, fill: fontys-blue-2)
  }
  show heading.where(level: 5): h => {
    text(emph(upper(h)), size: 11pt, fill: fontys-blue-2, font: "Calibri")
  }

  // Set the listing style
  show figure.where(kind: raw): it => {
    set align(left)
    it.body
    set align(center)
    it.caption
  }

  // Set Cover Page
  set page(
    "a4",
    background: [
      // Main background triangle
      #place(
        top + left,
        curve(
          fill: fontys-purple-2,
          stroke: none,
          curve.move((0%, 0%)),
          curve.line((5%, 0%)),
          curve.line((70%, 45%)),
          curve.cubic(
            (70%, 45%),
            (78%, 50%),
            (70%, 55%),
          ),
          curve.line((70%, 55%)),
          curve.line((5%, 100%)),
          curve.line((0%, 100%)),
          curve.close(),
        ),
      )
      #if secondary-organisation-color != none {
        // Secondary organisation triangle
        place(
          top + left,
          curve(
            fill: secondary-organisation-color,
            stroke: none,
            curve.move((100%, 100%)),
            curve.line((10%, 100%), relative: false),
            curve.line((101%, 37%), relative: false),
            curve.line((101%, 100%), relative: false),
            curve.close(),
          ),
        )
      }

      #if secondary-organisation-logo != none {
        // Secondary organisation logo
        place(
          bottom + right,
          dx: -30pt,
          dy: -120pt,
          image(secondary-organisation-logo, height: secondary-organisation-logo-cover-size),
        )
      }
      // For scociety image
      #place(
        top + left,
        dx: 70pt,
        dy: 70pt,
        image(
          "assets/fontys-for-society.png",
          height: 9%,
        ),
      )
      // Language boxes
      #if available-languages != none {
        place(
          right + top,
          dy: 0pt,
          dx: -10pt,
          box[
            #for l-language in language-data.keys() {
              if lower(l-language) in available-languages {
                if l-language == upper(language) {
                  box(height: 25pt + 5pt, width: 37.5pt + 5pt + 2.5pt, fill: fontys-pink-1.lighten(50%))
                } else {
                  box(height: 25pt + 5pt, width: 37.5pt + 5pt + 2.5pt, fill: rgb("#ffffff00"), radius: 1pt)
                }
                h(5pt)
              }
            }
          ],
        )
        place(
          right + top,
          dy: 15pt,
          dx: -10pt,
          box[
            #for l-language in language-data.keys() {
              if lower(l-language) in available-languages {
                let path = ""
                path = "assets/" + l-language + "-flag.svg"
                box(height: 25pt + 5pt, width: 37.5pt + 5pt + 2.5pt, fill: fontys-pink-1.lighten(50%), radius: 1pt)[
                  #place(
                    center + horizon,
                    image(path, height: 25pt, width: 37.5pt),
                  )
                ]
                h(5pt)
              }
            }
          ],
        )
      }

      // Title, Subtitle, Authors, Assessors
      #set text(fill: fontys-purple-1)
      #place(
        left + top,
        dy: 380pt,
        dx: 40pt,
        grid(
          columns: (25%, 60%),
          rows: auto,
          stroke: none,
          gutter: 5pt,
          if (title != none) {
            grid.cell(
              colspan: 2,
              box(
                height: auto,
                inset: 10pt,
                fill: fontys-pink-1,
                text(30pt, fill: white, font: "Roboto")[
                  *#upper(title)*
                ],
              ),
            )
          } else {
            grid.cell(colspan: 2)
          },
          if (subtitle != none) {
            grid.cell(
              colspan: 2,
              box(
                height: auto,
                inset: 10pt,
                fill: white,
                text(20pt, fill: fontys-purple-1, font: "Roboto")[
                  *#upper(subtitle)*
                ],
              ),
            )
          } else {
            grid.cell(colspan: 2, [#h(-20pt)])
          },

          if (authors != none) {
            rect(
              height: auto,
              width: if (assessors == none) {
                auto
              } else {
                100%
              },
              stroke: none,
              fill: white,
              inset: 7pt,
            )[
              #set text(size: 9pt)
              #if authors-title != none {
                text(11pt)[*#authors-title:*#linebreak()]
              }
              #if authors.all(x => "email" in x) {
                if type(authors.at(0).name) == dictionary {
                  authors
                    .map(author => (
                      strong(author.name.content)
                        + linebreak()
                        + text(size: 6pt)[#{
                            "   " * 4
                          }#link("mailto:" + author.email)[#author.email]]
                    ))
                    .join("\n")
                } else {
                  authors
                    .map(author => (
                      author.name
                        + linebreak()
                        + text(size: 7pt)[#{
                            "   " * 4
                          }#link("mailto:" + author.email)[#author.email]]
                    ))
                    .join("\n")
                }
              } else {
                if type(authors.at(0).name) == dictionary {
                  [#authors.map(author => author.name.content).join("\n")]
                } else {
                  [#authors.map(author => author.name).join("\n")]
                }
              }
            ]
          },
          if (assessors != none) {
            rect(height: auto, width: auto, stroke: none, fill: white, inset: 7pt)[
              #set text(size: 9pt)
              #if assessors-title != none {
                text(11pt)[*#assessors-title:*#linebreak()]
              }
              #text(size: 8pt)[
                #for assessor in assessors {
                  if "title" in assessor {
                    strong(assessor.title) + strong(": ")
                  }
                  if "name" in assessor and "email" in assessor {
                    link("mailto:" + assessor.email)[#assessor.name]
                  } else if "name" in assessor {
                    assessor.name
                  }
                  if (assessors.at(assessors.len() - 1) != assessor) {
                    ", "
                  }
                }
              ]
            ]
          },
        ),
      )
      #set text(size: 11pt, fill: black)

      // Date
      #if secondary-organisation-color == none {
        place(
          right + horizon,
          dy: 330pt,
          box(
            height: 40pt,
            inset: 10pt,
            fill: fontys-pink-1,
            text(30pt, fill: white, font: "Roboto")[
              #if (date != none) {
                strong(date)
              } else {
                strong(datetime.today().display())
              }
            ],
          ),
        )
      } else {
        place(
          right + horizon,
          dy: 330pt,
          box(
            height: 40pt,
            inset: 10pt,
            fill: white,
            text(30pt, fill: secondary-organisation-color, font: "Roboto")[
              #if (date != none) {
                strong(upper(date))
              } else {
                strong(datetime.today().display())
              }
            ],
          ),
        )
      }

      // Version
      #if (
        secondary-organisation-color == none
          and version-history != none
          and version-history.len() > 0
          and disable-version-on-cover == false
      ) {
        place(
          right + horizon,
          dy: 370pt,
          box(
            height: 30pt,
            inset: 10pt,
            fill: fontys-pink-1,
            text(20pt, fill: white, font: "Roboto")[
              #version-history.at(version-history.len() - 1).at("version")
            ],
          ),
        )
      } else if version-history != none and version-history.len() > 0 and disable-version-on-cover == false {
        place(
          right + horizon,
          dy: 370pt,
          box(
            height: 30pt,
            inset: 10pt,
            fill: white,
            text(20pt, fill: secondary-organisation-color, font: "Roboto")[
              #version-history.at(version-history.len() - 1).at("version")
            ],
          ),
        )
      }
    ],
    foreground: [
      #if watermark != none [
        #place(
          center + horizon,
          rotate(
            24deg,
            text(60pt, fill: rgb(0, 0, 0, 70), font: "Roboto")[
              *#upper(watermark)*
            ],
          ),
        )
      ]
    ],
  )

  // Show the cover page
  censored-state.update(censored)
  box()
  pagebreak()

  let pre-toc-numbering = "1"

  if (
    (version-history != none)
      or (distribution-history != none)
      or (pre-toc != none)
      or (disable-toc == false)
      or (disable-toc == false)
      or (
        glossary-terms != none and glossary-front == true
      )
      or ((table-of-figures != none) and (table-of-figures != false))
      or (
        (table-of-listings != none) and (table-of-listings != false)
      )
      or (print-extra-white-page == true)
  ) {
    pre-toc-numbering = "I"
  }

  // Set the page style for non body pages
  set page(
    "a4",
    background: [],
    header: [
      #set par(justify: false)
      #box(width: 100%)[
        #pad(top: 2em)[
          #grid(
            columns: header-content-spacing,
            rows: (1fr, 1fr),
            align: alignment.bottom,
            grid.cell(align: alignment.left)[
              #context [
                #let chapter = hydra(1)
                #if chapter != none {
                  text(10pt, fill: fontys-purple-1, font: "Roboto")[
                    *#upper(chapter)*
                  ]
                }
              ]
            ],
            grid.cell(align: alignment.right)[
              #text(10pt, fill: fontys-purple-1, font: "Roboto")[
                #upper[*#title*]
              ]
            ],
            grid.cell(colspan: 2, align: alignment.top)[
              #pad(y: 0.5em)[
                #line(length: 100%, stroke: 1pt + fontys-purple-1)
              ]
            ]
          )
        ]
      ]
    ],
    footer: [
      #place(left + horizon, dy: -10pt, dx: -15pt, image("assets/for-society.png", height: 3.5cm))
      #if (
        (secondary-organisation-logo != none or secondary-organisation-footer-logo != none)
          and (disable-secondary-organisation-logo-footer == false)
      ) {
        place(right + horizon, dy: -6pt, image(
          if (secondary-organisation-footer-logo != none) { secondary-organisation-footer-logo } else {
            secondary-organisation-logo
          },
          height: secondary-organisation-logo-footer-size,
        ))
      }
      #place(
        if (secondary-organisation-logo == none and secondary-organisation-footer-logo == none)
          or (disable-secondary-organisation-logo-footer == true) {
          right + horizon
        } else { center + horizon },
        dy: -10pt,
        text(15pt, fill: fontys-purple-1, font: "Roboto")[
          #context [
            *#counter(page).display(pre-toc-numbering)*
          ]
        ],
      )
      #place(
        left + top,
        line(length: 100%, stroke: 1pt + fontys-purple-1),
      )
    ],
    numbering: pre-toc-numbering,
  )
  counter(page).update(1)

  show: codly-init.with()
  codly(
    number-format: none,
    display-icon: true,
    zebra-fill: code-zebra-color,
    stroke: 1pt + code-zebra-color,
    languages: codly-languages,
  )


  if print-extra-white-page == true {
    page-intentionally-left-blank(newpage: false)
  }

  // Show the version history
  if version-history != none {
    heading(language-dict.at("version-history"), outlined: false, numbering: none)
    ftable(
      columns: (auto, auto, auto, 1fr),
      [#language-dict.at("version")],
      [#language-dict.at("date")],
      [#language-dict.at("author")],
      [#language-dict.at("changes")],
      ..for entry in version-history {
        ([#entry.version], [#entry.date], [#entry.author], [#entry.changes])
      },
    )
    pagebreak()
    if print-extra-white-page == true {
      page-intentionally-left-blank(newpage: false)
    }
  }

  // Show the distribution history
  if distribution-history != none {
    heading(language-dict.at("distribution-history"), outlined: false, numbering: none)
    ftable(
      columns: (1fr, auto, auto, auto, auto),
      [#language-dict.at("recipient")],
      [#language-dict.at("organisation")],
      [#language-dict.at("date")],
      [#language-dict.at("method")],
      [#language-dict.at("version")],
      ..for entry in distribution-history {
        ([#entry.recipient], [#entry.organisation], [#entry.date], [#entry.method], [#entry.version])
      },
    )
    pagebreak()
    if print-extra-white-page == true {
      page-intentionally-left-blank(newpage: false)
    }
  }

  if pre-toc != none {
    // Show the pre-toc
    // Disable heading numbering and appearing in the TOC
    set heading(numbering: none, outlined: false)
    if line-numbering == true {
      set par.line(
        numbering: num => {
          if (calc.rem(num, 5) == 0) {
            num
          } else if (num == 1) {
            num
          }
        },
        numbering-scope: line-numbering-scope,
      )
      pre-toc
    } else {
      pre-toc
    }
    pagebreak()
    set heading(numbering: numbering-set, outlined: true)
    // if disable-toc == false or (glossary-terms != none and glossary-front == true) or table-of-figures == true or table-of-listings == true {
    //   pagebreak()
    // }
    if print-extra-white-page == true {
      page-intentionally-left-blank(newpage: false)
    }
  }

  if disable-toc == false {
    // Show the table of contents
    show outline.entry.where(level: 1): it => {
      context [
        #if it.element.supplement == [#language-dict.at("appendix")] {
          if (appendices-state.at(here()) == 0) {
            [#language-dict.at("appendix-pl")]
            appendices-state.update(1)
          }
          it
        } else if (appendices-state.at(here()) == 1) {
          par[]
          it
        } else {
          it
        }
      ]
    }
    outline(
      title: language-dict.at("table-of-contents"),
      depth: toc-depth,
      indent: n => 1em * n,
    )
    if (
      (
        glossary-terms != none and glossary-front == true
      )
        or table-of-figures == true
        or table-of-listings == true
        or table-of-tables == true
    ) {
      if print-extra-white-page == false {
        pagebreak()
      }
    }
    if print-extra-white-page == true {
      pagebreak()
      page-intentionally-left-blank(newpage: false)
    }
  }

  // Show the Glossary in the front
  if glossary-terms != none and glossary-front == true {
    set heading(numbering: none, outlined: false)
    heading(language-dict.at("glossary"))
    print-glossary(glossary-terms)
    if table-of-figures == true or table-of-listings == true or table-of-tables == true {
      pagebreak()
    }
    if print-extra-white-page == true {
      page-intentionally-left-blank(newpage: false)
    }
  }

  // Show the table of figures if requested
  if table-of-figures == true {
    outline(
      title: language-dict.at("table-of-figures"),
      target: figure.where(kind: image),
    )
    if table-of-listings == true or table-of-tables == true {
      pagebreak()
    }
    if print-extra-white-page == true {
      page-intentionally-left-blank(newpage: false)
    }
  }

  // Show the table of listings if requested
  if table-of-listings == true {
    outline(
      title: language-dict.at("table-of-listings"),
      target: figure.where(kind: raw),
    )
    if table-of-tables == true {
      pagebreak()
    }
    if print-extra-white-page == true {
      page-intentionally-left-blank(newpage: false)
    }
  }

  // Show the table of tables if requested
  if table-of-tables == true {
    outline(
      title: language-dict.at("table-of-tables"),
      target: figure.where(kind: table),
    )
    if print-extra-white-page == true {
      pagebreak()
      page-intentionally-left-blank(newpage: false)
    }
  }

  // Set the page style for body pages'
  // block()
  set page(
    "a4",
    background: [],
    footer: [
      #place(left + horizon, dy: -10pt, dx: -15pt, image("assets/for-society.png", height: 3.5cm))
      #if (
        (secondary-organisation-logo != none or secondary-organisation-footer-logo != none)
          and (disable-secondary-organisation-logo-footer == false)
      ) {
        place(right + horizon, dy: -6pt, image(
          if (secondary-organisation-footer-logo != none) { secondary-organisation-footer-logo } else {
            secondary-organisation-logo
          },
          height: secondary-organisation-logo-footer-size,
        ))
      }
      #place(
        if (secondary-organisation-logo == none and secondary-organisation-footer-logo == none)
          or (disable-secondary-organisation-logo-footer == true) {
          right + horizon
        } else { center + horizon },
        dy: -10pt,
        text(15pt, fill: fontys-purple-1, font: "Roboto")[
          #context [
            *#counter(page).display()*
          ]
        ],
      )
      #place(
        left + top,
        line(length: 100%, stroke: 1pt + fontys-purple-1),
      )
    ],
    numbering: "1",
  )
  counter(page).update(1)

  // Show the page's contents
  if line-numbering == true {
    set par.line(
      numbering: num => {
        if (calc.rem(num, 5) == 0) {
          num
        } else if (num == 1) {
          num
        }
      },
      numbering-scope: line-numbering-scope,
    )
    body
  } else {
    body
  }

  if (
    (
      glossary-terms != none and glossary-front == false
    )
      or bibliography-file != none
      or appendix != none
      or enable-index == true
  ) {
    pagebreak()
  }
  if print-extra-white-page == true {
    page-intentionally-left-blank(odd: false)
  }

  // Show the Glossary in the back
  if glossary-terms != none and glossary-front == false {
    set heading(numbering: none, outlined: false)
    heading(language-dict.at("glossary"))
    print-glossary(glossary-terms)
    if (bibliography-file != none or appendix != none or enable-index == true) {
      pagebreak()
    }
    if print-extra-white-page == true and (bibliography-file != none or appendix != none or enable-index == true) {
      page-intentionally-left-blank(odd: false)
    }
  }

  // Show the bibliography
  if bibliography-file != none {
    set bibliography(title: language-dict.at("references"), style: citation-style)
    bibliography-file
    if appendix != none or enable-index == true {
      pagebreak()
    }
    if print-extra-white-page == true and (appendix != none or enable-index == true) {
      page-intentionally-left-blank(odd: false)
    }
  }

  // Show the appendix
  if appendix != none {
    // Set appendix page style
    counter(heading).update(0)
    set heading(numbering: "A.A", outlined: false)
    show heading.where(level: 1): set heading(
      numbering: "A.A:",
      outlined: true,
      supplement: language-dict.at("appendix"),
    )
    show heading.where(level: 1): it => block(
      text(
        strong[#upper[
          #if it.numbering != none [ #language-dict.at("appendix") #counter(heading).display(it.numbering)]
          #it.body
        ]],
        size: 18pt,
        fill: fontys-purple-1,
      ),
    )

    if line-numbering == true {
      set par.line(
        numbering: num => {
          if (calc.rem(num, 5) == 0) {
            num
          } else if (num == 1) {
            num
          }
        },
        numbering-scope: line-numbering-scope,
      )
      appendix
    } else {
      appendix
    }
    if enable-index == true {
      pagebreak()
    }
    if print-extra-white-page == true and enable-index == true {
      page-intentionally-left-blank(odd: false)
    }
  }

  // Show the index
  if enable-index == true {
    show heading.where(level: 1): h => {
      text(strong(upper(h)), size: 18pt, fill: fontys-purple-1)
    }
    heading(language-dict.at("index"), numbering: none)
    columns(index-columns)[
      #make-index(use-page-counter: true)
    ]
  }
}
