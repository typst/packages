// منحنى ومستقيم : سطر الفرق (ارتفاعه 1 سم) ثم سطر الوضع النسبي
// A curve and a line: the difference row (1 cm high) then the relative-position row
#import "@preview/na-tabpos:0.1.0": *
#set text(font: ("Amiri", "New Computer Modern"), lang: "ar", size: 16pt)
#set page(width: 22cm, height: auto, margin: 1cm)

#tabpos(
  variable: $x$,
  label: (
    ([$f(x) - y$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
