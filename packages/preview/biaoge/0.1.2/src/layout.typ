// 论文版式：标题 + 作者网格 + 摘要
#let conf(
  authors: (),
  abstract: [],
  doc,
) = {
  set page(
    columns: 1,
    margin: (left: 1.5in, top: 1in, right: 1in, bottom: 1in),
  )
  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 2em,
    {
      title()

      let ncols = calc.min(authors.len(), 3)
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
    },
  )

  doc
}
