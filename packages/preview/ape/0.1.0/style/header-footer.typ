#let header-footer(first-real-page, authors, content) = {
  set page(
    header: context {
      if (counter(page).get().at(0) > first-real-page and authors.len() > 0) {
        [
          #set text(size: 9pt)
          #grid(
            columns: (1fr, 2fr),
            align(left, authors.at(0)), align(right, authors.slice(1).join(" - ")),
          )
          #place(dy: 5pt, line(length: 100%, stroke: 0.5pt))
        ]
      }
    },

    footer: context {
      if (counter(page).get().at(0) >= first-real-page) {
        [
          #place(dy: -0.25cm, line(length: 100%, stroke: 0.5pt))
          #set align(center)


          _Page #counter(page).display() / #counter(page).final().at(0)_

        ]
      }
    },
  )

  content
}
