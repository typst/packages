#import "_helpers.typ": *
#set page(paper: "a4", margin: (x: 1.15cm, y: 1.2cm),
  header: text(size: 8pt, fill: luma(120))[faboxyst showcase · pictos],
  footer: context align(center, text(size: 8pt, fill: luma(120), counter(page).display())))
#set text(font: "DejaVu Sans", size: 9.5pt)

#cmd-title[meter  ·  battery / speedo / chrono / wifi / cible]
#sig[
```typ
#meter(value, max: 5, style: "battery", shaded: false, size: 1.5cm)
#pictochrono(5, max: 60)   // stopwatch
// styles + speedo | chrono | wifi | cible
```
]
#param-row([battery  fill opposite the black nub],
  meter(2, style: "battery", size: 2.6cm),
  meter(3, style: "battery", size: 2.6cm, direction: rtl),
  code: `#meter(2, style: "battery")`)
#param-row([battery + gradient],
  meter(3, style: "battery", size: 2.6cm, shaded: true),
  meter(4, style: "battery", size: 2.6cm, shaded: true, direction: rtl),
  code: `#meter(3, style: "battery", shaded: true)`)
#param-row([speedo  pads green→red],
  meter(4, style: "speedo", size: 1.6cm, max: 8),
  meter(1, style: "speedo", size: 1.6cm, max: 8, direction: rtl),
  code: `#meter(4, style: "speedo", max: 8)`)
#param-row([pictochrono],
  pictochrono(10, max: 60, size: 1.5cm),
  pictochrono(45, max: 60, size: 1.5cm, colour: rgb("#C62828")),
  code: `#pictochrono(10, max: 60)`)
#param-row([wifi  classic arcs · size],
  meter(3, style: "wifi", size: 1.15cm, max: 4),
  meter(3, style: "wifi", size: 1.9cm, max: 4),
  code: `#meter(3, style: "wifi", size: 1.15cm)`)
#param-row([cible  thicker shaft · size],
  meter(4, style: "cible", size: 1.2cm),
  meter(4, style: "cible", size: 1.9cm),
  code: `#meter(4, style: "cible", size: 1.2cm)`)

#cmd-title[customenvs pictos · banners]
#sig[
```typ
#tkzpicto("stars", value: 3)
#competence-crayon(title: [Chercher], body: [Comp. 1])
#level-counter(2, max: 4)
#bicolor-title([Part A], end: [Part B])
#banner-tri[SALE]  #banner-tri(alt: true)[ALT]
#highway-sign(title: [A1])[Algiers]
#sale-poster(old: [19,90 €], new: [9,90 €], reduction: [−50%])
#tcbwhiteboard  #tcboxnotebook
```
]
#param-row([tkzpicto stars / speedo],
  tkzpicto("stars", value: 3, max: 5),
  tkzpicto("speedo", value: 4, max: 8, size: 1.5cm),
  code: `#tkzpicto("stars", value: 3)`)
#param-row([level-counter],
  level-counter(2, max: 5),
  level-counter(4, max: 5, colour: rgb("#2E7D32"), direction: rtl),
  code: `#level-counter(2, max: 5)`)
#param-row([competence-crayon  LTR pencil left / RTL pill next to pencil],
  competence-crayon(sections: (
    ([Chercher], [Compétence 1]),
    ([Modéliser], [Compétence 1]),
  ), width: 6.4cm, size: 0.92, direction: ltr),
  competence-crayon(title: [حساب], body: [مهارة 1], width: 6.4cm, size: 0.92, direction: rtl),
  code: `#competence-crayon(title: [حساب], body: [مهارة 1], width: 6.4cm, size: 0.92, direction: rtl)`)
#param-row([bicolor-title],
  bicolor-title([Chapter], end: [01]),
  bicolor-title([فصل], end: [01], colour-a: rgb("#00695C"), colour-b: rgb("#EF6C00")),
  code: `#bicolor-title([Chapter], end: [01])`)
#param-row([banner-tri  width follows title · LTR start / RTL end],
  banner-tri(title: [01], colour: rgb("#C62828"), fill: auto, fill-b: auto,
    ink: white, arrows: 3, tip: 0.48cm, step: 0.18cm, size: 1.0,
    title-align: auto, body-align: auto, direction: ltr)[Chapter],
  banner-tri(title: [01], colour: rgb("#1565C0"), fill: auto, fill-b: auto,
    ink: white, arrows: 3, tip: 0.48cm, step: 0.18cm, size: 1.0,
    title-align: auto, body-align: auto, direction: rtl)[فصل],
  code: `#banner-tri(title: [01], arrows: 3, fill: auto, fill-b: auto, direction: rtl)[فصل]`)
#param-row([banner-tri  multi-line title · 4 arrows · custom fills],
  banner-tri(title: [Ex. 1\ Level A], colour: rgb("#6A1B9A"),
    fill: rgb("#6A1B9A"), fill-b: rgb("#E1BEE7"), arrows: 4,
    ink: white, ink-b: rgb("#4A148C"), direction: ltr)[Functions],
  banner-tri(title: [تمرين\ أولى], colour: rgb("#00695C"),
    fill: rgb("#00695C"), fill-b: rgb("#B2DFDB"), arrows: 2,
    ink: white, ink-b: rgb("#004D40"), direction: rtl)[الدوال],
  code: `#banner-tri(title: [Ex. 1\\ Level A], arrows: 4, fill: rgb("#6A1B9A"), fill-b: rgb("#E1BEE7"))[Functions]`)
#param-row([highway-sign],
  highway-sign(title: [A1])[Algiers  12 km],
  highway-sign(title: [A2], colour: rgb("#1B5E20"))[وهران  8 km],
  code: `#highway-sign(title: [A1])[Algiers]`)
#param-row([sale-poster  LTR / RTL mirrored],
  sale-poster(old: [19,90 €], new: [9,90 €], reduction: [−50%],
    header: auto, colour: luma(90), width: 6.4cm, size: 0.88, direction: ltr),
  sale-poster(old: [45 €], new: [22 €], reduction: [−50%],
    header: auto, colour: rgb("#EF6C00"), width: 6.4cm, size: 0.88, direction: rtl),
  code: `#sale-poster(old: [19,90 €], new: [9,90 €], reduction: [−50%], header: auto, colour: luma(90), width: 6.4cm, size: 0.88, direction: rtl)`)

