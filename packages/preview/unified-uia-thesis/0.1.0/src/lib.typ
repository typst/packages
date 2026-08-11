#import "translations.typ": *
#import "glossary.typ": *

#let report(
  meta: none,
  frontmatter: none, // ex. "preface.typ", "abstract.typ"
  references: none, // "references.yml"
  appendices: none, // "appendices.typ"
  contents: true,
  listings: true,
  body,
) = {
  assert(
    meta.format.type in ("bachelor", "master"),
    message: "type must be either bachelor or master",
  )
  let format-type = lower(meta.format.type)

  set document(title: meta.frontpage.title, author: meta.authors.students)

  // languages
  let lang = if meta.format.lang in ("no", "nb", "nn") { "no" } else { "en" }
  let t = translations.at(lang)
  set text(
    lang: meta.format.lang,
    font: "New Computer Modern", // overleaf font
  )

  let format-authors(authors) = {
    if type(authors) == str { authors = (authors,) }
    if authors.len() == 1 { authors.first() } else if authors.len() == 2 {
      (authors.first(), t.at("and"), authors.at(1)).join(" ")
    } else {
      let first-authors = authors.slice(0, -1)
      (first-authors.join(", "), t.at("and"), authors.last()).join(" ")
    }
  }

  // front page
  {
    let background-image = "/img/" + format-type + "_" + lang + ".svg"
    set page(margin: (right: 6.5cm), background: image(background-image))

    v(5cm)
    text(20pt, weight: "bold", smallcaps(meta.frontpage.title))

    v(0.5cm)
    text(12pt, meta.frontpage.subtitle)

    v(1.5cm)
    text(14pt, upper(format-authors(meta.authors.students)))

    v(1fr)

    text(16pt, upper(t.supervisor))
    linebreak()
    meta.authors.supervisor

    v(2cm)

    text(12pt)[*#t.university, #meta.institution.date*]
    linebreak()
    set text(size: 10pt)
    meta.institution.faculty
    linebreak()
    meta.institution.department
  }

  // heading styling
  let heading-size = 24pt
  show heading.where(depth: 1): set text(heading-size)
  show heading: set block(above: 32pt, below: 16pt)

  set par(justify: true) // blocky paragraphs

  // figures
  show figure: set block(breakable: false)
  show figure.where(kind: image): set figure(supplement: t.figure)
  show figure.where(kind: raw): set figure(supplement: t.listing)
  show figure.where(kind: table): set figure(supplement: t.table)

  // a very slight highlight for code blocks, since the default is awful
  show raw: set block(
    fill: luma(250),
    stroke: 0.5pt + luma(200),
    radius: 2pt,
    inset: 8pt,
  )

  // roman numeral page numbering before the main content
  counter(page).update(1)
  set page(numbering: "i", number-align: center)

  // whatever goes between the front page and outline
  if frontmatter != none {
    frontmatter
    pagebreak()
  }

  // outline
  if contents {
    // make top level ones bold
    show outline.entry.where(level: 1): it => {
      v(0.5em)
      link(
        it.element.location(),
        strong(it.indented(it.prefix(), [#it.body() #h(1fr) #it.page()])),
      )
    }

    show outline.entry: it => {
      if it.element.supplement != [#t.appendix] {
        it
      }
    }

    outline(title: t.contents)

    show outline.entry: it => if it.element.supplement == [#t.appendix] {
      link(
        it.element.location(),
        it.indented([#h(1.2em) #it.prefix()], it.inner()),
      )
    }

    outline(title: none)
    pagebreak()
  }

  // Lists of figures, tables and listings. Each list will be hidden if there are no matching elements
  if listings {
    show outline.entry: it => {
      let prefix = it.prefix().fields().at("children").last()
      link(it.element.location(), it.indented([#h(1.2em) #prefix], it.inner()))
    }

    context {
      let has-any-listings = false
      let has-type(type) = query(figure.where(kind: type)).len() > 0

      if has-type(image) {
        heading(t.list_of_figures)
        outline(title: none, target: figure.where(kind: image))
        has-any-listings = true
      }

      if has-type(table) {
        heading(t.list_of_tables)
        outline(title: none, target: figure.where(kind: table))
        has-any-listings = true
      }

      if has-type(raw) {
        heading(t.list_of_listings)
        outline(title: none, target: figure.where(kind: raw))
        has-any-listings = true
      }

      if has-any-listings {
        pagebreak()
      }
    }
  }

  // glossary only renders if there are any definitions
  context if GLOSSARY.final() != (:) {
    render-glossary(GLOSSARY.final(), t)
    pagebreak()
  }

  // main content
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1.1", outlined: true, supplement: it => if it.depth == 1 { t.chapter } else { t.section })

    show heading.where(depth: 1): it => block(above: 50pt, below: 40pt)[
      #let chapter = [#it.supplement #counter(heading).at(it.location()).at(0)]
      #text(22pt, chapter)
      #v(0pt)
      #text(heading-size, it.body)
    ]

    // enable numbering for labelled equations
    set math.equation(numbering: "(1.1)")
    show: body => {
      if "children" in body.fields().keys() {
        for elem in body.children {
          if elem.func() == math.equation and elem.block {
            let numbering = if "label" in elem.fields().keys() { "(1)" } else { none }
            set math.equation(numbering: numbering)
            elem
          } else {
            elem
          }
        }
      }
    }

    body // hello C:
  }

  if references != none {
    pagebreak()
    set par(justify: false)
    show heading.where(depth: 1): it => block(above: 50pt, below: 40pt, text(heading-size, it.body))
    set bibliography(title: t.references)
    references
  }

  if appendices != none {
    pagebreak()
    counter(heading).update(0)
    heading(level: 1, numbering: none)[#t.appendices]
    set heading(numbering: "A.1", supplement: t.appendix)
    appendices
  }
}

#let append-typ(path, numbering: none) = context {
  let saved-count = counter(heading).get()
  {
    // reset headers
    counter(heading).update(0)
    set heading(numbering: numbering, supplement: none, outlined: false)
    path
  }
  counter(heading).update(saved-count)
}
