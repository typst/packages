#import "_h.typ": *

= #T("Reference — solids and surfaces", "Référence — solides et surfaces")

#T[
Constructors of solids and surfaces. Each one returns a value that you can give to `fig` (simple layer) or to `draw(surface(…))` (advanced layer). Solids of revolution also support skeletons and silhouettes (see `draw` and `silhouette`).
][
Constructeurs de solides et de surfaces. Chacun renvoie une valeur que l'on peut donner à `fig` (couche simple) ou à `draw(surface(…))` (couche avancée). Les solides de révolution gèrent aussi squelettes et silhouettes (voir `draw` et `silhouette`).
]

== #T("Standard solids", "Solides usuels")

#api("sphere", "sphere(r)     sphere(c, r)     sphere(c, r, n)     sphere(…, n: 12, c: auto)",
  T[Sphere of radius `r`, as a solid of revolution about the z axis. Three call forms: radius only (centred at the origin), centre and radius, or centre, radius and number of Bézier segments in the half circle.][Sphère de rayon `r`, comme solide de révolution autour de l'axe z. Trois formes d'appel : rayon seul (centrée à l'origine), centre et rayon, ou centre, rayon et nombre de segments de Bézier du demi-cercle.],
  params: (
    P("r", "number", none, [Radius.], [Rayon.]),
    P("c", "point", "(0, 0, 0)", [Centre (positional first argument, or the named option `c:`).], [Centre (premier argument positionnel, ou option nommée `c:`).]),
    P("n", "integer", "12", [Bézier segments in the half circle (smoothness).], [Segments de Bézier du demi-cercle (finesse).]),
  ),
  ex: ```
fig(sphere(1), sphere(0.5, c: (1.6, 0, 0.5)), size: 4.4cm)
```)

#api("cylinder", "cylinder(r, h)     cylinder(c, r, h, axis)     cylinder(…, axis: Z, c: auto)",
  T[Cylinder of radius `r` and height `h` whose base circle is centred on `c`; `axis` is the direction of the axis.][Cylindre de rayon `r` et de hauteur `h` dont le cercle de base est centré en `c` ; `axis` est la direction de l'axe.],
  params: (
    P("r", "number", none, [Radius.], [Rayon.]),
    P("h", "number", none, [Height.], [Hauteur.]),
    P("c", "point", "(0, 0, 0)", [Centre of the base.], [Centre de la base.]),
    P("axis", "point", "Z", [Direction of the axis.], [Direction de l'axe.]),
  ),
  ex: ```
fig(cylinder(0.8, 1.5), cylinder(0.4, 2, c: (1.6, 0, 0), axis: (0.3, 0, 1)), size: 4.4cm)
```)

#api("cone", "cone(r, h)     cone(c, r, h, axis, n)     cone(…, axis: Z, n: 12, c: auto)",
  T[Cone with base radius `r`, height `h`, base centre `c`.][Cône de rayon de base `r`, de hauteur `h`, de centre de base `c`.],
  params: (
    P("r", "number", none, [Radius of the base.], [Rayon de la base.]),
    P("h", "number", none, [Height.], [Hauteur.]),
    P("c", "point", "(0, 0, 0)", [Centre of the base.], [Centre de la base.]),
    P("axis", "point", "Z", [Direction of the axis.], [Direction de l'axe.]),
    P("n", "integer", "12", [Number of slices (smoothness).], [Nombre de tranches (finesse).]),
  ),
  ex: ```
fig(cone(1, 1.8), size: 3.4cm, view: "low")
```)

#api("torus", "torus(R, a, c: (0, 0, 0), n: 16)",
  T[Torus of major radius `R` (distance from the centre to the tube axis) and minor radius `a` (tube radius), about the z axis. Its silhouette is exact, with the hidden parts of the hole removed.][Tore de grand rayon `R` (distance du centre à l'axe du tube) et de petit rayon `a` (rayon du tube), autour de l'axe z. Sa silhouette est exacte, les parties cachées du trou étant supprimées.],
  params: (
    P("R", "number", none, [Major radius.], [Grand rayon.]),
    P("a", "number", none, [Minor radius.], [Petit rayon.]),
    P("c", "point", "(0, 0, 0)", [Centre.], [Centre.]),
    P("n", "integer", "16", [Segments of the tube circle.], [Segments du cercle du tube.]),
  ),
  ex: ```
fig(torus(1, 0.4), size: 4cm, view: "high", style: "engraving")
```)

#api("revolution", "revolution(g, axis)     revolution(c, g, axis)     revolution(…, c: auto, axis: Z, angle1: 0, angle2: 360)",
  T[The general solid of revolution: the 3D path `g` turned about `axis` (a direction through `c`). `sphere`, `cylinder`, `cone` and `torus` are special cases. `angle1`, `angle2` limit the sweep, in degrees.][Le solide de révolution général : le chemin 3D `g` tourné autour de `axis` (une direction passant par `c`). `sphere`, `cylinder`, `cone` et `torus` en sont des cas particuliers. `angle1`, `angle2` limitent le balayage, en degrés.],
  params: (
    P("g", "path", none, [Generatrix (a 3D path, e.g. made with `line3` or `spline3`).], [Génératrice (un chemin 3D, par ex. fait avec `line3` ou `spline3`).]),
    P("axis", "point", "Z", [Direction of the axis of revolution.], [Direction de l'axe de révolution.]),
    P("c", "point", "(0, 0, 0)", [A point of the axis.], [Un point de l'axe.]),
    P("angle1, angle2", "number", "0, 360", [Start and end angles of the sweep, in degrees.], [Angles de début et de fin du balayage, en degrés.]),
  ),
  ex: ```
let vase = spline3((1, 0, 0), (0.55, 0, 0.8), (0.9, 0, 1.6), (0.6, 0, 2.2))
fig(revolution(vase, Z), size: 2.6cm, view: "front")
```)

#api("tube3", "tube3(g, width: 0.1, n: 12, samples: auto, caps: false, color: none)     (alias tube)",
  T[A polygonal tube around a 3D path, built from a transported frame — helices, wires, rods.][Un tube polygonal autour d'un chemin 3D, construit à partir d'un repère transporté — hélices, fils, tiges.],
  params: (
    P("g", "path", none, [Spine of the tube.], [Chemin directeur du tube.]),
    P("width", "number", "0.1", [Diameter of the tube.], [Diamètre du tube.]),
    P("n", "integer", "12", [Number of sides.], [Nombre de côtés.]),
    P("samples", "integer", "auto", [Subdivisions per Bézier segment.], [Subdivisions par segment de Bézier.]),
    P("caps", "bool", "false", [Close the ends.], [Fermer les extrémités.]),
    P("color", "color or function", "none", [Colour, or `(i, th) => colour`.], [Couleur, ou `(i, th) => couleur`.]),
  ),
  ex: ```
let helix = spline3(..range(25).map(i => (calc.cos(i * 0.5), calc.sin(i * 0.5), i * 0.08)))
fig(tube3(helix, width: 0.18), size: 2.6cm, view: "front")
```)

#api("extrude / cone-over", "extrude(p, v: Z, n: 8)     cone-over(base, vertex, n: 4)",
  T[`extrude` sweeps a planar path along the vector `v` (a prism, a cylinder with any section). `cone-over` joins a base path to a vertex (pyramid, cone with any base).][`extrude` balaie un chemin plan le long du vecteur `v` (prisme, cylindre de section quelconque). `cone-over` joint un chemin de base à un sommet (pyramide, cône de base quelconque).],
  params: (
    P("p / base", "path", none, [The planar path / the base.], [Le chemin plan / la base.]),
    P("v", "point", "Z", [Extrusion vector.], [Vecteur d'extrusion.]),
    P("vertex", "point", none, [Apex of the cone.], [Sommet du cône.]),
    P("n", "integer", "8 / 4", [Subdivisions.], [Subdivisions.]),
  ),
  ex: ```
let hexa = line3(..range(6).map(i => (calc.cos(i * 60deg), calc.sin(i * 60deg), 0)), cyclic: true)
grid(columns: 2, gutter: 4pt,
  fig(extrude(hexa, v: (0, 0, 1.2)), size: 2.4cm),
  fig(cone-over(hexa, (0, 0, 1.6)), size: 2.4cm))
```)

== #T("Surfaces and meshes", "Surfaces et maillages")

#api("surface-grid", "surface-grid(f, u0, u1, v0, v1, nu: 16, nv: 12, cyclic-u: false, cyclic-v: false, normal: auto, color: none)     (aliases parametric-surface, parametric)",
  T[Parametric surface: `f(u, v)` returns a point. The domain is cut into `nu × nv` patches.][Surface paramétrique : `f(u, v)` renvoie un point. Le domaine est découpé en `nu × nv` patchs.],
  params: (
    P("f", "function", none, [`(u, v) => (x, y, z)`.], [`(u, v) => (x, y, z)`.]),
    P("u0, u1, v0, v1", "number", none, [Parameter ranges.], [Intervalles des paramètres.]),
    P("nu, nv", "integer", "16, 12", [Number of patches along u and v.], [Nombre de patchs selon u et v.]),
    P("cyclic-u, cyclic-v", "bool", "false", [Close the surface in that direction (tori, cylinders).], [Fermer la surface dans cette direction (tores, cylindres).]),
    P("normal", "auto, point or function", "auto", [Normal: automatic, constant, or `(u, v) => point`.], [Normale : automatique, constante, ou `(u, v) => point`.]),
    P("color", "color or function", "none", [Colour, or `(u, v) => colour` evaluated at the centre of each patch.], [Couleur, ou `(u, v) => couleur` évaluée au centre de chaque patch.]),
  ),
  ex: ```
let mobius = surface-grid(
  (u, v) => ((1 + v * calc.cos(u / 2)) * calc.cos(u),
             (1 + v * calc.cos(u / 2)) * calc.sin(u), v * calc.sin(u / 2)),
  0, 2 * calc.pi, -0.4, 0.4, nu: 48, nv: 4, cyclic-u: false)
fig(mobius, size: 4cm, view: "high")
```)

#api("heightfield", "heightfield(f, x0, x1, y0, y1, nx: 16, ny: 16, normal: auto, color: none)",
  T[Surface `z = f(x, y)` over a rectangle.][Surface `z = f(x, y)` au-dessus d'un rectangle.],
  params: (
    P("f", "function", none, [`(x, y) => z`.], [`(x, y) => z`.]),
    P("x0, x1, y0, y1", "number", none, [The rectangle.], [Le rectangle.]),
    P("nx, ny", "integer", "16, 16", [Patches along x and y.], [Patchs selon x et y.]),
    P("normal, color", "…", "auto, none", [As in `surface-grid`.], [Comme pour `surface-grid`.]),
  ),
  ex: ```
fig(heightfield((x, y) => 0.35 * calc.sin(2 * x) * calc.cos(2 * y), -1.6, 1.6, -1.6, 1.6, nx: 28, ny: 28),
  size: 4.2cm, view: "high")
```)

#api("surface-mesh", "surface-mesh(vertices, faces, indices: \"zero\", normal: auto, smooth: true, color: none)     (alias mesh-surface)",
  T[Surface from an indexed mesh (polyhedra, `.obj`-like data). Faces are lists of vertex indices, triangles or polygons.][Surface à partir d'un maillage indexé (polyèdres, données de type `.obj`). Les faces sont des listes d'indices de sommets, triangles ou polygones.],
  params: (
    P("vertices", "array", none, [List of points.], [Liste de points.]),
    P("faces", "array", none, [List of index lists.], [Liste de listes d'indices.]),
    P("indices", "string", "\"zero\"", [`"zero"` or `"one"`: numbering of the indices.], [`"zero"` ou `"one"` : numérotation des indices.]),
    P("smooth", "bool", "true", [Average the normals at the vertices; `false` = flat faces (polyhedra).], [Moyenner les normales aux sommets ; `false` = faces planes (polyèdres).]),
    P("normal, color", "…", "auto, none", [Constant or function normal; colour or `(face, centre) => colour`.], [Normale constante ou fonction ; couleur ou `(face, centre) => couleur`.]),
  ),
  ex: ```
let v = ((0, 0, 0), (1.4, 0, 0), (0.7, 1.2, 0), (0.7, 0.4, 1.3))
fig(surface-mesh(v, ((0, 2, 1), (0, 1, 3), (1, 2, 3), (2, 0, 3)), smooth: false), size: 3cm)
```)

#api("mesh-edges", "mesh-edges(vertices, faces, indices: \"zero\", boundary: false)",
  T[The unique edges of a mesh, as 3D paths, to draw a wireframe: `draw(mesh-edges(v, f), pen)`.][Les arêtes uniques d'un maillage, en chemins 3D, pour dessiner une structure filaire : `draw(mesh-edges(v, f), plume)`.],
  params: (
    P("vertices, faces, indices", "…", none, [As in `surface-mesh`.], [Comme pour `surface-mesh`.]),
    P("boundary", "bool", "false", [Keep only the edges of a single face (the border).], [Ne garder que les arêtes d'une seule face (le bord).]),
  ),
  ex: ```
let v = ((0, 0, 0), (1.4, 0, 0), (0.7, 1.2, 0), (0.7, 0.4, 1.3))
let f = ((0, 2, 1), (0, 1, 3), (1, 2, 3), (2, 0, 3))
fig(draw(mesh-edges(v, f), linewidth(1pt)), size: 3cm)
```)

#api("surface / patch", "surface(..args, n: 12, color: none, normal: auto, planar: false)     patch(boundary, normal: auto, center: auto, color: none, holes: ())",
  T[`surface(x)` converts a solid of revolution, a closed planar path or a list of patches into a surface that `draw` can shade. `patch` builds one four-sided or polygonal patch from its boundary path.][`surface(x)` convertit un solide de révolution, un chemin plan fermé ou une liste de patchs en une surface que `draw` sait ombrer. `patch` construit un patch à quatre côtés ou polygonal à partir de son contour.],
  params: (
    P("args", "shape, path or patches", none, [What to convert (several surfaces are merged).], [Ce qu'il faut convertir (plusieurs surfaces sont fusionnées).]),
    P("n", "integer", "12", [Slices for solids of revolution.], [Tranches pour les solides de révolution.]),
    P("color", "color or function", "none", [Colour of the patches.], [Couleur des patchs.]),
    P("normal", "auto or point", "auto", [Normal.], [Normale.]),
    P("planar", "bool", "false", [The path is planar (fill it as one patch).], [Le chemin est plan (le remplir comme un seul patch).]),
    P("boundary", "path", none, [Boundary path of a patch.], [Contour d'un patch.]),
    P("holes", "array", "()", [Holes of a patch (paths).], [Trous d'un patch (chemins).]),
  ),
  ex: ```
picture(width: 3.6cm, projection: view-projection("iso"),
  draw(surface(unitsquare3), rgb("#9db4d4")),
  draw(unitsquare3, black))
```)

== #T("Unit solids and boxes", "Solides unitaires et boîtes")

#api("unit solids", "unitsphere  unithemisphere  unitcylinder  unitcone  unitsolidcone  unitcube  unitdisk  unitplane  unitfrustum(ta, tb)  unitbox  box3(v1, v2)  unitcircle3  unitsquare3",
  T[Ready-made unit shapes (from Asymptote's `solids`): the unit sphere, hemisphere, cylinder and cone (radius 1, height 1), the solid cone, the unit cube, disk, plane, the frustum of ratio `ta` : `tb`. `box3(v1, v2)` is the wireframe box between two opposite corners (hidden edges dashed); `unitbox` is `box3(O, (1, 1, 1))`. Scale and move them with transforms (`shift`, `scale3`, `rotate3`, `apply`).][Formes unitaires toutes faites (du module `solids` d'Asymptote) : sphère, hémisphère, cylindre et cône unitaires (rayon 1, hauteur 1), cône plein, cube, disque, plan unitaires, tronc de cône de rapport `ta` : `tb`. `box3(v1, v2)` est la boîte filaire entre deux sommets opposés (arêtes cachées en pointillés) ; `unitbox` vaut `box3(O, (1, 1, 1))`. On les met à l'échelle et on les déplace avec les transformations (`shift`, `scale3`, `rotate3`, `apply`).],
  params: (
    P("ta, tb", "number", none, [Radii of the frustum at the top and at the bottom (unit height).], [Rayons du tronc de cône en haut et en bas (hauteur unité).]),
    P("v1, v2", "point", none, [Opposite corners of the box.], [Sommets opposés de la boîte.]),
  ),
  ex: ```
picture(width: 3.8cm, projection: view-projection("iso"),
  draw(surface(apply(scale3(1.6, y: 1, z: 0.8), unitcube)), rgb("#9db4d4")),
  draw(box3((-0.2, -0.2, 0), (1.8, 1.2, 0.8)), black))
```)
