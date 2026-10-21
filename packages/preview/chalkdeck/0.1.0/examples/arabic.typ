// ===========================================================================
//  examples/arabic.typ — a full deck in Arabic.
//
//  Right-to-left is not a switch bolted on at the end: the frame title, the
//  bullets, the rule beside a block and the two halves of the footline all
//  read `text.dir` and place themselves accordingly. This deck is part of
//  the test suite for that.
//
//    typst compile examples/arabic.typ --font-path ../fonts
// ===========================================================================

#import "@preview/chalkdeck:0.1.0": *

#show: chalkdeck.with(
  theme: "blackboard",
  title: [حزمة chalkdeck],
  subtitle: [عروض تقديمية بلغة Typst],
  author: [مثال بالعربية],
  institute: [سبورة الفصل],
  date: [2026],
  lang: "ar",
  dir: rtl,
  font: ("Tajawal", "DejaVu Sans"),
)

#slide(title: [المحتويات])[
  #slide-list(
    [الأدوات الأساسية],
    [الألوان والخلفيات],
    [الرياضيات],
    kind: "enumerate")
]

// ---------------------------------------------------------------------------
#slide-section[الأدوات الأساسية]

#slide(title: [القوائم])[
  كل شيء يتبع اتجاه النص تلقائيا : العنوان، القوائم، وأسفل الصفحة.

  #slide-list(
    [البند الأول],
    [البند الثاني],
    [البند الثالث],
  )

  #slide-alert[النص المنبَّه يأخذ لون التنبيه من اللوحة.]
]

#slide(title: [الكتل])[
  #slide-block(kind: [تعريف], title: [الفضاء المتري])[
    الفضاء المتري هو مجموعة $X$ مزوّدة بمسافة $d$ تحقق شروطا ثلاثة.
  ]

  #slide-block(kind: [ملاحظة])[
    الخط العمودي يقف على حافة البداية — أي على اليمين هنا — ويأخذ ارتفاع
    الكتلة بالضبط.
  ]
]

#slide(title: [عمودان])[
  #slide-columns(
    [
      *الأول*
      #slide-list([نقطة], [نقطة أخرى])
    ],
    [
      *الثاني*
      #slide-block(kind: [مثال])[
        الأعمدة تتبع الاتجاه كذلك.
      ]
    ],
  )
]

// ---------------------------------------------------------------------------
#slide-section[الألوان والخلفيات]

#slide(title: [اللوحة تُدمج ولا تُستبدل])[
  تغيير لون السبورة وحده لا يتطلب سوى مفتاح واحد :

  #slide-block[
    ```typ
    #show: chalkdeck.with(theme: "blackboard",
      palette: (board: rgb("#12314F"), bg: rgb("#12314F")))
    ```
  ]

  أما بقية الألوان — النص، العناوين، التنبيه — فتبقى كما هي في السمة.
]

// ---------------------------------------------------------------------------
#slide-section[الرياضيات]

#slide(title: [المتطابقات])[
  المتطابقة الشهيرة صالحة لكل عددين :

  $ (a+b)^2 = a^2 + 2 a b + b^2. $

  #slide-block(kind: [مبرهنة], title: [فيثاغورس])[
    في مثلث قائم الزاوية في $A$ :
    $ B C^2 = A B^2 + A C^2. $
  ]

  #slide-alert[الأرقام غربية — وهذا هو العرف في المغرب العربي.]
]

#slide(title: [تكامل غاوس])[
  #slide-block(kind: [مبرهنة], title: [تكامل غاوس])[
    $ integral_(-oo)^oo e^(-x^2) dif x = sqrt(pi). $
  ]
  #v(1fr)
  #align(center)[التمرين 12 من الصفحة 18.]
  #v(1fr)
]
