// Banners w/ Circles — adjustable-width LTR and RTL reference galleries.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 22cm, height: auto, margin: 1cm, fill: rgb("#F2EFF1"))
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.notebook)

#let sample = (
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas.], icon: image("assets/bwc-people.svg", width: 0.58cm), print-icon: image("assets/bwc-people-print.svg", width: 0.58cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas.], icon: image("assets/bwc-chat.svg", width: 0.58cm), print-icon: image("assets/bwc-chat-print.svg", width: 0.58cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas.], icon: image("assets/bwc-plane.svg", width: 0.58cm), print-icon: image("assets/bwc-plane-print.svg", width: 0.58cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas.], icon: image("assets/bwc-gear.svg", width: 0.58cm), print-icon: image("assets/bwc-gear-print.svg", width: 0.58cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas.], icon: image("assets/bwc-chart.svg", width: 0.58cm), print-icon: image("assets/bwc-chart-print.svg", width: 0.58cm)),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas.], icon: image("assets/bwc-briefcase.svg", width: 0.58cm), print-icon: image("assets/bwc-briefcase-print.svg", width: 0.58cm)),
)

= Banners with circles — LTR
#banners-with-circles(steps: sample, width: 18cm, columns: 2, direction: ltr)

#v(0.45cm)
= Same banners — RTL
#banners-with-circles(
  steps: (
    (title: [الفكرة], body: [اجمع الملاحظات وحدّد السؤال الذي تريد الإجابة عنه.], icon: image("assets/bwc-people.svg", width: 0.58cm), print-icon: image("assets/bwc-people-print.svg", width: 0.58cm)),
    (title: [التخطيط], body: [اختر الطريقة المناسبة ونظّم الموارد اللازمة.], icon: image("assets/bwc-chat.svg", width: 0.58cm), print-icon: image("assets/bwc-chat-print.svg", width: 0.58cm)),
    (title: [التنفيذ], body: [نفّذ الخطة بالتعاون مع الفريق خطوة بخطوة.], icon: image("assets/bwc-plane.svg", width: 0.58cm), print-icon: image("assets/bwc-plane-print.svg", width: 0.58cm)),
    (title: [التحقق], body: [تابع التقدم وتأكد من جودة النتائج.], icon: image("assets/bwc-gear.svg", width: 0.58cm), print-icon: image("assets/bwc-gear-print.svg", width: 0.58cm)),
    (title: [التحسين], body: [استخلص الدروس وحسّن الخطوات التالية.], icon: image("assets/bwc-chart.svg", width: 0.58cm), print-icon: image("assets/bwc-chart-print.svg", width: 0.58cm)),
    (title: [الإنجاز], body: [احتفل بالنتيجة وشاركها مع الآخرين.], icon: image("assets/bwc-briefcase.svg", width: 0.58cm), print-icon: image("assets/bwc-briefcase-print.svg", width: 0.58cm)),
  ),
  width: 18cm,
  columns: 2,
  direction: rtl,
)
