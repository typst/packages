// One-pass review of the eight components introduced in styles 57–64.
// Pages 1–8: colour (alternating LTR/Arabic RTL); 9–16: print grayscale;
// pages 17–19: generic fabox folded-corner shadow, colour LTR/RTL and print.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 13.2cm, height: 8.8cm, margin: 0.35cm, fill: white)
#set text(font: "DejaVu Sans", size: 9pt)
#show: faboxyst.with(theme: themes.notebook)

// 57 — inclined card; width/height, custom stroke, custom icon.
#align(center + horizon)[
  #six-boxes-tilted-box(
    title: [Target], body: [Define the audience and state the outcome clearly.],
    icon-style: 2, icon-size: 0.78cm,
    width: 7.4cm, height: 2.35cm, badge-side: "left",
    stroke-colour: rgb("#6B491A"), stroke-width: 2.2pt,
    colour: rgb("#F1840B"),
  )
]
#pagebreak()

// 58 — folder card; Arabic RTL.
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #six-boxes-folder-card(
    title: [خطة واضحة], body: [تساعد الخطة الواضحة الفريق على تنسيق الجهود وتحقيق النتائج المطلوبة.],
    icon-style: 1, icon-size: 0.48cm, width: 4.9cm, height: 2.55cm,
    direction: rtl, stroke-colour: rgb("#365D39"), stroke-width: 1.9pt,
    colour: rgb("#43834A"),
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()

// 59 — banded horizontal card.
#align(center + horizon)[
  #six-boxes-banded-box(
    title: [Next step], body: [Keep the next action visible and easy to follow.],
    icon-style: 4, icon-size: 0.60cm, width: 7.1cm, height: 1.62cm,
    badge-side: "right", stroke-colour: rgb("#61212C"), stroke-width: 2.4pt,
    colour: rgb("#9E2737"),
  )
]
#pagebreak()

// 60 — pointer card; height aliases the square tile size.
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #six-boxes-pointer-card(
    title: [الهدف], body: [اختر خطوة عملية وابدأ بها اليوم.],
    icon-style: 2, icon-size: 0.72cm, width: 3.1cm, height: 1.90cm,
    direction: rtl, stroke-colour: rgb("#543B20"), stroke-width: 2.3pt,
    colour: rgb("#E6A023"),
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()

// 61 — hand-drawn rectangular outline with a leading icon.
#align(center + horizon)[
  #pencil-sketch-box(
    title: [Make it visible], body: [A hand-drawn frame can make a useful note feel more personal.],
    width: 7.2cm, height: 2.95cm, icon: [✦], icon-position: "start",
    icon-size: 0.36cm, icon-colour: rgb("#704A18"),
    stroke-colour: rgb("#704A18"), stroke-width: 2.5pt,
    colour: rgb("#C99D20"),
  )
]
#pagebreak()

// 62 — hand-drawn ellipse with an end-position icon in Arabic RTL.
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #pencil-sketch-ellipse(
    title: [فكرة واضحة], body: [أبرز الفكرة المهمة وعد إليها لاحقًا.],
    width: 7.4cm, height: 3.2cm, direction: rtl, icon: [✦],
    icon-position: "end", icon-size: 0.32cm, icon-colour: rgb("#80501F"),
    stroke-colour: rgb("#80501F"), stroke-width: 2.3pt,
    colour: rgb("#D99042"),
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()

// 63 — graphite hatch, top icon, custom stroke.
#align(center + horizon)[
  #pencil-sketch-graphite-box(
    title: [One useful note], body: [A pale graphite hatch keeps the message readable.],
    width: 7.4cm, height: 3.15cm, icon: [✦], icon-position: "top",
    icon-size: 0.30cm, icon-colour: rgb("#494541"),
    stroke-colour: rgb("#494541"), stroke-width: 1.9pt,
  )
]
#pagebreak()

// 64 — taped curled note, Arabic RTL; the shadow follows the lifted flap.
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #taped-curl-note(
    body: [• دوّن الفكرة المهمة.#linebreak()• أضف ملاحظة قصيرة.#linebreak()• عُد إليها عند الحاجة.],
    width: 5.9cm, height: 6.8cm, direction: rtl, icon: [✦],
    icon-position: "top", icon-size: 0.30cm, icon-colour: rgb("#383532"),
    stroke-colour: rgb("#383532"), stroke-width: 1.55pt,
    paper: rgb("#F1DADD"), tape-colour: rgb("#D39299"),
  )
]
#set text(lang: "en", dir: ltr)
#pagebreak()

// 57 — print.
#print-group[
  #align(center + horizon)[
    #six-boxes-tilted-box(
      title: [Target], body: [Define the audience and state the outcome clearly.],
      icon-style: 2, icon-size: 0.78cm,
      width: 7.4cm, height: 2.35cm, badge-side: "left",
      stroke-colour: rgb("#6B491A"), stroke-width: 2.2pt,
      colour: rgb("#F1840B"),
    )
  ]
]
#pagebreak()

// 58 — print Arabic RTL.
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #six-boxes-folder-card(
      title: [خطة واضحة], body: [تساعد الخطة الواضحة الفريق على تنسيق الجهود وتحقيق النتائج المطلوبة.],
      icon-style: 1, icon-size: 0.48cm, width: 4.9cm, height: 2.55cm,
      direction: rtl, stroke-colour: rgb("#365D39"), stroke-width: 1.9pt,
      colour: rgb("#43834A"),
    )
  ]
]
#pagebreak()

// 59 — print.
#print-group[
  #align(center + horizon)[
    #six-boxes-banded-box(
      title: [Next step], body: [Keep the next action visible and easy to follow.],
      icon-style: 4, icon-size: 0.60cm, width: 7.1cm, height: 1.62cm,
      badge-side: "right", stroke-colour: rgb("#61212C"), stroke-width: 2.4pt,
      colour: rgb("#9E2737"),
    )
  ]
]
#pagebreak()

// 60 — print Arabic RTL.
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #six-boxes-pointer-card(
      title: [الهدف], body: [اختر خطوة عملية وابدأ بها اليوم.],
      icon-style: 2, icon-size: 0.72cm, width: 3.1cm, height: 1.90cm,
      direction: rtl, stroke-colour: rgb("#543B20"), stroke-width: 2.3pt,
      colour: rgb("#E6A023"),
    )
  ]
]
#pagebreak()

// 61 — print.
#print-group[
  #align(center + horizon)[
    #pencil-sketch-box(
      title: [Make it visible], body: [A hand-drawn frame can make a useful note feel more personal.],
      width: 7.2cm, height: 2.95cm, icon: [✦], icon-position: "start",
      icon-size: 0.36cm, icon-colour: rgb("#704A18"),
      stroke-colour: rgb("#704A18"), stroke-width: 2.5pt,
      colour: rgb("#C99D20"),
    )
  ]
]
#pagebreak()

// 62 — print Arabic RTL.
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #pencil-sketch-ellipse(
      title: [فكرة واضحة], body: [أبرز الفكرة المهمة وعد إليها لاحقًا.],
      width: 7.4cm, height: 3.2cm, direction: rtl, icon: [✦],
      icon-position: "end", icon-size: 0.32cm, icon-colour: rgb("#80501F"),
      stroke-colour: rgb("#80501F"), stroke-width: 2.3pt,
      colour: rgb("#D99042"),
    )
  ]
]
#pagebreak()

// 63 — print.
#print-group[
  #align(center + horizon)[
    #pencil-sketch-graphite-box(
      title: [One useful note], body: [A pale graphite hatch keeps the message readable.],
      width: 7.4cm, height: 3.15cm, icon: [✦], icon-position: "top",
      icon-size: 0.30cm, icon-colour: rgb("#494541"),
      stroke-colour: rgb("#494541"), stroke-width: 1.9pt,
    )
  ]
]
#pagebreak()

// 64 — print Arabic RTL.
#print-group[
  #set text(lang: "ar", dir: rtl)
  #align(center + horizon)[
    #taped-curl-note(
      body: [• دوّن الفكرة المهمة.#linebreak()• أضف ملاحظة قصيرة.#linebreak()• عُد إليها عند الحاجة.],
      width: 5.9cm, height: 6.8cm, direction: rtl, icon: [✦],
      icon-position: "top", icon-size: 0.30cm, icon-colour: rgb("#383532"),
      stroke-colour: rgb("#383532"), stroke-width: 1.55pt,
      paper: rgb("#F1DADD"), tape-colour: rgb("#D39299"),
    )
  ]
]
#pagebreak()

// Generic fabox dog-ear shadow fix — LTR colour.
#align(center + horizon)[
  #fabox(
    title: [Folded note], width: 7.4cm, height: 3.6cm,
    colour: rgb("#D9A943"), frame: rgb("#594326"),
    back: rgb("#FCF6E8"), fold: true, fold-size: 0.82,
    shadow: "plain", shadow-colour: luma(105), rule-between: false,
  )[A folded corner should cast a soft edge-following shadow.]
]
#pagebreak()

// Generic fabox dog-ear shadow fix — RTL colour.
#set text(lang: "ar", dir: rtl)
#align(center + horizon)[
  #fabox(
    title: [ملاحظة مطوية], width: 7.4cm, height: 3.6cm,
    colour: rgb("#D9A943"), frame: rgb("#594326"),
    back: rgb("#FCF6E8"), fold: true, fold-size: 0.82,
    shadow: "plain", shadow-colour: luma(105), rule-between: false,
  )[ينبغي أن يتبع الظل حافة الطي بوضوح ونعومة.]
]
#set text(lang: "en", dir: ltr)
#pagebreak()

// Generic fabox dog-ear shadow fix — print.
#print-group[
  #align(center + horizon)[
    #fabox(
      title: [Folded note], width: 7.4cm, height: 3.6cm,
      colour: rgb("#D9A943"), frame: rgb("#594326"),
      back: rgb("#FCF6E8"), fold: true, fold-size: 0.82,
      shadow: "plain", shadow-colour: luma(105), rule-between: false,
    )[A folded corner should cast a soft edge-following shadow.]
  ]
]
