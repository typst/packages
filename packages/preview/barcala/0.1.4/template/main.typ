#import "@preview/barcala:0.1.4": apendice, informe, nomenclatura
#import "@preview/lilaq:0.4.0" as lq // Paquete para gráficos, puede ser omitido
#import "@preview/physica:0.9.5": * // Paquete para matemática y física, puede ser omitido
#import "@preview/zero:0.5.0" // Paquete para números lindos y unidades de medida, puede ser omitido

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

// Bloques de matemática con números para citar
#set math.equation(numbering: "(1)")

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
Utilice esta sección para presentar y analizar sus resultados. Incluya preferentemente gráficos vectoriales para garantizar la calidad de las imágenes. Recuerde mencionar y explicar el contenido de todas las figuras en el cuerpo principal del trabajo.

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
