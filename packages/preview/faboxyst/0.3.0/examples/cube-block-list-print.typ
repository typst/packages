// Cube Block List — monochrome print gallery, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.40em)
#show: faboxyst.with(theme: themes.print)

#let sample = (
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cube-gear-white.svg", width: 0.76cm), print-icon: image("assets/cube-gear-print.svg", width: 0.76cm)),
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cube-brain.svg", width: 0.76cm), print-icon: image("assets/cube-brain.svg", width: 0.76cm)),
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cube-stopwatch-white.svg", width: 0.76cm), print-icon: image("assets/cube-stopwatch-print.svg", width: 0.76cm)),
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cube-database.svg", width: 0.76cm), print-icon: image("assets/cube-database.svg", width: 0.76cm)),
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cube-search.svg", width: 0.76cm), print-icon: image("assets/cube-search.svg", width: 0.76cm)),
  (title: [LOREM IPSUM], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cube-bulb.svg", width: 0.76cm), print-icon: image("assets/cube-bulb.svg", width: 0.76cm)),
)

= Cube block list — print, LTR
#v(0.40cm)
#cube-block-list(steps: sample, width: 22cm, columns: 3, direction: ltr)

#v(0.72cm)
= Same blocks — print, RTL
#v(0.40cm)
#cube-block-list(
  steps: (
    (title: [التخطيط], body: [افهم الموضوع بعمق واجمع المعلومات المهمة ثم رتّب الأفكار بطريقة تساعد على اتخاذ القرار.], icon: image("assets/cube-gear-white.svg", width: 0.76cm), print-icon: image("assets/cube-gear-print.svg", width: 0.76cm)),
    (title: [الابتكار], body: [اكتشف حلولاً جديدة، اختبر الفرضيات، وطوّر الفكرة حتى تصبح قابلة للتطبيق.], icon: image("assets/cube-brain.svg", width: 0.76cm), print-icon: image("assets/cube-brain.svg", width: 0.76cm)),
    (title: [الوقت], body: [نظّم وقتك وحدّد الأولويات، ووازن بين سرعة التنفيذ وجودة النتيجة.], icon: image("assets/cube-stopwatch-white.svg", width: 0.76cm), print-icon: image("assets/cube-stopwatch-print.svg", width: 0.76cm)),
    (title: [البيانات], body: [اجمع البيانات من مصادر موثوقة، وابحث عن الأنماط، ثم لخّص ما تعنيه النتائج.], icon: image("assets/cube-database.svg", width: 0.76cm), print-icon: image("assets/cube-database.svg", width: 0.76cm)),
    (title: [التحليل], body: [افحص الأدلة وقارن النتائج بالهدف، واستعن بالقياس لاختيار الخطوة التالية.], icon: image("assets/cube-search.svg", width: 0.76cm), print-icon: image("assets/cube-search.svg", width: 0.76cm)),
    (title: [الإلهام], body: [أشعل فضولك واستفد من الأفكار الجديدة، ثم حوّلها إلى خطوات عملية.], icon: image("assets/cube-bulb.svg", width: 0.76cm), print-icon: image("assets/cube-bulb.svg", width: 0.76cm)),
  ),
  width: 22cm,
  columns: 3,
  direction: rtl,
)
