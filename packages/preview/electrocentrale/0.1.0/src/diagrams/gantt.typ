#import "../theme.typ": *

// Diagramme de Gantt (planning projet et stage)
#let gantt(
  unites: ("S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8"),
  taches: (),
  titre-taches: [*Tâches / Jalons*],
  accent: ece,
) = {
  let nb-u = unites.len()
  let cols = (2.6fr,) + (1fr,) * nb-u

  box(
    stroke: 0.6pt + rgb("#CBD5E1"),
    radius: 4pt,
    clip: true,
    width: 100%,
    table(
      columns: cols,
      align: (col, row) => if col == 0 { left + horizon } else { center + horizon },
      stroke: (x, y) => (
        top: 0.5pt + rgb("#E2E8F0"),
        bottom: if y == 0 { 1.5pt + accent } else { 0.5pt + rgb("#E2E8F0") },
        left: 0.5pt + rgb("#E2E8F0"),
        right: 0.5pt + rgb("#E2E8F0"),
      ),
      fill: (col, row) => if row == 0 { rgb("#F8FAFC") } else if calc.even(row) { rgb("#FCFDFD") } else { white },
      inset: (x: 6pt, y: 7pt),
      table.header(titre-taches, ..unites.map(u => text(weight: "bold", size: 8pt)[#u])),
      ..taches.map(t => {
        let cells = ([#text(weight: "medium", size: 8.5pt)[#t.nom]],)
        for u in range(1, nb-u + 1) {
          if u >= t.debut and u <= t.fin {
            let is-start = u == t.debut
            let is-end = u == t.fin
            let bar-color = t.at("couleur", default: accent)
            cells.push(box(
              fill: bar-color,
              radius: (
                left: if is-start { 3pt } else { 0pt },
                right: if is-end { 3pt } else { 0pt },
              ),
              width: 100%,
              height: 14pt,
            ))
          } else {
            cells.push([])
          }
        }
        cells
      }).flatten()
    )
  )
}
#let diagramme-gantt = gantt
