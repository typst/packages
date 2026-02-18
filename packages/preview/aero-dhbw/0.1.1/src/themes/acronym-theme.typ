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
    table(columns: (1fr, 4fr),
      stroke: none,
      inset: (x, y) => {
        if (x == 0) {
          (left: 0pt, rest: 5pt)
        } else if (x == 3) {
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