// Three Step Highlight Cards — monochrome print gallery, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.38em)
#show: faboxyst.with(theme: themes.print)

#let sample = (
  (title: [Discover], body: [Observe what is happening, gather useful insights, and frame the question that matters.], icon: image("assets/three-step-idea.svg", width: 1.38cm), print-icon: image("assets/three-step-idea-print.svg", width: 1.38cm)),
  (title: [Explore], body: [Compare the possibilities, test promising directions, and learn from the evidence.], icon: image("assets/three-step-analysis.svg", width: 1.38cm), print-icon: image("assets/three-step-analysis-print.svg", width: 1.38cm)),
  (title: [Achieve], body: [Choose a clear goal, take focused action, and celebrate meaningful progress.], icon: image("assets/three-step-target.svg", width: 1.38cm), print-icon: image("assets/three-step-target-print.svg", width: 1.38cm)),
)

= Three Step Highlight Cards — print, LTR
#v(0.35cm)
#print-group[
  #three-step-highlight-cards(steps: sample, width: 22cm, direction: ltr)
]

#v(0.70cm)
= Same cards — print, RTL
#v(0.35cm)
#print-group[
  #three-step-highlight-cards(
    steps: (
      (title: [اكتشف], body: [راقب ما يحدث، واجمع الملاحظات المفيدة، وحدّد السؤال الأهم.], icon: image("assets/three-step-idea.svg", width: 1.38cm), print-icon: image("assets/three-step-idea-print.svg", width: 1.38cm)),
      (title: [استكشف], body: [قارن الاحتمالات، واختبر الاتجاهات الواعدة، وتعلّم من النتائج.], icon: image("assets/three-step-analysis.svg", width: 1.38cm), print-icon: image("assets/three-step-analysis-print.svg", width: 1.38cm)),
      (title: [أنجز], body: [اختر هدفاً واضحاً، واتخذ خطوات مركّزة، واحتفل بالتقدّم.], icon: image("assets/three-step-target.svg", width: 1.38cm), print-icon: image("assets/three-step-target-print.svg", width: 1.38cm)),
    ),
    width: 22cm,
    direction: rtl,
  )
]
