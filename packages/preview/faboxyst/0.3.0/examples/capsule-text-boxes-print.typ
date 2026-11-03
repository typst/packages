// Capsule Text Boxes — monochrome print preview in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 22cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.42em)
#show: faboxyst.with(theme: themes.print)

#let sample = (
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/capsule-idea.svg", width: 0.72cm), print-icon: image("assets/capsule-idea-print.svg", width: 0.72cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/capsule-stopwatch.svg", width: 0.72cm), print-icon: image("assets/capsule-stopwatch-print.svg", width: 0.72cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/capsule-gears.svg", width: 0.72cm), print-icon: image("assets/capsule-gears-print.svg", width: 0.72cm)),
)

= Capsule Text Boxes — print, LTR
#capsule-text-boxes(steps: sample, width: 18cm, columns: 3, direction: ltr)

#v(0.55cm)
= Same cards — print, RTL
#capsule-text-boxes(
  steps: (
    (title: [الفكرة], body: [اجمع الملاحظات وحدّد السؤال الذي تريد الإجابة عنه.], icon: image("assets/capsule-idea.svg", width: 0.72cm), print-icon: image("assets/capsule-idea-print.svg", width: 0.72cm)),
    (title: [التخطيط], body: [اختر الطريقة المناسبة ونظّم الموارد والخطوات.], icon: image("assets/capsule-stopwatch.svg", width: 0.72cm), print-icon: image("assets/capsule-stopwatch-print.svg", width: 0.72cm)),
    (title: [التنفيذ], body: [نفّذ الخطة وتابع التقدم خطوة بعد خطوة.], icon: image("assets/capsule-gears.svg", width: 0.72cm), print-icon: image("assets/capsule-gears-print.svg", width: 0.72cm)),
  ),
  width: 18cm,
  columns: 3,
  direction: rtl,
)
