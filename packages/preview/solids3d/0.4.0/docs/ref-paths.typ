#import "_h.typ": *

= #T("Reference — points, paths and transforms", "Référence — points, chemins et transformations")

#T[
A *point* is an array `(x, y, z)`. A *path* (`path3`) is a chain of Bézier segments in space, with Asymptote's Hobby-spline semantics. A *transform* is a 4 × 4 matrix. Constants: `O = (0, 0, 0)`, `X`, `Y`, `Z` (unit vectors).
][
Un *point* est un tableau `(x, y, z)`. Un *chemin* (`path3`) est une chaîne de segments de Bézier dans l'espace, avec la sémantique des splines de Hobby d'Asymptote. Une *transformation* est une matrice 4 × 4. Constantes : `O = (0, 0, 0)`, `X`, `Y`, `Z` (vecteurs unitaires).
]

== #T("Vectors", "Vecteurs")

#table(columns: (auto, 1fr), stroke: (x: none, y: 0.3pt + luma(200)), inset: (x: 5pt, y: 3.5pt),
  table.header([#T("function", "fonction")], [#T("result", "résultat")]),
  raw("vadd(a, b)  vsub(a, b)  vmul(k, v)  vneg(v)", lang: "typc"), T[sum, difference, scalar product, opposite][somme, différence, produit par un scalaire, opposé],
  raw("vdot(a, b)  vcross(a, b)", lang: "typc"), T[dot product, cross product][produit scalaire, produit vectoriel],
  raw("vabs(v)  vunit(v)  vsum(..vs)", lang: "typc"), T[norm, unit vector, sum of several][norme, vecteur unitaire, somme de plusieurs],
  raw("interp(a, b, t)", lang: "typc"), T[point `a + t (b − a)`][point `a + t (b − a)`],
  raw("vmin  vmax  vproject(u, v)  vperp(v)  vangle(a, b)", lang: "typc"), T[component-wise min / max, projection of `u` on `v`, a perpendicular vector, angle in degrees][min / max composante par composante, projection de `u` sur `v`, un vecteur perpendiculaire, angle en degrés],
  raw("vdir(θ, φ)  expi(θ, φ)  colatitude  latitude  longitude", lang: "typc"), T[spherical coordinates (angles in degrees)][coordonnées sphériques (angles en degrés)],
)

== #T("Building paths", "Construire des chemins")

#api("line3", "line3(..points, cyclic: false)",
  T[Polyline through the points (straight segments).][Ligne brisée passant par les points (segments droits).],
  params: (
    P("..points", "point", none, [Vertices.], [Sommets.]),
    P("cyclic", "bool", "false", [Close the path.], [Fermer le chemin.]),
  ),
  ex: ```
fig(draw(line3(O, X, X + Y, (0, 1, 1), (0, 0, 1), cyclic: true), linewidth(1.2pt)), size: 2.6cm)
```)

#api("spline3", "spline3(..points, cyclic: false)",
  T[Smooth Hobby spline through the points: the natural way to describe a curve by a few points.][Spline de Hobby lisse passant par les points : la façon naturelle de décrire une courbe avec quelques points.],
  params: (
    P("..points", "point", none, [Points to interpolate.], [Points à interpoler.]),
    P("cyclic", "bool", "false", [Closed curve.], [Courbe fermée.]),
  ),
  ex: ```
fig(draw(spline3((0, 0, 0), (1, 0.6, 0.5), (2, 0, 1), (3, 0.8, 1.4)), linewidth(1.4pt)), size: 4cm, view: "front")
```)

#api("guide3", "guide3(..items, join: \"--\")",
  T[General guide with Asymptote's join operators between nodes: `\"--\"` straight, `\"..\"` Hobby curve. Items are points; `join` sets the operator used between them.][Guide général avec les opérateurs de jonction d'Asymptote entre les nœuds : `"--"` droit, `".."` courbe de Hobby. Les éléments sont des points ; `join` fixe l'opérateur utilisé entre eux.],
  params: (
    P("..items", "point", none, [Nodes.], [Nœuds.]),
    P("join", "string", "\"--\"", [`"--"` or `".."`.], [`"--"` ou `".."`.]),
  ),
  ex: ```
fig(draw(guide3(O, (1, 1, 0), (2, 0, 1), join: ".."), linewidth(1.4pt)), size: 3.4cm)
```)

#api("circle3 / arc3 / arc3-angles", "circle3(c, r, normal: Z)     arc3(c, v1, v2, normal: O, direction: CCW)     arc3-angles(c, r, θ1, φ1, θ2, φ2, normal: O, direction: auto)",
  T[Circle of centre `c`, radius `r` in the plane normal to `normal`. `arc3` is the arc from `v1` to `v2` seen from `c`. `arc3-angles` gives the ends in spherical angles (colatitude θ, longitude φ, in degrees).][Cercle de centre `c`, de rayon `r` dans le plan normal à `normal`. `arc3` est l'arc de `v1` à `v2` vu depuis `c`. `arc3-angles` donne les extrémités en angles sphériques (colatitude θ, longitude φ, en degrés).],
  params: (
    P("c", "point", none, [Centre.], [Centre.]),
    P("r", "number", none, [Radius.], [Rayon.]),
    P("normal", "point", "Z / O", [Normal to the plane (`O` = deduced from the ends).], [Normale au plan (`O` = déduite des extrémités).]),
    P("v1, v2", "point", none, [Ends of the arc.], [Extrémités de l'arc.]),
    P("direction", "CCW or CW", "CCW", [Orientation of the arc.], [Orientation de l'arc.]),
  ),
  ex: ```
fig(draw(circle3(O, 1, normal: X), linewidth(1pt)), draw(circle3(O, 1, normal: Y), linewidth(1pt)),
  draw(circle3(O, 1), linewidth(1pt)), size: 3cm)
```)

#api("graph3", "graph3(f, a, b, n: 100, join: \"--\")",
  T[Path of the curve `t ↦ f(t)` sampled at `n` points between `a` and `b`.][Chemin de la courbe `t ↦ f(t)` échantillonnée en `n` points entre `a` et `b`.],
  params: (
    P("f", "function", none, [`t => (x, y, z)`.], [`t => (x, y, z)`.]),
    P("a, b", "number", none, [Interval.], [Intervalle.]),
    P("n", "integer", "100", [Samples.], [Échantillons.]),
    P("join", "string", "\"--\"", [`".."` gives a smooth spline.], [`".."` donne une spline lisse.]),
  ),
  ex: ```
fig(draw(graph3(t => (calc.cos(t), calc.sin(t), t / 8), 0, 6 * calc.pi, n: 120), linewidth(1.2pt)), size: 2.6cm, view: "front")
```)

#api("plane", "plane(u, v, o: O)",
  T[A parallelogram (closed path) spanned by `u` and `v` from the origin `o`: a handy way to draw a plane section.][Un parallélogramme (chemin fermé) engendré par `u` et `v` depuis l'origine `o` : pratique pour dessiner une section plane.],
  params: (
    P("u, v", "point", none, [Edge vectors.], [Vecteurs des côtés.]),
    P("o", "point", "O", [Corner.], [Coin.]),
  ),
  ex: ```
fig(draw(surface(plane(2 * X, 2 * Y)), rgb("#cfd8e8")), sphere(0.8, c: (1, 1, 0.8)), size: 4cm)
```)

== #T("Operations on paths", "Opérations sur les chemins")

#table(columns: (auto, 1fr), stroke: (x: none, y: 0.3pt + luma(200)), inset: (x: 5pt, y: 3.5pt),
  table.header([#T("function", "fonction")], [#T("result", "résultat")]),
  raw("point(p, t)  dir(p, t)", lang: "typc"), T[position / unit tangent at time `t` (integer = node)][position / tangente unitaire au temps `t` (entier = nœud)],
  raw("size3(p)  length3(p)  cyclic(p)", lang: "typc"), T[number of nodes / segments, is it closed][nombre de nœuds / de segments, fermé ou non],
  raw("arclength(p)  arctime(p, s)  reltime(p, r)  midpoint(p)", lang: "typc"), T[length; time at arc length `s`; time at fraction `r` of the length; midpoint][longueur ; temps à l'abscisse curviligne `s` ; temps à la fraction `r` de la longueur ; milieu],
  raw("subpath(p, a, b)  reverse(p)", lang: "typc"), T[portion between times `a` and `b`; reversed][portion entre les temps `a` et `b` ; inversé],
  raw("join(p, q)  join-all(..ps)  close3(p)", lang: "typc"), T[concatenation; closing][concaténation ; fermeture],
  raw("min3(p)  max3(p)", lang: "typc"), T[corners of the bounding box][coins de la boîte englobante],
  raw("flatten3(p, n: 8)  nodes3(p)", lang: "typc"), T[polyline approximation; list of the nodes][approximation par ligne brisée ; liste des nœuds],
)

== #T("Transforms", "Transformations")

#api("shift / scale3 / rotate3 / reflect3", "shift(v)  scale3(x, y: auto, z: auto)  xscale3(x)  yscale3(y)  zscale3(z)  rotate3(a, u, v: none)  reflect3(u, v, w)  align3(u)  compose(..Ts)  apply(T, object)",
  T[Transforms are 4 × 4 matrices; `compose(T1, T2)` applies `T2` first. `apply(T, obj)` transforms a point, a path, a surface, a solid of revolution. `rotate3(a, u)` rotates by `a` degrees about the axis through the origin with direction `u` (or through `v` and direction `u` if `v` is given).][Les transformations sont des matrices 4 × 4 ; `compose(T1, T2)` applique `T2` en premier. `apply(T, obj)` transforme un point, un chemin, une surface, un solide de révolution. `rotate3(a, u)` tourne de `a` degrés autour de l'axe d'origine l'origine et de direction `u` (ou passant par `v` si `v` est donné).],
  params: (
    P("v", "point", none, [Translation vector (`shift(x, y, z)` also works).], [Vecteur de translation (`shift(x, y, z)` marche aussi).]),
    P("x, y, z", "number", none, [Scale factors (`y` and `z` default to `x`).], [Facteurs d'échelle (`y` et `z` valent `x` par défaut).]),
    P("a", "number", none, [Angle in degrees.], [Angle en degrés.]),
    P("u", "point", none, [Axis direction.], [Direction de l'axe.]),
    P("T", "transform", none, [A matrix.], [Une matrice.]),
  ),
  ex: ```
let c = cone(0.6, 1.4)
fig(c, apply(compose(shift(1.4, 0, 0), rotate3(100, Y)), c), size: 4.4cm)
```)
