#set page(width: auto, height: auto, margin: 5pt)

#import "../tabvar.typ": *

#tabvar(
  init: (
    variable: $x$,
    label: (
      ([sign], "Sign"),
      ([var], "Variation"),
    ),
  ),
  domain: ($3$, $2$, $1$),
  content: (
    ($+$, $-$),
    (
      (top, $3$),
      (bottom, $2$),
      (top, $ "tree"(3) $ + "that is a very big number"),
    ),
  ),
)