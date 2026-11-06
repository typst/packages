// Monochrome print version of the alternating process blocks, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 22cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt, fill: black)
#set par(leading: 0.42em)
#show: faboxyst.with(theme: themes.notebook)

= Alternating Block Process — print

#print-group[
  #alternating-block-process(
    direction: ltr,
    steps: (
      (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam.], icon: image("assets/alternating-idea.svg", width: 1.2cm), print-icon: image("assets/alternating-idea-print.svg", width: 1.2cm)),
      (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam.], icon: image("assets/alternating-target.svg", width: 1.2cm), print-icon: image("assets/alternating-target-print.svg", width: 1.2cm)),
      (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam.], icon: image("assets/alternating-gears.svg", width: 1.2cm), print-icon: image("assets/alternating-gears-print.svg", width: 1.2cm)),
      (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam.], icon: image("assets/alternating-chart.svg", width: 1.2cm), print-icon: image("assets/alternating-chart-print.svg", width: 1.2cm)),
    ),
  )

  #v(0.55cm)
  #text(lang: "en", dir: ltr, size: 12pt, weight: "bold")[Same process — RTL print]
  #set text(lang: "ar", dir: rtl)
  #v(0.18cm)
  #alternating-block-process(
    direction: rtl,
    steps: (
      (title: [الفكرة], body: [ابدأ بفكرة واضحة، وحدّد الهدف الذي تريد الوصول إليه.], icon: image("assets/alternating-idea.svg", width: 1.2cm), print-icon: image("assets/alternating-idea-print.svg", width: 1.2cm)),
      (title: [التخطيط], body: [اختر الخطوات المناسبة ورتّبها وفق تسلسل منطقي.], icon: image("assets/alternating-target.svg", width: 1.2cm), print-icon: image("assets/alternating-target-print.svg", width: 1.2cm)),
      (title: [التنفيذ], body: [نفّذ الخطة وتعاون مع الفريق لمتابعة التقدم.], icon: image("assets/alternating-gears.svg", width: 1.2cm), print-icon: image("assets/alternating-gears-print.svg", width: 1.2cm)),
      (title: [النتيجة], body: [قِس النتائج، واستخلص الدروس للخطوة التالية.], icon: image("assets/alternating-chart.svg", width: 1.2cm), print-icon: image("assets/alternating-chart-print.svg", width: 1.2cm)),
    ),
  )
]
