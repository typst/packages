#import "@preview/barcala:0.1.2": informe, nomenclatura, apendice
#import "@preview/fancy-units:0.1.1": unit, fancy-units-configure // Paquete para unidades de medida, puede ser omitido
#import "@preview/lilaq:0.2.0" as lq // Paquete para gráficos, puede ser omitido
#import "@preview/physica:0.9.5": * // Paquete para matemática y física, puede ser omitido

#show: informe.with(
  unidad-academica: "ingeniería",
  asignatura: "F0317 Física II",
  titulo: "Informe de Laboratorio Nº 2",
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

  titulo-descriptivo: "Circuitos de corriente continua en estado transistorio",
  resumen: [*_Objetivo_ --- determinación de las constantes de tiempo ($tau$) de carga y descarga de un circuito RC. Análisis de la dependencia de $tau$ en función de los valores de resistencia y capacidad que conforman el circuito.*],

  fecha: "2025-03-01",
)

// Configuración de `fancy-units`
#fancy-units-configure(
  per-mode: "slash",
  unit-separator: sym.comma,
)

// Bloques de matemática con números para citar
#set math.equation(numbering: "(1)")

#nomenclatura(
  ($q$, [Carga [#unit[C]]]),
  ($I$, [Corriente [#unit[A]]]),
  ($U$, [Potencial eléctrico [#unit[V]]]),
  ($va(E)$, [Campo eléctrico [#unit[V/m]]]),
  ($va(B)$, [Campo magnético [#unit[T]]]),
)

= Introducción
Coloque aquí la Introducción a su trabajo destacando el interés y los objetivos del mismo.

= Marco teórico
Si corresponde, describa aquí los fundamentos analíticos de su trabajo indicando las referencias consultadas para obtener la información en el formato adecuado. Por ejemplo, @griffiths_electrodynamics_2017, @jackson_classical_1999[p.~12], @maxwell_dynamical_1865.

También se puede agregar ecuaciones matemáticas, como

$
  integral.cont_(partial S) va(B) dot dd(va(l)) = mu_0 integral.double_S va(J) dot dd(va(A)).
$ <ley-de-ampere>

Estas se pueden citar como @ley-de-ampere.

= Metodología
Si corresponde, describa aquí la metodología empleada para desarrollar su trabajo. Recuerde mencionar y detallar dentro del texto principal todas las tablas y figuras incluidas en el documento.

= Resultados
Utilice esta sección para presentar y analizar sus resultados. Incluya preferetemente gráficos vectoriales para garantizar la calidad de las imágenes. Recuerde mencionar y explicar el contenido de todas las figuras en el cuerpo principal del trabajo.

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
)

= Conclusiones
Detalle aquí las conclusiones de su trabajo.

// Sección de apéndices. Si no se usa, se puede comentar o borrar
#show: apendice

= Apéndice
Si corresponde, utilice uno o más apéndices para complementar la información del trabajo.

#bibliography("bibliografia.bib")
