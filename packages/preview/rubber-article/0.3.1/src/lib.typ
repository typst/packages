#import "@preview/hydra:0.6.0": hydra

// Workaround for the lack of `std` scope
#let std-bibliography = bibliography


/// A Template recreating the look of the classic Article Class.
/// -> content
#let article(
  /// Set the language of the document.
  /// -> str
  lang: "de",
  /// Set the equation numbering style.
  /// -> str | none
  eq-numbering: none,
  /// Chapterwise numbering of equations.
  /// -> bool
  eq-chapterwise: false,
  /// Set the text size.
  /// Headings are adjusted automatically.
  /// -> length
  text-size: 10pt,
  /// Set the page numbering style.
  /// -> none | str | function
  page-numbering: "1",
  /// Set the page numbering alignment.
  /// -> alignment
  page-numbering-align: center,
  /// Set the heading numbering style.
  /// -> none | str | function
  heading-numbering: "1.1",
  /// Set the margins of the document.
  /// -> auto | relative | dictionary
  margins: (left: 25mm, right: 25mm, top: 30mm, bottom: 30mm),
  /// Set the Enum indentation.
  /// -> length
  enum-indent: 1.5em,
  /// Set the List indentation.
  /// -> length
  list-indent: 1.5em,
  /// Set if the default header should be used.
  /// -> bool
  show-header: false,
  /// Set if the default header should be alternating.
  /// -> bool
  alternating-header: true,
  /// Set the first page of the header.
  /// -> int | float
  first-page-header: 1,
  /// Set the Header Titel
  /// -> str | content
  header-titel: none,
  /// Set if document should be justified.
  /// -> bool
  justify: true,
  /// Add an appendix to the document.
  /// -> content
  appendix: none,
  /// Set the appendix numbering style.
  /// -> none | str | function
  appendix-numbering: "A.1",
  /// Add a bibliography to the document.
  /// -> content
  bibliography: none,
  /// Set the title of the bibliography.
  /// -> str | content
  bib-titel: "Bibliography",
  /// Set the width of the figure captions.
  /// -> relative
  fig-caption-width: 75%,
  ///-> content
  content,
) = {
  // Set the document's basic properties.
  set page(
    margin: margins,
    numbering: page-numbering,
    number-align: page-numbering-align,
  )
  set text(font: "New Computer Modern", lang: lang, size: text-size)

  // Set the equation numbering style.

  let chapterwise-numbering = (..num) => numbering(eq-numbering, counter(heading).get().first(), num.pos().first())

  let reset-eq-counter = it => {
    counter(math.equation).update(0)
    it
  }
  show heading.where(level: 1): if eq-chapterwise {reset-eq-counter} else {it => it}

  set math.equation(numbering: eq-numbering) if not eq-chapterwise
  set math.equation(numbering: chapterwise-numbering) if eq-chapterwise

  set heading(numbering: heading-numbering)
  set enum(indent: enum-indent)
  set list(indent: list-indent)
  show outline.entry.where(level:1): {
    it => link(
      it.element.location(),
      it.indented(strong(it.prefix()), strong((it.body()) + h(1fr) + it.page()), 
      gap:0.5em),
    )
  }

  set std-bibliography(style: "ieee", title: bib-titel)

  // Referencing Figures

  show figure.where(kind: table): set figure(supplement: [Tab.], numbering: "1") if lang == "de"
  show figure.where(kind: image): set figure(supplement: [Abb.], numbering: "1", ) if lang == "de"

  show figure.where(kind: table): set figure.caption(position: top)

  // Set Table style

  set table(
    stroke: none,
    gutter: auto,
    fill: none,
    inset: (right: 1.5em),
  )


  show figure.caption: it => {
    set par(justify: true)
    let prefix = {
      it.supplement + " " + context it.counter.display(it.numbering)+ ": "
    }
    let cap = {
      strong(prefix)
      it.body
    }
    block(width: fig-caption-width, cap)
  }

  // Configure the header.

  let header-oddPage = context {
    set text(10pt)
    set grid.hline(stroke: 0.9pt)
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      inset:4pt,
      smallcaps(header-titel),
      smallcaps(hydra(1)),
      grid.hline(),
    )
  }

  let header-evenPage = context {
    set text(10pt)
    set grid.hline(stroke: 0.9pt)
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      inset:4pt,
      smallcaps(hydra(1)),
      smallcaps(header-titel),
      grid.hline(),
    )
  }

  let header-content = context {
    let current = counter(page).get().first()

    if current > first-page-header and calc.rem(current,2) == 0{
      return header-evenPage
    } else if current > first-page-header {
      if alternating-header {
        return header-oddPage
      } else {
        return header-evenPage
      }
    }
  }

  set page(header: header-content) if show-header

  // Main body.

  set par(justify: justify)

  content

  if bibliography != none {
    pagebreak(weak: true)
    bibliography
  }

  if appendix != none {
    context counter(heading).update(0)
    set heading(numbering: appendix-numbering)
    appendix
  }
}

/// Make the title of the document.
/// -> content
#let maketitle(
  /// The title of the document.
  /// -> string | content
  title: "",
  /// The authors of the document.
  /// -> array
  authors: (),
  /// The date of the document.
  /// -> string | content | datetime
  date: none,
  /// Use titel and author information for
  /// the document metadata.
  /// -> bool
  metadata: true,
) = {
  if metadata {
    set document(author: authors, title: title)
  }
  // Author information.

  let authors-text = {
    set text(size: 1.1em)
    pad(
      top: 0.5em,
      bottom: 0.5em,
      x: 2em,
      grid(
        columns: (1fr,) * calc.min(3, authors.len()),
        gutter: 1em,
        ..authors.map(author => align(center, author)),
      ),
    )}
    // Frontmatter

    align(center)[
      #v(60pt)
      #block(text(weight: 400, 18pt, title))
      #v(1em, weak: true)
      #authors-text
      #v(1em, weak: true)
      #block(text(weight: 400, 1.1em, date))
      #v(20pt)
    ]
  }

/// Function to format the Appendix
/// -> content
#let appendix(
  /// The numbering of the Appendix
  /// -> none | str | function
  numbering:"A.1",
  /// The title of the Appendix
  /// -> none | str | content
  title: none,
  /// The alignment of the title
  /// -> alignment
  title-align: center,
  /// The size of the title
  /// -> length
  title-size: none,
  /// Startting the appendex after this number
  /// -> int
  numbering-start:0,
  content
) = {
  context counter(heading).update(numbering-start)
  set heading(numbering: numbering)

  // Optional Title
  if title != none {
    show heading.where(level:1, numbering:none): it => {
      if title-size != none {
        set text(size: title-size)
        it
      } else {
        it
      }
    }
    let title-text = heading(numbering: none, level: 1, title)
    align(title-align, title-text)
  }
  content
}