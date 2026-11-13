// اختبار لغة الكلمات : تتبع #set text(lang: ...) تلقائيًا
// Test of the words language: they follow #set text(lang: ...)
#import "@preview/na-tabpos:0.1.0": *
#set page(width: 20cm, height: auto, margin: 1cm)
#set text(font: ("Amiri", "New Computer Modern"), size: 13pt)

#let t() = tabpos(
  variable: $x$,
  label: (([$f(x) - y$], "s"), ([Position], "p")),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)

#for l in ("ar", "fr", "en", "es", "de", "it", "pt", "nl", "tr", "ru", "ja") [
  #set text(lang: l)
  *lang = #l* #t()
  #v(4pt)
]
