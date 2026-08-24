#import "../src/lib.typ": *

#set page(paper: "a4", margin: 1cm)
#set text(font: "Amiri", lang: "ar", size: 12pt)

#let wx = wexam-style(mode: "normal", dir: rtl)

#wexam-header(..wx)
#v(4mm)
#wexam-exercise-heading(title: [التمرين الأول], points: [3 ن], ..wx)
#wexam-question(number: 1, ..wx)[
  احسب $m = (+5) + (-7)$.
]
#v(2mm)
#wexam-question(number: 2, ..wx)[
  حل المعادلة $3x = 11$.
]
