// blockst — showcase français / arabe, en couleur et en niveaux de gris.
//
// Compilation :
//
//     typst compile examples/showcase-rtl.typ
//
// Les polices arabes sont décrites dans README-rtl.md.

#import "@preview/blockst:0.3.0": blockst, scratch
#import "showcase-data.typ": programs, catalogue

#set page(
  paper: "a4",
  flipped: true,
  margin: (x: 14mm, y: 15mm),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: rgb("#666"))
      grid(
        columns: (1fr, auto),
        align: (left, right),
        [blockst — Scratch en français et en arabe],
        [niveaux de gris et couleur],
      )
      v(-3mm)
      line(length: 100%, stroke: 0.4pt + rgb("#ccc"))
    }
  },
  footer: context {
    set text(size: 8pt, fill: rgb("#666"))
    align(center)[#counter(page).display("1")]
  },
)

// La police du DOCUMENT, pour les titres et le texte courant.
#set text(size: 9pt, lang: "fr")

// La police des BRIQUES est une autre affaire.
//
// Le paquet mesure chaque étiquette avec Typst, puis inscrit la police
// choisie dans le SVG. Un `#set text(font: ...)` global ne touche que le
// second : les largeurs restent mesurées dans la police par défaut alors
// que le tracé emploie la nouvelle, et les mots se chevauchent
// (« quand⚑estcliqué »). Il faut donc passer par l'option `font` du paquet,
// qui sert aux deux étapes.
//
// On la passe à chaque appel plutôt que par `set-blockst`, dont la mise à
// jour d'état empêche la mise en page de converger sur un document de
// plusieurs pages — un défaut amont, reproductible sur le paquet publié
// en anglais sans aucune modification.
#let BLOCK-FONT = "DejaVu Sans"

#show heading.where(level: 1): it => {
  set text(size: 15pt, weight: "bold")
  block(above: 0pt, below: 4mm, sticky: true, it.body)
}

#show heading.where(level: 2): it => {
  set text(size: 11pt, weight: "bold", fill: rgb("#333"))
  block(above: 5mm, below: 2.5mm, sticky: true)[
    #it.body
    #v(-2mm)
    #line(length: 100%, stroke: 0.6pt + rgb("#999"))
  ]
}

// A caption above a rendered block.
#let tag(body, color: rgb("#777")) = text(size: 7.5pt, fill: color, body)

// One example, rendered four ways: FR/AR × couleur/gris.
//
// The rendered blocks are an SVG image, and an image stretches to whatever
// width it is given. Putting one in a `block(width: 100%)` or in a `1fr`
// grid track squashes a long block like « glisser en (1) secondes à x… »
// down to the column width, which is why the cells are `auto`-sized and the
// script is wrapped in a left-aligned box that does not impose its width.
#let piece(code, lang, theme, size) = box(
  inset: (x: 1.5mm, y: 1mm),
  scratch(code, language: lang, theme: theme, scale: size, font: BLOCK-FONT),
)

// Stacked 2×2 — compact, for the short blocks of the catalogue.
#let quad(fr-code, ar-code, size: 62%) = grid(
  columns: (1fr, 1fr),
  column-gutter: 3mm,
  row-gutter: 1mm,
  align: (left + top, right + top),
  piece(fr-code, "fr", "normal", size), piece(ar-code, "ar", "normal", size),
  piece(fr-code, "fr", "grayscale", size), piece(ar-code, "ar", "grayscale", size),
)

// Four across — for whole programs.
//
// Stacking colour over grey doubles the height, and the tallest script here
// is 398pt at 62%: two of those need ~800pt where an A4 landscape page
// offers about 510pt, so the unbreakable block had nowhere to land and left
// the page empty. Side by side each program stays one row tall.
#let row4(fr-code, ar-code, size: 52%) = grid(
  columns: (auto, auto, auto, auto),
  column-gutter: 4mm,
  align: (left + top, left + top, right + top, right + top),
  piece(fr-code, "fr", "normal", size),
  piece(fr-code, "fr", "grayscale", size),
  piece(ar-code, "ar", "normal", size),
  piece(ar-code, "ar", "grayscale", size),
)

// ===========================================================================

#align(center)[
  #v(2cm)
  #text(size: 26pt, weight: "bold")[blockst]
  #v(3mm)
  #text(size: 14pt)[Scratch en français et en arabe]
  #v(2mm)
  #text(size: 11pt, fill: rgb("#555"))[
    rendu bidirectionnel · thèmes couleur et niveaux de gris
  ]
  #v(1.5cm)
  #block(width: 62%)[
    #set text(size: 9.5pt)
    #set par(justify: true)
    Ce document rend chaque exemple quatre fois : en français et en arabe,
    puis en couleur et en niveaux de gris. Les deux colonnes d'une même ligne
    sont le même programme, si bien qu'un bloc absent d'une locale se
    remarque comme un manque et non comme un exemple différent.

    Les scripts complets reprennent ceux de la documentation #emph[ProfCollege];
    le catalogue en reprend l'ordre des catégories.
  ]
  #v(1cm)
  #block(
    width: 62%,
    inset: 4mm,
    stroke: 0.5pt + rgb("#bbb"),
    radius: 2pt,
  )[
    #set text(size: 8.5pt)
    #set align(left)
    En arabe la disposition est inversée dans son entier : l'encoche,
    le dôme du chapeau, la bouche des blocs-C, la flèche de boucle et
    l'ordre des étiquettes passent tous du côté de la lecture. Les icônes
    #emph[tourner à droite] et #emph[tourner à gauche] ne sont
    #emph[jamais] miroitées — leur direction est ce que le lutin doit
    faire, pas une affaire de mise en page.
  ]
]

#pagebreak()

= Scripts complets

#v(-2mm)

#for p in programs {
  block(breakable: false, width: 100%, below: 6mm)[
    #text(size: 10pt, weight: "bold")[#p.title]
    #v(1mm)
    #grid(
      columns: (auto, auto, auto, auto),
      column-gutter: 4mm,
      row-gutter: 0.8mm,
      tag[français · couleur], tag[français · gris],
      tag[العربية · couleur], tag[العربية · gris],
      grid.cell(colspan: 4, row4(p.fr, p.ar)),
    )
  ]
}

#pagebreak()

= Catalogue des briques

#for cat in catalogue [
  == #cat.name

  // Three columns of `auto` width let one long Arabic block — « انزلق خلال
  // (1) ثانية… » — push the whole row past the right margin. Two columns of
  // a fixed share keep every row inside the page, and the blocks are still
  // laid out at their natural size inside each half.
  #let rows = cat.blocks.map(b => block(breakable: false, width: 100%)[
    #quad(b.at(0), b.at(1), size: 55%)
  ])

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 6mm,
    row-gutter: 2mm,
    align: left + top,
    ..rows,
  )
]

#pagebreak()

= Les trois thèmes

#let sample-fr = "quand @greenFlag est cliqué
avancer de (10) pas
répéter (4) fois
tourner @turnRight de (90) degrés
fin
dire [Bonjour !] pendant (2) secondes"

#let sample-ar = "عند نقر @greenFlag
تحرك (10) خطوة
كرِّر (4) مرة
استدر @turnRight (90) درجة
نهاية
قل [مرحبا!] لمدة (2) ثانية"

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 5mm,
  row-gutter: 3mm,
  align: top,
  tag[normal], tag[grayscale], tag[print],
  scratch(sample-fr, language: "fr", scale: 70%, font: BLOCK-FONT),
  scratch(sample-fr, language: "fr", theme: "grayscale", scale: 70%, font: BLOCK-FONT),
  scratch(sample-fr, language: "fr", theme: "print", scale: 70%, font: BLOCK-FONT),
  scratch(sample-ar, language: "ar", scale: 70%, font: BLOCK-FONT),
  scratch(sample-ar, language: "ar", theme: "grayscale", scale: 70%, font: BLOCK-FONT),
  scratch(sample-ar, language: "ar", theme: "print", scale: 70%, font: BLOCK-FONT),
)

#v(8mm)

#block(inset: 4mm, stroke: 0.5pt + rgb("#bbb"), radius: 2pt, width: 100%)[
  #set text(size: 8.5pt)
  *Pourquoi deux thèmes monochromes ?*
  #v(1.5mm)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 6mm,
    [
      *print* rend toutes les briques blanches à contour noir. C'est ce que
      fait la clé `[Impression]` de ProfCollege, et c'est le plus économe à
      l'impression — mais toutes les catégories se ressemblent.
    ],
    [
      *grayscale* donne à chaque catégorie son propre gris. Une conversion
      naïve par luminance ne suffisait pas : #emph[Listes] et #emph[Mouvement]
      tombent sur le même gris, #emph[Stylo] et #emph[Capteurs] aussi. L'échelle
      est donc attribuée, onze pas réguliers de 96 à 232.
    ],
  )
]
