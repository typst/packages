#import "@preview/barcala:0.1.0": informe, nomenclatura, apendice

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

#nomenclatura(
  ($S_1$, [Símbolo 1]),
  ($S_2$, [Símbolo 2]),
  ($S_3$, [Símbolo 3]),
)

= Introducción
Coloque aquí la Introducción a su trabajo destacando el interés y los objetivos del mismo.

= Marco teórico
Si corresponde, describa aquí los fundamentos analíticos de su trabajo indicando las referencias consultadas para obtener la información en el formato adecuado.

= Metodología
Si corresponde, describa aquí la metodología empleada para desarrollar su trabajo. Recuerde mencionar y detallar dentro del texto principal todas las tablas y figuras incluidas en el documento.

= Resultados
Utilice esta sección para presentar y analizar sus resultados. Incluya preferetemente gráficos vectoriales para garantizar la calidad de las imágenes. Recuerde mencionar y explicar el contenido de todas las figuras en el cuerpo principal del trabajo.

= Conclusiones
Detalle aquí las conclusiones de su trabajo.

// Sección de apéndices. Si no se usa, se puede comentar o borrar
#show: apendice

= Apéndice
Si corresponde, utilice uno o más apéndices para complementar la información del trabajo.

// #bibliography("referencias.bib") en formato BibTeX
