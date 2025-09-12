#import "../dependencies.typ": make-glossary, print-glossary, register-glossary
#import "../glossary-entries.typ": glossary-entry-list

#show: make-glossary
#register-glossary(glossary-entry-list)

#heading([Glossary], level: 1)
// https://forum.typst.app/t/how-to-fully-control-visualization-of-a-glossary-in-glossarium/1694
#print-glossary(
  show-all: true,
  user-print-glossary: (entries, groups, ..) => {
    grid(
      columns: (0.5fr, 1fr, 2.5fr),
      stroke: 0pt,
      row-gutter: 1em,
      column-gutter: 2em,
      ..for group in groups {
        (
          grid.cell(group, colspan: 3),
          ..for entry in entries.filter(x => x.group == group) {
            (
              text(weight: "bold", entry.short),
              entry.long,
              entry.description
            )
          }
        )
      }
    )
  },
  glossary-entry-list,
)
