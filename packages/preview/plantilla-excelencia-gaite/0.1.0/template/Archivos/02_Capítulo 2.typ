#import "@local/plantilla-excelencia-gaite:0.1.0": *

// Escribirmos a partir de aquí

= Capítulo 2

#lorem(300)

+ Fruta.

+ Verdura.

+ Carne.

+ Pescado.

  + Salmón.

  + Bacalao.

#lorem(50) #footnote[https://typst.app/docs] #lorem(10)

#link("https://example.com")

#link("https://example.com")[
  See example.com
]

== Apartado a <apartado_3.1>

#lorem(200)

Tal y como aparece en el @apartado_3.1, los números algebraicos

$ 1 + 2 + 3 + 4 + ... + n = (n dot (n+1))/2 $ <n_primeros_numeros>

Para demostrar @n_primeros_numeros


#let xs = (0, 1, 2, 3, 4)


#figure(
  lq.diagram(
    title: [Precious data],
    xlabel: $x$, 
    ylabel: $y$,
  
    lq.plot(xs, (5, 4, 2, 1, 2), mark: "s", label: [A]),
    lq.plot(xs, (2, 5, 4, 2, 3), mark: "o", label: [B])
  ),
  caption: [Gráfica no se qué]
)

== Apartado b

#lorem(200)


