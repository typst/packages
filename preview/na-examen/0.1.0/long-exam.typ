// اختبار : عدة صفحات (التذييل «صفحة X من Y») وعناوين لا تبقى وحدها في آخر الصفحة
#import "@preview/na-examen:0.1.0": *

#show: examen.with(code: "long test", duration: "3 ســا")

#for i in range(1, 7) [
  #exercise(points: 3)[
    #for j in range(1, 9) [
      #q[#j] سؤال رقم #j في التمرين #i : نص طويل نسبيًا ليملأ الصفحة ويختبر الانتقال بين الصفحات.

    ]
  ]
]
