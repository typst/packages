// ===========================================================================
//  examples/bilingual.typ — Arabic and Latin on the same deck.
//
//  The direction is a property of the TEXT, not of the deck, so a single
//  presentation can hold both. Set the deck's own `lang`/`dir` for the
//  common case and wrap the exception in `#text(..)`.
//
//  This is also the awkward case worth testing: numbers, formulae and code
//  are left-to-right runs INSIDE right-to-left prose.
//
//    typst compile examples/bilingual.typ --font-path ../fonts
// ===========================================================================

#import "@preview/chalkdeck:0.1.0": *

#let AR(body) = text(lang: "ar", dir: rtl,
  font: ("Tajawal", "DejaVu Sans"), body)

#show: chalkdeck.with(
  theme: "whiteboard",
  title: [Bilingual deck / عرض ثنائي اللغة],
  subtitle: [same package, both directions],
  author: [chalkdeck],
)

#slide(title: [Latin first])[
  The deck is left-to-right here: the title sits on the left, the bullets
  hang on the left, and the block's rule stands on the left.

  #slide-list([first], [second], [third])

  #slide-block(kind: [Note])[
    Nothing has been switched — this is the default.
  ]
]

#slide(title: AR[ثم العربية])[
  #AR[
    نفس الشريحة، لكن النص عربي : كل شيء ينقلب من تلقاء نفسه.

    #slide-list([الأول], [الثاني], [الثالث])

    #slide-block(kind: [ملاحظة])[
      العنوان على اليمين، والنقاط كذلك، والخط العمودي أيضا.
    ]
  ]
]

#slide(title: AR[الأرقام والصيغ])[
  #AR[
    الأرقام تبقى بالترتيب الغربي داخل النص العربي : الدرس 12، التمرين 18،
    الصفحة 145. وهذا هو العرف في المغرب العربي.

    #slide-block(kind: [مبرهنة], title: [فيثاغورس])[
      في مثلث قائم الزاوية : $a^2 + b^2 = c^2$، وهي صيغة تُقرأ من اليسار
      إلى اليمين داخل جملة تُقرأ من اليمين إلى اليسار.
    ]

    #slide-alert[حتى أسفل الصفحة : رقم الشريحة لا ينقلب.]
  ]
]

#slide(title: [Mixed lists / قوائم مختلطة])[
  #slide-columns(
    [
      *Latin*
      #slide-list([alpha], [beta], [gamma])
    ],
    AR[
      *عربي*
      #slide-list([ألف], [باء], [جيم])
    ],
  )
]
