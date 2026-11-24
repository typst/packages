#let section-page(title, body) = {
  pagebreak(weak: true)
  heading(level: 1, numbering: none, outlined: true, title)
  body
}

#let chapter-number(..numbers) = {
  if numbers.pos().len() == 1 {
    "Chapter " + numbering("1", ..numbers.pos())
  } else {
    numbering("1.1", ..numbers.pos())
  }
}

#let appendix-number(..numbers) = {
  if numbers.pos().len() == 1 {
    "Appendix " + numbering("A", ..numbers.pos())
  } else {
    numbering("A.1", ..numbers.pos())
  }
}

#let appendix-mode = state("appendices", false)

// Resolve the source location, since outlines/references render elsewhere.
#let item-number(target, n) = context {
  let item = query(target).filter(it => it.numbering != none).at(n - 1)
  let chapters = query(heading.where(level: 1).before(item.location()))
    .filter(it => it.numbering != none)
  if chapters.len() == 0 { return str(n) }
  let chapter = chapters.last()
  let ch = counter(heading).at(chapter.location()).first()
  let prior = counter(target).at(chapter.location()).first()
  let prefix = if appendix-mode.at(item.location()) { "A" } else { "1" }
  numbering(prefix + ".1", ch, n - prior)
}

#let number-figures(kinds, body) = {
  if kinds.len() == 0 { return body }
  let target = figure.where(kind: kinds.first())
  show target: set figure(numbering: item-number.with(target))
  number-figures(kinds.slice(1), body)
}

// Place once, after the final bibliography. Page numbering continues.
#let appendices(body) = {
  pagebreak(weak: true)
  appendix-mode.update(true)
  counter(heading).update(0)
  set heading(numbering: appendix-number, supplement: none)
  body
}

#let thesis(
  title: none,
  author: none,
  degree: none,
  department: none,
  year: none,
  specialization: none,
  abstract: none,
  preface: none,
  abstract-translation: none,
  dedication: none,
  acknowledgements: none,
  symbols: none,
  abbreviations: none,
  glossary: none,
  extra-lists: (),
  preliminary: (),
  title-page: none,
  font: "Libertinus Serif",
  font-size: 12pt,
  line-spacing: 2,
  toc-depth: 3,
  lang: "en",
  body,
) = {
  for (key, value) in (title: title, author: author, degree: degree, department: department) {
    assert(type(value) == str and value.trim() != "", message: key + " must be a nonempty string")
  }
  assert(type(year) == int and year >= 1000 and year <= 9999, message: "year must be the four-digit submission year")
  assert(abstract != none and abstract != [], message: "Supply your abstract (at most 700 words)")
  assert(preface != none and preface != [], message: "Supply your preface, including applicable disclosures")
  assert(lang == "en" or abstract-translation != none, message: "Non-English theses need both English and thesis-language abstracts")
  assert(font-size >= 10pt, message: "Use at least 10 pt; choose a font/size equivalent to Times New Roman 12 pt or Arial 10 pt")
  assert(line-spacing >= 1.5, message: "GPS requires at least 1.5 spacing in the body")
  assert(type(toc-depth) == int and toc-depth >= 3 and toc-depth <= 5, message: "toc-depth must be 3 to 5 (chapters plus 2 to 4 subheading levels)")

  set document(title: title, author: author)
  // Explicit edges make the normal text baseline distance line-spacing × font-size.
  set text(font: font, size: font-size, lang: lang, top-edge: 0.8em, bottom-edge: -0.2em)
  set par(justify: true, leading: (line-spacing - 1) * 1em, spacing: 1em)
  set page("us-letter", margin: 1in, numbering: "i", number-align: center + bottom, footer-descent: 0pt)
  set heading(numbering: chapter-number, supplement: none)
  show heading: set text(font: font, size: font-size, weight: "bold")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    if it.numbering != none {
      counter(footnote).update(0)
    }
    block(above: 0pt, below: 1.5em, it)
  }
  show: number-figures.with((image, table, "plate", raw) + extra-lists.map(pair => pair.first()))
  show figure.caption: set par(justify: false)
  show figure.where(kind: table): set figure.caption(position: top)
  set math.equation(numbering: n => [(#item-number(math.equation.where(block: true), n))])
  show footnote.entry: set par(leading: 0.2em, justify: false)
  show quote.where(block: true): set par(leading: 0.2em)
  show raw.where(block: true): set par(justify: false)
  show bibliography: set par(justify: false)
  show outline: set par(leading: 0.5em, justify: false)

  // The title page is counted as i, with its printed number suppressed.
  if title-page == none {
    page(numbering: none)[
      #set align(center)
      #set par(justify: false, leading: 0.5em)
      #v(0.3in)
      #strong(title)
      #v(0.2in)
      by
      #v(0.2in)
      #author
      #v(1fr)
      A thesis submitted in partial fulfillment of the requirements for the degree of
      #v(0.2in)
      #degree
      #if specialization != none and specialization != "" [
        #v(0.2in)
        in
        #v(0.2in)
        #specialization
      ]
      #v(1fr)
      #department \
      University of Alberta
      #v(1fr)
      © #author, #year
      #v(0.3in)
    ]
  } else {
    // E.g. a full-page SVG of GPS's completed official title-page form.
    page(numbering: none, margin: 0pt, title-page)
  }
  counter(page).update(2)

  // Abstract always double spaced, even when the body uses 1.5 spacing.
  {
    set text(lang: "en")
    set par(leading: 1em)
    section-page([Abstract], abstract)
    if abstract-translation != none {
      set text(lang: abstract-translation.lang)
      section-page(abstract-translation.title, abstract-translation.body)
    }
  }
  section-page([Preface], preface)
  if dedication != none { section-page([Dedication], dedication) }
  if acknowledgements != none { section-page([Acknowledgements], acknowledgements) }
  section-page([Table of Contents], outline(title: none, depth: toc-depth))
  context {
    for (kind, name) in ((table, [List of Tables]), (image, [List of Figures]), ("plate", [List of Plates])) + extra-lists {
      let target = figure.where(kind: kind, outlined: true)
      if query(target).len() > 0 {
        section-page(name, outline(title: none, target: target))
      }
    }
  }
  if symbols != none { section-page([List of Symbols], symbols) }
  if abbreviations != none { section-page([List of Abbreviations], abbreviations) }
  if glossary != none { section-page([Glossary], glossary) }
  for section in preliminary { section-page(section.title, section.body) }

  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  counter(heading).update(0)
  body
}
