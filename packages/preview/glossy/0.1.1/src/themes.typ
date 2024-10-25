#let theme-2col = (
  section: (title, body) => {
    set par.line(numbering: none)
    heading(level: 1, title)
    columns(2, body)
  },

  group: (name, i, n, body) => {
    if name != "" and n > 1 {
      heading(level: 2, name)
    }
    body
  },

  entry: (entry, i, n) => {
    // build our title, etc
    let short-display = text(weight: "regular", entry.short)
    let long-display = if entry.long == none {
      []
    } else {
      [#h(0.25em) -- #entry.long]
    }

    // build our description
    let description = if entry.description == none {
      []
    } else {
      [: #entry.description]
    }

    text(
      size: 0.75em,
      weight: "light",
      grid(
        columns: (auto,auto,auto,1fr,1em,auto),
        align: (left, left, left, center, center, right),
        [#short-display#entry.label],
        [#long-display],
        [#description],
        [#repeat(h(0.25em) + "." + h(0.25em))],
        [ . ],
        [#entry.pages]
      )
    )
  },
)

