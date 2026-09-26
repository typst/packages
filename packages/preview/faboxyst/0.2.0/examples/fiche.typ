// ===========================================================================
//  examples/fiche.typ — a pedagogical sheet (fiche pédagogique) rebuilt
//  with faboxyst: fabox panels, numbox badges, spine tabs for the side
//  labels.  Arabic, right-to-left, one A4 page.
//
//    typst compile examples/fiche.typ --root .
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *
#import "@preview/longops:0.1.1": division

#set page(paper: "a4", margin: 0.6cm)
#set text(dir: rtl, lang: "ar", size: 7.6pt,
  font: ("Amiri", "Noto Naskh Arabic", "DejaVu Sans"))
#set par(leading: 0.32em)

// ---- the sheet's palette --------------------------------------------------
#let INK = rgb("#25374A")
#let HD-BACK = rgb("#DEEBF4")
#let HD-RULE = rgb("#9FB8C8")
#let RED = rgb("#C0392B")
#let GREEN = rgb("#2E8B3A")
#let MAGENTA = rgb("#B0247A")
#let BLUE = rgb("#2471A3")
#let OLIVE = rgb("#8A7A1D")
#let PINK-BACK = rgb("#F9EDF5")
#let PINK-RULE = rgb("#D9B8D0")
#let BLUE-BACK = rgb("#DBEAF3")
#let YEL-BACK = rgb("#FBF6DA")
#let YEL-RULE = rgb("#D6C88E")
#let ACT-GREEN = rgb("#4C9A4C")
#let STEP-BACK = rgb("#EEF4E3")
#let STEP-RULE = rgb("#A9BE8E")
#let NOTE-BACK = rgb("#E1EEF5")
#let ROSE-BACK = rgb("#F9E7EE")
#let ROSE-RULE = rgb("#D48CB0")
#let LAV-BACK = rgb("#E9EFF9")
#let LAV-RULE = rgb("#8CA8D8")

// a titled panel of the sheet: fabox with the rule under the title off
#let panel(body, title: none, tfill: INK, back: white, rule: HD-RULE,
  inset: 0.2cm, ruled: false) = fabox(title: title, colour: rule,
  back: back, title-fill: back, title-colour: tfill, radius: 0.28,
  rule-between: ruled, inset: inset, title-weight: "bold", body)

// a vertical divider for the grids below (physical left edge)
#let vdiv(body) = block(width: 100%, stroke: (left: 0.7pt + HD-RULE), body)

#let arr(ch) = text(size: 13pt, fill: luma(25), ch)

// a numbered line with a small square badge (numbox, frameless)
#let item(colour, n, body) = numbox(number: n, numbering: "1",
  colour: colour, fill: none, stroke: none, badge-size: 0.42cm,
  badge-radius: 0.06cm, inset: 0cm, gap: 0.14cm, width: 100%, body)

// ===========================================================================
// 1. the header table
// ===========================================================================
#panel(back: HD-BACK, rule: HD-RULE, inset: 0.1cm)[
  #grid(columns: (20%, 20%, 22%, 22%, 16%),
    block(width: 100%, inset: (x: 0.18cm, y: 0.08cm), {
      set align(start)
      text(weight: "bold", fill: INK)[المستوى:]
      v(0.12cm)
      set align(center)
      text(weight: "bold", fill: INK)[الرابعة متوسط]
    }),
    block(width: 100%, stroke: (left: 0.7pt + HD-RULE),
      inset: (x: 0.18cm, y: 0.08cm), {
      set align(start)
      text(weight: "bold", fill: INK)[الميدان:]
      v(0.12cm)
      set align(center)
      text(weight: "bold", fill: INK)[الأعداد والحساب]
    }),
    block(width: 100%, stroke: (left: 0.7pt + HD-RULE),
      inset: (x: 0.18cm, y: 0.08cm), {
      set align(start)
      text(weight: "bold", fill: INK)[المقطع التعليمي:]
      v(0.12cm)
      set align(center)
      text(weight: "bold", fill: INK)[الأعداد الطبيعية\ والأعداد الناطقة]
    }),
    block(width: 100%, stroke: (left: 0.7pt + HD-RULE),
      inset: (x: 0.18cm, y: 0.08cm), {
      set align(start)
      text(weight: "bold", fill: INK)[المورد:]
      v(0.12cm)
      set align(center)
      text(weight: "bold", fill: RED)[القاسم المشترك الأكبر\ خوارزمية إقليدس]
    }),
    block(width: 100%, stroke: (left: 0.7pt + HD-RULE),
      inset: (x: 0.18cm, y: 0.08cm), {
      set align(start)
      text(weight: "bold", fill: INK)[المدة:]
      v(0.12cm)
      set align(center)
      text(weight: "bold", fill: INK)[01 سا]
    }),
  )
]

#v(0.05cm)

// ===========================================================================
// 2. competency row
// ===========================================================================
#panel(back: PINK-BACK, rule: PINK-RULE, inset: 0.1cm)[
  #grid(columns: (34%, 33%, 33%),
    block(width: 100%, inset: (x: 0.22cm, y: 0.13cm), {
      set align(start)
      text(weight: "bold", fill: GREEN)[الكفاءة المستهدفة:]
      v(0.16cm)
      text(fill: INK)[حل وضعيات مشكل دالة بالاعتماد على حساب القاسم المشترك
        الأكبر باستعمال خوارزمية إقليدس.]
    }),
    block(width: 100%, stroke: (left: 0.7pt + PINK-RULE),
      inset: (x: 0.22cm, y: 0.13cm), {
      set align(start)
      text(weight: "bold", fill: MAGENTA)[مركبات الكفاءة:]
      v(0.16cm)
      set text(fill: INK)
      [- تحديد القاسم المشترك الأكبر لعددين طبيعيين. \
        - استعمال خوارزمية إقليدس لحساب PGCD. \
        - توظيف PGCD في حل مشكلات.]
    }),
    block(width: 100%, stroke: (left: 0.7pt + PINK-RULE),
      inset: (x: 0.22cm, y: 0.13cm), {
      set align(start)
      text(weight: "bold", fill: RED)[الأهداف التعليمية:]
      v(0.16cm)
      set text(fill: INK)
      [في نهاية الدرس يكون التلميذ قادرًا على أن: \
        - يكشف خوارزمية إقليدس. \
        - يحسب القاسم المشترك الأكبر لعددين. \
        - يوظف النتيجة في وضعيات حياتية.]
    }),
  )
]

#v(0.05cm)

// ===========================================================================
// 3. starting situation + prior knowledge
// ===========================================================================
#grid(columns: (1.6fr, 1fr), column-gutter: 0.16cm,
  panel(title: [الوضعية الانطلاقية:], tfill: BLUE, back: BLUE-BACK,
    rule: HD-RULE)[
    لدى فلاح 84 شجرة زيتون و 60 شجرة حمضيات، ويريد غرسها في أكبر عدد ممكن
    من الصفوف المتطابقة بحيث يحتوي كل صف على نفس عدد أشجار الزيتون ونفس
    عدد أشجار الحمضيات. ما هو أكبر عدد من الصفوف؟
  ],
  panel(title: [المكتسبات القبلية:], tfill: OLIVE, back: YEL-BACK,
    rule: YEL-RULE)[
    القسمة الإقليدية على $NN$ : حيث $a = b q + r$
  ],
)

#v(0.06cm)

// ===========================================================================
// 4. activity 1 — discovering Euclid's algorithm
// ===========================================================================
#fabox(
  title: [النشاط 1],
  tab: "swoosh",
  swoosh-side: "right",
  colour: ACT-GREEN,
  back: white,
  title-fill: rgb("#DCEBD8"),
  title-colour: rgb("#2E5D2E"),
  radius: 0.32,
  rule-between: false,
  inset: 0.22cm,
)[
  #set align(center)
  #text(weight: "bold", size: 11.5pt, fill: rgb("#2E7D32"))[
    اكتشاف خوارزمية إقليدس]
  #v(0.06cm)
  #text(fill: INK)[لحساب اكبر عدد من الصفوف نبحث عن القاسم المشترك الأكبر
    للعددين 84 و 60.]
  #text(fill: INK)[ننجز القسمة الإقليدية للعدد الأكبر (84) على العدد الأصغر
    (60):]
  #v(0.16cm)
  #grid(columns: (21%, 23%, 5%, 23%, 5%, 23%), column-gutter: 0pt,
    align(center, panel(back: NOTE-BACK, rule: HD-RULE, inset: 0.14cm)[
      #set align(start)
      #text(fill: INK)[لاحظنا أن الباقي في كل خطوة يصبح أصغر من المقسوم
        عليه.]
      #v(0.06cm)
      #text(fill: INK)[استمرينا في القسمة حتى حصلنا على باقي منعدم.]
    ]),
    align(center, panel(title: [الخطوة الثالثة:], tfill: rgb("#556B2F"),
      back: STEP-BACK, rule: STEP-RULE, inset: 0.16cm)[
      #set align(end)
      #align(center, text(dir: ltr, fill: INK)[#division(24, 12, size: 0.92em)])
      #v(0.05cm)
      #align(start, text(fill: RED, weight: "bold")[الباقي: 0])
    ]),
    align(center + horizon, arr[→]),
    align(center, panel(title: [الخطوة الثانية:], tfill: rgb("#556B2F"),
      back: STEP-BACK, rule: STEP-RULE, inset: 0.16cm)[
      #set align(end)
      #align(center, text(dir: ltr, fill: INK)[#division(60, 24, size: 0.92em)])
      #v(0.05cm)
      #align(start, text(fill: RED, weight: "bold")[الباقي: 12])
    ]),
    align(center + horizon, arr[→]),
    align(center, panel(title: [الخطوة الأولى:], tfill: rgb("#556B2F"),
      back: STEP-BACK, rule: STEP-RULE, inset: 0.16cm)[
      #set align(end)
      #align(center, text(dir: ltr, fill: INK)[#division(84, 60, size: 0.92em)])
      #v(0.05cm)
      #align(start, text(fill: RED, weight: "bold")[الباقي: 24])
    ]),
  )
  #v(0.05cm)
  #grid(columns: (30%, 30%, 6%, 34%),
    [],
    align(center, {
      align(center)[#arr[↓]]
      block(width: 100%, fill: rgb("#E4F0DC"), radius: 4pt,
        stroke: 0.8pt + ACT-GREEN, inset: (x: 0.3cm, y: 0.16cm),
        align(center, text(fill: INK)[إذا أكبر عدد من الصفوف هو 12 .]))
    }),
    align(center + horizon, arr[←]),
    align(center, panel(back: NOTE-BACK, rule: HD-RULE, inset: 0.14cm)[
      #set align(start)
      #text(fill: INK)[نلاحظ أن 12 هو آخر باقي غير منعدم، وسنثبت فيما بعد
        أنه هو القاسم المشترك الأكبر.]
    ]),
  )
]

#v(0.06cm)

// ===========================================================================
// 5. the rule and the properties
// ===========================================================================
#grid(columns: (1.18fr, 1fr), column-gutter: 0.16cm,
  panel(title: [القاعدة ( خوارزمية إقليدس ) :], tfill: MAGENTA,
    back: ROSE-BACK, rule: ROSE-RULE)[
    #set align(start)
    #text(fill: INK)[لحساب القاسم المشترك الأكبر لعددين طبيعيين $a$ و $b$
      حيث $a > b$ نتبع الخطوات التالية:]
    #v(0.05cm)
    #set text(fill: INK)
    [1- نقسم $a$ على $b$ ونحسب الباقي $r_1$. \
      2- نقسم $b$ على $r_1$ ونحسب الباقي $r_2$. \
      3- نواصل العملية بنفس الطريقة. \
      4- نتوقف عندما نحصل على باقٍ يساوي صفرًا.]
    #v(0.05cm)
    #block(width: 100%, fill: rgb("#F6D9E4"), radius: 3pt,
      stroke: 0.8pt + rgb("#C05A8E"), inset: (x: 0.2cm, y: 0.1cm),
      align(center, text(fill: INK)[القاسم المشترك الأكبر هو آخر باقي غير
        منعدم.]))
  ],
  panel(title: [خصائص:], tfill: BLUE, back: LAV-BACK, rule: LAV-RULE)[
    #set align(start)
    #set text(fill: INK)
    [• إذا كان $a = b q$ فإن $"PGCD"(a ; b) = b$. \
      • إذا كان $a = b q + r$ حيث $0 < r < b$ فإن:]
    #v(0.05cm)
    #block(width: 100%, fill: rgb("#DDE9F5"), radius: 3pt,
      stroke: 0.8pt + rgb("#6F93C4"), inset: (x: 0.2cm, y: 0.1cm),
      align(center, text(dir: ltr)[$"PGCD"(a ; b) = "PGCD"(b ; r)$]))
    #v(0.05cm)
    [أي أن القاسم المشترك الأكبر لا يتغير عند تعويض $(a ; b)$ بـ $(b ; r)$.]
  ],
)

#v(0.06cm)

// ===========================================================================
// 6. worked examples, with a side tab
// ===========================================================================
#fabox(
  title: [أمثلة تطبيقية],
  tab: "swoosh",
  swoosh-side: "right",
  colour: ROSE-RULE,
  back: white,
  title-fill: rgb("#F3E3EE"),
  title-colour: MAGENTA,
  radius: 0.32,
  rule-between: false,
  inset: 0.2cm,
)[
  #grid(columns: (25%, 37.5%, 37.5%),
    block(width: 100%, inset: (x: 0.16cm, y: 0.1cm),
      panel(title: [ملاحظة :], tfill: OLIVE, back: YEL-BACK,
        rule: YEL-RULE, ruled: true, inset: 0.2cm)[
        #set align(start)
        #set text(fill: INK)
        [لا نبحث عن أكبر باقي، \ بل عن آخر باقي \ غير منعدم.]
      ]),
    block(width: 100%, stroke: (left: 0.7pt + ROSE-RULE),
      inset: (x: 0.24cm, y: 0.1cm), {
      set align(start)
      text(weight: "bold", fill: MAGENTA)[مثال 1:]
      v(0.08cm)
      text(fill: INK)[أحسب PGCD (252 ; 105)]
      v(0.06cm)
      set align(center)
      set text(dir: ltr, fill: INK)
      [252  =  105 × 2  +  42 \ 105  =  42 × 2  +  21 \ 42  =  21 × 2  +  0]
      v(0.08cm)
      text(weight: "bold", fill: RED)[PGCD (252 ; 105)  =  21]
    }),
    block(width: 100%, stroke: (left: 0.7pt + ROSE-RULE),
      inset: (x: 0.24cm, y: 0.1cm), {
      set align(start)
      text(weight: "bold", fill: MAGENTA)[مثال 2:]
      v(0.08cm)
      text(fill: INK)[أحسب PGCD (391 ; 299)]
      v(0.06cm)
      set align(center)
      set text(dir: ltr, fill: INK)
      [391  =  299 × 1  +  92 \ 299  =  92 × 3  +  23 \ 92  =  23 × 4  +  0]
      v(0.08cm)
      text(weight: "bold", fill: RED)[PGCD (391 ; 299)  =  23]
    }),
  )
]

#v(0.06cm)

// ===========================================================================
// 7. exercises — assessment, integration, consolidation
// ===========================================================================
#grid(columns: (1fr, 0.97fr, 0.97fr), column-gutter: 0.16cm,
  panel(back: rgb("#E4F0F8"), rule: HD-RULE, inset: 0.16cm)[
    #set align(center)
    #text(weight: "bold", fill: BLUE)[تقويم]
    #v(0.05cm)
    #set align(start)
    #text(fill: INK)[أكمل العبارات التالية:]
    #v(0.05cm)
    #item(rgb("#6FA8CC"), 1, [القاسم المشترك الأكبر لعددين هو ...........])
    #v(0.2em)
    #item(rgb("#6FA8CC"), 2, [في خوارزمية إقليدس نتوقف عندما ...........])
    #v(0.2em)
    #item(rgb("#6FA8CC"), 3, [آخر باقي غير منعدم هو ...........])
    #v(0.2em)
    #item(rgb("#6FA8CC"), 4, [إذا كان $a = b q + r$ فإن:])
    #v(0.2em)
    #align(center, text(dir: ltr, fill: INK)[$"PGCD"(a ; b) =
      "PGCD"(..... ; .....) $])
  ],
  panel(back: rgb("#FDF8E3"), rule: YEL-RULE, inset: 0.16cm)[
    #set align(center)
    #text(weight: "bold", fill: OLIVE)[وضعية إدماجية]
    #v(0.05cm)
    #set align(start)
    #text(fill: INK)[لدى تاجر 96 صندوقًا من البرتقال و 72 صندوقًا من
      التفاح. يريد ترتيب هذه الصناديق في أكبر عدد ممكن من المجموعات
      المتطابقة، بحيث تحتوي كل مجموعة على نفس عدد صناديق البرتقال ونفس
      عدد صناديق التفاح.]
    #v(0.05cm)
    #item(rgb("#E69A3C"), 1, [ماهو أكبر عدد من المجموعات؟])
    #v(0.2em)
    #item(rgb("#E69A3C"), 2, [كم صندوق برتقال في كل مجموعة؟])
    #v(0.2em)
    #item(rgb("#E69A3C"), 3, [كم صندوق تفاح في كل مجموعة؟])
  ],
  panel(back: rgb("#EAF4E7"), rule: STEP-RULE, inset: 0.16cm)[
    #set align(center)
    #text(weight: "bold", fill: GREEN)[تمارين للتثبيت]
    #v(0.05cm)
    #set align(start)
    #text(fill: INK)[أحسب باستعمال خوارزمية إقليدس PGCD :]
    #v(0.05cm)
    #item(rgb("#58A05A"), 1, align(right, text(dir: ltr)[PGCD (72 ; 30)]))
    #v(0.2em)
    #item(rgb("#58A05A"), 2, align(right, text(dir: ltr)[PGCD (135 ; 84)]))
    #v(0.2em)
    #item(rgb("#58A05A"), 3, align(right, text(dir: ltr)[PGCD (252 ; 198)]))
    #v(0.2em)
    #item(rgb("#58A05A"), 4, align(right, text(dir: ltr)[PGCD (425 ; 175)]))
  ],
)

#v(0.06cm)

// ===========================================================================
// 8. footer — common mistakes and a reminder star
// ===========================================================================
#panel(back: rgb("#FBE9EC"), rule: rgb("#E0A9B4"), inset: 0.1cm)[
  #grid(columns: (58%, 42%),
    block(width: 100%, inset: (x: 0.24cm, y: 0.08cm), {
      set align(start)
      text(weight: "bold", fill: RED)[الأخطاء الشائعة:  ]
      text(fill: INK)[• التوقف قبل الحصول على باقي منعدم.    • نسيان ترتيب
        القسمة من الأكبر إلى الأصغر.]
    }),
    block(width: 100%, stroke: (left: 0.7pt + rgb("#E0A9B4")),
      inset: (x: 0.24cm, y: 0.08cm),
      grid(columns: (auto, 1fr), column-gutter: 0.2cm, align: horizon,
        box(width: 1.4cm, height: 0.95cm, {
          place(top + left,
            polygon(fill: rgb("#58A05A"),
              (0.7cm, 0cm), (0.91cm, 0.31cm), (1.28cm, 0.38cm),
              (1.04cm, 0.65cm), (1.1cm, 0.95cm), (0.7cm, 0.79cm),
              (0.3cm, 0.95cm), (0.36cm, 0.65cm), (0.12cm, 0.38cm),
              (0.49cm, 0.31cm)))
          place(top + left, dx: 0.7cm, dy: 0.38cm,
            align(center + horizon,
              text(size: 7pt, weight: "bold", fill: white)[تذكير]))
        }),
        align(center, text(fill: INK)[القسمة الإقليدية هي أساس خوارزمية
          إقليدس.]),
      )),
  )
]
