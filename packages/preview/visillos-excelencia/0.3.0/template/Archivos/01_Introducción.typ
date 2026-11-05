// Un "=" es un capítulo; "==", un apartado; "===", un subapartado.
// La plantilla los numera y los mete en el índice sola.

= Introducción

Todos hemos dejado alguna vez una taza de café sobre la mesa y, al volver, nos lo hemos encontrado frío. ¿Cuánto tiempo tenemos antes de que eso pase? ¿Sirve de algo ponerle una tapa? Detrás de estas preguntas tan cotidianas hay una ley física sencilla y muy potente: la *ley de enfriamiento de Newton*.

Isaac Newton la propuso en 1701 en un breve artículo publicado de forma anónima#footnote[El artículo apareció sin firma en las _Philosophical Transactions_ de la Royal Society, pero hoy se atribuye a Newton sin discusión.] en el que describía cómo se enfrían los cuerpos calientes @newton1701. Más de tres siglos después, se sigue usando para modelizar desde el enfriamiento de los alimentos hasta la estimación de la hora de la muerte en medicina forense @zill2009.

// Así se cita la bibliografía: @etiqueta, con la etiqueta de referencias.yaml.
// Para citar varias fuentes a la vez, se ponen seguidas: @vollmer2009 @zill2009.

En este trabajo comprobamos experimentalmente si el café de una taza corriente sigue esta ley, y medimos cuánto cambia el enfriamiento cuando la taza está tapada.

== Objetivos

// Lista numerada: cada elemento empieza por "+".
El objetivo general es *comprobar si el enfriamiento de una taza de café sigue la ley de Newton*. Para ello nos planteamos estos objetivos específicos:

+ Medir la temperatura del café a lo largo del tiempo con un método sencillo y repetible.
+ Ajustar los datos a un modelo exponencial y calcular la constante de enfriamiento.
+ Comparar una taza con tapa y otra sin tapa.
+ Responder a la pregunta inicial: ¿cuánto tarda el café en dejar de estar «caliente»?

== Hipótesis

// Un recuadro de color con las herramientas de Typst, sin paquetes.
#block(
  fill: rgb("#e8f6f3"),
  stroke: (left: 3pt + rgb("#279985")),
  inset: 12pt,
  width: 100%,
)[
  *Hipótesis.* La temperatura del café se acerca a la del ambiente de forma exponencial, y la taza tapada se enfría más despacio porque pierde menos calor por evaporación.
]

== Estructura del trabajo

// Lista de viñetas: cada elemento empieza por "-". Con sangría se anidan.
El trabajo se organiza así:

- El @marco-teorico[capítulo] explica la física y las matemáticas del enfriamiento.
- El @metodologia[capítulo] describe el material y el procedimiento.
- Los capítulos de resultados y discusión presentan y analizan las medidas:
  - primero, los datos y sus gráficas;
  - después, su interpretación y sus limitaciones.
- Los anexos recogen los datos completos (@anexo-datos), la deducción de las fórmulas (@anexo-deduccion) y la hoja de registro que usamos (@anexo-registro).
