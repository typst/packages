// Milanovic Resume for Typst: one page, one column, ATS-friendly.
// Author: Dr. Milan Milanovic (https://github.com/milanm/Milanovic-Resume)
// License: MIT (code), SIL OFL 1.1 (bundled Source Sans 3 fonts)
//
// Compile: typst compile --font-path ../fonts resume.typ

#let _accent = state("accent", rgb("#003366"))

// Thin rule, full width.
#let _rule(weight) = line(length: 100%, stroke: weight + black)

// Separator for inline lists: Belgrade · email · phone
#let sep = h(0.45em) + sym.dot.c + h(0.45em)

// Main template. Use with: #show: resume.with(name: "...", ...)
#let resume(
  name: "",
  contact: (),          // array of strings or links, joined with " · "
  headline: none,       // target role, e.g. "Senior Backend Engineer"
  tagline: none,        // one line with your strongest result
  keywords: (),         // written to the PDF metadata
  accent: rgb("#003366"),
  paper: "a4",          // "a4" or "us-letter"
  font-size: 11pt,
  font: "Source Sans 3",
  ligatures: false,     // off by default, so "fi" and "fl" stay plain text for parsers
  body,
) = {
  set document(title: name + " - Resume", author: name, keywords: keywords)
  set page(
    paper: paper,
    margin: (top: 1.4cm, bottom: 1.3cm, left: 1.75cm, right: 1.5cm),
  )
  set text(font: font, size: font-size, lang: "en", ligatures: ligatures, hyphenate: false)
  set par(leading: 0.56em, spacing: 0.6em, justify: false)
  set list(marker: [•], indent: 0.35em, body-indent: 0.55em, spacing: 0.62em)
  show link: set text(fill: black)
  _accent.update(accent)

  // Section headings: centred, upper case, accent colour, rule above and below.
  show heading.where(level: 1): it => block(above: 13pt, below: 7pt, width: 100%, breakable: false, stack(
    spacing: 4pt,
    _rule(0.4pt),
    align(center, text(size: 1.12 * font-size, weight: "bold", fill: accent, upper(it.body))),
    _rule(0.8pt),
  ))

  // Header
  align(center, stack(
    spacing: 7pt,
    text(size: 2.25 * font-size, weight: "bold", fill: accent, name),
    text(size: 0.93 * font-size, contact.join(sep)),
  ))
  if headline != none {
    v(4pt)
    let lines = (text(size: 1.12 * font-size, weight: "bold", fill: accent, headline),)
    if tagline != none { lines.push(text(fill: accent, tagline)) }
    stack(
      spacing: 5pt,
      _rule(0.6pt),
      align(center, stack(spacing: 4.5pt, ..lines)),
      _rule(1.2pt),
    )
  }

  body
}

// Short paragraph under the header.
#let summary(body) = block(above: 7pt, below: 0pt, par(leading: 0.62em, body))

// Skills. Default: one paragraph of items separated by middle dots, so every parser
// reads them right after the SKILLS heading. `columns: true` gives the two-column
// bullet list instead; it looks closer to a classic resume, but pdfminer.six reads
// its left column before the heading.
#let skills(..items, columns: false) = {
  let all = items.pos()
  if columns {
    let half = calc.ceil(all.len() / 2)
    grid(
      columns: (1fr, 1fr),
      column-gutter: 1.6em,
      list(..all.slice(0, half)),
      list(..all.slice(half)),
    )
  } else {
    // Each skill is an unbreakable box; lines break only after a dot.
    let dot = [#h(0.2em)~#sym.dot.c#h(0.2em) ]
    block(above: 0pt, below: 0pt, par(leading: 0.62em, all.map(box).join(dot)))
  }
}

// One position. Bullets go in the body as a normal list.
#let job(company, title: none, location: none, dates: none, body) = {
  block(above: 10pt, below: 6.5pt, breakable: false)[
    #strong(company)#if title != none [#strong[ – #title]]#if location != none [, #location]
    #h(1fr)
    #if dates != none { emph(dates) }
  ]
  body
}

// One project: name, info (context or link), tech stack, then bullets.
#let project(name, info: none, stack: none, body) = {
  block(above: 9pt, below: 6.5pt, breakable: false)[
    #strong(name)#if info != none [ (#info)]
    #h(1fr)
    #if stack != none { text(size: 0.93em, emph(stack)) }
  ]
  body
}

// Education line: use inside a list.
#let education(degree, school: none, year: none) = [
  #strong(degree)#if school != none [ – #school]#if year != none [, #year]
]

// Plain line for certifications and languages: inline("A", "B", "C")
#let inline(..items) = block(above: 0pt, below: 0pt, items.pos().join(sep))

// Cover letter body in the same style. Use after #show: resume.with(...)
#let letter(recipient: [], date: none, signature: none, body) = context {
  let accent = _accent.get()
  v(12pt)
  grid(
    columns: (1fr, auto),
    recipient,
    if date != none { date } else { datetime.today().display("[day padding:none] [month repr:long] [year]") },
  )
  v(14pt)
  set par(leading: 0.62em, spacing: 1.1em)
  body
  if signature != none {
    v(1.4em)
    text(weight: "bold", fill: accent, signature)
  }
}
