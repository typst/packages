#import "../src/lib.typ": *

#set page(paper: "a4", margin: 1.8cm)
#set text(font: "Amiri", lang: "ar", size: 12pt)

#let sx = sexam-style(mode: "normal", dir: rtl)

#sexam-page(
  height: 100%,
  footer: sexam-footer(
    footer-left: [اقلب الورقة],
    footer-center: [صفحة 1 من 1],
    footer-right: [ركز جيدًا],
    ..sx,
  ),
  ..sx,
)[
  #sexam-header(..sx)
  #v(1cm)
  #sexam-exercise-heading(title: [التمرين الأول], points: [6 نقاط], ..sx)
  #sexam-part(score: "2", ..sx)[
    المتتالية العددية $U_n$ معرفة كما يلي: $U_0 = 6$ و $U_(n+1) = 1/4 U_n + 3$.
  ]
  #v(2mm)
  #sexam-part(score: "1", ..sx)[
    احسب $U_1$ ثم ناقش تغيرات المتتالية.
  ]
]
