// ===========================================================================
//  examples/lace.typ — the guilloche line families and the lacebox.
//
//    typst compile examples/lace.typ --root .
//
//  Three covers drawing the same plate with three other lace families,
//  then the lacebox frames in hand-drawn (rough) mode, and the pgfornament
//  ornaments seated in the corners.
// ===========================================================================

#import "@preview/faboxyst:0.2.0": *

#set page(paper: "a4", margin: 1.5cm)

// 1. engine-turned barleycorn under an Arabic philosophy plate
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "guilloche",
  lace: "engine",
  series: [سلسلة الفكر],
  title: [فلسفة اللغة],
  subtitle: [من الدالّ إلى المعنى],
  author: [د. ليلى مرابط],
  year: [2026],
  publisher: [دار المعاني],
  place-line: [الطبعة الثانية المنقّحة],
)

// 2. moiré rings under a French poetry anthology
#pagebreak()
#set text(dir: ltr, lang: "fr")
#book-cover(
  style: "guilloche",
  lace: "moire",
  series: [CAHIERS DE POÉSIE],
  title: [L'ENCRE ET LE VENT],
  subtitle: [Anthologie des rives sud],
  author: [Choisis par N. Djian],
  year: [2026],
  publisher: [PRESSES DU LARGE],
  place-line: [édition bilingue enrichie],
)

// 3. woven braid under an Arabic history plate
#pagebreak()
#set text(dir: rtl, lang: "ar")
#book-cover(
  style: "guilloche",
  lace: "braid",
  series: [سلسلة الذاكرة],
  title: [حواضر البحر],
  subtitle: [موانئ المتوسط عبر العصور],
  author: [أ. محمود زناد],
  year: [2025],
  publisher: [مؤسسة السرد],
  place-line: [خرائط ووثائق نادرة],
)

// 4. the lacebox frame: `band` sets the border's width — here in rough mode
#pagebreak()
#set text(dir: ltr, lang: "fr")
#lacebox(
  title: [Bordure 0,5 cm],
  lace: "moire",
  band: 0.5cm,
  colour: rgb("#14424B"),
  rough: 1.2,
)[
  #raw("band") est la largeur du cadre de dentelle : ici un demi-centimètre,
  un simple filet guilloché autour du panneau.
]

#v(0.6cm)
#lacebox(
  title: [Bordure 1,15 cm],
  lace: "moire",
  colour: rgb("#14424B"),
  rough: 1.2,
)[
  La valeur par défaut : assez de dentelle pour lire le motif sans
  écraser le corps du texte.
]

#v(0.6cm)
#lacebox(
  title: [Bordure 2 cm],
  lace: "moire",
  band: 2cm,
  colour: rgb("#14424B"),
  rough: 1.2,
)[
  Deux centimètres : le cadre devient le sujet de la page, le panneau se
  fait fenêtre. #raw("width") règle la largeur de la boîte elle-même et
  #raw("weight") l'épaisseur du filet extérieur.
]

// 5. the four frame models, all hand-drawn
#pagebreak()
#lacebox(
  title: [Modèle « double »],
  model: "double",
  lace: "engine",
  colour: rgb("#5B2A86"),
  rough: 1.2,
)[
  Un second anneau de dentelle court sous le filet du panneau.
]

#v(0.7cm)
#lacebox(
  title: [Modèle « scallop »],
  model: "scallop",
  lace: "braid",
  colour: rgb("#1B3A2F"),
  rough: 1.2,
)[
  Le bord du panneau ondule en festons, comme une dent de timbre.
]

#v(0.7cm)
#lacebox(
  title: [Modèle « corners »],
  model: "corners",
  lace: "spiral",
  colour: rgb("#8A2A1B"),
  rough: 1.2,
)[
  Plus de bande : un double filet et quatre éventails de rayons et d'arcs
  aux coins.
]

#v(0.7cm)
#set text(dir: rtl, lang: "ar")
#lacebox(
  title: [تمرين 7],
  lace: "engine",
  colour: rgb("#1B3A2F"),
  rough: 1.2,
)[
  بيّن أن تراكيب شبكتين دائريتين متباعدتين بمقدار ثابت يُنتج حزوزًا
  قطعية تبعد عنها بمقدار مضاعف، ثم استنتج موضع الحزمة الأولى.
]

// 6. pgfornament: the engraved ornament bank, and `ornament` corners
#pagebreak()
#set text(dir: ltr, lang: "fr")
#text(size: 9pt, fill: luma(90))[
  Port des 276 ornements du paquet CTAN #raw("pgfornament") (Alain Matthes,
  LPPL 1.3) : 196 vectorian, 78 han, 2 am.
]
#v(0.3cm)
#grid(columns: 8, column-gutter: 6pt, row-gutter: 10pt,
  ..(6, 22, 45, 61, 64, 74, 88, 96, 104, 121, 133, 147, 158, 166, 176, 196)
    .map(i => box(width: 100%, align(center,
      pgfornament(i, width: 1.7cm, paint: rgb("#1B2A41"))))))
#v(0.5cm)
#lacebox(
  title: [Coins ornés],
  lace: "moire",
  colour: rgb("#14424B"),
  rough: 1.2,
  ornament: 64,
)[
  #raw("ornament: 64") assoit le fleuron vectorian 64, miroité, dans les
  quatre coins de la bande — en lieu et place des rosettes.
]

// 7. han family in the corners of a « corners » frame
#pagebreak()
#lacebox(
  title: [Nœud sans fin],
  model: "corners",
  lace: "spiral",
  colour: rgb("#8A2A1B"),
  rough: 1.2,
  ornament: 58,
  ornament-family: "han",
)[
  Le nœud d'éternité de la famille #raw("han") (LIM LianTze) aux quatre
  coins du double filet, lui aussi tracé à main levée.
]

#v(0.7cm)
#grid(columns: 6, column-gutter: 6pt, row-gutter: 10pt,
  ..(13, 26, 40, 52, 63, 78).map(i => box(width: 100%, align(center,
    pgfornament(i, family: "han", width: 1.9cm, paint: rgb("#8A2A1B"))))))
