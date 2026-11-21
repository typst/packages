// Six-Step Numbered Card List — dark slide, RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: 13.5cm, margin: 1cm, fill: rgb("#032A3B"))
#set text(font: "DejaVu Sans", size: 8pt, fill: white)
#set par(leading: 0.34em)
#show: faboxyst.with(theme: themes.notebook)

#text(size: 18pt, weight: "bold")[قائمة البطاقات المرقّمة — ست خطوات]
#v(0.48cm)
#six-step-numbered-card-list(
  steps: (
    (title: [حدّد الاتجاه], body: [عرّف الهدف واتفق على معنى النتيجة الناجحة.]),
    (title: [اجمع الحقائق], body: [اجمع المعلومات والآراء والموارد المتاحة.]),
    (title: [استكشف الخيارات], body: [قارن الأساليب الممكنة وحدّد الفرص الأفضل.]),
    (title: [ضع الخطة], body: [اختر الإجراءات والمسؤوليات ونقاط المتابعة.]),
    (title: [ابدأ التنفيذ], body: [تابع العمل وحافظ على التواصل بين أعضاء الفريق.]),
    (title: [راجع التقدّم], body: [قِس النتائج وسجّل الدروس وحدّد الخطوة التالية.]),
  ),
  width: 22cm,
  direction: rtl,
  dark: true,
)
