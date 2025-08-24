#let supervisors-page(supervisors) = {
  pagebreak(weak: true, to: "even")

  // Apply styling to supervisor content
  let supervisors-content = supervisors.map(s => {
    (
      [#text(weight: "semibold", s.title + ":")],
      [#s.name],
      [#s.affiliation],
    )
  })

  // --- Supervisors ---
  page(
    numbering: none,
    footer: [
      #align(center)[
        #par(spacing: .75em)[
          This document was typeset with Typst using the _modern UiT thesis_ template

          #sym.copyright 2024 -- Moritz Jörg and Ole Tytlandsvik

          #link("https://github.com/mrtz-j/typst-thesis-template")
        ]
      ]
    ],
    [
      #text(
        14pt,
        weight: "bold",
        font: ("Open Sans", "Noto Sans"),
        "Supervisors",
      )
      #grid(
        // NOTE: If supervisor title, name and affiliation overlap in the PDF, try changing the column widths here
        columns: (120pt, 100pt, 200pt),
        gutter: 2em,
        ..supervisors-content.flatten()
      )
    ],
  )
}
