// La función figura (borde y nota fáciles) está en funciones.typ.
#import "funciones.typ": figura

= Metodología <metodologia>

== Material

// Una tabla dentro de una figura: la plantilla le pone "Tabla 3.1" y la mete en
// la lista de tablas. table.header marca la fila de títulos.
#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, center),
    table.header[*Material*][*Características*][*Cantidad*],
    [Taza de cerámica], [Capacidad de 300 ml, paredes de 4 mm], [2],
    [Tapa de silicona], [Ajustada al borde de la taza], [1],
    [Termómetro digital], [Sonda de acero, precisión de ±0.1 °C], [1],
    [Cronómetro], [El del teléfono móvil], [1],
    [Café], [Recién hecho, unos 250 ml por taza], [500 ml],
  ),
  caption: [Material utilizado en el experimento],
) <tab-material>

Todo el material, salvo el termómetro, es el que hay en cualquier cocina (@tab-material).

== Montaje

La @fig-montaje muestra el montaje: la sonda del termómetro se introduce en el centro del café, a media altura, y se sujeta para que no toque las paredes de la taza.

// Una imagen con borde y nota. Las imágenes están en Archivos/Imágenes.
// borde: true o false; nota: opcional (bórrala si no la quieres).
#figura(
  "Imágenes/montaje.svg",
  titulo: [Montaje del experimento],
  ancho: 80%,
  borde: true,
  nota: [Elaboración propia.],
) <fig-montaje>

Para comparar, preparamos dos tazas iguales: una sin tapa y otra con tapa (@fig-tazas).

// Dos imágenes lado a lado: un grid de dos columnas dentro de una sola figura.
#figura(
  grid(
    columns: 2,
    gutter: 2em,
    image("Imágenes/taza-sin-tapa.svg", width: 4cm),
    image("Imágenes/taza-con-tapa.svg", width: 4cm),
    [_a)_ Sin tapa], [_b)_ Con tapa],
  ),
  titulo: [Las dos tazas del experimento],
) <fig-tazas>

== Procedimiento

+ Dejamos el material en la cocina una hora antes para que estuviera a temperatura ambiente, que fue de 22.0 °C durante todo el experimento.
+ Llenamos las dos tazas con 250 ml de café recién hecho cada una y tapamos una de ellas.
+ Cuando el termómetro marcó 85.0 °C en cada taza, pusimos en marcha el cronómetro.
+ Anotamos la temperatura cada 2 minutos durante 40 minutos en la hoja de registro del @anexo-registro.
+ Repetimos el experimento tres días distintos y comprobamos que los resultados eran parecidos; en este trabajo presentamos los del primer día.

== Tratamiento de los datos

Para cada medida calculamos $ln(T - T_a)$ y ajustamos una recta por mínimos cuadrados, como indica la ecuación @eq-lineal. La pendiente de la recta es $-k$, y el coeficiente de determinación $R^2$ indica lo bien que los datos se ajustan al modelo: cuanto más cerca de 1, mejor#footnote[Hicimos los cálculos con una hoja de cálculo. Las gráficas de este trabajo, en cambio, las dibuja Typst directamente a partir del fichero de datos.].
