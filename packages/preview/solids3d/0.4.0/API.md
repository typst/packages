# Référence API de `solids3d`

## API simple (0.3)

```typst
#fig(..objets, size: 6cm, view: "iso", style: "shaded", light: auto, rim: auto, persp: false,
     tube: 7pt, knot-style: "weave", engraving: auto, ..options-de-picture)
```

- objets : solides (`sphere`, `cylinder`, `cone`, `torus`, `cube`, `brick`, `revolution`…), surfaces, chemins 3D,
  courbes de nœud (toutes les courbes d'un appel forment un seul entrelacs), `paint(forme, couleur)`, commandes
  (`brace3`, `draw`, `label`, `dimension3`…) ;
- `view` : `"iso" "front" "back" "side" "left" "top" "bottom" "low" "high"`, `(azimut, élévation)` ou une projection ;
- `style` : `"shaded" "engraving" "banknote" "etching" "vintage" "pencil"` ;
- `paint(forme, couleur)`, `cube(a, c:)`, `brick(l, w, h, c:)`, `view-projection(v, persp:)` ;
- `sphere`, `cylinder`, `cone`, `torus` acceptent `c:` (centre) ;
- `brace3(a, b, étiquette, flip: auto, distance: 6pt, outside: true, offset:, kind:, amplitude:, light:, heavy:, pen:, gap:)`.

Le manuel (`docs/manual-en.pdf`, `docs/manual-fr.pdf`) documente chaque fonction, tous ses paramètres, avec un exemple.


Utilisation publique :

```typst
#import "@preview/solids3d:0.4.0": *
```

Les groupes inspirés des modules Asymptote sont exportés comme modules nommés :
`three`, `three_surface`, `three_light`, `graph3mod`, `solidsmod`, `college`, `vintage` et
`obj3`.

Le package vise Typst **0.15.1** et reprend les conventions du module
`solids` d'Asymptote. Toutes les fonctions de `lib.typ` sont exportées par
l'import étoilé.

## Image et projection

```typst
#let P = orthographic(5, 4, 3)
#let Q = perspective(camera: (5, 4, 3), up: Z, target: O, zoom: .95)
#picture(width: 6cm, projection: P, draw(surface(sphere(O, 1)), paleblue))
```

- `orthographic(...)`, `perspective(...)`, `project(...)`, `project-point(...)`
  et `project-path(...)` ;
- `picture(..., shading: "smooth" | "flat" | "none", backend: "svg" |
  "typst", zsort: "command" | "global", refine: true | false,
  style: "none" | "pencil" | "vintage")` ;
- `limits`, `xaxis3`, `yaxis3`, `zaxis3`, `axes3`, `dot`, `label`, `Label`.

### Sketch 2D statique

`sketch(...)` fournit une petite couche de dessin déterministe inspirée de
p5.js, sans runtime JavaScript : le callback reçoit un contexte qui renvoie
des commandes SVG vectorielles.

```typst
#let scene = ctx => {
  let points = ()
  for i in range(180) {
    points.push((
      (ctx.random)(index: i * 2, a: 5, b: 95),
      (ctx.random)(index: i * 2 + 1, a: 5, b: 95),
    ))
  }
  ((ctx.polyline)(points, stroke: blue, width: .7),)
}
#sketch(width: 7cm, height: 5cm, seed: 17, draw: scene)
```

Le contexte expose `random`, `noise`, `line`, `circle`, `ellipse`, `rect`,
`polyline`, `polygon`, `transform`, `polar` et `project3`. Les fonctions
`sketch-random(seed:, index:, a:, b:)` et `sketch-noise(x, y:, z:, seed:,
octaves:)` sont également exportées. `project3` convertit un point 3D en
coordonnées de la vue 2D à l'aide d'une projection existante. Le résultat est
un SVG intégré, déterministe et imprimable.

`"smooth"` est le mode par défaut : les patchs disposant de normales aux
coins reçoivent un gradient vectoriel. `"flat"` conserve l'éclairage mais
utilise une couleur par patch ; `"none"` conserve la couleur diffuse et ne
calcule pas l'éclairage.

## Solides

- `revolution`, `sphere`, `cylinder`, `cone`, `torus` ;
- `tube3(spine, width: ..., n: ..., samples: ..., caps: ..., color: ...)` (alias `tube`) construit une surface de tube polygonal autour d'un chemin 3D. `width` est le diamètre, `n` le nombre de côtés, et `samples` le nombre de subdivisions par segment de Bézier ; le repère transporté évite les torsions brutales des repères de Frenet ;
- `surface`, `patch`, `extrude`, `cone-over` ;
- `unitsphere`, `unithemisphere`, `unitcylinder`, `unitcone`,
  `unitsolidcone`, `unitcube`, `unitdisk`, `unitplane`, `unitfrustum`,
  `unitbox`, `box3` ;
- `solid-plot(shape, size: ..., projection: ..., surfacepen: ..., meshpen: ...,
  hatch: ..., stipple: ..., outline: ...)` (alias `plot3d`) compose une
  représentation complète d'un solide à partir de tracés 2D projetés ;
- `draw(revolution, m: ..., n: ..., frontpen: ..., backpen: ...,
  longitudinalpen: ...)`, `skeleton`, `transverse`, `longitudinal`,
  `silhouette` ; pour une surface, `hatch: vintage-hatch(...)` ajoute des
  hachures vectorielles par patch ;
- `mesh-edges(vertices, faces, indices: "zero" | "one", boundary: false)`
  retourne les chemins 3D des arêtes uniques d'un maillage, pour les dessiner
  comme wireframe avec `draw(mesh-edges(...), pen: ...)`. `boundary: true`
  conserve uniquement les arêtes incidentes à une face.

## Surfaces paramétriques et maillages

### Grille paramétrique

```typst
#let s = surface-grid(
  (u, v) => (u, v, .2 * calc.sin(2 * u) * calc.cos(2 * v)),
  -1.5, 1.5, -1.5, 1.5,
  nu: 24, nv: 20,
)
```

Signature :

```text
surface-grid(f, u0, u1, v0, v1,
  nu: 16, nv: 12,
  cyclic-u: false, cyclic-v: false,
  normal: auto, color: none)
```

`f(u, v)` retourne un triplet. `normal` vaut soit `auto`, soit un triplet
constant, soit une fonction `normal(u, v)`. `color` vaut soit une couleur/un
pen, soit une fonction `color(u-centre, v-centre)`. Les alias
`parametric-surface` et `parametric` ont la même signature.

### Champ de hauteurs

```typst
#let s = heightfield(
  (x, y) => .15 * (x * x - y * y),
  -1, 1, -1, 1, nx: 20, ny: 20,
)
```

### Maillage indexé

```typst
#let vertices = ((0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0))
#let faces = ((0, 1, 2, 3),)
#let s = surface-mesh(vertices, faces)
```

`surface-mesh(vertices, faces, indices: "one")` accepte les indices
commençant à 1. Les normales sont moyennées aux sommets par défaut ;
`normal` peut être un triplet ou une fonction `normal(vertex)`. Passez
`smooth: false` pour conserver une normale constante par face (polyèdres
facettés). `color` peut être une couleur ou une fonction
`color(face-index, face-centre)`. `mesh-surface` est un alias.

## Texte RTL et multilingue

Le moteur de dessin est compatible avec les textes RTL pris en charge par
Typst. Pour l'arabe ou l'hébreu, définissez la langue et la direction dans le
document, et choisissez une police qui contient les glyphes nécessaires :

```typst
#set text(font: "DejaVu Sans", lang: "ar", dir: rtl)
#picture(width: 7cm,
  draw(cuboid(length: 3, width: 2, height: 1.5), paleblue),
  point3([A], O),
  dimension3([الطول = 3 cm], O, (3, 0, 0), offset: (0, -.4, 0)),
  callout3([رأس], (3, 2, 1.5), (4, 2, 2), pen: red),
)
```

Les labels, les légendes, les flèches et les cotes peuvent contenir de
l'arabe ou de l'hébreu. Les nombres, expressions mathématiques et identifiants
latins peuvent être placés dans un contenu LTR local avec `text(dir: ltr)[...]`.
La direction du texte ne miroir pas la scène : `E`, `W`, `N` et `S` restent des
directions géométriques physiques, ce qui évite de changer involontairement la
lecture d'une figure. L'exemple complet est
[`examples/rtl.typ`](examples/rtl.typ).

## Figures pédagogiques collège

Le module `education.typ` est réexporté par `lib.typ`. Il ajoute des
constructeurs d'annotations qui renvoient directement des commandes
compatibles avec `picture` :

```typst
#let A = (0, 0, 0)
#let B = (4, 0, 0)
#picture(width: 6cm,
  draw(cuboid(length: 4, width: 2, height: 2), withopacity(paleblue, .65)),
  dimension3([AB = 4 cm], A, B, offset: (0, -0.5, 0)),
  point3([A], A),
  callout3([arête], A, (-1, -1, 1), pen: red),
)
```

- `point3(label, point, align: ..., pen: ..., size: ..., dx: 0, dy: 0)` marque
  un sommet ou un centre ; `dx` et `dy` déplacent le nom dans le plan projeté ;
- `callout3(label, target, label-at, align: ..., pen: ..., arrow: ..., dx: 0, dy: 0)`
  place une légende avec une flèche orientée vers l'élément désigné ; il ne
  dessine pas l'élément lui-même. Pour une diagonale `AG`, ajouter par exemple
  `draw(line3(A, G), dashed)` ;
- `dimension3(label, a, b, offset: ..., align: ..., pen: ..., arrow: ..., rotate: auto, dx: 0, dy: 0, extensions: true, extension-pen: auto)`
  dessine une ligne de cote avec flèches et, par défaut, ses deux lignes
  d'attache ; le texte est centré sur la cote, suit automatiquement sa tangente
  projetée et reste lisible modulo 180°. `pen` règle la ligne de cote et ses
  flèches ; il peut être combiné avec `solid`, `dashed` ou `dotted`. Passer
  `extensions: false` pour supprimer les petits traits d'attache lorsque la
  cote suffit à relier les extrémités, ou utiliser `extension-pen` pour leur
  appliquer indépendamment `solid`, `dashed` ou `dotted`. `dx`/`dy` déplacent
  l'annotation sans déplacer la ligne 3D ; les nombres sont en unités de la
  figure, les longueurs Typst (`2pt`) restent absolues. Utiliser `rotate: false`
  pour conserver un texte horizontal ou fournir un angle Typst (`rotate: 12deg`)
  pour un cas particulier ;
- `edge-code3(a, b, count: ..., size: ..., spacing: ...)` pose les traits
  conventionnels d'égalité sur une arête ; `equal-edges3(((A, B), (C, D)),
  count: ...)` applique le même code à plusieurs arêtes ;
- `right-angle3(a, b, c)` dessine le carré de l'angle droit en `b` ;
  `angle-mark3(a, b, c, radius: ..., label: ...)` dessine un arc pour un
  angle non droit et `angle-code3(..., right: true)` choisit directement le
  carré ; pour un angle droit, préférer le carré afin d'éviter un codage
  ambigu par un arc marqué 90° ;
- `length3-label` est un alias de `dimension3`, `segment-label3` un alias
  supplémentaire et `construction3` une ligne de construction ;
- `cuboid` / `pave-droit`, `regular-pyramid` et `regular-prism` fournissent
  des solides prêts à annoter ;
- `regular-polygon3` construit une base polygonale réelle ;
- `diagonal3`, `height3`, `regular-tetrahedron`, `regular-octahedron`,
  `frustum3`, `right-prism3`, `cuboid-vertices` et `cuboid-edges` enrichissent
  les figures collège.

Les planches [`examples/college.typ`](examples/college.typ) et
[`examples/college-annotations.typ`](examples/college-annotations.typ) montrent
un pavé droit, un cône, un cylindre, une boule, une pyramide régulière et un
prisme droit triangulaire. La seconde est conçue comme un catalogue de recettes
à copier-coller pour les codages, les cotes, les hauteurs et les repères. Elles
sont inspirées par les familles de figures documentées dans
[pas-cours](https://ctan.org/pkg/pas-cours), mais n'en incorporent pas le code.

## Façades Asymptote

Les fichiers `three.typ`, `three-surface.typ`, `three-light.typ`, `graph3.typ`,
`solids.typ` et `obj3.typ` sont des réimplémentations Typst indépendantes des
interfaces géométriques correspondantes. Depuis l'import du package :

```typst
#import "@preview/solids3d:0.4.0": three, college, graph3mod

#let T = college.regular-tetrahedron()
#three.picture(
  size: 5cm,
  projection: three.orthographic(5, 4, 3),
  three.draw(T, three.paleblue),
)
#graph3mod.graph3-plot(t => (t, t * t, t), -1, 1, axes: false)
```

`graph3-plot` accepte `n`, `join`, `pen`, `axes`, `xlabel`, `ylabel` et
`zlabel`. `parametric-plot3` est son alias.

## Styles vectoriels optionnels

Les styles sont désactivés par défaut. Ils se branchent après la projection,
ce qui conserve la projection actuelle, le tri de profondeur et la sortie
vectorielle.

```typst
#let P = orthographic(6, 3, 2)
#picture(width: 7cm, projection: P, style: "vintage",
  draw(surface(unitcube), hatch: vintage-hatch(spacing: .22, angle: 35)),
  draw(line3(O, (1, 1, 1)), pencil-pen(paint: vintage-ink), arrow: Arrow3),
)
```

- `pencil-pen(paint: black, thickness: .65pt, roughness: .10,
  passes: 1, seed: 0, opacity: .82, nib-major: 1.15,
  nib-angle: 24deg, nib-ratio: .42, pressure: none, samples: none)` décrit une
  enveloppe de plume elliptique. `samples` peut recevoir des échantillons
  explicites `(arclength, a, b, angle)` ou leurs dictionnaires nommés afin de
  faire varier la largeur imprimable le long du trait. L'enveloppe est calculée
  par nibart (plume elliptique) puis émise comme un chemin rempli SVG ou
  Typst, jamais comme un bitmap. `pressure` peut recevoir le dictionnaire
  `{minimum-axis: ..., period: ..., seed: ...}` ;
  une valeur numérique reste acceptée comme raccourci de compatibilité ;
  `roughness` reste accepté pour compatibilité de l'API (aucun wobble Typst n'est ajouté) ;
  `plain: true` sur un dictionnaire de plume désactive explicitement la
  promotion automatique vers l'enveloppe elliptique lorsqu'un style
  d'illustration est actif ;
- `vintage-shaded(shape, hatch: ..., stipple: ..., pen: ..., outline: ...)`
  renvoie les deux commandes du motif de l'atlas : une surface dont les
  marques sont posées avant projection, puis un contour au premier plan.
  `outline: auto` reprend la plume du shading ; `outline: none` supprime le
  contour ; `outline: (plain: true, paint: ..., thickness: ...)` garde un
  tracé normal tandis que le remplissage reste une enveloppe elliptique ;
- `pencilize-pen(pen, roughness: ..., passes: ..., seed: ..., opacity: ...,
  `nib-major: ..., nib-angle: ..., nib-ratio: ..., pressure: ...)` conserve
  les propriétés d'une plume existante et lui ajoute l'effet ; `passes: 1` est
  le défaut, les passes supplémentaires sont optionnelles ;
- `style: "pencil"` choisit une esquisse monochrome : les contours, axes et
  `meshpen` utilisent `pencil-ink`, les back-lines implicites sont supprimées
  et un `backpen` explicitement fourni reste conservé. Les surfaces implicites
  restent sur le papier et sont suggérées par des hachures et un stippling
  séparés du contour ;
- `style: "vintage"` ajoute `vintage-paper` comme fond si aucun fond n'est
  spécifié, utilise `vintage-ink`/`vintage-pale-ink`, supprime les back-lines
  implicites et suggère les matériaux implicites par des marques gravées
  plutôt que par un aplat coloré ; une surface sans matériau, `hatch:` ni `stipple:` est gravée comme dans le style
  `engraving` (trame de lignes dont l'épaisseur suit l'éclairage, option `engraving:` pour la régler) ;
  les surfaces avec `hatch:`/`stipple:`/matériau explicite utilisent le hachage par patch ;
- `vintage-hatch(spacing: ..., angle: ..., cross: ..., broken: ..., segment: ..., gap: ..., light: ..., count: ..., length: ..., crosshatch: ..., seed: ..., pen: ...)` est une
  spécification de hachures courtes. `draw(surface(...), hatch: spec)` permet de
  les régler ou de les désactiver avec `hatch: none`. `spacing` et `angle` sont
  les paramètres principaux du hachage par patch projeté ; `count`, `length`,
  `crosshatch` et `seed` sont acceptés mais ignorés depuis la 0.4 ;
- `vintage-stipple(count: ..., seed: ..., min-size: ..., max-size: ..., gamma: ..., distribution: ..., light: ..., max-patch-count: ..., pen: ...)` ; `max-patch-count` limite la densité par patch du fallback vectoriel pur.
  est une spécification de stippling. `draw(surface(...), hatch: none, stipple: spec)`
  échantillonne des cercles dans le contour
  projeté de chaque patch. `seed` rend le résultat déterministe, `gamma`
  contrôle la distribution des rayons et `lit: true` adapte densité et taille à
  la lumière. Les points sont séparés du contour et restent vectoriels dans les
  backends SVG et natif ; `stipple: none` les désactive.
- `vintage-material(color: vintage-wash, opacity: .82)`,
  `vintage-picture(...)`, `pencil-picture(...)` et `pencil-draw(...)` sont des
  aides de style. `pencil-draw(...)` retire ses backpens implicites pour les
  squelettes ; un backpen explicite est conservé.

Les constantes de palette exportées sont `vintage-paper`, `vintage-ink`,
`vintage-pale-ink`, `vintage-wash` et `pencil-ink`. Un matériau ou une plume
colorés explicitement restent possibles ; ils constituent alors une exception
volontaire au mode monochrome. Le paquet ne contient plus de module WebAssembly depuis la 0.4 : les plumes sont calculées par nibart et les
surfaces gravées par `src/engrave.typ`.

## nibart : gravure, nœuds, accolades, cartouche (0.2)

| Commande | Rôle |
|---|---|
| `picture(engine: "nibart")` | moteur des plumes et contours (seule valeur depuis la 0.4 ; `"wasm"` a été supprimé) |
| `picture(style: "engraving", engraving: engraving(...))` | rendu gravure au burin |
| `engraving(spacing: 2.1pt, angle: 38, cross: true, cross-angle: 78, wave: none, gain: 1.0, minimum: 0.13pt, contours: true, nib-width: 1.35, nib-angle: 38, nib-ratio: 0.36, ink: auto, paper: auto, step: 1.6pt)` | options de la gravure ; `wave: (amplitude:, length:, shift:)` |
| `engraved(shape, m: 48, rim: auto, edges: none, color: none)` | surface hachurée + silhouette (+ arêtes) |
| `engraving-ink`, `engraving-paper` | couleurs par défaut |
| `knot3(..brins, samples: 120, width: 7pt, colors: auto, style: "gap" \| "weave", gap: auto, outline: auto, ink: auto, flips: ())` | nœuds tubulaires |
| `trefoil(scale:)`, `figure-eight(scale:)`, `torus-knot(p, q, R:, r:)`, `hopf-link(R:)`, `borromean(a:, b:)` | courbes prêtes à l'emploi |
| `brace3(a, b, label: none, offset: (0,0,0), kind: "brace" \| "paren" \| "paren-straight", amplitude: 9pt, flip: false, light: 0.35pt, heavy: 1.7pt, pen: auto, gap: 5pt)` | accolade calligraphique |
| `plate(body, title:, subtitle:, number:, caption:, ink:, paper:, pad: 16pt, band: 2.2pt, corner: 9pt, border: true, width: auto, font: auto, ornament: true)` | cartouche gravé |

## Couleurs, matériaux et traits

- couleurs `red`, `paleblue`, `lightgray`, etc. ; `rgbf`, `gray`,
  `color-add`, `color-scale`, `withopacity` ;
- `pen`, `linewidth`, `linetype`, `dashed`, `dotted`, `nullpen`,
  `pencil-pen`, `pencilize-pen` ;
- `material`, `light`, `White`, `Headlamp`, `Viewport`, `nolight` ;
- `Arrow3`, `BeginArrow3`, `Arrows3`, `Arrow`, `BeginArrow`, `Arrows`.

## Chemins et transformations

`line3`, `spline3`, `guide3`, `Circle3`, `Arc3`, `circle3`, `arc3`, `plane`,
`graph3`, `subpath`, `reltime`, `arclength`, `apply`, `shift`, `scale3`,
`rotate3`, `reflect3`, `compose` et les opérations vectorielles (`vadd`,
`vsub`, `vmul`, `vdot`, `vcross`, `vunit`).

## Compatibilité connue

Le rendu est vectoriel 2D, comme `settings.render = 0` d'Asymptote ; il ne
remplace pas le raster OpenGL/PRC. `intersectionpoints`, `polyhedron_js` et
les transformations 3D de `Label` ne sont pas implémentés. Les traits cachés
sont obtenus en séparant explicitement les parties `front` et `back` du
squelette, ou en dessinant les objets dans l'ordre voulu ; `zsort: "global"`
étend le tri aux patchs de surface mais ne réalise pas un depth-buffer de
rasterisation.
