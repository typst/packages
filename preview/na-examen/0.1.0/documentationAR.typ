// na-examen — الدليل (العربية)
// الترجمة من مجلد الحزمة :  typst compile documentationAR.typ
 #import "@preview/na-examen:0.1.0": *

#set page(paper: "a4", margin: (x: 2cm, y: 2cm), numbering: "1")
// ======================================================================
// ⚙ إعدادات الخط : غيّر القيم التالية فقط (اسم خط أو قائمة خطوط بديلة)
// ======================================================================
#let doc-font   = ("Amiri", "Noto Naskh Arabic", "New Computer Modern")  // خط نص الدليل
#let demo-font  = ("Amiri", "Noto Naskh Arabic", "New Computer Modern")  // خط نتيجة الأمثلة
#let code-font  = ("DejaVu Sans Mono", "Courier New")                     // خط الشيفرة
#let doc-size   = 13pt                                                    // حجم نص الدليل
#let code-size  = 8.6pt                                                   // حجم الشيفرة

#set text(font: doc-font, size: doc-size, lang: "ar", dir: rtl)
#set par(justify: true, leading: 0.8em)
#set heading(numbering: "1.1 –")
#show raw: set text(font: code-font, size: code-size, dir: ltr)
#show raw.where(block: true): set align(left)

// دالة مساعدة : تعرض الشيفرة ثم النتيجة (للدوال exercise و part و q فقط)
#let scope = (exercise: exercise, part: part, q: q, title-style: title-style)
#let demo(code) = {
  let src = code.text
  block(breakable: false, width: 100%, above: 1em, below: 1.2em)[
    #rect(fill: luma(96%), radius: 5pt, width: 100%, inset: 9pt, code)
    #counter("na-examen-exercise").update(0)
    #rect(stroke: 0.5pt + luma(60%), width: 100%, inset: 9pt)[
      #set text(font: demo-font)
      #eval(src, mode: "markup", scope: scope)
    ]
  ]
}

#align(center)[
  #text(26pt, weight: "bold")[na-examen] \
  #text(15pt)[قالب الفروض والاختبارات العربية واللاتينية في Typst] \
  الإصدار 1.1.0
]

#outline(indent: 1.5em, title: [الفهرس])

= مقدّمة

`na-examen` حزمة تجعل كتابة فرض أو اختبار بسيطة، بالعربية (من اليمين إلى اليسار) أو بلغة لاتينية كالفرنسية والإنجليزية (من اليسار إلى اليمين): تكتب نص التمارين فقط، والحزمة ترسم الترويسة (باركود + نص تحته + المؤسسة + السنة + المستوى + الفصل + المادة + المدة) والتذييل «صفحة X من Y»، وترقّم التمارين والأجزاء تلقائيًا.

= الاستعمال

```typ
#import "@preview/na-examen:1.1.0": *

#show: examen.with(
  school: "ثانوية فلان الفلاني",
  year: "2026-2027",
  level: "أولى جذع مشترك علوم وتكنولوجيا",
  term: "الفصل الأول",
  subject: "الرياضيات",
  duration: "2 ســا",
  code: "fard 1 fasl awal-1AS-typst",
)

#exercise(points: 8)[ نص التمرين ... ]
```

أو انسخ مجلد الحزمة بجوار ملفك واكتب `#import "lib.typ": *`. تحتاج الحزمة Typst ≥ 0.13 والخط #strong[Amiri] (للنص) و#strong[Arial] (للعناوين، وإن غاب استُعمل خط بديل).

= القالب `examen`

كل الخيارات اختيارية. غيّر منها ما تريد فقط.

#table(
  columns: (auto, auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*الخيار*], [*الافتراضي*], [*المعنى*],
  [`school`], [حسب اللغة], [المؤسسة (أعلى اليمين في العربية، وأعلى اليسار في اللاتينية)],
  [`year`], [`"2026-2027"`], [السنة الدراسية، تُسبق بـ `year-label`],
  [`level`], [المستوى], [المستوى، يُسبق بـ `level-label`],
  [`term`], [الفصل الأول], [الفصل],
  [`kind`], [فروض], [الكلمة قبل الفصل («فروض الفصل الأول»)؛ `none` لحذفها],
  [`term-label`], [`auto`], [نص السطر كاملًا بدل `kind` + `term`],
  [`exam`], [الفرض المحروس], [نوع الاختبار],
  [`subject`], [الرياضيات], [المادة: «الفرض المحروس في مادة الرياضيات»],
  [`title`], [`auto`], [نص السطر كاملًا بدل `exam` + `subject`],
  [`duration`], [`"2 ســا"`], [المدة؛ `none` لحذفها],
  [`code`], [`"na-examen"`], [النص تحت الباركود؛ `none` لحذفه],
  [`barcode`], [`true`], [رسم الباركود؛ `false` لحذفه],
  [`barcode-height`, `barcode-width`], [`0.64cm`, `5cm`], [شكل الباركود],
  [[`barcode-type`, `barcode-data`, `barcode-cut`], [`"Code128"`, `auto`, `0.25`], [نوع الباركود، القيمة المرمّزة (`auto` = نص `code`)، الجزء المقصوص من أسفله]],
  [`year-label`, `level-label`, `duration-label`, `page-label`, `of-label`], [حسب اللغة], [الكلمات الثابتة],
  [`lang`], [`"ar"`], [لغة المستند وقالبها: `"ar"` أو `"fr"` أو `"en"` أو `"es"` أو `"de"`],
  [`dir`], [`auto`], [`rtl` أو `ltr`؛ `auto` حسب اللغة],
  [`pad-points`], [`true`], [`8` ← «08»؛ و`false` ← «8»],
  [`font`, `title-font`, `size`], [`auto`], [الخطوط والحجم؛ العربية: Amiri وArial و`16pt`؛ اللاتينية: Libertinus Serif وArial و`12pt`],
  [`paper`, `margin`], [`"a4"`], [الصفحة؛ الهوامش كما في الملف الأصلي],
)

الخيارات التي تتركها `auto` (المؤسسة والمستوى والفصل والمادة والكلمات الثابتة والخطوط والحجم) تؤخذ من قالب اللغة. ولغة المستند هي `lang` (والافتراضي `ar`)، فالحزم التي تتبع `#set text(lang: ...)` (مثل `na-tabpos`) تستعمل الكلمات العربية تلقائيًا.

= التمارين `exercise`

`exercise(points: none, title: auto, gap: 1cm)[...]` — العنوان «التمرين الأول» ثم «الثاني»... تلقائيًا، وتُضاف مسافة `gap` قبل كل تمرين عدا الأول.

#demo(```typ
#exercise(points: 8)[
  نص التمرين الأول.
  #q[1] السؤال الأول.

  #q[2] السؤال الثاني.
]
#exercise(points: 1)[نص التمرين الثاني.]
#exercise(points: "04 نقاط", title: [المسألة])[نص المسألة.]
```)

قيمة `points`: عدد (`8` ← «(08 نقاط)»، و`1` ← «(01 نقطة)»)، أو نص يُكتب كما هو بين قوسين، أو `none` فلا تظهر النقاط.

= القالب اللاتيني: الفرنسية والإنجليزية ...

يعمل القالب نفسه بالحروف اللاتينية: اكتب `lang` فيصير الاتجاه من اليسار إلى اليمين، وتتبع الكلمات والخطوط وأسماء التمارين اللغةَ المختارة.

```typ
#show: examen.with(
  lang: "fr",                  // "fr" أو "en" أو "es" أو "de"
  school: "Lycée Ibn Khaldoun",
  level: "1re année secondaire",
  term: "Premier trimestre",
  subject: "Mathématiques",
  duration: "2 h",
)

#exercise(points: 8)[ ... #q[1] ... ]    // "Exercice 1 (08 points)"
#exercise(points: 7)[
  #part(points: 3)[ ... ]                  // "Partie A (03 points)"
  #part(points: 4)[ ... ]
]
```

`examen-latin` تساوي `examen.with(lang: "fr")`، وكذلك `examen-fr` و`examen-en`.

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*`lang`*], [*التمرين*], [*الجزء*], [*النقاط*], [*التذييل*],
  [`ar`], [التمرين الأول], [الجزء الأول], [(08 نقاط)], [صفحة 1 من 3],
  [`fr`], [Exercice 1], [Partie A], [(08 points)], [Page 1 sur 3],
  [`en`], [Exercise 1], [Part A], [(08 points)], [Page 1 of 3],
  [`es`], [Ejercicio 1], [Parte A], [(08 puntos)], [Página 1 de 3],
  [`de`], [Aufgabe 1], [Teil A], [(08 Punkte)], [Seite 1 von 3],
)

للغة أخرى (مثل `lang: "it"`) تُستعمل الكلمات الإنجليزية؛ فغيّرها بالخيارات `year-label` و`level-label` و`duration-label` و`page-label` و`of-label` و`title` و`term-label` و`points: "..."`. ولإضافة لغة دائمة انسخ قالبًا (مثل `_fr`) في `lib.typ` وأضفه إلى `_presets`.

= تغيير الخط

الخط خيار يمكنك تغييره متى شئت، في القالب نفسه:

```typ
#show: examen.with(
  font: "Cairo",                       // خط النص (أو قائمة بدائل)
  title-font: ("Tajawal", "Arial"),    // خط العناوين والترويسة
  size: 15pt,                          // الحجم
)
```

يقبل `font` و`title-font` اسم خط واحدًا أو قائمة خطوط بالترتيب، فيُستعمل أول خط موجود في جهازك. وفي أعلى ملف هذا الدليل متغيرات `doc-font` و`demo-font` و`code-font` تتحكم في خطوط الدليل نفسه.

= الأجزاء `part`

#demo(```typ
#exercise(points: 7)[
  #part(points: 2)[نص الجزء الأول.]
  #part(points: 5)[
    نص الجزء الثاني.
    #q[1] السؤال.
  ]
]
```)

يبدأ ترقيم الأجزاء من جديد مع كل تمرين.

= مربّع السؤال `q`

`#q[1]` يرسم الرقم في مربّع (والاسم `coB` هو الدالة نفسها). و`title-style[...]` عنوان عريض مسطّر.

= أمثلة

مجلد `examples/`: `basic.typ` (الفرض الأصلي كاملًا)، `custom-header.typ` (تغيير كل بيانات الترويسة)، `no-barcode.typ` (بدون باركود ولا مدة)، و`latin-fr.typ` (فرض بالفرنسية)، و`latin-en.typ` (اختبار بالإنجليزية). ومجلد `fichier_de_test/` فيه `long-exam.typ` لاختبار الصفحات المتعددة.
