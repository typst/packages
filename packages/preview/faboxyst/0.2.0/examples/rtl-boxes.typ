// ===========================================================================
//  faboxyst — every box speaks Arabic: bodies set to the right, fasteners
//  and badges mirrored, and a `direction` you can force either way.
//
//    typst compile examples/rtl-boxes.typ --root .
//
//  Fonts: any Naskh for the body (Amiri, Noto Naskh Arabic …); the whole
//  file falls back to DejaVu when absent.
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(width: 16cm, height: auto, margin: 9mm, fill: white)
#set text(dir: rtl, lang: "ar", font: ("Amiri", "DejaVu Serif"), size: 10.5pt)
#set par(leading: 0.64em)

#align(center)[#text(size: 17pt, weight: "bold")[صناديق تتكلّم العربية]]
#align(center)[#text(size: 9pt, fill: gray)[
  كل صندوق يتبع اتجاه المستند: المحتوى يُضبَط على _البداية_، أي إلى اليمين
  هنا — من غير لفّه في `align(right)[…]`.
]]

// ---------------------------------------------------------------------------
= البطاقات الورقية

#grid(columns: (1fr, 1fr), column-gutter: 0.45cm, row-gutter: 0.45cm,
  stamp-card(width: 6.6)[بطاقة طابع: نصها يبدأ من اليمين تلقائياً.],
  grid-note(width: 6.6)[ورقة مربعات: كذلك، وسطورها تُقلَب مع الاتجاه.],
  index-card(width: 6.6)[بطاقة فهرسة: كذلك.],
  deckle-tag(width: 6.6)[بطاقة مسنّنة الحواف: كذلك.],
)

// ---------------------------------------------------------------------------
= لواصق وتذاكر

#post-it(pin: "tape", tape-wide: 0.45cm)[
  ملاحظة لاصقة بشريط عريض (#raw("tape-wide"): 0.45 سم)، نصها من اليمين.
]

#v(0.3cm)
#ticket(stub: [١٢٣])[
  تذكرة: جذعها ينتقل إلى الجهة المنطقية المقابلة حين ينقلب المستند.
]

#v(0.3cm)
#terminal(title: [shell], direction: ltr)[`npm install @preview/faboxyst`]

// ---------------------------------------------------------------------------
= الشرائط والأختام

#flagbox(title: [شريط العنوان], colour: rgb("#1F6F4A"))[
  يجلس الشريط على الحافة العلوية للصندوق، وتنقلب الشارة والزخارف
  مع اتجاه المستند.
]

#v(0.35cm)
#khatambox(title: [خاتم], badge: [١], badge-label: [تمرين])[
  الشارة والتاج والساش: كل ذلك ينقلب مع الاتجاه، لأن الزوايا منطقية
  (start / end) لا فيزيائية.
]

// ---------------------------------------------------------------------------
= الورق والشريط في RTL

ستة أنواع من الورق (paper stocks) تحمل النص: في RTL يستقر السطر الأخير
القصير عند الحافة اليمنى، لأن المحاذاة تُضبط على الاتجاه لا على اليسار،
وشرط الوشي (washi) ينتقل إلى الزاوية المرآتية:

#grid(columns: (1fr, 1fr), column-gutter: 0.5cm, row-gutter: 0.45cm,
  torn-note(width: 6.6)[
    نص عربي طويل بما يكفي لكي يلتف على عدة أسطر، حتى تظهر محاذاة
    السطر الأخير القصير عند حافة البداية لا عند اليسار.
  ],
  ruled-sheet(width: 6.6)[
    ورقة مسطرة: الثقوب في حافة البداية، والسطر القصير الأخير عند
    اليمين تماماً كالسطر الأول.
  ],
  deckle-tag(width: 6.2)[
    بطاقة مسننة الحواف، شريطها في الزاوية المرآتية ونصها إلى اليمين.
  ],
  grid-note(width: 6.2)[
    ورقة مربعات: النص كله محاذاة إلى حافة البداية في هذا المستند.
  ],
)

// ---------------------------------------------------------------------------
= اتجاه مفروض

المعامل #raw("direction") يُفرض في الوجهين، داخل أي مستند:

#stamp-card(direction: ltr)[
  An English card inside an Arabic page: forcing #raw("direction: ltr")
  puts its body back on the left.
]

#v(0.3cm)
#set text(dir: ltr, lang: "en")
The page is LTR again — and each box below is forced RTL:

#grid(columns: (1fr, 1fr), column-gutter: 0.45cm,
  stamp-card(direction: rtl, width: 6.6)[بطاقة فُرض اتجاهها من اليمين داخل صفحة إنجليزية.],
  post-it(direction: rtl, pin: "tape")[ملاحظة فُرضت RTL وشريطها في موضع مرآتي.],
)
