#import "@preview/classic-uni-thesis:0.1.0": flex-caption

= Resultados

Reporta aquí tus hallazgos, en un orden lógico, sin interpretarlos (guarda la
interpretación para la Discusión). Empieza por el resultado, luego señala la
figura o tabla que lo respalda. El método que produjo estos números se describió
en el capítulo anterior (@fig:method-overview).

== Resultado principal

Presenta primero el resultado principal. Cuando una figura lleve el mensaje,
refiérete a ella directamente (@fig:results-overview) y deja que la leyenda
aporte la información que el lector necesita para leerla.

#figure(
  image("../figures/placeholder.svg", width: 85%),
  caption: flex-caption(
    [El resultado principal. Reemplaza este ejemplo por el gráfico que mejor
     transmita tu hallazgo principal, y limita la leyenda al contexto que el
     lector necesita para interpretarlo — no a una repetición del texto del
     cuerpo.],
    [El resultado principal],
  ),
) <fig:results-overview>

Los resultados cuantitativos suelen ser más claros en una tabla. Reporta los
valores exactos en el cuerpo o en la tabla, y reserva la leyenda para
definiciones y contexto.

#figure(
  table(
    columns: (1fr, auto, auto, auto),
    align: (left, right, right, right),
    table.header([*Grupo*], [*n*], [*Media*], [*DE*]),
    [Grupo A], [128], [3.42], [0.51],
    [Grupo B], [131], [3.97], [0.48],
    [Grupo C], [119], [4.15], [0.55],
    [Combinado], [378], [3.85], [0.58],
  ),
  caption: flex-caption(
    [Estadísticas resumidas por grupo. *n* es el número de observaciones; *DE*
     es la desviación estándar.],
    [Estadísticas resumidas por grupo],
  ),
) <tab:summary>

== Hallazgos secundarios

Reporta cualquier resultado adicional que respalde o matice el resultado
principal. Señala los patrones que el lector debería llevar a la Discusión y
marca cualquier cosa inesperada. Los análisis adicionales o las tablas grandes
que interrumpirían el flujo van en el apéndice, no aquí.
