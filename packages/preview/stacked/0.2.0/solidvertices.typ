#import "solidsection.typ": _p3, _sub3, _dot3, _cross3, _norm3, _mul3, _unit3, _lc

// =============================================================================
// solidvertices.typ
// Coordonnées des sommets de polygones et de solides réguliers
//
//   regpolygon(n, ...)            polygone régulier à n côtés
//   regpyramid(n, ...)            pyramide régulière (base à n côtés)
//   regprism(n, ...)              prisme droit à base régulière
//   regantiprism(n, ...)          antiprisme (base du haut tournée de 180°/n)
//   regbipyramid(n, ...)          bipyramide (deux pyramides base contre base)
//   regpolyhedron(nom, ...)       polyèdre régulier : "tétraèdre", "cube",
//                                 "octaèdre", "dodécaèdre", "icosaèdre"
//
// Chaque fonction renvoie un tableau de points (x, y, z), à passer directement
// à `vertices:` de polysection ou de polyunfold :
//
//   #polysection(0, 1, 0, -0.3, vertices: regpyramid(5, side: 2, height: 3))
//   #polyunfold(vertices: regpolyhedron("icosaèdre", side: 1.5), steps: (0, 1))
//
// Paramètres communs
//   radius   rayon du cercle (ou de la sphère) circonscrit, au centre du solide
//   side     longueur d'une arête (donne radius OU side ; par défaut radius: 1)
//   center   point de référence (voir plus bas), par défaut (0, 0, 0)
//   axis     direction de l'axe, par défaut (0, 1, 0) ; le solide est posé sur
//            sa face du dessous, l'axe pointe vers le haut
//   phase    rotation supplémentaire autour de l'axe, en degrés
//   start    "side" (défaut) : un côté du polygone de base fait face à
//            l'observateur ; "vertex" : c'est un sommet
//   height   hauteur (pyramide, prisme, antiprisme, bipyramide : de chaque pyramide)
//   centered true : `center` est le milieu de la hauteur au lieu du centre de la base
//
// Pour les polygones, pyramides, prismes et antiprismes, `center` est le centre
// de la base ; pour la bipyramide, le centre commun des deux pyramides ; pour les
// polyèdres réguliers, le centre du solide.
// Ordre des sommets : base d'abord (dans le sens direct autour de l'axe), puis le
// ou les sommets du haut (même ordre que la base), puis éventuellement le bas.
// L'orientation « face vers l'observateur » suppose la vue oblique usuelle, où
// z est dirigé vers l'observateur ; elle se règle avec `phase`.
// =============================================================================

#let _clean(p) = p.map(c => if calc.abs(c) < 1e-12 { 0 } else { c })

/// Direction de référence dans le plan perpendiculaire à e : la projection de +z.
#let _ref-dir(e) = {
  let z = (0, 0, 1)
  let r = _sub3(z, _mul3(_dot3(z, e), e))
  if _norm3(r) < 1e-6 { r = _sub3((1, 0, 0), _mul3(e.at(0), e)) }
  _unit3(r)
}

/// Rotation d'un vecteur d'un angle phi (radians) autour de l'axe e (unitaire).
#let _rot-axis(w, e, phi) = {
  let c = calc.cos(phi)
  let s = calc.sin(phi)
  _lc((0, 0, 0), ((c, w), (s, _cross3(e, w)), ((1 - c) * _dot3(e, w), e)))
}

/// Rayon circonscrit d'un polygone à n côtés, à partir de radius ou side.
#let _ngon-radius(n, radius, side) = {
  assert(n >= 3, message: "Un polygone a au moins 3 côtés.")
  assert(radius == none or side == none, message: "Donne radius ou side, pas les deux.")
  if side != none { side / (2 * calc.sin(calc.pi / n)) }
  else if radius != none { radius }
  else { 1 }
}

/// Les n sommets d'un polygone régulier de centre C, de rayon R, dans le plan
/// perpendiculaire à e (unitaire).
#let _ngon(n, R, C, e, phase, start) = {
  let ref = _ref-dir(e)
  let tg = _cross3(e, ref)
  range(n).map(i => {
    let th = (if start == "vertex" { 2 * i } else { 2 * i + 1 }) * calc.pi / n + phase * calc.pi / 180
    _clean(_lc(C, ((R * calc.cos(th), ref), (R * calc.sin(th), tg))))
  })
}

// Sommets d'un polygone régulier dans le plan perpendiculaire à `axis`, dans le sens direct autour de l'axe.
// Le polygone est défini par son nombre de côtés et par son rayon circonscrit ou la longueur de son côté. Les
// points sont plans : ils servent à tracer le polygone, mais pas de `vertices` pour un solide.
// Exemple d'utilisation :
// ```example
// #cetz.canvas({
//   import cetz.draw: *
//   line(..regpolygon(5, side: 2, axis: (0, 0, 1)), close: true)
// })
// ```
// -> array (de points (x, y, z))
#let regpolygon(
  // Nombre de côtés (au moins 3) -> int
  n,
  // Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  // donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  // Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  // Centre du polygone -> array
  center: (0, 0, 0),
  // Normale au plan du polygone (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  // "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  // "vertex" : c'est un sommet -> str
  start: "side",
) = _ngon(n, _ngon-radius(n, radius, side), _p3(center), _unit3(_p3(axis)), phase, start)

// Sommets d'une pyramide régulière : les n sommets de la base (dans le sens direct autour de l'axe), puis le
// sommet de la pyramide en dernier. À utiliser comme `vertices:` de `polysection` ou de `polyunfold`.
// Exemples d'utilisation :
// ```example
// #polysection(0, 1, 0, -0.1, vertices: regpyramid(5, side: 2, height: 3))
// ```
// Dépliage d'une pyramide à base carrée
// ```example
// #polyunfold(vertices: regpyramid(4, side: 2, height: 3), steps: (0, 0.5, 1), length: 0.5cm)
// ```
// -> array (de points (x, y, z))
#let regpyramid(
  // Nombre de côtés de la base (au moins 3) -> int
  n,
  // Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  // donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  // Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  // Hauteur de la pyramide -> int | float
  height: 1,
  // Centre de la base (ou milieu de la hauteur avec centered: true) -> array
  center: (0, 0, 0),
  // Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  // "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  // "vertex" : c'est un sommet -> str
  start: "side",
  // true : `center` est le milieu de la hauteur au lieu du centre de la base -> bool
  centered: false,
) = {
  let e = _unit3(_p3(axis))
  let C = if centered { _lc(_p3(center), ((-height / 2, e),)) } else { _p3(center) }
  _ngon(n, _ngon-radius(n, radius, side), C, e, phase, start) + (_clean(_lc(C, ((height, e),))),)
}

// Sommets d'un prisme droit à base régulière : les n sommets de la base, puis les n sommets de la face
// supérieure dans le même ordre. À utiliser comme `vertices:` de `polysection` ou de `polyunfold`.
// Exemples d'utilisation :
// ```example
// #polysection(1, 0.4, 0, 0.2, vertices: regprism(6, radius: 1.2, height: 2.5))
// ```
// Patron à plat d'un prisme à base triangulaire
// ```example
// #polyunfold(vertices: regprism(3, side: 1, height: 2), view: "top")
// ```
// -> array (de points (x, y, z))
#let regprism(
  // Nombre de côtés de la base (au moins 3) -> int
  n,
  // Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  // donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  // Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  // Hauteur du prisme -> int | float
  height: 1,
  // Centre de la base (ou milieu de la hauteur avec centered: true) -> array
  center: (0, 0, 0),
  // Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  // "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  // "vertex" : c'est un sommet -> str
  start: "side",
  // true : `center` est le milieu de la hauteur au lieu du centre de la base -> bool
  centered: false,
) = {
  let e = _unit3(_p3(axis))
  let C = if centered { _lc(_p3(center), ((-height / 2, e),)) } else { _p3(center) }
  let R = _ngon-radius(n, radius, side)
  _ngon(n, R, C, e, phase, start) + _ngon(n, R, _lc(C, ((height, e),)), e, phase, start)
}

// Sommets d'un antiprisme : comme un prisme, mais la face supérieure est tournée de 180°/n par rapport à la
// base, ce qui donne des faces latérales triangulaires. Mêmes conventions que `regprism`.
// Exemple d'utilisation :
// ```example
// #polyunfold(vertices: regantiprism(5, radius: 1.2, height: 1.2), view: "top")
// ```
// -> array (de points (x, y, z))
#let regantiprism(
  // Nombre de côtés de chaque base (au moins 3) -> int
  n,
  // Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  // donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  // Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  // Distance entre les plans des deux bases -> int | float
  height: 1,
  // Centre de la base (ou milieu de la hauteur avec centered: true) -> array
  center: (0, 0, 0),
  // Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  // "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  // "vertex" : c'est un sommet -> str
  start: "side",
  // true : `center` est le milieu de la hauteur au lieu du centre de la base -> bool
  centered: false,
) = {
  let e = _unit3(_p3(axis))
  let C = if centered { _lc(_p3(center), ((-height / 2, e),)) } else { _p3(center) }
  let R = _ngon-radius(n, radius, side)
  _ngon(n, R, C, e, phase, start) + _ngon(n, R, _lc(C, ((height, e),)), e, phase + 180 / n, start)
}

// Sommets d'une bipyramide : les n sommets du polygone du milieu, puis le sommet du haut, puis celui du bas.
// Exemple d'utilisation :
// ```example
// #polysection(0, 1, 0, -0.5, vertices: regbipyramid(5, side: 2, height: 3))
// ```
// -> array (de points (x, y, z))
#let regbipyramid(
  // Nombre de côtés du polygone du milieu (au moins 3) -> int
  n,
  // Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  // donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  // Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  // Hauteur de chaque pyramide (distance du polygone du milieu à chaque sommet) -> int | float
  height: 1,
  // Centre du polygone du milieu -> array
  center: (0, 0, 0),
  // Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
  // "side" : un côté du polygone de base fait face à l'observateur (direction +z de la vue oblique) ;
  // "vertex" : c'est un sommet -> str
  start: "side",
) = {
  let e = _unit3(_p3(axis))
  let C = _p3(center)
  _ngon(n, _ngon-radius(n, radius, side), C, e, phase, start) + (
    _clean(_lc(C, ((height, e),))),
    _clean(_lc(C, ((-height, e),))),
  )
}

// -----------------------------------------------------------------------------
// Polyèdres réguliers
//   Chaque solide est défini par ses coordonnées usuelles ; on le fait tourner pour
//   qu'une face (de normale sortante d0) soit en bas, un de ses côtés faisant face
//   à l'observateur, puis on le met à l'échelle et on le place.
// -----------------------------------------------------------------------------
#let _phi = (1 + calc.sqrt(5)) / 2

#let _signs = (-1, 1)

/// Sommets canoniques, normale sortante d'une face, rayon circonscrit, arête.
#let _canonical(key) = {
  let phi = _phi
  let ip = 1 / phi
  if key == "tetra" {
    (
      verts: ((1, 1, 1), (1, -1, -1), (-1, 1, -1), (-1, -1, 1)),
      d0: (-1, -1, -1), rc: calc.sqrt(3), edge: 2 * calc.sqrt(2),
    )
  } else if key == "cube" {
    let vs = ()
    for a in _signs { for b in _signs { for c in _signs { vs.push((a, b, c)) } } }
    (verts: vs, d0: (0, 0, -1), rc: calc.sqrt(3), edge: 2)
  } else if key == "octa" {
    (
      verts: ((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)),
      d0: (-1, -1, -1), rc: 1, edge: calc.sqrt(2),
    )
  } else if key == "icosa" {
    let vs = ()
    for a in _signs {
      for b in _signs {
        vs.push((0, a, b * phi))
        vs.push((a, b * phi, 0))
        vs.push((b * phi, 0, a))
      }
    }
    (verts: vs, d0: (-phi, 0, -(2 * phi + 1)), rc: calc.sqrt(1 + phi * phi), edge: 2)
  } else if key == "dodeca" {
    let vs = ()
    for a in _signs { for b in _signs { for c in _signs { vs.push((a, b, c)) } } }
    for a in _signs {
      for b in _signs {
        vs.push((0, a * ip, b * phi))
        vs.push((a * ip, b * phi, 0))
        vs.push((a * phi, 0, b * ip))
      }
    }
    (verts: vs, d0: (-1, 0, -phi), rc: calc.sqrt(3), edge: 2 * ip)
  } else {
    panic("Polyèdre régulier inconnu : " + key)
  }
}

#let _aliases = (
  "tetrahedron": "tetra", "tétraèdre": "tetra", "tetraedre": "tetra", "tétraedre": "tetra",
  "cube": "cube", "hexahedron": "cube", "hexaèdre": "cube", "hexaedre": "cube",
  "octahedron": "octa", "octaèdre": "octa", "octaedre": "octa",
  "dodecahedron": "dodeca", "dodécaèdre": "dodeca", "dodecaedre": "dodeca", "dodécaedre": "dodeca",
  "icosahedron": "icosa", "icosaèdre": "icosa", "icosaedre": "icosa",
)

// Sommets d'un polyèdre régulier (solide de Platon) : "tétraèdre", "cube", "octaèdre", "dodécaèdre" ou
// "icosaèdre" (les noms anglais sont acceptés). Le solide est posé sur l'une de ses faces, l'axe pointant vers le haut,
// et un côté de cette face fait face à l'observateur ; c'est aussi la face que `polyunfold` laisse fixe par défaut.
// Exemples d'utilisation :
// ```example
// #polysection(0.3, 1, 0.2, 0, vertices: regpolyhedron("dodécaèdre", side: 1))
// ```
// Patron à plat d'un icosaèdre
// ```example
// #polyunfold(vertices: regpolyhedron("icosaèdre", side: 1.5), view: "top", length: 0.6cm)
// ```
// -> array (de points (x, y, z))
#let regpolyhedron(
  // Nom du polyèdre : "tétraèdre", "cube", "octaèdre", "dodécaèdre" ou "icosaèdre" -> str
  name,
  // Rayon du cercle (ou de la sphère) circonscrit, c'est-à-dire la distance du centre à un sommet ;
  // donner radius OU side, pas les deux (par défaut radius: 1) -> none | int | float
  radius: none,
  // Longueur d'un côté (d'une arête pour un solide) ; donner side OU radius -> none | int | float
  side: none,
  // Centre du solide -> array
  center: (0, 0, 0),
  // Direction de l'axe, vers le haut (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Rotation supplémentaire autour de l'axe, en degrés, dans le sens direct -> int | float
  phase: 0,
) = {
  assert(radius == none or side == none, message: "Donne radius ou side, pas les deux.")
  let nm = lower(name)
  assert(nm in _aliases, message: "Polyèdre régulier inconnu : " + name
    + " (tétraèdre, cube, octaèdre, dodécaèdre, icosaèdre)")
  let cn = _canonical(_aliases.at(nm))
  let e = _unit3(_p3(axis))
  let C = _p3(center)
  let ref = _ref-dir(e)
  let scale = if side != none { side / cn.edge } else if radius != none { radius / cn.rc } else { 1 / cn.rc }

  // face du bas : sommets, centre, milieu d'une arête
  let d = _unit3(cn.d0)
  let hmax = calc.max(..cn.verts.map(v => _dot3(v, d)))
  let F = cn.verts.filter(v => hmax - _dot3(v, d) < 1e-7)
  let cF = (
    F.map(v => v.at(0)).sum() / F.len(),
    F.map(v => v.at(1)).sum() / F.len(),
    F.map(v => v.at(2)).sum() / F.len(),
  )
  let f0 = F.at(0)
  let f1 = F.slice(1).sorted(key: w => _norm3(_sub3(w, f0))).first()
  let m = _lc(f0, ((0.5, _sub3(f1, f0)),))
  let a1 = _unit3(_sub3(m, cF))
  let a2 = _cross3(d, a1)
  let b = _mul3(-1, _cross3(e, ref))

  // rotation : d -> -e (face en bas), a1 -> ref (côté vers l'observateur)
  cn.verts.map(v => {
    let w = _lc((0, 0, 0), ((_dot3(v, a1), ref), (_dot3(v, a2), b), (-_dot3(v, d), e)))
    let w2 = if phase == 0 { w } else { _rot-axis(w, e, phase * calc.pi / 180) }
    _clean(_lc(C, ((scale, w2),)))
  })
}
