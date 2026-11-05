// Cada "==" es un anexo: la plantilla lo numera solo (Anexo I, Anexo II…).
// Con una etiqueta, como <anexo-datos>, se cita con @anexo-datos.

= Anexos

== Tabla completa de medidas <anexo-datos>

// La tabla se construye a partir del fichero CSV: no hay que copiar los datos.
#let datos = csv("Datos/enfriamiento.csv", row-type: dictionary)

#figure(
  table(
    columns: 3,
    table.header[*Tiempo (min)*][*Sin tapa (°C)*][*Con tapa (°C)*],
    ..datos.map(f => (f.tiempo, f.sin_tapa, f.con_tapa)).flatten(),
  ),
  caption: [Temperatura del café cada 2 minutos],
) <tab-datos>

== Deducción de las fórmulas <anexo-deduccion>

Partimos de la ley de Newton, ecuación @eq-newton, y separamos las variables, pasando todo lo que depende de $T$ a la izquierda y lo que depende de $t$ a la derecha:

$ (d T) / (T - T_a) = -k thin d t $ <eq-separadas>

Integramos los dos miembros:

$ integral (d T) / (T - T_a) = integral -k thin d t quad arrow.double quad ln abs(T - T_a) = -k t + C $ <eq-integradas>

Como el café está más caliente que el ambiente, $T - T_a > 0$ y podemos quitar el valor absoluto. Tomando exponenciales:

$ T - T_a = e^C e^(-k t) $

En el instante inicial, $t = 0$ y $T = T_0$, así que $e^C = T_0 - T_a$, y se llega a la ecuación @eq-solucion. Por último, el tiempo de semienfriamiento se obtiene imponiendo que la diferencia de temperaturas se reduzca a la mitad:

$ (T_0 - T_a) / 2 = (T_0 - T_a) e^(-k t_(1\/2)) quad arrow.double quad t_(1\/2) = (ln 2) / k $

Las ecuaciones de este anexo se numeran con el número del anexo: ecuaciones @eq-separadas y @eq-integradas.

== Hoja de registro <anexo-registro>

Esta es la hoja que rellenamos durante cada medida. Las celdas vacías se completan a mano.

// Una tabla vacía para imprimir: las celdas [] quedan en blanco.
#figure(
  table(
    columns: (auto, 1fr, 1fr, 2fr),
    rows: 0.8cm,
    table.header[*Tiempo (min)*][*Sin tapa (°C)*][*Con tapa (°C)*][*Observaciones*],
    ..range(0, 42, step: 2).map(t => ([#t], [], [], [])).flatten(),
  ),
  caption: [Hoja de registro],
) <tab-registro>
