// Unofficial NTNU thesis template for Typst.

#let chapter-word(n) = (
  "ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE",
  "SIX", "SEVEN", "EIGHT", "NINE", "TEN",
).at(n, default: str(n))

#let section-figure-number(n) = context {
  let h = counter(heading).get()
  if h.len() >= 2 {
    numbering("1.1.1", h.at(0), h.at(1), n)
  } else if h.len() >= 1 {
    numbering("1.1", h.at(0), n)
  } else {
    numbering("1", n)
  }
}

#let chapter-equation-number(n) = context {
  let h = counter(heading).get()
  if h.len() >= 1 {
    numbering("(1.1)", h.at(0), n)
  } else {
    numbering("(1)", n)
  }
}

#let dotfill() = box(width: 1fr, repeat([. ], gap: 0.33em))

#let running-chapter-header(short-title: none) = context {
  let page-number = counter(page).get().first()
  let page-label = counter(page).display("1")
  let headings = query(heading.where(level: 1))
  let current-page = here().page()
  let on-chapter-page = headings.any(it => it.location().page() == current-page)

  if on-chapter-page {
    none
  } else {
    let before = query(heading.where(level: 1).before(here()))
    if before.len() == 0 {
      none
    } else {
      let current = before.last()
      let title = if short-title == none { current.body } else { short-title }
      let number = counter(heading).at(current.location()).first()
      let mark = text(size: 10pt, [CHAPTER #number. #upper(title)])
      if calc.odd(page-number) {
        grid(columns: (1fr, 1fr), mark, align(right, text(size: 10pt, page-label)))
      } else {
        grid(columns: (1fr, 1fr), text(size: 10pt, page-label), align(right, mark))
      }
    }
  }
}

#let chapter-heading(it) = {
  if it.numbering != none {
    pagebreak(to: "odd")
    place(bottom + center, text(size: 10pt, counter(page).display("1")))
    v(2.15cm)
    context {
      let n = counter(heading).at(it.location()).first()
      line(length: 100%, stroke: 0.8pt)
      align(right, text(size: 12pt, weight: "regular", [CHAPTER]))
      v(-0.18cm)
      align(right, text(size: 16.5pt, weight: "regular", chapter-word(n)))
      v(-0.09cm)
      line(length: 100%, stroke: 0.8pt)
      v(0.44cm)
      align(right, text(size: 17pt, weight: "regular", upper(it.body)))
      v(0.68cm)
    }
  } else {
    block(below: 1.2em, it.body)
  }
}

#let ntnu-thesis(
  title: [NTNU thesis],
  author: "Author",
  body-font: "New Computer Modern",
  mono-font: "DejaVu Sans Mono",
  paper: "a4",
  body,
) = {
  set document(title: title, author: author)
  set page(
    paper: paper,
    margin: (left: 1.5in, right: 1in, top: 1in, bottom: 1in),
  )
  set text(font: body-font, size: 12pt, lang: "en")
  set par(justify: true, leading: 0.55em, first-line-indent: 0pt)
  set list(indent: 1.2em, body-indent: 0.4em)
  set table(inset: (x: 0.6em, y: 0.55em), stroke: none)
  set heading(numbering: "1.1.1.1")
  set math.equation(numbering: chapter-equation-number)
  set figure(numbering: section-figure-number)

  show raw: set text(font: mono-font, size: 10pt)
  show link: set text(fill: rgb("#1b4f72"))
  show heading.where(level: 1): chapter-heading
  show heading.where(level: 2): it => block(
    above: 1.15em,
    below: 0.45em,
    text(size: 14pt, weight: "bold", it),
  )
  show heading.where(level: 3): it => block(
    above: 0.85em,
    below: 0.35em,
    text(size: 12.5pt, weight: "bold", it),
  )
  show heading.where(level: 4): it => block(
    above: 0.75em,
    below: 0.3em,
    text(size: 12pt, weight: "bold", it),
  )
  show figure.caption: set text(weight: "bold", size: 10pt)
  show figure: set block(above: 1.0em, below: 1.0em)

  body
}

#let title-page(
  author: "Your Name",
  title: "The title of your master's thesis should be written here",
  subtitle: "Any undertitle is written here",
  programme: "Master's thesis in Physics and Mathematics",
  supervisor: "Supervisor Name",
  co-supervisor: "Co-supervisor Name",
  date: "June 2026",
  university: "Norwegian University of Science and Technology",
  faculty: "Faculty of Natural Sciences",
  department: "Department of Physics",
  logo: none,
) = {
  set page(
    paper: "a4",
    margin: (left: 1.6in, right: 2in, top: 1in, bottom: 1in),
    numbering: none,
    header: none,
    footer: none,
  )
  v(1.5cm)
  text(fill: gray, size: 14pt, author)
  v(1cm)
  text(weight: "bold", size: 17pt, title)
  v(0.5cm)
  text(size: 14pt, subtitle)
  v(7cm)
  programme
  linebreak()
  [Supervisor: #supervisor]
  linebreak()
  [Co-supervisor: #co-supervisor]
  linebreak()
  date
  v(0.2cm)
  university
  linebreak()
  faculty
  linebreak()
  department
  v(0.55cm)
  if logo == none {
    text(size: 24pt, weight: "bold", [NTNU])
  } else {
    logo
  }
  pagebreak()
  pagebreak()
}

#let front-matter(body) = {
  set page(
    paper: "a4",
    margin: (left: 1.5in, right: 1in, top: 1in, bottom: 1in),
    numbering: "i",
    header: none,
    footer: context align(center, text(size: 10pt, counter(page).display("i"))),
  )
  set heading(numbering: none)
  counter(page).update(1)
  body
}

#let front-chapter(title, body) = {
  context place(bottom + center, text(size: 10pt, counter(page).display("i")))
  v(2.35cm)
  align(right, text(size: 18pt, weight: "regular", upper(title)))
  v(1.65cm)
  body
}

#let outline-page(title, target: heading, depth: 3) = {
  v(2.45cm)
  align(right, text(size: 18pt, weight: "regular", upper(title)))
  v(1.9cm)
  set outline(indent: auto, depth: depth)
  show outline.entry.where(level: 1): set text(weight: "bold")
  outline(title: none, target: target)
}

#let contents() = {
  outline-page("Contents", depth: 3)
  pagebreak()
  outline-page("List of Figures", target: figure.where(kind: image), depth: 1)
  pagebreak()
  outline-page("List of Tables", target: figure.where(kind: table), depth: 1)
  pagebreak()
}

#let main-matter(short-title: none, body) = {
  pagebreak()
  set page(
    paper: "a4",
    margin: (left: 1.5in, right: 1in, top: 1in, bottom: 1in),
    numbering: "1",
    header: running-chapter-header(short-title: short-title),
    footer: none,
  )
  set heading(numbering: "1.1.1.1")
  counter(page).update(1)
  counter(heading).update(0)
  body
}

#let references(body) = {
  pagebreak(to: "odd")
  body
}

#let appendices(body) = {
  set page(
    paper: "a4",
    margin: (left: 1.5in, right: 1in, top: 1in, bottom: 1in),
    numbering: "1",
    header: none,
    footer: context align(center, text(size: 10pt, counter(page).display("1"))),
  )
  pagebreak(to: "odd")
  heading(numbering: none, outlined: true, text(size: 17pt, weight: "regular", [Appendices]))
  set heading(numbering: none)
  counter(figure).update(0)
  body
}
