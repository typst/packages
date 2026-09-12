// A tabular theme courtesy of [@Fevol](https://github.com/Fevol)
#let theme-table = (
  section: (title, body) => {
    heading(level: 1, title)
    body
  },
  group: (name, index, total, body) => {
    if name != "" and total > 1 {
      heading(level: 2, name)
    }

    table(
      columns: 4,
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
      table.header([*Abbreviation*], [*Full Name*], [*Description*], [*Pages*]),
      ..body,
    )
  },
  entry: (entry, index, total) => {
    if entry.reference == none {
      (
        entry.short + entry.label,
        entry.long,
        entry.description,
        entry.pages.join(", "),
      )
    } else {
      if entry.reference.supplement == none {
        (
          entry.short + entry.label,
          entry.long,
          [#entry.description #cite(label(entry.reference.key))],
          entry.pages.join(", "),
        )
      } else {
        (
          entry.short + entry.label,
          entry.long,
          [#entry.description #cite(
              label(entry.reference.key),
              supplement: entry.reference.supplement,
            )],
          entry.pages.join(", "),
        )
      }
    }
  },
)
