// na-tabpos — الدليل (العربية)
// الترجمة من مجلد الحزمة :  typst compile documentationAR.typ
#import "@preview/na-tabpos:0.1.0": *

#set page(paper: "a4", margin: (x: 2cm, y: 2cm), numbering: "1")
#set text(font: ("Amiri", "New Computer Modern"), size: 13pt, lang: "ar", dir: rtl)
#set par(justify: true, leading: 0.8em)
#set heading(numbering: "1.1 –")
#show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em)[#it]
#show raw: set text(font: ("DejaVu Sans Mono", "Courier New"), size: 8.6pt, dir: ltr)
#show raw.where(block: true): set align(left)
#show link: it => underline(stroke: blue, it)

// ---- دالة مساعدة : تعرض الشيفرة ثم النتيجة -----------------------------------
#let scope = (tabpos: tabpos, tabpos-names: tabpos-names, tabvar: tabvar, hatch: hatch, grille: grille)
#let demo(code, size: 13pt) = {
  let src = code.text
  block(breakable: false, width: 100%, above: 1em, below: 1.2em)[
    #rect(fill: luma(96%), radius: 5pt, width: 100%, inset: 9pt, code)
    #v(-0.3em)
    #align(center)[
      #set text(font: ("Amiri", "New Computer Modern"), size: size, lang: "ar")
      #eval(src, mode: "markup", scope: scope)
    ]
  ]
}
#let en(body) = text(dir: ltr, body)

#align(center)[
  #text(26pt, weight: "bold")[na-tabpos] \
  #v(2pt)
  #text(15pt)[جداول الإشارة والتغيّرات و#strong[الوضع النسبي] في Typst] \
  #v(2pt)
  الإصدار 1.0.0 · مبنية على #link("https://typst.app/universe/package/vartable")[vartable] و#link("https://github.com/cetz-package/cetz")[CeTZ]
]

#v(0.5em)
#outline(indent: 1.5em, title: [الفهرس])
#pagebreak()

= مقدّمة

`na-tabpos` حزمة Typst للوثائق الرياضية العربية (وغيرها). مبنية على *vartable* وتضيف شيئًا واحدًا: سطر *الوضع النسبي* (منحنى مقابل مستقيم، أو منحنى مقابل منحنى) مع رسم القوسين عند كل نقطة تقاطع، مثل `\tkzTabPos` في LaTeX.

كل ما عدا ذلك هو vartable كما هو: أسطر الإشارة، أسطر التغيّرات، المناطق المهشّرة، الأشرطة `"||"` و`"0"`، القيم المضافة، الأنماط… وصياغة vartable لم تتغيّر.

*أهم الميزات*
- *سطر الفرق* `f(x) - g(x)` (سطر إشارة يأتي مباشرة قبل سطر `"p"`) ارتفاعه *1 سم* افتراضيًا (الخيار `diff-height`).
- كلمات سطر `"p"` (فوق / تحت / يقطع / في النقطة) *تتبع لغة المستند* (`#set text(lang: ...)`): العربية والفرنسية والإنجليزية والإسبانية والألمانية والإيطالية والبرتغالية والهولندية والتركية والروسية. وأي لغة أخرى تعطي الإنجليزية. ويمكنك دائمًا كتابة كلماتك.
- الارتفاع المكتوب في `label` (مثل `([العنوان], 2cm, "s")`) بالسنتيمتر بالضبط.

= التثبيت والاستيراد

من Typst Universe (عند النشر):

#en[```typ
#import "@preview/na-tabpos:1.0.0": *
```]

أو انسخ مجلد الحزمة بجانب مستندك واكتب:

#en[```typ
#import "lib.typ": *
```]

تحتاج الحزمة إلى Typst بإصدار 0.13 أو أحدث، وتحمّل CeTZ تلقائيًا. للنص العربي استعمل خطًا عربيًا (مثل *Amiri*) مع `lang: "ar"`.

= أنواع الأسطر

كل عنصر في `label` هو مصفوفة `(العنوان, النوع)` أو `(العنوان, الارتفاع, النوع)`.

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*النوع*], [*المعنى*],
  [`"s"`], [سطر إشارة. و#strong[سطر الفرق] `f(x) - g(x)` هو سطر إشارة عادي.],
  [`"v"`], [سطر تغيّرات.],
  [`"p"`], [*سطر الوضع النسبي* (جديد).],
)

اسم الدالة `tabpos` (والاسم `tabvar` مُصدَّر أيضًا وهو الدالة نفسها).

= سطر الفرق وارتفاعه

يُكتب سطر الفرق كسطر إشارة عادي. وعندما يقع *مباشرة قبل* سطر `"p"` يكون ارتفاعه `diff-height` وقيمته الافتراضية *1 سم*:

#demo(```typ
#tabpos(
  variable: $x$,
  label: (
    ([$f(x) - y$], "s"),     // سطر الفرق : 1 سم
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
```)

== تغيير الارتفاعات

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*الطريقة*], [*الأثر*],
  [#en[`diff-height: 1cm`]], [الافتراضي. ارتفاع كل سطر فرق (سطر `"s"` يليه سطر `"p"`).],
  [#en[`diff-height: 2cm`]], [ارتفاع آخر لكل أسطر الفرق في الجدول.],
  [#en[`diff-height: none`]], [ارتفاع تلقائي (سلوك vartable القديم، نحو 2.75 سم).],
  [#en[`([عنوان], 1.5cm, "s")`]], [ارتفاع مكتوب في السطر نفسه: له الأولوية على `diff-height`.],
  [#en[`pos-height: 3cm`]], [الارتفاع الافتراضي لأسطر `"p"` (3 سم).],
  [#en[`([عنوان], 3cm, "p")`]], [ارتفاع سطر `"p"` واحد بعينه.],
)

#demo(```typ
#tabpos(
  variable: $x$,
  diff-height: 2cm,        // سطر فرق أطول
  pos-height: 2cm,         // سطر وضع نسبي أقصر
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $0$, $+oo$),
  contents: (($-$, ("0", $+$)), ("-", ("0", "+"))),
)
```)

= سطر `"p"`

يُكتب تمامًا مثل سطر الإشارة، مع هذه الفروق:

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*المُدخَل*], [*النتيجة*],
  [#en[`"+"`]], [*فوق*: النص `(C_f) / فوق / (C_g)`.],
  [#en[`"-"`]], [*تحت*: النص `(C_f) / تحت / (C_g)`.],
  [#en[`("0", "+")`]], [القوسان عند الطرف الأيسر للمجال، ثم *فوق*.],
  [#en[`(content, "-")`]], [القوسان مع المحتوى (مثل النقطة `$A(-1 ; 0)$`) تحت النص، ثم *تحت*.],
  [#en[`"|h|"`, `"h"`, `"h|"`, `"|h"`, `("||", "+")`]], [مثل vartable: مناطق مهشّرة وأشرطة.],
)

استعمل النصّين `"+"` و`"-"` (وليس `$+$`) في سطر `"p"`.

= خيارات `tabpos`

#table(
  columns: (auto, auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [*الخيار*], [*الافتراضي*], [*المعنى*],
  [#en[`diff-height`]], [#en[`1cm`]], [ارتفاع سطر الفرق (سطر `"s"` قبل سطر `"p"` مباشرة)؛ `none` = تلقائي.],
  [#en[`pos-height`]], [#en[`3cm`]], [الارتفاع الافتراضي لسطر `"p"`، أو لكل سطر: `([عنوان], 3cm, "p")`.],
  [#en[`first`]], [#en[`auto` = `$(C_f)$`]], [اسم المنحنى الأول. انظر #link(<names>)[تسمية المنحنيين والمستقيم].],
  [#en[`second`]], [#en[`auto` = `$(C_g)$`]], [اسم المنحنى الثاني أو المستقيم، مثل `$(Delta)$`.],
  [#en[`above`, `below`]], [#en[`auto`]], [كلمتا الوضعين. `auto` = الكلمة بلغة المستند.],
  [#en[`cross`]], [#en[`auto`]], [الكلمة بين المنحنيين عند نقطة التقاطع.],
  [#en[`at-point`]], [#en[`auto`]], [الكلمة قبل اسم النقطة.],
  [#en[`arc-width`]], [#en[`0.94`]], [نصف المسافة بين القوسين (وحدات CeTZ، الوحدة = 1 سم).],
)

وتبقى كل خيارات vartable تعمل (`hatching-style`, `values`, `table-style`, `first-line-height`, …).

= تسمية المنحنيين والمستقيم <names>

الاسمان الافتراضيان هما $(C_f)$ و$(C_g)$: الخيار `first` يغيّر اسم $(C_f)$، والخيار `second` يغيّر اسم $(C_g)$ (أو يسمّي المستقيم، مثل $(Delta)$). غيّرهما *مرة واحدة لكل المستند* بالدالة `tabpos-names`، وكل جدول بعدها يستعمل الاسمين الجديدين. مثال: منحنى ومستقيم $(Delta)$:

#demo(```typ
#tabpos-names(first: $(C_f)$, second: $(Delta)$)
#tabpos(
  variable: $x$,
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
```)

#tabpos-names(first: $(C_f)$, second: $(C_g)$)

ولجدول واحد فقط يمكنك تجاوز الاسمين بالخيارين `first` و`second` دون المساس ببقية الجداول:

```typ
#tabpos(first: $(C_1)$, second: $(C_2)$, ...)
```

استدعِ `tabpos-names` من جديد في أي موضع لتغيير الاسمين للجداول التي بعده. واكتب `auto` (أو احذف الوسيط) للإبقاء على أحد الاسمين دون تغيير، مثل `#tabpos-names(second: $(Delta)$)`.

= لغة الكلمات

كلمات سطر `"p"` الافتراضية تتبع اللغة المحدّدة بـ `#set text(lang: ...)` تمامًا مثل أي نص في المستند:

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 6pt,
  stroke: 0.5pt + luma(60%),
  [*اللغة*], [*above*], [*below*], [*cross*], [*at-point*],
  [#en[`ar`]], [فوق], [تحت], [يقطع], [في النقطة],
  [#en[`fr`]], [#en[au-dessus]], [#en[au-dessous]], [#en[coupe]], [#en[au point]],
  [#en[`en`]], [#en[above]], [#en[below]], [#en[crosses]], [#en[at the point]],
  [#en[`es`]], [#en[encima]], [#en[debajo]], [#en[corta]], [#en[en el punto]],
  [#en[`de`]], [#en[oberhalb]], [#en[unterhalb]], [#en[schneidet]], [#en[im Punkt]],
  [#en[`it`]], [#en[sopra]], [#en[sotto]], [#en[interseca]], [#en[nel punto]],
  [#en[`pt`]], [#en[acima]], [#en[abaixo]], [#en[corta]], [#en[no ponto]],
  [#en[`nl`]], [#en[boven]], [#en[onder]], [#en[snijdt]], [#en[in het punt]],
  [#en[`tr`]], [#en[üstünde]], [#en[altında]], [#en[keser]], [#en[noktasında]],
  [#en[`ru`]], [#en[выше]], [#en[ниже]], [#en[пересекает]], [#en[в точке]],
)

#en[```typ
#set text(lang: "fr")      // => "au-dessus", "au-dessous", "coupe", "au point"
#tabpos(/* ... */)
```]

للغة أخرى أو لصياغة أخرى اكتب الكلمات بنفسك: `above: [oberhalb], below: [unterhalb]`.

= أمثلة أخرى

== منحنيان

#demo(```typ
#tabpos(
  variable: $x$,
  second: $(C_g)$,
  label: (([$f(x) - g(x)$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $0$, $+oo$),
  contents: (($-$, ("0", $+$)), ("-", ("0", "+"))),
)
```)

== قيمة ممنوعة، $D_f = RR without {1}$

#demo(```typ
#tabpos(
  variable: $x$,
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $1$, $+oo$),
  contents: (($-$, ("||", $+$)), ("-", ("||", "+"))),
)
```)

== جزء محذوف من الوسط (تهشير)

#demo(```typ
#tabpos(
  variable: $x$,
  hatching-style: hatch,
  label: (([$f(x) - y$], "s"), ([الوضع النسبي], "p")),
  domain: ($-oo$, $-2$, $2$, $+oo$),
  contents: (($-$, "|h|", $+$), ("-", "|h|", "+")),
)
```)

== إشارة وتغيّرات وفرق ووضع نسبي في جدول واحد

#demo(```typ
#tabpos(
  variable: $x$,
  label: (
    ([$f'(x)$], "s"),
    ([$f(x)$], "v"),
    ([$f(x) - y$], "s"),
    ([الوضع النسبي], "p"),
  ),
  domain: ($-oo$, $0$, $+oo$),
  contents: (
    ($-$, ("||", $-$)),
    ((center, $0$), (bottom, top, "||", $-oo$, $+oo$), (center, $0$)),
    ($+$, ("||", $-$)),
    ("+", ("||", "-")),
  ),
)
```)

== كلمات بالإنجليزية

#demo(```typ
#tabpos(
  variable: $x$,
  second: $(Delta)$,
  above: [above], below: [below], cross: [crosses], at-point: [at],
  label: (([$f(x) - y$], "s"), ([Position], "p")),
  domain: ($-oo$, $-1$, $1$, $+oo$),
  contents: (
    ($+$, ("0", $-$), ("0", $+$)),
    ("+", ($A(-1 ; 0)$, "-"), ($B(1 ; 0)$, "+")),
  ),
)
```)

= ملفات الحزمة

#table(
  columns: (auto, 1fr),
  inset: 7pt,
  stroke: 0.5pt + luma(60%),
  [#en[`lib.typ`]], [الحزمة كلها في ملف واحد (شيفرة مشتقة من vartable 0.2.5، مع سطر `"p"` و`diff-height` والكلمات التابعة للغة). تُصدِّر `tabpos` و`tabvar` و`hatch` و`grille`…],
  [#en[`typst.toml`, `LICENSE`]], [بيان الحزمة والتراخيص.],
  [#en[`README.md`]], [تعريف مختصر (إنجليزي وعربي في ملف واحد).],
  [#en[`documentationEN.typ` / `.pdf`]], [الدليل بالإنجليزية.],
  [#en[`documentationAR.typ` / `.pdf`]], [هذا الدليل بالعربية.],
  [#en[`examples/`]], [أمثلة جاهزة للترجمة (`.typ` و`.pdf`).],
  [#en[`fichier_de_test/`]], [ملفات اختبار: الارتفاعات وخيارات `"p"` والتهشير.],
)

= حلّ المشكلات

- *كلمات سطر `"p"` ليست بلغتي:* هي تتبع `#set text(lang: ...)`؛ أو اكتب `above` و`below` و`cross` و`at-point` بنفسك.
- *`+` أو `-` لا تعطي الكلمات:* اكتب في سطر `"p"` النصّين `"+"` و`"-"` وليس `$+$`.
- *الحروف العربية مقطّعة أو ناقصة:* حدّد خطًا عربيًا: `#set text(font: "Amiri", lang: "ar")`.
- *أريد الارتفاع التلقائي القديم لسطر الفرق:* اكتب `diff-height: none`.

= الحقوق والترخيص

`na-tabpos` © Naam Mohamed (MIT). وشيفرة `lib.typ` مشتقة من *vartable* © Le_Foucheur (MIT) — ويحمل ملف `LICENSE` حقوق الطرفين.
