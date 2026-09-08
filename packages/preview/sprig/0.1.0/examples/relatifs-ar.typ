// Un cas concret en arabe : les opérations sur les nombres relatifs.
//
// Style « affiche de classe » : palette chaude, feuilles en bulles, moyeu
// clair pris dans la palette, tiges larges et bien ondulées. C'est la
// manière de l'affiche dont ce module est tiré.
//
// Chiffres OCCIDENTAUX (0 1 2 3), pas arabes-indiens : c'est l'usage au
// Maghreb, et Typst ne les convertit pas tout seul.
#import "@preview/sprig:0.1.0": *

#set page(width: 26cm, height: auto, margin: 1.1cm, fill: rgb("#FFFDF7"))
#set text(font: ("Tajawal", "Amiri", "DejaVu Sans"), size: 10pt,
  lang: "ar", dir: rtl)
#set par(justify: false, leading: 0.70em)
#show math.equation: set text(dir: ltr, font: "New Computer Modern Math")

#let ic(c, g) = text(fill: c, weight: "bold", size: 1.15em, g)

#mindmap(
  [*العمليات على\ الأعداد النسبية*],
  palette: "warm", shape: "bubble",
  leaf-width: 4.2, weight: 1.2pt,
  wave: 0.06, waves: 1.8, stalk: 0.38,
  hub-fill: rgb("#7A2E1E"),
  start: 90deg,

  branch(title: [الجمع], icon: ic(rgb("#E4572E"), [+]), children: (
    branch[نفس الإشارة],
    branch[إشارتان مختلفتان],
  ))[
    نفس الإشارة: نجمع المسافتين ونحتفظ بالإشارة.
    $(-3) + (-5) = -8$
  ],

  branch(title: [الطرح], icon: ic(rgb("#F4A259"), [−]))[
    طرح عدد يعني جمع معاكسه.
    $7 - (-4) = 7 + 4 = 11$
  ],

  branch(title: [الضرب], icon: ic(rgb("#C9736A"), [×]), children: (
    branch[$(+) times (+) = +$],
    branch[$(-) times (-) = +$],
    branch[$(+) times (-) = -$],
  ))[
    نضرب المسافتين ثم نحدد الإشارة بقاعدة الإشارات.
  ],

  branch(title: [القسمة], icon: ic(rgb("#D08C60"), [÷]))[
    نفس قاعدة الإشارات كالضرب.
    $(-12) / (+3) = -4$
  ],

  branch(title: [قاعدة الإشارات], icon: ic(rgb("#B56576"), [±]))[
    إشارتان متماثلتان تعطيان $+$، ومختلفتان تعطيان $-$.
  ],

  branch(title: [أخطاء شائعة], icon: ic(rgb("#8E44AD"), [!]))[
    الخلط بين $-3^2 = -9$ و $(-3)^2 = 9$.
  ],
)
