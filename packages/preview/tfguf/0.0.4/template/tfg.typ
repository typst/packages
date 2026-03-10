
#import "@preview/tfguf:0.0.4": *

#show: unirfisica.with(
  titulo: "Mi trabajo de fin de grado",
  agradecimientos: quote(attribution: "Yo", block: true)[_A mis padres_],
  abstract: lorem(138),
  resumen: lorem(138),
)

// Esto es para que la aplicación web reconozca el texto como en español y haga mejor detección de sintaxis.
#set text(lang: "es")

// Esto es el estilo de una tabla de ejemplo.
#show table.cell.where(y: 0): set text(weight: "bold")

= Introducción
#lorem(120).trim(".") @xetex .

La distancia que separa dos torres en un tendido eléctrico en una vía de tren es
de #qty(60, "m"). Obtén el tiempo que emplea una cabeza locomotora en recorrer
dicha distancia si su velocidad es de #qty(72, "kilo meter per hour"). Expresa
dicho tiempo en el Sistema Internacional.
$ curl (grad f), tensor(T, -mu, +nu), pdv(f, x, y, [1,2]) $ <eq:tensor>


Como se puede derivar desde la @eq:tensor…

= Estado del arte
El nombre de esta sección es opcional. #link("https://unir.net")[Aquí] tenemos un enlace y una nota al pie #footnote([Ejemplo de pie de página]).

= Material y métodos

= Resultados y discusión

Como podemos ver en la @tabla:ejemplo…


#figure(
  table(
    columns: 4,
    stroke: none,

    table.header[Test Item][Specification][Test Result][Compliance],
    [Voltage], [220V ± 5%], [218V], [Pass],
    [Current], [5A ± 0.5A], [4.2A], [Fail],
  ),
  caption: [Probe results for design A. Fuente: fuente de los datos.],
) <tabla:ejemplo>


#figure(
  kind: image,
  rect(
    [Los pies de figura o tabla deben de tener un punto final (de lo contrario no compila), ser de una única frase y para indicar la fuente tenéis que usar la notación de: `Título figura. Fuente: mi fuente.`. Las fuentes también pueden ser una referencia bibliográfica.],
  ),
  caption: [Una figura. Fuente: mi fuente.],
)
#figure(kind: image, [Contenido imagen 2], caption: [Hola imagen 2. Fuente: @docker.])
#import "@preview/mmdr:0.2.1": mermaid

#let mi-diagrama = mermaid("graph LR; A-->B;")
//#let mi-diagrama = rect(width: 35%, height: 30pt)

#figure(kind: image, mi-diagrama, caption: [Hola. Fuente: una fuente.])

== Una subsección
#lorem(100)

== Otra subsección
#lorem(100)

= Conclusiones

#bibliography("bibliografia.bib")
