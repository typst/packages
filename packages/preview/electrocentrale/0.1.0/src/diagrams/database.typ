#import "../theme.typ": *

// Schéma relationnel de base de données
#let table-bdd(
  nom,
  colonnes,
  couleur-entete: darkpowderblue,
) = {
  box(
    stroke: 1.2pt + couleur-entete,
    radius: 4pt,
    clip: true,
    table(
      columns: (auto, auto, auto),
      stroke: 0.5pt + rgb("#E2E8F0"),
      fill: (col, row) => if row == 0 { couleur-entete } else if calc.even(row) { rgb("#F8FAFC") } else { white },
      inset: (x: 8pt, y: 5pt),
      table.header(
        table.cell(colspan: 3, fill: couleur-entete, align(center)[#text(fill: white, weight: "bold", size: 9pt)[#nom]])
      ),
      ..colonnes.map(c => {
        let (col-nom, col-type, col-key) = if c.len() == 3 { c } else { (c.at(0), c.at(1), "") }
        let is-pk = "PK" in col-key
        let is-fk = "FK" in col-key
        (
          align(left)[#text(weight: if is-pk { "bold" } else { "regular" }, size: 8.5pt)[#col-nom]],
          align(center)[#text(fill: rgb("#64748B"), size: 8pt, font: "Courier")[#col-type]],
          align(right)[#if is-pk [ #text(fill: gamboge, weight: "bold", size: 7.5pt)[PK] ] else if is-fk [ #text(fill: ece, weight: "bold", size: 7.5pt)[FK] ] else [ #text(size: 7.5pt, fill: rgb("#94A3B8"))[#col-key] ]],
        )
      }).flatten()
    )
  )
}
#let schema-bdd = table-bdd
