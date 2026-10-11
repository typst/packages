#import "_h.typ": *

= #T("Reference — school geometry", "Référence — géométrie du collège et du lycée")

#T[
Annotations and ready-made solids for geometry lessons. The annotation functions return commands: give them to `fig` or `picture` together with the solid. The projected label of a dimension follows the line; hidden edges are dashed (`dashed` is a pen).
][
Annotations et solides prêts à l'emploi pour les leçons de géométrie. Les fonctions d'annotation renvoient des commandes : donnez-les à `fig` ou à `picture` avec le solide. L'étiquette projetée d'une cote suit la ligne ; les arêtes cachées sont en pointillés (`dashed` est une plume).
]

== #T("Solids for lessons", "Solides pour les leçons")

#api("cuboid / regular-pyramid / regular-prism", "cuboid(origin: O, length: 3, width: 2, height: 1.5)     regular-pyramid(center: O, radius: 1, height: 2, n: 4, angle: 45)     regular-prism(center: O, radius: 1, height: 2, n: 6, angle: 0)",
  T[A cuboid (also `pave-droit`), a regular pyramid and a regular prism with `n`-gon base (true polygons, not circle approximations: `n = 3, 4, 6` give triangles, squares and hexagons). `radius` is the circumradius of the base, `angle` the rotation of the base in degrees.][Un pavé droit (aussi `pave-droit`), une pyramide régulière et un prisme régulier de base à `n` côtés (de vrais polygones, pas des approximations de cercle : `n = 3, 4, 6` donnent triangles, carrés et hexagones). `radius` est le rayon du cercle circonscrit à la base, `angle` la rotation de la base en degrés.],
  params: (
    P("origin / center", "point", "O", [Lower corner of the cuboid / centre of the base.], [Coin inférieur du pavé / centre de la base.]),
    P("length, width, height", "number", "3, 2, 1.5", [Dimensions of the cuboid (x, y, z).], [Dimensions du pavé (x, y, z).]),
    P("radius", "number", "1", [Circumradius of the base.], [Rayon circonscrit de la base.]),
    P("height", "number", "2", [Height.], [Hauteur.]),
    P("n", "integer", "4 / 6", [Sides of the base.], [Côtés de la base.]),
    P("angle", "number", "45 / 0", [Rotation of the base (degrees).], [Rotation de la base (degrés).]),
  ),
  ex: ```
grid(columns: 3, gutter: 4pt,
  fig(cuboid(), size: 2.6cm),
  fig(regular-pyramid(n: 3, radius: 1.2, height: 1.8), size: 2.6cm),
  fig(regular-prism(n: 6, height: 1.5), size: 2.6cm))
```)

#api("regular-tetrahedron / regular-octahedron / frustum3 / right-prism3", "regular-tetrahedron(center: O, radius: 1)     regular-octahedron(center: O, radius: 1)     frustum3(center: O, bottom-radius: 1, top-radius: 0.6, height: 1.5, n: 24)     right-prism3(origin: O, base: 2, width: 1.2, height: 2)",
  T[More solids: two Platonic solids (circumradius `radius`), a frustum of a cone, and a right prism whose base is a right triangle with legs `base` and `width`.][D'autres solides : deux solides de Platon (rayon circonscrit `radius`), un tronc de cône, et un prisme droit dont la base est un triangle rectangle de côtés `base` et `width`.],
  params: (
    P("center", "point", "O", [Centre of the (bottom) base.], [Centre de la base (inférieure).]),
    P("radius", "number", "1", [Circumradius.], [Rayon circonscrit.]),
    P("bottom-radius, top-radius", "number", "1, 0.6", [Radii of the frustum.], [Rayons du tronc de cône.]),
    P("height", "number", "1.5 / 2", [Height.], [Hauteur.]),
    P("n", "integer", "24", [Slices of the frustum.], [Tranches du tronc de cône.]),
    P("origin, base, width", "point, number", "O, 2, 1.2", [Corner and legs of the right prism.], [Coin et côtés du prisme droit.]),
  ),
  ex: ```
grid(columns: 4, gutter: 3pt,
  fig(regular-tetrahedron(), size: 2.1cm),
  fig(regular-octahedron(), size: 2.1cm),
  fig(frustum3(), size: 2.1cm),
  fig(right-prism3(), size: 2.1cm))
```)

== #T("Annotations", "Annotations")

#api("point3 / vertex3", "point3(name, p, align: E, pen: auto, size: auto, dx: 0, dy: 0)",
  T[Marks a point with a dot and names it. `align` is a *projected* direction (`N`, `S`, `E`, `W`, `NE`, `NW`, `SE`, `SW`); `dx`, `dy` nudge the label (in projected units or in lengths such as `2pt`).][Marque un point d'un disque et le nomme. `align` est une direction *projetée* (`N`, `S`, `E`, `W`, `NE`, `NW`, `SE`, `SW`) ; `dx`, `dy` déplacent légèrement l'étiquette (en unités projetées ou en longueurs comme `2pt`).],
  params: (
    P("name", "content", none, [Name of the point (`$A$`).], [Nom du point (`$A$`).]),
    P("p", "point", none, [Position.], [Position.]),
    P("align", "direction", "E", [Where the label goes.], [Où va l'étiquette.]),
    P("pen, size", "pen, length", "auto", [Colour and dot diameter.], [Couleur et diamètre du point.]),
    P("dx, dy", "number or length", "0", [Fine adjustment.], [Réglage fin.]),
  ),
  ex: ```
fig(cuboid(length: 2, width: 1.4, height: 1), size: 4cm, view: (35, 25),
  point3($A$, (0, 1.4, 0), align: SW), point3($B$, (2, 1.4, 0), align: SE),
  point3($F$, (2, 1.4, 1), align: E), point3($E$, (0, 1.4, 1), align: NW))
```)

#api("dimension3", "dimension3(text, a, b, offset: O, align: N, pen: auto, arrow: Arrows, rotate: auto, dx: 0, dy: 0, extensions: true, extension-pen: auto)     (alias length3-label, segment-label3)",
  T[A dimension line between `a` and `b`, translated by the 3D vector `offset` (so that it stands away from the edge), with extension lines and arrows at both ends and a label that follows the line.][Une ligne de cote entre `a` et `b`, translatée par le vecteur 3D `offset` (pour qu'elle soit écartée de l'arête), avec traits d'attache et flèches aux deux bouts et une étiquette qui suit la ligne.],
  params: (
    P("text", "content", none, [The measure: `$5$ cm`.], [La mesure : `$5$ cm`.]),
    P("a, b", "point", none, [Ends of the measured segment.], [Extrémités du segment mesuré.]),
    P("offset", "point", "O", [3D displacement of the dimension line.], [Déplacement 3D de la ligne de cote.]),
    P("align", "direction", "N", [Side of the label.], [Côté de l'étiquette.]),
    P("pen", "pen", "auto", [Dimension line and arrowheads.], [Ligne de cote et pointes.]),
    P("arrow", "arrow", "Arrows", [Arrowheads (`Arrows`, `Arrow3`, `none`…).], [Pointes (`Arrows`, `Arrow3`, `none`…).]),
    P("rotate", "auto, false or angle", "auto", [Label follows the line / stays horizontal / forced angle.], [L'étiquette suit la ligne / reste horizontale / angle imposé.]),
    P("dx, dy", "number", "0", [Move the label only.], [Déplacer l'étiquette seule.]),
    P("extensions", "bool", "true", [Draw the extension lines.], [Tracer les traits d'attache.]),
    P("extension-pen", "pen", "auto", [Pen of the extension lines (e.g. `dotted`).], [Plume des traits d'attache (par ex. `dotted`).]),
  ),
  ex: ```
fig(cuboid(length: 2, width: 1.4, height: 1), size: 4.4cm, view: (35, 25),
  dimension3($2$, (0, 1.4, 0), (2, 1.4, 0), offset: (0, 0.35, 0), align: S),
  dimension3($1$, (2, 1.4, 0), (2, 1.4, 1), offset: (0.35, 0, 0), align: E))
```)

#api("callout3", "callout3(text, target, label-at, align: E, pen: auto, arrow: BeginArrow, dx: 0, dy: 0)",
  T[A text with a leader line whose arrow points at `target`; the text sits at `label-at`.][Un texte avec une ligne de rappel dont la flèche pointe sur `target` ; le texte se place en `label-at`.],
  params: (
    P("text", "content", none, [The remark.], [La remarque.]),
    P("target", "point", none, [Where the arrow points.], [Où pointe la flèche.]),
    P("label-at", "point", none, [Where the text sits.], [Où se place le texte.]),
    P("align, pen, arrow, dx, dy", "…", "E, auto, BeginArrow, 0, 0", [As in `point3`.], [Comme pour `point3`.]),
  ),
  ex: ```
fig(sphere(1), size: 4cm, callout3([pôle nord], (0, 0, 1), (1.4, 0, 1.5), align: E))
```)

#api("edge-code3 / equal-edges3", "edge-code3(a, b, count: 1, size: 0.14, spacing: 0.16, at: 0.5, direction: auto, pen: auto)     equal-edges3(edges, count: 1, size: 0.14, spacing: 0.16, at: 0.5, direction: auto, pen: auto)",
  T[Tick marks (1, 2 or 3) on an edge to show equal lengths. `equal-edges3` takes a list of edges `((a, b), (c, d), …)` and marks all of them the same way. The ticks are built in 3D and projected with the figure.][Traits de codage (1, 2 ou 3) sur une arête pour indiquer des longueurs égales. `equal-edges3` prend une liste d'arêtes `((a, b), (c, d), …)` et les marque toutes pareillement. Les traits sont construits en 3D et projetés avec la figure.],
  params: (
    P("a, b / edges", "points / array", none, [Ends of the edge / list of edges.], [Extrémités de l'arête / liste d'arêtes.]),
    P("count", "integer", "1", [Number of ticks.], [Nombre de traits.]),
    P("size", "number", "0.14", [Length of a tick (3D units).], [Longueur d'un trait (unités 3D).]),
    P("spacing", "number", "0.16", [Distance between ticks.], [Distance entre les traits.]),
    P("at", "number", "0.5", [Position along the edge (0 – 1).], [Position le long de l'arête (0 – 1).]),
    P("direction", "point", "auto", [Direction of the ticks (default: perpendicular, in the face).], [Direction des traits (défaut : perpendiculaire, dans la face).]),
    P("pen", "pen", "auto", [Pen.], [Plume.]),
  ),
  ex: ```
fig(cube(1.6), size: 3.6cm, view: (35, 25),
  equal-edges3((((-0.8, 0.8, -0.8), (0.8, 0.8, -0.8)), ((0.8, 0.8, -0.8), (0.8, -0.8, -0.8))), count: 2, size: 0.25),
  edge-code3((0.8, 0.8, -0.8), (0.8, 0.8, 0.8), count: 1, size: 0.25))
```)

#api("right-angle3 / angle-mark3 / angle-code3", "right-angle3(a, b, c, size: 0.15, pen: auto)     angle-mark3(a, b, c, radius: 0.24, pen: auto, label: none, align: N)     angle-code3(a, b, c, right: false, size: 0.15, radius: 0.24, pen: auto, label: none, align: N)",
  T[Marks the angle at vertex `b` between rays `ba` and `bc`: a small square (right angle), an arc with an optional label, or either of them (`angle-code3` with `right: true / false`).][Marque l'angle au sommet `b` entre les demi-droites `ba` et `bc` : un petit carré (angle droit), un arc avec une étiquette facultative, ou l'un ou l'autre (`angle-code3` avec `right: true / false`).],
  params: (
    P("a, b, c", "point", none, [Points; `b` is the vertex.], [Points ; `b` est le sommet.]),
    P("size", "number", "0.15", [Side of the right-angle square.], [Côté du carré d'angle droit.]),
    P("radius", "number", "0.24", [Radius of the arc.], [Rayon de l'arc.]),
    P("right", "bool", "false", [`angle-code3`: square instead of arc.], [`angle-code3` : carré au lieu d'un arc.]),
    P("label, align", "content, direction", "none, N", [Text near the arc.], [Texte près de l'arc.]),
    P("pen", "pen", "auto", [Pen.], [Plume.]),
  ),
  ex: ```
fig(cuboid(length: 2, width: 1.4, height: 1), size: 4cm, view: (35, 25),
  right-angle3((0, 1.4, 1), (2, 1.4, 1), (2, 0, 1), size: 0.3),
  angle-mark3((0, 1.4, 1), (0, 1.4, 0), (2, 1.4, 1), label: $α$, radius: 0.5))
```)

#api("construction3 / height3 / diagonal3 / projection3", "construction3(a, b, pen: auto)     height3(top, foot, pen: dashed, mark: false, mark-size: 0.12)     diagonal3(a, b, pen: dashed)     projection3(p, foot, pen: auto)",
  T[Dashed construction lines: any segment, the height of a solid with an optional right-angle mark at the foot, a diagonal, the perpendicular projection of a point.][Traits de construction en pointillés : un segment quelconque, la hauteur d'un solide avec une marque d'angle droit facultative au pied, une diagonale, la projection orthogonale d'un point.],
  params: (
    P("a, b / top, foot / p", "point", none, [Ends.], [Extrémités.]),
    P("pen", "pen", "dashed", [Pen (`dashed`, `dotted`, a colour…).], [Plume (`dashed`, `dotted`, une couleur…).]),
    P("mark", "bool", "false", [`height3`: small right-angle mark at the foot.], [`height3` : petite marque d'angle droit au pied.]),
    P("mark-size", "number", "0.12", [Size of that mark.], [Taille de cette marque.]),
  ),
  ex: ```
fig(regular-pyramid(n: 4, radius: 1.2, height: 2), size: 3.8cm, view: (35, 25),
  height3((0, 0, 2), O, mark: true),
  diagonal3((-0.85, -0.85, 0), (0.85, 0.85, 0)),
  point3($S$, (0, 0, 2), align: N))
```)

#api("cuboid-vertices / cuboid-edges", "cuboid-vertices(origin: O, length: 3, width: 2, height: 1.5)     cuboid-edges(v, visible: black, hidden: dashed)",
  T[`cuboid-vertices` returns a dictionary of the eight corners `A … H` (ABCD the bottom, EFGH the top, E above A); `cuboid-edges` draws the twelve edges with the hidden ones in another pen. Handy to name vertices and to compute with them.][`cuboid-vertices` renvoie un dictionnaire des huit sommets `A … H` (ABCD le bas, EFGH le haut, E au-dessus de A) ; `cuboid-edges` dessine les douze arêtes avec les cachées dans une autre plume. Pratique pour nommer les sommets et calculer avec eux.],
  params: (
    P("origin, length, width, height", "…", "O, 3, 2, 1.5", [As in `cuboid`.], [Comme pour `cuboid`.]),
    P("v", "dictionary", none, [Result of `cuboid-vertices`.], [Résultat de `cuboid-vertices`.]),
    P("visible, hidden", "pen", "black, dashed", [Pens of the visible / hidden edges.], [Plumes des arêtes visibles / cachées.]),
  ),
  ex: ```
let v = cuboid-vertices(length: 2, width: 1.4, height: 1)
picture(width: 4.2cm, projection: orthographic(5, 3, 2.4),
  cuboid-edges(v),
  point3($A$, v.A, align: SW), point3($G$, v.G, align: NE),
  diagonal3(v.A, v.G, pen: red))
```)
