#import "../theme.typ": *

// Call Graph (Arbre & Couches Logicielles)
#let noeud-appel(
  nom,
  tag: none,
  sous-titre: none,
  couleur: ece,
  enfants: (),
) = (
  nom: nom,
  tag: tag,
  sous-titre: sous-titre,
  couleur: couleur,
  enfants: enfants,
)

#let _render-arbre-rows(noeud, ancestor-continues: (), depth: 0, accent: ece) = {
  let is-root = depth == 0
  let rows = ()
  let col-w = 20pt
  let row-h = 28pt
  let line-stroke = 1.2pt + rgb("#94A3B8")
  let half-w = col-w / 2
  let half-h = row-h / 2
  let has-children = noeud.enfants.len() > 0

  // Build the node box
  let node-box = box(
    fill: if is-root { rgb("#F0FDF4") } else { white },
    stroke: 1pt + if is-root { accent } else { rgb("#CBD5E1") },
    radius: 3.5pt,
    inset: (x: 7pt, y: 4pt),
    grid(
      columns: (auto, auto, auto),
      column-gutter: 6pt,
      align: horizon,
      text(font: "Courier", weight: if is-root { "bold" } else { "medium" }, size: 8pt, fill: if is-root { accent } else { rgb("#1E293B") })[#noeud.nom],
      if noeud.sous-titre != none [
        #text(size: 6.8pt, style: "italic", fill: rgb("#64748B"))[(#noeud.sous-titre)]
      ],
      if noeud.tag != none [
        #box(
          fill: if is-root { rgb("#DCFCE7") } else { rgb("#F1F5F9") },
          stroke: 0.5pt + if is-root { rgb("#86EFAC") } else { rgb("#CBD5E1") },
          radius: 2.5pt,
          inset: (x: 4pt, y: 1.8pt),
          text(size: 6pt, weight: "bold", fill: if is-root { rgb("#15803D") } else { rgb("#475569") })[#noeud.tag]
        )
      ]
    )
  )

  // Build prefix cells for this row
  let prefix-cells = ()
  if not is-root {
    let last-idx = ancestor-continues.len() - 1
    for k in range(0, ancestor-continues.len()) {
      let continues = ancestor-continues.at(k)
      let is-connector = k == last-idx

      let cell = box(width: col-w, height: row-h, {
        if not is-connector {
          // Pass-through column: full vertical line if ancestor continues
          if continues {
            place(top + left,
              line(start: (half-w, 0pt), end: (half-w, row-h), stroke: line-stroke)
            )
          }
        } else {
          // Connector: vertical from top to center
          place(top + left,
            line(start: (half-w, 0pt), end: (half-w, half-h), stroke: line-stroke)
          )
          // Horizontal from center to right edge
          place(top + left,
            line(start: (half-w, half-h), end: (col-w, half-h), stroke: line-stroke)
          )
          // Continuation below if not last sibling
          if continues {
            place(top + left,
              line(start: (half-w, half-h), end: (half-w, row-h), stroke: line-stroke)
            )
          }
        }
      })
      prefix-cells.push(cell)
    }
  }

  // Children drop line: from node center down to bottom of row
  let drop-cell = if has-children {
    let drop-x = if is-root { half-w } else { (ancestor-continues.len() + 0.5) * col-w }
    place(top + left,
      line(start: (drop-x, half-h), end: (drop-x, row-h), stroke: line-stroke)
    )
  }

  // Compose the row
  let row-content = box(width: 100%, height: row-h, {
    if drop-cell != none { drop-cell }
    align(left + horizon,
      grid(
        columns: (col-w,) * depth + (auto,),
        align: horizon,
        ..prefix-cells,
        node-box,
      )
    )
  })
  rows.push(row-content)

  // Recurse into children
  let total-enfants = noeud.enfants.len()
  for (idx, enfant) in noeud.enfants.enumerate() {
    let enfant-is-last = idx == total-enfants - 1
    let next-continues = ancestor-continues + (not enfant-is-last,)
    let child-rows = _render-arbre-rows(
      enfant,
      ancestor-continues: next-continues,
      depth: depth + 1,
      accent: accent,
    )
    for r in child-rows {
      rows.push(r)
    }
  }

  rows
}

#let arbre-appels(racine, width: 100%, accent: ece) = {
  box(
    width: width,
    stroke: 0.6pt + rgb("#CBD5E1"),
    radius: 6pt,
    fill: rgb("#FAFAFA"),
    inset: (x: 16pt, y: 14pt),
    align(left)[
      #stack(
        spacing: 0pt,
        .._render-arbre-rows(racine, accent: accent)
      )
    ]
  )
}
#let call-tree = arbre-appels

#let call-graph-couches(
  couches: (),
  width: 100%,
  accent: ece,
) = {
  box(
    width: width,
    stroke: 0.6pt + rgb("#CBD5E1"),
    radius: 4pt,
    fill: white,
    inset: (x: 10pt, y: 10pt),
    stack(
      spacing: 6pt,
      ..couches.enumerate().map(((idx, c)) => {
        let nom-couche = c.nom
        let fns = c.fonctions
        let bg = if idx == 0 { rgb("#F0FDF4") } else if idx == couches.len() - 1 { rgb("#FFFDF6") } else { rgb("#F8FAFC") }
        let stroke-c = if idx == 0 { rgb("#86EFAC") } else if idx == couches.len() - 1 { rgb("#FDE68A") } else { rgb("#CBD5E1") }

        stack(
          spacing: 3pt,
          box(
            width: 100%,
            fill: bg,
            stroke: 1pt + stroke-c,
            radius: 3pt,
            inset: (x: 8pt, y: 6pt),
            stack(
              spacing: 5pt,
              text(size: 7.5pt, weight: "bold", fill: rgb("#334155"))[#nom-couche],
              grid(
                columns: (1fr,) * fns.len(),
                gutter: 6pt,
                ..fns.map(f => {
                  let f-nom = if type(f) == dictionary { f.nom } else { f }
                  let f-tag = if type(f) == dictionary { f.at("tag", default: none) } else { none }
                  box(
                    width: 100%,
                    fill: white,
                    stroke: 0.8pt + rgb("#CBD5E1"),
                    radius: 2.5pt,
                    inset: (x: 4pt, y: 3.5pt),
                    align(center)[
                      #text(font: "Courier", size: 7.5pt, weight: "bold", fill: accent)[#f-nom]
                      #if f-tag != none [
                        #v(1.5pt)
                        #text(size: 5.5pt, fill: rgb("#64748B"))[#f-tag]
                      ]
                    ]
                  )
                })
              )
            )
          ),
          if idx < couches.len() - 1 {
            align(center, text(size: 8pt, fill: rgb("#94A3B8"))[↓ appels ↓])
          }
        )
      })
    )
  )
}
#let call-graph = call-graph-couches
#let graphe-appels = call-graph-couches
