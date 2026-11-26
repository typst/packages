// SPDX-License-Identifier: MIT
// A small document wrapper built from Typst's public APIs.

#let defaults = (
  title: "", author: "", email: "", institution: "", programme: "",
  supervisor: "", submission-date: "", keywords: (), anonymous: false,
  paper: "a4", margins: (x: 25mm, y: 25mm), font: "Libertinus Serif",
  font-size: 11pt, leading: 0.7em, paragraph-spacing: 0.8em,
  contents: true, contents-depth: 3, list-of-figures: true, list-of-tables: true,
  bibliography-file: none, citation-style: "ieee",
  frontmatter-order: ("abstract", "acknowledgements", "declaration"),
)

#let populated(value) = value != none and value != [] and value != ""

#let dissertation(
  config: (:), abstract: [], acknowledgements: none, declaration: none,
  abbreviations: none, symbols: none, glossary: none, appendices: none, body,
) = {
  assert(type(config) == dictionary, message: "config must be a dictionary")
  for key in config.keys() {
    assert(key in defaults, message: "Unknown configuration key: " + key)
  }
  let c = defaults + config
  for key in ("title", "author", "email", "institution", "programme",
    "supervisor", "submission-date", "paper", "font", "citation-style") {
    assert(type(c.at(key)) == str, message: key + " must be a string")
  }
  for key in ("anonymous", "contents", "list-of-figures", "list-of-tables") {
    assert(type(c.at(key)) == bool, message: key + " must be a boolean")
  }
  assert(c.title.trim() != "", message: "title is required")
  assert(c.anonymous or c.author.trim() != "", message: "author is required outside anonymous mode")
  assert(type(c.font-size) == length and c.font-size > 0pt,
    message: "font-size must be a positive absolute length")
  assert(type(c.contents-depth) == int and c.contents-depth >= 1 and c.contents-depth <= 6,
    message: "contents-depth must be an integer from 1 to 6")
  let margin-values = if type(c.margins) == dictionary { c.margins.values() } else { (c.margins,) }
  assert(margin-values.all(v => type(v) == length and v >= 0pt),
    message: "margins must contain non-negative absolute lengths")
  assert(type(c.keywords) == array and c.keywords.all(k => type(k) == str),
    message: "keywords must be an array of strings")
  assert(c.bibliography-file == none or type(c.bibliography-file) in (str, path),
    message: "bibliography-file must be a path, a package-relative string, or none")

  let front-keys = ("abstract", "acknowledgements", "declaration")
  assert(type(c.frontmatter-order) == array and c.frontmatter-order.len() == 3
    and front-keys.all(k => c.frontmatter-order.filter(v => v == k).len() == 1),
    message: "frontmatter-order must contain abstract, acknowledgements and declaration exactly once")

  set document(
    title: c.title,
    author: if c.anonymous { () } else { (c.author,) },
    keywords: if c.anonymous { () } else { c.keywords },
    date: none,
  )
  set text(font: c.font, size: c.font-size, lang: "en")
  set par(leading: c.leading, spacing: c.paragraph-spacing, justify: false)
  set page(paper: c.paper, margin: c.margins, header: none, footer: auto,
    numbering: "i", number-align: center + bottom)
  set heading(numbering: "1.1", outlined: true)
  set math.equation(numbering: "(1)")
  set table(inset: 6pt, stroke: 0.4pt + luma(65%))
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(above: 0pt, below: 1.1em, sticky: true)[
      #text(size: 1.65em, weight: "bold", hyphenate: false, it)
    ]
  }
  show heading.where(level: 2): set text(size: 1.2em)
  show figure.caption: set text(size: 0.95em)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set block(breakable: true)

  // The cover has no printed number. Front matter restarts at i afterwards.
  {
    set page(numbering: none, footer: none)
    text(size: 0.9em, tracking: 0.08em)[ACADEMIC DISSERTATION]
    v(1.5em)
    text(size: 2.15em, weight: "bold", hyphenate: false)[#c.title]
    v(1em)
    line(length: 100%, stroke: 0.6pt)
    v(1fr)
    if c.anonymous {
      [Anonymous author]
    } else {
      text(weight: "bold", c.author)
      if c.email != "" { linebreak(); link("mailto:" + c.email)[#c.email] }
      if c.institution != "" { parbreak(); c.institution }
      if c.programme != "" { linebreak(); c.programme }
      if c.supervisor != "" { parbreak(); [Supervisor: #c.supervisor] }
    }
    if c.submission-date != "" { parbreak(); c.submission-date }
    v(1.5em)
    text(size: 0.9em)[Independently maintained academic writing template]
    pagebreak()
  }
  counter(page).update(1)
  let section(title, content, outlined: false) = if populated(content) {
    heading(level: 1, numbering: none, outlined: outlined, title)
    content
    pagebreak(weak: true)
  }
  let fronts = (
    abstract: ([Abstract], abstract),
    acknowledgements: ([Acknowledgements], acknowledgements),
    declaration: ([Declaration], declaration),
  )
  for key in c.frontmatter-order {
    if key == "abstract" or not c.anonymous {
      let (title, content) = fronts.at(key)
      section(title, content)
    }
  }
  if c.contents {
    context if query(heading.where(outlined: true)).len() > 0 {
      outline(title: [Contents], depth: c.contents-depth, indent: auto)
      pagebreak(weak: true)
    }
  }
  for (enabled, kind, title) in (
    (c.list-of-figures, image, [List of Figures]),
    (c.list-of-tables, table, [List of Tables]),
  ) {
    if enabled {
      context if query(figure.where(kind: kind, outlined: true)).len() > 0 {
        outline(title: title, target: figure.where(kind: kind))
        pagebreak(weak: true)
      }
    }
  }
  for (title, content) in (
    ([List of Abbreviations], abbreviations),
    ([List of Symbols], symbols),
    ([Glossary], glossary),
  ) {
    section(title, content, outlined: true)
  }
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  body
  if c.bibliography-file != none {
    pagebreak(weak: true)
    bibliography(c.bibliography-file, style: c.citation-style, title: [References])
  }
  if populated(appendices) {
    pagebreak(weak: true)
    counter(heading).update(0)
    set heading(numbering: "A.1", supplement: [Appendix])
    appendices
  }
}
