// Cards With Corner Sleeve — colored sleeve cards in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: rgb("#F2EFF1"))
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.notebook)

#let sample = (
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/corner-sleeve-rocket.svg", width: 0.78cm), print-icon: image("assets/corner-sleeve-rocket-print.svg", width: 0.78cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/corner-sleeve-group.svg", width: 0.78cm), print-icon: image("assets/corner-sleeve-group-print.svg", width: 0.78cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/corner-sleeve-puzzle.svg", width: 0.78cm), print-icon: image("assets/corner-sleeve-puzzle-print.svg", width: 0.78cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/corner-sleeve-bulb.svg", width: 0.78cm), print-icon: image("assets/corner-sleeve-bulb-print.svg", width: 0.78cm)),
)

= Cards with corner sleeve — LTR
#v(0.4cm)
#cards-with-corner-sleeve(steps: sample, width: 22cm, columns: 4, direction: ltr)

#v(0.55cm)
= Same cards — RTL
#v(0.4cm)
#cards-with-corner-sleeve(
  steps: (
    (title: [الفكرة], body: [اجمع الملاحظات وحدّد السؤال الذي تريد الإجابة عنه.], icon: image("assets/corner-sleeve-rocket.svg", width: 0.78cm), print-icon: image("assets/corner-sleeve-rocket-print.svg", width: 0.78cm)),
    (title: [الفريق], body: [تعاون مع الفريق ووزّع الأدوار بوضوح.], icon: image("assets/corner-sleeve-group.svg", width: 0.78cm), print-icon: image("assets/corner-sleeve-group-print.svg", width: 0.78cm)),
    (title: [الحلول], body: [حلّل المشكلة وجرّب حلولاً مختلفة.], icon: image("assets/corner-sleeve-puzzle.svg", width: 0.78cm), print-icon: image("assets/corner-sleeve-puzzle-print.svg", width: 0.78cm)),
    (title: [الإلهام], body: [حوّل الأفكار الجديدة إلى خطوات عملية.], icon: image("assets/corner-sleeve-bulb.svg", width: 0.78cm), print-icon: image("assets/corner-sleeve-bulb-print.svg", width: 0.78cm)),
  ),
  width: 22cm,
  columns: 4,
  direction: rtl,
)
