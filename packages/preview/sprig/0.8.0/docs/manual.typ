// Sprig 0.8.0 — manuel de référence en français.
#import "@preview/sprig:0.8.0": *
#import "@preview/sprig:0.8.0": note as postit

#set page(paper: "a4", margin: (x: 1.65cm, y: 1.5cm), numbering: "1",
  number-align: center)
#set text(font: ("New Computer Modern",), size: 9pt, lang: "fr")
#set par(justify: true, leading: 0.62em)
#show raw: set text(font: "DejaVu Sans Mono", size: 0.82em)

#let ink = rgb("#18324B")
#let blue = rgb("#2463A5")
#let pale = rgb("#EDF3F8")
#let line-col = rgb("#CFD8E2")

#show heading.where(level: 1): it => {
  v(0.5em)
  text(size: 1.5em, weight: "bold", fill: ink, it.body)
  v(0.14em)
  line(length: 100%, stroke: 1pt + blue)
  v(0.35em)
}
#show heading.where(level: 2): it => {
  v(0.4em)
  text(size: 1.12em, weight: "bold", fill: blue, it.body)
  v(0.12em)
}

#let params(..cells) = table(
  columns: (1.15fr, 0.75fr, 3.2fr),
  inset: (x: 0.13cm, y: 0.09cm),
  align: left + horizon,
  stroke: (x, y) => if y == 0 { 0.7pt + blue } else { 0.35pt + line-col },
  fill: (x, y) => if y == 0 { pale } else if calc.even(y) { rgb("#FAFBFC") } else { white },
  ..cells.pos(),
)

#let callout(body) = block(
  width: 100%,
  inset: (x: 0.35cm, y: 0.22cm),
  fill: pale,
  stroke: (left: 2pt + blue),
  radius: 2pt,
  body,
)

#let fit(w, body) = context {
  let m = measure(body)
  if m.width > w { scale(x: (w / m.width) * 100%, reflow: false, body) }
  else { body }
}

#align(center, {
  v(1.4cm)
  image("../gallery/cover.png", width: 12cm)
  v(0.65cm)
  text(size: 31pt, weight: "bold", font: "DejaVu Sans Mono", fill: ink)[SPRIG]
  v(0.2cm)
  text(size: 17pt, fill: blue)[Manuel de référence]
  v(0.5cm)
  text(size: 11pt)[Cartes mentales pour Typst · version 0.8.0]
  v(0.4cm)
  block(width: 12cm, text(size: 9.5pt)[
    Six mises en page, des feuilles mesurées sur leur contenu, des limites
    de dimensions réglables et des contours personnalisables.
  ])
  v(0.4cm)
  text(size: 8.5pt, fill: rgb("#68798A"))[Typst 0.15.0 ou supérieur · licence MIT]
})

#pagebreak()

= Sommaire
#outline(depth: 2)

= Présentation

Sprig dessine six familles de cartes mentales : l’arbre radial `mindmap`, la
fleur `blossom`, la grille routée `mindgrid`, le mur de notes `sticky`, la carte
conceptuelle `tikzmap` et le tracé au feutre `buzan`. Le même contenu peut être
réemployé entre les mises en page grâce aux constructeurs `branch`, `node`,
`note` et `concept`.

La largeur et la hauteur d’une feuille sont calculées à partir de son contenu.
Les contraintes `min-width`, `max-width`, `min-height` et `max-height` se règlent
au niveau de la carte ou feuille par feuille. Une hauteur maximale trop basse
entraîne un ajustement de largeur quand le layout le permet, puis une erreur
explicite plutôt qu’un texte coupé.

== Installation et premier rendu

Une seule importation suffit. Typst Universe télécharge Sprig et sa dépendance
`nibart` au premier rendu; aucune copie de fichier n’est requise.

```typ
#import "@preview/sprig:0.8.0": *

#mindmap([*Le verbe*],
  branch(title: [Groupe])[1ᵉʳ, 2ᵉ, 3ᵉ personnes.],
  branch(title: [Temps])[Simples, composés.],
  branch(title: [Mode])[Indicatif, subjonctif.],
  branch(title: [Voix])[Active, passive.],
)
```

#align(center, fit(16cm, mindmap([*Le verbe*],
  branch(title: [Groupe])[1ᵉʳ, 2ᵉ, 3ᵉ personnes.],
  branch(title: [Temps])[Simples, composés.],
  branch(title: [Mode])[Indicatif, subjonctif.],
  branch(title: [Voix])[Active, passive.],
)))

#callout[
  Sprig demande Typst 0.15.0 ou supérieur. `buzan` utilise `nibart` 0.3.0
  pour les traits à largeur variable. `stroke-engine: "native"` sélectionne le
  moteur intégré. La dépendance `nibart` est résolue à l’import du paquet.
]

= Modèle commun

Les cartes partagent la même grammaire : un moyeu, un ou plusieurs éléments, et
un contenu positionnel. `title` et `icon` enrichissent le contenu; `colour` et
`shape` remplacent les choix du layout.

== `branch(..)`

Utiliser `branch` avec `mindmap`, `blossom` et `buzan`. Le contenu peut être
positionnel (`branch[Texte]`) ou placé après les paramètres nommés
(`branch(title: [Titre])[Texte]`). `children` ajoute des idées filles quand le
layout les prend en charge.

#params(
  [Option], [Défaut], [Rôle],
  [`title`, `icon`], [`none`], [Titre et signe facultatifs de la feuille.],
  [`colour`], [`auto`], [Couleur propre à la branche; `auto` suit la palette.],
  [`shape`], [`auto`], [Contour propre à la feuille, nom de `sprig-shapes` ou fonction.],
  [`width`], [`auto`], [Largeur de texte fixée localement, selon le layout.],
  [`min-width`, `max-width`], [`auto`], [Bornes horizontales de cette feuille.],
  [`min-height`, `max-height`], [`auto`], [Bornes verticales de cette feuille.],
  [`angle`, `at`], [`auto`], [Direction du rameau; `at` accepte les points cardinaux.],
  [`dist`], [`auto`], [Distance au moyeu, en centimètres.],
  [`dx`, `dy`], [`0`], [Décalage fin de la feuille, en centimètres; `dy` est positif vers le haut.],
  [`children`], [`()`], [Sous-branches pour les mises en page hiérarchiques.],
  [`children-at`, `spread`], [`auto`], [Position et éventail des sous-branches.],
  [`child-dist`, `child-width`], [`auto`], [Distance et largeur utilisées par les sous-feuilles.],
)

== Constructeurs des autres layouts

#params(
  [Constructeur], [Paramètres spécifiques], [Usage],
  [`node(body, ..)`], [`col`, `row`, `x`, `y`, `side`], [Feuille de `mindgrid`; placement dans une cellule ou coordonnées absolues.],
  [`note(..args)`], [`number`, `tilt`, `fill`, `width`, bornes], [Feuille de `sticky`; accepte aussi un dictionnaire `node(..)`.],
  [`concept(..args)`], [`children`, `angle`, `dist`, `width`, bornes], [Nœud de `tikzmap`, récursif à toute profondeur.],
  [`link(from, to, ..)`], [`label`, `colour`, `dash`, `arrow`, `bend`, `via`], [Lien croisé de `mindmap`; indices de branches à partir de zéro.],
)

Les dimensions numériques sont exprimées en centimètres. Une longueur Typst
équivalente (`3cm`, `25mm`) est aussi acceptée. Les paramètres de couleur
acceptent une valeur `color` Typst ou une chaîne hexadécimale dans les palettes.

= Dimensions et adaptation

== Limites de feuille

Les quatre paramètres se règlent au niveau d’un layout, puis peuvent être
remplacés sur une branche, un nœud ou une note :

```typ
#mindmap([Hub], min-width: 1.8, max-width: 4.8,
  min-height: 1.0, max-height: 3.8,
  branch(title: [Court], shape: "leaf")[Une phrase.],
  branch(title: [Plus long], shape: "ticket",
    min-width: 2.4, max-width: 4.2,
    min-height: 1.3, max-height: 3.5)[Le texte se replie à la largeur disponible.],
)
```

#align(center, fit(17cm, mindmap([Hub], min-width: 1.8, max-width: 4.8,
  min-height: 1.0, max-height: 3.8,
  branch(title: [Court], shape: "leaf")[Une phrase.],
  branch(title: [Plus long], shape: "ticket",
    min-width: 2.4, max-width: 4.2,
    min-height: 1.3, max-height: 3.5)[Le texte se replie à la largeur disponible.],
)))

#params(
  [Limite], [Effet], [À retenir],
  [`min-width`], [Largeur plancher.], [Évite les feuilles étroites; une valeur supérieure à la largeur maximale est refusée.],
  [`max-width`], [Largeur plafond.], [Le texte s’enroule dans cette largeur; certaines mises en page ajoutent leur propre plafond géométrique.],
  [`min-height`], [Hauteur plancher.], [Ajoute de l’espace intérieur sans agrandir le texte.],
  [`max-height`], [Hauteur plafond.], [Le moteur essaie d’abord d’élargir la colonne de texte; s’il ne peut pas satisfaire les deux limites, il signale l’incompatibilité.],
)

== Défauts par layout

#params(
  [Layout], [`min-width` / `max-width`], [`min-height` / `max-height`],
  [`mindmap`], [`1.5` / `9cm`], [`0` / `auto`],
  [`mindgrid`], [`1.5` / `9cm`], [`0` / `auto`],
  [`sticky`], [`2cm` / `cell`], [`cell-h` par défaut; une note ayant un `max-height` explicite peut être plus basse.],
  [`blossom`], [`1` / plafond géométrique ou `petal-width`], [`0.6` / `auto`],
  [`tikzmap`], [`auto` / `auto`], [`auto` / `auto`; les tables `size` fournissent aussi `min-size` et `text-width`.],
  [`buzan`], [`auto` / `auto`], [`auto` / `auto`],
)

Une contrainte peut être techniquement impossible : par exemple un long mot
insécable, un `max-width` inférieur à `min-width`, ou une hauteur qui ne peut
pas être obtenue même au maximum de largeur. Sprig s’arrête avec un message
explicite au lieu de rogner silencieusement le texte.

= `mindmap` — arbre radial ou étagé

Le moyeu est un polygone dont le nombre de côtés suit le nombre de branches.
`layout: "radial"` dessine l’arbre en anneau; `"both"`, `"right"`, `"left"`,
`"down"` et `"up"` étagent les rangs. Chaque feuille mesure sa propre largeur
et sa propre hauteur; les sous-feuilles peuvent recevoir leur disposition
avec `children-at`, `spread`, `child-dist` et `child-width`.

#params(
  [Option], [Défaut], [Rôle],
  [`leaf-width`], [`auto`], [Largeur commune facultative; `auto` laisse le contenu guider chaque feuille.],
  [`min-width`, `max-width`], [`1.5`, `9`], [Bornes communes, remplaçables sur `branch(..)`.],
  [`min-height`, `max-height`], [`0`, `auto`], [Bornes verticales communes.],
  [`layout`], [`"radial"`], [Disposition radiale, ou `both`, `right`, `left`, `down`, `up`.],
  [`sides`], [`auto`], [Nombre de côtés du moyeu; par défaut un par branche.],
  [`hub-shape`, `hub-ratio`], [`auto`, `1`], [Contour du moyeu et rapport largeur/hauteur.],
  [`dist`, `radius`], [`auto`], [Éloignement des feuilles et rayon du moyeu.],
  [`start`, `spread`, `phase`], [`90°`, `360°`, `0°`], [Angle de départ, étendue et rotation du motif.],
  [`shape`], [`"round"`], [Forme par défaut des feuilles.],
  [`palette`, `theme`], [`"poster"`, `auto`], [Palette; thème `"print"` ou `"poster"` selon l’effet voulu.],
  [`stalk`, `stalk-tip`, `bend`, `wave`, `waves`], [Voir description], [Épaisseur, amincissement, courbure et ondulation des tiges.],
  [`links`], [`()`], [Liens croisés dessinés au-dessus des feuilles.],
  [`rough`, `hand`, `roughness`, `seed`], [Faux, `none`, `1`, `3`], [Aspect esquissé reproductible.],
)

```typ
#mindmap([*Cycle de l’eau*], leaf-width: auto,
  branch(title: [Évaporation], shape: "leaf")[La chaleur transforme l’eau en vapeur.],
  branch(title: [Condensation], shape: "cloud")[La vapeur refroidit et forme les nuages.],
  branch(title: [Précipitation], shape: "ticket")[L’eau retombe sous forme de pluie ou de neige.],
  branch(title: [Ruissellement], shape: "parallelogram")[Les eaux rejoignent les rivières et la mer.],
)
```

#align(center, fit(17cm, mindmap([*Cycle de l’eau*], leaf-width: auto,
  branch(title: [Évaporation], shape: "leaf")[La chaleur transforme l’eau en vapeur.],
  branch(title: [Condensation], shape: "cloud")[La vapeur refroidit et forme les nuages.],
  branch(title: [Précipitation], shape: "ticket")[L’eau retombe sous forme de pluie ou de neige.],
  branch(title: [Ruissellement], shape: "parallelogram")[Les eaux rejoignent les rivières et la mer.],
)))

= `blossom` — fleur de branches

Une branche devient un pétale plein. Le layout demande au moins trois branches
et ne gère pas de sous-feuilles. `petal: "wedge"` trace des secteurs; `"petal"`
arrondit et resserre les pointes. Le texte mesuré se place vers l’extrémité
extérieure et tourne avec le pétale; dans la moitié basse, il est retourné si
nécessaire pour rester lisible. Le rayon automatique s’étend jusqu’à ce que le
bloc tourné tienne entièrement dans son secteur.

#params(
  [Option], [Défaut], [Rôle],
  [`petal`], [`"wedge"`], [`"wedge"` ou `"petal"`.],
  [`numbering`], [`false`], [Numérotation, motif Typst, tableau ou fonction; `true` utilise des numéros décimaux.],
  [`petal-width`], [`auto`], [Largeur maximale du texte dans les pétales.],
  [`min-width`, `max-width`], [`1`, géométrique], [Bornes horizontales par pétale.],
  [`min-height`, `max-height`], [`0.6`, `auto`], [Bornes verticales par pétale.],
  [`radius`, `length`], [`auto`, `auto`], [Rayon extérieur ou longueur radiale du pétale.],
  [`hub-radius`, `inner`], [`auto`, `auto`], [Rayon du moyeu et intervalle entre moyeu et pétales.],
  [`gap`, `start`], [`4deg`, `90deg`], [Angle libre entre pétales et départ du premier.],
  [`palette`, `tint`, `theme`], [`"poster"`, `24%`, `auto`], [Couleurs et thème d’impression.],
)

```typ
#blossom([*Résoudre une équation*], petal: "petal", numbering: true,
  branch(title: [Observer], shape: "diamond")[Lire l’énoncé et repérer les données.],
  branch(title: [Traduire], shape: "leaf")[Écrire l’équation qui modélise la situation.],
  branch(title: [Résoudre], shape: "bookmark")[Isoler l’inconnue pas à pas.],
  branch(title: [Vérifier], shape: "ticket")[Remplacer la valeur trouvée.],
)
```

#align(center, fit(16cm, blossom([*Résoudre une équation*], petal: "petal", numbering: true,
  branch(title: [Observer], shape: "diamond")[Lire l’énoncé et repérer les données.],
  branch(title: [Traduire], shape: "leaf")[Écrire l’équation qui modélise la situation.],
  branch(title: [Résoudre], shape: "bookmark")[Isoler l’inconnue pas à pas.],
  branch(title: [Vérifier], shape: "ticket")[Remplacer la valeur trouvée.],
)))

= `mindgrid` — grille et branches routées

`mindgrid` conserve un pas de colonne commun (`cell`) mais ajuste chaque carte
à son texte. Chaque rang gagne la hauteur de sa plus grande feuille. Les
branches peuvent éviter les cartes avec `route: true`. Pour un tableau symétrique,
réserver une case centrale au moyeu avec `hub-at:` et placer une feuille à chaque
case restante.

#params(
  [Option], [Défaut], [Rôle],
  [`cols`, `rows`], [`3`, `auto`], [Nombre de colonnes; `rows: auto` calcule les rangs nécessaires.],
  [`cell`, `cell-h`], [`auto`, `auto`], [Pas horizontal et plancher de hauteur d’un rang.],
  [`min-width`, `max-width`], [`1.5`, `9`], [Limites globales des nœuds; `node(..)` peut les remplacer.],
  [`min-height`, `max-height`], [`0`, `auto`], [Limites globales de hauteur.],
  [`gap-x`, `gap-y`], [`0.9`, `0.8`], [Gouttières; `gap-x` participe aussi au couloir de routage.],
  [`hub-at`], [`auto`], [Cellule du moyeu, coordonnées `(col, row)`.],
  [`route`, `clearance`], [`false`, `0.34`], [Routage autour des cartes et distance de dégagement.],
  [`node(..)`], [Une feuille], [`body`, `title`, `shape`, bornes, `col`, `row` ou `x`, `y`.],
  [`sides`, `hub-shape`, `hub-ratio`], [`auto`, `auto`, `1`], [Contour du moyeu et nombre de côtés.],
)

```typ
#mindgrid([Enquête], cols: 3, rows: 3, hub-at: (1, 1),
  cell: 4.2, gap-x: 0.6, gap-y: 0.5, route: true,
  stalk: 0.16, stalk-tip: 0.06, wave: 0.012,
  node(title: [Question], shape: "leaf")[Formuler un problème clair.],
  node(title: [Hypothèse], shape: "cloud")[Proposer une réponse à vérifier.],
  node(title: [Sources], shape: "ticket")[Choisir des documents fiables.],
  node(title: [Collecte], shape: "bookmark")[Noter les observations.],
  node(title: [Analyse], shape: "diamond")[Comparer les résultats.],
  node(title: [Synthèse], shape: "bubble")[Retenir l’essentiel.],
  node(title: [Restitution], shape: "parallelogram")[Présenter la démarche.],
  node(title: [Retour], shape: "round")[Améliorer la méthode.],
)
```

#align(center, fit(17cm, mindgrid([Enquête], cols: 3, rows: 3,
  hub-at: (1, 1), cell: 4.2, gap-x: 0.6, gap-y: 0.5,
  route: true, palette: "cool", theme: "poster",
  stalk: 0.16, stalk-tip: 0.06, wave: 0.012,
  node(title: [Question], shape: "leaf")[Formuler un problème clair.],
  node(title: [Hypothèse], shape: "cloud")[Proposer une réponse à vérifier.],
  node(title: [Sources], shape: "ticket")[Choisir des documents fiables.],
  node(title: [Collecte], shape: "bookmark")[Noter les observations.],
  node(title: [Analyse], shape: "diamond")[Comparer les résultats.],
  node(title: [Synthèse], shape: "bubble")[Retenir l’essentiel.],
  node(title: [Restitution], shape: "parallelogram")[Présenter la démarche.],
  node(title: [Retour], shape: "round")[Améliorer la méthode.],
)))

= `sticky` — mur de notes

Le moyeu et les feuilles sont des papiers. `cell` fixe le pas des colonnes;
une note peut être moins large que sa cellule. `cell-h` est la hauteur de base
d’une rangée. `numbering`, `fold`, `tape`, `pin` et `tilt` reproduisent un mur
de notes de cours.

#params(
  [Option], [Défaut], [Rôle],
  [`cols`, `rows`], [`4`, `auto`], [Dimensions du tableau; les rangées peuvent être calculées.],
  [`cell`, `cell-h`], [`5`, `3.4`], [Pas de colonne et hauteur de rangée plancher, en centimètres.],
  [`min-width`, `max-width`], [`2`, `cell`], [Limites horizontales des notes.],
  [`min-height`, `max-height`], [`auto`, `auto`], [Limites verticales; un `max-height` explicite peut autoriser une note sous `cell-h`.],
  [`hub-at`, `hub-span`], [`auto`, `1`], [Position du moyeu et nombre de colonnes qu’il couvre.],
  [`numbering`, `underline`], [`true`, `true`], [Numéros et règle sous le titre.],
  [`tilt`, `fold`], [`1.25deg`, `false`], [Inclinaison déterministe et coin plié.],
  [`tape`, `pin`, `shadow`], [`false`, `false`, `true`], [Décorations du papier.],
  [`arrows`, `arrow-colour`, `arrow-weight`], [`true`, `auto`, `1.5pt`], [Flèches du moyeu vers les feuilles.],
  [`note(..)`], [Une feuille], [`title`, `icon`, `shape`, `width`, bornes, placement par cellule ou coordonnées `x`, `y`.],
)

```typ
#sticky([*À retenir*], cols: 3, cell: 5.2, cell-h: 2.7,
  note(title: [Définition], shape: "note", max-width: 4.8)[Une idée par feuille.],
  note(title: [Exemple], shape: "ticket", min-width: 2.5,
    max-width: 4.8, max-height: 3.7)[Les rangées grandissent pour accueillir le texte.],
  note(title: [Rappel], shape: "bookmark")[La grille reste alignée.],
)
```

#align(center, fit(17cm, sticky([*À retenir*], cols: 3, cell: 5.2, cell-h: 2.7,
  note(title: [Définition], shape: "note", max-width: 4.8)[Une idée par feuille.],
  note(title: [Exemple], shape: "ticket", min-width: 2.5,
    max-width: 4.8, max-height: 3.7)[Les rangées grandissent pour accueillir le texte.],
  note(title: [Rappel], shape: "bookmark")[La grille reste alignée.],
)))

= `tikzmap` — carte conceptuelle

La carte conceptuelle peut se développer en cercle avec `grow: "cyclic"` ou
suivre des rangs directionnels (`down`, `up`, `left`, `right`). Les concepts
peuvent être imbriqués à toute profondeur; `size` choisit leurs dimensions par
rang. Les sous-concepts s’écrivent dans `children:` sur la racine ou sur tout
concept intermédiaire.

#params(
  [Option], [Défaut], [Rôle],
  [`size`], [`"small"`], [Table de tailles `small`, `mindmap`, `large`, `huge`, ou table personnalisée.],
  [`grow`], [`"cyclic"`], [Disposition circulaire ou directionnelle.],
  [`spin`, `start`, `spread`], [`auto`, `90deg`, `360deg`], [Sens et étendue de la croissance.],
  [`sibling-angle`, `min-angle`], [`auto`, `10deg`], [Angle par branche et plancher angulaire.],
  [`level-dist`, `shrink`], [`auto`, `1`], [Distance entre rangs et réduction par rang.],
  [`sibling-dist`, `clearance`], [`auto`, `auto`], [Espace entre sous-arbres et dégagement des rameaux.],
  [`shape`, `min-size`, `text-width`], [`auto`, `auto`, `auto`], [Contours et géométrie par rang.],
  [`min-width`, `max-width`, `min-height`, `max-height`], [`auto`], [Limites optionnelles des concepts, remplaçables sur `concept(..)`.],
  [`inner`, `font`, `scale`], [`auto`, `auto`, `1`], [Marge du texte et échelle typographique.],
  [`bar-angle`, `bar-thick`, `shade-branch`], [`20deg`, `0.175`, `true`], [Angle et épaisseur des raccords autour des concepts.],
  [`separators`, `fill`, `theme`], [`false`, `true`, `auto`], [Anneaux de séparation, remplissage et impression.],
)

```typ
#tikzmap(concept([*Écosystème*], children: (
  concept(title: [Milieu], children: (
    concept[Lumière], concept[Eau], concept[Sol],
  )),
  concept(title: [Organismes], children: (
    concept[Producteurs], concept[Consommateurs], concept[Décomposeurs],
  )),
  concept(title: [Interactions], children: (
    concept[Chaînes alimentaires], concept[Cycles],
  )),
)), size: "small", grow: "cyclic", separators: true)
```

#align(center, fit(17cm, tikzmap(concept([*Écosystème*], children: (
  concept(title: [Milieu], children: (
    concept[Lumière], concept[Eau], concept[Sol],
  )),
  concept(title: [Organismes], children: (
    concept[Producteurs], concept[Consommateurs], concept[Décomposeurs],
  )),
  concept(title: [Interactions], children: (
    concept[Chaînes alimentaires], concept[Cycles],
  )),
)), size: "small", grow: "cyclic", separators: true)))

= `buzan` — mots portés par le trait

`buzan` place un mot sur la branche, avec une ligne large qui s’amincit vers
l’extrémité. Le moteur `nibart` construit cette ligne comme un stylo variable.
`stroke-engine: "native"` conserve le rendu ruban natif de Sprig.

#params(
  [Option], [Défaut], [Rôle],
  [`stroke-engine`], [`"nibart"`], [`"nibart"` ou `"native"`; les chemins dégénérés retombent sur le moteur natif.],
  [`start`, `spread`, `min-angle`], [`90deg`, `360deg`, `15deg`], [Départ, éventail et angle minimal.],
  [`dist`, `dist-step`], [`0.7`, `0.8`], [Longueur de trait libre et réduction dans les rangs profonds.],
  [`knot`, `taper`], [`0.8`, `0.6`], [Épaisseur sous le mot et amincissement.],
  [`bow`, `wave`, `wave-step`], [`0.05`, `0.16`, `2.2`], [Courbure et ondulation du trait.],
  [`label-at`], [`"stroke"`], [`"stroke"` écrit sur la bande; `"tip"` place le mot après la pastille.],
  [`label-width`], [`auto`], [Largeur du mot; `branch(width:)` la remplace localement.],
  [`min-width`, `max-width`, `min-height`, `max-height`], [`auto`], [Bornes globales ou propres à une branche.],
  [`label-box`, `label-shape`, `label-pad`], [`"none"`, `"round"`, `0.12`], [Contour facultatif autour du mot.],
  [`fit`, `shrink`], [`auto`, `0.84`], [Ajustement à la largeur de la région et réduction des rangs.],
  [`hub-shape`, `hub-puffs`, `hub-squash`, `hub-bump`, `hub-lump`, `hub-tilt`], [`"cloud"`, `11.4`, `0.62`, `3.2`, `0.25`, `0deg`], [`"cloud"` est le moyeu par défaut; les réglages `hub-*` configurent `"cumulus"`.],
  [`upper`, `size`, `leaf-ink`, `shade`], [`false`, `1`, `auto`, `18%`], [Capitales, taille, encre et variation de couleur.],
)

```typ
#buzan([*Apprentissage*], stroke-engine: "nibart",
  label-at: "tip", wave: 0.18, knot: 0.85,
  branch(title: [Observer], icon: [●])[Repérer les faits importants.],
  branch(title: [Relier], icon: [●])[Rapprocher les idées.],
  branch(title: [Retenir], icon: [●])[Formuler un rappel bref.],
)
```

#align(center, fit(17cm, buzan([*Apprentissage*], stroke-engine: "nibart",
  label-at: "tip", wave: 0.18, knot: 0.85,
  branch(title: [Observer], icon: [●])[Repérer les faits importants.],
  branch(title: [Relier], icon: [●])[Rapprocher les idées.],
  branch(title: [Retenir], icon: [●])[Formuler un rappel bref.],
)))

= Formes, palettes et apparence

== Formes intégrées

`shape:` accepte un nom de `sprig-shapes`, ou une fonction de forme. Les formes
intègrent des marges propres lorsque leur contour réserve un coin, une pointe
ou une queue; le texte reste alors à l’intérieur du dessin.

#params(
  [Groupe], [Formes], [Remarque],
  [Base], [`round`, `sharp`, `none`, `pill`], [Rectangle arrondi, rectangle, sans contour, capsule.],
  [Polygones], [`diamond`, `hex`, `cut`, `parallelogram`, `arrow`], [Losange, hexagone, coins coupés, biais, pointe latérale.],
  [Papeterie], [`note`, `folder`, `bookmark`, `ticket`, `document`, `tag`], [Coin plié, onglet, fanion, billet, page, étiquette.],
  [Organiques], [`leaf`, `cloud`, `cumulus`, `bubble`, `wave`, `torn`, `shield`, `banner`, `asym`], [Feuille, nuage, bulle, bords ondulés/déchirés, écusson et ruban.],
  [Conceptuelles], [`ellipse`, `circle`], [Ellipse et disque, pour `tikzmap` et les moyeux.],
)

#pagebreak()

== Formes en pratique

Les vignettes gardent le même moyeu et les mêmes libellés; seule la silhouette
des feuilles change. Une forme peut être définie sur `branch`, `node`, `note`
ou `concept`.

#block(breakable: false, width: 100%, grid(
  columns: 3,
  gutter: 0.28cm,
  row-gutter: 0.16cm,
  ..("leaf", "cloud", "ticket", "bookmark", "bubble", "diamond",
    "cumulus", "arrow", "shield").map(sh =>
    block(width: 100%, inset: 0.10cm, fill: rgb("#FAFBFC"),
      stroke: 0.4pt + line-col, radius: 2pt,
      align(center, {
        text(size: 8pt, weight: "bold", fill: blue)[#sh]
        v(0.04cm)
        fit(5.2cm, mindmap([Hub], shape: "circle", hub-shape: "circle", palette: "cool",
          leaf-width: 1.25, min-width: 1.0, max-width: 1.25,
          min-height: 0.7, dist: 1.65, radius: 0.42,
          weight: 0.7pt, shadow: false,
          branch(shape: sh)[mot], branch(shape: sh)[idée], branch(shape: sh)[fait]))
      })
  ),
)))

Formes personnalisées : passer `shape: (w, h, r) => points`, où `w`, `h`, `r`
et les coordonnées sont en centimètres, avec l’origine en bas à gauche et l’axe
vertical dirigé vers le haut. `sprig-cloud(..)` construit une forme nuage réglable.

== Couleurs et direction

Les palettes intégrées sont `poster`, `warm`, `cool`, `pastel`, `ink`, `mono`
et `sticky`; une palette peut aussi être un tableau de couleurs. `theme: "print"`
retire les aplats afin d’économiser l’encre. `dir: rtl` inverse l’ordre des
branches et adapte l’alignement du corps; `body-align` permet de le remplacer.

`rough: true`, `hand`, `roughness`, `bowing` et `seed` contrôlent le rendu
esquissé. Les valeurs du seed rendent les irrégularités reproductibles.

== Liens croisés

Sur `mindmap`, `links: (link(0, 2, label: [implique]),)` relie des branches
numérotées à partir de zéro. `link` accepte `colour`, `dash`, `arrow`, `bend`
et `via` (`inside`, `outside` ou `auto`).

#pagebreak()

= Exemples et compilation

Chaque fichier `examples/*.typ` est un document autonome. `adaptive.typ`
montre les six mises en page et les limites de dimensions; les autres fichiers
illustrent séparément Blossom, Buzan, les grilles, les cartes conceptuelles,
l’impression et la lecture droite-à-gauche.

Depuis la racine du paquet, compiler un exemple ou ce manuel :

```sh
typst compile --root . examples/adaptive.typ /tmp/sprig-adaptive.pdf
typst compile --root . docs/manual.typ /tmp/sprig-manual.pdf
typst compile --root . gallery/cover.typ /tmp/sprig-cover.png
```

Le premier rendu de `buzan` peut télécharger `nibart` 0.3.0. Les documents
arabes utilisent les polices disponibles sur le système; installer une police
arabe améliore leur rendu, sans modifier le code des exemples.

== Limites pratiques

- `blossom` demande au moins trois pétales et ne prend pas de sous-feuilles.
- `mindgrid` garde un pas commun entre ses colonnes; `sticky` garde le pas de
  cellule même quand une note contient peu de texte.
- Une contrainte incompatible est signalée plutôt que dessinée avec du texte
  coupé.
- `buzan` utilise `nibart` par défaut; `stroke-engine: "native"` sélectionne
  le moteur intégré.

= Licence

Sprig est distribué sous licence MIT. Consulter `LICENSE` pour les conditions
et l’avis de copyright.
