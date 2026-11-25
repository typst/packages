#import "@preview/na-frame:0.1.0": *

// Latin version: every frame (60). Title and content are yours:
//   #theorem-frame(title: [My own title])[ Whatever I want ]
#set page(paper: "a4", margin: 18mm)
#set text(font: "New Computer Modern", lang: "en", dir: ltr, size: 11pt)

= na-frame frames (Latin)

#theorem-frame(title: [Pythagorean theorem])[
  In a right triangle: $ a^2 + b^2 = c^2 $
]

#blue-frame(title: [Definition of a function], color: palette.indigo)[
  Each input is related to at most one output.
]

#green-frame(title: [Exercise 1], subtitle: [4 points], color: palette.green)[
  Compute $ lim_(x -> 0) (sin x)/x $
]

#shadow-frame(title: [Worked example], color: palette.crimson)[
  Layered shadow, folded corner.
]

#proof-frame(title: [Proof])[
  Assume that ... hence ...
]

#flag-frame(title: [Key property])[
  Property text.
]

#gradient-frame(title: [Remark], color: palette.teal)[
  Gradient title tab.
]

#chapter-frame(title: [Chapter plan])[
  + Functions
    + Limits
    + Derivatives
]

#ribbon-frame(title: [Reminder])[
  Full-width folded ribbon.
]

#board-frame(title: [Blackboard], color: palette.orange)[
  Bevelled board frame.
]

#paper-frame(title: [Paper])[
  Pinned paper with a curled corner.
]

#sticky-frame(title: [Don't forget])[
  Yellow sticky note.
]

#notebook-frame(title: [Lab notebook])[
  Spiral notebook.
]

#corner-rule-frame(title: [Theorem])[
  Subtitle on the opposite side.
]

#properties-frame(title: [Properties])[
  $ overline(z_1 + z_2) = overline(z_1) + overline(z_2) $
]

#folded-definition-frame(title: [Definition])[
  Folded title tab.
]

#centered-info-frame(title: [Important])[
  Centered title between two bars.
]

#double-tab-frame(title: [Property])[
  Main and secondary title tabs.
]

#torn-paper-frame(title: [Torn paper])[
  Torn edges with a soft shadow.
]

#spiral-banner-frame(title: [My own title])[
  Title banner with a side wire.
]

#notebook-page-frame(title: [Intermediate value theorem], paper-color: rgb("#cdeef8"))[
  Ruled notebook page.
]

#numbered-exercise-frame(title: [Exercise], third-title: [Complex numbers])[
  Numbering is automatic.
]

#numbered-frame(title: [Exercise no.], number: [02])[
  Exercise text.
]

#property-frame(title: [Property], badge-top: [Add to], badge-bottom: [your notes])[
  Property text.
]

#exercise-card(title: [Review exercise])[
  Questions are independent.
]

#exam-frame(title: [Exercise no.], number: 3)[
  Exercise text.
]

#tab-frame(title: [Definition])[
  Definition text.
]

#curved-tab-frame(title: [Activity])[
  Text.
]

#speech-frame(title: [Note])[
  Note text.
]

#rounded-tab-frame(title: [Reminder])[
  Text.
]

#right-rule-frame(title: [Rule])[
  Text.
]

#folded-corner-frame(title: [Activity 1])[
  Text.
]

#subtitle-frame(title: [Exercise on functions])[
  Text.
]

#outlined-tab-frame(title: [Definition])[
  Text.
]

#inset-tab-frame(title: [Definition])[
  Text.
]

#side-notebook-frame(title: [Side notebook])[
  Text.
]

#binder-notebook-frame(title: [Note])[
  Text.
]

#framed-exercise(title: [Review exercise on functions])[
  Exercise text.
]

#sheet-frame(title: [Exercise])[
  The height follows your content.
]

#bevel-frame(title: [Bevelled frame])[
  Text.
]

#lace-frame(title: [Lace])[
  Text.
]

#illuminated-frame(title: [Illuminated])[
  Text.
]

#geometric-frame(title: [Geometric])[
  Text.
]

#math-cover-frame(title: [Distinction series])[
  Text.
]

#vintage-frame(title: [Vintage])[
  Text.
]

#jewel-frame(title: [Jewel])[
  Text.
]

#star-chain-frame(title: [Star chain])[
  Text.
]

#lantern-frame(title: [Lantern])[
  Text.
]

#botanical-frame(title: [Botanical])[
  Text.
]

#emerald-frame(title: [Emerald])[
  Text.
]

#right-scroll-frame(title: [Scroll])[
  Text.
]

#homework-sheet(title: [Homework sheet])[
  Text.
]

#homework-sheet-modern(title: [Application])[
  Text.
]

#practical-notebook(title: [Practical work])[
  Text.
]

#warning-note(title: [Warning])[
  Important text.
]

#ribbon-notes-frame(title: [Important notes])[
  Let $z$ be a nonzero complex number written in trigonometric form:
  $ z = r (cos(theta) + i sin(theta)). $

  #list(marker: text(fill: palette.purple)[▶],
    [The modulus of $z$ is $r$, where $r > 0$.],
    [For every natural number $n$: $z^n = r^n (cos(n theta) + i sin(n theta))$.],
    [$z^n$ is real if and only if $sin(n theta) = 0$.],
    [$z^n$ is purely imaginary if and only if $cos(n theta) = 0$.],
  )
]

#grid-notebook-frame(title: [Applied exercise])[
  In this activity we organise our ideas and apply what we learned step by step.

  We write the steps clearly and check the results.
]

#prerequisites-frame(items: (
  ([Prior knowledge], [Pythagorean theorem, simple point transformations.]),
  ([Target skills], [Use transformation properties to solve geometry problems.]),
  ([Tools], [Textbook, geometry tools, GeoGebra.]),
))

#folded-ribbon-frame(title: [Homework no. 1])[
  Simplify $sqrt(sqrt(3^8))$, then name the smallest set it belongs to.
]

#hanging-tab-frame(title: [Logarithm exercise])[
  Solve in $RR$: $ln(x) + ln(x - 1) = ln(6)$.
]

#winged-tab-frame(title: [Note])[
  A centered label with two pointed wings and a dotted inner border.
]

#badge-notebook-frame(title: [Practical work])[
  In this activity we organise our ideas and apply what we learned step by step.

  We write the steps clearly and check the results.
]

#ribbon-banner(title: [My own title])

#arched-ribbon(title: [My own title])

// An Arabic frame inside a Latin document, with your own title and content.
#theorem-frame(dir: rtl, title: [عنواني الخاص])[إطار عربي داخل مستند لاتيني: $ a^2 + b^2 = c^2 $]
#frame("blue", dir: rtl, title: [تعريف])[تعريف بالاتجاه العربي.]

// One title, two versions: picked by the frame language.
#theorem-frame(title: (ar: [مبرهنة], en: [Theorem]))[English title chosen automatically.]
#theorem-frame(dir: rtl, title: (ar: [مبرهنة], en: [Theorem]))[عنوان عربي.]

// Page-break test.
#theorem-frame(title: [Break test])[
  #for i in range(60) [Line #i of a long text to test breaking across pages. \ ]
]

// Batch 4 in the Arabic layout (dir: rtl) inside the Latin document.
#folded-ribbon-frame(dir: rtl, title: [الواجب المنزلي])[نسخة عربية: الشريط على اليمين.]
#hanging-tab-frame(dir: rtl, title: [تمرين])[نسخة عربية: اللسان على اليمين.]
#winged-tab-frame(dir: rtl, title: [ملاحظة])[نسخة عربية.]
#badge-notebook-frame(dir: rtl, title: [أعمال تطبيقية])[نسخة عربية: الشارة على اليمين.]
