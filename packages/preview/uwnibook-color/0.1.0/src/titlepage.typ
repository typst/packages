#let gradient = 1

#let book_title(
  config,
  title,
  author,
  affiliation,
  date,
  draft,
) = {
  set page(
    // explicitly set the paper
    numbering: none,
    margin: (top: 3.5cm),
    background: {
      let width = 25pt
      let height = gradient * width
      let items = for i in range(30) {
        (
          curve.line((width, height), relative: true),
          curve.line((-width, 2 * height), relative: true),
        )
      }

      place(dx: config._page_margin_note_width, curve(..items, stroke: config._color_palette.accent + 2pt))
    },
  )

  set par(first-line-indent: 0pt, leading: 1em, spacing: 1em)
  set text(config._main_size, weight: 450, font: config._serif_font, lang: config._lang)

  let title_text = text.with(config._title_size, font: config._title_font, weight: 600)
  set align(horizon)
  show: move.with(dx: config._page_margin_note_width)
  block[
    #set align(left)
    #title_text(title.at(config._lang))
    #v(2em)
    ◎ #author.at(config._lang)
    #v(0.5em)
    #if affiliation != none {
      affiliation
      v(0.5em)
    }
    #if date != none { date.display(config._date_format) }
  ]

  if draft {
    draft_seal
  }
}

#let titlepage(style: "", ..args) = {
  set page(paper: "a4")

  (
    "book": book_title(..args),
  ).at(style)
  pagebreak(to: "odd")
}
