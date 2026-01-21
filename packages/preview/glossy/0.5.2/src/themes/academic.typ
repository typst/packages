// Inspired by academic textbook glossaries
#let theme-academic = (
  section: (title, body) => {
    set text(font: "New Computer Modern")
    heading(level: 1, title)
    v(1em)
    body
  },

  group: (name, index, total, body) => {
    if name != "" and total > 1 {
      v(1.5em)
      align(left, text(weight: "bold", size: 1.2em, name))
      v(0.75em)
      line(length: 100%, stroke: 0.5pt)
      v(0.75em)
    }
    body
  },

  entry: (entry, index, total) => {
    let short-display = text(weight: "bold", entry.short)
    let long-display = if entry.long == none {
      []
    } else {
      [. #entry.long]
    }

    let description = if entry.description == none {
      []
    } else {
      [. #entry.description]
    }

    block(
      below: 1em,
      text(
        size: 0.95em,
        {
          grid(
            columns: (1fr, auto),
            gutter: 0.75em,
            [#short-display#long-display#description#entry.label],
            text(fill: rgb("#666666"), entry.pages)
          )
        }
      )
    )
  },
)
