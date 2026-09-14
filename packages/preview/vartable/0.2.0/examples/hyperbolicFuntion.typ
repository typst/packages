#set page(width: auto, height: auto, margin: 5pt)

#import "../tabvar.typ": tabvar

#tabvar(
  arrow-mark: (end: ">", start: "|"),
  init: (
    variable: $x$,
    label: (
      ([sign of $f’$], "Sign"),
      ([variation of $f$], "Variation"),
    ),
  ),
  domain: ($ -oo $, $ 0 $, $ +oo $),
  contents: (
    ($+$, ("||", $+$)),
    (
      (center, $0$),
      (bottom, top, "||", $ -oo $, $ +oo $),
      (center, $ 0 $),
    ),
  ),
)