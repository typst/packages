#import "@preview/klaro-ifsc-sj:0.1.0": report

#show: doc => report(
  title: "Typst IFSC-SJ",
  subtitle: "Um template para o Typst voltado para",
  // Se apenas um autor colocar , no final para indicar que é um array
  authors: ("Gabriel Luiz Espindola Pedro",),
  date: "13 de Setembro de 2023",
  doc,
)

= Soft
== Close
=== Closest
@hard #lorem(80)

== Softest

#lorem(80)

== Softest

#lorem(80)

= Hard <hard>

#lorem(80)

== Hardest

#lorem(80)