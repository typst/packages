#import "@preview/codly:1.0.0": *
#import "@preview/glossarium:0.4.1": make-glossary, print-glossary, gls, glspl
#import "@preview/in-dexter:0.4.2": *

#let fontys-purple-1 = rgb("663366")
#let fontys-purple-2 = rgb("B59DB5")
#let fontys-pink-1   = rgb("E4047C")
#let fontys-blue-1   = rgb("1F3763")
#let fontys-blue-2   = rgb("2F5496")
#let code-name-color = fontys-blue-2.lighten(35%)

// States
#let censored-state = state("style", "0")

// Misc functions
#let hlink(url, content: none) = {
  link(url)[
    #underline[#text([
      #if content == none {
        url
      } else {
        content
      }
    ], fill: fontys-blue-2)]
  ]
}

#let sensitive(textl) = {
  context [
    #if (censored-state.at(here()) == 1) {
      text(
        textl.replace(regex("."), "█"),
        fill: black,
        font: "Arial"
      )
    } else {
      textl
    }
  ]
}

#let fhict-table(
  columns: (),
  content: (),
  background-color-heading: fontys-purple-1,
  background-color: white,
  text-color-heading: white,
  text-color: black,
  top-colored: true,
  left-colored: false,
) = {
  table(
    columns: columns,
    inset: 7pt,
    align: horizon,
    fill: (
      if top-colored and left-colored {
        (column, row) => if column==0 or row==0 { background-color-heading } else { background-color }
      } else if top-colored {
        (_, row) => if row==0 { background-color-heading } else { background-color }
      } else if left-colored {
        (column, _) => if column==0 { background-color-heading } else { background-color }
      }
    ),
    ..for row in content {
      if (row == content.at(0)) and top-colored {
        for item in row {
          (text(fill: text-color-heading)[#strong(item)],)
        }
      } else {
        for item in row {
          if (item == row.at(0)) and left-colored {
            (text(fill: text-color-heading)[#strong(item)],)
          } else {
            (text(fill: text-color)[#item],)
          }
        }
      }
    }
  )
}

#let text-box(background-color: luma(240), stroke-color: black, text-color: black, content) = {
  rect(fill: background-color, width: 100%, stroke: (left: 0.25em + stroke-color))[
    #text(
      fill: text-color,
      content
    )
  ]
}

#let lined-box(title, body, line-color: red) = block(
  above: 2em, stroke: 0.5pt + line-color,
  width: 100%, inset: 14pt,
  breakable: false
)[
  #set text(font: "Roboto", fill: line-color)
  #place(
    top + left,
    dy: -6pt - 14pt,
    dx: 6pt - 14pt,
    block(fill: white, inset: 2pt)[*#title*]
  )
  #body
]

#let page-intentionally-left-blank-sub(newpage, force) = {
  block(height: 95%, width: 100%)[
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
  subtitle: "Document Subtitle",
  subtitle-lines: 1,

  language: "en",
  available-languages: none,

  authors: none,

  version-history: none,

  glossary-terms: none,
  glossary-front: false,

  bibliography-file: none,
  citation-style: "ieee",

  toc-depth: 3,
  disable-toc: false,
  disable-chapter-numbering: false,

  pre-toc: none,
  table-of-figures: none,
  table-of-listings: none,

  appendix: none,

  watermark: none,
  censored: 0,

  print-extra-white-page: false,

  secondary-organisation-color: none,
  secondary-organisation-logo: none,
  secondary-organisation-logo-height: 6%,

  enable-index: false,
  index-columns: 2,

  body
) = {
  show: make-glossary

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

  // Set the header style
  let numbering-set = none
  if disable-chapter-numbering == false {
    numbering-set = "1.1"
  } else {
    numbering-set = none
  }

  set heading(numbering: numbering-set)

  show heading.where(level: 1): h => {text(strong(upper(h)), size: 18pt, fill: fontys-purple-1)}
  show heading.where(level: 2): h => {text(strong(upper(h)), size: 14pt, fill: fontys-pink-1)}
  show heading.where(level: 3): h => {text(upper(h), size: 12pt, fill: fontys-blue-1)}
  show heading.where(level: 4): h => {text(upper(h), size: 11pt, fill: fontys-blue-2)}
  show heading.where(level: 5): h => {text(emph(upper(h)), size: 11pt, fill: fontys-blue-2, font: "Calibri")}

  // Set the listing style
  show figure.where(kind: raw): it => {
    set align(left)
    it.body
    it.caption
  }

  // Set Cover Page
  set page("a4",
  background: [
    // Main background triangle
    #place(top + left, path(
        fill: fontys-purple-2,
        closed: true,
        (0%, 0%),
        (5%, 0%),
        ((70%, 45%), (-20pt, -20pt)),
        ((75%, 50%), (0%, -15pt)),
        ((70%, 55%), (20pt, -20pt)),
        (5%, 100%),
        (0%, 100%)
    ))
    #if secondary-organisation-color != none {
      // Secondary organisation triangle
      place(top + left, path(
        fill: secondary-organisation-color,
        closed: true,
        (10%, 100%),
        (101%, 37%),
        (101%, 100%)
      ))
    }

    #if secondary-organisation-logo != none {
      // Secondary organisation logo
      place(bottom + right, dx: -30pt, dy: -120pt, image.decode(
        secondary-organisation-logo,
        height: secondary-organisation-logo-height,
      ))
    }
    // For scociety image
    #place(top + left, dx: 70pt, dy: 70pt, image(
        "assets/fontys-for-society.png",
        height: 9%,
    ))
    // Language boxes
    #if available-languages != none {
      place(left + horizon, dy: 322pt, dx: -10pt,
        box(
          width: 37%,
          height: 2em - 3pt,
          fill: fontys-pink-1,
          radius: 10pt,
          place(left + top, dx: 10pt + 10pt, dy: 5pt,
            [
            #text(12pt, fill: white, font: "Roboto")[
              *#language-dict.at("this-doc-is-avail"):*
          ]])
        )
      )
      // Place flags
      place(left + horizon, dy: 350pt, dx: 10pt,
        for l-language in language-data.keys() {
          if lower(l-language) in available-languages {
            let path = ""
            path = "assets/" + l-language + "-flag.svg"
            box(height: 25pt + 5pt, width: 37.5pt + 5pt + 2.5pt, fill: fontys-pink-1.lighten(50%), radius: 1pt)[
              #place(center + horizon,
                image(path, height: 25pt, width: 37.5pt)
              )
            ]
            h(5pt)
          }
        }
      )
      // Place other flag covers
      place(left + horizon, dy: 350pt, dx: 10pt,
        for l-language in language-data.keys() {
          if lower(l-language) in available-languages {
            if l-language == upper(language) {
              box(height: 25pt + 5pt, width: 37.5pt + 5pt + 2.5pt, fill: rgb(255,255,255,0), radius: 1pt)
            } else {
              box(height: 25pt + 5pt, width: 37.5pt + 5pt + 2.5pt, fill: rgb(255,255,255,100), radius: 1pt)
            }
            h(5pt)
          }
        }
      )
    }
    // Title
    #place(left + horizon, dy: -20pt, dx: 40pt,
        box(
            height: 40pt,
            inset: 10pt,
            fill: fontys-pink-1,
            text(30pt, fill: white, font: "Roboto")[
                *#upper(title)*
            ]
        )
    )
    // Sub title
    #place(left + horizon, dy: 20pt + ((22pt * (subtitle-lines - 1)) / 2), dx: 40pt,
        box(
            height: 30pt + (22pt * (subtitle-lines - 1)),
            inset: 10pt,
            fill: white,
            text(20pt, fill: fontys-purple-1, font: "Roboto")[
                *#upper(subtitle)*
            ]
        )
    )
    // Authors
    #censored-state.update(censored)
    #set text(fill: fontys-purple-1)
    #if authors != none {
      if authors.all(x => "email" in x) {
        place(left + horizon,
        dy: 60pt + (
          (authors.len() - 1) * 15pt
        ) + (22pt * (subtitle-lines - 1)), dx: 40pt,
        box(
          height: 35pt + ((authors.len() - 1) * 30pt),
          inset: 10pt,
          fill: white,
          text(10pt)[
            #if type(authors.at(0).name) == dictionary {
              authors.map(author => strong(author.name.content) + linebreak() + "      " + link("mailto:" + author.email)[#author.email]).join(",\n")
            } else {
              authors.map(author => strong(author.name) + linebreak() + "      " + link("mailto:" + author.email)).join(",\n")
            }]))
      } else {
        place(left + horizon, dy: 48pt + (
          if authors.len() == 1 {
            5pt
          } else {
            (authors.len() - 1) * 10pt
          }
        ) + (22pt * (subtitle-lines - 1)), dx: 40pt,
        box(
          inset: 10pt,
          fill: white,
          height: 20pt + ((authors.len() - 1) * 15pt),
          text(10pt, fill: fontys-purple-1, font: "Roboto")[
            #if type(authors.at(0).name) == dictionary {
              [*#authors.map(author => author.name.content).join(",\n")*]
            } else {
              [*#authors.map(author => author.name).join(",\n")*]
            }
          ]))
      }
    }

    #set text(fill: black)
    // Date
    #if secondary-organisation-color == none {
      place(right + horizon, dy: 330pt,
        box(
          width: 40%,
          height: 35pt,
          fill: fontys-pink-1,
          place(left + horizon, dx: 10pt,
            text(30pt, fill: white, font: "Roboto")[
              *#datetime.today().display()*
            ]
          )
        )
      )
    } else {
      place(right + horizon, dy: 330pt,
        box(
          width: 40%,
          height: 35pt,
          fill: white,
          place(left + horizon, dx: 10pt,
            text(30pt, fill: secondary-organisation-color, font: "Roboto")[
              *#datetime.today().display()*
            ]
          )
        )
      )
    }
  ],
  foreground: [
    #if watermark != none [
    #place(center + horizon, rotate(24deg,
        text(60pt, fill: rgb(0, 0, 0, 70), font: "Roboto")[
            *#upper(watermark)*
        ]
    ))
    ]
  ]
  )

  // Show the cover page
  censored-state.update(censored)
  box()
  pagebreak()

  let pre-toc-numbering = "1"

  if (version-history != none) or (pre-toc != none) or (disable-toc == false) or (disable-toc == false) or (glossary-terms != none and glossary-front == true) or ((table-of-figures != none) and (table-of-figures != false)) or ((table-of-listings != none) and (table-of-listings != false)) {
    pre-toc-numbering = "I"
  }

  // Set the page style for non body pages
  set page("a4",
    background: [],
    footer: [
        #place(left + horizon, dy: -25pt, dx: -15pt,
            image("assets/for-society.png", height: 200%)
        )
        #place(right + horizon, dy: -25pt,
            text(15pt, fill: fontys-purple-1, font: "Roboto")[
              *#counter(page).display(pre-toc-numbering)*
            ]
        )
    ],
    numbering: pre-toc-numbering
  )
  counter(page).update(1)

  if print-extra-white-page == true {
    page-intentionally-left-blank(force: true)
  }

  // Show the version history
  if version-history != none {
    heading(language-dict.at("version-history"), outlined: false, numbering: none)
    fhict-table(
      columns: (auto, auto, auto, 1fr),
      content: (
        (language-dict.at("version"), language-dict.at("date"), language-dict.at("author"), language-dict.at("changes")),
        ..version-history.map(version => (
          version.version,
          version.date,
          version.author,
          version.changes,
        )),
      ),
    )
    pagebreak()
    if print-extra-white-page == true { page-intentionally-left-blank() }
  }

  show: codly-init.with()
  codly(languages: (
      rust: (name: "Rust", color: code-name-color),
      rs: (name: "Rust", color: code-name-color),
      cmake: (name: "CMake", color: code-name-color),
      cpp: (name: "C++", color: code-name-color),
      c: (name: "C", color: code-name-color),
      py: (name: "Python", color: code-name-color),
      java: (name: "Java", color: code-name-color),
      js: (name: "JavaScript", color: code-name-color),
      sh: (name: "Shell", color: code-name-color),
      bash: (name: "Bash", color: code-name-color),
      json: (name: "JSON", color: code-name-color),
      xml: (name: "XML", color: code-name-color),
      yaml: (name: "YAML", color: code-name-color),
      typst: (name: "Typst", color: code-name-color),
    ),
    number-format: none,
    display-icon: false,
  )

  if pre-toc != none {
    // Show the pre-toc
    // Disable heading numbering and appearing in the TOC
    set heading(numbering: none, outlined: false)
    pre-toc
    pagebreak()
    set heading(numbering: numbering-set, outlined: true)
    // if disable-toc == false or (glossary-terms != none and glossary-front == true) or table-of-figures == true or table-of-listings == true {
    //   pagebreak()
    // }
    if print-extra-white-page == true { page-intentionally-left-blank() }
  }

  if disable-toc == false {
    // Show the table of contents
    show outline.entry: it => {
      let body = [#it.body #box(width: 1fr, it.fill) #it.page]
      if it.level == 1 {
        if it.element.supplement == [Appendix] {
          [Appendix #body]
        } else {
          body
        }
      } else {
        body
      }
    }
    outline(
      title: language-dict.at("table-of-contents"),
      depth: toc-depth,
      indent: n => [#h(1em)] * n,
    )
    if (glossary-terms != none and glossary-front == true) or table-of-figures == true or table-of-listings == true {
      pagebreak()
    }
    if print-extra-white-page == true { pagebreak(); page-intentionally-left-blank() }
  }

  // Show the Glossary in the front
  if glossary-terms != none and glossary-front == true {
    heading(language-dict.at("glossary"), numbering: none, outlined: false)
    print-glossary(
    (
      glossary-terms
    ),
    )
    if table-of-figures == true or table-of-listings == true {
      pagebreak()
    }
    if print-extra-white-page == true { page-intentionally-left-blank() }
  }

  // Show the table of figures if requested
  if table-of-figures == true {
    outline(
      title: language-dict.at("table-of-figures"),
      target: figure.where(kind: image),
    )
    if table-of-listings == true {
      pagebreak()
    }
    if print-extra-white-page == true { page-intentionally-left-blank() }
  }
  
  // Show the table of listings if requested
  if table-of-listings == true {
    outline(
      title: language-dict.at("table-of-listings"),
      target: figure.where(kind: raw),
    )
    if print-extra-white-page == true { pagebreak(); page-intentionally-left-blank(newpage: false) }
  }

  // Set the page style for body pages'
  // block()
  set page("a4",
    background: [],
    footer: [
        #place(left + horizon, dy: -25pt, dx: -15pt,
            image("assets/for-society.png", height: 200%)
        )
        #place(right + horizon, dy: -25pt,
            text(15pt, fill: fontys-purple-1, font: "Roboto")[
                *#counter(page).display()*
            ]
        )
    ],
    numbering: "1"
  )
  counter(page).update(1)

  // Show the page's contents
  body

  if (glossary-terms != none and glossary-front == false) or bibliography-file != none or appendix != none or enable-index == true{
    pagebreak()
  }
  if print-extra-white-page == true { page-intentionally-left-blank(odd: false) }

  // Show the Glossary in the back
  if glossary-terms != none and glossary-front == false {
    heading(language-dict.at("glossary"), numbering: none)
    print-glossary(
    (
      glossary-terms
    ),
    )
    pagebreak()
    if print-extra-white-page == true and (bibliography-file != none or appendix != none) { page-intentionally-left-blank(odd: false) }
  }

  // Show the bibliography
  if bibliography-file != none {
    set bibliography(title: language-dict.at("references"), style: "ieee")
    bibliography-file
    pagebreak()
    if print-extra-white-page == true and appendix != none { page-intentionally-left-blank(odd: false) }
  }

  // Show the appendix
  if appendix != none {
    // Set appendix page style
    counter(heading).update(0)
    set heading(numbering: "A.A", outlined: false)
    show heading.where(level: 1): set heading(numbering: "A.A:", outlined: true, supplement: "Appendix")
    show heading.where(level: 1): it => block(text(strong[#upper[
      #if it.numbering != none [ Appendix #counter(heading).display(it.numbering)]
      #it.body
    ]], size: 18pt, fill: fontys-purple-1))

    appendix
    if enable-index == true { pagebreak() }
    if print-extra-white-page == true and enable-index == true { page-intentionally-left-blank(odd: false) }
  }

  // Show the index
  if enable-index == true {
    show heading.where(level: 1): h => {text(strong(upper(h)), size: 18pt, fill: fontys-purple-1)}
    heading(language-dict.at("index"), numbering: none)
    columns(index-columns)[
      #make-index()
    ]
  }
}
