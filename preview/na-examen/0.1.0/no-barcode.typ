// بدون باركود وبدون نص تحته وبدون مدة ، وسطر الفصل مكتوب كاملًا
#import "../lib.typ": *

#show: examen.with(
  school: "ثانوية ابن خلدون",
  level: "ثالثة ثانوي علوم تجريبية",
  term-label: "الامتحان التجريبي",
  title: "امتحان في مادة الرياضيات",
  duration: none,
  barcode: false,
  code: none,
)

#exercise(points: 5)[نص التمرين الأول.]

#exercise(points: 1)[تمرين بنقطة واحدة : يظهر «01 نقطة».]
