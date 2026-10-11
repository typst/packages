#import "_h.typ": *

= #T("Reference — the simple layer", "Référence — la couche simple")

#T[
This chapter documents the functions of the *simple layer*: `fig` and its helpers. Everything else (the following chapters) is the advanced layer that `fig` is built on; you never need it for ordinary figures.
][
Ce chapitre documente les fonctions de la *couche simple* : `fig` et ses aides. Tout le reste (chapitres suivants) est la couche avancée sur laquelle `fig` est bâtie ; elle n'est jamais nécessaire pour les figures ordinaires.
]

#api("fig", "fig(..items, size: 6cm, view: \"iso\", style: \"shaded\", light: auto, rim: auto, persp: false, tube: 7pt, knot-style: \"weave\", engraving: auto, ..picture-options)",
  T[Turns what you give it into a finished figure. Each *item* is converted by its nature: a solid of revolution or a surface is lit and outlined; a 3D path is drawn as a line; a knot curve (`trefoil()`, a function `t => (x, y, z)`) becomes a tube — all the curves given in one call form *one* link, so that their crossings are detected; `paint(shape, colour)` gives a colour; a command (`brace3(…)`, `draw(…)`, `knot3(…)`, `dimension3(…)`…) is passed through untouched. The camera comes from `view`, the light follows the camera (it comes from the upper left).][Transforme ce qu'on lui donne en une figure finie. Chaque *objet* est converti selon sa nature : un solide de révolution ou une surface est éclairé et cerné ; un chemin 3D est tracé comme une ligne ; une courbe de nœud (`trefoil()`, une fonction `t => (x, y, z)`) devient un tube — toutes les courbes données dans un même appel forment *un seul* entrelacs, de sorte que leurs croisements sont détectés ; `paint(solide, couleur)` donne une couleur ; une commande (`brace3(…)`, `draw(…)`, `knot3(…)`, `dimension3(…)`…) passe telle quelle. La caméra vient de `view`, la lumière suit la caméra (elle vient d'en haut à gauche).],
  params: (
    P("..items", "shape, surface, path, curve or command", none, [What to draw (any number, any mix).], [Ce qu'il faut dessiner (en nombre quelconque, mélangés).]),
    P("size", "length", "6cm", [Width of the figure (the height follows the content).], [Largeur de la figure (la hauteur suit le contenu).]),
    P("view", "string or array or projection", "\"iso\"", [`"iso"`, `"front"`, `"back"`, `"side"`, `"left"`, `"top"`, `"bottom"`, `"low"`, `"high"`; or `(azimuth, elevation)` in degrees; or a projection built with `orthographic` / `perspective`.], [`"iso"`, `"front"`, `"back"`, `"side"`, `"left"`, `"top"`, `"bottom"`, `"low"`, `"high"` ; ou `(azimut, élévation)` en degrés ; ou une projection construite avec `orthographic` / `perspective`.]),
    P("style", "string", "\"shaded\"", [`"shaded"` (Phong shading), `"engraving"` (copper-plate), `"banknote"` (wavy engraving), `"etching"` (blue-ink engraving), `"vintage"`, `"pencil"`.], [`"shaded"` (ombrage de Phong), `"engraving"` (gravure sur cuivre), `"banknote"` (gravure ondulée), `"etching"` (gravure à l'encre bleue), `"vintage"`, `"pencil"`.]),
    P("light", "light", "auto", [A light made with `light(…)`; `auto` = from the upper left of the camera.], [Une lumière faite avec `light(…)` ; `auto` = en haut à gauche de la caméra.]),
    P("rim", "pen or none", "auto", [Pen of the outlines of the solids (`auto` = 0.8 pt black); `none` removes them.], [Plume des contours des solides (`auto` = 0,8 pt noir) ; `none` les supprime.]),
    P("persp", "bool", "false", [Perspective camera instead of orthographic.], [Caméra perspective au lieu d'orthographique.]),
    P("tube", "length", "7pt", [Diameter of the knot tubes.], [Diamètre des tubes de nœuds.]),
    P("knot-style", "string", "\"weave\"", [`"weave"` (continuous tubes) or `"gap"` (the under-strand is interrupted).], [`"weave"` (tubes continus) ou `"gap"` (le brin du dessous est interrompu).]),
    P("engraving", "dictionary", "auto", [An `engraving(…)` to tune the lines of the `engraving`, `banknote` and `etching` styles.], [Un `engraving(…)` pour régler les lignes des styles `engraving`, `banknote` et `etching`.]),
    P("..picture-options", "any", none, [Any other option is passed to `picture`: `shading`, `backend`, `zsort`, `refine`, `engine`, `fill`, `margin`, `limits`, `unitsize`…], [Toute autre option est transmise à `picture` : `shading`, `backend`, `zsort`, `refine`, `engine`, `fill`, `margin`, `limits`, `unitsize`…]),
  ),
  ret: T[a box (content).][une boîte (contenu).],
  note: T[Items are drawn in the order given: put the solids that must stay in front last. Knots form one layer, drawn after the solids.][Les objets sont dessinés dans l'ordre donné : mettez en dernier les solides qui doivent rester devant. Les nœuds forment une couche, dessinée après les solides.],
  ex: ```
fig(
  paint(torus(1, 0.35), rgb("#d98e5b")),
  paint(sphere(0.55), rgb("#7aa6d8")),
  size: 4.4cm, view: "high")
```)

#api("view-projection", "view-projection(v, persp: false)",
  T[The projection used by `fig` for a named view or a pair of angles. Use it to share one camera between `fig` and `picture`.][La projection que `fig` utilise pour une vue nommée ou un couple d'angles. Servez-vous-en pour partager une caméra entre `fig` et `picture`.],
  params: (
    P("v", "string, array or projection", none, [Name of a view, `(azimuth, elevation)` in degrees, or a projection (returned unchanged).], [Nom d'une vue, `(azimut, élévation)` en degrés, ou une projection (renvoyée telle quelle).]),
    P("persp", "bool", "false", [Perspective instead of orthographic.], [Perspective au lieu d'orthographique.]),
  ),
  ret: T[a projection.][une projection.],
  ex: ```
let P = view-projection((30, 35))
picture(width: 3.6cm, projection: P,
  light: light((-1, 0.8, 1.2)),
  draw(surface(unitcube), rgb("#9db4d4")))
```)

#api("paint", "paint(shape, color)",
  T[Gives a colour to a solid or a surface inside `fig`. In the engraving styles the colour sets the tone (dark colours give more ink).][Donne une couleur à un solide ou une surface dans `fig`. Dans les styles de gravure, la couleur règle le ton (une couleur sombre donne plus d'encre).],
  params: (
    P("shape", "shape or surface", none, [The solid.], [Le solide.]),
    P("color", "color", none, [Diffuse colour.], [Couleur diffuse.]),
  ),
  ex: ```
fig(paint(cylinder(0.7, 1.5), rgb("#e8a33d")),
  size: 3cm, style: "banknote")
```)

#api("cube / brick", "cube(a, c: (0, 0, 0))     brick(l, w, h, c: (0, 0, 0))",
  T[A cube of side `a`, or a rectangular block of length `l` (x), width `w` (y) and height `h` (z), centred on `c`. They are flat-shaded surfaces; `fig` also draws their edges (hidden ones dashed).][Un cube de côté `a`, ou un pavé de longueur `l` (x), largeur `w` (y) et hauteur `h` (z), centré en `c`. Ce sont des surfaces à ombrage plat ; `fig` dessine aussi leurs arêtes (cachées en pointillés).],
  params: (
    P("a", "number", none, [Side of the cube.], [Côté du cube.]),
    P("l, w, h", "number", none, [Length, width and height of the block.], [Longueur, largeur et hauteur du pavé.]),
    P("c", "point", "(0, 0, 0)", [Centre.], [Centre.]),
  ),
  ex: ```
fig(brick(3, 2, 1.4), size: 4cm,
  brace3((-1.5, 1, -0.7), (1.5, 1, -0.7), $3$))
```)
