= Introducción

Esta es la introducción. Reemplaza este texto de ejemplo por el tuyo, pero
mantén la estructura como guía: abre con el contexto general, acota al problema
específico que aborda tu tesis y termina con una declaración clara de tus
objetivos. Los párrafos siguientes existen solo para mostrar cómo se renderizan
el texto del cuerpo, las citas, las referencias cruzadas y las citas en bloque
en esta plantilla.

La introducción sitúa el tema y motiva el trabajo. Indica lo que se sabe, cita
las fuentes que lo establecen @smith2020 @jones2019 y luego identifica el vacío
que tu tesis llena. Las citas usan el estilo autor–año (APA) y se renderizan en
negro, igual que el texto que las rodea, para que la página impresa se mantenga
limpia; siguen siendo clicables en el PDF. Una cita individual se ve así
@garcia2021, y un grupo entre paréntesis se ve así
@smith2020 @mueller2018.

== Antecedentes

Usa encabezados de nivel dos para las secciones principales dentro de un
capítulo, y encabezados de nivel tres para las subsecciones debajo de ellas.
Cada encabezado se numera automáticamente (puedes desactivar la numeración con
`heading-numbering: false` en `main.typ`) y aparece en la tabla de contenidos.

Los párrafos del cuerpo están justificados con una altura de línea cómoda. El
énfasis viene en dos formas: *negrita* para énfasis fuerte y _cursiva_ para
términos y títulos. El código en línea, como el nombre de una variable
`threshold` o un comando corto, se coloca en una caja ligeramente sombreada.

== Objetivos

Declara con claridad el objetivo central de la tesis. A menudo ayuda aislar la
hipótesis central o la pregunta de investigación como una cita en bloque, que
esta plantilla renderiza con una regla a la izquierda en cursiva:

#quote(block: true)[
  La hipótesis central de esta tesis es que una pregunta de investigación
  claramente planteada, separada del texto que la rodea, es más fácil de
  encontrar y de retener en la mente para un lector (y un evaluador).
]

A partir de ese objetivo, deriva una lista corta de objetivos concretos:

+ Establecer el problema y revisar la literatura relevante.
+ Describir los datos y el método usado para abordar el problema.
+ Presentar los resultados e interpretarlos.
+ Discutir las implicaciones, limitaciones y posibles extensiones.

== Estructura de la tesis

Cierra la introducción con un breve mapa de ruta. El capítulo de Metodología
describe los materiales y el procedimiento (y muestra cómo se ven las figuras y
las tablas — véase @fig:method-overview y @tab:parameters). El capítulo de
Resultados reporta los hallazgos, y el capítulo de Discusión los interpreta y
concluye.
