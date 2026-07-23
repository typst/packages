
/// Wide text environment at the top of a page, followed by two column layout
///
#let widetext-top(
  continue-paragraph-begin: true,
  continue-paragraph-end: true,
  content,
) = {
  if (continue-paragraph-begin) { linebreak(justify: true) }
  pagebreak()
  place(top, float: true, scope: "parent", block(width: 100%)[
    #if (not continue-paragraph-begin) { h(1em, weak: false) }
    #content
    #if (continue-paragraph-end) { linebreak(justify: true) }
    #move(dy: 8pt, curve(
      stroke: 0.5pt,
      curve.move((50%, 7pt)),
      curve.line((50%, 0pt)),
      curve.line((100%, 0pt)),
    ))
  ])
  if (not continue-paragraph-end) { h(1em) }
}

/// Wide text environment at the bottom of a page, preceeded by two column layout
///
#let widetext-bottom(
  continue-paragraph-begin: true,
  continue-paragraph-end: true,
  content,
) = {
  if (continue-paragraph-begin) { linebreak(justify: true) }
  place(bottom, float: true, scope: "parent", block(width: 100%)[
    #move(dy: -6pt, curve(
      stroke: 0.5pt,
      curve.line((50%, 0pt)),
      curve.line((50%, -7pt)),
    ))
    #v(6pt)
    #if (not continue-paragraph-begin) { h(1em, weak: false) }
    #content
    #if (continue-paragraph-end) { linebreak(justify: true) }
  ])
  pagebreak()
  if (not continue-paragraph-end) { h(1em) }
}

/// Wide text environment filling a whole page
///
#let widetext-page(
  continue-paragraph-begin: true,
  continue-paragraph-end: true,
  content,
) = {
  if (continue-paragraph-begin) { linebreak(justify: true) }
  pagebreak()
  place(top, float: true, scope: "parent", block(width: 100%, height: 100%, {
    if (not continue-paragraph-begin) { h(1em, weak: false) }
    content
    if (continue-paragraph-end) { linebreak(justify: true) }
  }))
  if (not continue-paragraph-end) { h(1em) }
}

