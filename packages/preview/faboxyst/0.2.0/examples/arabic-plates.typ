// ===========================================================================
//  faboxyst — the four reference plates, in Arabic.
//
//    typst compile examples/arabic-plates.typ --root . --font-path fonts/
//
//  Fonts: any Naskh for the body (Amiri, Noto Naskh Arabic …) and a Kufi
//  display face for the titles (Noto Kufi Arabic). Both fall back to
//  DejaVu when absent.
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(width: 17cm, height: auto, margin: 9mm, fill: white)
#set text(font: ("Amiri", "Noto Naskh Arabic", "DejaVu Serif"), size: 12pt,
  lang: "ar", dir: rtl)
#show math.equation: set text(font: "New Computer Modern Math", dir: ltr, size: 11pt)

#let kufi(body) = text(font: ("Noto Kufi Arabic", "Amiri", "DejaVu Sans"),
  size: 0.85em, body)

#let ex1 = [
  نعتبر العددين المركّبين:
  #align(center)[$z_1 = 2 + i, quad z_2 = 1 - 2i.$]
  + اكتب الأعداد $z_1 + z_2$، $z_1 z_2$ و $z_1 / z_2$ على الشكل الجبري.
  + احسب $overline(z_1)$، $overline(z_2)$، $|z_1|$ و $|z_2|$.
  + حلّ المعادلة $(1 - i) z = 3 + i$.
]
#let ex2 = [
  ليكن $z = 1 + i sqrt(3)$.
  + احسب طويلة $z$ وعمدة له، ثم اكتب شكليه المثلثي والأسّي.
  + استنتج القيمتين الدقيقتين لـ $z^3$ و $z^6$.
  + حلّ في $CC$ المعادلة $w^3 = 8$، واكتب الحلول على الشكل الجبري.
  + مثّل هذه الحلول في المستوى المركّب، وحدّد الدائرة التي تنتمي إليها.
]

// 1 — navy frame, emerald sash, khatam badge, gold rosettes on a strip
#khatambox(title: kufi[الحساب الجبري والمرافق], badge: [1], badge-label: [تمرين], ex1)

#v(6mm)

// 2 — zellij course with a paper pennant, knot tiles down the sides
#zellijbox(title: kufi[تمرين 2 #h(0.5em) الكتابة الأسّية والجذور], ex2)

#v(6mm)

// 3 — rounded frame, ogee banner with finials, palmettes, scrolls
#arabesquebox(title: kufi[تمرين 1 #h(0.5em) الحساب الجبري والمرافق], ex1)

#v(6mm)

// 4 — emerald sash with pointed arches and medallions, rosettes, wedges
#mihrabbox(title: kufi[تمرين 2 #h(0.5em) الكتابة الأسّية والجذور], ex2)

#v(6mm)

// 5 — the flag box, in RTL
#flagbox(title: kufi[ملاحظة], badge: [1], colour: rgb("#1F3A68"), end-motif: "finial")[
  الشكل الأسّي $z = r e^(i theta)$ يجعل ضرب الأعداد المركّبة وقسمتها ورفعها إلى قوة أمراً مباشراً.
]
