#import "brand.typ": *

// ── Shared Page Layout ──────────────────────────────────────────────────────
#let project-page(
  project: none,
  title: "",
  subtitle: none,
  body,
) = {
  set text(font: font-family, size: size-body)

  set page(
    margin: (x: 2cm, y: 2cm),
    header: align(right)[
      #text(size: size-small, fill: gris-texto)[#project.name | #project.version]
    ],
    footer: align(center)[
      #line(length: 100%, stroke: 0.5pt + gris-borde)
      #v(4pt)
      #text(size: size-small, fill: gris-texto)[
        Documento generado automáticamente el #datetime.today().display()
      ]
    ],
  )

  // Page Title Block
  align(center)[
    #text(size: size-title, weight: "black", fill: azul-oscuro)[= #title] \
    #v(4pt)
    #if subtitle != none {
      text(size: size-header, fill: gris-oscuro)[#subtitle]
      v(20pt)
    }
  ]

  body
}
