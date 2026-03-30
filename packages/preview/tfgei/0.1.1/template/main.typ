#import "@preview/tfgei:0.1.1": *

#show: tfgei.with(
  titulo: "Título do Traballo de Fin de Grado",
  alumno: "D. Nome Alumna/o",
  agradecimientos: quote(attribution: "Yo", block: true)[_A mis padres_],
  resumen: lorem(138),
  idioma: "gl",
  salto-capitulo: true,
  indice-figuras: (enabled: true),
  indice-tablas: (enabled: true),
  indice-listados: (enabled: true),
)

// Esto es para que la aplicación web reconozca el texto como en español y haga mejor detección de sintaxis.
#set text(lang: "es")

= Introducción
#lorem(120).trim(".") @xetex .

La distancia que separa dos torres en un tendido eléctrico en una vía de tren es
de #qty(60, "m"). Obtén el tiempo que emplea una cabeza locomotora en recorrer
dicha distancia si su velocidad es de #qty(72, "kilo meter per hour"). Expresa
dicho tiempo en el Sistema Internacional.
$ curl (grad f), tensor(T, -mu, +nu), pdv(f, x, y, [1,2]) $


= Estado del arte
El nombre de esta sección es opcional. #link("https://www.uvigo.gal/")[Aquí] tenemos un enlace. #link("https://www.uvigo.gal/")

= Material y métodos

== Materiales

= Resultados y discusión

== Ejemplo de figura

#figure(
  rect(
    width: 85%,
    height: 4cm,
    fill: luma(240),
    stroke: 0.6pt + luma(140),
    radius: 4pt,
  ),
  kind: image,
  caption: [Esquema simplificado del sistema de medida.],
)

== Ejemplo de tabla

#figure(
  table(
    columns: 3,
    align: center + horizon,
    table.header([
      Magnitud
    ], [Valor], [Unidad]),
    [Longitud], [60], [m],
    [Velocidad], [72], [km/h],
    [Tiempo], [3000], [s],
  ),
  caption: [Resumen de magnitudes del problema.],
)

== Ejemplo de listado

#figure(
  raw(
    block: true,
    lang: "typ",
    "#let v = qty(72, \"kilo meter per hour\")\n#let d = qty(60, \"m\")\n#let t = d / v\n#t",
  ),
  kind: raw,
  caption: [Cálculo de tiempo en Typst con unidades.],
)

= Conclusiones

#bibliography("bibliografia.bib")
