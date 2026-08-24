#import "../src/lib.typ": *

#set page(paper: "a4", margin: 5mm)
#set text(font: "Amiri", lang: "ar", size: 12pt)

#let exam = exam-style(mode: "normal", dir: rtl, seed: 20)

#exam-page-frame(
  height: 95%,
  ..exam,
)[
  #exam-header(..exam)
  #v(.8mm)
  #exam-meta-line()
  #v(5mm)
  #exam-exercise-box(title: [التمرين الأول], points: [3 ن], ..exam)[
    اكتب العدد $562,405$ كتابة عشرية.
  ]
  #v(3mm)
  #exam-exercise-box(title: [التمرين الثاني], points: [2 ن], ..exam)[
    أنشئ الشكل ثم اكتب ملاحظاتك.
  ]
]
#v(1mm)
#exam-footer(footer-center: [صفحة 1 من 1])
