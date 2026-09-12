#import "@preview/complete-unsaac:0.2.3": corolario, definicion, teorema

= Marco teórico conceptual

== Antecedentes
=== Antecedentes internacionales

#cite(<haquehua2025modelo>, form: "prose") desarrollaró el trabajo _''Modelo de inventarios aplicado
al control de almacén del centro de salud integral La Fuente del Cusco, 2024''_ en donde esta
plantilla fue realizada. Si deseas ver el trabajo de investigación subido, ingresa al siguiente link
#link("https://repositorio.unsaac.edu.pe/handle/20.500.12918/11440")

=== Antecedentes nacionales

Asimismo el trabajo de investigación puede utilizar la citación entre paréntesis de la siguiente
forma @haquehua2025modelo

=== Antecedentes locales

#lorem(70)

#lorem(3)

== Bases Teóricas <sec>

Asimismo en la plantilla se pueden incluir figuras, tablas y fórmulas, una recomendación es conocer
el entorno para integrar figuras y tablas. Los ejemplos se muestran a continuación:

Como se muestra en @img.

#block[
  #figure(
    image("images/img1.pdf", width: 13.5cm, height: 8cm),
    caption: [
      Conducta de inventario en el modelo clásico económica de pedido (EOQ)
    ],
  ) <img>
]
_ *Fuente:* @haquehua2025modelo _

Asimismo para colocar una tabla se usa el siguiente comando, la @tbl resume el análisis ABC.

#figure(
  kind: table,
  caption: [Resumen de actividades basadas en costos (ABC)],
  table(
    columns: (auto, auto, auto, auto),
    align: left,
    table.header(
      [*Grupo*],
      [*(%) de Costos*],
      [*(%) ocupación del inventario*],
      [*Usar técnicas cuantitativas*],
    ),
    [*A*], [$70%$], [$10%$], [Si],
    [*B*], [$20%$], [$20%$], [Los que tienen costos altos],
    [*C*], [$10%$], [$70%$], [No],
  ),
) <tbl>

Para insertar definiciones, teoremas y corolarios usamos el siguiente esquema

#definicion[
  Sea $bold(f): D -> RR^m$, donde $D subset RR^n$, entonces se dice que $bold(f(x))$ tiene un límite
  $bold(L) = (L_1, L_2, dots.h, L_m)$ donde $bold(x)$ se aproxima hacia $bold(a)$, descrito como
  $bold(x) -> bold(a)$, donde $bold(a)$ es un punto límite de $D$, si para cada $epsilon > 0$ existe
  un $delta > 0$ tal que $norm(bold(f(x)) - bold(L)) < epsilon$ para todos los $bold(x)$ en
  $D inter N_delta^d (bold(a))$ donde $N_delta^d (bold(a))$ es una vecindad de $bold(a)$ de radio
  $delta$. Descrito de la forma $lim_(bold(x) -> bold(a)) bold(f(x) = L)$.
] <def>

#teorema[
  Sea $f$ definida en un punto $x_0$. Si $f$ tiene una derivada en $x_0$, entonces es continuo en
  $x_0$
] <teo>

#corolario[Sea esto un corolario en $f$] <col>

Según @def, el límite de $bold(f(x))$ existe si para cada $epsilon > 0$ existe un $delta > 0$ tal
que la función se aproxima arbitrariamente a $bold(L)$. A partir de @teo, si $f$ es derivable en
$x_0$ entonces es continua en $x_0$, resultado que se complementa con @col. Los fundamentos
matemáticos necesarios para el análisis se desarrollan en la @sec.

Insertar ecuaciones

$ A = B + C $ <eq>

Como indica @eq, la variable $A$ puede expresarse como la suma de $B$ y $C$.

== Marco conceptual

#[
  #set par(first-line-indent: 0em)
  *Primer marco:* #lorem(10) @haquehua2025modelo

  *Segundo marco:* #lorem(10) @haquehua2025modelo
]
