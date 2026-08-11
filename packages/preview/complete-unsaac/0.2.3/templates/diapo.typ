#import "@preview/complete-unsaac:0.2.3": diapo-funcs, src-block, src-file
#import diapo-funcs: *

#show: doc-diapo.with(
  titulo: [Titulo],
  subtitulo: [SubTitulo],
  curso: [Curso],
  docente: [Docente],
  autores: (
    (
      nombre: "Nombre Completo Autor 1",
      codigo: "100001",
    ),
    (
      nombre: "Nombre Completo Autor 2",
      codigo: "200002",
    ),
  ),
  // facultad: highlight[Ingrese su facultad],
  // escuela: highlight[Ingrese su E.P.],
  // escuela-logo: rect(height: 100%)[Ponga la imagen de su escudo aca],
)

/*
#show: touying-set-config.with(
  config-common(
    handout: true,
  ),
)
#show: touying-set-config.with(
  config-colors(
    primary: rgb("#4f46e5"),
    primary-light: rgb("#c7d2fe"),
    secondary: rgb("#0f172a"),
    neutral-lightest: rgb("#f8fafc"),
    neutral-dark: rgb("#334155"),
    neutral-darkest: rgb("#0f172a"),
  ),
)
#show: touying-set-config.with(
  config-store(
    align: start,
    footer: self => self.info.curso,
  ),
)
#show: touying-set-config.with(
  config-methods(
    cover: utils.color-changing-cover.with(color: rgb("#8b5e5e")),
  ),
)
*/

#title-slide()

#components.adaptive-columns(outline(title: none, indent: 1em, depth: 2))

= The Slide Function
#slide(composer: (2fr, 1fr))[
  == Subtitle 2

  + #lorem(20)

  #pause

  + #lorem(20)

  #pause

  + #lorem(20)
][
  #meanwhile

  #rect(width: 100%, height: 100%)
]

/*
#show: touying-set-config.with(
  config-common(
    slide-level: 1,
    new-section-slide-fn: new-section-slide,
  ),
)
*/

= Topic1

== Subtopic A
#lorem(20)
== Subtopic B
#lorem(20)
=== Subsubtopic a
#lorem(50)
=== Subsubtopic b
#lorem(50)

= Topic2

== Subtopic X
#lorem(20)
== Subtopic Y
#lorem(20)
=== Subsubtopic x
#lorem(50)
=== Subsubtopic y
#lorem(50)

#focus-slide[GRACIAS POR SU ATENCION!]
