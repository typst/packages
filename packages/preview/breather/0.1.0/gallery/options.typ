// Options: `only` filter and mid-document toggling.
#import "@preview/breather:0.1.0": breathe, breathe-on, breathe-off

#set page(width: 13cm, height: auto, margin: 6mm)
#set text(size: 11pt)
#set par(leading: 0.6em)
#show math.frac: it => math.display(it)

#show: breathe.with(only: math.frac)

== `only: math.frac` — fractions get room, matrices are left alone
$A = frac(54, 45) - frac(20, 45)$\
$M = mat(1, 2; 3, 4)$\
$N = mat(5, 6; 7, 8)$

#breathe-on(only: none, threshold: 1.4em)

== `breathe-on(only: none, threshold: 1.4em)` — everything, higher bar
$A = frac(54, 45) - frac(20, 45)$\
$M = mat(1, 2; 3, 4)$\
$N = mat(5, 6; 7, 8)$

#breathe-off()

== `breathe-off()` — back to Typst's default behaviour
$A = frac(54, 45) - frac(20, 45)$\
$A = frac(34, 45)$
