#import "@preview/divine-words:0.1.0": *

#show: template.with(
  title: " Titulo. Una plantilla para reportes de laboratorio ",
  institution: " Wayne Enterprises, Gotham City, 1007 Mountain Drive, Midtown.", 
    authors: [ A. Pepito, G. Fulanito, D. Pepita, D. Fulanita ], 
    resumen: [#lorem(60)], 
    palabras-clave: [#lorem(10)],
    abstract: [#lorem(60)], 
    keywords: [#lorem(10)], 
)

= 1. Introducción

#lorem(35) @Wayne2011. #lorem(25) 

= 2. Montaje experimental

#lorem(25)

#lorem(15) $ p = m v$, #lorem(7):
$ F = m a $

$ integral f(x) dif x $

= 3. Resultados

#lorem(30)

#figure(
  table(
    columns: 4, [Voltaje $V$], [Corriente $I$], [Potencia $P$], [Resistencia $R$], [115 $V$], [80 $A$ ], [400 $W$], [30 #sym.Omega],
  ), caption: [Esto es una tabla],
) <tabla01>

#lorem(3) @tabla01 #lorem(20) 
= 4. Discusión

#lorem(30)

= 5. Conclusiones

#lorem(30)

#bibliography("bib.bib", title: "Referencias")
