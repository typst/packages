#import "@preview/glossy:0.9.1": *

#let nomenclature(ctx) = {
  pagebreak(weak: true)

  // Initialisierung mit dem YAML-Pfad
  show: init-glossary.with(ctx.info.glossary)

  let theme = (
    // Section header
    section: (title, body) => {
      [= #title]
      body
    },
    // Grouping for "Abkürzungen", "Formelzeichen" and "Glossar"
    group: (name, index, total, body) => {
      if name != "" {
        [== #name]
      }
      table(
        columns: (20%, 1fr),
        stroke: none,
        inset: (x, y) => {
          if (x == 0) {
            (left: 0pt, rest: 5pt)
          } else {
            5pt
          }
        },
        ..body,
      )
    },
    // Entries with Short/Long for Abbreviations and Short/Description for Glossary
    entry: (entry, index, total) => {
      if entry.description != none {
        // Glossary entry
        (table.cell(colspan: 2)[
          *#eval(entry.long, mode: "markup"):*
          #entry.description
        ],)
      } else {
        // Abbreviation / Formula entry
        (
          [*#eval(entry.short, mode: "markup")*],
          [#entry.long],
        )
      }
    },
  )

  glossary(
    title: ctx.strings.at("nomenclature"),
    theme: theme,
    sort: true,
    ignore-case: false,
    show-all: true,
  )
}
