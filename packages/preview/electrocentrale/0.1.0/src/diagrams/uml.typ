#import "../theme.typ": *

// Diagrammes UML & Génie Logiciel

// 1. Diagramme de Classes UML
#let _formater-membre-uml(texte) = {
  let s = str(texte).trim()
  if s == "" { return [] }
  let first = s.at(0)
  let rest = s.slice(1).trim()
  if first in ("+", "-", "#", "~") {
    let (c, bg, sym) = if first == "+" {
      (rgb("#15803D"), rgb("#F0FDF4"), "+")
    } else if first == "-" {
      (warning-red, rgb("#FEF2F2"), "−")
    } else if first == "#" {
      (rgb("#D97706"), rgb("#FFFBEB"), "#")
    } else {
      (darkpowderblue, rgb("#F0F7FF"), "~")
    }
    box(
      inset: (x: 2.5pt, y: 0.5pt),
      radius: 2pt,
      fill: bg,
      text(weight: "bold", size: 7.5pt, fill: c)[#sym]
    )
    h(4pt)
    text(size: 8pt, fill: rgb("#1E293B"))[#rest]
  } else {
    text(size: 8pt, fill: rgb("#1E293B"))[#s]
  }
}

#let classe-uml(
  nom,
  stereotype: none,
  attributs: (),
  methodes: (),
  couleur: ece,
  width: 175pt,
  abstrait: false,
) = {
  box(
    width: width,
    stroke: 1.2pt + couleur,
    radius: 4pt,
    clip: true,
    fill: white,
    stack(
      spacing: 0pt,
      rect(
        fill: rgb("#F0F7F7"),
        width: 100%,
        stroke: (bottom: 1.1pt + couleur),
        inset: (x: 8pt, y: 6pt),
        align(center)[
          #if stereotype != none [
            #text(size: 7pt, style: "italic", fill: rgb("#64748B"))[\<\<#stereotype\>\>] \
            #v(1pt)
          ]
          #text(
            weight: "bold",
            style: if abstrait { "italic" } else { "normal" },
            size: 8.8pt,
            fill: couleur,
          )[#nom]
        ]
      ),
      if attributs.len() > 0 [
        #rect(
          fill: white,
          width: 100%,
          stroke: (bottom: if methodes.len() > 0 { 0.8pt + rgb("#E2E8F0") } else { none }),
          inset: (x: 8pt, y: 5pt),
          align(left)[
            #stack(
              spacing: 3.5pt,
              ..attributs.map(a => _formater-membre-uml(a))
            )
          ]
        )
      ],
      if methodes.len() > 0 [
        #rect(
          fill: rgb("#FAFAFA"),
          width: 100%,
          stroke: none,
          inset: (x: 8pt, y: 5pt),
          align(left)[
            #stack(
              spacing: 3.5pt,
              ..methodes.map(m => _formater-membre-uml(m))
            )
          ]
        )
      ]
    )
  )
}
#let uml-classe = classe-uml

#let relation-uml(
  type-rel: "heritage", // "heritage" | "implementation" | "composition" | "aggregation" | "association" | "dependance"
  label: none,
  card-source: none,
  card-cible: none,
  longueur: 54pt,
  direction: "gauche", // "gauche" | "droite"
  couleur: rgb("#475569"),
) = {
  let is-dashed = type-rel in ("implementation", "dependance")
  let stroke-style = (
    paint: couleur,
    thickness: 1.2pt,
    dash: if is-dashed { "dashed" } else { none },
  )
  let hw = 7pt
  let hh = 7pt
  let vers-droite = direction == "droite"

  align(center + horizon)[
    #box(width: longueur, height: 26pt)[
      #if label != none [
        #place(center + top, dy: 0pt)[
          #text(size: 6.8pt, style: "italic", fill: rgb("#64748B"))[#label]
        ]
      ]
      
      #let start-x = if not vers-droite and type-rel in ("heritage", "implementation") { hw - 1pt } else { 0pt }
      #let end-x = longueur - if vers-droite and type-rel in ("heritage", "implementation") { hw - 1pt } else { 0pt }
      #place(left + horizon)[
        #line(start: (start-x, 0pt), end: (end-x, 0pt), stroke: stroke-style)
      ]

      #if not vers-droite [
        #if type-rel in ("heritage", "implementation") [
          #place(left + horizon)[
            #polygon(
              fill: white,
              stroke: 1.2pt + couleur,
              (hw, -hh / 2),
              (0pt, 0pt),
              (hw, hh / 2),
            )
          ]
        ] else if type-rel in ("association", "dependance") [
          #place(left + horizon)[
            #polygon(
              fill: couleur,
              (4.8pt, -3pt),
              (0pt, 0pt),
              (4.8pt, 3pt),
            )
          ]
        ]
      ] else [
        #if type-rel in ("heritage", "implementation") [
          #place(right + horizon)[
            #polygon(
              fill: white,
              stroke: 1.2pt + couleur,
              (0pt, -hh / 2),
              (hw, 0pt),
              (0pt, hh / 2),
            )
          ]
        ] else if type-rel in ("association", "dependance") [
          #place(right + horizon)[
            #polygon(
              fill: couleur,
              (0pt, -3pt),
              (4.8pt, 0pt),
              (0pt, 3pt),
            )
          ]
        ]
      ]

      #if type-rel == "composition" [
        #place((if vers-droite { left } else { right }) + horizon)[
          #polygon(
            fill: couleur,
            stroke: 1pt + couleur,
            (0pt, 0pt),
            (hh / 2, -hh / 2),
            (hh, 0pt),
            (hh / 2, hh / 2),
          )
        ]
      ] else if type-rel == "aggregation" [
        #place((if vers-droite { left } else { right }) + horizon)[
          #polygon(
            fill: white,
            stroke: 1.2pt + couleur,
            (0pt, 0pt),
            (hh / 2, -hh / 2),
            (hh, 0pt),
            (hh / 2, hh / 2),
          )
        ]
      ]

      #if card-source != none [
        #place(left + bottom, dx: 3pt, dy: -1pt)[
          #text(size: 6.5pt, weight: "bold", fill: rgb("#64748B"))[#card-source]
        ]
      ]
      #if card-cible != none [
        #place(right + bottom, dx: -3pt, dy: -1pt)[
          #text(size: 6.5pt, weight: "bold", fill: rgb("#64748B"))[#card-cible]
        ]
      ]
    ]
  ]
}

#let diagramme-classes(..elements, gutter: 16pt) = {
  align(center)[
    #grid(
      columns: elements.pos().len(),
      column-gutter: gutter,
      align: horizon + center,
      ..elements.pos()
    )
  ]
}

// 2. Diagramme de Séquence UML
#let sequence-uml(
  participants: ("Navigateur Web", "API Gateway", "Base de Données"),
  messages: (),
  accent: ece,
  hauteur-step: 36pt,
) = {
  let nb = participants.len()

  box(width: 100%, stroke: 0.6pt + rgb("#CBD5E1"), radius: 4pt, inset: (x: 10pt, y: 12pt), fill: white)[
    #grid(
      columns: (1fr,) * nb,
      column-gutter: 12pt,
      ..participants.map(p => {
        let nom = if type(p) == dictionary { p.at("nom", default: "") } else { p }
        let tag = if type(p) == dictionary { p.at("tag", default: none) } else { none }
        box(
          width: 100%,
          fill: rgb("#F0F7F7"),
          stroke: 1.2pt + accent,
          radius: 3.5pt,
          inset: (x: 6pt, y: 6pt),
          align(center)[
            #if tag != none [
              #text(size: 6pt, weight: "bold", fill: rgb("#64748B"))[\<\<#tag\>\>] \
              #v(1pt)
            ]
            #text(size: 8.5pt, weight: "bold", fill: accent)[#nom]
          ]
        )
      })
    )

    #v(6pt)

    #for msg in messages {
      let de = msg.de
      let vers = msg.vers
      let lbl = msg.at("label", default: "")
      let m-type = msg.at("type", default: "sync")
      let is-retour = m-type == "retour"
      let is-self = de == vers

      box(width: 100%, height: hauteur-step)[
        #for k in range(1, nb + 1) {
          let pos-x = (k - 0.5) / nb * 100%
          place(left + top, dx: pos-x)[
            #line(start: (0pt, 0pt), end: (0pt, hauteur-step), stroke: (paint: rgb("#CBD5E1"), thickness: 1pt, dash: "dashed"))
          ]
        }

        #let line-y = hauteur-step * 0.55
        #let arrow-w = 5pt
        #let arrow-h = 5pt

        #if is-self [
          #let px = (de - 0.5) / nb * 100%
          #let loop-w = 28pt
          #let loop-h = 16pt
          #let loop-top = line-y - 4pt

          #place(top + left, dx: px + 4pt, dy: 0pt)[
            #box(width: 120pt, height: loop-top - 1.5pt)[
              #align(left + bottom)[
                #text(size: 7pt, weight: "medium", fill: rgb("#1E293B"))[#lbl]
              ]
            ]
          ]

          #place(top + left, dx: px, dy: loop-top)[
            #box(width: loop-w + 2pt, height: loop-h + 2pt)[
              #place(top + left, dx: 0pt, dy: 0pt)[
                #line(start: (0pt, 0pt), end: (loop-w, 0pt), stroke: 1.2pt + accent)
              ]
              #place(top + left, dx: loop-w, dy: 0pt)[
                #line(start: (0pt, 0pt), end: (0pt, loop-h), stroke: 1.2pt + accent)
              ]
              #place(top + left, dx: arrow-w - 0.5pt, dy: loop-h)[
                #line(start: (0pt, 0pt), end: (loop-w - arrow-w + 0.5pt, 0pt), stroke: 1.2pt + accent)
              ]
              #place(top + left, dx: 0pt, dy: loop-h - arrow-h / 2)[
                #polygon(
                  fill: accent,
                  stroke: 1pt + accent,
                  (arrow-w, 0pt),
                  (0pt, arrow-h / 2),
                  (arrow-w, arrow-h),
                )
              ]
            ]
          ]
        ] else [
          #let x-de = (de - 0.5) / nb * 100%
          #let x-vers = (vers - 0.5) / nb * 100%
          #let x-min = calc.min(x-de, x-vers)
          #let x-max = calc.max(x-de, x-vers)
          #let allant-a-droite = de < vers

          #place(top + left, dx: x-min + 6pt, dy: 0pt)[
            #box(width: x-max - x-min - 12pt, height: line-y - 2.5pt)[
              #align(center + bottom)[
                #text(size: 7.2pt, weight: "medium", fill: rgb("#1E293B"))[#lbl]
              ]
            ]
          ]

          #place(left + top, dx: x-min, dy: line-y)[
            #line(
              start: (0pt, 0pt),
              end: (x-max - x-min, 0pt),
              stroke: (
                paint: if is-retour { rgb("#64748B") } else { accent },
                thickness: 1.2pt,
                dash: if is-retour { "dashed" } else { none },
              )
            )
          ]

          #if allant-a-droite [
            #place(left + top, dx: x-max - arrow-w, dy: line-y - arrow-h / 2)[
              #polygon(
                fill: if is-retour { white } else { accent },
                stroke: 1.1pt + if is-retour { rgb("#64748B") } else { accent },
                (0pt, 0pt),
                (arrow-w, arrow-h / 2),
                (0pt, arrow-h),
              )
            ]
          ] else [
            #place(left + top, dx: x-min, dy: line-y - arrow-h / 2)[
              #polygon(
                fill: if is-retour { white } else { accent },
                stroke: 1.1pt + if is-retour { rgb("#64748B") } else { accent },
                (arrow-w, 0pt),
                (0pt, arrow-h / 2),
                (arrow-w, arrow-h),
              )
            ]
          ]
        ]
      ]
    }

    #v(4pt)

    #grid(
      columns: (1fr,) * nb,
      ..participants.map(p => align(center)[
        #box(width: 8pt, height: 4pt, fill: rgb("#CBD5E1"), radius: 2pt)
      ])
    )
  ]
}
#let diagramme-sequence = sequence-uml
