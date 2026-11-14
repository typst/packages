// توثيق الحزمة na-courbe v0.1.0  —  شغّله بـ: typst compile doc.typ
#import "@preview/na-courbe:0.1.0": courbe, integrale, papier-milli

#let page-margin = 2cm
#set page(paper: "a4", margin: page-margin, fill: white, numbering: "1")
#set text(font: ("Amiri", "Arial"), lang: "ar", dir: rtl, size: 13pt)
#set par(justify: true, leading: 0.8em, first-line-indent: 0pt)

// ════════════════════════════════════════════════════════════
//  تنسيق الوحدة (من section.typ)  ←  العناوين من المستوى 1
// ════════════════════════════════════════════════════════════
#let triangle-shape(color) = curve(
  fill: color,
  curve.move((8mm, 1mm)),
  curve.cubic((5mm, 0.5mm), (3mm, 2mm), (3mm, 4.5mm)),
  curve.line((3mm, 21.5mm)),
  curve.cubic((3mm, 24.5mm), (5mm, 26mm), (8mm, 24.5mm)),
  curve.line((25mm, 16mm)),
  curve.cubic((29mm, 14mm), (29mm, 11mm), (25mm, 9mm)),
  curve.line((9mm, 1.5mm)),
  curve.cubic((8.6mm, 1.3mm), (8.3mm, 1.1mm), (8mm, 1mm)),
  curve.close(mode: "straight"),
)

#let unit-icon(
  number,
  color: rgb("#08a9ea"),
  shadow-color: rgb("#26343d"),
  circle-color: white,
  number-color: rgb("#08a9ea"),
) = block(width: 34mm, height: 29mm, inset: 0pt)[
  #place(top + left, dx: 9mm, dy: 3mm)[#triangle-shape(shadow-color)]
  #place(top + left, dx: 9mm)[#triangle-shape(color)]
  #place(top + left, dx: 1mm, dy: 6mm)[#circle(radius: 8.7mm, fill: rgb("#bbbbbb"))]
  #place(top + left, dy: 5mm)[
    #circle(radius: 8.7mm, fill: circle-color, stroke: 0.6pt + rgb("#dddddd"))
  ]
  #place(top + left, dy: 5mm)[
    #block(width: 17.4mm, height: 17.4mm, inset: 0pt)[
      #align(center + horizon)[
        #text(font: "Noto Sans", size: 24pt, weight: "bold", fill: number-color)[#number]
      ]
    ]
  ]
]

#let unit-heading(
  number,
  title,
  note: none,
  width: 100%,
  color: rgb("#08a9ea"),
  title-color: black,
  note-color: black,
) = {
  let icon-width = 30mm
  let gap = 4mm
  let text-width = width - icon-width - gap
  let row-height = if note == none { 26mm } else { 39mm }

  block(width: width, height: row-height, inset: 0pt, breakable: false)[
    #place(top + right)[
      #scale(88%, origin: top + right)[
        #unit-icon(number, color: color, number-color: color)
      ]
    ]
    #place(top + right, dx: -(icon-width + gap))[
      #block(width: text-width, height: 26mm, inset: 0pt)[
        #align(right + horizon)[
          #text(font: ("Amiri", "Arial"), lang: "ar", dir: rtl, size: 22pt,
            weight: "bold", fill: title-color)[#title]
        ]
      ]
    ]
    #if note != none {
      place(top + right, dy: 26mm)[
        #block(width: icon-width, inset: 0pt)[
          #align(center)[#text(size: 12pt, fill: note-color)[#note]]
        ]
      ]
    }
  ]
}

// ════════════════════════════════════════════════════════════
//  تنسيق الوحدة الفرعية (من explika.typ)  ←  العناوين من المستوى 2
//  الترقيم: رقم الفرعية أولًا ثم رقم الوحدة  1.3 ، 2.3 ، 3.3 ...
// ════════════════════════════════════════════════════════════
#let sub-inverse = true    // true ⇒ (الفرعية.الوحدة) مثل 1.3 ، 2.3   |   false ⇒ (الوحدة.الفرعية) مثل 3.1 ، 3.2

#let sub-num = context {
  let n = counter(heading).get()
  let parts = if sub-inverse { n.rev() } else { n }
  // نرصّ الأجزاء من اليسار إلى اليمين بـ stack كي لا يقلبها اتجاه النص العربي
  let items = ()
  for (i, part) in parts.enumerate() {
    if i > 0 { items.push(".") }
    items.push(str(part))
  }
  box(stack(dir: ltr, spacing: 0pt, ..items.map(t => text(t))))
}

#let sub-style(it) = {
  v(0.6cm, weak: true)
  block(width: 100%, height: 1.77cm, breakable: false, sticky: true)[
    // المستطيل الأزرق
    #place(horizon + left)[
      #block(
        width: 100% - 0.9cm,
        height: 1.4cm,
        fill: rgb("#00CCFF"),
        radius: (left: 0.5cm, right: 0cm),
        inset: (right: 1.2cm, left: 0.4cm),
      )[
        #align(horizon + right)[
          #text(size: 19pt, weight: "bold", fill: white, font: "Arial")[#it.body]
        ]
      ]
    ]
    // الدائرة وفيها الترقيم 1.1
    #place(horizon + right)[
      #block(
        fill: white,
        width: 1.77cm,
        height: 1.77cm,
        radius: 50%,
        stroke: rgb("#00CCFF") + 2pt,
      )[
        #align(center + horizon)[
          #text(size: 15pt, weight: "bold", fill: rgb("#350758"), font: "Arial")[#sub-num]
        ]
      ]
    ]
  ]
  v(0.4cm, weak: true)
}

#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  v(0.6cm, weak: true)
  unit-heading(counter(heading).display("1"), it.body)
  v(0.4cm)
}
#show heading.where(level: 2): it => sub-style(it)
#show heading.where(level: 3): set text(size: 14pt, fill: rgb("#08a9ea"))

// ════════════════════════════════════════════════════════════
//  صناديق الشيفرة (من explika.typ)
// ════════════════════════════════════════════════════════════
#show raw: set text(font: ("DejaVu Sans Mono", "Consolas"), size: 9.5pt, dir: ltr)
#show raw.where(block: true): set block(
  fill: rgb("#ddf3f3"), inset: 14pt, radius: 2pt, width: 100%,
  stroke: 0.3pt + gray, breakable: true,
)
#show raw.where(block: true): it => align(left, it)

#let note(title, body, color: rgb("#e8a317")) = block(
  width: 100%, inset: 10pt, radius: 4pt, breakable: false,
  fill: color.lighten(88%), stroke: (right: 3pt + color),
)[*#title* \ #body]

// يعرض الشيفرة ثم نتيجتها المحسوبة فعليًا
#let demo(code) = {
  let src = code.text
  block(width: 100%, breakable: false, stroke: 0.6pt + luma(190), radius: 4pt, clip: true)[
    #{
      show raw.where(block: true): set block(fill: none, stroke: none, inset: 0pt, radius: 0pt)
      block(width: 100%, fill: rgb("#ddf3f3"), inset: 12pt, code)
    }
    #block(width: 100%, inset: 10pt, align(center)[
      #set text(dir: ltr)
      #eval(src, mode: "markup", scope: (courbe: courbe, integrale: integrale, papier-milli: papier-milli))
    ])
  ]
}

#let tbl(..rows) = table(
  columns: (auto, 1fr, auto), inset: 6pt, stroke: 0.5pt + luma(180),
  fill: (_, y) => if y == 0 { rgb("#dbe8f7") },
  align: (left, right, left),
  table.header([*الوسيط*], [*المعنى*], [*الافتراضي*]),
  ..rows,
)

// ── الغلاف ──
#align(center)[
  #v(1.5cm)
  #block(
    width: 100%, inset: (y: 1cm), radius: (top-left: 1cm, bottom-right: 1cm),
    fill: rgb("#ddf3f3"), stroke: 1pt + rgb("#00CCFF"),
  )[
    #text(size: 34pt, weight: "bold", fill: rgb("#350758"))[الحزمة #text(fill: rgb("#08a9ea"),size:74pt)[`na-courbe`]]
    #v(0.2cm)
    #text(size: 17pt)[حزمة متكاملة لرسم الدوال في Typst]
  ]
  #v(0.6cm)
  #courbe(x => x * x - 2, x: (-3, 3), y: (-3, 5), size: (9, 5), nom: $C_f$,
    autres: ((f: x => 4 - x * x, nom: $C_g$, trait: "tirets"),),
    aire: (-calc.sqrt(3), calc.sqrt(3)), aire-avec: x => 4 - x * x,
    xlabel: $x$, ylabel: $y$, origine: $O$)
  #v(0.6cm)
  #text(size: 12pt, fill: luma(90))[الإصدار 0.1.0 · الأستاذ نسيم · #link("doc-en.typ")[English documentation]]
]
// ── الفهرس: بدون ترقيم، بعنوان ملوّن وسطور مرتبة ──
#let toc-blue = rgb("#08a9ea")
#let toc-dark = rgb("#350758")

#show outline.entry: it => {
  let loc = it.element.location()
  if it.level == 1 {
    block(above: 1.2em, below: 0.5em, breakable: false, link(loc, it.indented(none, {
      box(width: 4pt, height: 0.9em, fill: toc-blue, radius: 1pt, baseline: 0.1em)
      h(6pt)
      text(size: 14.5pt, weight: "bold", fill: toc-dark, it.element.body)
      h(5pt)
      box(width: 1fr, text(fill: toc-blue, it.fill))
      h(5pt)
      text(size: 13pt, weight: "bold", fill: toc-blue, it.page())
    })))
  } else {
    block(above: 0.7em, below: 0.3em, breakable: false, link(loc, it.indented(none, {
      h(1.2cm)
      text(size: 12pt, fill: luma(60), it.element.body)
      h(5pt)
      box(width: 1fr, text(fill: luma(160), it.fill))
      h(5pt)
      text(size: 12pt, fill: luma(60), it.page())
    })))
  }
}

// عنوان الفهرس بنفس لون الوحدات الفرعية
#block(width: 100%, height: 1.4cm, fill: rgb("#00CCFF"), radius: (left: 0.5cm, right: 0cm),
  inset: (right: 0.8cm), breakable: false)[
  #align(horizon + right)[
    #text(size: 22pt, weight: "bold", fill: white, font: "Arial")[المحتويات]
  ]
]
#v(0.4cm)
#outline(title: none, depth: 2, indent: 0pt)
#pagebreak()

= مقدمة

الدالة `courbe` ترسم في معلم واحد كل ما نحتاجه في درس الدوال:

- منحنيات بأنواع خطوط مختلفة: متصل، متقطع، منقط، مختلط، *على شكل نقاط*، أو خط مع نقاط.
- *دوال معرّفة بقطع* مع نقاط مفتوحة ومغلقة عند الأطراف.
- *أسماء توضع في المكان الذي تريد* لكل عنصر: منحنى، مستقيم، مقارب، نقطة، مماس، حيز، مع نصوص حرة، وإزاحة دقيقة لكل اسم.
- *ورقة مليمترية*: شبكة بخطوط كل 1 مم و5 مم و1 سم، بالطول الفعلي للمحورين تمامًا، مع اختيار لونها.
- *نوع الشبكة*: رئيسية، ثانوية، كلتاهما، مليمترية، أو بدون شبكة، مع التحكم في نمط خطها ولونها وسمكها.
- *مظهر عام*: خلفية، إطار، عنوان، ولون المحاور وسمكها.
- *طول التدريجات* على كل محور على حدة، وحجم أرقام التدريج.
- *ترقيم عادي أو مثلثي* (مضاعفات $pi$) لتدريج المحورين.
- نقاط (على المنحنى أو حرة، مفتوحة أو مغلقة) مع إسقاطات على المحورين.
- مستقيمات وقطع مستقيمة ومقاربات ومماس.
- حيز بين منحنى والمحور، أو بين منحنيين، أو بين منحنى ومستقيم، مع حساب مساحته.

= التثبيت

ضع المجلد في `~/.local/share/typst/packages/local/na-courbe/0.1.0/` (Linux) أو ما يقابله في macOS وWindows، ثم:
```typ
#import "@local/na-courbe:0.1.0": courbe, integrale, papier-milli
```
أو من Typst Universe بعد نشرها:
```typ
#import "@preview/na-courbe:0.1.0": courbe, integrale, papier-milli
```
#note("تنبيه")[داخل نص عربي ضع `#set text(dir: ltr)` قبل الرسم ليبقى المعلم من اليسار إلى اليمين.]

= الوسائط

== المنحنى الرئيسي
#tbl(
  [`f`], [الدالة `x => ...`، أو `none` إن استعملت `morceaux` فقط (إجباري)], [—],
  [`domain`], [مجال الرسم `(a, b)`], [`(-4, 4)`],
  [`branches`], [مجالات منفصلة عند المقارب العمودي], [`none`],
  [`morceaux`], [دالة بقطع: `(f:, domain:, gauche:, droite:, nom:, couleur:, trait:)`، والطرف `"ouvert"` أو `"ferme"`], [`()`],
  [`couleur`], [لون المنحنى], [`blue`],
  [`trait`], [نوع الخط: `"continu"`, `"tirets"`, `"pointille"`, `"mixte"`, `"points"`, `"lie"`], [`"continu"`],
  [`epaisseur`], [سمك الخط], [`1.6pt`],
  [`marque`, `npts`], [شكل النقاط (`"o"`, `"x"`, `"+"`, `"*"`, `"square"`, `"triangle"`) وعددها لـ `"points"` و`"lie"`], [`"o"`, `25`],
  [`autres`], [منحنيات أخرى: نفس مفاتيح المنحنى (`f`, `nom`, `couleur`, `trait`, `domain`, `branches`, `morceaux`...)], [`()`],
)

== الأسماء (موضع حر)
لكل عنصر (منحنى، مستقيم، مقارب، قطعة، مماس، نقطة) المفاتيح التالية، وتعمل كلها داخل `autres` و`droites` و`segments` و`va` و`ha` و`tangente` و`points` أيضًا.
#tbl(
  [`nom`], [اسم العنصر، مثل `$C_f$`], [`none`],
  [`nom-pos`], [موضع حر `(x, y)` للاسم بإحداثيات المعلم؛ وإلا يوضع قرب نهاية العنصر], [`none`],
  [`nom-t`], [موضع الاسم على العنصر نفسه كنسبة من `0` (البداية) إلى `1` (النهاية)، إن لم تستعمل `nom-pos`], [`auto`],
  [`nom-x`], [فاصلة الاسم على المنحنى أو المستقيم (بديل عن `nom-t`)], [`auto`],
  [`nom-dx`, `nom-dy`], [إزاحة إضافية للاسم بوحدات المعلم، تُضاف فوق أي موضع آخر], [`0`, `0`],
  [`nom-ancre`], [أي طرف من النص يلتصق بالنقطة: `"center"`, `"north"`, `"south-east"`...], [`auto`],
  [`textes`], [نصوص حرة: `((pos: (1, 2), t: [نص], couleur:, ancre:),)`], [`()`],
  [`origine`], [اسم نقطة الأصل، مثل `$O$`], [`none`],
  [`fond-noms`], [خلفية بيضاء خلف الأسماء لتسهل قراءتها], [`false`],
)

== المستقيمات والنقاط
#tbl(
  [`droites`], [`(a:, b:)` للمستقيم $y = a x + b$ أو `(x: c)` للعمودي؛ مع `nom`, `nom-pos`, `nom-t`, `couleur`, `trait`], [`()`],
  [`segments`], [`(de: (x1, y1), a: (x2, y2), nom:, trait:, couleur:)`؛ `nom-t` نسبة بين الطرفين], [`()`],
  [`va`, `ha`], [مقاربات: أعداد أو `(v: 2, nom: $x=2$, nom-pos: (..))`], [`()`],
  [`tangente`], [فاصلة التماس أو `(a: 1.5, nom: $T$, nom-pos: (..))`], [`none`],
  [`points`], [عدد (نقطة على المنحنى)، أو `(v:, nom:, proj:, ouvert:, marque:, couleur:, nom-pos:)`، أو نقطة حرة `(p: (x, y), ...)`], [`()`],
)

== الحيز
#tbl(
  [`aire`], [مجال الحيز `(a, b)`], [`none`],
  [`aire-avec`], [دالة ثانية تحدّ الحيز بدل المحور], [`none`],
  [`aire-couleur`], [لون التظليل], [`auto`],
  [`aire-nom`, `aire-nom-pos`], [اسم الحيز وموضعه الحر], [`none`],
)

== المعلم والسلم
#tbl(
  [`x`, `y`], [حدود المحورين], [`(-5, 5)`],
  [`xstep`, `ystep`], [خطوة التدريج الرئيسي؛ مع الترقيم المثلثي تصبح $pi$/المقام تلقائيًا], [`auto` ⇒ `1`],
  [`xminor`, `yminor`], [خطوة التدريج الثانوي], [`none`],
  [`xunite`, `yunite`], [طول الوحدة بالسنتيمتر على كل محور على حدة، مثل `xunite: 2` أو `yunite: 0.5cm`؛ مع الترقيم المثلثي هو طول $pi$ كاملة. لهما الأولوية على `echelle` و`size`], [`auto`],
  [`echelle`], [`(سم لكل وحدة أفقيًا, سم لكل وحدة رأسيًا)` في وسيط واحد], [`none`],
  [`size`], [الأبعاد بالسنتيمتر إن لم تُحدد `echelle`], [`(8, 6)`],
  [`xlabel`, `ylabel`], [تسمية المحورين], [`none`],
  [`samples`], [دقة الرسم], [`150`],
)

== الشبكة
#tbl(
  [`grille`], [نوع الشبكة: `true` أو `"principale"` (عند التدريج الرئيسي) · `"secondaire"` (عند التدريج الثانوي) · `"toutes"` (الاثنتان) · `"millimetre"` (ورقة مليمترية، وأسماؤها المرادفة `"milli"` و`"mm"` و`"papier"`) · `false` أو `"aucune"` (بدون شبكة)], [`true`],
  [`grille-x`, `grille-y`], [نوع شبكة كل محور على حدة (القيم نفسها)؛ `auto` يتبع `grille`], [`auto`],
  [`grille-trait`], [نمط الخط: `"continu"`, `"tirets"`, `"pointille"`, `"mixte"`], [`auto`],
  [`grille-couleur`], [لون خطوط الشبكة (والثانوية أفتح منه). مع الورقة المليمترية تُشتق منه الدرجات الثلاث، والافتراضي برتقالي محمر], [`auto`],
  [`grille-epaisseur`], [سمك خط الشبكة الرئيسية (الثانوية أرق بنسبة 60%). مع الورقة المليمترية هو سمك خط السنتيمتر، وخط 5 مم 60% منه وخط 1 مم 30% منه], [`auto`],
  [`milli-fin`], [الورقة المليمترية: إظهار خطوط 1 مم؛ مع `false` تبقى خطوط 5 مم و1 سم فقط], [`true`],
  [`milli-ancre`], [الورقة المليمترية: `"origine"` تجعل خطوط السنتيمتر تمر بنقطة الأصل (فتنطبق على التدريجات)، و`"coin"` تبدأ العدّ من الزاوية السفلية اليسرى], [`"origine"`],
)

#note("الورقة المليمترية", color: rgb("#27ae60"))[الشبكة المليمترية تُرسم بالمليمتر الفعلي على الورق، وتمتد من أول المحور إلى آخره تمامًا (عرض الرسم × ارتفاعه)، وتحيط بها حدود. لتنطبق خطوط السنتيمتر على التدريجات اجعل `xunite` و`yunite` أعدادًا صحيحة من السنتيمترات (أو اترك `size` بحيث يكون عرضه مساويًا لعدد وحدات `x`).]

== المظهر العام
#tbl(
  [`fond`], [لون خلفية الرسم، مثل `rgb("#fffbe6")`], [`none`],
  [`cadre`], [`true` لإطار أسود، أو لون للإطار], [`none`],
  [`titre`], [عنوان يوضع فوق الرسم، مثل `[منحنى الدالة]`], [`none`],
  [`axes-couleur`], [لون المحورين], [`auto`],
  [`axes-epaisseur`], [سمك المحورين، مثل `1.2pt`], [`auto`],
)

الدالة `papier-milli(..)` اختصار لورقة مليمترية فارغة: تقبل وسائط `courbe` نفسها (ما عدا `f`)، وتضبط `grille: "millimetre"`.
#note("ملاحظة", color: rgb("#27ae60"))[عند اختيار `"secondaire"` أو `"toutes"` دون تحديد `xminor`/`yminor` تُحسب الخطوة الثانوية تلقائيًا (خُمس الخطوة الرئيسية، ونصفها في الترقيم المثلثي).]

== طول التدريجات والترقيم
#tbl(
  [`xtick`, `ytick`], [طول التدريج الرئيسي بالسنتيمتر على كل محور (مثل `0.25` أو `3mm`)], [`auto`],
  [`tick-minor`], [نسبة طول التدريج الثانوي إلى الرئيسي], [`0.6`],
  [`tick-taille`], [حجم خط أرقام التدريج، مثل `9pt`], [`auto`],
  [`xnum`, `ynum`], [نوع ترقيم التدريج: `"normal"` أو `"pi"` (مضاعفات $pi$ مثل $pi/2$ و $3pi/2$ و $-pi$)], [`"normal"`],
  [`xpi`, `ypi`], [مقام $pi$ في الترقيم المثلثي: `2` ⇒ تدريج كل $pi/2$، `3` ⇒ كل $pi/3$، `6` ⇒ كل $pi/6$...], [`2`, `2`],
)

= أمثلة

== وضع الأسماء في الأماكن التي تريد
كل `nom-pos` يعيّن مكان الاسم بإحداثيات المعلم، و`textes` تضع أي نص في أي مكان.

#demo(```typ
#courbe(
  x => x * x / 2,
  domain: (-3, 3), x: (-3, 3), y: (-1, 5),
  nom: $C_f$, nom-pos: (-2.4, 3.4),
  droites: ((a: 1, b: 0.5, nom: $d$, nom-pos: (2.5, 1.4)),),
  textes: ((pos: (0, 4.4), t: [قطع مكافئ], couleur: blue),),
  points: ((v: 2, nom: $M$, nom-pos: (2.35, 1.6)),),
  fond-noms: true, origine: $O$,
  xlabel: $x$, ylabel: $y$,
)
```)

== الاسم على المنحنى نفسه بنسبة وإزاحة
`nom-t` يضع الاسم عند نسبة من طول المجال (`0` البداية و`1` النهاية)، و`nom-dx` و`nom-dy` يزيحانه قليلًا.

#demo(```typ
#courbe(
  x => x * x / 2 - 1,
  domain: (-3, 3), x: (-3, 3), y: (-2, 5),
  nom: $C_f$, nom-t: 0.15, nom-dx: -0.2, nom-dy: 0.3,
  droites: ((a: -1, b: 2, nom: $d$, nom-t: 0.2, nom-dy: 0.3, nom-ancre: "south"),),
  segments: ((de: (-2, 1), a: (2, 1), nom: $[A B]$, nom-t: 0.8, nom-dy: 0.25, trait: "tirets", couleur: red),),
)
```)

== أنواع الشبكة
`grille: "toutes"` ترسم الشبكتين الرئيسية والثانوية، و`grille: "secondaire"` الثانوية فقط، و`grille: false` تحذف الشبكة.

#demo(```typ
#courbe(
  x => x * x / 2,
  domain: (-3, 3), x: (-3, 3), y: (-1, 5), size: (8, 5),
  grille: "toutes", xminor: 0.5, yminor: 0.5,
  grille-trait: "pointille", grille-couleur: gray,
  nom: $C_f$,
)
```)

نفس الدالة بشبكة أفقية فقط (`grille-x` مع `false`) ومن غير تدريج ثانوي:

#demo(```typ
#courbe(
  x => x * x / 2,
  domain: (-3, 3), x: (-3, 3), y: (-1, 5), size: (8, 5),
  grille-x: false, grille-y: true, grille-trait: "tirets",
  nom: $C_f$,
)
```)

== الورقة المليمترية
`grille: "millimetre"` ترسم ورقة مليمترية: خط كل 1 مم رقيق، وكل 5 مم متوسط، وكل 1 سم سميك. الشبكة بطول المحورين تمامًا.

#demo(```typ
#courbe(
  x => x * x / 4 - 1,
  domain: (-4, 4), x: (-4, 4), y: (-2, 4),
  grille: "millimetre",
  nom: $C_f$, nom-t: 0.9, nom-dy: 0.3,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

=== تغيير لون الشبكة
`grille-couleur` يغيّر لون الورقة المليمترية (وكل أنواع الشبكة الأخرى)، و`grille-epaisseur` سمكها.

#demo(```typ
#courbe(
  x => calc.sin(x) * 2,
  domain: (-4, 4), x: (-4, 4), y: (-3, 3),
  grille: "millimetre", grille-couleur: blue,
  nom: $C_f$, nom-t: 0.8, nom-dy: 0.3, origine: $O$,
)
```)

#demo(```typ
#courbe(
  x => x * x / 2,
  domain: (-3, 3), x: (-3, 3), y: (-1, 5),
  grille: "millimetre", grille-couleur: green.darken(10%),
  grille-epaisseur: 1pt, milli-fin: false,
  nom: $C_f$, nom-t: 0.9, nom-dy: 0.3,
)
```)

=== وحدتان مختلفتان على المحورين
مع `xunite` و`yunite` تتبع الشبكة الطول الجديد للمحورين تلقائيًا.

#demo(```typ
#courbe(
  x => calc.sqrt(x),
  domain: (0, 8), x: (-1, 8), y: (-1, 4),
  grille: "millimetre", xunite: 1, yunite: 1.5,
  cadre: true, titre: [$y = sqrt(x)$],
  nom: $C_f$, origine: $O$,
)
```)

=== ورقة مليمترية فارغة
#demo(```typ
#papier-milli(
  x: (0, 10), y: (0, 6),
  grille-couleur: rgb("#2a9d8f"),
)
```)

=== مع الترقيم المثلثي
#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (-calc.pi, calc.pi), x: (-calc.pi, calc.pi), y: (-1.5, 1.5),
  grille: "millimetre", grille-couleur: purple,
  xnum: "pi", xpi: 2, xunite: 6, yunite: 2,
  nom: $sin x$, nom-t: 0.6, nom-dy: 0.3, origine: $O$,
)
```)

== المظهر العام: خلفية وإطار وعنوان
#demo(```typ
#courbe(
  x => x * x / 4,
  domain: (-4, 4), x: (-4, 4), y: (-1, 4), size: (8, 5),
  fond: rgb("#fffbe6"), cadre: true,
  titre: [القطع المكافئ],
  axes-couleur: maroon, axes-epaisseur: 1.2pt,
  nom: $C_f$, origine: $O$,
)
```)

== طول التدريجات
`xtick` و`ytick` يتحكمان في طول التدريج على المحورين بالسنتيمتر، و`tick-taille` في حجم الأرقام.

#demo(```typ
#courbe(
  x => x * x / 4,
  domain: (-4, 4), x: (-4, 4), y: (-1, 4), size: (8, 5),
  xtick: 0.3, ytick: 0.12, tick-taille: 9pt,
  xlabel: $x$, ylabel: $y$, origine: $O$, nom: $C_f$,
)
```)

== الترقيم المثلثي
مع `xnum: "pi"` تصبح الخطوة $pi/"xpi"$ تلقائيًا وتُكتب الأرقام على شكل مضاعفات $pi$.

#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (-2 * calc.pi, 2 * calc.pi),
  x: (-2 * calc.pi, 2 * calc.pi), y: (-1.5, 1.5),
  echelle: (0.9, 2.2),
  xnum: "pi", xpi: 2,
  nom: $sin x$, nom-t: 0.62, nom-dy: 0.3,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

وبتدريج كل $pi/6$ وشبكة ثانوية:

#demo(```typ
#courbe(
  x => calc.cos(x),
  domain: (-calc.pi, calc.pi),
  x: (-calc.pi, calc.pi), y: (-1.5, 1.5),
  echelle: (2.4, 2.2),
  xnum: "pi", xpi: 6, tick-taille: 8pt,
  grille: "principale", couleur: red,
  nom: $cos x$, nom-t: 0.55, nom-dy: 0.3,
)
```)

== أنواع الخطوط
نفس الدالة بستة أنواع: `continu`, `tirets`, `pointille`, `mixte`, `points`, `lie`.

#demo(```typ
#courbe(
  x => 0.3 * x + 3.0,
  domain: (-3, 3), x: (-3, 3), y: (-3, 4.5),
  nom: [continu], nom-pos: (-2.2, 3.8),
  autres: (
    (f: x => 0.3 * x + 2.0, trait: "tirets", nom: [tirets], nom-pos: (-2.2, 2.8), couleur: red),
    (f: x => 0.3 * x + 1.0, trait: "pointille", nom: [pointille], nom-pos: (-2.2, 1.8), couleur: green),
    (f: x => 0.3 * x + 0.0, trait: "mixte", nom: [mixte], nom-pos: (-2.2, 0.8), couleur: purple),
    (f: x => 0.3 * x - 1.0, trait: "points", npts: 18, nom: [points], nom-pos: (-2.2, -0.2), couleur: orange),
    (f: x => 0.3 * x - 2.0, trait: "lie", marque: "x", npts: 10, nom: [lie], nom-pos: (-2.2, -1.2), couleur: teal),
  ),
  grille: false,
)
```)

== دالة معرّفة بقطع
نمرر `none` كدالة رئيسية ونصف كل قطعة بمجالها. الطرف `"ouvert"` دائرة فارغة و`"ferme"` دائرة ممتلئة.

#demo(```typ
#courbe(
  none, x: (-3, 4), y: (-2, 5),
  morceaux: (
    (f: x => x + 2, domain: (-3, 0), droite: "ouvert", nom: $f_1$),
    (f: x => 0.5 * x * x + 1, domain: (0, 2), gauche: "ouvert", nom: $f_2$),
    (f: x => -x + 5, domain: (2, 4), nom: $f_3$),
  ),
  points: ((p: (0, 0.5), nom: $A$),),
  xlabel: $x$, ylabel: $y$,
)
```)

== تكبير وحدات المحورين كما تريد
`xunite` و`yunite` يحددان طول الوحدة الواحدة بالسنتيمتر على كل محور باستقلال، فيكبر الرسم أو يصغر دون تغيير الحدود.

#demo(```typ
#courbe(
  x => x * x / 4,
  domain: (-4, 4), x: (-4, 4), y: (-1, 4),
  xunite: 0.8, yunite: 1.5,
  nom: $C_f$, origine: $O$,
)
```)

ومع الترقيم المثلثي يكون `xunite` هو طول $pi$ بالسنتيمتر:

#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (-calc.pi, calc.pi), x: (-calc.pi, calc.pi), y: (-1.5, 1.5),
  xnum: "pi", xpi: 2, xunite: 3, yunite: 2,
  nom: $sin x$, nom-t: 0.6, nom-dy: 0.3, origine: $O$,
)
```)

== السلم وتسمية المحاور
#demo(```typ
#courbe(
  x => x * x / 4,
  domain: (-4, 4), x: (-4, 4), y: (-1, 4),
  xstep: 2, ystep: 0.5, echelle: (0.8, 1),
  xlabel: $x$, ylabel: $y$, origine: $O$, nom: $C_f$,
)
```)

== مقاربات ومماس ونقاط بإسقاطات
#demo(```typ
#courbe(
  x => 1 / (x - 1) + 2,
  branches: ((-4, 0.7), (1.3, 5)),
  x: (-4, 5), y: (-3, 7),
  va: ((v: 1, nom: $x = 1$, nom-pos: (1.6, 6.4)),),
  ha: ((v: 2, nom: $y = 2$, nom-pos: (-3, 1.6)),),
  tangente: (a: 3, nom: $T$),
  points: ((v: 3, nom: $A$, proj: true),),
  nom: $C_f$,
)
```)

#note("لماذا `branches`؟", color: rgb("#c0392b"))[
  عند المقارب العمودي يمتد خط مزيّف بين الفرعين إن رسمنا على مجال واحد، فنقسم الرسم إلى مجالين متجاورين من المقارب.
]

== قطعة مستقيمة ونقاط حرة
#demo(```typ
#courbe(
  x => 0.2 * x * x,
  domain: (-4, 4), x: (-4, 4), y: (-1, 5),
  segments: ((de: (-2, 0.8), a: (3, 1.8), nom: $[A B]$, trait: "tirets", couleur: red),),
  points: ((p: (-2, 0.8), nom: $A$), (p: (3, 1.8), nom: $B$, ouvert: true)),
)
```)

== مساحة حيز محدد بمنحنى ومحور الفواصل
#demo(```typ
#courbe(
  x => 4 - x * x,
  domain: (-3, 3), x: (-3, 3), y: (-3, 5),
  aire: (-2, 2), aire-nom: $cal(A)$, aire-nom-pos: (0, 1.5),
  couleur: purple, nom: $C_f$,
)
المساحة = #calc.round(integrale(x => 4 - x * x, -2, 2), digits: 3)
```)

== مساحة حيز بين منحنيين
نمرر المنحنى الثاني في `autres` ليُرسم، وفي `aire-avec` ليحدّ الحيز.

#demo(```typ
#let f = x => x * x - 2
#let g = x => 4 - x * x
#let r = calc.sqrt(3)
#courbe(
  f, x: (-3, 3), y: (-3, 5), nom: $C_f$,
  autres: ((f: g, nom: $C_g$, couleur: orange),),
  aire: (-r, r), aire-avec: g, aire-nom: $cal(A)$,
)
المساحة = #calc.round(integrale(f, -r, r, g: g), digits: 3)
```)

== مساحة حيز بين منحنى ومستقيم
#demo(```typ
#let f = x => x * x
#let d = x => x + 2
#courbe(
  f, x: (-2, 3), y: (-1, 6), nom: $C_f$,
  droites: ((a: 1, b: 2, nom: $d$),),
  aire: (-1, 2), aire-avec: d, aire-nom: $cal(A)$, couleur: teal,
)
المساحة = #calc.round(integrale(f, -1, 2, g: d), digits: 3)
```)

= أمثلة متنوعة

== الدالة الأسية والدالة اللوغاريتمية
المنحنيان متناظران بالنسبة إلى المستقيم $y = x$ المرسوم بتقطيع.

#demo(```typ
#courbe(
  x => calc.exp(x),
  domain: (-3, 1.7), x: (-3, 5), y: (-3, 5), size: (7, 7),
  nom: $e^x$, couleur: blue,
  autres: ((f: x => calc.ln(x), domain: (0.05, 5), nom: $ln x$, couleur: red),),
  droites: ((a: 1, b: 0, trait: "tirets", nom: $y = x$, nom-t: 0.15, nom-dy: 0.3),),
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

== دالة تكعيبية: قيم حدية ومماس
#demo(```typ
#courbe(
  x => x * x * x / 3 - x,
  domain: (-2.5, 2.5), x: (-3, 3), y: (-3, 3), size: (7, 7),
  nom: $C_f$, nom-pos: (-2.2, -2.2),
  points: ((v: 1, nom: $A$, proj: true), (v: -1, nom: $B$, proj: true)),
  tangente: (a: 2, nom: $T$, trait: "tirets"),
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

== دالة القيمة المطلقة
#demo(```typ
#courbe(
  x => calc.abs(x - 1) - 2,
  domain: (-3, 5), x: (-3, 5), y: (-3, 4), size: (8, 5),
  nom: $C_f$, nom-t: 0.9, nom-dy: 0.3,
  points: ((v: 1, nom: $S$, nom-ancre: "north"), (v: -1), (v: 3)),
  grille: "toutes", xminor: 0.5, yminor: 0.5, grille-trait: "pointille",
)
```)

== دالة الجذر التربيعي بنقطة مغلقة
#demo(```typ
#courbe(
  x => calc.sqrt(x),
  domain: (0, 8), x: (-1, 8), y: (-1, 4), size: (8, 5),
  nom: $C_f$, nom-t: 0.7, nom-dy: -0.35,
  points: ((p: (0, 0), nom: $O$, nom-ancre: "north-east"), (v: 4, nom: $A$, proj: true)),
  xlabel: $x$, ylabel: $y$,
)
```)

== دالة كسرية بمقاربين
#demo(```typ
#courbe(
  x => 2 + 3 / (x - 1),
  branches: ((-4, 0.4), (1.5, 5)),
  x: (-4, 5), y: (-3, 9), size: (8, 6),
  va: ((v: 1, nom: $x = 1$, nom-dx: 0.1),),
  ha: ((v: 2, nom: $y = 2$, nom-t: 0.05, nom-dy: -0.4),),
  nom: $C_f$, nom-t: 0.95, nom-dy: -0.4,
  origine: $O$,
)
```)

== دالة سلمية بأطراف مفتوحة ومغلقة
#demo(```typ
#courbe(
  none, x: (-3, 3), y: (-1, 3), size: (8, 4),
  morceaux: (
    (f: x => 1.0, domain: (-3, -1), droite: "ouvert", nom: $f_1$, nom-t: 0.5, nom-dy: 0.3),
    (f: x => 2.0, domain: (-1, 1), gauche: "ferme", droite: "ouvert", nom: $f_2$, nom-t: 0.5, nom-dy: 0.3),
    (f: x => 0.5, domain: (1, 3), gauche: "ferme", nom: $f_3$, nom-t: 0.5, nom-dy: 0.3),
  ),
  xlabel: $x$, ylabel: $y$,
)
```)

== تقاطع منحنى ومستقيم
#demo(```typ
#courbe(
  x => x * x, domain: (-2.5, 3), x: (-3, 3.5), y: (-1, 7), size: (8, 6),
  nom: $C_f$, nom-t: 0.1, nom-dy: 0.3,
  droites: ((a: 1, b: 2, nom: $d$, nom-t: 0.1, nom-dy: -0.3),),
  points: ((p: (-1, 1), nom: $A$, proj: true), (p: (2, 4), nom: $B$, proj: true)),
  origine: $O$,
)
```)

== عائلة منحنيات
نحرك المعامل $a$ في $y = a x^2$ ونكتب قيمته بجانب كل منحنى.

#demo(```typ
#courbe(
  x => 0.5 * x * x, domain: (-3, 3), x: (-3, 3), y: (-1, 6), size: (8, 5),
  nom: $a = 1 / 2$, nom-pos: (2.4, 1.0), couleur: blue,
  autres: (
    (f: x => x * x, domain: (-2.4, 2.4), nom: $a = 1$, nom-pos: (1.8, 4.2), couleur: red),
    (f: x => 2 * x * x, domain: (-1.7, 1.7), nom: $a = 2$, nom-pos: (1.2, 5.4), couleur: green),
  ),
  grille: false, origine: $O$,
)
```)

== الجيب وجيب التمام معًا
#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (-calc.pi, 2 * calc.pi), x: (-calc.pi, 2 * calc.pi), y: (-1.5, 1.5),
  echelle: (0.9, 2.2), xnum: "pi", xpi: 2,
  grille: "toutes", grille-trait: "pointille", grille-couleur: gray,
  nom: $sin x$, nom-t: 0.62, nom-dy: 0.3,
  autres: ((f: x => calc.cos(x), domain: (-calc.pi, 2 * calc.pi), trait: "tirets",
    nom: $cos x$, couleur: red, nom-t: 0.45, nom-dy: 0.3),),
  origine: $O$,
)
```)

== دالة الظل ومقارباتها العمودية
#demo(```typ
#courbe(
  x => calc.tan(x),
  branches: ((-calc.pi, -calc.pi / 2 - 0.3), (-calc.pi / 2 + 0.3, calc.pi / 2 - 0.3), (calc.pi / 2 + 0.3, calc.pi)),
  x: (-calc.pi, calc.pi), y: (-4, 4), echelle: (1.2, 0.7),
  xnum: "pi", xpi: 2, tick-taille: 9pt,
  va: (calc.pi / 2, -calc.pi / 2),
  nom: $tan x$, nom-pos: (0.9, 3.2), origine: $O$,
)
```)

== مساحة تحت منحنى الجيب
#demo(```typ
#courbe(
  x => calc.sin(x),
  domain: (0, calc.pi), x: (-0.5, 3.8), y: (-0.5, 1.5), size: (8, 4),
  xnum: "pi", xpi: 2,
  aire: (0, calc.pi), aire-nom: $cal(A)$, aire-nom-pos: (calc.pi / 2, 0.4),
  couleur: purple, nom: $sin x$, nom-t: 0.2, nom-dy: 0.3,
)
المساحة = #calc.round(integrale(x => calc.sin(x), 0, calc.pi), digits: 3)
```)

= دليل الدوال المرجعية

هذا الفصل مرجع سريع للدوال الخمس الأكثر استعمالًا في دروس الدوال: الكسرية، والأسية، واللوغاريتمية، والقيمة المطلقة، والجذر التربيعي. لكل عائلة جدول يلخص مجالها ومقارباتها وطريقة رسمها، ثم أمثلة جاهزة تغطي حالاتها المعتادة، وكلها تُحسب فعليًا عند ترجمة هذا الملف، فانسخ المثال الأقرب إلى مسألتك وغيّر الدالة والحدود.

#let guide-table(..rows) = table(
  columns: (auto, 1fr), inset: 6pt, stroke: 0.5pt + luma(180),
  fill: (x, _) => if x == 0 { rgb("#dbe8f7") },
  ..rows,
)

#guide-table(
  [*العائلة*], [*ما تحتاجه من الوسائط*],
  [كسرية], [`branches` و`va` و`ha` ومستقيم مائل في `droites`],
  [أسية], [`domain` واحد و`ha`],
  [لوغاريتمية], [`domain` يبدأ بقيمة موجبة صغيرة و`va`],
  [قيمة مطلقة], [`calc.abs` أو `morceaux`],
  [جذر تربيعي], [`domain` يبدأ عند حد المجال و`calc.max(0, ...)` ونقطة مغلقة عند البداية],
)

== الدوال الكسرية

#guide-table(
  [*الصيغة*], [$f(x) = P(x) / Q(x)$],
  [*المجال*], [كل الأعداد ما عدا جذور المقام],
  [*مقارب عمودي*], [عند كل جذر للمقام لا يلغيه البسط: `va`],
  [*مقارب أفقي*], [إذا كانت درجة البسط ≤ درجة المقام: `ha`],
  [*مقارب مائل*], [إذا كانت درجة البسط = درجة المقام + 1: مستقيم في `droites` بتقطيع],
  [*طريقة الرسم*], [`branches`: مجالات متجاورة تبتعد قليلًا عن كل مقارب عمودي، و`y` يقص الأطراف الطويلة],
)

=== الدالة المقلوب $1/x$
#demo(```typ
#courbe(
  x => 1 / x,
  branches: ((-4, -0.25), (0.25, 4)),
  x: (-4, 4), y: (-4, 4), size: (7, 7),
  va: (0,), ha: (0,),
  nom: $C_f$, nom-t: 0.9, nom-dy: 0.4,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

=== دالة تآلفية كسرية (مقاربان ومركز تناظر)
#demo(```typ
#courbe(
  x => (2 * x + 1) / (x - 1),
  branches: ((-4, 0.6), (1.4, 6)),
  x: (-4, 6), y: (-4, 8), size: (8, 6),
  va: ((v: 1, nom: $x = 1$, nom-dx: 0.1),),
  ha: ((v: 2, nom: $y = 2$, nom-t: 0.05, nom-dy: -0.4),),
  points: ((p: (1, 2), nom: $Omega$),),
  nom: $C_f$, nom-t: 0.5, nom-dy: -0.4, origine: $O$,
)
```)

=== دالة ذات مقارب مائل
#demo(```typ
#courbe(
  x => (x * x - 1) / (x - 2),
  branches: ((-4, 1.6), (2.4, 6)),
  x: (-4, 6), y: (-8, 12), size: (7, 8),
  va: ((v: 2, nom: $x = 2$, nom-dx: 0.1),),
  droites: ((a: 1, b: 2, trait: "tirets", couleur: red,
    nom: $y = x + 2$, nom-t: 0.1, nom-dy: 0.4),),
  nom: $C_f$, nom-t: 0.8, nom-dy: -0.5, origine: $O$,
)
```)

=== دالة ذات مقاربين عموديين
#demo(```typ
#courbe(
  x => 1 / (x * x - 1),
  branches: ((-3, -1.15), (-0.85, 0.85), (1.15, 3)),
  x: (-3, 3), y: (-4, 4), size: (7, 6),
  va: (1, -1), ha: (0,),
  nom: $C_f$, nom-pos: (2.4, 0.7), origine: $O$,
)
```)

== الدالة الأسية

#guide-table(
  [*الصيغة*], [$f(x) = a^x$ مع $a > 0$ و $a != 1$، أو $e^x$],
  [*المجال والمدى*], [مجالها $RR$ ومدى قيمها $]0, +oo[$],
  [*مقارب*], [المستقيم $y = 0$ (عند $-oo$ إن كان $a > 1$ وعند $+oo$ إن كان $0 < a < 1$): `ha`],
  [*نقطة ثابتة*], [كل المنحنيات تمر بالنقطة $(0, 1)$],
  [*طريقة الرسم*], [مجال واحد، ولا حاجة إلى `branches`. استعمل `calc.exp(x)` أو `calc.pow(a, x)` مع عدد عشري],
)

=== الدالة $e^x$ مع مقاربها ومماسها
#demo(```typ
#courbe(
  x => calc.exp(x),
  domain: (-3, 2), x: (-3, 3), y: (-1, 8), size: (7, 6),
  ha: ((v: 0, nom: $y = 0$, nom-t: 0.8, nom-dy: -0.4),),
  tangente: (a: 0, nom: $T$, nom-t: 0.75),
  points: ((v: 0, nom: $A$, proj: true),),
  nom: $e^x$, nom-t: 0.9, nom-dx: -0.5,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

=== الأساس يغيّر الاتجاه: $a > 1$ و $0 < a < 1$
#demo(```typ
#courbe(
  x => calc.pow(2.0, x),
  domain: (-3, 3), x: (-3, 3), y: (-1, 6), size: (7, 6),
  ha: (0,),
  nom: $2^x$, nom-pos: (2, 5.3), couleur: blue,
  autres: ((f: x => calc.pow(0.5, x), nom: $(1/2)^x$, nom-pos: (-2, 5.3), couleur: red),),
  points: ((p: (0, 1), nom: $A$, nom-ancre: "south-west"),),
  origine: $O$,
)
```)

=== انسحاب: $e^(x-1) + 1$
#demo(```typ
#courbe(
  x => calc.exp(x - 1) + 1,
  domain: (-3, 2.5), x: (-3, 3), y: (-1, 6), size: (7, 6),
  ha: ((v: 1, nom: $y = 1$, nom-t: 0.1, nom-dy: 0.35),),
  points: ((v: 1, nom: $A$, proj: true),),
  autres: ((f: x => calc.exp(x), domain: (-3, 1.8), trait: "tirets",
    couleur: gray, nom: $e^x$, nom-t: 0.85, nom-dx: -0.4),),
  nom: $C_f$, nom-t: 0.9, nom-dx: 0.3, nom-dy: -0.3,
)
```)

== الدالة اللوغاريتمية

#guide-table(
  [*الصيغة*], [$f(x) = ln x$ أو $log_a x = (ln x) / (ln a)$],
  [*المجال*], [$]0, +oo[$ ، فتبدأ المجال بقيمة موجبة صغيرة مثل `0.04`],
  [*مقارب*], [المستقيم $x = 0$: `va`],
  [*نقطة ثابتة*], [كل المنحنيات تمر بالنقطة $(1, 0)$],
  [*الصيغ في Typst*], [`calc.ln(x)` للطبيعي، و`calc.log(x)` للعشري، و`calc.log(x, base: 2)` لأي أساس],
  [*علاقتها بالأسية*], [$ln$ و $exp$ متناظرتان بالنسبة إلى $y = x$],
)

=== الدالة $ln x$ مع مقاربها ومماسها
#demo(```typ
#courbe(
  x => calc.ln(x),
  domain: (0.04, 8), x: (-1, 8), y: (-3, 3), size: (8, 6),
  va: ((v: 0, nom: $x = 0$, nom-t: 0.9, nom-dx: 0.1),),
  tangente: (a: 1, nom: $T$, nom-t: 0.35),
  points: ((v: 1, nom: $A$, nom-ancre: "north"),),
  nom: $ln x$, nom-t: 0.9, nom-dy: -0.4,
  xlabel: $x$, ylabel: $y$, origine: $O$,
)
```)

=== أسس مختلفة: $log_2$ و $ln$ و $log_(10)$
#demo(```typ
#courbe(
  x => calc.log(x, base: 2),
  domain: (0.05, 8), x: (-1, 8), y: (-3, 3), size: (8, 6),
  va: (0,),
  nom: $log_2 x$, nom-t: 0.75, nom-dy: 0.3, couleur: blue,
  autres: (
    (f: x => calc.ln(x), domain: (0.05, 8), couleur: red,
      nom: $ln x$, nom-t: 0.75, nom-dy: 0.3),
    (f: x => calc.log(x), domain: (0.05, 8), couleur: green,
      nom: $log x$, nom-t: 0.75, nom-dy: 0.3),
  ),
  points: ((p: (1, 0), nom: $A$, nom-ancre: "north-west"),),
)
```)

=== انسحاب: $ln(x - 1) + 2$
#demo(```typ
#courbe(
  x => calc.ln(x - 1) + 2,
  domain: (1.05, 8), x: (-1, 8), y: (-2, 5), size: (8, 6),
  va: ((v: 1, nom: $x = 1$, nom-dx: 0.1),),
  points: ((p: (2, 2), nom: $A$, proj: true),),
  nom: $C_f$, nom-t: 0.8, nom-dy: -0.4, origine: $O$,
)
```)

=== فرعان: $ln |x|$
#demo(```typ
#courbe(
  x => calc.ln(calc.abs(x)),
  branches: ((-6, -0.04), (0.04, 6)),
  x: (-6, 6), y: (-3, 3), size: (8, 5),
  va: (0,),
  nom: $ln |x|$, nom-t: 0.8, nom-dy: -0.4, origine: $O$,
)
```)

== دالة القيمة المطلقة

#guide-table(
  [*الصيغة*], [$f(x) = |u(x)|$ وتساوي $u(x)$ حيث $u >= 0$ و $-u(x)$ حيث $u < 0$],
  [*المجال*], [نفس مجال $u$],
  [*طريقة الرسم*], [`calc.abs(...)` مباشرة، وتظهر الزاوية عند أصفار $u$],
  [*قطع متفرقة*], [يمكن كتابتها بـ `morceaux` لتسمية كل قطعة],
  [*الرأس*], [نقطة حرة `(p: (a, b), nom: $S$, proj: true)`],
)

=== الدالة $|x|$
#demo(```typ
#courbe(
  x => calc.abs(x),
  domain: (-4, 4), x: (-4, 4), y: (-1, 5), size: (7, 5),
  nom: $|x|$, nom-t: 0.9, nom-dy: -0.4,
  points: ((p: (0, 0), nom: $O$, nom-ancre: "north-east"),),
  xlabel: $x$, ylabel: $y$,
)
```)

=== الصيغة $|a x + b| + c$ ورأسها
#demo(```typ
#courbe(
  x => calc.abs(2 * x - 3) - 1,
  domain: (-1, 4), x: (-1, 4), y: (-2, 6), size: (7, 6),
  points: ((p: (1.5, -1), nom: $S$, nom-ancre: "north", proj: true),),
  nom: $C_f$, nom-t: 0.9, nom-dy: -0.4, origine: $O$,
)
```)

=== المنحنى $|f|$ مقابل $f$
#demo(```typ
#courbe(
  x => calc.abs(x * x - 1),
  domain: (-3, 3), x: (-3, 3), y: (-2, 5), size: (7, 6),
  nom: $|f|$, nom-t: 0.9, nom-dx: -0.6,
  autres: ((f: x => x * x - 1, trait: "tirets", couleur: gray,
    nom: $C_f$, nom-pos: (0.5, -1.4)),),
  origine: $O$,
)
```)

=== مجموع قيمتين مطلقتين: $|x| + |x - 2|$
#demo(```typ
#courbe(
  x => calc.abs(x) + calc.abs(x - 2),
  domain: (-3, 5), x: (-3, 5), y: (-1, 9), size: (7, 6),
  nom: $C_f$, nom-t: 0.9, nom-dy: -0.5, origine: $O$,
)
```)

=== كتابتها على شكل قطع: $|x - 1|$
#demo(```typ
#courbe(
  none, x: (-3, 4), y: (-1, 4), size: (7, 5),
  morceaux: (
    (f: x => 1 - x, domain: (-3, 1), nom: $1 - x$, nom-t: 0.3, nom-dy: 0.3),
    (f: x => x - 1, domain: (1, 4), nom: $x - 1$, nom-t: 0.7, nom-dy: -0.4),
  ),
  points: ((p: (1, 0), nom: $S$, nom-ancre: "north"),),
)
```)

== دالة الجذر التربيعي

#guide-table(
  [*الصيغة*], [$f(x) = sqrt(u(x))$],
  [*المجال*], [حيث $u(x) >= 0$ فقط: ابدأ `domain` عند حد المجال تمامًا],
  [*تفادي الخطأ*], [اكتب `calc.sqrt(calc.max(0, u))` كي لا تُنتج الأخطاء العددية الصغيرة جذرًا لعدد سالب عند الأطراف],
  [*نقطة البداية*], [نقطة حرة مغلقة عند أول المجال `(p: (a, 0))`],
  [*فروع*], [إذا كان المجال من قطعتين (مثل $x^2 - 1 >= 0$) استعمل `branches`],
)

=== انسحابات الجذر: $sqrt(x)$ و $sqrt(x + 2)$ و $sqrt(x - 1)$
#demo(```typ
#courbe(
  x => calc.sqrt(x),
  domain: (0, 8), x: (-3, 8), y: (-1, 4), size: (8, 5),
  nom: $sqrt(x)$, nom-t: 0.1, nom-dy: -0.4, couleur: blue,
  autres: (
    (f: x => calc.sqrt(calc.max(0, x + 2)), domain: (-2, 8), couleur: red,
      nom: $sqrt(x + 2)$, nom-t: 0.35, nom-dy: 0.35),
    (f: x => calc.sqrt(calc.max(0, x - 1)), domain: (1, 8), couleur: green,
      nom: $sqrt(x - 1)$, nom-t: 0.7, nom-dy: -0.4),
  ),
  points: ((p: (0, 0)), (p: (-2, 0)), (p: (1, 0))),
)
```)

=== الجذر وانعكاسه: $sqrt(x)$ و $-sqrt(x)$
#demo(```typ
#courbe(
  x => calc.sqrt(x),
  domain: (0, 6), x: (-1, 6), y: (-3, 3), size: (7, 6),
  nom: $sqrt(x)$, nom-t: 0.8, nom-dy: 0.35,
  autres: ((f: x => -calc.sqrt(x), domain: (0, 6),
    nom: $-sqrt(x)$, nom-t: 0.8, nom-dy: -0.4),),
  origine: $O$,
)
```)

=== نصف دائرة: $sqrt(4 - x^2)$
#demo(```typ
#courbe(
  x => calc.sqrt(calc.max(0, 4 - x * x)),
  domain: (-2, 2), x: (-3, 3), y: (-1, 3), size: (6, 4),
  points: ((p: (-2, 0), nom: $A$, nom-ancre: "north"), (p: (2, 0), nom: $B$, nom-ancre: "north")),
  nom: $sqrt(4 - x^2)$, nom-pos: (0, 1), origine: $O$,
)
```)

=== فرعان: $sqrt(x^2 - 1)$ مع مقاربيه المائلين
#demo(```typ
#courbe(
  x => calc.sqrt(calc.max(0, x * x - 1)),
  branches: ((-4, -1), (1, 4)),
  x: (-4, 4), y: (-1, 5), size: (8, 5),
  droites: (
    (a: 1, b: 0, trait: "tirets", couleur: gray),
    (a: -1, b: 0, trait: "tirets", couleur: gray),
  ),
  points: ((p: (-1, 0), nom: $A$, nom-ancre: "north"), (p: (1, 0), nom: $B$, nom-ancre: "north")),
  nom: $sqrt(x^2 - 1)$, nom-t: 0.7, nom-dy: -0.45,
)
```)

= الدالة `integrale`
```typ
integrale(f, a, b, g: none, n: 2000, absolu: true)
```
تحسب $display(integral_a^b |f(t) - g(t)| dif t)$ بطريقة سيمبسون. بدون `g` يكون الحيز بين المنحنى ومحور الفواصل. وبـ `absolu: false` نحصل على التكامل بالإشارة.

#note("ملاحظة", color: rgb("#27ae60"))[
  المساحة بين منحنيين هي تكامل $|f - g|$، فاختر حدّي الحيز عند فاصلتي التقاطع أو حيث لا يتبدل ترتيب المنحنيين.
]

= أخطاء شائعة

#table(columns: (1fr, 1.4fr), inset: 7pt, stroke: 0.5pt + luma(180),
  fill: (_, y) => if y == 0 { rgb("#fbe3e0") },
  table.header([*المشكلة*], [*الحل*]),
  [اسم لا يظهر], [موضعه خارج الإطار `x` و`y`؛ غيّر `nom-pos`.],
  [اسم يغطي المنحنى], [غيّر `nom-pos` أو `nom-t` أو `nom-dy`، أو فعّل `fond-noms: true`.],
  [خط مزيّف بين فرعين], [استعمل `branches` وابتعد عن المقارب.],
  [`trait: "points"` قليل النقاط], [زد `npts`.],
  [دالة ثابتة مثل `x => 2` تعطي خطأ], [اكتبها `x => 2.0`.],
  [الأرقام مقلوبة], [ضع `#set text(dir: ltr)`.],
  [مساحة غير متوقعة], [تأكد أن حدّي `aire` بين فاصلتي التقاطع.],
  [الشبكة الثانوية لا تظهر], [استعمل `grille: "secondaire"` أو `"toutes"`، وتأكد أن `xminor` أو `yminor` أصغر من الخطوة الرئيسية.],
  [خطوط السنتيمتر لا تنطبق على التدريجات], [اجعل `xunite` و`yunite` أعدادًا صحيحة (سنتيمتر لكل وحدة)، أو اترك `milli-ancre: "origine"` (الافتراضي).],
  [الورقة المليمترية كثيفة جدًا عند الطباعة], [استعمل `milli-fin: false` لحذف خطوط 1 مم، أو `grille-epaisseur` أرق.],
  [خطأ `x must be (min, max)`], [حدّا `x` و`y` يجب أن يكونا `(الأصغر, الأكبر)`.],
  [ترقيم $pi$ غير مضبوط], [اجعل حدود `x` مضاعفات للخطوة $pi/"xpi"$، مثل `(-2 * calc.pi, 2 * calc.pi)`.],
)
