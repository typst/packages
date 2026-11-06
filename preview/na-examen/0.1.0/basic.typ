// نفس ملف fard1annee.typ لكن باستعمال الحزمة : المستخدم يكتب نص التمارين فقط
#import "../lib.typ": *

#show: examen.with(
  school: "ثانوية فلان الفلاني",
  year: "2026-2027",
  level: "أولى جذع مشترك علوم وتكنولوجيا",
  term: "الفصل الأول",
  subject: "الرياضيات",
  duration: "2 ســا",
  code: "fard 1 fasl awal-1AS-typst",
)

#exercise(points: 8)[
  *I.*
  ليكن العددين $A$ و $B$ حيث :
  $A = 27300$ و $B = (2 times 3)^3 times 27 times 5 times (-1)^1962$

  #q[1] حلل إلى جداء عوامل أولية كلا من $A$ و $B$ .

  #q[2] احسب كلا من $"PPCM"(A; B)$ و $"PGCD"(A; B)$ .

  *II.*
  أكتب العدد $a = 0"."underline(233766)$ على شكل كسر غير قابل للاختزال.

  #q[1] أكتب $a$ على الشكل العلمي.

  #q[2] عين رتبة مقدار العدد $a$ .
]

#exercise(points: 5)[
  $A$ ، $B$ ، $C$ ، $D$ أعداد حقيقية حيث :

  $ A = sqrt((3 sqrt(6) + 2)/2) times sqrt((3 sqrt(6) - 2)/5) $

  $ B = (-8^2 times 3^5 times 6^7)/(4^3 times (-3)^3 times 12^2) $

  $ C = ((3 sqrt(2) + sqrt(13))/sqrt(5))^2025 times ((3 sqrt(2) - sqrt(13))/sqrt(5))^2025 $

  $ D = ((a + b)^2 + (a - b)^2)/(a^2 + b^2) $

  حيث $a$ و $b$ عددان حقيقيان .

  $triangle.filled.small.l$
  بسط الأعداد $A$ ، $B$ ، $C$ ، $D$ وعين أصغر مجموعة تنتمي إليها.
]

#exercise(points: 7)[
  #part(points: 2)[
    نعتبر العدد الحقيقي
    $X = sqrt(7 sqrt(7 sqrt(7 sqrt(7 sqrt(7 dots.c)))))$

    عين القيمة المضبوطة لـ $X$ .
  ]

  #part(points: 5)[
    $a$ و $b$ عددان حقيقيان موجبان حيث : $a < b$

    علما أن : $a + b = 7$ و $a times b = 12$

    #q[1] احسب قيمة $sqrt(a) + sqrt(b)$ و $sqrt(a) - sqrt(b)$ .

    #q[2] استنتج قيمة $a - b$ .

    #q[3] أوجد قيمة كل من $a$ و $b$ .
  ]
]
