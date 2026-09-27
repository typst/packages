#import "../theme.typ": *

// Chaîne de blocs fonctionnels (électronique et HW/SW)
#let bloc-fonctionnel(
  titre,
  sous-titre: none,
  tag: none,
  fill: rgb("#F8FAFC"),
  stroke: ece,
  couleur: none,
  width: 100%,
  hauteur: 48pt,
  min-height: auto,
  compact: false,
) = {
  let c = if couleur != none { couleur } else { stroke }
  let h = if min-height != auto { min-height } else { hauteur }
  box(
    fill: fill,
    stroke: 1.2pt + c,
    radius: 4pt,
    inset: (x: if compact { 3.5pt } else { 4.5pt }, y: 4pt),
    width: width,
    height: if h != none and h != auto and h != 0pt { h } else { auto },
    align(center + horizon)[
      #set par(justify: false, leading: 2.2pt)
      #set text(hyphenate: false)
      #if tag != none [
        #box(
          fill: rgb("#F1F5F9"),
          stroke: 0.5pt + rgb("#CBD5E1"),
          radius: 2.5pt,
          inset: (x: 3.5pt, y: 1pt),
          text(size: 5.5pt, weight: "bold", fill: rgb("#475569"))[#tag]
        )
        #v(2pt)
      ]
      #text(weight: "bold", size: if compact { 7pt } else { 7.5pt }, fill: c)[#titre]
      #if sous-titre != none [
        #v(2pt)
        #text(size: if compact { 5.8pt } else { 6.2pt }, fill: rgb("#64748B"), weight: "regular")[#sous-titre]
      ]
    ]
  )
}
#let bloc = bloc-fonctionnel

#let fleche-bus(
  ..args,
  label: none,
  couleur: ece,
  bidirectionnelle: false,
  width: auto,
  pill: false,
  min-width: 32pt,
) = [
  #metadata("fleche-bus")
  #{
    let l = if args.pos().len() > 0 { args.pos().at(0) } else { label }
    let has-label = l != none and l != ""
    let arrow-head-w = 4.8pt
    let arrow-head-h = 5pt

    let label-content = if has-label {
      if pill [
        #box(
          inset: (x: 4pt, y: 1.2pt),
          radius: 3pt,
          fill: rgb("#F1F5F9"),
          stroke: 0.5pt + rgb("#CBD5E1"),
          text(size: 6pt, weight: "bold", fill: rgb("#334155"))[#l]
        )
      ] else [
        #text(size: 6.5pt, weight: "bold", fill: rgb("#475569"))[#l]
      ]
    } else {
      none
    }

    align(center + horizon)[
      #set par(justify: false)
      #context {
        let label-w = if has-label { measure(label-content).width + 8pt } else { 0pt }
        let total-w = if width != auto {
          width
        } else {
          calc.max(min-width, label-w)
        }

        box(width: total-w)[
          #stack(
            spacing: 2.5pt,
            if has-label {
              align(center)[#label-content]
            },
            box(width: 100%, height: 8pt)[
              #let line-start = if bidirectionnelle { arrow-head-w - 1.5pt } else { 0pt }
              #let line-end = 100% - 1.5pt
              #place(horizon)[#line(start: (line-start, 0pt), end: (line-end, 0pt), stroke: 1.2pt + couleur)]
              #if bidirectionnelle [
                #place(left + horizon)[
                  #polygon(
                    fill: couleur,
                    (arrow-head-w, 0pt),
                    (0pt, arrow-head-h / 2),
                    (arrow-head-w, arrow-head-h),
                  )
                ]
              ]
              #place(right + horizon)[
                #polygon(
                  fill: couleur,
                  (0pt, 0pt),
                  (arrow-head-w, arrow-head-h / 2),
                  (0pt, arrow-head-h),
                )
              ]
            ]
          )
        ]
      }
    ]
  }
]

#let is-bus-arrow(el) = type(el) == str or (type(el) == content and "fleche-bus" in repr(el))

#let chaine-blocs(..elements, largeur-fleche: auto, pill: false) = {
  let raw = elements.pos()
  let cols = ()
  let cells = ()
  let i = 0
  while i < raw.len() {
    let el = raw.at(i)
    if type(el) == str {
      cols.push(auto)
      cells.push(fleche-bus(label: el, width: largeur-fleche, pill: pill))
      i += 1
    } else if type(el) == content and "fleche-bus" in repr(el) {
      cols.push(auto)
      cells.push(el)
      i += 1
    } else {
      cols.push(1fr)
      cells.push(el)
      if i + 1 < raw.len() and not is-bus-arrow(raw.at(i + 1)) {
        cols.push(auto)
        cells.push(fleche-bus(width: largeur-fleche, pill: pill))
      }
      i += 1
    }
  }

  box(width: 100%)[
    #grid(
      columns: cols,
      align: horizon + center,
      column-gutter: 0pt,
      ..cells
    )
  ]
}
#let diagramme-blocs = chaine-blocs
