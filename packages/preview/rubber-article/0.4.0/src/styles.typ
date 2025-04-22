// This file contains functions that will set the styles for the documents.

#import "dependencies.typ": *

/// A Template recreating the look of the classic Article Class.
///
/// Example usage:
/// ```typ
/// #show: article.with(
///   lang: "de",
/// )
/// ```
/// This will format the document with the specified options.
/// For more styling options, explore the following parameters.
///
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
  header-display: false,
  /// Set if the default header should be alternating.
  /// -> bool
  alternating-header: true,
  /// Set the first page of the header.
  /// -> int | float
  first-page-header: 1,
  /// Set the Header Titel
  /// -> str | content
  header-title: none,
  /// Set if document should be justified.
  /// -> bool
  justify: true,
  /// Set the width of the figure captions.
  /// -> relative
  fig-caption-width: 75%,
  /// Set the width of the headerline.
  /// -> length
  header-line-stroke: .65pt,
  ///-> content
  content,
) = {
  import "utils.typ": reset-eq-counter, header-content, header-oddPage, header-evenPage
  // Set the document's basic properties.

  set page(
    margin: margins,
    numbering: page-numbering,
    number-align: page-numbering-align,
  )
  set text(font: "New Computer Modern", lang: lang, size: text-size)
  set par(leading: 0.55em, spacing: 0.55em, first-line-indent: 1.8em, justify: true)
  show heading: set block(above: 1.4em, below: 1em)
  show math.equation: set block(above: 2em, below: 2em)
  show figure: set block(above: 2em, below: 2em)

  // Set the equation numbering style.

  let chapterwise-numbering = (..num) => numbering(eq-numbering, counter(heading).get().first(), num.pos().first())
  show heading.where(level: 1): if eq-chapterwise {reset-eq-counter} else {it => it}

  set math.equation(numbering: eq-numbering) if not eq-chapterwise
  set math.equation(numbering: chapterwise-numbering) if eq-chapterwise

  set heading(numbering: heading-numbering)
  set enum(indent: enum-indent)
  set list(indent: list-indent)
  show outline.entry.where(level: 1): {
    it => link(
      it.element.location(),
      it.indented(
        strong(it.prefix()),
        strong((it.body()) + h(1fr) + it.page()),
        gap: 0.5em,
      ),
    )
  }

  // Figure styles

  show figure.where(kind: table): set figure(supplement: [Tab.], numbering: "1") if lang == "de"
  show figure.where(kind: image): set figure(supplement: [Abb.], numbering: "1", ) if lang == "de"
  show figure.where(kind: table): set figure.caption(position: top)

  // Set Table style

  set table(
    stroke: none,
    gutter: auto,
    fill: none,
  )
  // Emphasize the figure caption numbering

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

  let header-oddPage = header-oddPage(header-line-stroke, header-title)
  let header-evenPage = header-evenPage(header-line-stroke, header-title)
  let header-content = header-content(
    first-page-header,
    alternating-header,
    oddPage: header-oddPage,
    evenPage: header-evenPage,
  )
  set page(header: header-content) if header-display

  // Main body.

  content
}

/// Function to format the Appendix. This function is intended to be used after the document has been styled with the `article` function.
///
/// Example usage:
/// ```typ
/// #show: article.with()
/// // A lot of content goes here...
///
/// #show: appendix.with(
///   title: "Appendix",
///   title-align: center,
/// )
/// ```
///
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
  /// Startting the appendex after this number
  /// -> int
  numbering-start: 0,
  content,
) = {
  context counter(heading).update(numbering-start)
  set heading(numbering: numbering)

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
    let title-text = heading(numbering: none, level: 1, title)
    align(title-align, title-text)
  }
  content
}
