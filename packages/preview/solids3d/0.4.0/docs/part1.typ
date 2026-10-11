#import "_h.typ": *

= #T("Getting started", "Prise en main")

== #T("What solids3d does", "Ce que fait solids3d")

#T[
`solids3d` draws three-dimensional figures directly in a Typst document: solids of revolution (sphere, cone, cylinder, torus), cubes and blocks, parametric surfaces and meshes, 3D curves, *knots and links*, calligraphic *braces*, and school-geometry annotations (dimensions, right angles, equal-edge marks). Every figure is an ordinary vector box: it scales, it can be put in a table, a `figure`, a grid, and the PDF stays vector.

The package is built around *one* function, `fig`. You give it what you want to see; it chooses the camera, the light, the shading, the outlines and the page-ready size. For anything finer, the full `picture` / `draw` machinery inspired by Asymptote's `three` and `solids` modules is available (chapters “advanced layer”).

Since 0.3 the pens, outlines, knots and braces are drawn by #link("https://github.com/fergousA/nibart")[nibart] (MIT).
][
`solids3d` dessine des figures en trois dimensions directement dans un document Typst : solides de révolution (sphère, cône, cylindre, tore), cubes et pavés, surfaces paramétriques et maillages, courbes 3D, *nœuds et entrelacs*, *accolades* calligraphiques, et annotations de géométrie de collège (cotes, angles droits, codages d'arêtes). Chaque figure est une boîte vectorielle ordinaire : elle se met à l'échelle, se place dans un tableau, une `figure`, une grille, et le PDF reste vectoriel.

Le paquet est construit autour d'*une seule* fonction, `fig`. Vous lui donnez ce que vous voulez voir ; elle choisit la caméra, la lumière, l'ombrage, les contours et la taille. Pour aller plus loin, toute la machinerie `picture` / `draw` inspirée des modules `three` et `solids` d'Asymptote reste disponible (chapitres « couche avancée »).

Depuis la 0.3, les plumes, contours, nœuds et accolades sont dessinés par #link("https://github.com/fergousA/nibart")[nibart] (MIT).
]

== #T("Installation", "Installation")

#raw("#import \"@preview/solids3d:" + pkg.version + "\": *", lang: "typ", block: true)

#if ns == "local" [
  #T[*Local edition*: install it with `install.sh` (Linux, macOS) or `install.ps1` (Windows); the package then lives in the `@local` namespace. It needs the *local* edition of nibart (`@local/nibart:0.3.0`), installed the same way; the installer checks it.][*Édition locale* : installez-la avec `install.sh` (Linux, macOS) ou `install.ps1` (Windows) ; le paquet vit alors dans l'espace de noms `@local`. Elle a besoin de l'édition *locale* de nibart (`@local/nibart:0.3.0`), installée de la même façon ; l'installateur le vérifie.]
] else [
  #T[*Typst Universe edition*: nothing to install, Typst downloads the package (and `@preview/nibart:0.3.0`) on first use. A local edition (zip with an installer) installs the same package under `@local`.][*Édition Typst Universe* : rien à installer, Typst télécharge le paquet (et `@preview/nibart:0.3.0`) au premier usage. Une édition locale (zip avec installateur) installe le même paquet sous `@local`.]
]

#T[
The star import brings in a lot of short names (`draw`, `light`, `plane`, `sphere`…). If a name clashes with yours, import only what you need: `#import "…": fig, sphere, torus, brace3`.
][
L'import étoilé apporte beaucoup de noms courts (`draw`, `light`, `plane`, `sphere`…). Si un nom entre en conflit avec le vôtre, n'importez que le nécessaire : `#import "…": fig, sphere, torus, brace3`.
]

== #T("Your first figure", "Votre première figure")

#T[One line: a solid inside `fig`. That is all.][Une ligne : un solide dans `fig`. C'est tout.]

#ex(```
// a lit, outlined sphere § une sphère éclairée et cernée
fig(sphere(1), size: 4cm)
```)

#T[Several solids: they share the same camera and light. Colours come from `paint(shape, colour)`.][Plusieurs solides : ils partagent la même caméra et la même lumière. Les couleurs viennent de `paint(solide, couleur)`.]

#ex(```
fig(
  cube(1, c: (0, -1.8, 0.5)), // c: = centre § c: = centre
  paint(cone(0.7, 1.6, c: (-0.6, 0.3, 0)), rgb("#7aa6d8")),
  paint(sphere(0.7, c: (1.2, 1.4, 0.7)), orange),
  size: 5.5cm)
```)

== #T("The simple API at a glance", "L'API simple en un coup d'œil")

#T[Five ideas are enough for most figures.][Cinq idées suffisent pour la plupart des figures.]

#table(columns: (1.35fr, 1fr), stroke: (x: none, y: 0.3pt + luma(200)), inset: (x: 5pt, y: 4pt),
  table.header([#T("You write", "Vous écrivez")], [#T("You get", "Vous obtenez")]),
  raw("fig(…items, size, view, style)", lang: "typc"), T[a finished figure: camera, light, shading and outlines chosen for you][une figure finie : caméra, lumière, ombrage et contours choisis pour vous],
  raw("sphere(r)  cone(r, h)  cylinder(r, h)  torus(R, r)  cube(a)  brick(l, w, h)", lang: "typc"), T[the solids (option `c:` = centre)][les solides (option `c:` = centre)],
  raw("paint(shape, colour)", lang: "typc"), T[a coloured solid][un solide coloré],
  raw("view: \"iso\" \"front\" \"top\" \"side\" \"low\" \"high\" (az, el)", lang: "typc"), T[the camera][la caméra],
  raw("style: \"shaded\" \"engraving\" \"banknote\" \"etching\" \"vintage\" \"pencil\"", lang: "typc"), T[the look: Phong shading, copper-plate engraving, wavy banknote lines, blue-ink etching, old-plate hatching, pencil][le rendu : ombrage de Phong, gravure sur cuivre, billet de banque ondulé, eau-forte bleue, hachures de planche ancienne, crayon],
  raw("trefoil()  torus-knot(p, q)  hopf-link()  borromean()", lang: "typc"), T[knots and links: just give them to `fig`][nœuds et entrelacs : donnez-les simplement à `fig`],
  raw("brace3(a, b, label)", lang: "typc"), T[a calligraphic brace placed outside the figure][une accolade calligraphique placée à l'extérieur de la figure],
  raw("plate(figure, title: …, caption: …)", lang: "typc"), T[an engraved frame around a figure][un cadre gravé autour d'une figure],
)

== #T("Choosing the view", "Choisir la vue")

#T[`view` accepts a name or a pair `(azimuth, elevation)` in degrees. `persp: true` switches to a perspective camera.][`view` accepte un nom ou un couple `(azimut, élévation)` en degrés. `persp: true` passe en caméra perspective.]

#ex(```
let s = cone(1, 1.6)
grid(columns: 3, gutter: 4pt,
  fig(s, size: 2.7cm, view: "top"),
  fig(s, size: 2.7cm, view: "front"),
  fig(s, size: 2.7cm, view: (60, 35), persp: true))
```)

== #T("Choosing the style", "Choisir le style")

#T[The same scene in every style. `engraving` and `banknote` replace the shading by a screen of lines whose thickness follows the tone; `etching` is the same in blue ink on white paper.][La même scène dans tous les styles. `engraving` et `banknote` remplacent l'ombrage par une trame de lignes dont l'épaisseur suit le ton ; `etching` est la même chose à l'encre bleue sur papier blanc.]

#ex(```
let scene(st) = fig(torus(1, 0.38), size: 2.9cm, style: st)
grid(columns: 3, gutter: 4pt,
  scene("shaded"), scene("engraving"), scene("banknote"),
  scene("etching"), scene("vintage"), scene("pencil"))
```, cols: (1fr, 1.25fr))

== #T("Dimensions with braces", "Cotes avec accolades")

#T[`brace3(a, b, label)` joins two 3D points. The brace is placed on the outside of the figure by itself.][`brace3(a, b, étiquette)` joint deux points 3D. L'accolade se place d'elle-même à l'extérieur de la figure.]

#ex(```
fig(cone(1, 1.8), size: 4.4cm,
  brace3((0, 0, 0), (0, 0, 1.8), $h$),
  brace3((-1, 0, 0), (1, 0, 0), $2r$))
```)

== #T("Knots and links", "Nœuds et entrelacs")

#T[Give curves to `fig`: they become tubes, interrupted or woven at the crossings. `tube` is the width, `knot-style` is `"weave"` (default) or `"gap"`.][Donnez des courbes à `fig` : elles deviennent des tubes, interrompus ou tissés aux croisements. `tube` est la largeur, `knot-style` vaut `"weave"` (défaut) ou `"gap"`.]

#ex(```
grid(columns: 3, gutter: 4pt,
  fig(trefoil(), size: 3cm, tube: 10pt),
  fig(figure-eight(), size: 3cm, tube: 8pt,
    knot-style: "gap", view: (60, 50)),
  fig(torus-knot(3, 5, R: 2, r: 0.8), size: 3cm,
    tube: 6pt, view: "top"))
```, cols: (1fr, 1.5fr))

== #T("An engraved plate", "Une planche gravée")

#T[`plate` wraps any content (a figure, a grid of figures) in a frame with notched corners and a calligraphic flourish.][`plate` entoure n'importe quel contenu (une figure, une grille de figures) d'un cadre à coins échancrés et d'un fleuron calligraphique.]

#ex(```
plate(title: "Géométrie", number: "I", width: 7cm,
  caption: [Fig. 1],
  fig(torus(1, 0.38), size: 5cm, style: "banknote"))
```, cols: (1fr, 1.2fr))
