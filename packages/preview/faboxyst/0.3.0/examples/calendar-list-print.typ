// Calendar List — monochrome print cards in LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 22cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.42em)
#show: faboxyst.with(theme: themes.print)

#let sample = (
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/calendar-stopwatch.svg", width: 0.82cm), print-icon: image("assets/calendar-stopwatch-print.svg", width: 0.82cm)),
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/calendar-clipboard.svg", width: 0.82cm), print-icon: image("assets/calendar-clipboard-print.svg", width: 0.82cm)),
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/calendar-bell.svg", width: 0.82cm), print-icon: image("assets/calendar-bell-print.svg", width: 0.82cm)),
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/calendar-briefcase.svg", width: 0.82cm), print-icon: image("assets/calendar-briefcase-print.svg", width: 0.82cm)),
)

= Calendar List — print, LTR
#calendar-list(steps: sample, width: 18cm, columns: 4, direction: ltr)

#v(0.55cm)
= Same cards — print, RTL
#calendar-list(
  steps: (
    (title: [التخطيط], body: [راجع الخطة وحدّد المهام والمواعيد المهمة خلال الأسبوع.], icon: image("assets/calendar-stopwatch.svg", width: 0.82cm), print-icon: image("assets/calendar-stopwatch-print.svg", width: 0.82cm)),
    (title: [المتابعة], body: [تحقق من الإنجاز ودوّن الملاحظات التي تحتاج إلى متابعة.], icon: image("assets/calendar-clipboard.svg", width: 0.82cm), print-icon: image("assets/calendar-clipboard-print.svg", width: 0.82cm)),
    (title: [التذكير], body: [استعد للموعد القادم وتواصل مع أعضاء الفريق عند الحاجة.], icon: image("assets/calendar-bell.svg", width: 0.82cm), print-icon: image("assets/calendar-bell-print.svg", width: 0.82cm)),
    (title: [الإنجاز], body: [أنهِ المهام في وقتها وسجّل النتائج والخطوات التالية.], icon: image("assets/calendar-briefcase.svg", width: 0.82cm), print-icon: image("assets/calendar-briefcase-print.svg", width: 0.82cm)),
  ),
  width: 18cm,
  columns: 4,
  direction: rtl,
)
