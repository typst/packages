#import "@preview/complete-unsaac:0.2.3": (
  doc-tesis, sty-tesis-anexos, sty-tesis-base, sty-tesis-post, sty-tesis-pre,
)

#import "contenido/metadata.typ": ep, facu, titulo, titulo-prof, titulo-prof-lbl

#show: doc-tesis.with(
  titulo: titulo,
  asesor: [Nombre completo Asesor],
  co-asesor: [Nombre completo Co-Asesor],
  autores: (
    "Nombre Completo Autor 1",
    "Nombre Completo Autor 2",
  ),
  titulo-documento: [PLANTILLA DE TESIS],
  facultad: facu,
  escuela: ep,
  titulo-academico: titulo-prof,
  // titulo-academico-label: [Para optar al Grado Académico de],
  // duplex: true,
  // binding-margin: 2%,
)

#show: sty-tesis-pre

#include "contenido/presentacion.typ"
#include "contenido/dedicatoria.typ"
#include "contenido/agradecimiento.typ"

= Índice
#outline(title: none)

= Índice de Tablas
#outline(title: none, target: figure.where(kind: table))

= Índice de Figuras
#outline(title: none, target: figure.where(kind: image))

/*
= Índice de Ecuaciones
#outline(title: none, target: math.equation.where(block: true))

= Índice de Teoremas
#outline(
  title: none,
  target: figure
    .where(kind: "definicion")
    .or(figure.where(kind: "teorema"))
    .or(figure.where(kind: "corolario")),
)
*/

#include "contenido/resumen.typ"
#include "contenido/abstract.typ"
#include "contenido/introduccion.typ"

#show: sty-tesis-base

#include "contenido/cap_1_planteamiento_problema.typ"
#include "contenido/cap_2_marco_teorico.typ"
#include "contenido/cap_3_hipotesis_variables.typ"
#include "contenido/cap_4_metodologia.typ"
#include "contenido/cap_5_resultados.typ"

#show: sty-tesis-post

#include "contenido/discusiones.typ"
#include "contenido/conclusiones.typ"
#include "contenido/recomendaciones.typ"

#bibliography(title: [Bibliografía], "contenido/bibliog.bib", style: "apa")

#show: sty-tesis-anexos

#include "contenido/anexo.typ"
