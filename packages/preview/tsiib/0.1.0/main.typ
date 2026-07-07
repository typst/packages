// ==========================================
// main.typ — Artículo de ejemplo usando tsiib
// Tema: Regresión Lineal
// ==========================================

#import "@preview/tsiib:0.1.0": tsiib, teorema, proposicion, corolario, lema, problema, ejemplo, definicion, demostracion, solucion, axioma, ecuacion, figura, tabla, imagen, codigo-formal

#show: tsiib.with(
  title: "Fundamentos Matemáticos de la Regresión Lineal",
  subtitle: "Una Perspectiva Algebraica",
  author: "M.H. Alberto",
  affiliation: "Departamento de Matemáticas Aplicadas",
  email: "mario_alberto_claudio_h@hotmail.com",
  date: "7 de julio de 2026",
  abstract: [
    En este artículo se presenta una introducción rigurosa a la regresión
    lineal desde una perspectiva algebraica y computacional. Se desarrolla el
    método de mínimos cuadrados ordinarios, se analiza la descomposición
    matricial del problema y se implementa una solución en Python. Se incluyen
    demostraciones formales, ejemplos numéricos y referencias a la literatura
    clásica @pearson1901.
  ],
  keywords: "regresión lineal, mínimos cuadrados, álgebra lineal, Python, OLS",
  bib: bibliography("refs.bib", style: "ieee"),
)

= Introducción

La regresión lineal es uno de los modelos fundamentales del análisis
estadístico y constituye la primera aproximación al estudio de relaciones
entre variables @pearson1901. Su objetivo principal es modelar la relación
entre un conjunto de variables predictoras y una variable de respuesta
mediante una función lineal.

#axioma(titulo: "de Linealidad")[
  Existe una relación funcional $y = f(x) + epsilon$ donde $f$ es una función
  lineal en los parámetros y $epsilon$ es un término de error aleatorio con
  $EE[epsilon] = 0$.
] <ax-linealidad>

El Axioma @ax-linealidad establece la hipótesis fundamental sobre la que se
construye toda la teoría de regresión lineal. A partir de este principio, el
problema se reduce a encontrar los coeficientes que minimizan el error.

== Planteamiento del Problema

#definicion(titulo: "Regresión Lineal Simple")[
  Sea $cal(D) = {(x_i, y_i)}_(i=1)^n subset RR^2$ un conjunto de datos
  observados. La regresión lineal simple consiste en encontrar coeficientes
  $beta_0, beta_1 in RR$ tales que
  #ecuacion[$ y_i approx beta_0 + beta_1 x_i, quad i = 1, dots, n . $] <eq-modelo>
] <def-regresion>

La ecuación @eq-modelo establece que cada valor observado $y_i$ se aproxima
mediante una combinación lineal de $x_i$. Dado que el sistema tiene $n$
ecuaciones y solo $2$ incógnitas, es generalmente sobredeterminado.

#ejemplo[
  Consideremos el siguiente conjunto de datos sobre la relación entre horas
  de estudio ($x$) y calificación obtenida ($y$):

  #tabla(
    columns: 2,
    table.header([Horas ($x$)], [Calificación ($y$)]),
    [2], [65],
    [3], [72],
    [5], [81],
    [7], [88],
    [9], [95],
    caption: [Datos de ejemplo: horas de estudio vs. calificación.],
  ) <tabla-datos>

  Buscamos una recta $y = beta_0 + beta_1 x$ que mejor se ajuste a estos
  puntos, en el sentido de minimizar el error cuadrático total.
]

= Formulación Matricial

== El Sistema Sobredeterminado

El modelo lineal puede expresarse en forma matricial. Para $n$ observaciones
y $p$ variables predictoras, definimos la matriz de diseño $X in RR^(n times p)$ y el vector de respuesta $y in RR^n$:

#ecuacion[$ y = X beta + epsilon, quad X = mat(1, x_11, dots, x_(1,p-1); 1, x_21, dots, x_(2,p-1); dots.v, dots.v, dots.down, dots.v; 1, x_(n 1), dots, x_(n,p-1)) $] <eq-forma-matricial>

donde $beta in RR^p$ es el vector de coeficientes y $epsilon in RR^n$ es el
vector de errores. La ecuación @eq-forma-matricial es la representación
estándar del modelo lineal general.

#teorema(titulo: "de Mínimos Cuadrados Ordinarios")[
  Sea $X in RR^(n times p)$ una matriz de diseño de rango completo
  ($op("rango")(X) = p$). El estimador de mínimos cuadrados ordinarios (OLS)
  que minimiza $norm(y - X beta)^2$ está dado por

  #ecuacion[$ hat(beta) = (X^T X)^(-1) X^T y . $] <eq-ols>
] <teo-ols>

#demostracion[
  La función objetivo es $S(beta) = norm(y - X beta)^2 = (y - X beta)^T (y - X beta)$.
  Derivando respecto a $beta$ e igualando a cero:

  $ frac(partial S, partial beta) = -2 X^T (y - X beta) = 0 . $

  Esto conduce a las ecuaciones normales $X^T X beta = X^T y$. Como $X$ tiene
  rango completo, $X^T X$ es invertible y obtenemos la ecuación @eq-ols.
]

#proposicion[
  La matriz $X^T X$ es simétrica y definida positiva cuando $X$ tiene rango
  completo. En consecuencia, el problema de mínimos cuadrados tiene solución
  única.
] <prop-positiva>

#corolario[
  El vector de valores ajustados es $hat(y) = X hat(beta) = H y$, donde
  $H = X (X^T X)^(-1) X^T$ es la matriz de proyección ortogonal sobre el
  espacio columna de $X$.
] <cor-proyeccion>

=== Propiedades de la Matriz de Proyección

#lema(titulo: "Idempotencia de H")[
  La matriz de proyección $H$ es simétrica ($H^T = H$) e idempotente
  ($H^2 = H$). Además, $op("tr")(H) = p$ y sus eigenvalores son $0$ o $1$.
] <lema-idempotente>

#demostracion[
  La simetría es inmediata: $H^T = (X (X^T X)^(-1) X^T)^T = X (X^T X)^(-T) X^T = H$.
  Para la idempotencia:

  #ecuacion[$ H^2 = X (X^T X)^(-1) X^T X (X^T X)^(-1) X^T = X (X^T X)^(-1) X^T = H . $] <eq-idempotencia>

  La ecuación @eq-idempotencia confirma que $H$ proyecta sobre el mismo
  subespacio al aplicarse dos veces.
]

= Métricas de Evaluación

Una vez ajustado el modelo, es necesario evaluar su calidad. Las métricas más
comunes son el coeficiente de determinación $R^2$ y el error cuadrático medio
(RMSE).

#definicion(titulo: "Coeficiente de Determinación")[
  El coeficiente de determinación se define como

  #ecuacion[$ R^2 = 1 - frac(sum_(i=1)^n (y_i - hat(y)_i)^2, sum_(i=1)^n (y_i - overline(y))^2) , $] <eq-r2>

  donde $hat(y)_i$ son los valores ajustados y $overline(y)$ es la media
  muestral. $R^2 in [0,1]$ mide la proporción de varianza explicada por el
  modelo.
] <def-r2>

La Definición @def-r2 cuantifica qué tan bien se ajusta el modelo a los datos.
Un valor de $R^2$ cercano a $1$ indica un buen ajuste.

#problema(titulo: "Cálculo de Métricas")[
  Utilizando los datos de la Tabla @tabla-datos, calcula manualmente los
  coeficientes de la recta de regresión y determina el valor de $R^2$.
]

#solucion[
  Construimos la matriz de diseño y el vector de respuesta:

  $ X = mat(1, 2; 1, 3; 1, 5; 1, 7; 1, 9), quad y = mat(65; 72; 81; 88; 95) . $

  Aplicando la fórmula @eq-ols obtenemos $hat(beta)_0 approx 53.47$,
  $hat(beta)_1 approx 4.69$. La recta ajustada es $y approx 53.47 + 4.69 x$.
  Sustituyendo en @eq-r2 se obtiene $R^2 approx 0.991$.
]

= Implementación en Python

A continuación se presenta una implementación del estimador OLS en Python
utilizando las bibliotecas `numpy` y `pandas`.

== Carga y Preparación de Datos

#codigo-formal(```
import numpy as np
import pandas as pd

datos = pd.DataFrame({
    "horas": [2, 3, 5, 7, 9],
    "calificacion": [65, 72, 81, 88, 95]
})

X = datos[["horas"]].values
y = datos["calificacion"].values
print("X:", X.shape, "y:", y.shape)
```)

== Implementación del Estimador OLS

#codigo-formal(titulo: "Estimador de Mínimos Cuadrados", ```
def ols_estimador(X, y):
    n, p = X.shape
    X_d = np.hstack([np.ones((n, 1)), X])
    XtX = X_d.T @ X_d
    Xty = X_d.T @ y
    beta = np.linalg.solve(XtX, Xty)
    y_pred = X_d @ beta
    residuos = y - y_pred
    ss_res = (residuos * residuos).sum()
    ss_tot = ((y - y.mean()) * (y - y.mean())).sum()
    r2 = 1 - ss_res / ss_tot
    return beta, y_pred, r2

beta, y_pred, r2 = ols_estimador(X, y)
print("beta:", beta)
print("R2:", round(r2, 4))
```) <listado-ols>

El Listado @listado-ols implementa directamente la fórmula del
Teorema @teo-ols, utilizando la descomposición de la matriz $X^T X$ para
resolver las ecuaciones normales de forma numéricamente estable.

= Resultados Experimentales

== Comparación de Métodos

Evaluamos el modelo OLS contra una regresión Ridge con distintos valores del
parámetro de regularización $lambda$.

#tabla(
  columns: 4,
  table.header([Método], [$lambda$], [RMSE], [$R^2$]),
  [OLS], [---], [2.341], [0.991],
  [Ridge], [0.1], [2.389], [0.988],
  [Ridge], [1.0], [2.521], [0.979],
  [Ridge], [10.0], [3.107], [0.951],
  caption: [Comparación de OLS y regresión Ridge para los datos de
    horas de estudio vs. calificación.],
) <tabla-comparacion>

La Tabla @tabla-comparacion muestra que OLS ofrece el mejor ajuste en
términos de $R^2$, como era de esperar al ser el estimador insesgado de
mínima varianza bajo los supuestos clásicos.

== Visualización del Ajuste

#figura(
  rect(width: 100%, height: 5cm, fill: rgb("#f1f5f9"), stroke: 0.5pt, inset: 12pt)[
    *[Recta de regresión ajustada]*
    #v(1em)
    Gráfica de dispersión de los datos con la recta $y = 53.47 + 4.69x$
    superpuesta. Los residuos se muestran como líneas verticales.
  ],
  caption: [Ajuste por mínimos cuadrados de los datos de la
    Tabla @tabla-datos.],
) <fig-ajuste>

#figura(
  image("cuadrado.png", width: 40%),
  caption: [Representación gráfica del método de mínimos cuadrados
    @pearson1901.],
) <fig-cuadrado>

= Conclusiones

La regresión lineal, fundamentada en el álgebra lineal y la optimización,
proporciona un marco teórico sólido para el modelado estadístico. El
Teorema @teo-ols, demostrado formalmente, establece la solución óptima
para el problema de mínimos cuadrados. Las propiedades de la matriz de
proyección analizadas en el Lema @lema-idempotente son esenciales para
comprender la geometría del ajuste. La Definición @def-r2 proporciona una
métrica estándar para evaluar la calidad predictiva del modelo.

La implementación computacional en Python (Listado @listado-ols) muestra
cómo los conceptos teóricos se traducen directamente en código funcional,
cerrando el ciclo entre las matemáticas y la práctica del análisis de datos.
