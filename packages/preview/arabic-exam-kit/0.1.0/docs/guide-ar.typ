// Arabic Exam Kit — الدليل العربي للمبتدئ
#import "../src/lib.typ": *

#set page(paper: "a4", margin: (x: 1.55cm, y: 1.4cm), numbering: "1 / 1")
#set text(font: "Amiri", lang: "ar", dir: rtl, size: 12pt, fill: rgb("#17212A"))
#set par(leading: .48em, justify: true)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 25pt, weight: "bold", fill: wexam-palette.blue-dark)[Arabic Exam Kit]
  #v(.4em)
  #text(size: 17pt)[الدليل العربي العملي للمبتدئ في Typst]
  #v(1em)
  #mf-paint-splat(model: 9, width: 4.7cm, height: 3.7cm)
]

#v(1em)

هذا الدليل يشرح خطوة بخطوة كيفية إنشاء ورقة تمارين أو اختبار رياضيات باللغة
العربية باستعمال Typst. ستتعلم استيراد الحزمة، اختيار النموذج، كتابة الأسئلة
وتشغيل النمط اليدوي `rough`.

#v(1em)
#text(weight: "bold")[ماذا ستتعلم؟]

- تثبيت الحزمة واستيرادها؛
- استعمال النماذج الحمراء والسوداء والزرقاء؛
- إنشاء أسئلة مرقمة وصناديق التنقيط؛
- رسم الأشكال الهندسية؛
- استعمال الورقة البيداغوجية الكاملة؛
- الانتقال بين النمط العادي والنمط اليدوي.

#pagebreak()

#outline(title: [فهرس المحتويات])

#pagebreak()

= التثبيت وأول ملف

للتجربة من داخل مجلد الحزمة، استعمل الاستيراد النسبي:

```typst
#import "../src/lib.typ": *
```

بعد تثبيت الحزمة محليًا، يصبح الاستيراد كالتالي:

```typst
#import "@local/arabic-exam-kit:0.1.0": *
```

أضف خط Amiri للوثائق العربية:

```typst
#set page(paper: "a4", margin: 1cm)
#set text(font: "Amiri", lang: "ar", size: 12pt)
```

== أول سؤال باستعمال نموذج 2AM

```typst
#let wx = wexam-style(mode: "normal", dir: rtl)

#wexam-header(..wx)
#v(4mm)
#wexam-exercise-heading(title: [التمرين الأول], points: [3 ن], ..wx)
#wexam-question(number: 1, ..wx)[
  احسب $m = (+5) + (-7)$.
]
```

#wexam-header(
  school: [متوسطة : مثال],
  level: [🎓 المستوى : السنة ② متوسط],
  title: [مثال مبسط],
  year: [2024 – 2025],
  duration: [المدة : 02 سا],
)
#v(3mm)
#wexam-exercise-heading(title: [التمرين الأول], points: [3 ن])
#wexam-question(number: 1)[احسب $m = (+5) + (-7)$.]

#pagebreak()

= النمط العادي والنمط اليدوي

كل عائلة توفر قاموسًا موحدًا للأسلوب:

```typst
#let normal = wexam-style(mode: "normal", dir: rtl, seed: 42)
#let rough = wexam-style(mode: "rough", roughness: 1.15, dir: rtl, seed: 42)
```

| الإعداد | النتيجة |
|---|---|
| `mode: "normal"` | خطوط نظيفة ودقيقة للطباعة |
| `mode: "rough"` | خطوط تشبه الرسم باليد |
| `roughness: 0.7` | تأثير خفيف |
| `roughness: 1.15` | التأثير المقترح |
| `roughness: 1.8` | رسم يدوي واضح |
| `seed` | يجعل النتيجة ثابتة عند كل تجميع |

#grid(columns: (1fr, 1fr), column-gutter: 8mm,
  [#text(weight: "bold")[عادي] #v(2mm) #wexam-exercise-heading(title: [التمرين الأول], points: [3 ن])],
  [#text(weight: "bold")[يدوي] #v(2mm) #wexam-exercise-heading(title: [التمرين الأول], points: [3 ن], mode: "rough", roughness: 1.15)],
)

#pagebreak()

= اختيار النموذج المناسب

== النموذج الأحمر

هذا النموذج مناسب لاختبارات المتوسطة ذات الأشرطة الحمراء:

```typst
#let ex = exam-style(mode: "normal", dir: rtl)
#exam-header(..ex)
#exam-meta-line()
#exam-exercise-box(title: [التمرين الأول], points: [3 ن], ..ex)[
  اكتب العدد $562,405$ كتابة عشرية.
]
```

== النموذج الأبيض والأسود sexam

```typst
#let sx = sexam-style(dir: rtl)
#sexam-exercise-heading(title: [التمرين الأول], points: [6 نقاط], ..sx)
#sexam-part(score: "2", ..sx)[
  نص السؤال أو الحل المطلوب.
]
```

في `sexam-part` أعط الرقم فقط (`"2"`). تقوم الحزمة بوضع `ن` في الموضع
الصحيح داخل صندوق التنقيط.

== النموذج الأزرق 2AM

يستعمل الشريط الأزرق المرصع بالنجوم، والعنوان داخل بطاقة بيضاء، وأرقامًا
سماوية للأسئلة.

#pagebreak()

= الورقة البيداغوجية الكاملة

الدالة `worksheet(...)` تنشئ ورقة بيداغوجية كاملة: بيانات الأستاذ، السياق،
الكفاءات، جدول سير الدرس والملاحظات. وهي ليست صورة، بل تصميم متجهي يتكيف مع
مقاس الصفحة.

```typst
#set page(paper: "a4", margin: 0pt)
#set text(font: "Amiri", lang: "ar")

#worksheet(mode: "normal")
```

وللنسخة اليدوية:

```typst
#worksheet(
  mode: "rough",
  roughness: 1.25,
  outer-x: 3.8%,
  outer-y: 3.8%,
)
```

لا تعدّل الإحداثيات الداخلية للورقة. استعمل `outer-x` و `outer-y` لتغيير
الهوامش، واستعمل `paper:` لتغيير A4 إلى A5 أو Letter.

== معاينة مباشرة للورقة

الصفحة التالية مرسومة مباشرة بالدالة `worksheet(...)`، وهي جزء من الحزمة
وليست صورة مضافة إلى الدليل.

#pagebreak()
#worksheet(mode: "normal")

#pagebreak()

= الأشكال الهندسية

تستعمل الحزمة `ctz-euclide` لرسم الأشكال المتجهية، ولذلك يمكن تعديلها
وطباعتها بدقة عالية.

```typst
#wexam-angle-figure(width: 35%, mode: "rough", roughness: 1.15)
#wexam-house-figure(width: 48%)
#exam-circle-geometry(width: 42%)
```

#grid(columns: (1fr, 1fr), column-gutter: 10mm,
  [#wexam-angle-figure(width: 100%)],
  [#wexam-house-figure(width: 100%)],
)

#pagebreak()

= التأثيرات والصناديق

== البطاقات والورق المربع

`mf-card` و `mf-grid-box` و `mf-perforated-box` و `mf-spiral-box` مناسبة
لأوراق العمل والاختبارات القصيرة.

== القهوة ورشاشات الطلاء

```typst
#mf-coffee-stain(size: 4cm, variant: "ring")
#mf-coffee-blot(width: 2cm, height: 3cm)
#mf-paint-splat(model: 5, width: 5cm, height: 4cm)
```

== الصناديق المرقمة

```typst
#let cards = exercise-style(color_mode: "color", dir: rtl)
#exercise-3(title: [ضرب قوى لها نفس الأساس], ..cards)[
  احسب $2^3 times 2^5 = dots$.
]
```

#pagebreak()

= وصفات عملية: الكود والنتيجة

== بطاقة بعنوان

```typst
#mf-card[
  #mf-title(dir: rtl)[بطاقة رياضيات]
  #v(.7em)
  محتوى عربي داخل بطاقة قابلة لإعادة الاستعمال.
]
```

#mf-card[
  #mf-title(dir: rtl)[بطاقة رياضيات]
  #v(.7em)
  محتوى عربي داخل بطاقة قابلة لإعادة الاستعمال.
]

تعمل `mf-card[...]` من اليمين إلى اليسار افتراضيًا، لذلك يحاذى النص العربي
إلى اليمين. للنص اللاتيني استعمل `#mf-card(dir: ltr)[English text]`.

#v(7mm)

== ورقة مربعة ومثقبة

```typst
#mf-grid-box(grid-columns: 20, dir: rtl)[
  اكتب خطوات الحل هنا.
]

#mf-perforated-box(perforation-count: 8, dir: rtl)[
  سؤال على ورقة مثقبة.
]
```

#mf-grid-box(grid-columns: 20, dir: rtl)[
  اكتب خطوات الحل هنا.
]
#v(5mm)
#mf-perforated-box(perforation-count: 8, dir: rtl)[
  سؤال على ورقة مثقبة.
]

#pagebreak()

== اختيار متعدد ودفتر حل

```typst
#mf-choice("أ", dir: rtl)[الإجابة الأولى.]
#mf-spiral-box(coil-count: 8, dir: rtl)[
  دفتر حل مزود بحلقات.
]
```

#mf-choice("أ", dir: rtl)[الإجابة الأولى.]
#v(7mm)
#mf-spiral-box(coil-count: 8, dir: rtl)[
  دفتر حل مزود بحلقات.
]

#pagebreak()

== تمرين مرقم وإطار مغناطيسي

```typst
#let cards = exercise-style(color_mode: "color", dir: rtl)
#exercise-3(title: [ضرب قوى لها نفس الأساس], ..cards)[
  احسب $2^3 times 2^5 = dots$.
]

#mf-magnetic-filings-box(dir: rtl)[المجال المغناطيسي.]
```

#let recipe-cards = exercise-style(color_mode: "color", dir: rtl)
#exercise-3(title: [ضرب قوى لها نفس الأساس], ..recipe-cards)[
  احسب $2^3 times 2^5 = dots$.
]

لتغيير الرقم في أسلوب مشترك:

```typst
#let labelled = exercise-style(number: "أ", color_mode: "color", dir: rtl)
#exercise-3(title: [اختبار], ..labelled)[احسب $2^3 times 2^5$.]
```

ولتغيير رقم صندوق واحد فقط:

```typst
#exercise-3(number: "✓", title: [اختبار], color_mode: "color", dir: rtl)[
  احسب $2^3 times 2^5$.
]
```

#v(8mm)
#mf-magnetic-filings-box(dir: rtl)[المجال المغناطيسي.]

#pagebreak()

== القهوة ورشاشات الطلاء

```typst
#mf-coffee-stain(size: 3.5cm, variant: "ring")
#mf-paint-splat(model: 5, width: 4.5cm, height: 3.5cm)
```

#align(center)[
  #mf-coffee-stain(size: 3.5cm, variant: "ring")
  #h(1cm)
  #mf-paint-splat(model: 5, width: 4.5cm, height: 3.5cm)
]

#pagebreak()

= حلول المشاكل الشائعة

== خط Amiri غير موجود

```typst
typst compile --font-path assets/fonts examples/01-minimal-wexam.typ
```

== ظهور النص خارج الصفحة

- قلل `width:` إلى `90%`؛
- استعمل `#pagebreak()` قبل شكل كبير؛
- قلل حجم النص العام؛
- استخدم القيم النسبية `%` و `em` في المكونات القابلة لإعادة الاستعمال.

== الفاصلة العشرية

في الأمثلة الجزائرية استعمل الفاصلة:

```typst
$562,405$
$2,5 "m"$
```

== قائمة المراجعة قبل الطباعة

1. جرّب النسخة العادية؛
2. جرّب النسخة اليدوية؛
3. راجع أرقام النقاط `ن` والفواصل العشرية؛
4. تأكد من عدم خروج النص أو الشكل من الصفحة؛
5. اطبع صفحة تجريبية قبل النسخة النهائية.

#align(center)[#text(size: 15pt, weight: "bold", fill: wexam-palette.blue-dark)[بالتوفيق في إنشاء وثائق Typst!]]
