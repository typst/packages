#import "../template/src/settings/name.typ": *

// ============================================================================
// 1-LAYOUT.TYP - MISE EN PAGE
// ============================================================================
// Ce fichier gère la mise en page générale du document

#let mis-en-page(doc) = {
  import "box-layout.typ": *

  // CONFIGURATION DE LA PAGE
  set page(
    margin: (top: 3cm, bottom: 2cm, left: 2.5cm, right: 2.5cm),
    header: [
      #v(0.5cm)
      #grid(
        columns: (auto, 1fr),
        align: (horizon + left, horizon + right),
        gutter: 1em,
        image("../template/src/assets/picture/" + config.logo, height: 1.2cm),
        text(font: "New Computer Modern", size: 12pt)[#config.cours],
      )
      #v(0cm)
      #line(length: 100%)
    ],
    footer: [
      #show link: set text(fill: black)
      #line(length: 100%, stroke: 0.5pt)
      #text(10pt)[
        #grid(
          columns: (1fr, 1fr, 1fr),
          align: (left, center, right),
          {
            let author_links = ()
            for author in auteurs {
              if author.active {
                author_links.push(link("mailto:" + author.email, author.abreviation))
              }
            }
            text(fill: black, author_links.join(" & "))
          },

          config.date,
          context {
            let current = counter(page).display("1")
            let reperes = query(<fin_rapport>)
            let total = if reperes.len() > 0 {
              reperes.last().location().page()
            } else {
              counter(page).final().at(0)
            }
            [Page #current / #total]
          },
        )
      ]
    ],
  )

  set text(size: 11pt, lang: config.language)
  set par(justify: true, leading: 0.65em, spacing: 1.2em)
  show figure.where(kind: image): set figure(supplement: "Figure")

  // NUMÉROTATION ET TITRES
  set heading(numbering: "1.1.1")

  let styled-heading(it, size, above, below, dx-move) = {
    set text(size: size)
    block(above: above, below: below)[
      #move(dx: dx-move)[
        #if it.numbering != none {
          stack(
            dir: ltr,
            spacing: 0.5em,
            text(weight: "bold")[#counter(heading).display(it.numbering)],
            if it.level == 1 { text(fill: gray)[|] },
            it.body,
          )
        } else {
          it.body
        }
      ]
    ]
  }

  show heading.where(level: 1): it => styled-heading(it, 25pt, 1.5cm, 0.7cm, -1cm)
  show heading.where(level: 2): it => styled-heading(it, 18pt, 0.8cm, 0.5cm, -0.6cm)
  show heading.where(level: 3): it => styled-heading(it, 14pt, 0.7cm, 0.4cm, -0.3cm)
  show heading.where(level: 4): it => styled-heading(it, 13pt, 0.5cm, 0.4cm, -0.3cm)

  // LIENS ET RÉFÉRENCES
  show link: set text(fill: rgb("#318aa1"))
  show cite: set text(fill: rgb("#318aa1"))
  show ref: set text(fill: rgb("#318aa1"))

  // REGEX: Supprime les espaces avant points et virgules (français)
  show regex("\s+([.,])"): it => {
    let punctuation = it.text.match(regex("[.,]")).text
    punctuation
  }

  doc
}
