#import "../theme.typ": *

// Organigramme d'équipe ou de département
#let carte-membre(
  nom,
  role: none,
  service: none,
  affiliation: none,
  tag: none,
  badge: auto,
  email: none,
  responsable: false,
  stagiaire: false,
  couleur: auto,
  width: 100%,
  compact: false,
) = {
  let affil = if service != none { service } else { affiliation }
  let accent = if couleur != auto {
    couleur
  } else if stagiaire {
    gamboge
  } else if responsable {
    ece
  } else {
    darkpowderblue
  }

  let bg = if responsable {
    rgb("#F2F9F9")
  } else if stagiaire {
    rgb("#FFFDF6")
  } else {
    white
  }

  let border-color = if responsable {
    ece
  } else if stagiaire {
    gamboge
  } else {
    rgb("#CBD5E1")
  }

  let pad-y = if compact { 3.5pt } else { 5.5pt }
  let pad-x = if compact { 5pt } else { 8pt }
  let font-name = if compact { 8pt } else { 9pt }
  let font-role = if compact { 6.8pt } else { 7.8pt }
  let font-sub = if compact { 6pt } else { 6.8pt }
  let top-bar = if compact { 2.5pt } else { 3.5pt }

  let show-badge = if badge == false or badge == none {
    false
  } else if badge == true or type(badge) == str {
    true
  } else {
    tag != none or stagiaire or responsable
  }

  box(
    width: width,
    fill: bg,
    stroke: (top: top-bar + accent, rest: 0.8pt + border-color),
    radius: 5pt,
  )[
    #pad(x: pad-x, top: pad-y, bottom: pad-y)[
      #align(center)[
        #if show-badge [
          #let badge-text = if type(badge) == str {
            badge
          } else if tag != none {
            tag
          } else if stagiaire {
            "STAGIAIRE"
          } else {
            "RESPONSABLE"
          }
          #box(
            fill: accent.lighten(80%),
            radius: 3pt,
            inset: (x: 4pt, y: 1.2pt),
          )[
            #text(size: 6pt, weight: "bold", fill: accent)[#badge-text]
          ]
          #v(if compact { 2pt } else { 2.5pt })
        ]
        #text(weight: "bold", size: font-name, fill: if responsable { ece } else { rgb("#0F172A") })[#nom]
        #if role != none [
          #v(1.2pt)
          #text(size: font-role, style: "italic", fill: rgb("#334155"))[#role]
        ]
        #if affil != none [
          #v(1.2pt)
          #text(size: font-sub, fill: rgb("#64748B"))[#affil]
        ]
        #if email != none [
          #v(1.2pt)
          #text(size: font-sub, fill: darkpowderblue)[#link("mailto:" + email)[#email]]
        ]
      ]
    ]
  ]
}

// Organigramme d'entreprise, de département ou de projet multi-pôles
#let orga-entreprise(
  direction: "Direction Technique & R&D",
  transverse: none,
  poles: (),
  largeur: 100%,
  gutter: 12pt,
  couleur-liaison: ece,
  largeur-direction: auto,
  largeur-transverse: auto,
) = {
  let nb-poles = poles.len()
  let cols = (1fr,) * calc.max(1, nb-poles)
  let stroke = 1.2pt + couleur-liaison
  let stroke-trans = 1.2pt + couleur-liaison.lighten(25%)

  let dir-w = if largeur-direction != auto {
    largeur-direction
  } else if type(direction) == str {
    auto
  } else {
    215pt
  }

  let trans-w = if largeur-transverse != auto {
    largeur-transverse
  } else {
    175pt
  }

  let dir-node = if type(direction) == str [
    #box(
      fill: rgb("#EBF5F5"),
      stroke: 1.2pt + ece,
      radius: 6pt,
      inset: (x: 16pt, y: 8pt),
    )[
      #text(weight: "bold", size: 10pt, fill: ece)[#direction]
    ]
  ] else [
    #box(width: dir-w)[#direction]
  ]

  let trans-node = if transverse != none [
    #box(width: trans-w)[#transverse]
  ] else {
    none
  }

  let top-section = if trans-node != none [
    #grid(
      columns: (1fr, auto, 1fr),
      align: (horizon + right, horizon + center, horizon + left),
      [],
      dir-node,
      grid(
        columns: (22pt, auto),
        align: (horizon + left, horizon + left),
        line(length: 22pt, stroke: stroke-trans),
        trans-node,
      )
    )
  ] else [
    #align(center)[#dir-node]
  ]

  let connector-section = if nb-poles > 0 [
    #let stem-h = 14pt
    #let drop-h = 12pt
    #let total-h = stem-h + drop-h
    #box(width: 100%, height: total-h)[
      #layout(size => {
        let w = size.width
        let col-w = (w - (nb-poles - 1) * gutter) / nb-poles
        box(width: 100%, height: total-h)[
          #if nb-poles > 1 {
            let x-start = col-w / 2
            let x-end = (nb-poles - 1) * (col-w + gutter) + col-w / 2
            let x-center = w / 2
            place(top + left, line(start: (x-center, 0pt), end: (x-center, stem-h), stroke: stroke))
            place(top + left, line(start: (x-start, stem-h), end: (x-end, stem-h), stroke: stroke))
            for i in range(nb-poles) {
              let x = i * (col-w + gutter) + col-w / 2
              place(top + left, line(start: (x, stem-h), end: (x, total-h), stroke: stroke))
            }
          } else {
            let x-center = w / 2
            place(top + left, line(start: (x-center, 0pt), end: (x-center, total-h), stroke: stroke))
          }
        ]
      })
    ]
  ] else {
    none
  }

  let poles-section = if nb-poles > 0 [
    #grid(
      columns: cols,
      gutter: gutter,
      ..poles.map(p => {
        let p-nom = p.at("nom", default: "")
        let p-resp = p.at("responsable", default: none)
        let p-sous-poles = p.at("sous-poles", default: ())
        let p-membres = p.at("membres", default: ())
        let accent-pole = p.at("couleur", default: darkpowderblue)
        
        box(
          fill: rgb("#F8FAFC"),
          stroke: 0.8pt + rgb("#CBD5E1"),
          radius: 6pt,
          inset: (x: 6pt, y: 7pt),
          width: 100%,
        )[
          #align(center)[
            #text(weight: "bold", size: 8pt, fill: accent-pole)[#p-nom]
            #v(3pt)
            #line(length: 65%, stroke: 0.8pt + accent-pole.lighten(50%))
            #v(5pt)
            
            #if p-resp != none [
              #p-resp
              #if p-membres.len() > 0 or p-sous-poles.len() > 0 [
                #v(4pt)
                #line(start: (0pt, 0pt), end: (0pt, 8pt), stroke: 0.8pt + rgb("#94A3B8"))
                #v(3pt)
              ]
            ]

            #if p-membres.len() > 0 [
              #stack(
                spacing: 5pt,
                ..p-membres
              )
            ]

            #if p-sous-poles.len() > 0 [
              #if p-membres.len() > 0 [ #v(5pt) ]
              #stack(
                spacing: 6pt,
                ..p-sous-poles.map(sp => {
                  let sp-nom = sp.at("nom", default: "")
                  let sp-membres = sp.at("membres", default: ())
                  box(
                    fill: white,
                    stroke: 0.6pt + rgb("#E2E8F0"),
                    radius: 5pt,
                    inset: (x: 5pt, top: 4pt, bottom: 5pt),
                    width: 100%,
                  )[
                    #text(size: 6.8pt, weight: "bold", fill: rgb("#475569"))[#upper(sp-nom)]
                    #v(3pt)
                    #stack(
                      spacing: 4pt,
                      ..sp-membres
                    )
                  ]
                })
              )
            ]
          ]
        ]
      })
    )
  ] else {
    none
  }

  align(center)[
    #box(width: largeur)[
      #stack(
        spacing: 0pt,
        top-section,
        connector-section,
        poles-section,
      )
    ]
  ]
}
#let organigramme-entreprise = orga-entreprise
#let orga-projet = orga-entreprise
#let organigramme-projet = orga-entreprise

// Organigramme d'équipe projet
#let orga-equipe(
  responsable: none,
  poles: (),
  membres: (),
  largeur: 95%,
  gutter: 14pt,
  colonnes: auto,
  couleur-liaison: ece,
  largeur-responsable: auto,
) = {
  if poles.len() > 0 {
    orga-entreprise(
      direction: responsable,
      poles: poles,
      largeur: largeur,
      gutter: gutter,
      couleur-liaison: couleur-liaison,
      largeur-direction: largeur-responsable,
    )
  } else {
    let nb = membres.len()
    let cols-spec = if colonnes != auto {
      if type(colonnes) == int {
        (1fr,) * colonnes
      } else {
        colonnes
      }
    } else {
      (1fr,) * calc.max(1, calc.min(nb, 4))
    }
    let nb-cols = if type(cols-spec) == array { cols-spec.len() } else { 1 }
    let stroke = 1.2pt + couleur-liaison
    let resp-w = if largeur-responsable != auto {
      largeur-responsable
    } else {
      220pt
    }

    let resp-node = if responsable != none [
      #align(center)[
        #box(width: resp-w)[#responsable]
      ]
    ] else {
      none
    }

    let conn-node = if responsable != none and nb > 0 [
      #let stem-h = 14pt
      #let drop-h = 12pt
      #let total-h = stem-h + drop-h
      #box(width: 100%, height: total-h)[
        #layout(size => {
          let w = size.width
          let col-w = (w - (nb-cols - 1) * gutter) / nb-cols
          box(width: 100%, height: total-h)[
            #if nb-cols > 1 {
              let x-start = col-w / 2
              let x-end = (nb-cols - 1) * (col-w + gutter) + col-w / 2
              let x-center = w / 2
              place(top + left, line(start: (x-center, 0pt), end: (x-center, stem-h), stroke: stroke))
              place(top + left, line(start: (x-start, stem-h), end: (x-end, stem-h), stroke: stroke))
              for i in range(nb-cols) {
                let x = i * (col-w + gutter) + col-w / 2
                place(top + left, line(start: (x, stem-h), end: (x, total-h), stroke: stroke))
              }
            } else {
              let x-center = w / 2
              place(top + left, line(start: (x-center, 0pt), end: (x-center, total-h), stroke: stroke))
            }
          ]
        })
      ]
    ] else {
      none
    }

    let membres-section = if nb > 0 [
      #grid(
        columns: cols-spec,
        gutter: gutter,
        ..membres
      )
    ] else {
      none
    }

    align(center)[
      #box(width: largeur)[
        #stack(
          spacing: 0pt,
          resp-node,
          conn-node,
          membres-section,
        )
      ]
    ]
  }
}
#let organigramme-equipe = orga-equipe
