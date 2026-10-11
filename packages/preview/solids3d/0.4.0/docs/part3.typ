#import "_h.typ": *

= #T("Appendices", "Annexes")

== #T("Performance and memory", "Performance et mémoire")

#T[
Figures are computed in pure Typst, so their cost is that of a Typst script. Rough guide on a laptop: a shaded `fig` takes 0.2 – 0.6 s; an `engraving` or `banknote` figure 1 – 3 s; knots about 0.3 s. Typst keeps every computed figure in memory until the end of the compilation (about 40 MB for a shaded sphere): a document with more than 60 figures on a machine with 2 GB of memory should be compiled in pieces, or use the tips below.
][
Les figures sont calculées en Typst pur : leur coût est celui d'un script Typst. Ordres de grandeur sur un portable : une `fig` ombrée prend 0,2 – 0,6 s ; une figure `engraving` ou `banknote` 1 – 3 s ; un nœud environ 0,3 s. Typst garde chaque figure calculée en mémoire jusqu'à la fin de la compilation (environ 40 Mo pour une sphère ombrée) : un document de plus de 60 figures sur une machine de 2 Go de mémoire doit être compilé par morceaux, ou suivre les conseils ci-dessous.
]

#T[
- Lower the smoothness: `sphere(1, n: 8)`, `surface-grid(…, nu: 16, nv: 12)`.
- Use `shading: "flat"` or `refine: false` in `fig` / `picture` for drafts.
- Engraving: increase `spacing` (e.g. `3pt`) and `step` (`2.4pt`); `cross: false` halves the work.
- Reuse a figure: compute it once with `let f = fig(…)` and place `f` several times (Typst caches the result).
- The manual of this package is built chapter by chapter (`docs/build-manual.py`) for that reason.
][
- Baissez la finesse : `sphere(1, n: 8)`, `surface-grid(…, nu: 16, nv: 12)`.
- Utilisez `shading: "flat"` ou `refine: false` dans `fig` / `picture` pour les brouillons.
- Gravure : augmentez `spacing` (par ex. `3pt`) et `step` (`2.4pt`) ; `cross: false` divise le travail par deux.
- Réutilisez une figure : calculez-la une fois avec `let f = fig(…)` et placez `f` plusieurs fois (Typst met le résultat en cache).
- Le manuel de ce paquet est construit chapitre par chapitre (`docs/build-manual.py`) pour cette raison.
]

== #T("Troubleshooting", "Dépannage")

#table(columns: (1fr, 1.6fr), stroke: (x: none, y: 0.3pt + luma(200)), inset: (x: 5pt, y: 4pt),
  table.header([#T("Symptom", "Symptôme")], [#T("Cause and remedy", "Cause et remède")]),
  T[A solid is black][Un solide est noir], T[A surface without colour is black: with `fig` use `paint(shape, colour)`; with `draw` give a colour or material.][Une surface sans couleur est noire : avec `fig` utilisez `paint(solide, couleur)` ; avec `draw` donnez une couleur ou un matériau.],
  T[A solid hides another one wrongly][Un solide en cache un autre à tort], T[Surfaces are painted in the order given. Put the farthest first, or use `picture(zsort: "global")` when solids interpenetrate.][Les surfaces sont peintes dans l'ordre donné. Mettez le plus lointain d'abord, ou utilisez `picture(zsort: "global")` quand les solides s'interpénètrent.],
  raw("cannot compare float.nan", lang: none), T[A point contains `nan` or an axis `min` / `max` was given as a point: `min` / `max` of `xaxis3` are numbers.][Un point contient `nan` ou un `min` / `max` d'axe a été donné comme point : `min` / `max` de `xaxis3` sont des nombres.],
  raw("number must be at least zero", lang: none), T[`-1 * (1, 1, 1)` repeats an array in Typst; write `(-1, -1, -1)` or `vmul(-1, v)`.][`-1 * (1, 1, 1)` répète un tableau en Typst ; écrivez `(-1, -1, -1)` ou `vmul(-1, v)`.],
  T[A knot loses pieces or has wrong crossings][Un nœud perd des morceaux ou a de faux croisements], T[Use `knot-style: "weave"`, a thinner `tube`, a view that separates the strands, or `flips` in `knot3`.][Utilisez `knot-style: "weave"`, un `tube` plus fin, une vue qui sépare les brins, ou `flips` dans `knot3`.],
  T[A brace crosses the figure][Une accolade traverse la figure], T[Force the other side with `flip: true / false`, or move it with `offset`.][Forcez l'autre côté avec `flip: true / false`, ou déplacez-la avec `offset`.],
  T[`package not found: nibart`][`package not found: nibart`], T[Edition mismatch: the Universe edition needs `@preview/nibart:0.3.0`, the local edition `@local/nibart:0.3.0` (install nibart-local first).][Édition incompatible : l'édition Universe veut `@preview/nibart:0.3.0`, l'édition locale `@local/nibart:0.3.0` (installez d'abord nibart-local).],
  T[Compilation is killed (memory)][La compilation est tuée (mémoire)], T[See "Performance and memory" above.][Voir « Performance et mémoire » ci-dessus.],
)

== #T("Coming from Asymptote", "Venir d'Asymptote")

#T[
The advanced layer keeps Asymptote's names and conventions: `currentprojection`, `orthographic`, `perspective`, `draw`, `dot`, `label`, `path3` operations (`subpath`, `arclength`, `arctime`…), `revolution`, `surface`, `light`, `material`, `pen`, `dashed`, `Arrow3`. Differences: functions take named arguments in Typst syntax (`draw(p, linewidth(1pt))`), pens combine with `pen(a, b)` rather than `+`, a picture is a Typst box and several pictures are laid out with `grid`; angles of the vector helpers are in degrees. The French guide (docs/guide-avance-fr.pdf) contains the full correspondence table.
][
La couche avancée garde les noms et conventions d'Asymptote : `currentprojection`, `orthographic`, `perspective`, `draw`, `dot`, `label`, opérations de `path3` (`subpath`, `arclength`, `arctime`…), `revolution`, `surface`, `light`, `material`, `pen`, `dashed`, `Arrow3`. Différences : les fonctions prennent des arguments nommés à la syntaxe Typst (`draw(p, linewidth(1pt))`), les plumes se combinent avec `pen(a, b)` et non `+`, une figure est une boîte Typst et plusieurs figures se disposent avec `grid` ; les angles des aides vectorielles sont en degrés. Le guide français (docs/guide-avance-fr.pdf) contient la table de correspondance complète.
]

== #T("What's new in 0.3", "Nouveautés de la 0.3")

#T[
- *`fig`*: the one-call simple API (view names, styles, automatic light, one link for all curves), with `paint`, `cube`, `brick` and `view-projection`.
- *Styles* `banknote` and `etching` in `fig`; every solid constructor accepts `c:` for its centre.
- *`brace3`* rewritten: outer side chosen automatically (`flip: auto`), `outside`, `distance`, third positional argument for the label.
- *`engraved`* takes a plain colour; exact torus silhouette (0.2.0 fix kept).
- *Manual* rewritten (this document, English + French) with every function, its parameters and an example; the former French manual becomes the *advanced guide* (`docs/guide-avance-fr.pdf`).
- Author and licence metadata; Universe and local editions.
][
- *`fig`* : l'API simple en un appel (noms de vues, styles, lumière automatique, un seul entrelacs pour toutes les courbes), avec `paint`, `cube`, `brick` et `view-projection`.
- Styles `banknote` et `etching` dans `fig` ; tous les constructeurs de solides acceptent `c:` pour leur centre.
- *`brace3`* réécrite : côté extérieur choisi automatiquement (`flip: auto`), `outside`, `distance`, troisième argument positionnel pour l'étiquette.
- *`engraved`* accepte une simple couleur ; silhouette exacte du tore (correctif de la 0.2.0 conservé).
- *Manuel* réécrit (ce document, anglais + français) avec chaque fonction, ses paramètres et un exemple ; l'ancien manuel français devient le *guide avancé* (`docs/guide-avance-fr.pdf`).
- Métadonnées d'auteur et de licence ; éditions Universe et locale.
]

== #T("Licences and credits", "Licences et crédits")

#T[
*solids3d* is released under the LGPL-3.0-or-later (see `LICENSE`). It uses *nibart* (MIT, FERGOUS Abdelhak) for pens, outlines, knots, braces and plates. The package contains no binary and no third-party code. The API follows the vocabulary of Asymptote's `three` and `solids` modules; no Asymptote code is included.
][
*solids3d* est publié sous licence LGPL-3.0-or-later (voir `LICENSE`). Il utilise *nibart* (MIT, FERGOUS Abdelhak) pour les plumes, contours, nœuds, accolades et planches. Le paquet ne contient ni binaire ni code tiers. L'API suit le vocabulaire des modules `three` et `solids` d'Asymptote ; aucun code d'Asymptote n'est inclus.
]
