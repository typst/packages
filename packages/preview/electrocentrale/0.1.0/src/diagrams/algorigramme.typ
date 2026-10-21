#import "../theme.typ": *

// Algorigrammes et logigrammes
#let fleche-algo(
  ..args,
  label: none,
  longueur: 22pt,
  couleur: rgb("#64748B"),
  pill: false,
) = {
  let l = if args.pos().len() > 0 { args.pos().at(0) } else { label }
  let has-label = l != none and l != ""
  let is-oui = l in ("OUI", "Oui", "oui", "YES", "Yes", "yes", "VRAI", "True")
  let is-non = l in ("NON", "Non", "non", "NO", "No", "no", "FAUX", "False")
  let badge-color = if is-oui { rgb("#15803D") } else if is-non { warning-red } else { rgb("#475569") }
  let badge-bg = if is-oui { rgb("#F0FDF4") } else if is-non { rgb("#FEF2F2") } else { rgb("#F1F5F9") }
  let badge-border = if is-oui { rgb("#86EFAC") } else if is-non { rgb("#FECACA") } else { rgb("#CBD5E1") }

  let vw = 5.2pt
  let vh = 4.8pt

  box(width: 80pt, height: longueur)[
    #place(center + top)[
      #line(start: (0pt, 0pt), end: (0pt, longueur - 1.5pt), stroke: 1.2pt + couleur)
    ]
    #place(center + bottom)[
      #polygon(
        fill: couleur,
        (0pt, 0pt),
        (vw, 0pt),
        (vw / 2, vh),
      )
    ]
    #if has-label [
      #place(center + horizon, dx: 18pt)[
        #if pill [
          #box(
            inset: (x: 4.5pt, y: 1.5pt),
            radius: 3pt,
            fill: badge-bg,
            stroke: 0.6pt + badge-border,
            text(size: 6.2pt, weight: "bold", fill: badge-color)[#l]
          )
        ] else [
          #text(size: 7.2pt, weight: "bold", fill: badge-color)[#l]
        ]
      ]
    ]
  ]
}

#let algo-debut(texte, sous-titre: none, couleur: ece) = box(
  fill: rgb("#EBF5F5"),
  stroke: 1.2pt + couleur,
  radius: 20pt,
  inset: (x: 16pt, y: 6.5pt),
  [
    #set par(justify: false, leading: 2.2pt)
    #set text(hyphenate: false)
    #align(center)[
      #text(weight: "bold", size: 8.5pt, fill: couleur)[#texte]
      #if sous-titre != none [
        #v(2pt)
        #text(size: 7pt, fill: rgb("#555555"))[#sous-titre]
      ]
    ]
  ]
)

#let algo-fin(texte, sous-titre: none, couleur: warning-red) = box(
  fill: rgb("#FEF2F2"),
  stroke: 1.2pt + couleur,
  radius: 20pt,
  inset: (x: 16pt, y: 6.5pt),
  [
    #set par(justify: false, leading: 2.2pt)
    #set text(hyphenate: false)
    #align(center)[
      #text(weight: "bold", size: 8.5pt, fill: couleur)[#texte]
      #if sous-titre != none [
        #v(2pt)
        #text(size: 7pt, fill: rgb("#555555"))[#sous-titre]
      ]
    ]
  ]
)

#let algo-action(texte, sous-titre: none, width: 140pt, couleur: rgb("#64748B"), fill: white) = box(
  width: width,
  fill: fill,
  stroke: 1pt + couleur,
  radius: 3.5pt,
  inset: (x: 8pt, y: 6.5pt),
  [
    #set par(justify: false, leading: 2.2pt)
    #set text(hyphenate: false)
    #align(center)[
      #text(weight: "medium", size: 8.5pt, fill: rgb("#1E293B"))[#texte]
      #if sous-titre != none [
        #v(2pt)
        #text(size: 7pt, fill: rgb("#64748B"))[#sous-titre]
      ]
    ]
  ]
)

#let algo-es(texte, sous-titre: none, width: 154pt, height: 32pt, couleur: darkpowderblue) = {
  let slant = 10pt
  box(
    width: width,
    height: if sous-titre != none { height + 10pt } else { height },
    [
      #set par(justify: false, leading: 2.2pt)
      #set text(hyphenate: false)
      #align(center + horizon)[
        #place(top + left)[
          #layout(size => {
            let w = size.width
            let h = size.height
            polygon(
              fill: rgb("#F0F7FF"),
              stroke: 1.1pt + couleur,
              (slant, 0pt),
              (w, 0pt),
              (w - slant, h),
              (0pt, h),
            )
          })
        ]
        #box(width: width - slant * 2)[
          #align(center)[
            #text(weight: "semibold", size: 8.2pt, fill: couleur)[#texte]
            #if sous-titre != none [
              #v(1.5pt)
              #text(size: 6.8pt, fill: rgb("#64748B"))[#sous-titre]
            ]
          ]
        ]
      ]
    ]
  )
}
#let algo-io = algo-es

#let algo-decision(
  question,
  non: none,
  label-non: auto,
  width: 140pt,
  height: 44pt,
  couleur: rgb("#D97706"),
  pill: false,
) = {
  let q = if type(question) == str and not question.ends-with("?") { question + " ?" } else { question }
  box(
    width: width,
    height: height,
    [
      #set par(justify: false, leading: 2.2pt)
      #set text(hyphenate: false)
      #place(top + left)[
        #polygon(
          fill: rgb("#FFFBEB"),
          stroke: 1.2pt + couleur,
          (width / 2, 0pt),
          (width, height / 2),
          (width / 2, height),
          (0pt, height / 2),
        )
      ]
      #place(center + horizon)[
        #box(width: width * 0.74)[
          #align(center)[#text(weight: "bold", size: 7.8pt, fill: rgb("#B45309"))[#q]]
        ]
      ]
      #if non != none [
        #place(left + horizon, dx: width)[
          #box(height: height)[
            #context {
              let lbl = if label-non != auto {
                label-non
              } else if text.lang == "en" {
                "NO"
              } else {
                "NON"
              }
              let arrow-l = 42pt
              let arrow-hw = 4.8pt
              let arrow-hh = 5pt

              grid(
                columns: (arrow-l, auto),
                align: horizon,
                column-gutter: 4pt,
                box(width: arrow-l, height: height)[
                  #place(center + horizon, dy: -9pt)[
                    #if pill [
                      #box(
                        fill: rgb("#FEF2F2"),
                        inset: (x: 4pt, y: 1.2pt),
                        radius: 2.5pt,
                        stroke: 0.5pt + rgb("#FECACA")
                      )[
                        #text(size: 6pt, weight: "bold", fill: warning-red)[#lbl]
                      ]
                    ] else [
                      #text(size: 7.2pt, weight: "bold", fill: warning-red)[#lbl]
                    ]
                  ]
                  #place(center + horizon)[
                    #line(start: (0pt, 0pt), end: (100% - 1.5pt, 0pt), stroke: 1.2pt + rgb("#64748B"))
                    #place(right + horizon)[
                      #polygon(
                        fill: rgb("#64748B"),
                        (0pt, 0pt),
                        (arrow-hw, arrow-hh / 2),
                        (0pt, arrow-hh),
                      )
                    ]
                  ]
                ],
                if type(non) == str [
                  #box(
                    fill: rgb("#FEF2F2"),
                    stroke: 1.1pt + warning-red,
                    radius: 3.5pt,
                    inset: (x: 8pt, y: 6pt),
                    [
                      #set par(justify: false)
                      #set text(hyphenate: false)
                      #text(size: 7.8pt, weight: "semibold", fill: warning-red)[#non]
                    ]
                  )
                ] else {
                  non
                }
              )
            }
          ]
        ]
      ]
    ]
  )
}

#let algo-sous-programme(texte, sous-titre: none, width: 140pt, couleur: ece) = box(
  width: width,
  fill: rgb("#F8FAFC"),
  stroke: 1pt + couleur,
  radius: 3.5pt,
  clip: true,
  [
    #set par(justify: false, leading: 2.2pt)
    #set text(hyphenate: false)
    #place(left + top)[#line(start: (6pt, 0pt), end: (6pt, 100%), stroke: 1pt + couleur)]
    #place(right + top)[#line(start: (-6pt, 0pt), end: (-6pt, 100%), stroke: 1pt + couleur)]
    #box(width: 100%, inset: (x: 12pt, y: 6.5pt), align(center)[
      #text(weight: "bold", size: 8.5pt, fill: couleur)[#texte]
      #if sous-titre != none [
        #v(2pt)
        #text(size: 7pt, fill: rgb("#64748B"))[#sous-titre]
      ]
    ])
  ]
)
#let algo-sous-routine = algo-sous-programme

#let algo-branche(
  condition,
  oui: (),
  non: (),
  label-oui: auto,
  label-non: auto,
  largeur-noeud: 120pt,
  pill: false,
) = {
  let w = largeur-noeud
  let g = 24pt
  let arm = (w + g) / 2
  let total-w = w * 2 + g
  let oui-items = if type(oui) == array { oui } else { (oui,) }
  let non-items = if type(non) == array { non } else { (non,) }

  box(width: total-w)[
    #align(center)[
      #algo-decision(condition, width: w, pill: pill)
      
      #context {
        let lbl-oui = if label-oui != auto { label-oui } else if text.lang == "en" { "YES" } else { "OUI" }
        let lbl-non = if label-non != auto { label-non } else if text.lang == "en" { "NO" } else { "NON" }
        let vw = 5.2pt
        let vh = 4.8pt
        box(width: total-w, height: 22pt)[
          #place(center + top)[#line(start: (0pt, 0pt), end: (0pt, 9pt), stroke: 1.2pt + rgb("#64748B"))]
          #place(center + top, dy: 9pt)[#line(start: (-arm, 0pt), end: (arm, 0pt), stroke: 1.2pt + rgb("#64748B"))]
          #place(center + top, dx: -arm, dy: 9pt)[
            #line(start: (0pt, 0pt), end: (0pt, 13pt - 1.5pt), stroke: 1.2pt + rgb("#64748B"))
            #place(center + bottom)[#polygon(fill: rgb("#64748B"), (0pt, 0pt), (vw, 0pt), (vw / 2, vh))]
          ]
          #place(center + top, dx: arm, dy: 9pt)[
            #line(start: (0pt, 0pt), end: (0pt, 13pt - 1.5pt), stroke: 1.2pt + rgb("#64748B"))
            #place(center + bottom)[#polygon(fill: rgb("#64748B"), (0pt, 0pt), (vw, 0pt), (vw / 2, vh))]
          ]
          #place(center + top, dx: -arm / 2, dy: 0pt)[
            #if pill [
              #box(fill: rgb("#F0FDF4"), inset: (x: 4pt, y: 1.2pt), radius: 2.5pt, stroke: 0.5pt + rgb("#86EFAC"))[
                #text(size: 6pt, weight: "bold", fill: rgb("#15803D"))[#lbl-oui]
              ]
            ] else [
              #text(size: 7.2pt, weight: "bold", fill: rgb("#15803D"))[#lbl-oui]
            ]
          ]
          #place(center + top, dx: arm / 2, dy: 0pt)[
            #if pill [
              #box(fill: rgb("#FEF2F2"), inset: (x: 4pt, y: 1.2pt), radius: 2.5pt, stroke: 0.5pt + rgb("#FECACA"))[
                #text(size: 6pt, weight: "bold", fill: warning-red)[#lbl-non]
              ]
            ] else [
              #text(size: 7.2pt, weight: "bold", fill: warning-red)[#lbl-non]
            ]
          ]
        ]
      }

      #grid(
        columns: (w, w),
        column-gutter: g,
        align: top + center,
        stack(
          spacing: 0pt,
          ..oui-items.map(el => if type(el) == str { fleche-algo(label: el, pill: pill) } else { el })
        ),
        stack(
          spacing: 0pt,
          ..non-items.map(el => if type(el) == str { fleche-algo(label: el, pill: pill) } else { el })
        )
      )
    ]
  ]
}

#let algorigramme(..etapes, pill: false) = {
  let raw = etapes.pos()
  let items = ()
  let i = 0
  while i < raw.len() {
    let current = raw.at(i)
    if type(current) == str {
      items.push(fleche-algo(label: if current != "" { current } else { none }, pill: pill))
      i += 1
    } else {
      items.push(current)
      if i + 1 < raw.len() {
        let next-el = raw.at(i + 1)
        if type(next-el) != str {
          items.push(fleche-algo(pill: pill))
        }
      }
      i += 1
    }
  }

  align(center)[
    #stack(
      dir: ttb,
      spacing: 0pt,
      ..items
    )
  ]
}
