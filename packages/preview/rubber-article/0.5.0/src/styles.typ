/*
 * Copyright (c) 2025 npikall
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the MIT License; see the LICENSE file for details.
 *
 * This file contains functions that will set the style for the document.
 */

#import "dependencies.typ": *
#import "utils.typ": *

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
  /// Set the number of columns, that the document should have.
  /// -> none | int
  cols: none,
  /// Chapterwise numbering of equations.
  /// -> bool
  eq-chapterwise: false,
  /// Set the equation numbering style.
  /// -> str | none
  eq-numbering: none,
  /// Set the width of the figure captions.
  /// -> relative
  fig-caption-width: 75%,
  /// Set if the default header should be alternating.
  /// -> bool
  header-alternating: true,
  /// Set if the default header should be used.
  /// -> bool
  header-display: false,
  /// Set the first page of the header.
  /// -> int | float
  header-first-page: 1,
  /// Set the width of the headerline.
  /// -> length
  header-line-stroke: .65pt,
  /// Set the Header Title
  /// -> str | content
  header-title: none,
  /// Set the heading numbering style.
  /// -> none | str | function
  heading-numbering: "1.1",
  /// Set the language of the document.
  /// -> str
  lang: "de",
  /// Set the List indentation.
  /// -> length
  list-bullet-indent: 1.5em,
  /// Set the Enum indentation.
  /// -> length
  list-numbered-indent: 1.5em,
  /// Set the margins of the document.
  /// -> auto | relative | dictionary
  page-margins: (left: 25mm, right: 25mm, top: 30mm, bottom: 30mm),
  /// Set the page numbering alignment.
  /// -> alignment
  page-numbering-align: center,
  /// Set the page numbering style.
  /// -> none | str | function
  page-numbering: "1",
  /// Set the paper size.
  /// -> str
  page-paper: "a4",
  /// Set the indentation of the first line of paragraphs.
  /// -> length
  par-first-line-indent: 1.8em,
  /// Set if document should be justified.
  /// -> bool
  par-justify: true,
  /// Set the spacing between paragraphs.
  /// -> length
  par-spacing: 0.55em,
  /// Set the text font.
  /// -> str
  text-font: "New Computer Modern",
  /// Set the text size.
  /// Headings are adjusted automatically.
  /// -> length
  text-size: 10pt,
  /// -> content
  content,
) = {
  // Set the document's basic properties.
  set page(
    margin: page-margins,
    numbering: page-numbering,
    number-align: page-numbering-align,
    paper: page-paper,
  )
  set text(font: text-font, lang: lang, size: text-size)
  set par(
    leading: 0.55em,
    spacing: par-spacing,
    first-line-indent: par-first-line-indent,
    justify: par-justify,
  )
  show heading: set block(above: 1.4em, below: 1em)
  show math.equation: set block(above: 2em, below: 2em)
  show figure: set block(above: 2em, below: 2em)

  // Set the equation numbering style.

  let chapterwise-numbering = (..num) => numbering(eq-numbering, counter(heading).get().first(), num
    .pos()
    .first())
  show heading.where(level: 1): if eq-chapterwise { reset-eq-counter } else {
    it => it
  }

  set math.equation(numbering: eq-numbering) if not eq-chapterwise
  set math.equation(numbering: chapterwise-numbering) if eq-chapterwise

  set heading(numbering: heading-numbering)
  set enum(indent: list-numbered-indent)
  set list(indent: list-bullet-indent)
  show outline.entry.where(level: 1): {
    it => link(it.element.location(), it.indented(
      strong(it.prefix()),
      strong((it.body()) + h(1fr) + it.page()),
      gap: 0.5em,
    ))
  }
  show outline: it => {
    outlined.update(true)
    it
    outlined.update(false)
  }

  // Outline styling for image figures

  show outline.where(target: figure.where(kind: image)): it => {
    show outline.entry.where(level: 1): {
      it => link(it.element.location(), it.indented(strong(it.prefix()), it.inner()))
    }
    it
  }

  // Outline styling for table figures

  show outline.where(target: figure.where(kind: table)): it => {
    show outline.entry.where(level: 1): {
      it => link(it.element.location(), it.indented(strong(it.prefix()), it.inner()))
    }
    it
  }

  // Figure styles

  show figure.where(kind: table): set figure(
    supplement: [Tab.],
    numbering: "1",
  ) if lang == "de"
  show figure.where(kind: image): set figure(
    supplement: [Abb.],
    numbering: "1",
  ) if lang == "de"
  show figure.where(kind: table): set figure.caption(position: top)

  // Set Table style

  set table(stroke: none, gutter: auto, fill: none)

  // Emphasize the figure caption numbering

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

  // Configure the header.

  let header-oddPage = header-oddPage(header-line-stroke, header-title)
  let header-evenPage = header-evenPage(header-line-stroke, header-title)
  let header-content = header-content(
    header-first-page,
    header-alternating,
    oddPage: header-oddPage,
    evenPage: header-evenPage,
  )
  set page(header: header-content) if header-display

  // Main body.

  if cols != none {
    show: rest => columns(cols, rest)
    content
  } else { content }
}

/// Function to format the Appendix.
/// This function is intended to be used after the document has been styled
/// with the `article` function.
///
/// Example usage:
/// ```typ
/// #show: article
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
  /// The title of the Appendix
  /// -> none | str | content
  title: none,
  /// The alignment of the title
  /// -> alignment
  title-align: center,
  /// The size of the title
  /// -> length
  title-size: none,
  /// The numbering of the Appendix
  /// -> none | str | function
  numbering: "A.1",
  /// Startting the appendix after this number
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
