#let affidavit-page(body, background: none) = page(
  paper: "a4",
  header: none,
  footer: none,
  background: background,
  [
    #align(start)[
      #show heading.where(level: 1): it => {
        v(7.5%)
        text(32pt, weight: "bold", it.body)
        v(5%, weak: true)
      }
      #heading(
        level: 1,
        bookmarked: false,
        outlined: false,
        "Affidavit",
      ) <ch:affidavit>

      #body
    ]
  ],
)
