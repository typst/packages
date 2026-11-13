#import "@preview/na-tabpos:0.1.0": *
#set text(font: ("Amiri", "New Computer Modern"), lang: "ar", size: 16pt)
#set page(width: 24cm, height: auto, margin: 1cm)

== 1) منحنى ومستقيم : سطر الفرق ثم سطر الوضع النسبي

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

== 2) منحنيان : $(C_f)$ و $(C_g)$

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

== 3) قيمة ممنوعة : $D_f = RR without {1}$

#tabpos(
  variable: $x$,
  label: (
    ([$f(x) - y$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $1$, $+oo$),
  contents: (
    ($-$, ("||", $+$)),
    ("-", ("||", "+")),
  ),
)

== 4) جزء محذوف من الوسط : $D_f = ]-oo ; -2[ union ]2 ; +oo[$

#tabpos(
  variable: $x$,
  hatching-style: hatch,
  label: (
    ([$f(x) - y$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $-2$, $2$, $+oo$),
  contents: (
    ($-$, "|h|", $+$),
    ("-", "|h|", "+"),
  ),
)

== 5) جزء محذوف من البداية : $D_f = [0 ; +oo[$

#tabpos(
  variable: $x$,
  hatching-style: hatch,
  label: (
    ([$f(x) - y$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $0$, $2$, $+oo$),
  contents: (
    ("h|", $-$, ("0", $+$)),
    ("h|", "-", ($A(2 ; 0)$, "+")),
  ),
)

== 6) إشارة وتغيّرات وفرق ووضع نسبي في جدول واحد

#tabpos(
  variable: $x$,
  label: (
    ([$f'(x)$], "s"),
    ([$f(x)$], "v"),
    ([$f(x) - y$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $0$, $+oo$),
  contents: (
    ($-$, ("||", $-$)),
    (
      (center, $0$),
      (bottom, top, "||", $-oo$, $+oo$),
      (center, $0$),
    ),
    ($+$, ("||", $-$)),
    ("+", ("||", "-")),
  ),
)
