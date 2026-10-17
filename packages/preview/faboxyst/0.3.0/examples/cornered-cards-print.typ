// Cornered Cards — monochrome print gallery, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.42em)
#show: faboxyst.with(theme: themes.print)

#let sample = (
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cornered-balloon.svg", width: 0.78cm), print-icon: image("assets/cornered-balloon.svg", width: 0.78cm), number: [01]),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cornered-cake.svg", width: 0.78cm), print-icon: image("assets/cornered-cake.svg", width: 0.78cm), number: [02]),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cornered-bunting.svg", width: 0.78cm), print-icon: image("assets/cornered-bunting.svg", width: 0.78cm), number: [03]),
  (title: [Lorem Ipsum], body: [Lorem ipsum dolor sit amet, nibh est. A magna maecenas, quam magna nec quis, lorem nunc. Suspendisse viverra sodales mauris, cras pharetra proin egestas arcu erat dolor, at amet.], icon: image("assets/cornered-gift.svg", width: 0.78cm), print-icon: image("assets/cornered-gift.svg", width: 0.78cm), number: [04]),
)

= Cornered cards — print, LTR
#v(0.45cm)
#cornered-cards(steps: sample, width: 22cm, columns: 4, direction: ltr)

#v(0.72cm)
= Same cards — print, RTL
#v(0.45cm)
#cornered-cards(
  steps: (
    (title: [الذكرى], body: [اجمع الأفكار والملاحظات المهمة، رتّبها بوضوح، وشاركها مع الفريق للانطلاق معاً نحو الهدف.], icon: image("assets/cornered-balloon.svg", width: 0.78cm), print-icon: image("assets/cornered-balloon.svg", width: 0.78cm), number: [01]),
    (title: [الاحتفال], body: [احتفل بالإنجازات الصغيرة، وامنح كل خطوة وقتها، ثم استعدّ للمحطة التالية بثقة وحماس.], icon: image("assets/cornered-cake.svg", width: 0.78cm), print-icon: image("assets/cornered-cake.svg", width: 0.78cm), number: [02]),
    (title: [الفريق], body: [تعاون مع الفريق ووزّع المهام بوضوح، واستفد من مهارات الجميع لصناعة نتيجة أفضل.], icon: image("assets/cornered-bunting.svg", width: 0.78cm), print-icon: image("assets/cornered-bunting.svg", width: 0.78cm), number: [03]),
    (title: [العطاء], body: [شارك النتيجة مع الآخرين، وقدّم أفكارك بكرم، وافتح المجال لتجارب وفرص جديدة.], icon: image("assets/cornered-gift.svg", width: 0.78cm), print-icon: image("assets/cornered-gift.svg", width: 0.78cm), number: [04]),
  ),
  width: 22cm,
  columns: 4,
  direction: rtl,
)
