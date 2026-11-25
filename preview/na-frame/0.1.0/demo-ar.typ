#import "@preview/na-frame:0.1.0": *

// نسخة عربية: كل الإطارات (60). العنوان والمحتوى من كتابتك أنت:
//   #theorem-frame(title: [عنواني الخاص])[ المحتوى الذي أريده ]
#set page(paper: "a4", margin: 18mm)
#set text(font: "Noto Naskh Arabic", lang: "ar", dir: rtl, size: 13pt)
#set par(leading: .7em)

= عرض إطارات na-frame (عربي)

#theorem-frame(title: [مبرهنة فيثاغورس])[
  في مثلث قائم: $ a^2 + b^2 = c^2 $
]

#blue-frame(title: [تعريف الدالة], color: palette.indigo)[
  علاقة تربط كل عنصر بعنصر واحد على الأكثر.
]

#green-frame(title: [تمرين 1], subtitle: [4 نقاط], color: palette.green)[
  احسب $ lim_(x -> 0) (sin x)/x $
]

#shadow-frame(title: [مثال محلول], color: palette.crimson)[
  ظل متدرج وطية زاوية.
]

#proof-frame(title: [البرهان])[
  نفرض أن ... ثم نستنتج أن ...
]

#flag-frame(title: [خاصية مهمة])[
  نص الخاصية.
]

#gradient-frame(title: [ملاحظة], color: palette.teal)[
  عنوان متدرج اللون.
]

#chapter-frame(title: [خطة الفصل])[
  + الدوال
    + النهايات
    + الاشتقاقية
]

#ribbon-frame(title: [تذكير])[
  شريط عريض بأطراف مطوية.
]

#board-frame(title: [السبورة], color: palette.orange)[
  إطار سبورة مشطوف.
]

#paper-frame(title: [ورقة])[
  ورقة مدبّسة بزاوية ملتفة.
]

#sticky-frame(title: [لا تنسَ])[
  ورقة لاصقة صفراء.
]

#notebook-frame(title: [دفتر الأعمال])[
  دفتر بحلقات معدنية.
]

#corner-rule-frame(title: [مبرهنة])[
  عنوان فرعي في الجهة المقابلة.
]

#properties-frame(title: [خواص])[
  $ overline(z_1 + z_2) = overline(z_1) + overline(z_2) $
]

#folded-definition-frame(title: [تعريف])[
  خانة عنوان مطوية.
]

#centered-info-frame(title: [معلومات هامة])[
  عنوان في الوسط بين شريطين.
]

#double-tab-frame(title: [خاصية])[
  خانتا عنوان: رئيسية وفرعية.
]

#torn-paper-frame(title: [ورقة ممزقة])[
  حواف ممزقة مع ظل.
]

#spiral-banner-frame(title: [عنوان من اختياري])[
  شريط عنوان وسلك جانبي.
]

#notebook-page-frame(title: [مبرهنة القيم المتوسطة], paper-color: rgb("#cdeef8"))[
  ورقة دفتر مسطّرة.
]

#numbered-exercise-frame(title: [التمرين], third-title: [الأعداد المركبة])[
  الترقيم تلقائي.
]

#numbered-frame(title: [التمرين رقم], number: [02])[
  نص التمرين.
]

#property-frame(title: [خاصية], badge-top: [أضف إلى], badge-bottom: [معلوماتك])[
  نص الخاصية.
]

#exercise-card(title: [تمرين شامل])[
  الأسئلة مستقلة.
]

#exam-frame(title: [التمرين رقم], number: 3)[
  نص التمرين.
]

#tab-frame(title: [تعريف])[
  نص التعريف.
]

#curved-tab-frame(title: [نشاط])[
  نص.
]

#speech-frame(title: [ملاحظة])[
  نص الملاحظة.
]

#rounded-tab-frame(title: [تذكير])[
  نص.
]

#right-rule-frame(title: [قاعدة])[
  نص.
]

#folded-corner-frame(title: [نشاط 1])[
  نص.
]

#subtitle-frame(title: [تمرين في الدوال])[
  نص.
]

#outlined-tab-frame(title: [تعريف])[
  نص.
]

#inset-tab-frame(title: [تعريف])[
  نص.
]

#side-notebook-frame(title: [دفتر جانبي])[
  نص.
]

#binder-notebook-frame(title: [ملاحظة])[
  نص.
]

#framed-exercise(title: [تمرين شامل في الدوال])[
  نص التمرين.
]

#sheet-frame(title: [تمرين])[
  ارتفاع المحتوى يتبع ما تكتبه.
]

#bevel-frame(title: [إطار مشطوف])[
  نص.
]

#lace-frame(title: [دانتيل])[
  نص.
]

#illuminated-frame(title: [مزخرف])[
  نص.
]

#geometric-frame(title: [هندسي])[
  نص.
]

#math-cover-frame(title: [سلسلة المتميز])[
  نص.
]

#vintage-frame(title: [قديم])[
  نص.
]

#jewel-frame(title: [جوهرة])[
  نص.
]

#star-chain-frame(title: [سلسلة نجوم])[
  نص.
]

#lantern-frame(title: [فانوس])[
  نص.
]

#botanical-frame(title: [نباتي])[
  نص.
]

#emerald-frame(title: [زمردي])[
  نص.
]

#right-scroll-frame(title: [درج])[
  نص.
]

#homework-sheet(title: [ورقة واجب])[
  نص.
]

#homework-sheet-modern(title: [تطبيق])[
  نص.
]

#practical-notebook(title: [أعمال تطبيقية])[
  نص.
]

#warning-note(title: [تنبيه])[
  نص مهم.
]

#ribbon-notes-frame(title: [ملاحظات هامة])[
  ليكن $z$ عددًا مركبًا غير معدوم، مكتوبًا بالشكل المثلثي:
  $ z = r (cos(theta) + i sin(theta)). $

  #list(marker: text(fill: palette.purple)[◀],
    [طويلة العدد $z$ هي $r$، حيث $r > 0$.],
    [لكل عدد طبيعي $n$، لدينا: $z^n = r^n (cos(n theta) + i sin(n theta))$.],
    [يكون $z^n$ حقيقيًا إذا وفقط إذا كان $sin(n theta) = 0$.],
    [يكون $z^n$ تخيليًا صرفًا إذا وفقط إذا كان $cos(n theta) = 0$.],
  )
]

#grid-notebook-frame(title: [تمرين تطبيقي])[
  في هذا النشاط ننظّم أفكارنا ونطبّق ما درسناه خطوةً بخطوة.

  نكتب خطوات العمل بوضوح ونراجع النتائج.
]

#prerequisites-frame(items: (
  ([المكتسبات القبلية], [مبرهنة فيثاغورس، التحويلات النقطية البسيطة.]),
  ([الكفاءات المستهدفة], [استعمال خواص التحويلات النقطية لحل مسائل هندسية.]),
  ([الأدوات المستعملة], [الكتاب المدرسي، الأدوات الهندسية، برنامج جيوجيبرا.]),
))

#folded-ribbon-frame(title: [الواجب المنزلي رقم 1])[
  بسّط العدد $sqrt(sqrt(3^8))$ ثم اذكر أصغر مجموعة ينتمي إليها.
]

#hanging-tab-frame(title: [تمرين في الدوال اللوغاريتمية])[
  حل في $RR$ المعادلة: $ln(x) + ln(x - 1) = ln(6)$.
]

#winged-tab-frame(title: [ملاحظة])[
  لسان في الوسط بجناحين وحدّ منقّط داخلي.
]

#badge-notebook-frame(title: [أعمال تطبيقية])[
  في هذا النشاط ننظّم أفكارنا ونطبّق ما درسناه خطوةً بخطوة.

  نكتب خطوات العمل بوضوح ونراجع النتائج.
]

#ribbon-banner(title: [عنوان من اختياري])

#arched-ribbon(title: [عنوان من اختياري])

// الدفعة الرابعة بنسختها اللاتينية (dir: ltr) داخل المستند العربي.
#folded-ribbon-frame(dir: ltr, title: [Homework no. 1])[Latin version: the ribbon and folds are mirrored, the text is not.]
#hanging-tab-frame(dir: ltr, title: [Exercise])[Latin version: the tab hangs on the left.]
#winged-tab-frame(dir: ltr, title: [Note])[Latin version.]
#badge-notebook-frame(dir: ltr, title: [Practical work])[Latin version: badge and heel on the left.]

// إطار لاتيني داخل مستند عربي، بعنوان ومحتوى من اختيارك.
#theorem-frame(dir: ltr, title: [My own title])[Latin frame inside an Arabic document: $ a^2 + b^2 = c^2 $]
#frame("blue", dir: ltr, title: [Definition])[A definition in LTR.]

// عنوان واحد بنسختين: يُختار حسب لغة الإطار.
#theorem-frame(title: (ar: [مبرهنة], en: [Theorem]))[عنوان عربي.]
#theorem-frame(dir: ltr, title: (ar: [مبرهنة], en: [Theorem]))[English title chosen automatically.]

// اختبار التقسيم بين الصفحات.
#theorem-frame(title: [اختبار التقسيم])[
  #for i in range(60) [سطر رقم #i من نص طويل لاختبار انتقال الإطار بين الصفحات. \ ]
]
