#let conf(
  authors: (),
  abstract: [],
  doc,
) = {
  // Set and show rules from before.
  set page(
    columns: 1,
    margin: (left: 1.5in, top: 1in, right: 1in, bottom: 1in)
  )
   place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 2em,
    {
      title()

      let count = authors.len()
      let ncols = calc.min(count, 3)
      [#ncols]
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 24pt,
        ..authors.map(author => [
          #author.name \
          // #author.affiliation \
          // #link("mailto:" + author.email)
        ]),
      )

      par(justify: false)[
        *Abstract* \
        #abstract
      ]

    }
  )

  doc
}
