#let theme-pa = (
  section: (title, body) => {
    heading(level: 1, title)
    body
  },

  group: (name, index, total, body) => {

    set par(leading: 0.75em)

    if name != "" and total > 1 {
      heading(level: 2, name)
    }
    show table.cell.where(x: 0): strong
    // Pin the remaining table fields to their defaults so the user's global
    // table styling cannot leak into the glossary (explicit args beat set/show rules).
    table(columns: (1fr, 4fr),
      stroke: none,
      fill: none,
      align: auto,
      rows: auto,
      gutter: auto,
      column-gutter: auto,
      row-gutter: auto,
      inset: (x, y) => {
        if (x == 0) {
          (left: 0pt, rest: 5pt)
        } else if (x == 1) {
          (right: 0pt, rest: 5pt)
        } else {
          5pt
        }
      },
      ..body
    )
  },
  
  entry: (entry, index, total) => {
    (entry.short + entry.label, entry.long + entry.description)
  }
)