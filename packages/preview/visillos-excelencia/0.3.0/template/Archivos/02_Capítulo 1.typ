// La etiqueta <marco-teorico> permite citar este capítulo con @marco-teorico.

= Marco teórico <marco-teorico>

== Calor y temperatura

La *temperatura* mide lo agitadas que están, de media, las partículas de un cuerpo. El *calor* es la energía que pasa de un cuerpo a otro cuando están a distinta temperatura, siempre del más caliente al más frío. Una taza de café caliente cede calor al aire de la cocina hasta que los dos quedan a la misma temperatura.

== Cómo pierde calor una taza de café

El café pierde calor por cuatro vías a la vez @vollmer2009:

// Lista de términos: "/ Término: explicación".
/ Conducción: a través de la cerámica de la taza y de la mesa.
/ Convección: el aire caliente que está en contacto con el café sube y lo sustituye aire más frío.
/ Radiación: todo cuerpo caliente emite radiación infrarroja.
/ Evaporación: las moléculas más rápidas escapan de la superficie y se llevan energía. Es la vía que una tapa reduce más.

== La ley de enfriamiento de Newton

Newton propuso que la rapidez con la que se enfría un cuerpo es proporcional a la diferencia entre su temperatura $T$ y la temperatura del ambiente $T_a$:

// Una ecuación en su propia línea: con espacios dentro de los $ $.
// La etiqueta <eq-newton> sirve para citarla con @eq-newton. La plantilla
// escribe solo el número, «(2.1)»: en el texto, pon delante «la ecuación».
$ (d T) / (d t) = -k (T - T_a) $ <eq-newton>

donde $k > 0$ es la *constante de enfriamiento*, que depende de la forma del recipiente, del material y de si está tapado. Resolviendo la ecuación diferencial @eq-newton (la deducción completa está en el @anexo-deduccion) se obtiene la temperatura en cada instante:

$ T(t) = T_a + (T_0 - T_a) e^(-k t) $ <eq-solucion>

siendo $T_0$ la temperatura inicial. Puede encontrarse una explicación divulgativa de estas fórmulas en @wikipedia-enfriamiento. Según la ecuación @eq-solucion, la diferencia de temperaturas $T - T_a$ disminuye de forma exponencial: el café se enfría deprisa al principio y cada vez más despacio.

=== Linealización

Para comprobar si unos datos siguen la ecuación @eq-solucion es cómodo tomar logaritmos neperianos. Despejando $T - T_a$ y aplicando $ln$ a los dos lados:

$ ln(T - T_a) = ln(T_0 - T_a) - k t $ <eq-lineal>

Es decir, si representamos $ln(T - T_a)$ frente al tiempo, los puntos deben quedar sobre una recta de pendiente $-k$. Así, una regresión lineal nos da directamente la constante de enfriamiento.

=== Tiempo de semienfriamiento

Llamamos *tiempo de semienfriamiento* $t_(1\/2)$ al tiempo que tarda en reducirse a la mitad la diferencia de temperatura con el ambiente. Imponiendo $T - T_a = (T_0 - T_a) \/ 2$ en la ecuación @eq-solucion:

$ t_(1\/2) = (ln 2) / k $ <eq-tiempo-medio>

No depende de la temperatura inicial: el café tarda lo mismo en pasar de 80 °C a 51 °C que de 51 °C a 36.5 °C (con un ambiente de 22 °C).
