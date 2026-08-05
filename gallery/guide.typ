// gallery/guide.typ — the illustrated manual.
//
// Laid out after `visual-tikz`: every option is SHOWN, with the code that
// made the picture beside it. A parameter you cannot see the effect of is
// a parameter nobody will use.
#import "../lib.typ": *

#set page(width: 21cm, height: 29.7cm, margin: (x: 1.6cm, y: 1.5cm),
  fill: white, numbering: "1", number-align: center)
#set text(font: ("New Computer Modern",), size: 9.5pt)
#set par(justify: true, leading: 0.62em)
#show raw: set text(font: "DejaVu Sans Mono", size: 0.84em)
#show heading.where(level: 1): it => {
  v(0.5em); text(size: 1.5em, weight: "bold", fill: rgb("#0B3C7A"), it.body)
  v(0.15em); line(length: 100%, stroke: 1pt + rgb("#0B3C7A")); v(0.4em)
}
#show heading.where(level: 2): it => {
  v(0.45em); text(size: 1.1em, weight: "bold", fill: rgb("#1F5FA8"), it.body)
  v(0.2em)
}

/// One entry: the picture on the left, its code on the right.
// The picture is scaled to fit its column. A mind map sizes itself to its
// contents, so a demo with twelve branches is simply wider than the page —
// `scale` with `reflow: true` shrinks it and gives back the space.
// The code shown is COMPLETE and compiles as it stands, preamble included.
// An excerpt with `..` in it is quicker to write and useless to the reader:
// they cannot paste it anywhere.
#let preamble = "#import \"@preview/sprig:0.1.0\": *
#set page(width: auto, height: auto, margin: 1cm)
#set text(font: \"New Computer Modern\", size: 10pt)

"

#let demo(code, pic, ratio: 0.46, s: 62%, full: true) = block(width: 100%,
  breakable: false, above: 0.6em, below: 0.9em,
  grid(columns: (ratio * 100%, 1fr), column-gutter: 0.5cm, align: horizon,
    align(center, scale(s, reflow: true, pic)),
    block(fill: rgb("#F5F3EE"), inset: 7pt, radius: 3pt, width: 100%,
      raw(if full { preamble + code } else { code }, lang: "typ"))))

#let note(t) = block(width: 100%, inset: (left: 8pt), above: 0.4em,
  below: 0.7em, stroke: (left: 2pt + rgb("#C9A227")),
  text(size: 0.94em, style: "italic", t))

#align(center, {
  v(1.5cm)
  text(size: 30pt, weight: "bold", font: "DejaVu Sans Mono")[sprig]
  v(0.1em)
  text(size: 14pt, font: "DejaVu Sans Mono")[#emoji.hand.write  FERGOUS Abdelhak]
  v(0.2em)
  text(size: 13pt, style: "italic")[des cartes mentales pour Typst]
  v(0.8em)
  block(width: 80%, text(size: 10pt)[
    Un moyeu, des branches qui en sortent, une carte au bout de chacune.
    Le moyeu est un polygone qui a *exactement autant de côtés qu'il y a de
    branches*, et chaque branche part du *milieu de son propre côté* — la
    tige rencontre donc une arête bien à plat.
  ])
  v(0.6em)
  text(size: 9pt, fill: rgb("#666"))[version 0.1.0 · licence MIT · sans
  aucune dépendance]
})

#v(0.8cm)
#align(center, image("cover.png", width: 100%))

#pagebreak()

= Prise en main

Une carte tient en un appel. Le moyeu vient en premier, les branches
ensuite ; tout le reste a une valeur par défaut raisonnable.

#demo("#mindmap([*Le verbe*],
  branch(title: [Groupe])[1ᵉʳ, 2ᵉ, 3ᵉ.],
  branch(title: [Temps])[Simples, composés.],
  branch(title: [Mode])[Indicatif, subjonctif.],
  branch(title: [Voix])[Active, passive.],
)",
  mindmap([*Le verbe*], leaf-width: 2.9, weight: 1pt,
    branch(title: [Groupe])[1ᵉʳ, 2ᵉ, 3ᵉ.],
    branch(title: [Temps])[Simples, composés.],
    branch(title: [Mode])[Indicatif, subjonctif.],
    branch(title: [Voix])[Active, passive.]))

#note[
  *Les codes de ce guide sont complets* : copiez-les tels quels, ils
  compilent. Seul le nom du paquet est à ajuster si vous travaillez depuis
  une copie locale.
]

== Les dimensions

#demo("#mindmap([Cycle],
  // leaf-width est un MAXIMUM :
  // chaque carte se réduit à son texte
  leaf-width: 4.6,
  min-width: 1.5,
  branch(title: [Pluie])[Bref.],
  branch(title: [Condensation])[Un texte
    nettement plus long qui, lui, se
    replie sur plusieurs lignes.],
  branch(title: [Neige])[Court.])",
  mindmap([*Cycle*], weight: 1pt,
    branch(title: [Pluie])[Bref.],
    branch(title: [Condensation])[Un texte nettement plus long qui, lui,
      se replie sur plusieurs lignes.],
    branch(title: [Neige])[Court.]))

#note[
  `leaf-width` est un *maximum*, pas une taille imposée : le texte est
  mesuré sans repli et la carte prend la plus petite des deux largeurs.
  C'est ce qui évite qu'un mot seul reçoive 4,6 cm et soit coupé en deux.
  `min-width` empêche l'inverse — des cartes minuscules et inégales.

  Le moyeu suit la même règle, mais il est inscrit dans une *ellipse* et
  non dans un cercle : une ligne de texte est presque toujours plus large
  que haute, alors qu'un cercle grandit dans les deux sens à la fois — il
  faudrait le rendre haut pour loger une ligne large, et toute cette
  hauteur serait vide. Les deux demi-axes suivent les proportions du texte.
  `hub-round: true` rend le moyeu circulaire d'autrefois.
]

#demo("#mindmap([Missing Data Handling],
  ..range(5).map(i => branch[·]))

#mindmap([Missing Data Handling],
  hub-round: true,     // l'ancien moyeu
  ..range(5).map(i => branch[·]))",
  grid(columns: 2, column-gutter: 4pt, align: horizon,
    mindmap([*Missing Data Handling*], leaf-width: 1.5, weight: 0.9pt,
      ..range(5).map(i => branch[·])),
    mindmap([*Missing Data Handling*], leaf-width: 1.5, weight: 0.9pt,
      hub-round: true, ..range(5).map(i => branch[·]))))

#note[
  Quatre branches, quatre côtés. La distance des feuilles est calculée à
  partir de leur nombre : elles se partagent un cercle, donc chacune reçoit
  #raw("2π·dist/n") d'arc et elles se chevaucheraient dès que c'est plus
  étroit qu'une carte. Rien à régler tant que le résultat convient.
]

= Le moyeu

== `sides` — la règle, et comment s'en écarter

#demo("// autant de côtés que de branches
#mindmap([6],
  ..range(6).map(i => branch[·]))

// ou un nombre imposé :
#mindmap([6], sides: 3,
  ..range(6).map(i => branch[·]))",
  grid(columns: 3, column-gutter: 3pt,
    ..(3, 6, 9).map(k => mindmap([#k], leaf-width: 1.5, weight: 0.8pt,
      ..range(k).map(i => branch[·])))))

== `hub-shape` — une forme libre

Le compte de côtés est la règle par défaut, pas une contrainte. Un
rectangle avec douze branches est un schéma parfaitement légitime.

#demo("#mindmap([12 branches\\ un rectangle],
  hub-shape: \"rounded\", hub-ratio: 1.9,
  ..range(12).map(i => branch[·]))

// \"box\" \"rounded\" \"circle\"
// \"ellipse\" · n · (r, ph) => pts",
  mindmap([*12 branches\ un rectangle*], leaf-width: 2.0, weight: 0.9pt,
    hub-shape: "rounded", hub-ratio: 1.9, radius: 1.8,
    ..range(12).map(i => branch[·])))

#note[
  Avec une forme libre, l'apothème ne veut plus rien dire : le pied de
  chaque tige est l'*intersection du rayon avec le contour*. Approcher un
  rectangle par son cercle inscrit laissait les tiges flotter dans les
  coins.
]

== La couleur du moyeu

#demo("#mindmap([a], hub-fill: rgb(\"#7A1F3D\"),
  ..range(5).map(i => branch[·]))

#mindmap([b], palette: \"warm\",
  hub-fill: \"palette\",
  ..range(5).map(i => branch[·]))

#mindmap([c], hub-fill: rgb(\"#EFE7D2\"),
  hub-ink: rgb(\"#B9A77A\"),
  ..range(5).map(i => branch[·]))",
  grid(columns: 3, column-gutter: 3pt,
    mindmap([a], leaf-width: 1.5, weight: 0.8pt,
      hub-fill: rgb("#7A1F3D"), ..range(5).map(i => branch[·])),
    mindmap([b], leaf-width: 1.5, weight: 0.8pt, palette: "warm",
      hub-fill: "palette", ..range(5).map(i => branch[·])),
    mindmap([c], leaf-width: 1.5, weight: 0.8pt,
      hub-fill: rgb("#EFE7D2"), hub-ink: rgb("#B9A77A"),
      ..range(5).map(i => branch[·]))))

#note[
  Le texte du moyeu suit la *luminance du fond* : au-delà de 58 % de clarté
  il passe en sombre tout seul. Du blanc sur un moyeu clair serait
  invisible.
]

= Les feuilles

== `shape` — quinze contours

#demo("#mindmap([tag], shape: \"tag\",
  ..range(3).map(i => branch[·]))

// round sharp pill tag shield
// cloud banner wave note folder
// hex arrow bubble cut torn
// ou (w, h, r) => pts",
  grid(columns: 4, column-gutter: 2pt, row-gutter: 2pt,
    ..("round", "sharp", "pill", "tag", "shield", "cloud", "banner", "wave",
       "note", "folder", "hex", "arrow", "bubble", "cut", "torn")
      .map(sh => mindmap([#raw(sh)], leaf-width: 1.6, shape: sh,
        weight: 0.8pt, ..range(3).map(i => branch[·])))),
  ratio: 0.56)

== `palette` — six jeux, ou le vôtre

#demo("#mindmap([cool], palette: \"cool\",
  ..range(4).map(i => branch[·]))

#mindmap([perso],
  palette: (red, blue, green),
  ..range(4).map(i => branch[·]))

// poster · warm · cool
// pastel · ink · mono",
  grid(columns: 3, column-gutter: 2pt, row-gutter: 2pt,
    ..("poster", "warm", "cool", "pastel", "ink", "mono").map(p =>
      mindmap([#raw(p)], leaf-width: 1.5, palette: p, weight: 0.8pt,
        ..range(4).map(i => branch[·])))),
  ratio: 0.5)

== `weight` et `tint`

#demo("#mindmap([0pt], weight: 0pt,
  ..range(4).map(i => branch[·]))

#mindmap([2.5], weight: 2.5pt,
  ..range(4).map(i => branch[·]))

#mindmap([30%], tint: 30%,
  ..range(4).map(i => branch[·]))",
  grid(columns: 3, column-gutter: 3pt,
    mindmap([0pt], leaf-width: 1.5, weight: 0pt,
      ..range(4).map(i => branch[·])),
    mindmap([2.5], leaf-width: 1.5, weight: 2.5pt,
      ..range(4).map(i => branch[·])),
    mindmap([30%], leaf-width: 1.5, tint: 30%, weight: 0.8pt,
      ..range(4).map(i => branch[·]))))

= Les branches

== `stalk`, `wave`, `bend`

#demo("#mindmap([0], wave: 0,          // droites
  ..range(5).map(i => branch[·]))

#mindmap([.09], wave: 0.09,      // ondulées
  ..range(5).map(i => branch[·]))

#mindmap([.7], stalk: 0.7,       // épaisses
  ..range(5).map(i => branch[·]))

#mindmap([.18], bend: 0.18,      // cambrées
  ..range(5).map(i => branch[·]))",
  grid(columns: 4, column-gutter: 2pt,
    mindmap([0], leaf-width: 1.4, wave: 0.0, weight: 0.8pt,
      ..range(5).map(i => branch[·])),
    mindmap([.09], leaf-width: 1.4, wave: 0.09, weight: 0.8pt,
      ..range(5).map(i => branch[·])),
    mindmap([.7], leaf-width: 1.4, stalk: 0.7, weight: 0.8pt,
      ..range(5).map(i => branch[·])),
    mindmap([.18], leaf-width: 1.4, bend: 0.18, weight: 0.8pt,
      ..range(5).map(i => branch[·]))),
  ratio: 0.54)

#note[
  Les bords d'une tige suivent la *tangente locale*, pas la corde : les
  décaler selon la normale de la droite pince la tige à l'intérieur d'un
  virage. Et l'ondulation est amortie par #raw("sin(π·t)"), nulle aux deux
  bouts — la racine doit quitter le moyeu bien d'équerre.
]

== `start` et `spread`

#demo("#mindmap([en haut],
  start: -90deg,     // vers le bas
  spread: 170deg,    // en éventail
  radius: 1.2,
  ..range(5).map(i =>
    branch(title: [B] + str(i + 1))[·]))",
  mindmap([*en haut*], leaf-width: 2.2, weight: 0.9pt, radius: 1.2,
    start: -90deg, spread: 170deg,
    ..range(5).map(i => branch(title: [B#(i+1)])[·])))

== `dist`, `dx`, `dy` — placer une feuille à la main

#demo("#mindmap([niveaux],
  start: -90deg, spread: 165deg,
  radius: 1.1, wave: 0.02,
  branch(title: [1], dist: 3.6, dy: 0.4)[·],
  branch(title: [2], dist: 3.6, dy: -0.5)[·],
  branch(title: [3], dist: 3.6, dy: 0.5)[·],
  branch(title: [4], dist: 3.6, dy: -0.5)[·],
  branch(title: [5], dist: 3.6, dy: 0.4)[·])",
  mindmap([*niveaux*], leaf-width: 2.2, weight: 0.9pt, radius: 1.1,
    start: -90deg, spread: 165deg, wave: 0.02,
    branch(title: [1], dist: 3.6, dy: 0.4)[·],
    branch(title: [2], dist: 3.6, dy: -0.5)[·],
    branch(title: [3], dist: 3.6, dy: 0.5)[·],
    branch(title: [4], dist: 3.6, dy: -0.5)[·],
    branch(title: [5], dist: 3.6, dy: 0.4)[·]))

== `at` — par point cardinal

#demo("#mindmap([compas],
  branch(title: [N], at: \"north\")[·],
  branch(title: [SE], at: \"se\")[·],
  branch(title: [O], at: \"ouest\")[·],
  branch(title: [S], at: \"south\")[·])

// north south east west + les
// diagonales, abrégées (n, sw)
// ou en français (nord, sud-est)",
  mindmap([*compas*], leaf-width: 2.0, weight: 0.9pt,
    branch(title: [N], at: "north")[·],
    branch(title: [SE], at: "se")[·],
    branch(title: [O], at: "ouest")[·],
    branch(title: [S], at: "south")[·]))

= Les sous-feuilles

Une feuille devient un moyeu à son tour.

#demo("#mindmap([Grammaire],
  branch(title: [Le nom], children: (
    branch[commun], branch[propre],
  ))[·],
  branch(title: [Le verbe], children: (
    branch[action], branch[état],
  ))[·],
  branch(title: [L'adjectif])[·])",
  mindmap([*Grammaire*], leaf-width: 2.4, weight: 0.9pt,
    branch(title: [Le nom], children: (
      branch[commun], branch[propre],
    ))[·],
    branch(title: [Le verbe], children: (
      branch[action], branch[état],
    ))[·],
    branch(title: [L'adjectif])[·]))

#note[
  L'éventail est centré sur la *direction du parent vu du moyeu* : les
  enfants s'ouvrent vers l'extérieur et une sous-branche ne revient jamais
  sur la carte. `children-at` vise un point cardinal à la place, `spread`,
  `child-dist` et `child-width` règlent l'écartement.
]

= Direction et impression

== `dir` — droite-à-gauche

#demo("#set text(font: \"DejaVu Sans\",
  lang: \"ar\", dir: rtl)

#mindmap([عربي],       // sens détecté
  branch(title: [واحد])[نص.],
  branch(title: [اثنان])[نص.],
  branch(title: [ثلاثة])[نص.])

// ou explicitement : dir: rtl",
  {
    set text(font: ("DejaVu Sans",), size: 8pt, lang: "ar", dir: rtl)
    mindmap([*عربي*], leaf-width: 2.2, weight: 0.9pt,
      branch(title: [واحد])[نص.],
      branch(title: [اثنان])[نص.],
      branch(title: [ثلاثة])[نص.])
  })

#note[
  En RTL les branches tournent dans le sens antihoraire, si bien que
  l'ordre de lecture court de droite à gauche autour de la carte.
]

== `theme: "print"`

#demo("#mindmap([print], theme: \"print\",
  ..range(5).map(i => branch[·]))",
  grid(columns: 2, column-gutter: 4pt,
    mindmap([couleur], leaf-width: 1.9, weight: 0.9pt,
      ..range(5).map(i => branch[·])),
    mindmap([print], leaf-width: 1.9, weight: 0.9pt, theme: "print",
      ..range(5).map(i => branch[·]))))

#note[
  Les couleurs ne sont pas désaturées mais *retirées* : un aplat gris coûte
  encore de l'encre et grise le texte. Et la tige s'amincit d'un tiers —
  une aire noire pèse bien plus qu'une aire colorée de même taille.
]

== `rough` — le mode dessiné

#demo("#mindmap([1.0], rough: true,
  ..range(5).map(i => branch[·]))

#mindmap([2.0], rough: true,
  roughness: 2.0,
  ..range(5).map(i => branch[·]))",
  grid(columns: 2, column-gutter: 4pt,
    mindmap([1.0], leaf-width: 1.9, weight: 0.9pt, rough: true,
      ..range(5).map(i => branch[·])),
    mindmap([2.0], leaf-width: 1.9, weight: 0.9pt, rough: true,
      roughness: 2.0, ..range(5).map(i => branch[·]))))

== `icon` — une pastille sur la carte

#demo("#mindmap([Méthode],
  branch(title: [Comprendre],
    icon: text(fill: red)[★])[·],
  branch(title: [Chercher],
    icon: text(fill: blue)[◆])[·],
  branch(title: [Calculer],
    icon: text(fill: green)[▲])[·],
  branch(title: [Vérifier],
    icon: text(fill: purple)[●])[·])",
  mindmap([*Méthode*], leaf-width: 2.4, weight: 0.9pt,
    branch(title: [Comprendre], icon: text(fill: rgb("#C0392B"))[★])[·],
    branch(title: [Chercher], icon: text(fill: rgb("#2980B9"))[◆])[·],
    branch(title: [Calculer], icon: text(fill: rgb("#27AE60"))[▲])[·],
    branch(title: [Vérifier], icon: text(fill: rgb("#8E44AD"))[●])[·]))

#note[
  N'importe quel contenu : un symbole, une émoji, une petite image. L'affiche
  arabe dont ce module est tiré en met une sur chaque carte, et c'est ce qui
  rend une carte chargée lisible d'un coup d'œil.
]

= Un troisième rang

La structure est récursive : un enfant se déclare avec le même `branch(..)`
que son parent, donc il peut avoir ses propres enfants.

#demo("#mindmap([Le mot],
  branch(title: [Le nom], children: (
    branch(title: [commun], children: (
      branch[table], branch[idée])),
    branch(title: [propre], children: (
      branch[Paris],)),
  ))[·],
  branch(title: [Le verbe], children: (
    branch(title: [action], children: (
      branch[courir],)),
    branch[état],
  ))[·],
  branch(title: [L'adjectif])[·])",
  mindmap([*Le mot*], leaf-width: 2.2, weight: 0.9pt,
    branch(title: [Le nom], children: (
      branch(title: [commun], children: (branch[table], branch[idée])),
      branch(title: [propre], children: (branch[Paris],)),
    ))[·],
    branch(title: [Le verbe], children: (
      branch(title: [action], children: (branch[courir],)),
      branch[état],
    ))[·],
    branch(title: [L'adjectif])[·]))

#note[
  Chaque petit-enfant s'évente autour de son propre parent, sur la direction
  que ce parent a par rapport au sien : l'arbre s'ouvre toujours vers
  l'extérieur et ne se replie jamais sur lui-même. Un `branch(title: [x])`
  sans corps est accepté — dans un arbre, un nœud n'est souvent qu'une
  étiquette.
]

= Les liens transverses

Une carte mentale est un arbre ; les idées qu'elle porte le sont rarement.
`link` trace l'association sans casser la hiérarchie.

#demo("#mindmap([Cycle de l'eau],
  links: (
    link(0, 1, label: [provoque]),
    link(1, 2, label: [donne]),
    link(3, 0, via: \"inside\"),
  ),
  branch(title: [Évaporation])[·],
  branch(title: [Condensation])[·],
  branch(title: [Précipitations])[·],
  branch(title: [Ruissellement])[·])",
  mindmap([*Cycle de l'eau*], leaf-width: 2.4, weight: 0.9pt,
    links: (
      link(0, 1, label: [provoque]),
      link(1, 2, label: [donne]),
      link(3, 0, via: "inside"),
    ),
    branch(title: [Évaporation])[·],
    branch(title: [Condensation])[·],
    branch(title: [Précipitations])[·],
    branch(title: [Ruissellement])[·]))

#note[
  Le trait est pointillé et il passe *par-dessus* les cartes : il se lit
  comme une annotation, pas comme une partie du squelette. `via: "inside"`
  le fait passer côté moyeu, `bend` règle la courbure, `arrow: false`
  enlève la pointe.
]

= Une disposition imposée : `mindgrid`


Quand les cartes doivent rester en grille, `mindgrid` prend le relais. Les
branches passent *derrière* les cartes qu'elles rencontrent — le trait se
comprend comme continuant dessous, ce que fait tout schéma à la main.

#demo("#mindgrid([Hub],
  cols: 3, cell: 2.0, cell-h: 0.9,
  gap-x: 0.9, gap-y: 0.7,
  hub-x: 0, hub-y: 2.9, radius: 0.75,
  ..range(9).map(i =>
    node[#(i + 1)]))",
  mindgrid([*Hub*], cols: 3, cell: 2.0, cell-h: 0.9,
    gap-x: 0.9, gap-y: 0.7, hub-x: 0, hub-y: 2.9, radius: 0.75,
    ..range(9).map(i => node[#(i+1)])))

#note[
  `route: true` calcule à la place un vrai contournement, sur un graphe de
  visibilité : aucune branche ne croise plus une carte, au prix de longs
  détours. Les deux se défendent — le premier est plus fluide, le second
  plus rigoureux.

  La *largeur* des cellules reste fixe, c'est tout l'objet d'une grille ;
  la hauteur, elle, suit le contenu de chaque carte.
]

= Trois cartes entières

Les pages qui précèdent montrent chaque réglage isolément. Voici trois
cartes complètes, chacune dans un genre différent — c'est le choix des
réglages *ensemble* qui fait le style, bien plus que chaque option prise à
part.

Les trois vivent dans `examples/`. La page ci-dessous *lit ces fichiers* :
le code imprimé et l'image sont le même fichier, ils ne peuvent pas
diverger. Chaque carte est reproduite en entier — c'est bien tout le
document, préambule compris.

#pagebreak()

// One page per map: the picture on top, the file that made it underneath.
// These maps are all much wider than they are tall, so the picture is
// bounded by the WIDTH — giving it a page of its own would only add white
// space, and the code belongs next to it anyway.
#let showcase(file, pdf, title, why) = {
  heading(level: 2, title)
  note(why)
  align(center, image(pdf, width: 100%))
  v(0.5em)
  block(fill: rgb("#F5F3EE"), inset: 7pt, radius: 3pt, width: 100%,
    raw(read(file), lang: "typ"))
  pagebreak(weak: true)
}

#showcase("../examples/typst.typ", "../examples/typst.pdf",
  [Typst, en français], [
    Genre *aide-mémoire technique* : moyeu en boîte arrondie plutôt qu'en
    polygone, feuilles `note`, palette `cool`, ondulation ramenée à 0,018 —
    presque des droites. Une carte de code n'a pas à onduler comme une
    affiche de classe. Le second rang porte les mots-clés nus, sans cadre
    de titre : dans un arbre, un nœud n'est souvent qu'une étiquette.
  ])

#showcase("../examples/relatifs-ar.typ", "../examples/relatifs-ar.pdf",
  [Les nombres relatifs, en arabe], [
    Genre *affiche de classe* : palette `warm`, feuilles en bulles, tiges
    larges et franchement ondulées, une icône par carte. `dir: rtl` suffit
    à faire tourner la carte dans l'autre sens.

    Deux détails qui comptent. Les chiffres restent *occidentaux* — c'est
    l'usage au Maghreb, et Typst ne les convertit pas tout seul. Et les
    formules sont remises en `dir: ltr` par une règle `show`, sinon
    #raw("(-12)/(+3) = -4") se lirait à l'envers.
  ])

#showcase("../examples/grammar-en.typ", "../examples/grammar-en.pdf",
  [La grammaire anglaise], [
    Genre *carnet* : `rough: true`, palette `ink`, feuilles `torn`, moyeu
    circulaire. Sept branches et un second rang complet, donc `dist` est
    relevé à la main : la distance calculée d'office tient compte des
    cartes du premier rang, pas de la couronne d'enfants qui les entoure.
    C'est délibéré — sinon une carte à trois rangs partirait très loin pour
    rien — mais il faut le savoir.
  ])

= Référence

#block(fill: rgb("#F5F3EE"), inset: 9pt, radius: 3pt, width: 100%,
  text(size: 8.5pt)[
    *`mindmap(hub, ..branches, …)`* \
    `sides` `hub-shape` `hub-ratio` `radius` `leaf-width` `dist` `palette`
    `theme` `shape` `weight` `hub-fill` `hub-ink` `hub-text` `leaf-fill`
    `leaf-ink` `tint` `stalk` `stalk-tip` `bend` `wave` `waves` `start`
    `hub-round` `min-width` `spread` `phase` `radius-leaf` `gap` `shadow` `dir` `size` `seed`
    `rough` `hand` `roughness` `bowing` `links`
    #v(0.4em)
    *`branch(body, …)`* \
    `title` `icon` `colour` `shape` `angle` `at` `dist` `width` `dx` `dy`
    `children` `children-at` `spread` `child-dist` `child-width`
    #v(0.4em)
    *`link(from, to, …)`* — `label` `colour` `dash` `arrow` `bend` `via`
    #v(0.4em)
    *`mindgrid(hub, ..nodes, …)`* \
    `cols` `rows` `cell` `cell-h` `gap-x` `gap-y` `hub-at` `hub-x` `hub-y`
    `route` `clearance` — plus les réglages communs ci-dessus
    #v(0.4em)
    *`node(body, …)`* \
    `title` `icon` `colour` `shape` `width` `col` `row` `x` `y` `side`
    #v(0.4em)
    *Tables* — `sprig-palettes` `sprig-shapes` `sprig-compass`
  ])
