/*
 * Copyright (c) 2025 npikall
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the MIT License; see the LICENSE file for details.
 *
 * This file contains minor utility functions which are used in other functions
 * or have very little functionality.
 */

#import "dependencies.typ": *

// Used to reset the equation counter to 0 for chapterwise numbering.
#let reset-eq-counter = it => {
  counter(math.equation).update(0)
  it
}

// Helper function to display the header on odd pages
#let header-oddPage(header-line-stroke, header-title) = context {
  set text(10pt)
  set grid.hline(stroke: header-line-stroke)
  grid(
    columns: (1fr, 1fr),
    align: (left, right),
    inset: 4pt,
    smallcaps(header-title),
    smallcaps(hydra(1)),
    grid.hline(),
  )
}

// Helper function to display the header on even pages
#let header-evenPage(header-line-stroke, header-title) = context {
  set text(10pt)
  set grid.hline(stroke: header-line-stroke)
  grid(
    columns: (1fr, 1fr),
    align: (left, right),
    inset: 4pt,
    smallcaps(hydra(1)),
    smallcaps(header-title),
    grid.hline(),
  )
}

// Helper function to put a header line with alternating content
#let header-content(
  first-page-header,
  alternating-header,
  oddPage: header-oddPage,
  evenPage: header-evenPage,
) = context {
  let current = counter(page).get().first()

  if current > first-page-header and calc.rem(current, 2) == 0 {
    return evenPage
  } else if current > first-page-header {
    if alternating-header {
      return oddPage
    } else {
      return evenPage
    }
  }
}

// Used to determine if the long or short caption should be displayed.
#let outlined = state("outlined", false)

/// Balance the content of columns.
/// Have a multicolumn layout with almost equal height columns.
/// #show link: set text(fill:blue)
/// Credits go to: #link("https://github.com/typst/typst/issues/466")
///
/// Example usage:
/// ```typ
/// #balance(columns(n)[#lorem(80)])
/// ```
///
/// -> content
#let balance(content) = layout(size => {
  let count = content.at("count")
  let textheight = measure(content).at("height")
  let linegap = par.leading.em * textheight
  let (height,) = measure(block(width: size.width, content))
  let lines = calc.ceil((height - textheight) / count / (textheight + linegap))
  let newheight = lines * (textheight + linegap) + textheight
  [#block(height: newheight)[#content]]
})


/// A vertical space, which is weakly enforced.
/// This is useful to add space between paragraphs if the default spacing is not
/// sufficient and the same space should be used throughout the document.
/// By using this function instead of regular `v(xem)` you can ensure the same distance
/// throughout the document.
///
/// ```typ
/// #lorem(50) // Some paragraph
/// #vspace // Add some space
/// #lorem(50) // Next paragraph
/// ```
///
/// If the space is not as large as you want it to be, you can set the value in the
/// beginning of the document with `#let vspace = v(1.5em)`
///
/// -> space
#let vspace = v(1.5em, weak: true)
