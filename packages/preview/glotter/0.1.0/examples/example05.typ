#import "../lib.typ": *
#set page(width: auto, height: auto, margin: 2mm)

#let localized-abstract(body) = {
  let info = detect-info(body, fallback: "en")
  let l = info.at("lang")
  let rtl-lang = ("ar", "fa", "he", "ur").contains(l)

  let title = if l == "ja" {
    "概要"
  } else if l == "ar" {
    "ملخص"
  } else if l == "de" {
    "Zusammenfassung"
  } else if l == "fr" {
    "Résumé"
  } else {
    "Abstract"
  }

  block(
    width: 10cm,
    inset: 8pt,
    stroke: 0.5pt + luma(180),
    radius: 4pt,
  )[
    #set text(lang: l, dir: if rtl-lang { rtl } else { ltr })
    #set align(if rtl-lang { right } else { left })

    #strong[#title] \
    #auto-text(fallback: "en")[#body]
  ]
}

#localized-abstract[This package detects the language of text fragments.]

#localized-abstract[تقوم هذه الحزمة بتحديد لغة أجزاء النص.]