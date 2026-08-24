// Arabic Exam Kit — visual component gallery
#import "../src/lib.typ": *

#set page(paper: "a4", margin: 1.3cm, numbering: "1 / 1")
#set text(font: "Amiri", lang: "ar", size: 11pt)
#set par(leading: .35em)

#let ar = mf-style(mode: "normal", dir: rtl, seed: 801)
#let cards = exercise-style(mode: "normal", color_mode: "color", dir: rtl, seed: 802)

#align(center)[#text(size: 22pt, weight: "bold", fill: wexam-palette.blue-dark)[Arabic Exam Kit — Galerie visuelle]]
#v(6mm)
#text(size: 13pt)[Composants pédagogiques]
#v(3mm)

#grid(columns: (1fr, 1fr), column-gutter: 8mm, row-gutter: 7mm,
  [
    #mf-card(inset: 1em, ..ar)[
      #mf-title(dir: rtl)[بطاقة رياضيات]
      #v(.7em)
      محتوى عربي داخل بطاقة قابلة لإعادة الاستعمال.
    ]
  ],
  [
    #mf-grid-box(grid-columns: 20, ..ar)[
      #align(center)[ورقة مربعات]
      اكتب خطوات الحل هنا.
    ]
  ],
  [#mf-perforated-box(perforation-count: 8, ..ar)[سؤال على ورقة مثقبة.]],
  [#mf-choice("أ", ..ar)[إجابة متعددة الاختيارات]],
)

#v(8mm)
#align(center)[#mf-spiral-box(coil-count: 8, width: 70%, ..ar)[دفتر حل مزود بحلقات.]]

#pagebreak()

#align(center)[#text(size: 19pt, weight: "bold", fill: ex-palette.ink)[Boîtes d’exercices 1 à 10]]
#v(5mm)

#grid(columns: (1fr, 1fr, 1fr), column-gutter: 5mm, row-gutter: 5mm,
  exercise-1(title: [قوة عدد طبيعي], ..cards)[$2^3 = dots$],
  exercise-2(title: [أس صفر], ..cards)[$6^0 = dots$],
  exercise-3(title: [ضرب قوى], ..cards)[$2^3 times 2^5 = dots$],
  exercise-4(title: [قسمة قوى], ..cards)[$2^7 / 2^3 = dots$],
  exercise-5(title: [قوة قوة], ..cards)[$(2^2)^3 = dots$],
  exercise-6(title: [قوة جداء], ..cards)[$(2 times 3)^3 = dots$],
  exercise-7(title: [قوة لكسر], ..cards)[$(3/5)^3 = dots$],
  exercise-8(title: [مقلوب قوة], ..cards)[$1/2^3 = dots$],
  exercise-9(title: [تعبير قوة], ..cards)[$2^3 times 2^4 = dots$],
)
#v(6mm)
#exercise-10(title: [تطبيقات مركبة], title_band_extra: 3mm, title_band_extra_height: 3mm, ..cards)[
  #align(center)[$((3/2)^2 times (3/2)^3) / (3/2)^4 = dots$]
]

#pagebreak()

#align(center)[#text(size: 19pt, weight: "bold", fill: exam-palette.red-dark)[Modèle d’examen rouge]]
#v(4mm)
#let exam = exam-style(mode: "normal", dir: rtl, seed: 803)
#exam-header(..exam)
#v(1mm)
#exam-meta-line()
#v(5mm)
#exam-exercise-box(title: [التمرين الأول], points: [3 ن], ..exam)[
  اكتب العدد $562,405$ كتابة عشرية.
]
#v(7mm)
#align(center)[#exam-circle-geometry(width: 48%, ..exam)]

#pagebreak()

#align(center)[#text(size: 19pt, weight: "bold")[Modèles de sujets sobres]]
#v(4mm)
#let sx = sexam-style(mode: "normal", dir: rtl, seed: 804)
#sexam-header(..sx)
#v(7mm)
#sexam-exercise-heading(title: [التمرين الأول], points: [6 نقاط], ..sx)
#sexam-part(score: "2", ..sx)[اكتب الحل بالتفصيل.] 
#v(8mm)
#let wx = wexam-style(mode: "normal", dir: rtl, seed: 805)
#wexam-header(..wx)
#v(5mm)
#wexam-exercise-heading(title: [التمرين الأول], points: [3 ن], ..wx)
#wexam-question(number: 1, ..wx)[احسب $m = (+5) + (-7)$.]

#pagebreak()

#align(center)[#text(size: 19pt, weight: "bold", fill: palette.coffee-dark)[Effets vectoriels]]
#v(5mm)
#grid(columns: (1fr, 1fr), column-gutter: 12mm,
  [#align(center)[#mf-coffee-stain(size: 4.6cm, paper-color: white)]],
  [#align(center)[#mf-coffee-blot(width: 2.5cm, height: 3.4cm)]],
)
#v(4mm)
#grid(columns: (1fr, 1fr), column-gutter: 12mm,
  [#align(center)[#mf-paint-splat(model: 5, width: 5cm, height: 4cm)]],
  [#align(center)[#mf-magnetic-filings-box(width: 100%, dir: rtl)[المجال المغناطيسي]]],
)

#pagebreak()

#align(center)[#text(size: 19pt, weight: "bold", fill: wexam-palette.blue-dark)[Figures et 2AM]]
#v(4mm)
#grid(columns: (1fr, 1fr), column-gutter: 10mm,
  [#wexam-angle-figure(width: 100%)],
  [#wexam-house-figure(width: 100%)],
)
#v(7mm)
#text(dir: rtl)[كل العناصر السابقة تستجيب إلى `mode: "rough"` و `roughness:` و `seed:` حسب عائلتها.]
