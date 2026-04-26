#import "@preview/suboutline:0.2.0": suboutline

#let colors = (
  accent: rgb(113, 127, 184),
)

#let publication(authors, title, venue, doi: none) = {
  set par(leading: 0.8em)
  [#authors. _[#title]_. #venue]
  if doi != none {
    [\ DOI: #link("https://doi.org/" + doi)[#doi]]
  }
}

#let objective(content) = {
  align(
    center,
    block(
      width: 88%,
      fill: white,
      stroke: colors.accent,
      inset: 10pt,
      radius: 4pt,
      align(left)[
        #place(
          top + left,
          dy: -16pt,
          dx: -30pt,
          block(
            fill: white,
            outset: 8pt,
            text(fill: colors.accent, weight: "bold", size: 14pt)[Objectives],
          ),
        )
        #content
      ],
    ),
  )

  v(3em)

  heading([Table of contents], depth: 2, outlined: false, numbering: none)
  line(length: 100%)
  suboutline()
  line(length: 100%)
  pagebreak()
}

