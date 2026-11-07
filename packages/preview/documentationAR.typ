// na-corexamen — التوثيق (العربية)
// للتصريف من مجلد الحزمة :  typst compile documentationAR.typ

// ======================================================================
// الألوان : غيّر القيم أدناه فقط
// ======================================================================
#let c-mod  = rgb("#1E4E8C")   // الوحدات (العناوين الرئيسية) : أزرق
#let c-sub  = rgb("#0E8A7D")   // الوحدات الفرعية : أخضر مزرق
#let c-warn = rgb("#B45309")   // التنبيهات : برتقالي
#let c-code = rgb("#9D174D")   // الشيفرة المضمّنة

// ======================================================================
// إعدادات الخطوط : غيّر القيم أدناه فقط
// ======================================================================
#let doc-font   = ("Amiri",)   // أضف خطوطًا بديلة هنا إن شئت (كل خط غير مثبّت يُظهر تحذيرًا)
#let code-font  = ("DejaVu Sans Mono", "Courier New")
#let doc-size   = 14pt
#let code-size  = 8.6pt     // كتل الشيفرة
#let icode-size = 10.5pt    // الشيفرة داخل السطر

#set document(title: "na-corexamen — التوثيق", author: "Naam Mohamed")
#set page(
  paper: "a4",
  margin: (x: 2cm, top: 2cm, bottom: 2.4cm),
  footer: context {
    line(length: 100%, stroke: 0.6pt + c-mod.lighten(55%))
    v(3pt)
    align(center, text(size: 9.5pt, fill: c-mod, dir: ltr)[
      #counter(page).display() / #counter(page).final().first()
    ])
  },
)

#set text(font: doc-font, size: doc-size, lang: "ar", dir: rtl)
#set par(justify: true)
#set heading(numbering: "1.1")
#set list(marker: text(fill: c-sub)[•], body-indent: 0.6em)

#show raw: set text(font: code-font, size: code-size)
#show raw.where(block: false): it => box(
  fill: luma(240), inset: (x: 3pt), outset: (y: 3pt), radius: 2pt,
  text(fill: c-code, size: icode-size, it),
)
#show raw.where(block: true): it => block(
  width: 100%, fill: luma(96%), stroke: 0.5pt + luma(85%), radius: 5pt,
  inset: 9pt, above: 1em, below: 1.2em,
  align(left, text(dir: ltr, it)),
)

// ----------------------------------------------------------------------
// الوحدات (المستوى 1) : شارة ملوّنة برقم الوحدة + عنوان + خط سفلي
// ----------------------------------------------------------------------
#show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 0.9em, sticky: true)[
  #grid(
    columns: (auto, 1fr), column-gutter: 0.7em, align: horizon,
    box(fill: c-mod, radius: 5pt, inset: (x: 0.6em, y: 0.3em),
      text(fill: white, weight: "bold", counter(heading).display(it.numbering))),
    text(fill: c-mod, weight: "bold", size: 1.4em, it.body),
  )
  #v(0.15em)
  #line(length: 100%, stroke: 1.4pt + c-mod.lighten(50%))
]

// ----------------------------------------------------------------------
// الوحدات الفرعية (المستوى 2) : مربّع ملوّن + رقم + عنوان
// ----------------------------------------------------------------------
#show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.6em, sticky: true)[
  #grid(
    columns: (auto, auto, 1fr), column-gutter: 0.5em, align: horizon,
    box(width: 0.55em, height: 0.55em, fill: c-sub, radius: 1.5pt),
    text(fill: c-sub, weight: "bold", counter(heading).display(it.numbering)),
    text(fill: c-sub.darken(15%), weight: "bold", size: 1.1em, it.body),
  )
]

// ----------------------------------------------------------------------
// الفهرس : الوحدات بخط عريض أزرق، والفرعية خضراء، ونقاط وصل خفيفة
// ----------------------------------------------------------------------
#set outline.entry(fill: repeat(gap: 0.35em)[#text(fill: luma(150))[.]])
#show outline.entry.where(level: 1): set text(fill: c-mod, weight: "bold")
#show outline.entry.where(level: 1): set block(above: 1.1em)
#show outline.entry.where(level: 2): set text(fill: c-sub, size: 0.92em)
#show outline.entry.where(level: 2): set block(above: 0.55em)

// ----------------------------------------------------------------------
// أدوات التنسيق
// ----------------------------------------------------------------------
// جدول بسطر عناوين ملوّن وتظليل متناوب (أول خلايا الجدول هي سطر العناوين)
#let tbl(columns, ..cells, color: c-sub) = block(width: 100%, above: 1em, below: 1.2em)[
  #show table.cell.where(y: 0): set text(fill: white, weight: "bold")
  #table(
    columns: columns, inset: 7pt, stroke: 0.5pt + luma(80%),
    fill: (_, y) => if y == 0 { color } else if calc.odd(y) { luma(96%) } else { white },
    ..cells,
  )
]

// مربّع تنبيه بحدّ جانبي ملوّن
#let note(title, body, color: c-warn) = block(
  width: 100%, breakable: false, above: 1em, below: 1em,
  fill: color.lighten(92%), stroke: (right: 3pt + color), radius: 3pt, inset: 10pt,
)[
  #text(fill: color, weight: "bold")[#title] \
  #body
]

// ======================================================================
// الغلاف
// ======================================================================
#block(
  width: 100%, radius: 10pt, inset: (x: 20pt, y: 26pt),
  fill: gradient.linear(c-mod, c-sub, angle: 20deg),
)[
  #set text(fill: white)
  #align(center)[
    #text(size: 30pt, weight: "bold", dir: ltr)[na-corexamen] \
    #v(2pt)
    #text(size: 15pt)[حزمة Typst لتصحيح الفروض والاختبارات — بالعربية واللغات اللاتينية] \
    #v(8pt)
    #box(fill: rgb("#ffffff33"), radius: 20pt, inset: (x: 12pt, y: 4pt))[
      #text(size: 11pt)[الإصدار 0.1.0]
    ]
  ]
]

#v(1.2em)
#block(width: 100%, above: 1em, below: 0.4em)[
  #text(size: 18pt, weight: "bold", fill: c-mod)[فهرس المحتويات]
  #v(0.1em)
  #line(length: 100%, stroke: 1.6pt + c-mod)
]
#outline(title: none, indent: 1.6em)

#pagebreak(weak: true)

// ======================================================================
// المحتوى
// ======================================================================
= مقدمة

== فكرة الحزمة

`na-corexamen` رفيقة حزمة `na-examen`. ترسم *نفس الترويسة* (الباركود، النص تحته، المؤسسة، السنة الدراسية، المستوى، الفصل، المادة، المدة) ونفس تذييل «صفحة X من Y»، وعنوانها «تصحيح الفرض المحروس في مادة …». وترسم لكل التمارين *جدولًا واحدًا متصلًا* من عمودين : *عناصر الإجابة* و#strong[العلامة]، يقبل الانقسام بين الصفحات (ويتكرر سطر العناوين أعلى كل صفحة). وكل تمرين سطر عنوان بعرض الجدول ثم أسطر الحل ثم سطر «المجموع»، ثم يبدأ التمرين التالي مباشرةً في نفس الجدول دون فاصل.

== ما تفعله الحزمة تلقائيًا

تكتب الحل *بحرية تامة* : نصًّا عاديًّا ومعادلات، دون أقواس ولا صيغة خاصة لكل سؤال. وكل ما عليك أن تضع العلامة بالأمر `#mk(...)` في آخر كل خطوة. فتقطع الحزمة نصك عند كل `#mk`، وتضع كل قطعة في سطر من الجدول وعلامتها أمامها، ثم تجمع كل شيء :

- يُختم كل تمرين داخل الجدول بسطر «المجموع» ؛
- ويظهر المجموع في عنوان التمرين أيضًا («التمرين الأول (08 نقاط)») ؛
- وجدول إجمالي اختياري يجمع كل التمارين («20 / 20»).

= البدء السريع

== الاستيراد والترويسة

```typ
#import "@preview/na-corexamen:0.1.0": *

#show: correction.with(
  school: "ثانوية فلان الفلاني",
  year: "2026-2027",
  level: "أولى جذع مشترك علوم وتكنولوجيا",
  term: "الفصل الأول",
  subject: "الرياضيات",
  duration: "2 ســا",
  code: "tashih-fard-1",          // النص تحت الباركود
)
```

== التمارين والجدول الإجمالي

```typ
#exercise[
  #section[I.]                    // سطر عنوان فرعي (اختياري)

  #q[1] اكتب الحل بحرية مع المعادلات $x = 3$ #mk(0.5)

  #q[2] خطوة أخرى من الحل
  $ f(x) = x^2 + 1 $ #mk(1)

  خطوة بعلامتين على جزأين #mk(1, 1)
]

#exercise[
  #part[ #q[1] ... #mk(1) ]       // «الجزء الأول (01 نقطة)»
  #part[ #q[1] ... #mk(2) ]       // «الجزء الثاني (02 نقاط)»
]

#summary(total: 20)               // الجدول الإجمالي والمجموع الكلي
```

= طريقة العمل

== قراءة النص وتقطيعه

داخل `#exercise[ ... ]` يُقرأ النص من الأعلى إلى الأسفل :

- كل ما كُتب *قبل* `#mk(...)` (منذ العلامة السابقة) يصير سطرًا واحدًا من الجدول، وتوضع قيمة العلامة في عمود العلامة من نفس السطر ؛
- `#mk(1, 0.5)` تجمع العددين (هنا 1.5) وتُظهر المجموع فقط ؛
- الأعداد مثل `0.25` و`0.5` و`1.5` مقبولة ؛ ويُنظَّف العرض (`2` وليس `2.0`) ؛
- النص الذي بعد آخر `#mk` (ملاحظة مثل «كل طريقة صحيحة أخرى تُقبل») يصير سطرًا أخيرًا بلا علامة.

== العناوين الفرعية والأجزاء

- `#section[I.]` يصنع سطر عنوان فرعي بعرض الجدول ؛
- `#part[ ... ]` يجمع الأسطر تحت عنوان فرعي «الجزء الأول (03 نقاط)» نقاطه مجموع علاماته ؛ ويُعاد ترقيم الأجزاء مع كل تمرين.

والمعادلات (داخل السطر أو منفصلة) والفقرات كلها مسموحة داخل السطر الواحد من الجدول.

== القواعد الثلاث

#note("ثلاث قواعد")[
  + اكتب `#exercise` في المستوى الأعلى من الوثيقة (لا داخل أمر آخر) ؛
  + واكتب `#mk` و`#section` و`#part` مباشرةً في جسم التمرين (لا داخل أمر آخر مثل `#align[...]` أو `#strong[...]`) ؛
  + ولا تضع قواعد `#set` أو `#show` داخل جسم التمرين ولا بعد `#show: correction` (ضعها قبله).
]

التمارين المتتالية تُدمج في جدول واحد، وأي محتوى آخر بينها (نص أو `#summary`) يغلق الجدول ويبدأ جدول جديد بعده.

= الدوال

== القالب والتمرين

#tbl((auto, 1fr),
  table.header[الدالة][الوصف],
  [`correction`], [القالب : `#show: correction.with(...)`. الصفحة والترويسة والتذييل وكتلة المعلومات.],
  [`exercise(points:, title:, gap:)[...]`], [تمرين : سطر عنوان «التمرين الأول (08 نقاط)» (النقاط من العلامات) وأسطر الحل وسطر «المجموع»، كلها داخل الجدول الواحد. و`gap` بقي للتوافق ولا أثر له.],
)

== العلامات والعناوين الفرعية

#tbl((auto, 1fr),
  table.header[الدالة][الوصف],
  [`mk(..marks)`], [علامة تُكتب في آخر الخطوة : `#mk(0.5)` أو `#mk(0.5, 0.5)`.],
  [`section[...]`], [سطر عنوان فرعي بعرض الجدول.],
  [`part(title:)[...]`], [جزء داخل تمرين («الجزء الأول (02 نقاط)») ؛ نقاطه مجموع علاماته.],
)

== أدوات مساعدة

#tbl((auto, 1fr),
  table.header[الدالة][الوصف],
  [`q[1]`], [مربّع رقم السؤال (الاسم `coB` يؤدي نفس الدور).],
  [`summary(total:, title:, gap:)`], [جدول إجمالي : سطر لكل تمرين والمجموع الكلي.],
  [`title-style[...]`], [عنوان بخط عريض ومسطّر.],
)

= المراجعة التلقائية

== مراجعة التمرين

`exercise(points: 8)` : إن لم يكن مجموع العلامات 8 يظهر `⚠ المعلن : 8` بالأحمر في سطر «المجموع». وبدون `points` يعرض العنوان المجموع المحسوب ببساطة.

== مراجعة الجدول الإجمالي

`summary(total: 20)` : تعرض الخلية الأخيرة `20 / 20` إن جمعت التمارين 20 بالضبط ؛ وإلا عرضت المجموع المحسوب مع `⚠ المعلن : 20` بالأحمر. وبدون `total` تعرض المجموع الكلي فقط.

= خيارات `correction`

== الترويسة والباركود

#tbl((auto, auto, 1fr),
  table.header[الخيار][الافتراضي][المعنى],
  [`school`، `year`، `level`، `term`], [حسب اللغة], [معلومات الترويسة],
  [`kind`], [`"فروض"`], [كلمة قبل الفصل ؛ `none` لحذفها],
  [`term-label`], [`auto`], [نص الفصل كاملًا بدل `kind` + `term`],
  [`exam`، `subject`], [حسب اللغة], [نوع الاختبار والمادة],
  [`title`], [`auto`], [سطر العنوان كاملًا بدل «تصحيح …» التلقائي],
  [`duration`], [حسب اللغة], [المدة ؛ `none` لحذفها],
  [`code`], [`"na-corexamen"`], [النص تحت الباركود ؛ `none` لحذفه],
  [`barcode`، `barcode-type`، `barcode-data`، `barcode-height`، `barcode-width`، `barcode-cut`], [`true`، `"Code128"`، `auto`، `0.64cm`، `5cm`، `0.25`], [الباركود (كما في `na-examen`)],
)

== المظهر والجداول

#tbl((auto, auto, 1fr),
  table.header[الخيار][الافتراضي][المعنى],
  [`decimal`], [`"."`], [فاصلة الأعداد في كل العلامات],
  [`head-fill`، `sub-fill`], [`luma(215)`، `luma(238)`], [ألوان سطر العناوين والعناوين الفرعية وسطر المجموع],
  [`table-stroke`، `table-inset`، `mark-width`], [`0.6pt + black`، `7pt`، `2.4cm`], [الخطوط والحشو وعرض عمود العلامة],
  [`pad-points`], [`true`], [`8` تصير `08`],
  [`paper`، `margin`], [`"a4"`، كما في `na-examen`], [الصفحة],
)

== النصوص الثابتة

#tbl((auto, auto, 1fr),
  table.header[الخيار][الافتراضي][المعنى],
  [`ex-label`، `ans-label`، `mark-label`، `total-label`، `summary-label`], [حسب اللغة], [كلمات ثابتة في الجداول],
  [`year-label`، `level-label`، `duration-label`، `page-label`، `of-label`], [حسب اللغة], [كلمات الترويسة والتذييل],
)

== اللغة والخطوط

#tbl((auto, auto, 1fr),
  table.header[الخيار][الافتراضي][المعنى],
  [`lang`], [`"ar"`], [`"ar"` أو `"fr"` أو `"en"` أو `"es"` أو `"de"`],
  [`font`، `title-font`، `size`], [حسب اللغة], [الخطوط والحجم],
)

= اللغات

== اختيار اللغة

`lang: "ar"` (الافتراضي، من اليمين إلى اليسار) أو `lang: "fr"` و`"en"` و`"es"` و`"de"` (من اليسار إلى اليمين). اختصارات : `correction-fr` و`correction-en` و`correction-latin`. وكل خيار تتركه على `auto` يؤخذ من اللغة.

== ما تغيّره اللغة

#tbl((auto, auto, auto, auto),
  table.header[اللغة][العنوان][التمرين][المجموع],
  [`ar`], [تصحيح الفرض المحروس في مادة …], [التمرين الأول (08 نقاط)], [المجموع],
  [`fr`], [Corrigé — Devoir surveillé de …], [Exercice 1 (08 points)], [Total],
  [`en`], [… Test — Marking scheme], [Exercise 1 (08 points)], [Total],
  [`es`], [Solucionario — Examen de …], [Ejercicio 1 (08 puntos)], [Total],
  [`de`], [Lösung — Klassenarbeit in …], [Aufgabe 1 (08 Punkte)], [Summe],
)

= الملفات

```
lib.typ  typst.toml  LICENSE  README.md
documentationEN.typ  documentationAR.typ     (قم بتصريفهما للحصول على ملفات PDF)
examples/   basic.typ  latin-fr.typ  latin-en.typ
```

= الرخصة

MIT.
