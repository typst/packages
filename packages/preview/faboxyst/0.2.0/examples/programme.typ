// faboxyst — the "annual programme" plate: the four boxes of the
// secondary-school physics programme sheet, rebuilt as vectors.
#import "@preview/faboxyst:0.2.0": *

#set page(width: 21cm, height: 29.7cm, margin: 1.4cm, fill: rgb("#F7F7F9"))
#set text(lang: "ar", dir: rtl, font: "Amiri", size: 13pt)

// ---------------------------------------------------------------- header
#grid(
  columns: (auto, 1fr, auto),
  column-gutter: 10pt,
  align(center + horizon, pinbox[السنة الأولى][1 ج م ع ت]),
  align(center + horizon, brushbox[البرنامج السنوي لمادة العلوم الفيزيائية]),
  align(center + horizon,
    block(width: 6.5cm, matierebox(subject: [Physique], year: [2026/2027]))),
)

#v(1.1cm)

// ---------------------------------------------------------------- lessons
#let lessons = (
  [بنية وهندسة أفراد بعض الأنواع الكيميائية],
  [القوة والحركات المستقيمة],
  [القوة والحركات المنحنية],
  [القوة والحركة والمرجع],
  [دفع وكبح متحرك],
  [من المجهري إلى العياني],
  [التماسك في المادة وفي الفضاء],
  [إنكسار الضوء],
  [الضوء الأبيض والضوء وحيد اللون],
  [المقاربة الكمية لتحول كيميائي],
  [أطياف الإصدار وأطياف الامتصاص],
)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 16pt,
  row-gutter: 15pt,
  ..lessons.enumerate().map(((i, t)) => align(center,
    leconbox(num: i + 1, min-height: 2.6em, text-size: 0.95em)[#t]))
)

#v(1cm)

// the same bars in French, left to right: the plate mirrors itself
#set text(lang: "fr", dir: ltr, size: 11pt)
#leconbox(num: 1, width: 100%, min-height: 2.2em)[Structure et géométrie de quelques espèces chimiques]
#v(0.4cm)
#leconbox(num: 8, width: 100%, min-height: 2.2em)[Réfraction de la lumière]
