#set page(width: auto, height: auto, margin: 1em)
#import "../lib.typ": *

#show: setup-lovelace

#pseudocode(
  $x <- a$,
  [*repeat until convergence*], ind,
    $x <- (x + a/x) / 2$, ded,
  [*return* $x$]
)
