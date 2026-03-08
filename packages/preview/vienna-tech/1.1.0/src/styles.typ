#import "utils.typ": *

/// Thesis Template for Civil- und Environmentalengineers at TU Wien.
/// This function gets your whole document as its `body` and formats
/// it according to the TU Wien guidelines for theses.
#let tuw-thesis(
  /// The numbering of the headings
  /// -> string | content | func
  heading-numbering: "1.1",
  /// The numbering style of equations
  /// -> string | func
  eq-numbering: "(1.1)",
  /// Restart the equation counter after every level 1 chapter
  /// -> bool
  eq-chapterwise: false,
  /// The Titel or Text which should be displayed in the header.
  /// -> string | content
  header-title: none,
  /// The starting page of the header.
  /// -> integer
  header-start: 1,
  /// The style of the header (emph, strong, smallcaps, ...)
  /// -> element
  header-style: emph,
  /// The thesis papersize. Affects margins.
  /// -> string
  papersize: "a4",
  /// The language of the document.
  /// -> string
  lang: "de",
  /// The standard fontsize. All other fontsizes are in calculated from this value.
  /// -> length
  font-size: 11pt,
  /// The font of the whole document.
  /// -> string | array
  main-font: "New Computer Modern",
  /// The font of the headings (of Sans Type)
  /// -> string | array
  title-font: ("New Computer Modern Sans", "PT Sans", "DejaVu Sans"),
  /// The font of the raw text or codeblocks.
  /// -> string | array
  raw-font: "DejaVu Sans Mono",
  /// The margins of the paper
  /// -> dictionary | lenght
  paper-margins: (left: 2.5cm, right: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  fig-caption-width: 80%,
  ///
  title-hypenation: auto,
  // The document's body
  body,
) = {
  // Configure the page
  set page(
    paper: papersize,
    margin: paper-margins,
    header-ascent: 14pt,
    header: header-func(
      header-title,
      start: header-start,
      style: header-style,
      size: small-size,
    ),
  )

  // Set text properties
  set text(lang: lang, size: font-size, font: main-font)
  // Set footnote properties
  show footnote.entry: set text(footnote-size)


  // Configure headings
  set heading(numbering: heading-numbering)
  show heading: it => {
    set text(font: title-font)
    block(it) + v(0.2em)
  }

  // Configure lists and links
  set list(indent: 24pt, body-indent: 5pt)
  set enum(indent: 24pt, body-indent: 5pt)

  // show link: set text(font: raw-font, size: small-size)

  // Configure equations
  let chapterwise-numbering = (..num) => numbering(
    eq-numbering,
    counter(heading).get().first(),
    num.pos().first(),
  )
  let reset-eq-counter = it => {
    counter(math.equation).update(0)
    it
  }
  show heading.where(level: 1): if eq-chapterwise { reset-eq-counter } else {
    it => it
  }
  show math.equation: set block(below: 8pt, above: 9pt)
  show math.equation: set text(weight: 400)
  set math.equation(numbering: eq-numbering) if not eq-chapterwise
  set math.equation(numbering: chapterwise-numbering) if eq-chapterwise


  // Referencing Figures
  show figure.where(kind: table): set figure(
    supplement: [Tab.],
    numbering: "1",
  ) if lang == "de"
  show figure.where(kind: image): set figure(
    supplement: [Abb.],
    numbering: "1",
  ) if lang == "de"
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.caption: it => {
    set par(justify: true)
    let prefix = {
      it.supplement + " " + context it.counter.display(it.numbering) + ": "
    }
    let cap = {
      strong(prefix)
      it.body
    }
    block(width: fig-caption-width, cap)
  }
  show figure: pad.with(y: 1.5em)

  // Configure paragraph properties.
  set par(
    first-line-indent: 1.8em,
    justify: true,
    leading: 0.55em,
    spacing: 0.65em,
  ) //above: 1.4em, below: 1em,

  // Configure raw text
  show raw: set text(font: raw-font, size: small-size)

  // Set Table style
  set table(stroke: none, gutter: auto, fill: none, inset: (right: 1.5em))


  // Table of Contents Style
  show outline.entry.where(level: 1): {
    it => link(it.element.location(), it.indented(
      strong(it.prefix()),
      strong((it.body()) + h(1fr) + it.page()),
      gap: 0.5em,
    ))
  }

  // Outline styling for image figures
  show outline.where(target: figure.where(kind: image)): it => {
    show outline.entry.where(level: 1): {
      it => link(it.element.location(), it.indented(strong(it.prefix()), text(
        font: main-font,
        it.inner(),
      )))
    }
    it
  }

  // Outline styling for table figures
  show outline.where(target: figure.where(kind: table)): it => {
    show outline.entry.where(level: 1): {
      it => link(it.element.location(), it.indented(strong(it.prefix()), text(
        font: main-font,
        it.inner(),
      )))
    }
    it
  }

  show outline.entry.where(level: 1): set text(font: title-font)
  show outline: it => {
    outlined.update(true)
    it
    outlined.update(false)
  }

  body
}

/// Function to format the Appendix
/// -> content
#let appendix(
  /// The numbering of the Appendix
  /// -> none | str | function
  numbering: "A.1",
  /// The title of the Appendix
  /// -> none | str | content
  title: none,
  /// The alignment of the title
  /// -> alignment
  title-align: center,
  /// The size of the title
  /// -> length
  title-size: none,
  /// Wheter the title should be outlined
  /// -> bool
  title-ouline: false,
  /// Starting the appendix after this number
  /// -> int
  numbering-start: 0,
  /// Exclude these heading levels from beeing outlined.
  /// -> array
  outline-exclude: (2, 3),
  content,
) = {
  context counter(heading).update(numbering-start)
  set heading(numbering: numbering)


  show heading.where(level: 2): set heading(outlined: false) if (
    2 in outline-exclude
  )
  show heading.where(level: 3): set heading(outlined: false) if (
    3 in outline-exclude
  )

  // Optional Title
  if title != none {
    show heading.where(level: 1, numbering: none): it => {
      if title-size != none {
        set text(size: title-size)
        it
      } else {
        it
      }
    }
    let title-text = heading(
      numbering: none,
      level: 1,
      outlined: title-ouline,
      title,
    )
    align(title-align, title-text)
  }

  content
}
