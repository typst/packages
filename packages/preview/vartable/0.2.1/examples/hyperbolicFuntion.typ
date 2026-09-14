#set page(width: auto, height: auto, margin: 5pt)

#import "../tabvar.typ": tabvar

#tabvar(
  arrow-mark: (end: ">", start: "|"),
  variable: $x$,
  label: (
    ([sign of $f’$], "s"),
    ([variation of $f$], "v"),
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