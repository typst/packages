// اللغات المدعومة : كلمات سطر الوضع النسبي تتبع lang تلقائيًا
// Supported languages: the words of the "p" row follow lang automatically
#import "@preview/na-tabpos:0.1.0": *

#set page(width: 20cm, height: auto, margin: 1cm)
#set text(font: ("Amiri", "New Computer Modern"), size: 13pt)

== العربية — lang: "ar"
#[
  #set text(lang: "ar")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== الفرنسية — lang: "fr"
#[
  #set text(lang: "fr")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Position relative], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== الإنجليزية — lang: "en"
#[
  #set text(lang: "en")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Relative position], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== الإسبانية — lang: "es"
#[
  #set text(lang: "es")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Posición relativa], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== الألمانية — lang: "de"
#[
  #set text(lang: "de")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Relative Lage], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== الإيطالية — lang: "it"
#[
  #set text(lang: "it")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Posizione relativa], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== البرتغالية — lang: "pt"
#[
  #set text(lang: "pt")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Posição relativa], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== الهولندية — lang: "nl"
#[
  #set text(lang: "nl")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Relatieve ligging], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== التركية — lang: "tr"
#[
  #set text(lang: "tr")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Göreli konum], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== الروسية — lang: "ru"
#[
  #set text(lang: "ru")
  #tabpos(
    variable: $x$,
    label: (([$f(x) - y$], "s"), ([Взаимное расположение], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]

== كلمات من اختيارك / your own words
#[
  #set text(lang: "fr")
  #tabpos(
    variable: $x$,
    above: [plus haut], below: [plus bas], cross: [rencontre], at-point: [en],
    label: (([$f(x) - y$], "s"), ([Position], "p")),
    domain: ($-oo$, $-1$, $1$, $+oo$),
    contents: (
      ($+$, ("0", $-$), ("0", $+$)),
      ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
    ),
  )
]
