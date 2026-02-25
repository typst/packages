#import "@preview/barcala:0.3.0": apendice, informe, nomenclatura
#import "@preview/lilaq:0.5.0" as lq // Paquete para gráficos, puede ser omitido
#import "@preview/physica:0.9.7": * // Paquete para matemática y física, puede ser omitido
#import "@preview/zero:0.5.0" // Paquete para números lindos y unidades de medida, puede ser omitido

#show: informe.with(
  unidad-academica: "ingeniería",
  asignatura: "F0317 Física II",
  trabajo: "Informe de Laboratorio Nº 2",
  equipo: "Grupo 3",
  autores: (
    (
      nombre: "Kirchhoff, Gustav",
      email: "gustav.kirchhoff@alu.ing.unlp.edu.ar",
      legajo: "12345/6",
      notas: "Autor responsable del informe",
    ),
    (
      nombre: "Maxwell, James C.",
      email: "james.maxwll@alu.ing.unlp.edu.ar",
      legajo: "12345/6",
    ),
    (
      nombre: "Faraday, Michael",
      email: "mfaraday@alu.ing.unlp.edu.ar",
      legajo: "12345/6",
    ),
  ),

  titulo: [Circuitos de corriente continua en estado transistorio],
  resumen: [*_Objetivo_ --- determinación de las constantes de tiempo ($tau$) de carga y descarga de un circuito RC. Análisis de la dependencia de $tau$ en función de los valores de resistencia y capacidad que conforman el circuito.*],

  fecha: "2025-03-01",
)

// Enlaces de colores
#show cite: set text(blue)
#show link: set text(blue)
#show ref: set text(blue)

// Bloques de matemática con números para citar
#set math.equation(numbering: "(1)")
#show ref: it => {
  if it.element != none and it.element.func() == math.equation {
    // Sobreescribir las referencias a ecuaciones
    link(it.element.location(), numbering(
      it.element.numbering,
      ..counter(math.equation).at(it.element.location()),
    ))
  } else {
    // Otras referencias quedan igual
    it
  }
}

// Configuración de `zero`
#import zero: num, zi
#zero.set-num(
  decimal-separator: ",",
)
#zero.set-group(
  size: 3,
  separator: ".",
  threshold: (integer: 5, fractional: calc.inf),
)
#zero.set-unit(
  fraction: "inline",
)

// Unidades
#let Vm = zi.declare("V/m")

#nomenclatura(
  ($q$, [Carga [#zi.coulomb()]]),
  ($I$, [Corriente [#zi.ampere()]]),
  ($U$, [Potencial eléctrico [#zi.volt()]]),
  ($va(E)$, [Campo eléctrico [#Vm()]]),
  ($va(B)$, [Campo magnético [#zi.tesla()]]),
)

= Introducción
Coloque aquí la introducción a su trabajo destacando el interés y los objetivos del mismo.

= Marco teórico
Si corresponde, describa aquí los fundamentos analíticos de su trabajo indicando las referencias consultadas para obtener la información en el formato adecuado. Por ejemplo, @griffiths_electrodynamics_2017, @jackson_classical_1999[p.~12], @maxwell_dynamical_1865.

También se puede agregar ecuaciones matemáticas, como

$
  integral.cont_(partial S) va(B) dot dd(va(l)) = mu_0 integral.double_S va(J) dot dd(va(A)).
$ <ley-de-ampere>

Estas se pueden citar como @ley-de-ampere. Los números y unidades pueden ser escritos con `zero`. Un número se puede escribir como #num[12345.6789] y una unidad como #zi.volt() o #zi.newton(). Se pueden declar unidades personalizadas como #Vm() e incluso combinar con una magnitud como #zi.ohm[220].

= Metodología
Si corresponde, describa aquí la metodología empleada para desarrollar su trabajo. Recuerde mencionar y detallar dentro del texto principal todas las tablas y figuras incluidas en el documento.

= Resultados
Utilice esta sección para presentar y analizar sus resultados. Incluya preferentemente gráficos vectoriales para garantizar la calidad de las imágenes. Recuerde mencionar y explicar el contenido de todas las figuras en el cuerpo principal del trabajo, como @fig-boxplot.

#figure(
  lq.diagram(
    lq.boxplot(
      (1, 3, 10),
      stroke: luma(30%),
      fill: yellow,
      median: red,
    ),
    lq.boxplot(
      (1.5, 3, 9),
      x: 2,
      whisker: blue,
      cap: red,
      cap-length: 0.7,
      median: green,
    ),
    lq.boxplot(
      lq.linspace(5.3, 6.2) + (2, 3, 7, 9.5),
      x: 3,
      outliers: "x",
    ),
    lq.boxplot(
      lq.linspace(5.3, 6.2) + (2, 3, 7, 9.5),
      x: 4,
      outliers: none,
    ),
  ),
  caption: [Boxplot genérico.],
) <fig-boxplot>

Además, se pueden incluir tablas como @tabla-ejemplo. Se pueden crear tablas muy complejas, se recomienda leer #link("https://typst.app/docs/guides/tables/"). Además, el paquete #link("https://typst.app/universe/package/zero")[`zero`] permite alinear números y unidades dentro de las tablas de forma sencilla.

#figure(caption: [Mediciones realizadas.], {
  show: zero.format-table(none, auto)
  table(
    columns: 2,
    align: center + horizon,
    stroke: none,
    table.hline(),
    table.header[][Corriente [#zi.mA()]],
    table.hline(),
    $I_1$, [27.0+-0.6],
    $I_2$, [18.7+-0.4],
    $I_3$, [7.4+-0.2],
    $I_5$, [22+-1],
    table.hline(),
  )
}) <tabla-ejemplo>

También se puede complementar el trabajo con notas al pié de página.#footnote[#lorem(10)]

= Conclusiones
Detalle aquí las conclusiones de su trabajo.

// Sección de apéndices. Si no se usa, se puede comentar o borrar
#show: apendice

= Apéndice
Si corresponde, utilice uno o más apéndices para complementar la información del trabajo.

#bibliography("bibliografia.bib")
