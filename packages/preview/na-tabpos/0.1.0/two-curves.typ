// منحنيان (C_f) و (C_g)
// Two curves (C_f) and (C_g)
#import "@preview/na-tabpos:0.1.0": *
#set text(font: ("Amiri", "New Computer Modern"), lang: "ar", size: 16pt)
#set page(width: 18cm, height: auto, margin: 1cm)

#tabpos(
  variable: $x$,
  second: $(C_g)$,
  label: (
    ([$f(x) - g(x)$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $0$, $+oo$),
  contents: (
    ($-$, ("0", $+$)),
    ("-", ("0", "+")),
  ),
)
