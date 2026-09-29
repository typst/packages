#import "@preview/geomtools:0.1.0": *
#import "helpers.typ": *

#set page(
  paper: "a4",
  margin: (x: 1.7cm, y: 1.85cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: luma(110), font: "DejaVu Serif")
      grid(columns: (1fr, 1fr),
        [geomtools — guide utilisateur],
        align(right)[Instruments de géométrie],
      )
      v(-0.35em)
      line(length: 100%, stroke: 0.4pt + luma(200))
    }
  },
)
#set text(size: 10.2pt, font: "DejaVu Serif", lang: "fr", fill: ink)
#set par(justify: true, leading: 0.72em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(above: 0.4em, below: 0.75em, {
    text(size: 16pt, weight: "bold", fill: blue, it)
    v(-0.5em)
    line(length: 100%, stroke: 0.9pt + blue)
  })
}
#show heading.where(level: 2): it => block(above: 1.15em, below: 0.5em,
  text(size: 12pt, weight: "bold", fill: rgb("#1C3D5A"), it))
#show heading.where(level: 3): it => block(above: 0.9em, below: 0.4em,
  text(size: 10.6pt, weight: "bold", style: "italic", it))
#show raw: set text(font: "DejaVu Sans Mono", size: 7.7pt)
#show raw.where(block: true): it => block(
  width: 100%, fill: luma(248), stroke: 0.4pt + luma(220),
  inset: 7pt, radius: 3pt, above: 0.45em, below: 0.55em, it,
)
#show strong: set text(fill: rgb("#16324F"))

#let cap(t) = align(center, text(size: 8pt, fill: luma(90), style: "italic", t))
#let note(title, body) = block(
  width: 100%, fill: rgb("#E7F5FF"), stroke: 0.7pt + blue,
  inset: 9pt, radius: 4pt, above: 0.6em, below: 0.6em,
  {
    text(weight: "bold", fill: blue, size: 9pt, title)
    v(0.2em)
    body
  },
)
#let warn(title, body) = block(
  width: 100%, fill: rgb("#FFF4E6"), stroke: 0.7pt + orange,
  inset: 9pt, radius: 4pt, above: 0.55em, below: 0.55em,
  {
    text(weight: "bold", fill: orange, size: 9pt, title)
    v(0.2em)
    body
  },
)
#let codebox(body) = block(
  width: 100%, fill: luma(248), stroke: 0.4pt + luma(220),
  inset: 7pt, radius: 3pt, above: 0.4em, below: 0.5em,
  raw(body, lang: "typ"),
)

#let A = A0
#let B = B0
#let C = C0
#let O = circumcenter(A, B, C)
#let I = incenter(A, B, C)
#let G = centroid(A, B, C)
#let H = orthocenter(A, B, C)
#let R = dist(O, A)
#let r-in = I.at(1) // AB est l'axe des x
#let Ma = midp(B, C)
#let Mb = midp(A, C)
#let Mc = midp(A, B)
#let Ha = foot(A, B, C)
#let Hb = foot(B, A, C)
#let Hc = foot(C, A, B)
#let Ta = foot(I, B, C)
#let Tb = foot(I, A, C)
#let Tc = foot(I, A, B)

#let rAB = 4.5
#let (Pab, Qab) = circ-inter(A, rAB, B, rAB)
#let P-ab = if Pab.at(1) > Qab.at(1) { Pab } else { Qab }
#let Q-ab = if Pab.at(1) > Qab.at(1) { Qab } else { Pab }

#let rAC = 4.2
#let (Pac, Qac) = circ-inter(A, rAC, C, rAC)
#let toward-b = vsub(B, midp(A, C))
#let P-ac = if dotp(vsub(Pac, midp(A, C)), toward-b) > 0 { Pac } else { Qac }
#let Q-ac = if dotp(vsub(Pac, midp(A, C)), toward-b) > 0 { Qac } else { Pac }

#let r-bis = 2.05
#let P-angA = lerp(A, B, r-bis / dist(A, B))
#let Q-angA = lerp(A, C, r-bis / dist(A, C))
#let r-bis2 = 1.85
#let (Ra1, Ra2) = circ-inter(P-angA, r-bis2, Q-angA, r-bis2)
#let R-A = farther(A, Ra1, Ra2)

#let P-angB = lerp(B, A, r-bis / dist(B, A))
#let Q-angB = lerp(B, C, r-bis / dist(B, C))
#let (Rb1, Rb2) = circ-inter(P-angB, r-bis2, Q-angB, r-bis2)
#let R-B = farther(B, Rb1, Rb2)

#let r-drop = r-in + 1.15
#let U-V-BC = {
  let F = Ta
  let h = dist(I, F)
  let half = calc.sqrt(r-drop * r-drop - h * h)
  let u = unit(vsub(C, B))
  (vadd(F, vmul(u, half)), vsub(F, vmul(u, half)))
}
#let Ubc = U-V-BC.at(0)
#let Vbc = U-V-BC.at(1)

// ===========================================================================
//  Couverture
// ===========================================================================

#align(center)[
  #v(0.4em)
  #text(size: 11pt, fill: blue, tracking: 1.4pt)[GUIDE UTILISATEUR]
  #v(0.15em)
  #text(size: 28pt, weight: "bold")[geomtools]

  #v(1em) 

  #text(size: 13pt, fill: luma(68))[#emoji.hand.write FERGOUS Abdelhak]

  #v(1em)
  #text(size: 12.5pt, fill: luma(70))[
    Dessiner les instruments de géométrie
  ]
  #v(0.15em)
  #text(size: 10pt, fill: luma(100))[
    règle · crayon · équerre · rapporteur · compas
  ]
]

#v(0.55em)

#align(center, geom({
  let fig = abc-figure(A, B, C)
  // médiatrices légères
  fig += line-ext(P-ab, Q-ab, beyond: 0.3, stroke: blue.lighten(45%), weight: 0.55)
  fig += line-ext(P-ac, Q-ac, beyond: 0.3, stroke: blue.lighten(45%), weight: 0.55)
  // médianes
  fig += p-line(A, Ma, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  fig += p-line(B, Mb, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  fig += p-line(C, Mc, stroke: orange.lighten(25%), weight: 0.7, role: "edge")
  // hauteurs
  fig += p-line(A, Ha, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  fig += p-line(B, Hb, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  fig += p-line(C, Hc, stroke: purple.lighten(30%), weight: 0.7, role: "edge")
  // bissectrices
  fig += p-line(A, Ta, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  fig += p-line(B, Tb, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  fig += p-line(C, Tc, stroke: green.lighten(25%), weight: 0.65, role: "edge")
  // cercles
  fig += p-circle(O, R, stroke: blue, weight: 1.35)
  fig += p-circle(I, r-in, stroke: green, weight: 1.25)
  // droite d'Euler
  fig += line-ext(O, H, beyond: 0.55, stroke: red, weight: 1.05, dash: none)
  fig += pt(O, fill: blue, r: 0.09)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(G, fill: orange, r: 0.09)
  fig += pt(H, fill: purple, r: 0.09)
  fig += lab(O, text(fill: blue)[$O$], dx: 0.28, dy: -0.28, fill: blue)
  fig += lab(I, text(fill: green)[$I$], dx: -0.30, dy: 0.22, fill: green)
  fig += lab(G, text(fill: orange)[$G$], dx: 0.28, dy: 0.22, fill: orange)
  fig += lab(H, text(fill: purple)[$H$], dx: -0.28, dy: 0.26, fill: purple)
  fig
}, padding: 0.55))
#cap[Le triangle $A B C$ du guide, ses quatre centres, et la droite d'Euler $(O G H)$.]

#v(0.4em)

#grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 8pt,
  align(center)[
    #text(fill: blue, weight: "bold")[$O$ circonscrit]\
    #text(size: 8.5pt, fill: luma(80))[médiatrices, au compas]
  ],
  align(center)[
    #text(fill: green, weight: "bold")[$I$ inscrit]\
    #text(size: 8.5pt, fill: luma(80))[bissectrices, au compas]
  ],
  align(center)[
    #text(fill: orange, weight: "bold")[$G$ barycentre]\
    #text(size: 8.5pt, fill: luma(80))[médianes, à la règle]
  ],
  align(center)[
    #text(fill: purple, weight: "bold")[$H$ orthocentre]\
    #text(size: 8.5pt, fill: luma(80))[hauteurs, à l'équerre]
  ],
)

#v(0.7em)

Le paquet Typst `geomtools` pose sur une figure les *instruments du
géomètre* : règle, crayon, équerre, rapporteur, compas — nets comme
l'original LaTeX, ou « à main levée ». Ce guide les présente, puis s'en
sert pour *construire* les quatre centres d'un triangle, avec leurs
codages (traits d'égalité, angles droits, arcs de bissectrice).

C'est un portage d'`OutilsGeomTikZ` de Cédric Pierquet. Pas de CeTZ : les
outils sont de simples listes de polygones, d'arcs et d'étiquettes.

#outline(indent: 1em, depth: 2)

= Le paquet en deux minutes

== Installation locale

Le paquet n'est pas (encore) sur Universe. On l'importe par son chemin :

```typ
#import "chemin/vers/geomtools/lib.typ": *
```

Tout ce que le paquet exporte tient dans `geom` : on lui passe une *liste de
primitives* — ce que chaque instrument *retourne*, pas du contenu Typst.

```typ
#geom({
  ruler(length: 10)
  pencil(at: (3, 2), rotate: -20deg)
})
```

Dans un bloc `{ ... }`, Typst *concatène* les tableaux. On peut aussi écrire
`ruler(...) + pencil(...)` avec `+`, c'est plus explicite, et c'est ce que
font tous les listings de ce guide.

== Deux modes, une géométrie

#grid(columns: (1fr, 1fr), column-gutter: 12pt,
  [
    #align(center, geom(ruler(length: 7, width: 1.5), padding: 0.3))
    #cap[`mode: "clean"` — le défaut]
  ],
  [
    #align(center, geom(ruler(length: 7, width: 1.5), mode: "rough", padding: 0.3))
    #cap[`mode: "rough"`]
  ],
)

```typ
#geom(ruler(length: 7))
#geom(ruler(length: 7), mode: "rough", roughness: 2, seed: 4)
#geom-rough(ruler(length: 7))
```

Le tremblement est *déterministe* : même `seed`, même figure à chaque
compilation. Les chiffres ne sont jamais tordus — un « 3 » à main levée
n'est pas un 3, c'est une autre police.

== Ce que l'on compose

| Fonction | Rôle sur une construction |
|---|---|
| `compass(from, to)` | pointe en `from`, mine en `to` — l'ouverture est exacte |
| `set-square` | équerre 30-60-90, angle droit à l'origine |
| `ruler` | zéro à l'origine, vers la droite |
| `right-angle` | *codage* d'angle droit (carré ouvert, pas l'équerre) |
| `pencil` | crayon, pointe à l'origine vers le haut |
| `p-line` `p-arc` `p-circle` `p-label` | le trait de la figure elle-même |

Arguments communs des instruments : `at`, `rotate`, `scale`, `colour`,
`fill`. Les clés françaises de l'original (`Longueur`, `Origine`…) sont
traduites (`length`, `at`…).

#note[Convention des manuels][
  *Le trait plein est la figure, le tiret est la trace de l'instrument*
  — celle qu'on efface ensuite. Toute primitive accepte `dash: "dashed"`.
  Un arc de construction se trace donc :

  ```typ
  p-arc(A, 4.5, 20deg, 160deg, stroke: luma(120), dash: "dashed")
  ```
]

= Le canevas et la boîte à outils

Les coordonnées sont en *centimètres*, $y$ vers le *haut* (orientation
mathématique). Le rendu retourne l'axe une seule fois.

== Helpers déjà exportés

`vadd` `vsub` `vmul` `vnorm` `dist` `vangle` `arc-pts` `circle-pts`
`rect-pts` — plus les constructeurs `p-poly` `p-line` `p-circle` `p-arc`
`p-label`.

`vangle((x, y))` est l'angle du vecteur, $0 degree$ sur $+x$, $90 degree$
sur $+y$. C'est l'angle que l'on passe à `rotate`.

== Helpers de ce guide

Le fichier `helpers.typ` ajoute ce dont une construction a besoin :

- `midp(A, B)`, `unit(v)`, `lerp(A, B, t)`, `foot(P, A, B)`
- `circ-inter(P, r1, Q, r2)` — les deux intersections de deux cercles
- `line-inter(P1, P2, Q1, Q2)` — intersection de deux droites
- `circumcenter` `incenter` `centroid` `orthocenter`
- `ticks(P, Q, n: 1)` — codage d'égalité au milieu de $[P Q]$
- `right-angle` (du paquet) et `ang-mark` — codages d'angles
- `square-on(at, along, toward)` — pose l'équerre sur une droite, l'angle
  droit tourné vers un point

Le triangle de travail, utilisé partout :

$ A = (0, 0), quad B = (7.2, 0), quad C = (2.2, 4.8) $

Il est *scalène* et *acutangle* : les quatre centres sont distincts et
*intérieurs*, les pieds des hauteurs tombent sur les côtés (pas sur leurs
prolongements). $A B$ est sur l'axe des $x$, ce qui simplifie la lecture
sans rendre la figure spéciale.

```typ
#let A = (0.0, 0.0)
#let B = (7.2, 0.0)
#let C = (2.2, 4.8)
```

= Rapporteur et crayon au bout du trait

Pour *mesurer* $angle B A C$, on centre le rapporteur en $A$ et on aligne
sa base sur $(A B)$. Le côté $[A C]$ coupe la graduation à la mesure de
l'angle (ici $approx 65 degree$).

Quand on *tire un trait*, on pose souvent un crayon à son extrémité : la
mine est au bout, le fût suit la direction du trait.
`pencil-tip(from, to)` le fait — la pointe de `pencil` est à l'origine et
regarde vers le haut, d'où `rotate: vangle(to − from) - 90deg`.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += protractor(at: A, rotate: 0deg, scale: 0.58, radians: false,
    colour: luma(45), value-size: 0.65)
  fig += pencil-tip(A, C, colour: rgb("#2B6CB0"), lead: rgb("#2B6CB0"),
    length: 3.6, scale: 0.78)
  fig
}, padding: 0.4))
#cap[Rapporteur en $A$, base sur $(A B)$. Le crayon est au bout de $[A C]$.]

```typ
#protractor(at: A, rotate: 0deg, scale: 0.58, radians: false)
#pencil-tip(A, C, colour: rgb("#2B6CB0"), lead: rgb("#2B6CB0"))
```

`scale` réduit le rapporteur (rayon d'origine $3.75$ cm) sans bouger le
centre. `radians: false` cache la bande $pi/6$, $pi/4$… si l'on ne veut
que les degrés. Pour un disque $0 degree$–$360 degree$ : `full: true`.

= Cercle circonscrit — au compas

Le *cercle circonscrit* est l'unique cercle passant par $A$, $B$ et $C$.
Son centre $O$ est l'intersection des *médiatrices*. Une médiatrice se
construit au compas : deux arcs de *même rayon*, plus grand que la
demi-base.

#note[Ce que l'on code][
  - traits d'égalité $A M = M B$ (le milieu) ;
  - *angles droits* au milieu : la médiatrice est perpendiculaire au côté ;
  - à la fin, $O A = O B = O C$ (le rayon), éventuellement par trois petits
    arcs, mais le cercle lui-même suffit souvent.
]

== Étape 1 — Le triangle

#align(center, geom(
  abc-figure(A, B, C)
  + ruler(at: (0, -0.62), length: 7.2, width: 0.55, clamp: false,
      values: true, value-size: 0.7, colour: luma(70)),
  padding: 0.4,
))
#cap[On trace $A B C$ à la règle. Le zéro de la règle est en $A$.]

```typ
#geom(
  p-line(A, B, stroke: black, weight: 1.35, role: "edge")
  + p-line(B, C, stroke: black, weight: 1.35, role: "edge")
  + p-line(C, A, stroke: black, weight: 1.35, role: "edge")
  + ruler(at: (0, -0.62), length: 7.2, width: 0.55, clamp: false)
  + pencil-tip(A, B)
)
```

`clamp: false` est indispensable : par défaut la largeur d'une règle est
ramenée *en silence* à $1.5$ cm, et une règle que l'on croyait fine
décolle de 8 mm.

== Étape 2 — Compas en $A$, ouverture plus grande que la demi-base

$A B = 7.2$, donc $A B slash 2 = 3.6$. On prend $4.5$ cm. L'arc doit être assez
long pour croiser son jumeau issu de $B$, *des deux côtés* de $(A B)$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -55deg, 95deg, stroke: muted, dash: "dashed", weight: 0.9)
  fig += compass(A, P-ab, scale: 0.58, leg: 5.2, flip: false,
    pencil-colour: rgb("#C92A2A"))
  fig
}, padding: 0.45))
#cap[`compass(A, P)` — la pointe est en $A$, la mine passe par un point de l'arc.]

```typ
#let rAB = 4.5
#p-arc(A, rAB, -55deg, 95deg, stroke: luma(120), dash: "dashed")
#compass(A, (4.5 * calc.cos(40deg), 4.5 * calc.sin(40deg)), scale: 0.58)
```

Le compas *ouvre vraiment* sur les deux points :

$ "demi-angle" = arcsin( (|italic("to") - italic("from")|) slash (2 "leg" "scale") ) $

`scale` réduit l'instrument *sans* déplacer les pieds — indispensable pour
qu'il tienne dans la figure. `flip: true` le bascule de l'autre côté du
segment, quand il recouvre le triangle.

== Étape 3 — Même ouverture, pointe en $B$

Les deux arcs se coupent en $P$ et $Q$. *Ne pas changer l'ouverture* : c'est
tout le codage $A P = B P = A Q = B Q$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -58deg, 100deg, stroke: muted, dash: "dashed", weight: 0.85)
  fig += p-arc(B, rAB, 80deg, 238deg, stroke: muted, dash: "dashed", weight: 0.85)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue)
  fig += lab(P-ab, [$P$], dx: 0.28, dy: 0.18, fill: blue)
  fig += lab(Q-ab, [$Q$], dx: 0.28, dy: -0.28, fill: blue)
  fig += compass(B, P-ab, scale: 0.58, leg: 5.2, flip: true,
    pencil-colour: rgb("#C92A2A"))
  fig
}, padding: 0.45))
#cap[Deuxième arc, *même rayon*. $P$ et $Q$ sont à égale distance de $A$ et de $B$.]

Les intersections se calculent, on ne les devine pas :

```typ
#let (P, Q) = circ-inter(A, rAB, B, rAB)
#compass(B, P, scale: 0.58, flip: true)
```

`circ-inter` (dans `helpers.typ`) est l'intersection classique de deux
cercles : on projette sur la ligne des centres, puis on s'écarte de
$h = sqrt(r_1^2 - a^2)$.

== Étape 4 — La médiatrice de $[A B]$

La droite $(P Q)$ est la médiatrice : elle coupe $[A B]$ en son milieu $M$
et lui est perpendiculaire. On *code* les deux.

#align(center, geom({
  let M = Mc
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, rAB, -50deg, 95deg, stroke: muted, dash: "dashed", weight: 0.7)
  fig += p-arc(B, rAB, 85deg, 230deg, stroke: muted, dash: "dashed", weight: 0.7)
  fig += line-ext(P-ab, Q-ab, beyond: 0.35, stroke: blue, weight: 1.05, dash: none)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue) + pt(M, fill: blue)
  fig += lab(P-ab, [$P$], dx: 0.26, dy: 0.16, fill: blue)
  fig += lab(Q-ab, [$Q$], dx: 0.26, dy: -0.28, fill: blue)
  fig += lab(M, [$M$], dx: 0.22, dy: 0.22, fill: blue)
  fig += ticks(A, M, n: 1) + ticks(M, B, n: 1)
  fig += right-angle(at: M, rotate: 0deg, size: 0.32, colour: blue)
  fig
}, padding: 0.4))
#cap[Codage : $A M = M B$ (un trait) et $angle P M B = 90 degree$ (carré ouvert).]

```typ
#let M = midp(A, B)
#line-ext(P, Q, stroke: blue, dash: none)
#ticks(A, M, n: 1) + ticks(M, B, n: 1)
#right-angle(at: M, rotate: 0deg, size: 0.32, colour: blue)
```

#warn[`right-angle` n'est pas `mini-square`][
  `mini-square` est une *petite équerre* : elle a une hypoténuse. Posée dans
  un angle, cette hypoténuse traverse le coin en diagonale. Le codage d'un
  angle droit est un *carré ouvert* — deux côtés, sommet en retrait du
  vertex. C'est `right-angle`.
]

`rotate` de `right-angle` est la direction du *premier* côté. Ici $(A B)$
est horizontale, donc `rotate: 0deg` et le carré monte dans le triangle.
Sur un côté d'angle $theta$, on passe `rotate: theta`, et l'on ajoute
$90 degree$ ou l'on retourne selon le côté où l'on veut le carré.

== Étape 5 — Médiatrice de $[A C]$

Même geste, *deux arcs de même rayon* qui se coupent en *deux* points
$P'$ et $Q'$. Le rayon $4.2$ cm dépasse $A C slash 2 approx 2.64$.
L'intersection des deux médiatrices est $O$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += arc-through(A, P-ab, Q-ab, extra: 22deg, stroke: muted, weight: 0.6)
  fig += arc-through(B, P-ab, Q-ab, extra: 22deg, stroke: muted, weight: 0.6)
  fig += arc-through(A, P-ac, Q-ac, extra: 28deg, stroke: green, weight: 0.85)
  fig += arc-through(C, P-ac, Q-ac, extra: 28deg, stroke: green, weight: 0.85)
  fig += line-ext(P-ab, Q-ab, beyond: 0.2, stroke: blue, weight: 1.0, dash: none)
  fig += line-ext(P-ac, Q-ac, beyond: 0.45, stroke: green, weight: 1.05, dash: none)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += right-angle(at: Mc, rotate: 0deg, size: 0.28, colour: blue)
  fig += ra-in(Mb, vsub(C, A), vsub(B, Mb), size: 0.28, colour: green)
  fig += pt(P-ab, fill: blue) + pt(Q-ab, fill: blue)
  fig += pt(P-ac, fill: green) + pt(Q-ac, fill: green)
  fig += lab(P-ac, [$P'$], dx: 0.28, dy: 0.16, fill: green, size: 9pt)
  fig += lab(Q-ac, [$Q'$], dx: -0.38, dy: 0.14, fill: green, size: 9pt)
  fig += pt(O, fill: red, r: 0.09)
  fig += lab(O, text(fill: red)[$O$], dx: 0.28, dy: -0.26, fill: red)
  fig += pt(Mc, fill: blue) + pt(Mb, fill: green)
  fig
}, padding: 0.4))
#cap[Chaque médiatrice : *deux* arcs, *deux* points d'intersection. $(P' Q')$ coupe $(P Q)$ en $O$.]

```typ
#let rAC = 4.2
#let (P2, Q2) = circ-inter(A, rAC, C, rAC)
#arc-through(A, P2, Q2) + arc-through(C, P2, Q2)
#let O = line-inter(P, Q, P2, Q2)   // ou circumcenter(A, B, C)
```

On code $[A C]$ avec *deux* traits, pour ne pas le confondre avec $[A B]$
(un trait). L'angle droit en $M_(A C)$ est renvoyé vers l'intérieur par
`ra-in`.

== Étape 6 — Compas en $O$, ouverture $O A$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += line-ext(P-ab, Q-ab, beyond: 0.15, stroke: blue.lighten(35%), weight: 0.7, dash: none)
  fig += line-ext(P-ac, Q-ac, beyond: 0.4, stroke: blue.lighten(35%), weight: 0.7, dash: none)
  fig += p-circle(O, R, stroke: blue, weight: 1.4)
  fig += p-line(O, A, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += p-line(O, B, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += p-line(O, C, stroke: blue.lighten(20%), weight: 0.7, role: "edge")
  fig += waves(O, A, n: 2, stroke: blue)
  fig += waves(O, B, n: 2, stroke: blue)
  fig += waves(O, C, n: 2, stroke: blue)
  fig += pt(O, fill: blue, r: 0.09)
  fig += lab(O, text(fill: blue)[$O$], dx: 0.32, dy: 0.08, fill: blue)
  fig += compass(O, lerp(O, C, 1.0), scale: 0.52, leg: 5.4, flip: false,
    pencil-colour: rgb("#1864AB"), pencil-lead: rgb("#1864AB"))
  fig
}, padding: 0.5))
#cap[Deux tildes identiques sur $[O A]$, $[O B]$ et $[O C]$ : $O A = O B = O C$.]

```typ
#let O = circumcenter(A, B, C)
#let R = dist(O, A)
#p-circle(O, R, stroke: rgb("#1864AB"), weight: 1.4)
#waves(O, A, n: 2) + waves(O, B, n: 2) + waves(O, C, n: 2)
#compass(O, C, scale: 0.52, pencil-colour: rgb("#1864AB"),
         pencil-lead: rgb("#1864AB"))
```

Sans `pencil-lead`, le crayon du compas resterait à mine *noire* — un
crayon à papier collé sur un fût bleu. Pour un crayon de couleur, la mine
suit le fût.

#note[Pourquoi $O$ est sur les trois médiatrices][
  Par construction $P$ et $Q$ sont équidistants de $A$ et $B$, donc tout
  point de $(P Q)$ l'est aussi — en particulier $O$. De même $O A = O C$.
  D'où $O A = O B = O C$ : le cercle de centre $O$ passant par $A$ passe
  par $B$ et $C$.
]

= Cercle inscrit — au compas

Le *cercle inscrit* est tangent aux trois côtés. Son centre $I$ est
l'intersection des *bissectrices*. Une bissectrice se construit au compas
en deux temps : un arc centré au sommet, puis deux arcs égaux centrés aux
points de coupe.

#note[Ce que l'on code][
  - *arcs égaux* dans les deux demi-angles (la bissectrice) ;
  - aux points de tangence, un *angle droit* entre le rayon et le côté
    (le rayon est perpendiculaire à la tangente) ;
  - $I T_a = I T_b = I T_c$ (le rayon), porté par le cercle lui-même.
]

== Étape 1 — Arc centré en $A$, qui coupe $[A B]$ et $[A C]$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, r-bis, -8deg, 80deg, stroke: muted, dash: "dashed", weight: 0.9)
  fig += pt(P-angA, fill: green) + pt(Q-angA, fill: green)
  fig += lab(P-angA, [$P$], dx: 0.08, dy: -0.32, fill: green)
  fig += lab(Q-angA, [$Q$], dx: -0.34, dy: 0.10, fill: green)
  fig += compass(A, P-angA, scale: 0.55, leg: 5.0, flip: false,
    pencil-colour: rgb("#2F9E44"))
  fig
}, padding: 0.45))
#cap[Pointe en $A$. L'arc coupe les deux côtés de l'angle — *pas* le troisième.]

```typ
#let r = 2.05
#let P = lerp(A, B, r / dist(A, B))   // sur [AB], à r de A
#let Q = lerp(A, C, r / dist(A, C))   // sur [AC], à r de A
#p-arc(A, r, -8deg, 80deg, stroke: luma(120), dash: "dashed")
#compass(A, P, scale: 0.55)
```

== Étape 2 — Compas en $P$ et en $Q$, même ouverture

Les deux arcs se coupent en $R$ *à l'intérieur* de l'angle, vers la
droite. Le dernier arc est celui centré en $Q$ : on pose la pointe en
$Q$ et la mine s'arrête en $R$, pas vers $A$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-arc(A, r-bis, -6deg, 78deg, stroke: muted, dash: "dashed", weight: 0.65)
  fig += arc-to(P-angA, R-A, back: 48deg, extra: 16deg, stroke: muted, weight: 0.8)
  fig += arc-to(Q-angA, R-A, back: 72deg, extra: 0deg, stroke: green, weight: 0.95)
  fig += pt(P-angA, fill: green) + pt(Q-angA, fill: green) + pt(R-A, fill: green)
  fig += lab(P-angA, [$P$], dx: 0.10, dy: -0.32, fill: green)
  fig += lab(Q-angA, [$Q$], dx: -0.34, dy: 0.14, fill: green)
  fig += lab(R-A, [$R$], dx: 0.28, dy: 0.18, fill: green)
  fig += ray(A, R-A, extra: 2.2, stroke: green, weight: 1.1, dash: none)
  fig += ang-mark(A, B, R-A, r: 0.72, stroke: green)
  fig += ang-mark(A, R-A, C, r: 0.72, stroke: green)
  fig += compass(Q-angA, R-A, scale: 0.48, leg: 4.6, flip: false,
    pencil-colour: rgb("#2F9E44"))
  fig
}, padding: 0.4))
#cap[Pointe en $Q$, mine en $R$ : le crayon est au *bout* de l'arc, vers la droite.]

```typ
#let R = farther(A, R1, R2)     // l'intersection éloignée de A
#arc-to(Q, R, back: 72deg, extra: 0deg)
#compass(Q, R, scale: 0.48)     // mine au bout de l'arc, vers la droite
```

Pourquoi ça marche : $A P = A Q$ (même arc), $P R = Q R$ (même ouverture),
$A R$ commun, donc $triangle A P R = triangle A Q R$ (CCC) et les angles
en $A$ sont égaux.

== Étape 3 — Bissectrice de $angle A B C$, puis $I$

Une deuxième bissectrice suffit : la troisième passe par $I$. Pour
*chaque* angle on laisse les *trois* arcs de construction : l'arc au
sommet, puis les deux arcs égaux qui se coupent en $R$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += bisector-three-arcs(A, P-angA, Q-angA, R-A, r-bis, r-bis2, stroke: muted)
  fig += bisector-three-arcs(B, P-angB, Q-angB, R-B, r-bis, r-bis2, stroke: muted)
  fig += ray(A, R-A, extra: 2.6, stroke: green, weight: 1.05, dash: none)
  fig += ray(B, R-B, extra: 2.2, stroke: green, weight: 1.05, dash: none)
  fig += ang-mark(A, B, R-A, r: 0.62, stroke: green)
  fig += ang-mark(A, R-A, C, r: 0.62, stroke: green)
  fig += ang-mark(B, A, R-B, r: 0.62, stroke: green)
  fig += ang-mark(B, R-B, C, r: 0.62, stroke: green)
  fig += pt(R-A, fill: green) + pt(R-B, fill: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.20, fill: green)
  fig
}, padding: 0.4))
#cap[Trois arcs en $A$, trois arcs en $B$. $I$ est leur intersection.]

```typ
#let I = line-inter(A, R-A, B, R-B)   // ou incenter(A, B, C)
```

== Étape 4 — Projeter $I$ sur un côté, à l'équerre

On *garde* les six arcs des bissectrices. Pour le rayon, on ne trace
plus d'arc au sommet $C$ : on abaisse la perpendiculaire de $I$ sur un
côté *à l'équerre*. Le pied $T$ est le point de tangence ; $I T$ sera
l'ouverture du compas.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += bisector-three-arcs(A, P-angA, Q-angA, R-A, r-bis, r-bis2, stroke: luma(170))
  fig += bisector-three-arcs(B, P-angB, Q-angB, R-B, r-bis, r-bis2, stroke: luma(170))
  fig += ray(A, R-A, extra: 2.4, stroke: green.lighten(20%), weight: 0.8, dash: none)
  fig += ray(B, R-B, extra: 2.0, stroke: green.lighten(20%), weight: 0.8, dash: none)
  fig += p-line(I, Tc, stroke: green, weight: 1.15, role: "edge")
  fig += ra-in(Tc, vsub(B, A), vsub(I, Tc), size: 0.30, colour: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(Tc, fill: green)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.22, fill: green)
  fig += lab(Tc, [$T$], dx: 0.22, dy: -0.32, fill: green)
  fig += square-on(Tc, vsub(B, A), vsub(I, Tc),
    length: dist(I, Tc) + 1.15, colour: luma(65))
  fig
}, padding: 0.4))
#cap[Les 3+3 arcs restent. L'équerre sur $(A B)$ projette $I$ en $T$ : $(I T) perp (A B)$.]

```typ
#let T = foot(I, A, B)
#square-on(T, vsub(B, A), vsub(I, T), length: dist(I, T) + 1.15)
#ra-in(T, vsub(B, A), vsub(I, T), colour: rgb("#2F9E44"))
```

== Étape 5 — Le cercle, et les trois tangences

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-circle(I, r-in, stroke: green, weight: 1.4)
  fig += p-line(I, Ta, stroke: green, weight: 0.85, role: "edge")
  fig += p-line(I, Tb, stroke: green, weight: 0.85, role: "edge")
  fig += p-line(I, Tc, stroke: green, weight: 0.85, role: "edge")
  fig += ra-in(Ta, vsub(C, B), vsub(I, Ta), size: 0.26, colour: green)
  fig += ra-in(Tb, vsub(C, A), vsub(I, Tb), size: 0.26, colour: green)
  fig += ra-in(Tc, vsub(B, A), vsub(I, Tc), size: 0.26, colour: green)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(Ta, fill: green) + pt(Tb, fill: green) + pt(Tc, fill: green)
  fig += lab(I, text(fill: green)[$I$], dx: 0.28, dy: 0.22, fill: green)
  fig += lab(Ta, [$T_a$], dx: 0.34, dy: 0.10, fill: green, size: 9pt)
  fig += lab(Tb, [$T_b$], dx: -0.36, dy: 0.10, fill: green, size: 9pt)
  fig += lab(Tc, [$T_c$], dx: 0.10, dy: -0.32, fill: green, size: 9pt)
  fig += compass(I, Tc, scale: 0.5, leg: 4.8, flip: false,
    pencil-colour: rgb("#2F9E44"), pencil-lead: rgb("#2F9E44"))
  fig
}, padding: 0.45))
#cap[Trois rayons, trois angles droits : le cercle est tangent aux trois côtés.]

```typ
#let I = incenter(A, B, C)
#let T = foot(I, A, B)                 // point de tangence sur [AB]
#let r = dist(I, T)
#p-circle(I, r, stroke: rgb("#2F9E44"), weight: 1.4)
#ra-in(T, vsub(B, A), vsub(I, T), colour: rgb("#2F9E44"))
#compass(I, T, scale: 0.5, pencil-lead: rgb("#2F9E44"))
```

`ra-in(T, along, toward)` oriente le carré *vers l'intérieur* : `along`
est le côté, `toward` pointe vers $I$. Sur $[A C]$, sans ce test, le
carré tombait à l'extérieur.

= Centre de gravité — médianes, à la règle

Le *centre de gravité* $G$ (barycentre des trois sommets) est
l'intersection des *médianes*. Une médiane joint un sommet au *milieu* du
côté opposé. On trouve les milieux à la règle, puis on tire les trois
médianes. L'équerre n'a rien à faire ici : une médiane n'est pas une
perpendiculaire.

#note[Ce que l'on code][
  - sur chaque côté, *le même nombre de traits* de part et d'autre du
    milieu : un trait sur $[A B]$, deux sur $[A C]$, trois sur $[B C]$ ;
  - on ne code *pas* $A G = 2 thin  G M$ en général (ce $2:1$ est un théorème,
    pas un geste de construction). On peut l'écrire à côté, une fois $G$
    trouvé.
]

== Étape 1 — Milieu de $[A B]$ à la règle

$A B = 7.2$ cm, le milieu $M_c$ est à $3.6$ cm. On pose la règle le long
du côté, zéro en $A$.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += ruler(at: (0, -0.58), length: 7.2, width: 0.62, clamp: false,
    values: true, value-size: 0.72, colour: luma(60))
  fig += pt(Mc, fill: orange, r: 0.085)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.32, fill: orange)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += p-line(Mc, (Mc.at(0), Mc.at(1) + 0.22), stroke: orange, weight: 1.0)
  fig
}, padding: 0.35))
#cap[Le $3.6$ de la règle tombe sur le milieu. Un trait de chaque côté code $A M_c = M_c B$.]

```typ
#let Mc = midp(A, B)
#ruler(at: A, rotate: 0deg, length: dist(A, B),
       width: 0.62, clamp: false)
#ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
```

Sur un côté quelconque, on *aligne* la règle :

```typ
#ruler(
  at: A,
  rotate: vangle(vsub(C, A)),          // le long de [AC]
  length: dist(A, C),
  width: 0.62, clamp: false,
)
```

#warn[Le plancher de `ruler`][
  `width` est ramené à $1.5$ cm par défaut, `length` à $3$. Une règle
  posée *sous* un côté de 7 cm, si elle fait 1.5 cm de large, recouvre
  la moitié du triangle. `clamp: false` lève les deux planchers
  (largeur minimale alors $0.05$).
]

== Étape 2 — Les trois milieux

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += ticks(B, Ma, n: 3) + ticks(Ma, C, n: 3)
  fig += pt(Ma, fill: orange) + pt(Mb, fill: orange) + pt(Mc, fill: orange)
  fig += lab(Ma, [$M_a$], dx: 0.34, dy: 0.12, fill: orange)
  fig += lab(Mb, [$M_b$], dx: -0.36, dy: 0.10, fill: orange)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.30, fill: orange)
  fig += ruler(
    at: A, rotate: vangle(vsub(C, A)),
    length: dist(A, C), width: 0.55, clamp: false,
    values: false, colour: luma(70),
  )
  fig
}, padding: 0.4))
#cap[Trois milieux, trois codages distincts. La règle est posée sur $[A C]$.]

== Étape 3 — Tirer les trois médianes

On joint chaque sommet au milieu du côté opposé. Deux médianes suffisent ;
la troisième vérifie : si elle manque $G$, un milieu est faux.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(A, Ma, stroke: orange, weight: 1.15, role: "edge")
  fig += p-line(B, Mb, stroke: orange, weight: 1.05, role: "edge")
  fig += p-line(C, Mc, stroke: orange, weight: 1.05, role: "edge")
  fig += ticks(A, Mc, n: 1) + ticks(Mc, B, n: 1)
  fig += ticks(A, Mb, n: 2) + ticks(Mb, C, n: 2)
  fig += ticks(B, Ma, n: 3) + ticks(Ma, C, n: 3)
  fig += pt(Ma, fill: orange) + pt(Mb, fill: orange) + pt(Mc, fill: orange)
  fig += pt(G, fill: orange, r: 0.1)
  fig += lab(G, text(fill: orange)[$G$], dx: 0.30, dy: 0.22, fill: orange)
  fig += lab(Ma, [$M_a$], dx: 0.34, dy: 0.10, fill: orange)
  fig += lab(Mb, [$M_b$], dx: -0.36, dy: 0.10, fill: orange)
  fig += lab(Mc, [$M_c$], dx: 0.12, dy: 0.30, fill: orange)
  fig
}, padding: 0.4))
#cap[Les trois médianes se coupent en $G$. Pas d'équerre : ce n'est pas un angle droit.]

```typ
#p-line(A, Ma, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
#p-line(B, Mb, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
#p-line(C, Mc, stroke: rgb("#E8590C"), weight: 1.15, role: "edge")
```

Deux médianes suffisent. La troisième est une vérification : si elle
manque $G$, un milieu est faux.

#note[$G$ partage chaque médiane au tiers][
  $arrow(A G) = 2 thin arrow(G M_a)$.
  Dans le code, $G$ est tout simplement la moyenne des sommets — c'est la même chose :

  ```typ
  #let G = (
    (A.at(0) + B.at(0) + C.at(0)) / 3,
    (A.at(1) + B.at(1) + C.at(1)) / 3,
  )
  ```
]

= Orthocentre — les hauteurs, à l'équerre

L'*orthocentre* $H$ est l'intersection des *hauteurs*. Une hauteur est la
perpendiculaire menée d'un sommet au côté opposé. C'est *le* geste de
l'équerre : on pose un bord sur le côté, l'autre bord passe par le sommet.

#note[Ce que l'on code][
  Un *carré d'angle droit* à chaque pied $H_a$, $H_b$, $H_c$. Rien de plus :
  les hauteurs ne portent pas de traits d'égalité.
]

== Poser l'équerre sur un côté

`set-square` a l'angle droit à l'origine, la *base* (le petit côté) sur
$+x$, le *grand côté* sur $+y$. Pour la coller à une droite :

1. `at` : le point où l'on veut l'angle droit — en pratique le *pied*
   de la hauteur, ou n'importe quel point du côté si l'on cherche encore
   le pied ;
2. `rotate` : l'angle du côté, `vangle(vsub(C, B))` pour $(B C)$ ;
3. `flip` : si le grand côté part à l'opposé du sommet, on retourne
   l'équerre.

Le helper `square-on(at, along, toward)` fait ce test : `along` est un
vecteur directeur du côté, `toward` un vecteur vers le sommet. Si le
$+90 degree$ local n'est pas du bon côté, `flip` s'active.

== Étape 1 — Hauteur issue de $C$, équerre sur $(A B)$

$(A B)$ est horizontale, la perpendiculaire est verticale. L'équerre
s'assoit sur $A B$, l'angle droit au pied $H_c = (2.2, 0)$. Le grand
côté doit *dépasser* $C$ : on prend `length: dist(C, Hc) + 0.55`.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(C, Hc, stroke: purple, weight: 1.15, role: "edge")
  fig += pt(Hc, fill: purple)
  fig += lab(Hc, [$H_c$], dx: -0.40, dy: -0.28, fill: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.32, colour: purple)
  fig += square-on(Hc, vsub(B, A), vsub(C, Hc),
    length: dist(C, Hc) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[Un bord sur $(A B)$, l'autre passe par $C$. Le pied $H_c$ se lit au contact.]

```typ
#let Hc = foot(C, A, B)
#square-on(Hc, vsub(B, A), vsub(C, Hc), length: dist(C, Hc) + 0.55)
#ra-in(Hc, vsub(B, A), vsub(C, Hc), colour: rgb("#7048E8"))
#p-line(C, Hc, stroke: rgb("#7048E8"), weight: 1.15, role: "edge")
```

Dans une copie, l'élève *fait glisser* l'équerre le long de $(A B)$ jusqu'à
ce que l'autre bord rencontre $C$, *puis* trace. Sur la figure, on la pose
déjà au bon endroit — le pied est calculé par `foot(C, A, B)`, la projection
orthogonale.

== Étape 2 — Hauteur issue de $A$, équerre sur $(B C)$

Le côté n'est plus horizontal. `rotate` suit $(B C)$, `flip` rentre
l'équerre dans le triangle.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(C, Hc, stroke: purple.lighten(25%), weight: 0.8, role: "edge")
  fig += p-line(A, Ha, stroke: purple, weight: 1.15, role: "edge")
  fig += pt(Hc, fill: purple) + pt(Ha, fill: purple)
  fig += lab(Ha, [$H_a$], dx: 0.32, dy: 0.16, fill: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.28, colour: purple)
  fig += ra-in(Ha, vsub(C, B), vsub(A, Ha), size: 0.28, colour: purple)
  fig += square-on(Ha, vsub(C, B), vsub(A, Ha),
    length: dist(A, Ha) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[Équerre sur $(B C)$, grand côté vers $A$. Deux hauteurs suffisent déjà à donner $H$.]

```typ
#let Ha = foot(A, B, C)
#square-on(Ha, vsub(C, B), vsub(A, Ha), length: dist(A, Ha) + 0.55)
#ra-in(Ha, vsub(C, B), vsub(A, Ha), colour: rgb("#7048E8"))
```

Si le petit carré de codage *sort* du triangle, c'est que `rotate` pointe
vers le mauvais demi-plan. On ajoute $180 degree$, ou l'on prend
`vangle(vsub(B, C))` au lieu de `vangle(vsub(C, B))`.

== Étape 3 — La troisième hauteur, et $H$

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-line(A, Ha, stroke: purple, weight: 1.05, role: "edge")
  fig += p-line(B, Hb, stroke: purple, weight: 1.05, role: "edge")
  fig += p-line(C, Hc, stroke: purple, weight: 1.05, role: "edge")
  fig += ra-in(Ha, vsub(C, B), vsub(A, Ha), size: 0.26, colour: purple)
  fig += ra-in(Hb, vsub(C, A), vsub(B, Hb), size: 0.26, colour: purple)
  fig += ra-in(Hc, vsub(B, A), vsub(C, Hc), size: 0.26, colour: purple)
  fig += pt(Ha, fill: purple) + pt(Hb, fill: purple) + pt(Hc, fill: purple)
  fig += pt(H, fill: purple, r: 0.1)
  fig += lab(H, text(fill: purple)[$H$], dx: -0.32, dy: 0.24, fill: purple)
  fig += lab(Ha, [$H_a$], dx: 0.32, dy: 0.14, fill: purple, size: 9pt)
  fig += lab(Hb, [$H_b$], dx: -0.36, dy: 0.12, fill: purple, size: 9pt)
  fig += lab(Hc, [$H_c$], dx: -0.40, dy: -0.28, fill: purple, size: 9pt)
  fig += square-on(Hb, vsub(C, A), vsub(B, Hb),
    length: dist(B, Hb) + 0.55, colour: luma(65))
  fig
}, padding: 0.4))
#cap[Les trois hauteurs et leurs trois angles droits. $H$ est intérieur : le triangle est acutangle.]

```typ
#let H = line-inter(A, Ha, B, Hb)   // ou orthocenter(A, B, C)
```

#note[Triangle obtusangle][
  Si un angle est obtus, l'orthocentre sort du triangle et deux pieds
  tombent sur les *prolongements*. `foot` le calcule quand même (le $t$
  de la projection n'est plus dans $[0, 1]$). On prolonge le côté en
  tiretés avec `line-ext`, et l'on pose l'équerre sur ce prolongement.
]

= Les quatre centres ensemble

Sur *tout* triangle, $O$, $G$ et $H$ sont alignés : c'est la *droite
d'Euler*, et $G$ est au tiers de $[O H]$ du côté de $O$ :

$ arrow(O G) = 1/3 thin  arrow(O H) $

$I$ n'est sur cette droite que dans les triangles isocèles.

#align(center, geom({
  let fig = abc-figure(A, B, C)
  fig += p-circle(O, R, stroke: blue, weight: 1.15)
  fig += p-circle(I, r-in, stroke: green, weight: 1.1)
  fig += p-line(A, Ma, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(B, Mb, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(C, Mc, stroke: orange.lighten(20%), weight: 0.6, role: "edge")
  fig += p-line(A, Ha, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += p-line(B, Hb, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += p-line(C, Hc, stroke: purple.lighten(25%), weight: 0.6, role: "edge")
  fig += line-ext(O, H, beyond: 0.7, stroke: red, weight: 1.2, dash: none)
  fig += pt(O, fill: blue, r: 0.09)
  fig += pt(I, fill: green, r: 0.09)
  fig += pt(G, fill: orange, r: 0.09)
  fig += pt(H, fill: purple, r: 0.09)
  fig += lab(O, [$O$], dx: 0.30, dy: -0.26, fill: blue)
  fig += lab(I, [$I$], dx: -0.30, dy: 0.22, fill: green)
  fig += lab(G, [$G$], dx: 0.30, dy: 0.20, fill: orange)
  fig += lab(H, [$H$], dx: -0.30, dy: 0.26, fill: purple)
  fig
}, padding: 0.5))
#cap[$O$, $G$, $H$ alignés (rouge). $I$ est à l'écart : $A B C$ n'est pas isocèle.]

== Récapitulatif des gestes

#table(
  columns: (auto, auto, 1fr, auto),
  inset: 7pt,
  stroke: 0.4pt + luma(210),
  fill: (_, y) => if y == 0 { blue.lighten(82%) } else if calc.odd(y) { luma(248) },
  [*Centre*], [*Lignes*], [*Instrument*], [*Codage*],
  text(fill: blue, weight: "bold")[$O$], [médiatrices], [compas, deux arcs égaux],
    [$A M = M B$, angle droit],
  text(fill: green, weight: "bold")[$I$], [bissectrices], [compas, arc puis deux arcs],
    [arcs d'angles, rayons $perp$],
  text(fill: orange, weight: "bold")[$G$], [médianes], [règle (milieux), équerre (trait)],
    [traits d'égalité des milieux],
  text(fill: purple, weight: "bold")[$H$], [hauteurs], [équerre posée sur le côté],
    [angle droit à chaque pied],
)

= Référence rapide

== `geom`

```typ
#geom(body, mode: "clean", roughness: 1.0, seed: 1,
      colour: black, frame: none, padding: 0.25)
```

`body` est un tableau de primitives. `frame: (x0, x1, y0, y1)` fige
l'étendue au lieu de l'ajuster au contenu — utile pour empiler des étapes
*à la même échelle*.

== `compass(from, to)`

| Argument | Défaut | |
|---|---|---|
| `leg` | `6.0` | longueur d'une branche, cm |
| `scale` | `1.0` | réduit l'instrument, *garde* les pieds |
| `flip` | `false` | bascule de l'autre côté de `[from to]` |
| `pencil-colour` | rouge | fût du crayon |
| `pencil-lead` | `auto` (noir) | mine ; passer la même couleur que le fût |
| `show-pencil` | `true` | |

Si l'écart des deux points dépasse $2 times "leg" times "scale"$, les
jambes saturent et les pieds ne joignent plus. On augmente `leg` ou l'on
rapproche les points.

== `set-square`

| Argument | Défaut | |
|---|---|---|
| `at` | `(0,0)` | *l'angle droit* |
| `rotate` | `0deg` | direction de la base ($+x$ local) |
| `length` | `10` | grand côté ; plancher $4.5$ si `clamp: true` |
| `flip` | `false` | retournement sur la table |
| `values` | `true` | chiffres ; `false` garde les ticks |
| `clamp` | `true` | |

`square-on(at, along, toward)` (ce guide) choisit `rotate` et `flip`.

== `ruler`

Zéro à `at`, vers `rotate`. `corner: 0.12` adoucit les bouts (pas une
gélule). `corner: 0` : coins vifs. `value-pos: "m"` (milieu), `"h"`
(haut), `"b"` (bas, tête-bêche), combinables (`"hb"`).

== `right-angle`

```typ
#right-angle(at: vertex, rotate: 0deg, size: 0.32, colour: black)
```

Carré *ouvert*, sommet en retrait. `rotate` = direction du premier côté.

== Primitives de construction

```typ
p-line(A, B, stroke: luma(120), weight: 1.0, dash: "dashed", role: "edge")
p-arc(centre, r, a0, a1, stroke: blue, dash: "dashed")
p-circle(centre, r, stroke: blue, weight: 1.3)
p-label(pos, [A], size: 10pt, fill: black)
```

`role: "edge"` (défaut des outils) ou `"tick"` / `"detail"` : en mode
`rough`, les ticks tremblent trois fois moins, sinon un trait de 2 mm
fond à l'amplitude qui habille une règle de 12 cm.

== Formules utilisées

- $O$ est l'intersection des médiatrices.
- $I = (a A + b B + c C) / (a + b + c)$ avec $a = B C$, $b = A C$, $c = A B$.
- $G = (A + B + C) / 3$.
- $H$ est l'intersection de deux hauteurs ; $H_a$ est le projeté de $A$ sur le côté $B C$.

#v(0.8em)
#line(length: 100%, stroke: 0.4pt + luma(180))
#v(0.25em)
#text(size: 8pt, fill: luma(110))[
  `geomtools` 0.1.0 — portage d'`OutilsGeomTikZ` de Cédric Pierquet
  (LPPL 1.3c). Il n'entretient ni n'endosse ce portage. Guide rédigé pour
  le triangle $A(0,0)$, $B(7.2,0)$, $C(2.2, 4.8)$ ; les listings se recopient
  tels quels une fois `helpers.typ` importé.
]
