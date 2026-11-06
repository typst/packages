// Alternating Line Block Process — LTR and RTL reference examples.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 22cm, height: auto, margin: 1cm, fill: rgb("#F2EFF1"))
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.notebook)

= Alternating Line Block Process

#alternating-line-block-process(
  direction: ltr,
  width: 18cm,
  height: 6.20cm,
  gap: 0.72cm,
  steps: (
    (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/alternating-idea-print.svg", width: 0.58cm)),
    (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/alternating-target-print.svg", width: 0.58cm)),
    (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/alternating-gears-print.svg", width: 0.58cm)),
    (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/line-process-database.svg", width: 0.58cm), print-icon: image("assets/line-process-database-print.svg", width: 0.58cm)),
  ),
)

#v(0.55cm)
#text(lang: "en", dir: ltr, size: 12pt, weight: "bold")[Same process — RTL]
#v(0.18cm)
#alternating-line-block-process(
  direction: rtl,
  width: 18cm,
  height: 6.20cm,
  gap: 0.72cm,
  steps: (
    (title: [الفكرة], body: [ابدأ بفكرة واضحة، واجمع الملاحظات وحدّد السؤال الذي تريد الإجابة عنه.], icon: image("assets/alternating-idea-print.svg", width: 0.58cm)),
    (title: [التخطيط], body: [اختر طريقة العمل المناسبة، ونظّم الخطوات والموارد اللازمة للتنفيذ.], icon: image("assets/alternating-target-print.svg", width: 0.58cm)),
    (title: [التنفيذ], body: [نفّذ الخطة بالتعاون مع الفريق، وتابع التقدم خطوة بعد خطوة.], icon: image("assets/alternating-gears-print.svg", width: 0.58cm)),
    (title: [النتيجة], body: [راجع النتائج، واستخلص الدروس التي ستفيدك في المرحلة التالية.], icon: image("assets/line-process-database.svg", width: 0.58cm), print-icon: image("assets/line-process-database-print.svg", width: 0.58cm)),
  ),
)
