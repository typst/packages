#import "../lib.typ": *
#import "helpers.typ": *

#set page(
  paper: "a4",
  margin: (x: 1.7cm, y: 1.85cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8.5pt, fill: luma(110), font: "DejaVu Sans")
      grid(columns: (1fr, 1fr),
        align(right)[أدوات الرسم الهندسي],
        [geomtools — دليل المستعمل],
      )
      v(-0.35em)
      line(length: 100%, stroke: 0.4pt + luma(200))
    }
  },
)
#set text(size: 10.4pt, font: "Estedad", lang: "ar", dir: rtl, fill: ink)
#set par(justify: true, leading: 0.78em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(above: 0.4em, below: 0.75em, {
    text(size: 16pt, weight: "bold", fill: blue, it)
    v(-0.5em)
    line(length: 100%, stroke: 0.9pt + blue)
  })
}
#show heading.where(level: 2): it => block(above: 1.15em, below: 0.5em,
  text(size: 12pt, weight: "bold", fill: rgb("#1C3D5A"), it))
#show heading.where(level: 3): it => block(above: 0.9em, below: 0.4em,
  text(size: 10.6pt, weight: "bold", it))
#show raw: set text(font: "DejaVu Sans Mono", size: 7.7pt, dir: ltr, lang: "en")
#show raw.where(block: true): it => block(
  width: 100%, fill: luma(248), stroke: 0.4pt + luma(220),
  inset: 7pt, radius: 3pt, above: 0.45em, below: 0.55em,
  align(left, it),
)
#show math.equation: set text(dir: ltr, font: "DejaVu Sans")
#show strong: set text(fill: rgb("#16324F"))

#let cap(t) = align(center, text(size: 8.2pt, fill: luma(90), t))
#let note(title, body) = block(
  width: 100%, fill: rgb("#E7F5FF"), stroke: 0.7pt + blue,
  inset: 9pt, radius: 4pt, above: 0.6em, below: 0.6em,
  {
    text(weight: "bold", fill: blue, size: 9pt, title)
    v(0.2em)
    body
  },
)
#let warn(title, body) = block(
  width: 100%, fill: rgb("#FFF4E6"), stroke: 0.7pt + orange,
  inset: 9pt, radius: 4pt, above: 0.55em, below: 0.55em,
  {
    text(weight: "bold", fill: orange, size: 9pt, title)
    v(0.2em)
    body
  },
)

#let A = A0
#let B = B0
#let C = C0
#let O = circumcenter(A, B, C)
#let I = incenter(A, B, C)
#let G = centroid(A, B, C)
#let H = orthocenter(A, B, C)
#let R = dist(O, A)
#let r-in = I.at(1)
#let Ma = midp(B, C)
#let Mb = midp(A, C)
#let Mc = midp(A, B)
#let Ha = foot(A, B, C)
#let Hb = foot(B, A, C)
#let Hc = foot(C, A, B)
#let Ta = foot(I, B, C)
#let Tb = foot(I, A, C)
#let Tc = foot(I, A, B)

#let rAB = 4.5
#let (Pab, Qab) = circ-inter(A, rAB, B, rAB)
#let P-ab = if Pab.at(1) > Qab.at(1) { Pab } else { Qab }
#let Q-ab = if Pab.at(1) > Qab.at(1) { Qab } else { Pab }

#let rAC = 4.2
#let (Pac, Qac) = circ-inter(A, rAC, C, rAC)
#let toward-b = vsub(B, midp(A, C))
#let P-ac = if dotp(vsub(Pac, midp(A, C)), toward-b) > 0 { Pac } else { Qac }
#let Q-ac = if dotp(vsub(Pac, midp(A, C)), toward-b) > 0 { Qac } else { Pac }

#let r-bis = 2.05
#let P-angA = lerp(A, B, r-bis / dist(A, B))
#let Q-angA = lerp(A, C, r-bis / dist(A, C))
#let r-bis2 = 1.85
#let (Ra1, Ra2) = circ-inter(P-angA, r-bis2, Q-angA, r-bis2)
#let R-A = farther(A, Ra1, Ra2)

#let P-angB = lerp(B, A, r-bis / dist(B, A))
#let Q-angB = lerp(B, C, r-bis / dist(B, C))
#let (Rb1, Rb2) = circ-inter(P-angB, r-bis2, Q-angB, r-bis2)
#let R-B = farther(B, Rb1, Rb2)

#align(center)[
  #v(0.4em)
  #text(size: 11pt, fill: blue)[دليل المستعمل]
  #v(0.15em)
  #text(size: 28pt, weight: "bold", dir: ltr)[geomtools]


  #v(1em) 

  #text(size: 13pt, fill: luma(68))[#emoji.hand.write فرڤوس عبدالحق]

  #v(1em)

  #text(size: 12.5pt, fill: luma(70))[
    رسم أدوات الهندسة على شكل
  ]
  #v(0.15em)
  #text(size: 10pt, fill: luma(100))[
    مسطرة · قلم · كوس · منقلة · مدور
  ]
]

#v(0.55em)

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += line-ext(P-ab, Q-ab, beyond: 0.3, stroke: blue.lighten(45%), weight: 0.55)
  fig += line-ext(P-ac, Q-ac, beyond: 0.3, stroke: blue.lighten(45%), weight: 0.55)
  fig += p-line(A, Ma, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  fig += p-line(B, Mb, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  fig += p-line(C, Mc, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  fig += p-line(A, Ha, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  fig += p-line(B, Hb, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  fig += p-line(C, Hc, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  fig += p-line(A, Ta, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  fig += p-line(B, Tb, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  fig += p-line(C, Tc, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  fig += p-circle(O, R, stroke: blue, weight: 1.35)
  fig += p-circle(I, r-in, stroke: green, weight: 1.25)
  fig += line-ext(O, H, beyond: 0.55, stroke: red, weight: 1.05, dash: none)
  fig += pt(O, fill: blue, r: 0.09)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(G, fill: orange, r: 0.09)
  fig += pt(H, fill: purple, r: 0.09)
  fig += lab(O, text(fill: blue)[$O$], dx: 0.28, dy: -0.28, fill: blue)
  fig += lab(I, text(fill: green)[$I$], dx: -0.30, dy: 0.22, fill: green)
  fig += lab(G, text(fill: orange)[$G$], dx: 0.28, dy: 0.22, fill: orange)
  fig += lab(H, text(fill: purple)[$H$], dx: -0.28, dy: 0.26, fill: purple)
  fig
}, padding: 0.55))
#cap[المثلث $A B C$ المعتمد في الدليل، مراكزه الأربعة، ومستقيم أويلر $(O G H)$.]

#v(0.4em)

#grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt,
  align(center)[
    #text(fill: blue, weight: "bold")[$O$ الدائرة المحيطة]\
    #text(size: 8.2pt, fill: luma(80))[المحاور، بالمدور]
  ],
  align(center)[
    #text(fill: green, weight: "bold")[$I$ الدائرة المُحاطة]\
    #text(size: 8.2pt, fill: luma(80))[المنصفات، بالمدور]
  ],
  align(center)[
    #text(fill: orange, weight: "bold")[$G$ مركز الثقل]\
    #text(size: 8.2pt, fill: luma(80))[المتوسطات، بالمسطرة]
  ],
  align(center)[
    #text(fill: purple, weight: "bold")[$H$ تلاقي الارتفاعات]\
    #text(size: 8.2pt, fill: luma(80))[الارتفاعات، بالكوس]
  ],
)

#v(0.7em)

حزمة Typst المسماة `geomtools` تضع على الشكل #strong[الأدوات الهندسية] :
مسطرة، قلم، كوس، منقلة، مدور — ناعمة كالأصل LaTeX، أو «باليد». يعرض هذا
الدليل الأدوات، ثم يستعملها في #strong[إنشاء] المراكز الأربعة لمثلث، مع
ترميزاتها (شرطات التقايس، الزوايا القائمة، أقواس المنصف).

نقلٌ لـ `OutilsGeomTikZ` لسيدريك بيركي. لا CeTZ : الأدوات قوائم من
المضلعات والأقواس والتسميات.

#outline(indent: 1em, depth: 2)

= الحزمة في دقيقتين

== التثبيت المحلي

الحزمة ليست (بعد) على Universe. تُستورد بمسارها :

```typ
#import "path/to/geomtools/lib.typ": *
```

كل ما تصدّره الحزمة يمرّ عبر `geom` : نمرر له #strong[قائمة بدائيات] — ما
#strong[ترجعه] كل أداة، لا محتوى Typst.

```typ
#geom({
  ruler(length: 10)
  pencil(at: (3, 2), rotate: -20deg)
})
```

داخل كتلة `{ ... }`، Typst #strong[يلصق] الجداول. يمكن أيضا كتابة
`ruler(...) + pencil(...)` بـ `+`، وهو أوضح، وهو ما تفعله كل قوائم هذا
الدليل.

== نمطان، هندسة واحدة

#grid(columns: (1fr, 1fr), column-gutter: 12pt,
  [
    #align(center, geom(ruler(length: 7, width: 1.5), padding: 0.3))
    #cap[`mode: "clean"` — الافتراضي]
  ],
  [
    #align(center, geom(ruler(length: 7, width: 1.5), mode: "rough", padding: 0.3))
    #cap[`mode: "rough"`]
  ],
)

```typ
#geom(ruler(length: 7))
#geom(ruler(length: 7), mode: "rough", roughness: 2, seed: 4)
#geom-rough(ruler(length: 7))
```

الارتعاش #strong[حتمي] : نفس `seed`، نفس الشكل في كل ترجمة. الأرقام لا تُلوى —
«3» مرسوم باليد خطّ آخر، لا 3 مرتجف.

== ما نركّبه

#set table(align: right)
| الدالة | دورها في إنشاء |
|---|---|
| `compass(from, to)` | السنّ في `from`، الساس في `to` — الفتحة مضبوطة |
| `set-square` | كوس 30-60-90، الزاوية القائمة في الأصل |
| `ruler` | الصفر في الأصل، نحو اليمين |
| `right-angle` | #strong[ترميز] الزاوية القائمة (مربع مفتوح، ليس الكوس) |
| `pencil` | قلم، رأسه في الأصل نحو الأعلى |
| `p-line` `p-arc` `p-circle` `p-label` | خط الشكل نفسه |

وسائط مشتركة : `at`، `rotate`، `scale`، `colour`، `fill`. مفاتيح الفرنسية
في الأصل (`Longueur`، `Origine`…) صارت إنجليزية (`length`، `at`…).

#note[اصطلاح الكتب المدرسية][
  #strong[الخط المتصل هو الشكل، والخط المتقطع أثر الأداة] — ما يُمحى بعد ذلك.
  كل بدائية تقبل `dash: "dashed"`. قوس إنشاء يُرسم إذن :

  ```typ
  p-arc(A, 4.5, 20deg, 160deg, stroke: luma(120), dash: "dashed")
  ```
]

= اللوحة وعلبة الأدوات

الإحداثيات بال#strong[سنتيمتر]، $y$ نحو #strong[الأعلى] (توجيه رياضي). المحرّك يقلب
المحور مرة واحدة.

== مساعدات مصدَّرة سلفا

`vadd` `vsub` `vmul` `vnorm` `dist` `vangle` `arc-pts` `circle-pts`
`rect-pts` — إضافة إلى البانين `p-poly` `p-line` `p-circle` `p-arc`
`p-label`.

`vangle((x, y))` زاوية الشعاع، $0 degree$ على $+x$، $90 degree$ على
$+y$. تلك الزاوية التي نمررها إلى `rotate`.

== مساعدات هذا الدليل

`helpers.typ` يضيف ما يحتاجه إنشاء :

- `midp(A, B)`، `unit(v)`، `lerp(A, B, t)`، `foot(P, A, B)`
- `circ-inter(P, r1, Q, r2)` — تقاطعا دائرتين
- `line-inter(P1, P2, Q1, Q2)` — تقاطع مستقيمين
- `circumcenter` `incenter` `centroid` `orthocenter`
- `ticks(P, Q, n: 1)` — ترميز تساوٍ في منتصف $[P Q]$
- `right-angle` (من الحزمة) و `ang-mark` — ترميز الزوايا
- `square-on(at, along, toward)` — يُقعد الكوس على مستقيم، الزاوية
  القائمة نحو نقطة

مثلث العمل، المستعمل في كل مكان :

$ A = (0, 0), quad B = (7.2, 0), quad C = (2.2, 4.8) $

هو #strong[مختلف الأضلاع] و#strong[حاده الزوايا] : المراكز الأربعة متمايزة و#strong[داخلية]،
وأقدام الارتفاعات تسقط على الأضلاع (لا على تمديداتها). $A B$ على محور
$x$، فيسهل القراءة دون أن يصير الشكل خاصا.

```typ
#let A = (0.0, 0.0)
#let B = (7.2, 0.0)
#let C = (2.2, 4.8)
```

= المنقلة، والقلم في طرف الخط

ل#strong[قياس] $angle B A C$، نضع مركز المنقلة في $A$ ونحاذي قاعدتها مع
$(A B)$. الضلع $[A C]$ يقطع التدريج عند قياس الزاوية (هنا
$approx 65 degree$).

عندما #strong[نرسم خطا]، يحسن وضع قلم في طرفه : الساس على الرأس، والجسم
يتبع اتجاه الخط. ذلك عمل `pencil-tip(from, to)` — رأس `pencil` في الأصل
ويتجه نحو الأعلى، ومنه `rotate: vangle(to − from) - 90deg`.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += protractor(at: A, rotate: 0deg, scale: 0.58, radians: false,
    colour: luma(45), value-size: 0.65)
  fig += pencil-tip(A, C, colour: rgb("#2B6CB0"), lead: rgb("#2B6CB0"),
    length: 3.6, scale: 0.78)
  fig
}, padding: 0.4))
#cap[منقلة في $A$، القاعدة على $(A B)$. القلم في طرف $[A C]$.]

```typ
#protractor(at: A, rotate: 0deg, scale: 0.58, radians: false)
#pencil-tip(A, C, colour: rgb("#2B6CB0"), lead: rgb("#2B6CB0"))
```

`scale` يصغّر المنقلة (شعاع الأصل $3.75$ سم) دون تحريك المركز.
`radians: false` يخفي شريط $pi/6$، $pi/4$… إن أردنا الدرجات فقط. لقرص
$0 degree$–$360 degree$ : `full: true`.

= الدائرة المحيطة — بالمدور

#strong[الدائرة المحيطة] هي الدائرة الوحيدة المارة بـ $A$ و $B$ و $C$. مركزها
$O$ تقاطع #strong[المحاور]. يُنشأ المحور بالمدور : قوسان من #strong[نفس الشعاع]، أكبر
من نصف الضلع.

#note[ما نرمّزه][
  - شرطات تساوٍ $A M = M B$ (المنتصف) ؛
  - #strong[زوايا قائمة] في المنتصف : المحور عمودي على الضلع ؛
  - في الأخير، $O A = O B = O C$ (الشعاع)، اختياريا بثلاثة أقواس صغيرة،
    غير أن الدائرة نفسها تكفي غالبا.
]

== الخطوة 1 — المثلث

#align(center, geom(
  abc-figure(A, B, C)
  + ruler(at: (0, -0.62), length: 7.2, width: 0.55, clamp: false,
      values: true, value-size: 0.7, colour: luma(70)),
  padding: 0.4,
))
#cap[نرسم $A B C$ بالمسطرة. صفر المسطرة في $A$.]

```typ
#geom(
  p-line(A, B, stroke: black, weight: 1.35, role: "edge")
  + p-line(B, C, stroke: black, weight: 1.35, role: "edge")
  + p-line(C, A, stroke: black, weight: 1.35, role: "edge")
  + ruler(at: (0, -0.62), length: 7.2, width: 0.55, clamp: false)
  + pencil-tip(A, B)
)
```

`clamp: false` ضروري : افتراضيا يُرفع عرض المسطرة #strong[في صمت] إلى $1.5$
سم، ومسطرة ظننتها رقيقة تبتعد 8 مم.

== الخطوة 2 — مدور في $A$، فتحة أكبر من نصف الضلع

$A B = 7.2$، إذن $A B slash 2 = 3.6$. نأخذ $4.5$ سم. يجب أن يكون القوس
طويلا بما يكفي ليقطع توأمه الصادر من $B$، #strong[من جهتي] $(A B)$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -55deg, 95deg, stroke: muted, dash: "dashed", weight: 0.9)
  fig += compass(A, P-ab, scale: 0.58, leg: 5.2, flip: false,
    pencil-colour: rgb("#C92A2A"))
  fig
}, padding: 0.45))
#cap[`compass(A, P)` — السنّ في $A$، الساس يمر بنقطة من القوس.]

```typ
#let rAB = 4.5
#p-arc(A, rAB, -55deg, 95deg, stroke: luma(120), dash: "dashed")
#compass(A, (4.5 * calc.cos(40deg), 4.5 * calc.sin(40deg)), scale: 0.58)
```

المدور #strong[يفتح حقا] على النقطتين :

$ "half-angle" = arcsin( (|italic("to") - italic("from")|) slash (2 "leg" "scale") ) $

`scale` يصغّر الأداة #strong[دون] تحريك القدمين — لا غنى عنه ليبقى في الشكل.
`flip: true` يقلبه إلى الجهة الأخرى من القطعة، حين يغطي المثلث.

== الخطوة 3 — نفس الفتحة، السنّ في $B$

القوسان يتقاطعان في $P$ و $Q$. #strong[لا تغيّر الفتحة] : ذلك كل ترميز
$A P = B P = A Q = B Q$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -58deg, 100deg, stroke: muted, dash: "dashed", weight: 0.85)
  fig += p-arc(B, rAB, 80deg, 238deg, stroke: muted, dash: "dashed", weight: 0.85)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue)
  fig += lab(P-ab, [$P$], dx: 0.28, dy: 0.18, fill: blue)
  fig += lab(Q-ab, [$Q$], dx: 0.28, dy: -0.28, fill: blue)
  fig += compass(B, P-ab, scale: 0.58, leg: 5.2, flip: true,
    pencil-colour: rgb("#C92A2A"))
  fig
}, padding: 0.45))
#cap[القوس الثاني، #strong[نفس الشعاع]. $P$ و $Q$ على بعد متساو من $A$ ومن $B$.]

التقاطعات تُحسب، لا تُخمَّن :

```typ
#let (P, Q) = circ-inter(A, rAB, B, rAB)
#compass(B, P, scale: 0.58, flip: true)
```

`circ-inter` (في `helpers.typ`) تقاطع دائرتين الكلاسيكي : نسقط على خط
المركزين، ثم نبتعد بـ $h = sqrt(r_1^2 - a^2)$.

== الخطوة 4 — محور $[A B]$

المستقيم $(P Q)$ هو المحور : يقطع $[A B]$ في منتصفه $M$ وهو عمودي عليه.
نرمّز الأمرين.

#align(center, geom({
  let M = Mc
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -50deg, 95deg, stroke: muted, dash: "dashed", weight: 0.7)
  fig += p-arc(B, rAB, 85deg, 230deg, stroke: muted, dash: "dashed", weight: 0.7)
  fig += line-ext(P-ab, Q-ab, beyond: 0.35, stroke: blue, weight: 1.05, dash: none)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue) + pt(M, fill: blue)
  fig += lab(P-ab, [$P$], dx: 0.26, dy: 0.16, fill: blue)
  fig += lab(Q-ab, [$Q$], dx: 0.26, dy: -0.28, fill: blue)
  fig += lab(M, [$M$], dx: 0.22, dy: 0.22, fill: blue)
  fig += ticks(A, M, n: 1) + ticks(M, B, n: 1)
  fig += right-angle(at: M, rotate: 0deg, size: 0.32, colour: blue)
  fig
}, padding: 0.4))
#cap[الترميز : $A M = M B$ (شرطة واحدة) و $angle P M B = 90 degree$ (مربع مفتوح).]

```typ
#let M = midp(A, B)
#line-ext(P, Q, stroke: blue, dash: none)
#ticks(A, M, n: 1) + ticks(M, B, n: 1)
#right-angle(at: M, rotate: 0deg, size: 0.32, colour: blue)
```

#warn[`right-angle` ليس `mini-square`][
  `mini-square` #strong[كوس صغير] : له وتر. إن وُضع في زاوية، يقطع الوتر الركن
  قطريا. ترميز الزاوية القائمة #strong[مربع مفتوح] — ضلعان، الرأس متراجع عن
  الذروة. ذلك `right-angle`.
]

`rotate` في `right-angle` اتجاه الضلع #strong[الأول]. هنا $(A B)$ أفقي، إذن
`rotate: 0deg` والمربع يصعد داخل المثلث. على ضلع زاويته $theta$، نمرر
`rotate: theta`، ثم نضيف $90 degree$ أو نقلب حسب الجهة التي نريد المربع
فيها.

== الخطوة 5 — محور $[A C]$

نفس الحركة : #strong[قوسان من نفس الشعاع] يتقاطعان في #strong[نقطتين] $P'$ و $Q'$.
الشعاع $4.2$ سم يتجاوز $A C slash 2 approx 2.64$. تقاطع المحورين هو $O$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += arc-through(A, P-ab, Q-ab, extra: 22deg, stroke: muted, weight: 0.6)
  fig += arc-through(B, P-ab, Q-ab, extra: 22deg, stroke: muted, weight: 0.6)
  fig += arc-through(A, P-ac, Q-ac, extra: 28deg, stroke: green, weight: 0.85)
  fig += arc-through(C, P-ac, Q-ac, extra: 28deg, stroke: green, weight: 0.85)
  fig += line-ext(P-ab, Q-ab, beyond: 0.2, stroke: blue, weight: 1.0, dash: none)
  fig += line-ext(P-ac, Q-ac, beyond: 0.45, stroke: green, weight: 1.05, dash: none)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += right-angle(at: Mc, rotate: 0deg, size: 0.28, colour: blue)
  fig += ra-in(Mb, vsub(C, A), vsub(B, Mb), size: 0.28, colour: green)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue)
  fig += pt(P-ac, fill: green) + pt(Q-ac, fill: green)
  fig += lab(P-ac, [$P'$], dx: 0.36, dy: -0.22, fill: green, size: 9pt)
  fig += lab(Q-ac, [$Q'$], dx: -0.42, dy: 0.18, fill: green, size: 9pt)
  fig += pt(O, fill: red, r: 0.09)
  fig += lab(O, text(fill: red)[$O$], dx: 0.28, dy: -0.26, fill: red)
  fig += pt(Mc, fill: blue) + pt(Mb, fill: green)
  fig
}, padding: 0.4))
#cap[كل محور : #strong[قوسان]، #strong[نقطتا] تقاطع. $(P' Q')$ يقطع $(P Q)$ في $O$.]

```typ
#let rAC = 4.2
#let (P2, Q2) = circ-inter(A, rAC, C, rAC)
#arc-through(A, P2, Q2) + arc-through(C, P2, Q2)
#let O = line-inter(P, Q, P2, Q2)   // أو circumcenter(A, B, C)
```

نرمّز $[A C]$ ب#strong[شرطتين]، كي لا يختلط بـ $[A B]$ (شرطة واحدة). الزاوية
القائمة في $M_(A C)$ تُوجَّه نحو الداخل بـ `ra-in`.

== الخطوة 6 — مدور في $O$، فتحة $O A$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += line-ext(P-ab, Q-ab, beyond: 0.15, stroke: blue.lighten(35%), weight: 0.7, dash: none)
  fig += line-ext(P-ac, Q-ac, beyond: 0.4, stroke: blue.lighten(35%), weight: 0.7, dash: none)
  fig += p-circle(O, R, stroke: blue, weight: 1.4)
  fig += p-line(O, A, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += p-line(O, B, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += p-line(O, C, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += waves(O, A, n: 2, stroke: blue)
  fig += waves(O, B, n: 2, stroke: blue)
  fig += waves(O, C, n: 2, stroke: blue)
  fig += pt(O, fill: blue, r: 0.09)
  fig += lab(O, text(fill: blue)[$O$], dx: 0.32, dy: 0.08, fill: blue)
  fig += compass(O, lerp(O, C, 1.0), scale: 0.52, leg: 5.4, flip: false,
    pencil-colour: rgb("#1864AB"), pencil-lead: rgb("#1864AB"))
  fig
}, padding: 0.5))
#cap[موجتان متماثلتان على $[O A]$ و $[O B]$ و $[O C]$ : $O A = O B = O C$.]

```typ
#let O = circumcenter(A, B, C)
#let R = dist(O, A)
#p-circle(O, R, stroke: rgb("#1864AB"), weight: 1.4)
#waves(O, A, n: 2) + waves(O, B, n: 2) + waves(O, C, n: 2)
#compass(O, C, scale: 0.52, pencil-colour: rgb("#1864AB"),
         pencil-lead: rgb("#1864AB"))
```

بدون `pencil-lead`، يبقى ساس قلم المدور #strong[أسود] — قلم رصاص ملتصق على
جسم أزرق. في قلم ملون، الساس يوافق الجسم.

#note[لماذا يقع $O$ على المحاور الثلاثة][
  بالإنشاء $P$ و $Q$ على بعد متساو من $A$ و $B$، فكل نقطة من $(P Q)$ كذلك
  — وخصوصا $O$. وكذلك $O A = O C$. ومنه $O A = O B = O C$ : دائرة المركز
  $O$ المارة بـ $A$ تمر بـ $B$ و $C$.
]

= الدائرة المماسّة — بالمدور

#strong[الدائرة المماسّة] مماسة للأضلاع الثلاثة. مركزها $I$ تقاطع #strong[المنصفات].
يُنشأ المنصف بالمدور على مرحلتين : قوس مركزه الرأس، ثم قوسان متساويان
مركزاهما نقطتا القطع.

#note[ما نرمّزه][
  - #strong[أقواس متساوية] في نصفي الزاوية (المنصف) ؛
  - في نقاط التماس، #strong[زاوية قائمة] بين الشعاع والضلع (الشعاع عمودي على
    المماس) ؛
  - $I T_a = I T_b = I T_c$ (الشعاع)، يحمله الدائرة نفسها.
]

== الخطوة 1 — قوس مركزه $A$، يقطع $[A B]$ و $[A C]$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, r-bis, -8deg, 80deg, stroke: muted, dash: "dashed", weight: 0.9)
  fig += pt(P-angA, fill: green) + pt(Q-angA, fill: green)
  fig += lab(P-angA, [$P$], dx: 0.08, dy: -0.32, fill: green)
  fig += lab(Q-angA, [$Q$], dx: -0.34, dy: 0.10, fill: green)
  fig += compass(A, P-angA, scale: 0.55, leg: 5.0, flip: false,
    pencil-colour: rgb("#2F9E44"))
  fig
}, padding: 0.45))
#cap[السنّ في $A$. القوس يقطع ضلعي الزاوية — #strong[لا] الثالث.]

```typ
#let r = 2.05
#let P = lerp(A, B, r / dist(A, B))
#let Q = lerp(A, C, r / dist(A, C))
#p-arc(A, r, -8deg, 80deg, stroke: luma(120), dash: "dashed")
#compass(A, P, scale: 0.55)
```

== الخطوة 2 — مدور في $P$ وفي $Q$، نفس الفتحة

القوسان يتقاطعان في $R$ #strong[داخل] الزاوية، نحو اليمين. آخر قوس هو ذو المركز
$Q$ : نضع السنّ في $Q$ ويتوقف الساس في $R$، لا نحو $A$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, r-bis, -6deg, 78deg, stroke: muted, dash: "dashed", weight: 0.65)
  fig += arc-to(P-angA, R-A, back: 48deg, extra: 16deg, stroke: muted, weight: 0.8)
  fig += arc-to(Q-angA, R-A, back: 72deg, extra: 0deg, stroke: green, weight: 0.95)
  fig += pt(P-angA, fill: green) + pt(Q-angA, fill: green) + pt(R-A, fill: green)
  fig += lab(P-angA, [$P$], dx: 0.10, dy: -0.32, fill: green)
  fig += lab(Q-angA, [$Q$], dx: -0.34, dy: 0.14, fill: green)
  fig += lab(R-A, [$R$], dx: 0.28, dy: 0.18, fill: green)
  fig += ray(A, R-A, extra: 2.2, stroke: green, weight: 1.1, dash: none)
  fig += ang-mark(A, B, R-A, r: 0.72, stroke: green)
  fig += ang-mark(A, R-A, C, r: 0.72, stroke: green)
  fig += compass(Q-angA, R-A, scale: 0.48, leg: 4.6, flip: false,
    pencil-colour: rgb("#2F9E44"))
  fig
}, padding: 0.4))
#cap[السنّ في $Q$، الساس في $R$ : القلم في #strong[طرف] القوس، نحو اليمين.]

```typ
#let R = farther(A, R1, R2)
#arc-to(Q, R, back: 72deg, extra: 0deg)
#compass(Q, R, scale: 0.48)
```

لماذا ينجح : $A P = A Q$ (نفس القوس)، $P R = Q R$ (نفس الفتحة)، $A R$
مشترك، إذن $triangle A P R = triangle A Q R$ (ضضض) والزاويتان في $A$
متساويتان.

== الخطوة 3 — منصف $angle A B C$، ثم $I$

منصف ثان يكفي : الثالث يمر بـ $I$. ل#strong[كل] زاوية نترك #strong[ثلاثة] أقواس إنشاء :
قوس الرأس، ثم القوسان المتساويان المتقاطعان في $R$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += bisector-three-arcs(A, P-angA, Q-angA, R-A, r-bis, r-bis2, stroke: muted)
  fig += bisector-three-arcs(B, P-angB, Q-angB, R-B, r-bis, r-bis2, stroke: muted)
  fig += ray(A, R-A, extra: 2.6, stroke: green, weight: 1.05, dash: none)
  fig += ray(B, R-B, extra: 2.2, stroke: green, weight: 1.05, dash: none)
  fig += ang-mark(A, B, R-A, r: 0.62, stroke: green)
  fig += ang-mark(A, R-A, C, r: 0.62, stroke: green)
  fig += ang-mark(B, A, R-B, r: 0.62, stroke: green)
  fig += ang-mark(B, R-B, C, r: 0.62, stroke: green)
  fig += pt(R-A, fill: green) + pt(R-B, fill: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.20, fill: green)
  fig
}, padding: 0.4))
#cap[ثلاثة أقواس في $A$، ثلاثة في $B$. $I$ تقاطعهما.]

```typ
#let I = line-inter(A, R-A, B, R-B)   // أو incenter(A, B, C)
```

== الخطوة 4 — إسقاط $I$ على ضلع، بالكوس

ن#strong[بقي] الأقواس الستة للمنصفين. للشعاع، لا نرسم قوسا في الرأس $C$ : ننزل
العمود من $I$ على ضلع #strong[بالكوس]. القدم $T$ نقطة التماس ؛ $I T$ ستكون فتحة
المدور.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += bisector-three-arcs(A, P-angA, Q-angA, R-A, r-bis, r-bis2, stroke: luma(170))
  fig += bisector-three-arcs(B, P-angB, Q-angB, R-B, r-bis, r-bis2, stroke: luma(170))
  fig += ray(A, R-A, extra: 2.4, stroke: green.lighten(20%), weight: 0.8, dash: none)
  fig += ray(B, R-B, extra: 2.0, stroke: green.lighten(20%), weight: 0.8, dash: none)
  fig += p-line(I, Tc, stroke: green, weight: 1.15, role: "edge")
  fig += ra-in(Tc, vsub(B, A), vsub(I, Tc), size: 0.30, colour: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(Tc, fill: green)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.22, fill: green)
  fig += lab(Tc, [$T$], dx: 0.22, dy: -0.32, fill: green)
  fig += square-on(Tc, vsub(B, A), vsub(I, Tc),
    length: dist(I, Tc) + 1.15, colour: luma(65))
  fig
}, padding: 0.4))
#cap[الأقواس 3+3 تبقى. الكوس على $(A B)$ يسقط $I$ في $T$ : $(I T) perp (A B)$.]

```typ
#let T = foot(I, A, B)
#square-on(T, vsub(B, A), vsub(I, T), length: dist(I, T) + 1.15)
#ra-in(T, vsub(B, A), vsub(I, T), colour: rgb("#2F9E44"))
```

== الخطوة 5 — الدائرة، والتماسات الثلاثة

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-circle(I, r-in, stroke: green, weight: 1.4)
  fig += p-line(I, Ta, stroke: green, weight: 0.85, role: "edge")
  fig += p-line(I, Tb, stroke: green, weight: 0.85, role: "edge")
  fig += p-line(I, Tc, stroke: green, weight: 0.85, role: "edge")
  fig += ra-in(Ta, vsub(C, B), vsub(I, Ta), size: 0.26, colour: green)
  fig += ra-in(Tb, vsub(C, A), vsub(I, Tb), size: 0.26, colour: green)
  fig += ra-in(Tc, vsub(B, A), vsub(I, Tc), size: 0.26, colour: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(Ta, fill: green) + pt(Tb, fill: green) + pt(Tc, fill: green)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.22, fill: green)
  fig += lab(Ta, [$T_a$], dx: 0.34, dy: 0.10, fill: green, size: 9pt)
  fig += lab(Tb, [$T_b$], dx: -0.36, dy: 0.10, fill: green, size: 9pt)
  fig += lab(Tc, [$T_c$], dx: 0.10, dy: -0.32, fill: green, size: 9pt)
  fig += compass(I, Tc, scale: 0.5, leg: 4.8, flip: false,
    pencil-colour: rgb("#2F9E44"), pencil-lead: rgb("#2F9E44"))
  fig
}, padding: 0.45))
#cap[ثلاثة أشعة، ثلاث زوايا قائمة : الدائرة مماسة للأضلاع الثلاثة.]

```typ
#let I = incenter(A, B, C)
#let T = foot(I, A, B)
#let r = dist(I, T)
#p-circle(I, r, stroke: rgb("#2F9E44"), weight: 1.4)
#ra-in(T, vsub(B, A), vsub(I, T), colour: rgb("#2F9E44"))
#compass(I, T, scale: 0.5, pencil-lead: rgb("#2F9E44"))
```

`ra-in(T, along, toward)` يوجّه المربع #strong[نحو الداخل] : `along` هو الضلع،
`toward` يشير إلى $I$. على $[A C]$، بدون هذا الاختبار، كان المربع خارج
المثلث.

= مركز الثقل — المتوسطات، بالمسطرة

#strong[مركز الثقل] $G$ (مركز ثقل الرؤوس الثلاثة) تقاطع #strong[المتوسطات]. المتوسط
يربط رأسا ب#strong[منتصف] الضلع المقابل. نجد المناصف بالمسطرة، ثم نرسم
المتوسطات الثلاثة. لا دور للكوس هنا : المتوسط ليس عمودا.

#note[ما نرمّزه][
  - على كل ضلع، #strong[نفس عدد الشرط] على جانبي المنتصف : شرطة على $[A B]$،
    اثنتان على $[A C]$، ثلاث على $[B C]$ ؛
  - لا نرمّز $A G = 2 thin G M$ كحركة إنشاء (التقسيم $2:1$ مبرهنة). يمكن
    كتابته بجانب الشكل بعد إيجاد $G$.
]

== الخطوة 1 — منتصف $[A B]$ بالمسطرة

$A B = 7.2$ سم، المنتصف $M_c$ عند $3.6$ سم. نضع المسطرة على الضلع، الصفر
في $A$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += ruler(at: (0, -0.58), length: 7.2, width: 0.62, clamp: false,
    values: true, value-size: 0.72, colour: luma(60))
  fig += pt(Mc, fill: orange, r: 0.085)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.32, fill: orange)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += p-line(Mc, (Mc.at(0), Mc.at(1) + 0.22), stroke: orange, weight: 1.0)
  fig
}, padding: 0.35))
#cap[الـ $3.6$ على المسطرة يسقط على المنتصف. شرطة على كل نصف ترمّز $A M_c = M_c B$.]

```typ
#let Mc = midp(A, B)
#ruler(at: A, rotate: 0deg, length: dist(A, B),
       width: 0.62, clamp: false)
#ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
```

على ضلع أيّا كان، #strong[نحاذي] المسطرة :

```typ
#ruler(
  at: A,
  rotate: vangle(vsub(C, A)),
  length: dist(A, C),
  width: 0.62, clamp: false,
)
```

#warn[أرضية `ruler`][
  `width` يُرفع افتراضيا إلى $1.5$ سم، و `length` إلى $3$. مسطرة تحت ضلع
  7 سم، إن كان عرضها 1.5 سم، تغطي نصف المثلث. `clamp: false` يرفع
  الأرضيتين (الحد الأدنى للعرض بعدها $0.05$).
]

== الخطوة 2 — المناصف الثلاثة

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += ticks(B, Ma, n: 3) + ticks(Ma, C, n: 3)
  fig += pt(Ma, fill: orange) + pt(Mb, fill: orange) + pt(Mc, fill: orange)
  fig += lab(Ma, [$M_a$], dx: 0.34, dy: 0.12, fill: orange)
  fig += lab(Mb, [$M_b$], dx: -0.36, dy: 0.10, fill: orange)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.30, fill: orange)
  fig += ruler(
    at: A, rotate: vangle(vsub(C, A)),
    length: dist(A, C), width: 0.55, clamp: false,
    values: false, colour: luma(70),
  )
  fig
}, padding: 0.4))
#cap[ثلاثة مناصف، ثلاثة ترميزات متمايزة. المسطرة على $[A C]$.]

== الخطوة 3 — رسم المتوسطات الثلاثة

نصل كل رأس بمنتصف الضلع المقابل. متوسطان يكفيان ؛ الثالث تحقق : إن أخطأ
$G$، فمنتصف غلط.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(A, Ma, stroke: orange, weight: 1.15, role: "edge")
  fig += p-line(B, Mb, stroke: orange, weight: 1.05, role: "edge")
  fig += p-line(C, Mc, stroke: orange, weight: 1.05, role: "edge")
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += ticks(B, Ma, n: 3) + ticks(Ma, C, n: 3)
  fig += pt(Ma, fill: orange) + pt(Mb, fill: orange) + pt(Mc, fill: orange)
  fig += pt(G, fill: orange, r: 0.1)
  fig += lab(G, text(fill: orange)[$G$], dx: 0.30, dy: 0.22, fill: orange)
  fig += lab(Ma, [$M_a$], dx: 0.34, dy: 0.10, fill: orange)
  fig += lab(Mb, [$M_b$], dx: -0.36, dy: 0.10, fill: orange)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.30, fill: orange)
  fig
}, padding: 0.4))
#cap[المتوسطات الثلاثة تتقاطع في $G$. لا كوس : ليست زاوية قائمة.]

```typ
#p-line(A, Ma, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
#p-line(B, Mb, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
#p-line(C, Mc, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
```

متوسطان يكفيان. الثالث تحقق : إن أخطأ $G$، فمنتصف غلط.

#note[$G$ يقسم كل متوسط بنسبة $2:1$][
  $arrow(A G) = 2 thin arrow(G M_a)$.
  في الشفرة، $G$ مجرد معدل الرؤوس — نفس الواقعة :

  ```typ
  #let G = (
    (A.at(0) + B.at(0) + C.at(0)) / 3,
    (A.at(1) + B.at(1) + C.at(1)) / 3,
  )
  ```
]

= ملتقى الارتفاعات — الارتفاعات، بالكوس

#strong[ملتقى الارتفاعات] $H$ تقاطع #strong[الارتفاعات]. الارتفاع العمود النازل من رأس
على الضلع المقابل. تلك #strong[حركة] الكوس : ضلع على الضلع، والآخر يمر بالرأس.

#note[ما نرمّزه][
  #strong[مربع زاوية قائمة] في كل قدم $H_a$، $H_b$، $H_c$. لا غير : الارتفاعات
  لا تحمل شرطات تساوٍ.
]

== إقعاد الكوس على ضلع

`set-square` زاويته القائمة في الأصل، #strong[القاعدة] (الضلع القصير) على $+x$،
#strong[الضلع الطويل] على $+y$. لإقعاده على مستقيم :

1. `at` : النقطة حيث نريد الزاوية القائمة — عمليا #strong[قدم] الارتفاع، أو أي
   نقطة من الضلع ريثما نبحث عن القدم ؛
2. `rotate` : زاوية الضلع، `vangle(vsub(C, B))` لـ $(B C)$ ؛
3. `flip` : إن اتجه الضلع الطويل بعيدا عن الرأس، نقلب الكوس.

المساعد `square-on(at, along, toward)` يجري هذا الاختبار : `along` شعاع
موجه للضلع، `toward` شعاع نحو الرأس. إن لم يكن $+90 degree$ المحلي في
الجهة الصحيحة، يُفعَّل `flip`.

== الخطوة 1 — الارتفاع الصادر من $C$، كوس على $(A B)$

$(A B)$ أفقي، العمود شاقولي. يجلس الكوس على $A B$، الزاوية القائمة في
القدم $H_c = (2.2, 0)$. يجب أن #strong[يتجاوز] الضلع الطويل $C$ : نأخذ
`length: dist(C, Hc) + 0.55`.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(C, Hc, stroke: purple, weight: 1.15, role: "edge")
  fig += pt(Hc, fill: purple)
  fig += lab(Hc, [$H_c$], dx: -0.40, dy: -0.28, fill: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.32, colour: purple)
  fig += square-on(Hc, vsub(B, A), vsub(C, Hc),
    length: dist(C, Hc) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[ضلع على $(A B)$، والآخر يمر بـ $C$. تُقرأ القدم $H_c$ عند التماس.]

```typ
#let Hc = foot(C, A, B)
#square-on(Hc, vsub(B, A), vsub(C, Hc), length: dist(C, Hc) + 0.55)
#ra-in(Hc, vsub(B, A), vsub(C, Hc), colour: rgb("#7048E8"))
#p-line(C, Hc, stroke: rgb("#7048E8"), weight: 1.15, role: "edge")
```

على الورق، #strong[يزلق] التلميذ الكوس على $(A B)$ حتى يلاقي الضلع الآخر $C$،
#strong[ثم] يرسم. على الشكل نُقعده في موضعه — القدم يحسبها `foot(C, A, B)`،
الإسقاط العمودي.

== الخطوة 2 — الارتفاع الصادر من $A$، كوس على $(B C)$

الضلع لم يعد أفقيا. `rotate` يتبع $(B C)$، و `flip` يُدخل الكوس في
المثلث.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(C, Hc, stroke: purple.lighten(25%), weight: 0.8, role: "edge")
  fig += p-line(A, Ha, stroke: purple, weight: 1.15, role: "edge")
  fig += pt(Hc, fill: purple) + pt(Ha, fill: purple)
  fig += lab(Ha, [$H_a$], dx: 0.32, dy: 0.16, fill: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.28, colour: purple)
  fig += ra-in(Ha, vsub(C, B), vsub(A, Ha), size: 0.28, colour: purple)
  fig += square-on(Ha, vsub(C, B), vsub(A, Ha),
    length: dist(A, Ha) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[كوس على $(B C)$، الضلع الطويل نحو $A$. ارتفاعان يكفيان لإعطاء $H$.]

```typ
#let Ha = foot(A, B, C)
#square-on(Ha, vsub(C, B), vsub(A, Ha), length: dist(A, Ha) + 0.55)
#ra-in(Ha, vsub(C, B), vsub(A, Ha), colour: rgb("#7048E8"))
```

إن #strong[خرج] مربع الترميز من المثلث، فـ `rotate` يشير إلى نصف المستوى الخطأ.
نضيف $180 degree$، أو نأخذ `vangle(vsub(B, C))` بدل
`vangle(vsub(C, B))`.

== الخطوة 3 — الارتفاع الثالث، و $H$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(A, Ha, stroke: purple, weight: 1.05, role: "edge")
  fig += p-line(B, Hb, stroke: purple, weight: 1.05, role: "edge")
  fig += p-line(C, Hc, stroke: purple, weight: 1.05, role: "edge")
  fig += ra-in(Ha, vsub(C, B), vsub(A, Ha), size: 0.26, colour: purple)
  fig += ra-in(Hb, vsub(C, A), vsub(B, Hb), size: 0.26, colour: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.26, colour: purple)
  fig += pt(Ha, fill: purple) + pt(Hb, fill: purple) + pt(Hc, fill: purple)
  fig += pt(H, fill: purple, r: 0.1)
  fig += lab(H, text(fill: purple)[$H$], dx: -0.32, dy: 0.24, fill: purple)
  fig += lab(Ha, [$H_a$], dx: 0.32, dy: 0.14, fill: purple, size: 9pt)
  fig += lab(Hb, [$H_b$], dx: -0.36, dy: 0.12, fill: purple, size: 9pt)
  fig += lab(Hc, [$H_c$], dx: -0.40, dy: -0.28, fill: purple, size: 9pt)
  fig += square-on(Hb, vsub(C, A), vsub(B, Hb),
    length: dist(B, Hb) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[الارتفاعات الثلاثة وزواياها القائمة. $H$ داخلي : المثلث حاد الزوايا.]

```typ
#let H = line-inter(A, Ha, B, Hb)   // أو orthocenter(A, B, C)
```

#note[مثلث منفرج][
  إن كانت زاوية منفرجة، يخرج ملتقى الارتفاعات من المثلث وتسقط قدمان على
  #strong[التمديدات]. `foot` يحسبهما رغم ذلك ($t$ الإسقاط لم يعد في $[0, 1]$).
  نمدّد الضلع بمتقطع `line-ext`، ونُقعد الكوس على هذا التمديد.
]

= المراكز الأربعة معا

في #strong[كل] مثلث، $O$ و $G$ و $H$ مستقيمية : ذلك #strong[مستقيم أويلر]، و $G$ في
ثلث $[O H]$ من جهة $O$ :

$ arrow(O G) = 1/3 thin arrow(O H) $

$I$ لا يقع على هذا المستقيم إلا في المثلثات المتساوية الساقين.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-circle(O, R, stroke: blue, weight: 1.15)
  fig += p-circle(I, r-in, stroke: green, weight: 1.1)
  fig += p-line(A, Ma, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(B, Mb, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(C, Mc, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(A, Ha, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += p-line(B, Hb, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += p-line(C, Hc, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += line-ext(O, H, beyond: 0.7, stroke: red, weight: 1.2, dash: none)
  fig += pt(O, fill: blue, r: 0.09)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(G, fill: orange, r: 0.09)
  fig += pt(H, fill: purple, r: 0.09)
  fig += lab(O, [$O$], dx: 0.30, dy: -0.26, fill: blue)
  fig += lab(I, [$I$], dx: -0.30, dy: 0.22, fill: green)
  fig += lab(G, [$G$], dx: 0.30, dy: 0.20, fill: orange)
  fig += lab(H, [$H$], dx: -0.30, dy: 0.26, fill: purple)
  fig
}, padding: 0.5))
#cap[$O$، $G$، $H$ مستقيمية (أحمر). $I$ بمعزل : $A B C$ ليس متساوي الساقين.]

== خلاصة الحركات

#table(
  columns: (auto, auto, 1fr, auto),
  inset: 7pt,
  stroke: 0.4pt + luma(210),
  fill: (_, y) => if y == 0 { blue.lighten(82%) } else if calc.odd(y) { luma(248) },
  [#strong[المركز]], [#strong[الخطوط]], [#strong[الأداة]], [#strong[الترميز]],
  text(fill: blue, weight: "bold")[$O$], [المحاور], [مدور، قوسان متساويان],
    [$A M = M B$، زاوية قائمة],
  text(fill: green, weight: "bold")[$I$], [المنصفات], [مدور، قوس ثم قوسان],
    [أقواس زوايا، أشعة $perp$],
  text(fill: orange, weight: "bold")[$G$], [المتوسطات], [مسطرة (مناصف ومتوسطات)],
    [شرطات تساوٍ في المناصف],
  text(fill: purple, weight: "bold")[$H$], [الارتفاعات], [كوس على الضلع],
    [زاوية قائمة في كل قدم],
)

= مرجع سريع

== `geom`

```typ
#geom(body, mode: "clean", roughness: 1.0, seed: 1,
      colour: black, frame: none, padding: 0.25)
```

`body` جدول بدائيات. `frame: (x0, x1, y0, y1)` يثبّت المدى بدل ملاءمة
المحتوى — مفيد لرصّ خطوات #strong[بنفس المقياس].

== `compass(from, to)`

| الوسيط | الافتراضي | |
|---|---|---|
| `leg` | `6.0` | طول الساق، سم |
| `scale` | `1.0` | يصغّر الأداة، #strong[يبقي] القدمين |
| `flip` | `false` | يقلب إلى الجهة الأخرى من `[from to]` |
| `pencil-colour` | أحمر | جسم القلم |
| `pencil-lead` | `auto` (أسود) | الساس ؛ مرّر لون الجسم |
| `show-pencil` | `true` | |

إن تجاوز البعد $2 times "leg" times "scale"$، تشبع الساقان ولا تعود
القدمان تلتقيان. نزيد `leg` أو نقرّب النقطتين.

== `set-square`

| الوسيط | الافتراضي | |
|---|---|---|
| `at` | `(0,0)` | #strong[الزاوية القائمة] |
| `rotate` | `0deg` | اتجاه القاعدة ($+x$ المحلي) |
| `length` | `10` | الضلع الطويل ؛ أرضية $4.5$ إن `clamp: true` |
| `flip` | `false` | قلب على الطاولة |
| `values` | `true` | الأرقام ؛ `false` يبقي التدرجات |
| `clamp` | `true` | |

`square-on(at, along, toward)` (هذا الدليل) يختار `rotate` و `flip`.

== `ruler`

الصفر في `at`، نحو `rotate`. `corner: 0.12` يلطّف الطرفين (ليست كبسولة).
`corner: 0` : زوايا حادة. `value-pos: "m"` (وسط)، `"h"` (أعلى)، `"b"`
(أسفل، مقلوب)، قابلة للجمع (`"hb"`).

== `right-angle`

```typ
#right-angle(at: vertex, rotate: 0deg, size: 0.32, colour: black)
```

مربع #strong[مفتوح]، الرأس متراجع. `rotate` = اتجاه الضلع الأول.

== بدائيات الإنشاء

```typ
p-line(A, B, stroke: luma(120), weight: 1.0, dash: "dashed", role: "edge")
p-arc(centre, r, a0, a1, stroke: blue, dash: "dashed")
p-circle(centre, r, stroke: blue, weight: 1.3)
p-label(pos, [A], size: 10pt, fill: black)
```

`role: "edge"` (افتراضي الأدوات) أو `"tick"` / `"detail"` : في نمط
`rough`، التدرجات ترتجف ثلاث مرات أقل، وإلا علامة 2 مم تذوب عند السعة
التي تكسو مسطرة 12 سم.

== الصيغ المستعملة

- $O$ تقاطع المحاور.
- $I = (a A + b B + c C) / (a + b + c)$ مع $a = B C$، $b = A C$، $c = A B$.
- $G = (A + B + C) / 3$.
- $H$ تقاطع ارتفاعين ؛ $H_a$ المسقط العمودي لـ $A$ على الضلع $B C$.

#v(0.8em)
#line(length: 100%, stroke: 0.4pt + luma(180))
#v(0.25em)
#text(size: 8.2pt, fill: luma(110))[
  `geomtools` 0.1.0 — نقل لـ `OutilsGeomTikZ` لسيدريك بيركي
  (LPPL 1.3c). لا يصون هذا النقل ولا يزكيه. دليل كُتب للمثلث
  $A(0,0)$، $B(7.2,0)$، $C(2.2, 4.8)$ ؛ القوائم تُنسخ كما هي بعد استيراد
  `helpers.typ`.
]
