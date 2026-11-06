// تغيير المؤسسة والسنة والفصل والنص تحت الباركود وبقية الخيارات
#import "../lib.typ": *
#show: examen.with(
 // title-font: "ae_AlBattar",
  school: "متوسطة الأمير عبد القادر - تلمسان",
  year: "2026-2027",
  level: "السنة الرابعة متوسط",
  term: "الفصل الثاني",
  kind: "اختبار",
  exam: "الاختبار",
  subject: "الفيزياء",
  duration: "ساعة ونصف",
  code: "test 2 fasl thani-4AM",
  size: 15pt
)
#exercise(points: 7)[
  نص التمرين الأول هنا.

  #q[1] السؤال الثاني.
]

// عنوان يدوي بدل الترقيم التلقائي
#exercise(points: "04 نقاط", title: [المسألة])[
  نص المسألة هنا.
]
