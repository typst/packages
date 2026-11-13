// تغيير أسماء المنحنيين والمستقيم / Changing the names of the curves and the line
#import "@preview/na-tabpos:0.1.0": *

#set page(width: 20cm, height: auto, margin: 1cm)
#set text(font: ("Amiri", "New Computer Modern"), size: 13pt)
#set text(lang: "ar")

// مرة واحدة لكل المستند : منحنى ومستقيم
#tabpos-names(first: $(C_f)$, second: $(Delta)$)

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

#v(1cm)

// لجدول واحد فقط : منحنيان باسمين آخرين
#tabpos(
  first: $(C_1)$,
  second: $(C_2)$,
  variable: $x$,
  label: (
    ([$f(x) - g(x)$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
