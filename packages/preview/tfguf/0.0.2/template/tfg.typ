
#import "@preview/tfguf:0.0.2": *
//#import "../unirfisica.typ": *
#show: unirfisica.with(
  titulo: "Mi trabajo de fin de grado",
  logo: image("unir logo.png", width: 60%),
)

// Esto es para que la aplicación web reconozca el texto como en español y haga mejor detección de sintaxis.
#set text(lang: "es")

= Introducción
#lorem(120).trim(".") @xetex .

La distancia que separa dos torres en un tendido eléctrico en una vía de tren es
de #qty(60, "m"). Obtén el tiempo que emplea una cabeza locomotora en recorrer
dicha distancia si su velocidad es de #qty(72, "kilo meter per hour"). Expresa
dicho tiempo en el Sistema Internacional.
$ curl (grad f), tensor(T, -mu, +nu), pdv(f,x,y,[1,2]) $


= Estado del arte
El nombre de esta sección es opcional.

= Material y métodos

= Resultados y discusión

= Conclusiones

#bibliography("bibliografia.bib")
