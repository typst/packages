#set page(width: auto, height: auto, margin: 5pt)

#import "../tabvar.typ": tabvar, hatch

#tabvar(
  variable: $t$,
  label: (
    ([Sign of $f'$], 1cm,"s"),
    ([Variation of $f$], "v"),
  ),
  hatching-style: hatch,
  domain: ($ -oo $,($ -2 $, 1cm),$ 2 $, $ +oo $),
  contents: (
    ( $ - $, "|h|", $ + $), 
    (
      (top, $ +oo $),
      (bottom,"|h", $ 0 $), 
      (bottom, "H|", $ 0 $),
      (top, $ +oo $)
    )
  )
)
  