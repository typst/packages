#set page(width: auto, height: auto, margin: 5pt)

#import "../tabvar.typ": tabvar

#tabvar(

  variable: $x$,
  label: (
    ([sign of cos’], "s"),
    ([variation of cos], "v"),
    ([sign of sin’], "s"),
    ([variation of sin], "v"),
  ),

  domain: ($0$, $ pi / 2 $, $ pi $, $ (2pi) / 3 $, $ 2 pi $),
  contents: (
    ($-$, (), ("0",$+$), ()),
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
  values: (
    ("arrow10.50%", $  $, $ 0 $, "f"),
    ("arrow12.49%", $  $, $ 0 $, "f"),
  )
)