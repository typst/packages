// Las gráficas usan el paquete lilaq. Se importa en el capítulo que lo usa.
#import "@preview/lilaq:0.6.0" as lq
#import "funciones.typ": figura

// Los datos se leen del fichero CSV: si cambias un dato allí, cambian a la vez
// la tabla del Anexo I y las dos gráficas de este capítulo.
#let datos = csv("Datos/enfriamiento.csv", row-type: dictionary)
#let tiempo = datos.map(f => float(f.tiempo))
#let sin-tapa = datos.map(f => float(f.sin_tapa))
#let con-tapa = datos.map(f => float(f.con_tapa))

// Valores del ajuste (ver la tabla de resultados) y temperatura ambiente
#let Ta = 22.0
#let k-sin = 0.0451
#let k-con = 0.0280
#let modelo(k) = t => Ta + (85.0 - Ta) * calc.exp(-k * t)

// Un color para cada taza: el mismo en los puntos y en su curva
#let azul = rgb("#3a7dc9")
#let naranja = rgb("#e08a1e")

= Resultados

== Medidas

La @tab-resumen recoge las temperaturas cada 10 minutos. Todas las medidas, cada 2 minutos, están en el @anexo-datos.

#figure(
  table(
    columns: 3,
    table.header[*Tiempo (min)*][*Sin tapa (°C)*][*Con tapa (°C)*],
    [0], [85.0], [85.0],
    [10], [61.8], [69.6],
    [20], [47.7], [57.9],
    [30], [38.1], [49.3],
    [40], [32.3], [42.6],
  ),
  caption: [Temperatura del café cada 10 minutos],
) <tab-resumen>

A los 40 minutos, el café de la taza tapada está 10.3 °C más caliente que el de la taza sin tapa.

== Curvas de enfriamiento

La @fig-curvas representa todas las medidas junto con la curva del modelo de Newton, ecuación @eq-solucion, para cada taza.

// figura también vale para gráficas y tablas: van en lugar de la ruta.
#figura(
  lq.diagram(
    width: 12cm,
    height: 7cm,
    xlabel: [Tiempo (min)],
    ylabel: [Temperatura (°C)],
    lq.plot(tiempo, sin-tapa, stroke: none, mark: "o", color: azul, label: [Sin tapa]),
    lq.plot(tiempo, con-tapa, stroke: none, mark: "s", color: naranja, label: [Con tapa]),
    lq.plot(lq.linspace(0, 40), modelo(k-sin), mark: none, color: azul),
    lq.plot(lq.linspace(0, 40), modelo(k-con), mark: none, color: naranja),
  ),
  titulo: [Temperatura del café frente al tiempo],
  nota: [Los puntos son las medidas y las líneas, el modelo de Newton con los valores de $k$ de la @tab-ajuste.],
) <fig-curvas>

== Ajuste al modelo

Si el enfriamiento sigue la ley de Newton, al representar $ln(T - T_a)$ frente al tiempo los puntos deben quedar alineados, como indica la ecuación @eq-lineal. La @fig-lineal muestra que es así en las dos tazas.

#figure(
  lq.diagram(
    width: 12cm,
    height: 6cm,
    xlabel: [Tiempo (min)],
    ylabel: $ln(T - T_a)$,
    lq.plot(tiempo, sin-tapa.map(T => calc.ln(T - Ta)), stroke: none, mark: "o", color: azul, label: [Sin tapa]),
    lq.plot(tiempo, con-tapa.map(T => calc.ln(T - Ta)), stroke: none, mark: "s", color: naranja, label: [Con tapa]),
  ),
  caption: [Linealización de las medidas],
) <fig-lineal>

Los resultados del ajuste por mínimos cuadrados están en la @tab-ajuste. El tiempo de semienfriamiento se calcula con la ecuación @eq-tiempo-medio.

#figura(
  table(
    columns: 3,
    table.header[][*Sin tapa*][*Con tapa*],
    [Constante de enfriamiento $k$ (min#super[−1])], [0.0451], [0.0280],
    [Coeficiente de determinación $R^2$], [0.9997], [0.9997],
    [Tiempo de semienfriamiento $t_(1\/2)$ (min)], [15.4], [24.7],
    [Tiempo hasta bajar de 60 °C (min)], [11.2], [18.0],
  ),
  titulo: [Resultados del ajuste al modelo de Newton],
  nota: [Ajuste por mínimos cuadrados de $ln(T - T_a)$ frente a $t$, con $T_a = 22.0$ °C.],
) <tab-ajuste>
