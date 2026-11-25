// دليل استخدام الحزمة na-frame (نسخة عربية).
// للترجمة:  typst compile doc.typ
// يضع هذا الملف في جذر الحزمة (بجانب lib.typ).

#import "lib.typ"
#import "lib.typ": *

#set page(paper: "a4", margin: (x: 20mm, y: 22mm), numbering: "1")
#set text(font: ("Noto Naskh Arabic", "Amiri", "DejaVu Sans"), lang: "ar", dir: rtl, size: 12pt)
#set par(leading: 0.8em, justify: false)
#set heading(numbering: "1.1")
#show heading: set block(above: 1.4em, below: 0.8em)
#show heading.where(level: 1): set text(size: 18pt, fill: rgb("#4B0082"))
#show heading.where(level: 2): set text(size: 14pt, fill: rgb("#4B0082"))
#show raw: set text(font: ("DejaVu Sans Mono", "Liberation Mono"), size: 9pt, dir: ltr)
#show raw.where(block: false): box.with(fill: luma(238), inset: (x: 3pt), outset: (y: 3pt), radius: 2pt)

// يعرض الشيفرة ثم نتيجتها الحيّة.
#let scope = dictionary(lib)
#let demo(code) = block(width: 100%, above: 1em, below: 1em)[
  #block(width: 100%, fill: luma(246), stroke: 0.5pt + luma(200), radius: 2pt, inset: 8pt)[
    #set par(leading: 0.5em)
    #align(left, raw(code.text, lang: "typ", block: true))
  ]
  #v(1mm)
  #eval(code.text, mode: "markup", scope: scope)
]

#let note(body) = block(width: 100%, fill: rgb("#FFF8E1"), stroke: (right: 2.5pt + rgb("#E0A800")),
  inset: 9pt, radius: 2pt, above: 1em, below: 1em)[#body]

// ───────────── الغلاف ─────────────
#align(center)[
  #v(8mm)
  #text(size: 30pt, weight: "bold", fill: rgb("#4B0082"))[na-frame]
  #v(2mm)
  #text(size: 16pt)[حزمة إطارات احترافية لـ Typst]
  #v(1mm)
  #text(size: 12pt, fill: luma(90))[دليل الاستخدام · الإصدار 0.1.0]
]
#v(6mm)
#outline(indent: 1.2em, depth: 2)
#pagebreak()

= ما هي الحزمة؟

`na-frame` مكتبة Typst تقدّم *#frames.len() إطارًا جاهزًا* (تعريف، مبرهنة، تمرين، خاصية، دفتر، ورقة، شريط...) تعمل بالعربية (من اليمين إلى اليسار) وباللاتينية (من اليسار إلى اليمين) بالواجهة نفسها.

- كل الإطارات قابلة للتقسيم بين الصفحات (`breakable`) ما لم يُذكر خلاف ذلك.
- كل إطار يقبل عنوانًا ولونًا وألوانًا فرعية، والعنوان يمكن أن يحتوي معادلات أو أي محتوى.
- كل تعريفات الإطارات موجودة في ملف واحد: `lib.typ`.
- يمكن في الملف الواحد خلط إطارات عربية ولاتينية (المعامل `dir`).

= التثبيت

== التثبيت اليدوي

يبحث Typst عن الحزم داخل مجلد بياناته بالشكل `packages/<المجال>/<الاسم>/<الإصدار>/`. نستعمل هنا المجال القصير `na`. بعد التثبيت هناك تستطيع استيراد `na-frame` من أي مستند دون نسخ المجلد في كل مرة.

+ حدّد مجلد `packages` في نظامك (الجدول أدناه، حتى `packages/`) وأنشئ المجلدات الناقصة.
+ أنشئ بداخله `na/na-frame/0.1.0/`. يجب أن يطابق اسم آخر مجلد قيمة `version` في `typst.toml`.
+ انسخ *محتويات* الحزمة إلى ذلك المجلد (`typst.toml` و`lib.typ` و`doc.typ` و`doc-en.typ` و`examples/`). يجب أن يكون `typst.toml` و`lib.typ` مباشرة داخل `0.1.0/` وليس في مجلد فرعي.
+ استورد الحزمة بالاسم من أي مستند كما هو موضح أدناه.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [نظام التشغيل], [المسار],
  [Linux], [`~/.local/share/typst/packages/na/na-frame/0.1.0/`],
  [macOS], [`~/Library/Application Support/typst/packages/na/na-frame/0.1.0/`],
  [Windows], [`%APPDATA%\typst\packages\na\na-frame\0.1.0\`],
)

يجب أن تكون البنية النهائية هكذا:

```
typst/packages/na/na-frame/0.1.0/
├── typst.toml
├── lib.typ
├── doc.typ
├── doc-en.typ
└── examples/
```

في Linux، إذا كان المتغير `XDG_DATA_HOME` معرّفًا فاستبدل `~/.local/share` بمساره.

=== استدعاء الحزمة بعد تثبيتها

استعمل المجال `@na` ثم اسم الحزمة والإصدار بالضبط:

```typ
#import "@na/na-frame:0.1.0": *

#set text(lang: "ar", dir: rtl)

#theorem-frame(title: [مبرهنة فيثاغورس])[
  $ a^2 + b^2 = c^2 $
]
```

يعمل الاستيراد مع Typst في سطر الأوامر (`typst compile` و`typst watch`) ومع المحررات التي تعتمد عليه (مثل Tinymist في VS Code). أما تطبيق Typst على الويب فلا يدعم الحزم المثبّتة بهذه الطريقة.

إذا ظهرت رسالة _package not found_ فتأكد أن المسار يطابق الجدول، وأن اسم المجلد `0.1.0`، وأن الإصدار في الاستيراد يساوي الإصدار في `typst.toml`.

== التثبيت من مستودع حزم Typst (في حال القبول)

عند قبول الحزمة في مستودع حزم Typst الرسمي (Typst Universe) لا تحتاج إلى أي تثبيت يدوي: يكفي استيرادها، وسينزّلها Typst تلقائيًا في أول استعمال ثم يحتفظ بها في ذاكرة التخزين المؤقت. المجال هنا هو `@preview` وليس `@na`.

```typ
#import "@preview/na-frame:0.1.0": *

#set text(lang: "ar", dir: rtl)

#theorem-frame(title: [مبرهنة فيثاغورس])[
  $ a^2 + b^2 = c^2 $
]
```

يعمل هذا الاستيراد مع Typst في سطر الأوامر ومع المحررات (مثل Tinymist في VS Code) ومع تطبيق Typst على الويب أيضًا. ويمكنك العثور على الحزمة والإصدار الأحدث في صفحتها بموقع Typst Universe (`typst.app/universe`).

#note[ما دامت الحزمة غير مقبولة بعد في المستودع فاستعمل التثبيت اليدوي أعلاه مع المجال `@na`.]

#note[الاستيراد بـ `*` يجلب كل الإطارات إضافة إلى `palette` و`frame` و`frames` و`exercise-counter`.]

= البدء السريع

كل إطار دالة: *المحتوى أولًا* (بين قوسين مربعين) ثم المعاملات المسماة قبله:

#demo(```typ
#theorem-frame(title: [مبرهنة فيثاغورس])[
  في مثلث قائم، مربع الوتر يساوي مجموع مربعي الضلعين:
  $ a^2 + b^2 = c^2 $
]
```)

إذا حذفت `title` ظهر عنوان افتراضي مناسب للإطار بلغة المستند (مثلًا «مبرهنة» بالعربية و«Theorem» بالإنجليزية):

#demo(```typ
#blue-frame[
  الدالة علاقة تربط كل عنصر بعنصر واحد على الأكثر.
]
```)

= المعاملات المشتركة

تشترك معظم الإطارات في هذه المعاملات (وبعضها أبسط: `warning-note` و`homework-sheet` بلا عنوان، و`ribbon-banner` و`arched-ribbon` بلا محتوى):

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`title`], [العنوان. القيمة `auto` تعني عنوانًا افتراضيًا حسب لغة المستند.],
  [`color`], [لون الإطار (والأرضية الفرعية في بعض الإطارات).],
  [`title-color`], [لون خانة العنوان. `auto` يعني نفس `color`.],
  [`title-text-color`], [لون نص العنوان.],
  [`breakable`], [يسمح بتقسيم الإطار بين صفحتين (الافتراضي `true`).],
  [`dir`], [`auto` (اتجاه المستند) أو `rtl` أو `ltr`.],
  [`lang`], [لغة الإطار (الافتراضي `ar` مع rtl و`en` مع ltr).],
)

#note[القيم الافتراضية للألوان تختلف من إطار لآخر، ولبعض الإطارات معاملات خاصة بها (انظر الفصل «معاملات خاصة»).]

= الألوان والعناوين

== اللوحة palette

تحتوي `palette` على ألوان جاهزة: `blue` و`red` و`crimson` و`green` و`teal` و`orange` و`purple` و`indigo` و`gold` و`gray`.

#demo(```typ
#blue-frame(title: [تعريف], color: palette.teal)[
  لون الإطار من اللوحة الجاهزة.
]

#blue-frame(title: [تعريف], color: rgb("#8a2be2"))[
  أو أي لون تختاره بنفسك.
]
```)

== ألوان العنوان

#demo(```typ
#theorem-frame(
  title: [مبرهنة],
  color: palette.indigo,
  title-color: palette.purple,
  title-text-color: yellow,
)[
  إطار نيلي وخانة عنوان بنفسجية ونص أصفر.
]
```)

== عنوان بمعادلة

العنوان محتوى Typst كامل، فيمكن أن يضم معادلات وتنسيقًا:

#demo(```typ
#green-frame(title: [تمرين #sym.star], subtitle: [4 نقاط])[
  احسب النهاية: $ lim_(x -> 0) (sin x) / x $
]
```)

= التقسيم بين الصفحات

الإطارات قابلة للتقسيم افتراضيًا؛ ويبقى العنوان ملتصقًا بأول سطر. لمنع التقسيم:

```typ
#theorem-frame(breakable: false)[ نص لا يُقسَّم. ]
```

#note[الإطار `warning-note` ذو عرض ثابت (`170mm`) وغير قابل للتقسيم. أما `practical-notebook` فعرضه الافتراضي `auto` أي العرض المتاح كله بمحاذاة بقية الإطارات (تبرز الحلقات 4 مم في الهامش)، ولا يُقسَّم بين صفحتين. أما `sheet-frame` فبعرض كامل وقابل للتقسيم بين الصفحات (`breakable: true`).]

= إطارات عربية ولاتينية في ملف واحد

المعامل `dir` يحدد اتجاه الإطار، و`lang` لغته:

#demo(```typ
#theorem-frame(dir: ltr, title: [Theorem])[
  A Latin frame inside an Arabic document: $ a^2 + b^2 = c^2 $
]

#frame("blue", dir: ltr, title: [Definition])[A definition in LTR.]
```)

الاتجاه العكسي (إطار عربي داخل مستند لاتيني) بالطريقة نفسها: `dir: rtl`.

#note[في المستند اللاتيني (`dir: ltr`) تظهر خانة العنوان في الإطارات ذات الخانة على *اليسار*، وفي المستند العربي (`dir: rtl`) تبقى على اليمين. ينطبق هذا على كل الإطارات ذات الخانة (`tab-frame` و`curved-tab-frame` و`speech-frame` و`rounded-tab-frame` و`exam-frame` و`right-rule-frame` و`folded-corner-frame` و`subtitle-frame` و`outlined-tab-frame` و`inset-tab-frame` و`numbered-frame` و`property-frame` و`exercise-card` و`sheet-frame`...): تنعكس الزخارف والخطوط الجانبية والظلال والعنوان الفرعي مع الخانة. أما الإطارات ذات العنوان المتوسط فلا تتغير.]

= الاستدعاء بالاسم: frame

الدالة `frame` تستدعي أي إطار باسمه المسجَّل في القاموس `frames`:

#demo(```typ
#frame("shadow", title: [مثال], color: palette.crimson)[
  نفس `shadow-frame` لكن بالاسم.
]
```)

يفيد هذا عندما يكون نمط الإطار متغيرًا، مثلًا:

```typ
#let style = "blue"
#frame(style, title: [تعريف])[ ... ]
```

وللاطلاع على كل الأسماء المتاحة: `#frames.keys()`.

= دليل الإطارات

== التعريفات والمبرهنات والخواص

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [الإطار], [الوصف],
  [`theorem-frame`], [خانة عنوان حمراء معلّقة على إطار فاتح (مبرهنة).],
  [`blue-frame`], [إطار مدوّر بعنوان منحنٍ (تعريف).],
  [`flag-frame`], [عنوان على شكل راية (خاصية).],
  [`proof-frame`], [إطار مدوّر بخانة عنوان (برهان).],
  [`gradient-frame`], [عنوان متدرج اللون (ملاحظة).],
  [`chapter-frame`], [خانة عنوان بسهم (خطة الفصل).],
  [`ribbon-frame`], [شريط عريض بأطراف مطوية (تذكير).],
  [`shadow-frame`], [ظل متدرج وطية زاوية (مثال).],
  [`board-frame`], [إطار سبورة مشطوف، العنوان نص بلا خانة.],
  [`property-frame`], [خاصية بشارتين صغيرتين.],
  [`folded-definition-frame`], [خانة عنوان مطوية.],
  [`corner-rule-frame`], [عنوان وعنوان فرعي في الجهتين.],
  [`properties-frame`], [إطار سميك بعنوان وعنوان فرعي.],
  [`centered-info-frame`], [عنوان في الوسط بين شريطين.],
  [`ribbon-notes-frame`], [شريط علوي متدرج مع عنوان فرعي وشارة ملوّنة (ملاحظات هامة).],
  [`double-tab-frame`], [خانتا عنوان: رئيسية وفرعية.],
  [`tab-frame`، `curved-tab-frame`، `rounded-tab-frame`], [خانات عنوان بأشكال مختلفة.],
  [`right-rule-frame`، `folded-corner-frame`، `subtitle-frame`], [قواعد جانبية وزوايا مطوية وعنوان فرعي.],
  [`outlined-tab-frame`، `inset-tab-frame`], [خانات بحدود أو داخلية.],
  [`speech-frame`], [شكل فقاعة حوار.],
  [`warning-note`], [ورقة تنبيه صفراء بعنوان عمودي حرّ (عرض ثابت).],
  [`grid-notebook-frame`], [دفتر أزرق بشبكة ملليمترية وحلقات وشارة عنوان منحنية.],
  [`prerequisites-frame`], [بطاقة بنود حمراء التسميات بزاوية مطوية وحلقات (المكتسبات القبلية).],
  [`folded-ribbon-frame`], [ورقة بشريط عريض بنهاية مشطوفة وطيّتين.],
  [`hanging-tab-frame`], [ورقة بخط علوي ولسان عنوان منحنٍ معلّق.],
  [`winged-tab-frame`], [عنوان في الوسط بجناحين وحدّ منقّط.],
  [`badge-notebook-frame`], [بطاقة بطبقتين وشارة عنوان مائلة وخط ذهبي.],
)

#demo(```typ
#centered-info-frame(title: [معلومات هامة])[
  عنوان في الوسط بين شريطين.
]

#double-tab-frame(title: [خاصية], subtitle: [عمدة عدد مركب])[
  خانتا عنوان: رئيسية وفرعية.
]

#board-frame(title: [السبورة])[
  إطار سبورة مشطوف، والعنوان نص بلا خانة.
]
```)

=== إطار الملاحظة `warning-note` بالتفصيل

ورقة صفراء بزاوية مطوية في أسفلها اليسار، وعلى يمينها شريط عمودي ذهبي يُكتب فيه عنوان *حرّ* بشكل عمودي. ارتفاع الورقة يتبع طول النص تلقائيًا (بحد أدنى 25mm) ولا يمكن تقسيمها بين صفحتين.

*العنوان:* اكتب ما تشاء في `title`. إذا حذفته ظهرت كلمة «ملاحظة» (أو «Note» في مستند لاتيني). يتمدد الشريط العمودي والورقة معًا إن كان العنوان طويلًا.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`title`], [العنوان العمودي الحر. الافتراضي `auto` (ملاحظة).],
  [`title-color`], [لون العنوان (الافتراضي أبيض).],
  [`title-size`], [حجم العنوان (الافتراضي `10pt`).],
  [`title-font`], [خط العنوان (الافتراضي `"Noto Kufi Arabic"`).],
  [`width`], [عرض الورقة (الافتراضي `170mm`).],
  [`body-color`], [لون الورقة (الافتراضي أصفر فاتح).],
)

#demo(```typ
#warning-note[تنبيه مهم.]

#warning-note(title: [تنبيه هام جدًا])[
  عنوان حرّ يكتبه المستخدم، ويظهر عموديًا على الشريط.
]

#warning-note(title: [نصيحة], title-color: rgb("#4a2c00"), body-color: rgb("#e6f4ea"))[
  لون عنوان ولون ورقة مخصصان.
]
```)

== التمارين

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [الإطار], [الوصف والمعاملات الخاصة],
  [`green-frame`], [تمرين أخضر. `subtitle`: نص جانبي (مثل عدد النقاط).],
  [`numbered-exercise-frame`], [ترقيم تلقائي «التمرين 1، 2...». `subtitle`: النقاط، `third-title`: عنوان ثالث.],
  [`numbered-frame`], [«التمرين رقم 02». `number`: الرقم، `subtitle`: عنوان فرعي.],
  [`exercise-card`], [بطاقة تمرين بأيقونة. `points`، `subtitle`، `icon` (`true`/`false`).],
  [`exam-frame`], [تمرين امتحان. `number`: الرقم، `source`: المصدر مثل «بكالوريا 2010».],
  [`framed-exercise`], [تمرين بإطار أخضر وذهبي، العنوان حرّ بلا ترقيم. `title`، `title-color`، `title-size`.],
  [`sheet-frame`], [ورقة بعنوان كبير، قابلة للتقسيم بين الصفحات. `width`، `body-height` (الافتراضي `auto`)، `title-size`، `breakable`.],
)

=== الترقيم التلقائي

يزيد `numbered-exercise-frame` عدّادًا عند كل استدعاء. لإعادة البدء استعمل العدّاد المصدَّر `exercise-counter`:

#demo(```typ
#exercise-counter.update(0)

#numbered-exercise-frame(subtitle: [4 نقاط], third-title: [الأعداد المركبة])[
  الترقيم تلقائي.
]

#numbered-exercise-frame(subtitle: [3 نقاط])[
  تمرين ثانٍ يأخذ الرقم 2.
]
```)

=== بقية إطارات التمارين

#demo(```typ
#numbered-frame(number: [02], subtitle: [تمرين شامل في الدوال])[
  نص التمرين.
]

#exercise-card(points: [6 نقاط], subtitle: [الأسئلة مستقلة.])[
  نص التمرين.
]

#exam-frame(number: 3, source: [بكالوريا 2010])[
  نص التمرين.
]
```)

== الدفاتر والأوراق

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [الإطار], [الوصف],
  [`paper-frame`، `sticky-frame`], [ورقة مدبّسة بزاوية ملتفة، وورقة لاصقة صفراء.],
  [`notebook-frame`], [دفتر بحلقات معدنية.],
  [`notebook-page-frame`], [ورقة دفتر مسطّرة بسلك على جهة النهاية.],
  [`torn-paper-frame`], [ورقة ممزقة الحواف مع ظل. `subtitle`.],
  [`side-notebook-frame`، `binder-notebook-frame`], [دفاتر بسلك جانبي أو بحلقات.],
  [`practical-notebook`], [دفتر أعمال تطبيقية بقلم رصاص وحلقات (عرض تلقائي كامل).],
  [`homework-sheet`، `homework-sheet-modern`], [ورقة واجب (بيانات الاسم والتاريخ).],
)

== إطارات الدفعة الرابعة

أربعة إطارات جديدة (مأخوذة من تصاميم الأوراق التي كانت تحمل كلها الاسم `homework-sheet-modern` وكتصميم `practical-notebook` بلا حلقات)، أُعطي كل واحد منها اسمًا مستقلًا. كلها تقبل `title` و`color` و`breakable` و`dir` و`lang`، وكل منها له نسخة عربية (الشريط أو اللسان أو الشارة على اليمين) ونسخة لاتينية (`dir: ltr`) تنعكس فيها الرسوم دون النص، مع عنوان افتراضي بالإنجليزية.

=== `folded-ribbon-frame`: الشريط المطوي

ورقة بإطار رفيع، وعلى زاويتها العليا شريط عريض بنهاية مشطوفة مدبّبة (من جهة داخل الورقة)، يبرز قليلًا خارج حافتها، وخلفه مثلثان صغيران يوهمان بأنه مطوي على الورقة. العنوان داخل الشريط بخط عريض أبيض. يصلح لأوراق الواجبات المنزلية وعناوين السلاسل.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`title`], [العنوان (الافتراضي «الواجب المنزلي» أو Homework).],
  [`color`], [لون الإطار ولون الشريط (الافتراضي أحمر قاتم `#780505`).],
  [`title-color`], [لون الشريط وحده (`auto` = `color`).],
  [`title-text-color`], [لون نص العنوان (أبيض).],
  [`fold-color`], [لون المثلثين المطويين (بنفسجي).],
  [`paper-color`], [لون خلفية الورقة (أبيض).],
  [`ribbon-width`], [عرض الشريط (الافتراضي `100mm`).],
  [`breakable`], [قابل للتقسيم بين الصفحات (الافتراضي `true`).],
)

#demo(```typ
#folded-ribbon-frame(title: [الواجب المنزلي رقم 1])[
  بسّط العدد $sqrt(sqrt(3^8))$ ثم اذكر أصغر مجموعة ينتمي إليها.
]

#folded-ribbon-frame(title: [Homework no. 2], dir: ltr, color: palette.indigo)[
  Latin version: the ribbon sits on the left.
]
```)

=== `hanging-tab-frame`: اللسان المعلّق

ورقة بخط علوي فقط، يتدلى فوقه لسان عنوان منحنٍ (مستدير من جهة ومائل من الجهة الأخرى) يبدأ فوق الخط وينزل قليلًا تحته. عرض اللسان وارتفاعه يتبعان طول العنوان تلقائيًا، فلا حاجة لتحديدهما. اللسان على اليمين في العربية وعلى اليسار في اللاتينية. لا يوجد إطار جانبي أو سفلي، فهو مناسب لتمارين طويلة تمتد على عدة صفحات.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`title`], [العنوان (الافتراضي «تمرين» أو Exercise).],
  [`color`], [لون الخط العلوي ولون اللسان (الافتراضي أسود).],
  [`title-color`], [لون اللسان وحده (`auto` = `color`).],
  [`title-text-color`], [لون نص العنوان (أبيض).],
  [`paper-color`], [لون خلفية الورقة.],
  [`breakable`], [قابل للتقسيم بين الصفحات.],
)

#demo(```typ
#hanging-tab-frame(title: [تمرين في الدوال اللوغاريتمية])[
  حل في $RR$ المعادلة: $ln(x) + ln(x - 1) = ln(6)$.
]

#hanging-tab-frame(title: [Logarithm exercise], dir: ltr, color: palette.teal)[
  Solve in $RR$: $ln(x) + ln(x - 1) = ln(6)$.
]
```)

=== `winged-tab-frame`: اللسان ذو الجناحين

ورقة بإطار رفيع، وفي وسط حافتها العليا عنوان داخل مستطيل أبيض بحد منقّط داخلي، وعلى جانبيه جناحان مدبّبان بلون الإطار. التصميم متماثل، فهو لا يختلف بين العربية واللاتينية إلا في اتجاه النص. نص العنوان يأخذ لون الإطار افتراضيًا.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`title`], [العنوان (الافتراضي «ملاحظة» أو Note).],
  [`color`], [لون الإطار والجناحين والحد المنقّط (الافتراضي أسود).],
  [`title-color`], [لون الجناحين والحدود (`auto` = `color`).],
  [`title-text-color`], [لون نص العنوان (`auto` = لون الجناحين).],
  [`tab-fill`], [لون خلفية خانة العنوان (أبيض).],
  [`paper-color`، `breakable`], [خلفية الورقة والتقسيم بين الصفحات.],
)

#demo(```typ
#winged-tab-frame(title: [ملاحظة], color: palette.crimson)[
  لسان في الوسط بجناحين وحدّ منقّط داخلي.
]

#winged-tab-frame(title: [Remark], dir: ltr, color: palette.indigo)[
  Latin version.
]
```)

=== `badge-notebook-frame`: الدفتر ذو الشارة

بطاقة بطبقتين: ورقة بحد ناعم فوق طبقة خلفية داكنة تظهر كأنها كعب بسمك 2 مم، وفي زاويتها العليا شارة عنوان مائلة بلون داكن، تحتها شريط ذهبي قصير، وفي أسفل البطاقة خط رفيع بنقطة ذهبية. زوايا البطاقة غير متماثلة (مستديرة بقوة في زاويتين متقابلتين). يختلف عن `practical-notebook` بأنه بلا حلقات. عرضه الافتراضي `auto` (العرض المتاح كله)، ويمكنك تمرير `width` ثابت. في اللاتينية تنتقل الشارة إلى اليسار وينعكس الكعب.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`title`، `title-font`، `title-size`، `title-color`], [العنوان وخطه وحجمه ولون نصه.],
  [`title-box-color`], [لون الشارة والطبقة الخلفية (أخضر مزرق داكن).],
  [`accent-color`], [لون الشريط الذهبي والنقطة.],
  [`paper-color`، `border-color`، `text-fill`], [ألوان الورقة والحد ونص المحتوى.],
  [`width`], [`auto` (الافتراضي) أو طول ثابت.],
  [`height`، `min-height`], [الارتفاع والحد الأدنى (`60mm`).],
)

#demo(```typ
#badge-notebook-frame(title: [أعمال تطبيقية])[
  في هذا النشاط ننظّم أفكارنا ونطبّق ما درسناه خطوةً بخطوة.
]

#badge-notebook-frame(title: [Practical work], dir: ltr, title-box-color: rgb("#5d2490"))[
  Latin version: badge and heel on the left.
]
```)

#note[عند `width: auto` يُرسم الإطار داخل مساحة بعرض ثابت محسوب من الحاوية، فلا يُقسَّم بين صفحتين. إن أردت التقسيم فمرّر `width` بطول ثابت.]

== إطار «ملاحظات هامة» `ribbon-notes-frame`

شريط علوي متدرج اللون في قطعة واحدة: عنوان رئيسي في جهة، وعنوان فرعي صغير («أضف إلى») وشارة ملوّنة متدرجة («معلوماتك») معلّقة تحته في الجهة المقابلة. في المستند العربي يكون العنوان الرئيسي على اليمين والشارة على اليسار، وفي النسخة اللاتينية (`dir: ltr`) ينعكس الشريط كله (الرسم فقط، دون النص) فيصير العنوان على اليسار والشارة على اليمين.

*العناوين:* `title` و`subtitle` و`tag-title` كلها من اختيارك. إذا حذفتها ظهرت الكلمات الافتراضية («ملاحظات هامة» و«أضف إلى» و«معلوماتك»، أو Important notes / Add to / your notes في مستند لاتيني). اكتب `subtitle: []` أو `tag-title: []` لإخفاء العنوان الفرعي أو الشارة. العرض الأدنى `70mm`.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`title`], [العنوان الرئيسي في الشريط.],
  [`subtitle`], [العنوان الفرعي الصغير (أضف إلى).],
  [`tag-title`], [نص الشارة الملوّنة (معلوماتك).],
  [`color`], [لون الإطار (الافتراضي بنفسجي `4B0082`).],
  [`title-color`], [لون الشريط (`auto` = لون الإطار).],
  [`title-text-color`], [لون نص العنوان (الافتراضي أبيض).],
  [`background`], [لون خلفية الإطار المتدرجة.],
  [`subtitle-color`], [لون نص العنوان الفرعي.],
  [`tag-color`، `tag-end-color`، `tag-text-color`], [بداية ونهاية تدرج الشارة ولون نصها.],
  [`title-size`، `title-raise`], [حجم العنوان ورفعه (في `ribbon-notes-frame` الافتراضي `0mm`: العنوان في وسط إطاره تمامًا).],
)

#demo(```typ
#ribbon-notes-frame(title: [ملاحظات هامة])[
  ليكن $z$ عددًا مركبًا غير معدوم، مكتوبًا بالشكل المثلثي:
  $ z = r (cos(theta) + i sin(theta)). $

  #list(marker: text(fill: palette.purple)[◀],
    [طويلة العدد $z$ هي $r$، حيث $r > 0$.],
    [لكل عدد طبيعي $n$، لدينا: $z^n = r^n (cos(n theta) + i sin(n theta))$.],
  )
]

#ribbon-notes-frame(
  title: [تذكير], subtitle: [لا تنسَ], tag-title: [القاعدة],
  color: palette.teal, background: rgb("#DDF3EC"),
)[
  ألوان وعناوين من اختيارك.
]

#ribbon-notes-frame(dir: ltr, title: [Important notes])[
  The same frame in a Latin layout: the ribbon is mirrored, the text is not.
]
```)

== إطار الدفتر الأزرق `grid-notebook-frame`

دفتر بشبكة ملليمترية (مربعات كل 1 مم) وهامش أحمر مزدوج وحلقات سلك معدنية، وفي أعلاه شارة عنوان زرقاء منحنية ملاصقة لحافة الإطار. يختلف عن `practical-notebook` بالشارة (منحنية بلا قلم) وبالألوان الزرقاء. في المستند العربي تكون الشارة والحلقات على اليمين، وفي النسخة اللاتينية (`dir: ltr`) ينعكس التجليد والشارة كلهما (الرسم فقط، دون النص).

العنوان من اختيارك في `title` (الافتراضي «تمرين تطبيقي» أو Applied exercise). عرضه الافتراضي `auto`: يملأ العرض المتاح مثل بقية الإطارات (لا حاجة لتحديد `width`)، وإن أردت عرضًا ثابتًا فمرّر طولًا مثل `width: 150mm`. ويتبع ارتفاعه طول المحتوى (بحد أدنى `min-height: 60mm`).

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`title`، `title-font`، `title-size`، `title-color`], [العنوان وخطه وحجمه ولون نصه.],
  [`accent-color`], [لون الشارة (الافتراضي أزرق داكن).],
  [`width`], [`auto` (الافتراضي) = العرض المتاح كله بحدّ الورقة بمحاذاة بقية الإطارات (تبرز الحلقات 4 مم في الهامش)؛ أو طول ثابت.],
  [`height`، `min-height`], [الارتفاع والحد الأدنى للارتفاع.],
  [`ring-spacing`], [المسافة بين الحلقات (الافتراضي `12mm`).],
  [`paper-color`، `border-color`، `wire-color`، `hole-color`], [ألوان الورقة والإطار والسلك والثقوب.],
  [`rule-color`، `fine-rule-color`، `margin-color`], [ألوان خطوط الشبكة والهامش.],
)

#demo(```typ
#grid-notebook-frame(title: [تمرين تطبيقي])[
  اكتب خطوات الحل بوضوح ثم راجع النتيجة.
]

#grid-notebook-frame(title: [Applied exercise], dir: ltr)[
  The binding and the badge are mirrored; the text is not.
]
```)

== إطار المكتسبات القبلية `prerequisites-frame`

ورقة بتدرج لوني وزاوية سفلية مطوية وظل خفيف، وعلى حافتها حلقات سلك يزداد عددها مع الارتفاع. المحتوى قائمة بنود لكل منها تسمية حمراء، تمررها في `items` كأزواج `(التسمية, المحتوى)`، ويمكنك إضافة نص عادي بعدها. لا عنوان له ولا يُقسَّم بين صفحتين. في النسخة اللاتينية (`dir: ltr`) تنتقل الحلقات إلى اليسار والزاوية المطوية إلى اليمين.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [المعامل], [المعنى],
  [`items`], [مصفوفة أزواج `([التسمية], [المحتوى])`.],
  [`label-color`], [لون التسميات (الافتراضي أحمر).],
  [`color`], [لون الإطار.],
  [`fill-color`], [لون نهاية التدرج (سماوي فاتح).],
  [`fold-color`، `fold-border-color`], [لون الزاوية المطوية وحدّها.],
  [`shadow-color`], [لون الظل.],
  [`wire-color`، `ring-spacing`، `ring-out`], [لون الحلقات والمسافة بينها وبروزها خارج الحافة.],
)

#demo(```typ
#prerequisites-frame(items: (
  ([المكتسبات القبلية], [مبرهنة فيثاغورس والتحويلات النقطية.]),
  ([الكفاءات المستهدفة], [استعمال خواص التحويلات لحل مسائل هندسية.]),
  ([الأدوات المستعملة], [الكتاب المدرسي، الأدوات الهندسية، جيوجيبرا.]),
))

#prerequisites-frame(dir: ltr, items: (
  ([Prior knowledge], [Pythagorean theorem, point transformations.]),
  ([Target skills], [Use transformation properties to solve problems.]),
))
```)

== الأشرطة (عناوين بلا محتوى)

الشريطان `ribbon-banner` و`arched-ribbon` يأخذان عنوانًا فقط ولا محتوى لهما:

#demo(```typ
#ribbon-banner(title: [عنوان الفصل])

#arched-ribbon(title: [عنوان الفصل])
```)

== إطارات بنمط السلك الجانبي

شريط عنوان ملوّن فوق ورقة بسلك معدني جانبي، والعنوان في وسط الشريط. هذا هو الإطار `spiral-banner-frame`، وعلى نمطه صارت الإطارات التي كانت مزخرفة سابقًا:

`lace-frame` و`illuminated-frame` و`geometric-frame` و`math-cover-frame` و`vintage-frame` و`jewel-frame` و`star-chain-frame` و`lantern-frame` و`botanical-frame` و`emerald-frame` و`right-scroll-frame` و`bevel-frame`

لكل منها لون افتراضي مختلف. تقبل `title` و`color` و`title-color` و`title-text-color` و`breakable`، وتتجاهل بصمت أي معامل قديم آخر (`footer` و`series`...).

#demo(```typ
#spiral-banner-frame(title: [عنوان الإطار])[
  شريط عنوان وسلك جانبي.
]

#emerald-frame(title: [ملاحظة])[
  النمط نفسه بلون زمردي.
]

#spiral-banner-frame(title-color: palette.crimson, frame-color: rgb("#FDECEC"))[
  ألوان مخصصة.
]
```)

= معاملات خاصة

بعض الإطارات تقبل معاملات إضافية. أهمها:

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [الإطار], [المعاملات],
  [`shadow-frame`], [`frame-color`، `frame-width`، `shadow-color`، `shadow-size`، `background`، `fold-size`],
  [`corner-rule-frame`], [`subtitle`، `subtitle-color`، `background`، `border-thickness`، `title-size`],
  [`properties-frame`], [`subtitle`، `subtitle-color`، `background`، `frame-width`، `title-size`],
  [`folded-definition-frame`], [`frame-color`، `background`، `title-size`],
  [`centered-info-frame`], [`frame-color`، `background`، `band-thickness`، `title-size`],
  [`double-tab-frame`], [`subtitle`، `title-border-color`، `frame-color`، `subtitle-color`، `subtitle-background`، `subtitle-border-color`، `background`],
  [`torn-paper-frame`], [`subtitle`، `subtitle-color`، `frame-color`، `background`، `outside-color`، `shadow-color`],
  [`spiral-banner-frame`], [`frame-color` (لون الورقة)، `binding-color` (لون السلك)، `title-size`، `title-raise`],
  [`notebook-page-frame`], [`text-color`، `paper-color`، `rule-color`، `major-rule-color`، `binding-color`، `title-size`],
  [`numbered-exercise-frame`], [`subtitle`، `third-title`، `secondary-color`، `number-color`، `title-size`، `title-raise`، `number-raise`، `subtitle-raise`],
  [`property-frame`], [`badge-top`، `badge-bottom`، `badge-color`],
  [`tab-frame`], [`title-width` (`auto` افتراضيًا: عرض اللسان لا يقل عن `25mm` مثل `curved-tab-frame` ويكبر مع العنوان، وارتفاعه يتبع العنوان، مع مسافة 1 مم فوقه و5 مم تحته ليظهر كاملًا مهما كبر، والعنوان في وسط اللسان أفقيًا؛ أو طول ثابت)، `background`، `border-color`],
  [`exam-frame`], [`number`، `source`، `title-background`، `number-color`، `background`],
  [`sheet-frame`], [`width`، `body-height`، `border-color`، `title-border-color`، `shadow-color`، `body-color`، `title-size`، `breakable`],
  [`warning-note`], [`title`، `title-color`، `title-size`، `title-font`، `width`، `body-color`],
  [`practical-notebook`], [`width` (`auto` افتراضيًا أو طول ثابت)، `height`، `min-height`، `ring-spacing`، `paper-color`، `border-color`، `wire-color` وغيرها (راجع التوقيع في `lib.typ`)],
  [`ribbon-banner`، `arched-ribbon`], [`title`، `color`، `text-color`، `border-color`، `title-size`],
  [`ribbon-notes-frame`], [`subtitle`، `tag-title`، `background`، `subtitle-color`، `tag-color`، `tag-end-color`، `tag-text-color`، `title-size`، `title-raise`],
  [`grid-notebook-frame`], [`accent-color`، `ring-spacing`، `paper-color`، `border-color`، `wire-color`، `rule-color`، `margin-color` وغيرها],
  [`folded-ribbon-frame`], [`color`، `title-color`، `title-text-color`، `fold-color`، `paper-color`، `ribbon-width`],
  [`hanging-tab-frame`], [`color`، `title-color`، `title-text-color`، `paper-color`],
  [`winged-tab-frame`], [`color`، `title-color`، `title-text-color`، `tab-fill`، `paper-color`],
  [`badge-notebook-frame`], [`title-box-color`، `accent-color`، `paper-color`، `border-color`، `text-fill`، `width`، `height`، `min-height`],
  [`prerequisites-frame`], [`items`، `label-color`، `color`، `fill-color`، `fold-color`، `shadow-color`، `wire-color`، `ring-spacing`، `ring-out`],
)

#note[التوقيع الكامل لكل إطار مكتوب في `lib.typ` عند تعريف الدالة `<اسم>-raw`، ويمكن قراءة قيمه الافتراضية من هناك.]

= نصائح وحل المشكلات

- *الخط العربي:* ضع خطًا عربيًا في مستندك، مثل `#set text(font: "Noto Naskh Arabic", lang: "ar", dir: rtl)`. اللغة والاتجاه يؤثران في العنوان الافتراضي وفي موضع الزخارف.
- *رسالة «needs at least … mm of width»:* بعض الإطارات تشترط عرضًا أدنى (`double-tab-frame` 60mm، `centered-info-frame` 40mm، `numbered-exercise-frame` 90mm). لا تضعها داخل أعمدة ضيقة جدًا.
- *إطار داخل جدول أو شبكة:* ضع `breakable: false` ليتصرف الإطار ككتلة واحدة.
- *عنوان مرتفع أو منخفض قليلًا:* يعتمد التوسيط على مقاييس الخط. للتعديل الدقيق استعمل المعاملات `title-raise` و`number-raise` و`subtitle-raise` حيث تتوفر.
- *عرض كل الإطارات:* جرّب `examples/demo-ar.typ` (نسخة عربية) و`examples/demo-en.typ` (نسخة لاتينية).
