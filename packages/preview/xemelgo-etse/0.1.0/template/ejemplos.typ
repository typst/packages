#import "@preview/xemelgo-etse:0.1.0": short-title

// Examples chapter shared by the three models (remove it in the final version)

= Ejemplos (eliminar capítulo en la versión final) #short-title[Ejemplos] <ejemplos>

== Un ejemplo de sección

Esta es _letra cursiva_, esta es *letra negrita*, esta es #underline[letra subrayada], y esta es
`letra courier`. Letra #text(size: 6pt)[tiny], #text(size: 8pt)[scriptsize], #text(size: 11pt)[small],
#text(size: 14pt)[large], #text(size: 17pt)[Large], #text(size: 20pt)[LARGE] y muchas más. Ejemplo de
fórmula: $a = integral_0^oo f(t) dif t$. Y ahora una ecuación aparte:

$ S = sum_(i=0)^(N-1) a_i^2 . $ <mi_ecuacion>

Las ecuaciones se pueden referenciar: @mi_ecuacion. Y también los capítulos y las secciones: @ejemplos,
@seccion.

=== Un ejemplo de subsección

El texto va aquí.

=== Otro ejemplo de subsección

El texto va aquí.

==== Un ejemplo de subsubsección

El texto va aquí.

==== Un ejemplo de subsubsección

El texto va aquí.

==== Un ejemplo de subsubsección

El texto va aquí.

== Ejemplos de figuras y tablas <seccion>

Referencia a una figura: @enlace1.

Referencia a una tabla: @enlace2.

#figure(
  // usually an image: image("figura.pdf", width: 100%)
  {
    let step(body) = rect(width: 2.6cm, height: 1.4cm, radius: 4pt, fill: luma(235), align(center + horizon, body))
    grid(columns: 5, column-gutter: 0.4cm, align: horizon, step[Datos], $arrow.r$, step[Proceso], $arrow.r$, step[Resultados])
  },
  caption: [Esta es la figura de tal y cual.],
) <enlace1>

#figure(
  table(
    columns: 3,
    align: (left, right, center),
    [Izquierda], [Derecha], [Centrado],
    [ll], [r], [cccc],
    [llll], [rrr], [c],
  ),
  caption: [Esta es la tabla de tal y cual.],
) <enlace2>

== Ejemplos de referencias a la bibliografía

Este es un ejemplo de referencia a un documento descargado de la web @cuda. Y este es un ejemplo
de referencia a una página de la Wikipedia @cdma. Ahora un libro @gonzalez y ahora una referencia
a un artículo de una revista @patricia. También se pueden poner varias referencias a la vez
@cuda @gonzalez. Y también se puede indicar la página concreta de una referencia @gonzalez[p. 7].

== Ejemplos de enumeraciones

Con puntos:

- Uno.
- Dos.
- Tres.

Con números:

+ Cuatro.
+ Cinco.
+ Seis.

Ejemplo de texto verbatim:

```
El texto        verbatim
     se visualiza tal
            como se escribe
```

Ejemplo de código C:

```c
#include <math.h>
main()
{  int i, j, a[10];
   for(i=0;i<=10;i++) a[i]=i; // comentario 1
   if(a[1]==0) j=1; /* comentario 2 */
   else j=2;
}
```

Ejemplo de código Java:

```java
class HelloWorldApp {
    public static void main(String[] args) {
        System.out.println("Hello World!"); // Display the string.
    }
}
```
