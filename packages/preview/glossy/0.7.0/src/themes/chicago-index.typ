// Inspired by the Chicago Manual of Style's index format
#let theme-chicago-index = (
  section: (title, body) => {
    set par(hanging-indent: 1em)
    heading(level: 1, smallcaps(title))
    body
  },

  group: (name, index, total, body) => {
    if name != "" and total > 1 {
      v(1em)
      text(weight: "medium", style: "italic", name)
      v(0.5em)
    }
    body
  },

  entry: (entry, index, total) => {
    let short-display = text(weight: "regular", entry.short)
    let long-display = if entry.long == none {
      []
    } else {
      [ — #entry.long]  // Using em-dash for Chicago style
    }

    let description = if entry.description == none {
      []
    } else {
      text(style: "italic", [: #entry.description])
    }

    block(
      below: 0.65em,
      text(
        size: 0.9em,
        {
          grid(
            columns: (1fr, auto),
            gutter: 1em,
            [#short-display#entry.label#long-display#description#entry.label],
            [#entry.pages]
          )
        }
      )
    )
  },
)
