
#import "@preview/tfguf:0.0.4": *
#let longitud-abstract = 150
#show: unirfisica.with(
  titulo: "Mi trabajo de fin de grado",
  alumno: ("Alumno 1", "Alumno 2", "Alumno 3"),
  director: "Director 1 y Director 2",
  agradecimientos: quote(attribution: "Yo", block: true)[_A mis padres_],
  abstract: lorem(longitud-abstract),
  resumen: lorem(longitud-abstract),
  pclave: ("Una", "Dos", "Otra"),
  kwords: ("Some", "Key", "Words"),
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
  caption: caption[Hola imagen 3][https://typst.app],
) <tabla:ejemplo>

#lorem(10)


#figure(
  kind: image,
  rect(
    height: 3cm,
    [Los pies de figura o tabla deben de tener un punto final (de lo contrario no compila), ser de una única frase y para indicar la fuente tenéis que usar la notación de: `Título figura. Fuente: mi fuente.`. Las fuentes también pueden ser una referencia bibliográfica.],
  ),
  caption: caption[Hola.][una fuente],
)
#lorem(10)
#figure(kind: image, [Contenido imagen 2], caption: caption[Hola.][@docker])
#import "@preview/mmdr:0.2.1": mermaid
#lorem(10)
#let mi-diagrama = mermaid("graph LR; A-->B;")
//#let mi-diagrama = rect(width: 35%, height: 30pt)

#figure(kind: image, mi-diagrama, caption: caption[Hola.][una fuente])

#let cdu(name) = ([CDU], table.cell(fill: black, text(fill: white, name)))
#let spd(name) = ([SPD], table.cell(fill: red, text(fill: white, name)))
#let fdp(name) = ([FDP], table.cell(fill: yellow, name))

Veamos la @tab:datos

#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: (x: none),

    table.header[Tenure][Party][President],
    [1949-1959], ..fdp[Theodor Heuss],
    [1959-1969], ..cdu[Heinrich Lübke],
    [1969-1974], ..spd[Gustav Heinemann],
    [1974-1979], ..fdp[Walter Scheel],
    [1979-1984], ..cdu[Karl Carstens],
    [1984-1994], ..cdu[Richard von Weizsäcker],
    [1994-1999], ..cdu[Roman Herzog],
    [1999-2004], ..spd[Johannes Rau],
    [2004-2010], ..cdu[Horst Köhler],
    [2010-2012], ..cdu[Christian Wulff],
    [2012-2017], [n/a], [Joachim Gauck],
    [2017-], ..spd[Frank-Walter-Steinmeier],
  ),
  caption: caption[Probe results for design A.][fuente de los datos.],
) <tab:datos>

#lorem(10)

#import "@preview/tablem:0.3.0": tablem, three-line-table

#show table.cell: set par(leading: 0.3cm)
#figure(
  three-line-table[
    | System   | Category                        | Compilation model | Unicode support  | Font handling            |
    | -------- | ------------------------------- | ----------------- | ---------------- | ------------------------ |
    | TeX      | Typesetting engine              | DVI → PDF         | Limited          | METAFONT                 |
    | pdfTeX   | TeX engine                      | Direct PDF        | Partial          | Type1 / limited OpenType |
    | XeTeX    | TeX engine                      | Direct PDF        | Full             | OpenType / system fonts  |
    | LuaTeX   | TeX engine                      | Direct PDF        | Full             | OpenType                 |
    | LaTeX    | Macro system                    | Engine-dependent  | Engine-dependent | Engine-dependent         |
    | ConTeXt  | TeX macro system                | Engine-dependent  | Full (LuaTeX)    | OpenType                 |
    | Typst    | Markup typesetting system       | Direct PDF        | Full             | Modern font system       |
    | Pandoc   | Document converter              | Multi-format      | Full             | Delegated to backend     |
    | Quarto   | Scientific publishing framework | Multi-format      | Full             | Delegated to backend     |
    | LyX      | Visual LaTeX editor             | LaTeX backend     | Engine-dependent | Engine-dependent         |
    | Overleaf | Collaborative platform          | LaTeX backend     | Engine-dependent | Engine-dependent         |
    | Typst    | Markup typesetting system       | Direct PDF        | Full             | Modern font system       |
    | Pandoc   | Document converter              | Multi-format      | Full             | Delegated to backend     |
  ],
  caption: caption[Comparative overview of major scientific document composition systems.][Yo mismico.],
)



== Una subsección

#lorem(100) asdasdfdf

#link("http://apple.com")[apple]

#link("http://apple.com") apple

== Otra subsección
#lorem(100)

= Conclusiones

#bibliography("bibliografia.bib")

#show: anejos

= Encuentas realizadas
sadasdasdsdasdfasasd

