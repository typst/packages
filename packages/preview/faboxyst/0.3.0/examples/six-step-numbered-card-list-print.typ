// Six-Step Numbered Card List — monochrome print, LTR and RTL.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 24cm, height: auto, margin: 1cm, fill: white)
#set text(font: "DejaVu Sans", size: 8pt)
#set par(leading: 0.34em)
#show: faboxyst.with(theme: themes.print)

#text(size: 14pt, weight: "bold")[6-Step Numbered Card List — print, LTR]
#v(0.25cm)
#print-group[
  #six-step-numbered-card-list(
    steps: (
      (title: [Set the direction], body: [Define the goal and agree on what a successful outcome means.]),
      (title: [Gather the facts], body: [Collect useful information, perspectives, and available resources.]),
      (title: [Explore options], body: [Compare possible approaches and identify the strongest opportunities.]),
      (title: [Make a plan], body: [Choose clear actions, owners, and realistic checkpoints.]),
      (title: [Take action], body: [Move the work forward and keep communication open across the team.]),
      (title: [Review progress], body: [Measure the results, capture lessons, and decide what comes next.]),
    ),
    width: 22cm,
    direction: ltr,
    monochrome: true,
  )
]

#v(0.50cm)
#text(size: 14pt, weight: "bold")[Same cards — print, RTL]
#v(0.25cm)
#print-group[
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
    monochrome: true,
  )
]
