#set page(width: auto, height: auto, margin: 5pt)

#import "../tabvar.typ": tabvar

#tabvar(
  init: (
    variable: $x$,
    label: (
      ([sign of cos’], "Sign"),
      ([variation of cos], "Variation"),
      ([sign of sin’], "Sign"),
      ([variation of sin], "Variation"),
    ),
  ),
  domain: ($0$, $ pi / 2 $, $ pi $, $ (2pi) / 3 $, $ 2 pi $),
  content: (
    ($-$, (), $+$, ()),
    (
      (top, $1$),
      (),
      (bottom, $-1$),
      (),
      (top, $1$),
    ),
    ($+$, $-$, (), $+$),
    (
      (center, $0$),
      (top, $1$),
      (),
      (bottom, $-1$),
      (center, $0$),
    ),
  ),
)