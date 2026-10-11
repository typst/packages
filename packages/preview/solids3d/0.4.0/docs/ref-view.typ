#import "_h.typ": *

= #T("Reference — the advanced layer: picture, draw, camera, light", "Référence — la couche avancée : picture, draw, caméra, lumière")

#T[
`fig` is a thin layer over `picture`. Use `picture` directly when you need full control: several pens, axes, labels, dots, your own camera and light, `zsort`, perspective… Everything is a *command*: `draw`, `dot`, `label`, `xaxis3`, `brace3`, `knot3`… return lists of commands that `picture` executes in order.
][
`fig` est une fine couche au-dessus de `picture`. Utilisez `picture` directement quand il faut le contrôle complet : plusieurs plumes, axes, étiquettes, points, caméra et lumière personnelles, `zsort`, perspective… Tout est une *commande* : `draw`, `dot`, `label`, `xaxis3`, `brace3`, `knot3`… renvoient des listes de commandes que `picture` exécute dans l'ordre.
]

== picture

#api("picture", "picture(..commands, size: auto, width: auto, height: auto, unitsize: 1cm, projection: currentprojection, light: currentlight, limits: none, margin: 0pt, inset: 0pt, fill: none, stroke: none, radius: 0pt, dotfactor: 6, arrowsize: auto, clip: false, baseline: 0pt, zsort: \"command\", shading: \"smooth\", refine: true, backend: \"svg\", style: \"none\", engine: \"nibart\", engraving: auto)",
  T[Renders commands into a box. Sizing: `width` and/or `height` (or `size`, the larger side) fit the picture; without any, `unitsize` is the length of one unit of the projected plane.][Rend des commandes dans une boîte. Dimensionnement : `width` et/ou `height` (ou `size`, le plus grand côté) ajustent la figure ; sans eux, `unitsize` est la longueur d'une unité du plan projeté.],
  params: (
    P("..commands", "commands", none, [Lists returned by `draw`, `dot`, `label`, axes, `brace3`, `knot3`…], [Listes renvoyées par `draw`, `dot`, `label`, axes, `brace3`, `knot3`…]),
    P("size, width, height", "length", "auto", [Final size of the figure.], [Taille finale de la figure.]),
    P("unitsize", "length", "1cm", [Length of one unit when no size is given.], [Longueur d'une unité quand aucune taille n'est donnée.]),
    P("projection", "projection", "perspective(5, 4, 2)", [Camera (see `orthographic`, `perspective`).], [Caméra (voir `orthographic`, `perspective`).]),
    P("light", "light", "Headlamp", [Light of the scene.], [Lumière de la scène.]),
    P("limits", "limits", "none", [Fixes the 3D box used to frame the camera: `limits((x0, y0, z0), (x1, y1, z1))`. The same box gives identical framing to several figures.], [Fixe la boîte 3D utilisée pour cadrer la caméra : `limits((x0, y0, z0), (x1, y1, z1))`. La même boîte donne un cadrage identique à plusieurs figures.]),
    P("margin, inset", "length", "0pt", [Space added around the drawing / inside the frame.], [Espace ajouté autour du dessin / dans le cadre.]),
    P("fill, stroke, radius", "…", "none, none, 0pt", [Background, border and corner radius of the frame.], [Fond, bordure et rayon des coins du cadre.]),
    P("dotfactor", "number", "6", [Dot diameter = `dotfactor` × pen width.], [Diamètre des points = `dotfactor` × épaisseur de plume.]),
    P("arrowsize", "length", "auto", [Size of the arrowheads.], [Taille des pointes de flèche.]),
    P("clip", "bool", "false", [Clip the drawing to the frame.], [Découper le dessin au cadre.]),
    P("baseline", "length", "0pt", [Baseline shift of the box.], [Décalage de ligne de base de la boîte.]),
    P("zsort", "string", "\"command\"", [`"command"`: surfaces painted in command order (fast, predictable); `"global"`: all patches merged and sorted by depth (use when solids interpenetrate).], [`"command"` : surfaces peintes dans l'ordre des commandes (rapide, prévisible) ; `"global"` : tous les patchs fusionnés et triés par profondeur (à utiliser quand les solides s'interpénètrent).]),
    P("shading", "string", "\"smooth\"", [`"smooth"`, `"flat"` or `"none"`.], [`"smooth"`, `"flat"` ou `"none"`.]),
    P("refine", "bool", "true", [Subdivide patches that cross the silhouette for cleaner edges.], [Subdiviser les patchs qui coupent la silhouette pour des bords plus nets.]),
    P("backend", "string", "\"svg\"", [`"svg"` (one image) or `"typst"` (native shapes: selectable, lighter in memory for big drawings).], [`"svg"` (une image) ou `"typst"` (formes natives).]),
    P("style", "string", "\"none\"", [`"none"`, `"vintage"`, `"pencil"` or `"engraving"` (see chapter styles).], [`"none"`, `"vintage"`, `"pencil"` ou `"engraving"` (voir chapitre styles).]),
    P("engine", "string", "\"nibart\"", [Pen engine: only `"nibart"` (pure Typst + nibart); the `"wasm"` engine was removed in 0.4.0.], [Moteur de plume : seulement `"nibart"` (Typst pur + nibart) ; le moteur `"wasm"` a été supprimé en 0.4.0.]),
    P("engraving", "dictionary", "auto", [Engraving settings for `style: "engraving"`.], [Réglages de gravure pour `style: "engraving"`.]),
  ),
  ret: T[a box.][une boîte.],
  ex: ```
picture(width: 4.2cm, projection: orthographic(4, 3, 2.2),
  draw(surface(cuboid(length: 2, width: 1.4, height: 1)), rgb("#9db4d4"), light((-1, 0.8, 1.2))),
  draw(box3(O, (2, 1.4, 1)), black),
  axes3(min: 0, max: 2.4))
```)

#api("orthographic / perspective", "orthographic(x, y, z)     perspective(x, y, z)     (…, camera: none, up: Z, target: O, zoom: 1)",
  T[Cameras. The three numbers (or a point) give the position of the eye; `target` is the point looked at, `up` the vertical direction of the page. Orthographic keeps parallels parallel (technical drawing); perspective converges. Ready-made: `LeftView`, `RightView`, `FrontView`, `BackView`, `TopView`, `BottomView`.][Caméras. Les trois nombres (ou un point) donnent la position de l'œil ; `target` est le point visé, `up` la direction verticale de la page. L'orthographique garde les parallèles parallèles (dessin technique) ; la perspective fait converger. Prêtes à l'emploi : `LeftView`, `RightView`, `FrontView`, `BackView`, `TopView`, `BottomView`.],
  params: (
    P("x, y, z", "number", none, [Position of the camera (only its direction matters in orthographic).], [Position de la caméra (seule sa direction compte en orthographique).]),
    P("camera", "point", "none", [Same, as a single point.], [Idem, sous forme d'un seul point.]),
    P("up", "point", "Z", [Which 3D direction is vertical on the page.], [Quelle direction 3D est verticale sur la page.]),
    P("target", "point", "O", [Point looked at.], [Point visé.]),
    P("zoom", "number", "1", [Zoom factor.], [Facteur de zoom.]),
  ),
  ex: ```
let s = cone(0.8, 1.4)
grid(columns: 2, gutter: 6pt,
  picture(width: 3cm, projection: orthographic(4, 2, 1.5), draw(surface(s), rgb("#9db4d4")), draw(silhouette(s), black)),
  picture(width: 3cm, projection: perspective(3, 1.5, 1.2), draw(surface(s), rgb("#9db4d4")), draw(silhouette(s), black)))
```)

== #T("Drawing commands", "Commandes de dessin")

#api("draw", "draw(object, ..pens, pen: auto, arrow: none, label: none, align: auto, light: auto, meshpen: none, m: auto, n: 12, frontpen: auto, backpen: auto, longitudinalpen: auto, longitudinalbackpen: auto, ninterpolate: auto, seam: auto, hatch: auto, stipple: auto)",
  T[Draws a path (as a line), a surface (shaded), a solid of revolution (its skeleton: meridians and parallels, front pen / back pen), or a deferred object like `silhouette(...)`. Positional extras are classified by type: a colour or pen = the pen, a `Label` = the label, an arrow, a light. Asymptote-style calls work: `draw(Label("x"), path, red, Arrow3)`.][Dessine un chemin (en ligne), une surface (ombrée), un solide de révolution (son squelette : méridiens et parallèles, plume de face / d'arrière) ou un objet différé comme `silhouette(...)`. Les extras positionnels sont classés par type : une couleur ou plume = la plume, un `Label` = l'étiquette, une flèche, une lumière. Les appels à la façon d'Asymptote marchent : `draw(Label("x"), chemin, red, Arrow3)`.],
  params: (
    P("object", "path, surface, shape…", none, [What to draw.], [Ce qu'il faut dessiner.]),
    P("pen", "pen or colour or material", "auto", [Line pen, or surface colour/material. For a surface an array gives one material per patch.], [Plume de ligne, ou couleur/matériau de surface. Pour une surface, un tableau donne un matériau par patch.]),
    P("arrow", "arrow", "none", [`Arrow3`, `BeginArrow`, `Arrows`… for a path.], [`Arrow3`, `BeginArrow`, `Arrows`… pour un chemin.]),
    P("label", "content or Label", "none", [Label attached to the path (`Label(body, position: 0.5, align: N)`).], [Étiquette attachée au chemin (`Label(corps, position: 0.5, align: N)`).]),
    P("align", "direction", "auto", [Label alignment (`N`, `S`, `E`, `W`, `NE`…).], [Alignement de l'étiquette (`N`, `S`, `E`, `W`, `NE`…).]),
    P("light", "light", "auto", [Light for this surface (e.g. `nolight`).], [Lumière pour cette surface (par ex. `nolight`).]),
    P("meshpen", "pen", "none", [Draws the patch boundaries (wireframe).], [Dessine les bords des patchs (filaire).]),
    P("m, n", "integer", "auto, 12", [Number of meridians / slices of a skeleton.], [Nombre de méridiens / de tranches d'un squelette.]),
    P("frontpen, backpen", "pen", "auto", [Visible / hidden parts of a skeleton.], [Parties visibles / cachées d'un squelette.]),
    P("longitudinalpen, longitudinalbackpen", "pen", "auto", [Pens of the meridians.], [Plumes des méridiens.]),
    P("ninterpolate", "integer", "auto", [Projection subdivisions of a path (curves in perspective).], [Subdivisions de projection d'un chemin (courbes en perspective).]),
    P("hatch, stipple", "hatch / stipple", "auto", [Vintage hatching or stippling of a surface (see `vintage-hatch`, `vintage-stipple`).], [Hachures ou pointillé vintage d'une surface (voir `vintage-hatch`, `vintage-stipple`).]),
  ),
  ex: ```
let s = sphere(1)
picture(width: 3.6cm, projection: orthographic(4, 2, 1.6),
  draw(surface(s), rgb("#a9c4e8")),
  draw(s, 6, 8, frontpen: pen(linewidth(0.5pt), black), backpen: pen(dashed, gray(0.5))),
  draw(silhouette(s), linewidth(0.9pt)))
```)

#api("silhouette", "silhouette(shape, m: 64)",
  T[The outline of a solid of revolution as seen by the camera — computed when `picture` knows the projection (hence a deferred object). Exact for spheres, cones, cylinders and tori.][Le contour apparent d'un solide de révolution vu par la caméra — calculé quand `picture` connaît la projection (c'est donc un objet différé). Exact pour sphères, cônes, cylindres et tores.],
  params: (
    P("shape", "revolution", none, [The solid.], [Le solide.]),
    P("m", "integer", "64", [Samples of the contour.], [Échantillons du contour.]),
  ),
  ex: ```
let t = torus(1, 0.4)
picture(width: 4cm, projection: orthographic(4, 2, 3),
  draw(surface(t), rgb("#d8b087")),
  draw(silhouette(t), linewidth(1pt)))
```)

#api("fill3", "fill3(path, pen: auto)",
  T[Fills a planar closed path with a flat colour, no lighting.][Remplit un chemin plan fermé d'une couleur plate, sans éclairage.],
  params: (P("path", "path", none, [Planar closed path.], [Chemin plan fermé.]), P("pen", "colour", "auto", [Fill colour.], [Couleur de remplissage.])),
  ex: ```
picture(width: 3.6cm, projection: orthographic(4, 3, 2.4),
  fill3(line3(O, X, X + Y, Y, cyclic: true), paleblue),
  draw(line3(O, X, X + Y, Y, cyclic: true), black))
```)

#api("dot", "dot(point, pen: auto, label: none, align: auto, size: auto)",
  T[Draws a dot at a point (or at the nodes of a path), with an optional label.][Dessine un point en un point (ou aux nœuds d'un chemin), avec une étiquette facultative.],
  params: (
    P("point", "point or path", none, [Position(s).], [Position(s).]),
    P("pen", "pen", "auto", [Colour / size.], [Couleur / taille.]),
    P("label", "content", "none", [Label.], [Étiquette.]),
    P("align", "direction", "E", [Where the label sits.], [Où se place l'étiquette.]),
    P("size", "length", "auto", [Dot diameter.], [Diamètre.]),
  ),
  ex: ```
picture(width: 3.6cm, projection: orthographic(4, 3, 2.4),
  draw(line3(O, X, X + Y), black),
  dot(O, label: $A$, align: SW), dot(X, label: $B$, align: SE), dot(X + Y, label: $C$, align: NE))
```)

#api("label", "label(body, point, ..args, align: auto, pen: auto)",
  T[Text (or math) anchored at a 3D point, not rotated.][Texte (ou formule) ancré en un point 3D, non tourné.],
  params: (
    P("body", "content", none, [The text.], [Le texte.]),
    P("point", "point", none, [Anchor.], [Ancre.]),
    P("align", "direction", "Center", [Placement around the anchor.], [Placement autour de l'ancre.]),
    P("pen", "pen", "auto", [Colour and size.], [Couleur et taille.]),
  ),
  ex: ```
picture(width: 3.6cm, projection: orthographic(4, 3, 2.4),
  draw(surface(unitcube), paleblue, light((-1, 0.8, 1.2))), label($O$, O, align: SW), label($G$, (1, 1, 1), align: NE))
```)

#api("xaxis3 / yaxis3 / zaxis3 / axes3", "xaxis3(label, pen, arrow, min: auto, max: auto)     axes3(xlabel: $x$, ylabel: $y$, zlabel: $z$, pen: auto, arrow: Arrow3, min: auto, max: auto)",
  T[Coordinate axes. `min` / `max` are the coordinates where the axis starts and ends; `auto` takes the scene bounds.][Axes de coordonnées. `min` / `max` sont les coordonnées de début et de fin de l'axe ; `auto` prend les bornes de la scène.],
  params: (
    P("label", "content", "none", [Axis label.], [Étiquette de l'axe.]),
    P("pen", "pen", "auto", [Pen.], [Plume.]),
    P("arrow", "arrow", "none (axes3: Arrow3)", [Arrowhead.], [Pointe de flèche.]),
    P("min, max", "number", "auto", [Start and end coordinate of the axis.], [Coordonnées de début et de fin de l'axe.]),
    P("xlabel, ylabel, zlabel", "content", "$x$ $y$ $z$", [Labels for `axes3`.], [Étiquettes pour `axes3`.]),
  ),
  ex: ```
picture(width: 3.6cm, projection: orthographic(4, 3, 2.4),
  axes3(min: 0, max: 2.2), draw(spline3(O, (1, 1.5, 0.6), (2, 2, 1.6)), red))
```)

#api("limits", "limits(min, max)",
  T[Declares the 3D box of the scene: it gives the extent of the axes drawn with `axes3` (when `min` / `max` are `auto`) and the box used to place the camera. Without it, the bounds of the drawn objects are used. To give several figures the same scale, give them the same `unitsize` instead of a `width`.][Déclare la boîte 3D de la scène : elle donne l'étendue des axes tracés par `axes3` (quand `min` / `max` valent `auto`) et la boîte qui sert à placer la caméra. Sans elle, les bornes des objets dessinés sont utilisées. Pour donner la même échelle à plusieurs figures, donnez-leur le même `unitsize` plutôt qu'une `width`.],
  params: (P("min, max", "point", none, [Opposite corners of the box.], [Sommets opposés de la boîte.]),),
  ex: ```
picture(unitsize: 0.9cm, projection: orthographic(4, 3, 2),
  limits(O, (2, 2, 2)), axes3(),
  draw(surface(sphere(0.5, c: (1, 1, 0.5))), paleblue))
```)

== #T("Light, materials and pens", "Lumière, matériaux et plumes")

#api("light", "light(..positions, diffuse: auto, specular: auto, specularfactor: 1, background: none, viewport: true)",
  T[A light source. `light((x, y, z))` gives the direction *the light comes from*; with `viewport: true` (default) the direction is relative to the camera (x to the right, y up, z toward you), with `false` it is fixed in the scene. Positional colours come first: `light(white, gray(0.5), (1, 1, 2))`. `Headlamp` is the default; `nolight` disables shading (flat colours).][Une source de lumière. `light((x, y, z))` donne la direction *d'où vient la lumière* ; avec `viewport: true` (défaut) la direction est relative à la caméra (x vers la droite, y vers le haut, z vers vous), avec `false` elle est fixe dans la scène. Les couleurs positionnelles viennent d'abord : `light(white, gray(0.5), (1, 1, 2))`. `Headlamp` est le défaut ; `nolight` supprime l'ombrage (couleurs plates).],
  params: (
    P("..positions", "point", none, [Directions (several = several lights).], [Directions (plusieurs = plusieurs lumières).]),
    P("diffuse", "colour", "white", [Diffuse colour (or an array, one per light).], [Couleur diffuse (ou tableau, une par lumière).]),
    P("specular", "colour", "auto", [Colour of highlights.], [Couleur des reflets.]),
    P("specularfactor", "number", "1", [Strength of highlights.], [Intensité des reflets.]),
    P("background", "colour", "none", [Ambient background colour.], [Couleur de fond ambiante.]),
    P("viewport", "bool", "true", [Direction relative to the camera.], [Direction relative à la caméra.]),
  ),
  ex: ```
let s = sphere(1)
let pic(L) = picture(width: 2.4cm, projection: orthographic(4, 2, 1.6), light: L, draw(surface(s), rgb("#a9c4e8")))
grid(columns: 3, gutter: 4pt, pic(light((-1, 1, 1))), pic(light((1, 0.2, 0.6))), pic(nolight))
```)

#api("material", "material(diffuse: black, emissive: black, specular: mediumgray, opacity: auto, shininess: 0.7)",
  T[Surface material: colours, transparency (`opacity`) and glossiness (`shininess`). A plain colour is accepted wherever a material is expected. `withopacity(colour, 0.5)` and `opacity(0.5)` build translucent colours/pens.][Matériau de surface : couleurs, transparence (`opacity`) et brillance (`shininess`). Une simple couleur est acceptée partout où un matériau est attendu. `withopacity(couleur, 0.5)` et `opacity(0.5)` fabriquent des couleurs/plumes translucides.],
  params: (
    P("diffuse", "colour", "black", [Base colour.], [Couleur de base.]),
    P("emissive", "colour", "black", [Self-lit colour added (glow).], [Couleur propre ajoutée (lueur).]),
    P("specular", "colour", "mediumgray", [Highlight colour.], [Couleur du reflet.]),
    P("opacity", "number", "auto", [0 – 1.], [0 – 1.]),
    P("shininess", "number", "0.7", [Sharpness of the highlight.], [Finesse du reflet.]),
  ),
  ex: ```
let s = sphere(1)
picture(width: 3.6cm, projection: orthographic(4, 2, 1.6), light: light((-1, 1, 1.5)),
  draw(surface(s), material(diffuse: rgb("#d05050"), specular: white, shininess: 0.9)))
```)

#api("pen & friends", "pen(..items)  linewidth(w)  dashed  dotted  longdashed  dashdotted  linetype(pattern)  roundcap  squarecap  roundjoin  miterjoin  invisible  fontsize(s)  nolight  opacity(x)  withopacity(c, x)",
  T[Pens are small dictionaries combined with `pen(…)`: `pen(linewidth(1pt), red, dashed)`. Colours are Asymptote's: `red green blue cyan magenta yellow black white orange purple…` and the families `pale…`, `light…`, `medium…`, `heavy…`, `deep…`, `dark…`; `gray(0.4)`; `rgbf(r, g, b)` (0–1). Standard Typst `rgb(…)` also works.][Les plumes sont de petits dictionnaires que l'on combine avec `pen(…)` : `pen(linewidth(1pt), red, dashed)`. Les couleurs sont celles d'Asymptote : `red green blue cyan magenta yellow black white orange purple…` et les familles `pale…`, `light…`, `medium…`, `heavy…`, `deep…`, `dark…` ; `gray(0.4)` ; `rgbf(r, g, b)` (0–1). Le `rgb(…)` de Typst marche aussi.],
  ex: ```
picture(width: 3.6cm, projection: orthographic(4, 3, 2.4),
  draw(circle3(O, 1), pen(linewidth(1.4pt), heavyblue)),
  draw(circle3(O, 1, normal: X), pen(linewidth(1pt), red, dashed)),
  draw(circle3(O, 1, normal: Y), pen(linewidth(1.4pt), darkgreen, roundcap)))
```)
