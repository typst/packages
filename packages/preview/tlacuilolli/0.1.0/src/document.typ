/// Apply the editorial style and insert a title in the running document.
#let note-document(
  title: none,
  subtitle: none,
  category: none,
  author: none,
  date: none,
  description: none,
  keywords: (),
  show-byline: false,
  lang: "en",
  paper: "us-letter",
  font: ("Libertinus Serif", "New Computer Modern"),
  font-size: 13pt,
  margin: (x: 0.64in, top: 0.56in, bottom: 0.58in),
  show-page-number: false,
  title-size: 3.8em,
  subtitle-size: 1.34em,
  category-size: 0.86em,
  leading: 0.66em,
  paragraph-spacing: 1.28em,
  body,
) = {
  assert(title != none, message: "note-document requires a title")
  let authors = if author == none { () } else if type(author) == str { (author,) } else { author }
  set document(title: title, author: authors, date: date, description: description, keywords: keywords)
  set page(
    paper: paper,
    margin: margin,
    fill: white,
    numbering: if show-page-number { "1" },
    number-align: center + bottom,
  )
  set text(font: font, size: font-size, lang: lang, fill: rgb("#191919"), hyphenate: false)
  set par(justify: true, leading: leading, spacing: paragraph-spacing)
  set heading(numbering: none)
  set list(indent: 0.6em, body-indent: 0.6em)
  set enum(indent: 0.6em, body-indent: 0.6em)

  show heading: set text(weight: "semibold")
  show heading: set block(above: 1.14em, below: 0.63em, sticky: true)
  show math.equation.where(block: true): set text(size: 1.1em)
  show math.equation.where(block: true): set block(above: 1.18em, below: 1.18em)
  show quote.where(block: true): set block(inset: (x: 1.35em), above: 0.9em, below: 0.9em)
  show figure.caption: set text(size: 0.88em, fill: rgb("#343434"))
  show figure.caption: set par(justify: false, leading: 0.55em)
  show footnote.entry: set text(size: 0.8em)
  show footnote.entry: set par(justify: false, leading: 0.5em)
  show bibliography: set text(size: 0.92em)
  show bibliography: set par(justify: false, leading: 0.45em)
  show bibliography: it => {
    pagebreak(weak: true)
    it
    pagebreak(weak: true)
  }

  block(width: 100%, below: 2.33em, sticky: true, breakable: false, align(center, context {
    let size = title-size.to-absolute()
    show std.title: it => block(above: 0pt, below: 0pt, {
      set text(size: size, weight: "regular", bottom-edge: "descender")
      set par(leading: 0.23em)
      it.body
    })
    set par(justify: false)
    if category != none {
      text(size: category-size, tracking: 0.81em, upper(category))
      v(2.2em)
    }
    std.title(title)
    if subtitle != none {
      v(0.54em)
      text(size: subtitle-size, style: "italic", subtitle)
    }
    if show-byline and (authors.len() > 0 or date != none) {
      v(0.65em)
      let byline = (if authors.len() > 0 { authors.join(", ") }, if date != none { date.display() })
      text(size: 0.86em, fill: rgb("#505050"), byline.filter(item => item != none).join(" · "))
    }
  }))
  body
}
