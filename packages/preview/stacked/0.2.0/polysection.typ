#import "@preview/cetz:0.5.2" as cetz: canvas, draw

// =============================================================================
// HELPERS GÉOMÉTRIQUES & INTERSECTIONS DE DROITES 3D
// =============================================================================

#let _sub3(u, v) = (u.at(0)-v.at(0), u.at(1)-v.at(1), u.at(2, default:0)-v.at(2, default:0))
#let _dot3(u, v) = u.at(0)*v.at(0) + u.at(1)*v.at(1) + u.at(2, default:0)*v.at(2, default:0)
#let _cross3(u, v) = (
  u.at(1)*v.at(2, default:0) - u.at(2, default:0)*v.at(1),
  u.at(2, default:0)*v.at(0) - u.at(0)*v.at(2, default:0),
  u.at(0)*v.at(1) - u.at(1)*v.at(0)
)
#let _norm3(v) = calc.sqrt(_dot3(v, v))

#let _project-pt(pt, x, y, z) = (
  pt.at(0)*x.at(0) + pt.at(1)*y.at(0) + pt.at(2, default:0)*z.at(0),
  pt.at(0)*x.at(1) + pt.at(1)*y.at(1) + pt.at(2, default:0)*z.at(1)
)

#let _add-unique-pt(pts, p, eps) = {
  for pt in pts {
    let d = _sub3(pt, p)
    if _dot3(d, d) < eps*eps { return pts }
  }
  pts.push(p)
  pts
}

/// Retourne une nouvelle liste contenant uniquement les points de `l2`
/// qui ne se trouvent pas déjà dans `l1` (à epsilon près).
#let _filter-new-points(l1, l2, eps: 1e-6) = {
  // On commence avec une copie de l1 (ou une liste vide si tu veux seulement les rescapés de l2)
  let result = l1
  let unique-l2 = ()

  for p2 in l2 {
    let exists = false
    for p1 in result {
      let d = _sub3(p2, p1)
      if _dot3(d, d) < eps * eps {
        exists = true
        break
      }
    }
    // Si le point n'est dans aucune des listes cumulées, on le garde
    if not exists {
      unique-l2.push(p2)
      result.push(p2) // Optionnel : l'ajoute pour éviter les doublons internes à l2 aussi
    }
  }
  
  unique-l2
}

#let _remove-duplicates(l1, l2, eps: 1e-6) = {
  l2.filter(p2 => {
    // On garde p2 seulement s'il n'est PAS présent dans l1
    not l1.any(p1 => {
      let d = _sub3(p2, p1)
      _dot3(d, d) < eps * eps
    })
  })
}

#let _get-view-direction(x, y, z) = {
  let r1 = (x.at(0), y.at(0), z.at(0))
  let r2 = (x.at(1), y.at(1), z.at(1))
  let v = _cross3(r1, r2)
  if v.at(2, default:0) > 0 {
    (-v.at(0), -v.at(1), -v.at(2))
  } else {
    v
  }
}

#let _build-convex-faces(vertices, eps: 1e-6) = {
  let n = vertices.len()
  let faces = ()
  let center = (
    vertices.map(v => v.at(0)).sum() / n,
    vertices.map(v => v.at(1)).sum() / n,
    vertices.map(v => v.at(2, default:0)).sum() / n
  )

  for i in range(n) {
    for j in range(i + 1, n) {
      for k in range(j + 1, n) {
        let A = vertices.at(i); let B = vertices.at(j); let C = vertices.at(k)
        let norm = _cross3(_sub3(B, A), _sub3(C, A))
        let nlen = _norm3(norm)
        if nlen < eps { continue }

        let side = 0; let valid = true
        for m in range(n) {
          if m == i or m == j or m == k { continue }
          let d = _dot3(norm, _sub3(vertices.at(m), A)) / nlen
          if calc.abs(d) > eps {
            let current-side = if d > 0 { 1 } else { -1 }
            if side == 0 { side = current-side }
            else if side != current-side { valid = false; break }
          }
        }

        if valid {
          // jj et kk : copies locales (ne jamais modifier les variables j et k des
          // boucles for, sous peine de fausser les triplets suivants)
          let jj = j; let kk = k
          if _dot3(norm, _sub3(A, center)) < 0 {
            norm = (-norm.at(0), -norm.at(1), -norm.at(2))
            jj = k; kk = j
          }
          
          let face-indices = (i, jj, kk)
          for m in range(n) {
            if m == i or m == jj or m == kk { continue }
            if calc.abs(_dot3(norm, _sub3(vertices.at(m), A))) / nlen < eps {
              if not face-indices.contains(m) { face-indices.push(m) }
            }
          }

          let u = _sub3(vertices.at(jj), A)
          let u-len = _norm3(u)
          if u-len > eps {
            u = (u.at(0)/u-len, u.at(1)/u-len, u.at(2, default:0)/u-len)
            let v = _cross3(norm, u)
            let v-len = _norm3(v)
            if v-len > eps {
              v = (v.at(0)/v-len, v.at(1)/v-len, v.at(2, default:0)/v-len)
              let f-center = (
                face-indices.map(idx => vertices.at(idx).at(0)).sum() / face-indices.len(),
                face-indices.map(idx => vertices.at(idx).at(1)).sum() / face-indices.len(),
                face-indices.map(idx => vertices.at(idx).at(2, default:0)).sum() / face-indices.len()
              )
              
              let sorted-f = face-indices.map(idx => {
                let w = _sub3(vertices.at(idx), f-center)
                (idx: idx, angle: calc.atan2(_dot3(w, v), _dot3(w, u)))
              }).sorted(key: item => item.angle).map(item => item.idx)

              let is-dup = faces.any(f => {
                if f.len() != sorted-f.len() { return false }
                sorted-f.all(idx => f.contains(idx))
              })
              if not is-dup { faces.push(sorted-f) }
            }
          }
        }
      }
    }
  }
  faces
}

#let _convex-hull-2d(pts, eps: 1e-6) = {
  if pts.len() <= 3 { return pts.map(item => item.pt3d) }
  let sorted = pts.sorted(key: item => (item.x, item.y))

  let lower = ()
  for p in sorted {
    while lower.len() >= 2 {
      let l1 = lower.at(lower.len() - 2)
      let l2 = lower.at(lower.len() - 1)
      let cross2d = (l2.x - l1.x)*(p.y - l1.y) - (l2.y - l1.y)*(p.x - l1.x)
      if cross2d <= eps { let _ = lower.pop() } else { break }
    }
    lower.push(p)
  }

  let upper = ()
  for p in sorted.rev() {
    while upper.len() >= 2 {
      let u1 = upper.at(upper.len() - 2)
      let u2 = upper.at(upper.len() - 1)
      let cross2d = (u2.x - u1.x)*(p.y - u1.y) - (u2.y - u1.y)*(p.x - u1.x)
      if cross2d <= eps { let _ = upper.pop() } else { break }
    }
    upper.push(p)
  }

  let _ = lower.pop()
  let _ = upper.pop()
  (lower + upper).map(item => item.pt3d)
}

// =============================================================================
// FONCTION PRINCIPALE : polysection
// =============================================================================

// Dessine un polyèdre convexe et sa section par un plan, en projection oblique (CeTZ).
// Le polyèdre est défini par la liste de ses sommets : les faces sont déduites automatiquement (enveloppe
// convexe). Les arêtes cachées sont en pointillés ; la section est remplie et ses parties cachées sont en
// pointillés. Le plan se donne par trois points ou par les quatre coefficients de son équation cartésienne.
// Ancres : "0", "1", ... pour les sommets (dans l'ordre de `vertices`), puis les points d'intersection des
// prolongements (voir `show-extensions` et `show-all`) ; `help: true` les numérote.
// Exemples d'utilisation :
// ```example
// #polysection((-1, -1, 0), (1, 0, 1), (0, 1, -1))
// ```
// Plan donné par trois points nommés, avec les prolongements des côtés de la section
// ```example
// #polysection((-1, -1, 0), (1, 0, 1), (0, 1, -1), plane-names: ($A$, $B$, $C$), show-extensions: true)
// ```
// Pyramide régulière (sommets calculés par `regpyramid`) avec le nom des sommets
// ```example
// #polysection(0, 1, 0, -0.5, vertices: regpyramid(4, side: 2, height: 3),
//   vertices-names: ($A$, $B$, $C$, $D$, $S$))
// ```
// -> content
#let polysection(
  // Sommets du polyèdre convexe, sous forme de points (x, y, z) ; par défaut le cube [-1, 1]³. Les
  // fonctions de solidvertices (regpyramid, regprism, regpolyhedron...) en fournissent -> array
  vertices: (
    (-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
    (-1, -1,  1), (1, -1,  1), (1, 1,  1), (-1, 1,  1)
  ),
  // Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by +
  // cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de
  // 3 points) -> array | dictionary
  ..plane-args,
  // Noms des sommets, dans l'ordre de `vertices` -> none | array
  vertices-names: none,
  // Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné
  // par une équation) -> none | array
  plane-names: none,
  // Calcule et affiche les prolongements des côtés de la section et leurs points d'intersection -> bool
  show-extensions: false,
  // Affiche aussi les intersections des droites portant les côtés de la section avec les droites
  // portant les arêtes du solide -> bool
  show-all: false,
  // Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5,
  // -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  // Tolérance numérique (distances) -> float
  eps: 1e-6,
  // Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres)
  // -> content
  more: (),
  // Couleur du contour de la section -> color
  section-border: blue,
  // Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  // Affiche en rouge le numéro des ancres (sommets, puis points d'intersection) -> bool
  help: false,
  // Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) ->
  // str | array | dictionary
  hidden-style:"dashed",
  // Style des lignes de rappel des prolongements -> str | array | dictionary
  extensions-style:"dotted"
) = {
  let pos = plane-args.pos()
  let a = 0.0; let b = 0.0; let c = 0.0; let d = 0.0

  if pos.len() == 3 {
    let A = pos.at(0); let B = pos.at(1); let C = pos.at(2)
    let n = _cross3(_sub3(B, A), _sub3(C, A))
    let len = _norm3(n)
    assert(len > 0, message: "Les 3 points définissant le plan ne doivent pas être alignés.")
    a = n.at(0)/len; b = n.at(1)/len; c = n.at(2)/len
    d = -_dot3((a, b, c), A)
  } else if pos.len() == 4 {
    (a, b, c, d) = pos
  } else if pos.len() == 1 {
    let arg = pos.at(0)
    if type(arg) == dictionary {
      a = arg.a; b = arg.b; c = arg.c; d = arg.d
    } else if type(arg) == array {
      if arg.len() == 4 { (a, b, c, d) = arg }
      else if arg.len() == 3 {
        let A = arg.at(0); let B = arg.at(1); let C = arg.at(2)
        let n = _cross3(_sub3(B, A), _sub3(C, A))
        let len = _norm3(n)
        a = n.at(0)/len; b = n.at(1)/len; c = n.at(2)/len
        d = -_dot3((a, b, c), A)
      }
    }
  } else {
    panic("Format d'arguments de plan invalide.")
  }

  let faces = _build-convex-faces(vertices, eps: eps)
  let view-dir = _get-view-direction(x, y, z)
  let face-vis = faces.map(f => {
    let A = vertices.at(f.at(0)); let B = vertices.at(f.at(1)); let C = vertices.at(f.at(2))
    let face-norm = _cross3(_sub3(B, A), _sub3(C, A))
    _dot3(face-norm, view-dir) > 0
  })

  let edge-map = (:)
  for (f-idx, face) in faces.enumerate() {
    let nf = face.len()
    for i in range(nf) {
      let v1 = face.at(i); let v2 = face.at(calc.rem(i + 1, nf))
      let key = if v1 < v2 { str(v1) + "-" + str(v2) } else { str(v2) + "-" + str(v1) }
      if key in edge-map { edge-map.at(key).push(f-idx) }
      else { edge-map.insert(key, (f-idx,)) }
    }
  }

  let visible-edges = ()
  let hidden-edges = ()
  for (key, f-indices) in edge-map {
    let parts = key.split("-").map(int)
    let edge = (vertices.at(parts.at(0)), vertices.at(parts.at(1)))
    if f-indices.any(f-idx => face-vis.at(f-idx)) { visible-edges.push(edge) }
    else { hidden-edges.push(edge) }
  }

  let visible-section = ()
  let hidden-section = ()
  let all-intersections = ()

  for (f-idx, face) in faces.enumerate() {
    let vis = face-vis.at(f-idx)
    let pts = ()
    let nf = face.len()

    for i in range(nf) {
      let P1 = vertices.at(face.at(i))
      let P2 = vertices.at(face.at(calc.rem(i + 1, nf)))
      let v1 = a * P1.at(0) + b * P1.at(1) + c * P1.at(2, default: 0) + d
      let v2 = a * P2.at(0) + b * P2.at(1) + c * P2.at(2, default: 0) + d

      if calc.abs(v1) < eps and calc.abs(v2) < eps {
        pts = _add-unique-pt(pts, P1, eps)
        pts = _add-unique-pt(pts, P2, eps)
      } else if v1 * v2 <= 0 {
        let denom = v1 - v2
        if calc.abs(denom) > eps {
          let t = v1 / denom
          let ix = P1.at(0) + t * (P2.at(0) - P1.at(0))
          let iy = P1.at(1) + t * (P2.at(1) - P1.at(1))
          let iz = P1.at(2, default: 0) + t * (P2.at(2, default: 0) - P1.at(2, default: 0))
          let P-inter = (ix, iy, iz)
          pts = _add-unique-pt(pts, P-inter, eps)
          all-intersections = _add-unique-pt(all-intersections, P-inter, eps)
        }
      }
    }

    if pts.len() == 2 {
      if vis { visible-section.push(pts) }
      else { hidden-section.push(pts) }
    }
  }

  let full-section = ()
  if all-intersections.len() >= 3 {
    let count = all-intersections.len()
    let cx = all-intersections.map(p => p.at(0)).sum() / count
    let cy = all-intersections.map(p => p.at(1)).sum() / count
    let cz = all-intersections.map(p => p.at(2, default:0)).sum() / count
    let n-len = calc.sqrt(a*a + b*b + c*c)
    
    if n-len > eps {
      let n-vec = (a/n-len, b/n-len, c/n-len)
      let p0 = all-intersections.at(0)
      let u-raw = _sub3(p0, (cx, cy, cz))
      let u-len = _norm3(u-raw)
      if u-len > eps {
        let u = (u-raw.at(0)/u-len, u-raw.at(1)/u-len, u-raw.at(2, default:0)/u-len)
        let v = _cross3(n-vec, u)
        let pts-2d = all-intersections.map(pt => {
          let w = _sub3(pt, (cx, cy, cz))
          (x: _dot3(w, u), y: _dot3(w, v), pt3d: pt)
        })
        full-section = _convex-hull-2d(pts-2d, eps: eps)
      }
    }
  }

  canvas(x: x, y: y, z: z, {
    import draw: *

    // Calcul analytique et tracé des prolongements et points d'intersection (Méthode géométrique)
    let extension-points = ()
    let inter-points = ()
    if full-section.len() >= 2 {
      let n-sec = full-section.len()
      // Teste les intersections entre les droites porteuses des segments de section
      for i in range(n-sec) {
        for j in range(i + 1, n-sec) {
          let A1 = full-section.at(i)
          let B1 = full-section.at(calc.rem(i + 1, n-sec))
          let A2 = full-section.at(j)
          let B2 = full-section.at(calc.rem(j + 1, n-sec))

          let inter = cetz.intersection.line-line(A1, B1, A2, B2, ray: true) //_intersect-two-lines(A1, B1, A2, B2)
          if inter != none {
            // Vérifie que le point d'intersection n'est pas déjà dans la liste
            extension-points = _add-unique-pt(extension-points, inter, eps)
            
            // Trace les lignes de rappel en pointillés fins depuis les sommets de coupe vers l'intersection
            if show-extensions {
              line(B1, inter, stroke: (paint: section-border.lighten(20%), dash: extensions-style, thickness: 0.6pt))
              line(B2, inter, stroke: (paint: section-border.lighten(20%), dash: extensions-style, thickness: 0.6pt))
          }
          }
        }
      }
    // Teste les intersections entre les droites porteuses des segments de section et les droites portant les arêtes
    for i in range(n-sec) {
        for j in range(visible-edges.len()) {
          let A1 = full-section.at(i)
          let B1 = full-section.at(calc.rem(i + 1, n-sec))
          let (A2,B2) = visible-edges.at(j)

          let inter = cetz.intersection.line-line(A1, B1, A2, B2, ray: true) //_intersect-two-lines(A1, B1, A2, B2)
          if inter != none {//.map(it => calc.round(it,digits: 6))
            // Vérifie que le point d'intersection n'est pas déjà dans la liste
            inter-points = _add-unique-pt(inter-points, inter, eps)
            
            // Trace les lignes de rappel en pointillés fins depuis les sommets de coupe vers l'intersection
            if show-all {
              line(A1, inter, stroke: (paint: section-border.lighten(20%), dash: extensions-style, thickness: 0.6pt))
              line(A2, inter, stroke: (paint: section-border.lighten(20%), dash: extensions-style, thickness: 0.6pt))
          }
          }
        }
        for j in range(hidden-edges.len()) {
          let A1 = full-section.at(i)
          let B1 = full-section.at(calc.rem(i + 1, n-sec))
          let (A2,B2) = hidden-edges.at(j)

          let inter = cetz.intersection.line-line(A1, B1, A2, B2, ray: true) //_intersect-two-lines(A1, B1, A2, B2)
          if inter != none {
            // Vérifie que le point d'intersection n'est pas déjà dans la liste
            inter-points = _add-unique-pt(inter-points, inter, eps)
            
            // Trace les lignes de rappel en pointillés fins depuis les sommets de coupe vers l'intersection
            if show-all {
              line(B1, inter, stroke: (paint: section-border.lighten(20%), dash: extensions-style, thickness: 0.6pt))
              line(B2, inter, stroke: (paint: section-border.lighten(20%), dash: extensions-style, thickness: 0.6pt))
          }
          }
        }
      }
      inter-points = _filter-new-points(extension-points, inter-points, eps: 1e-6)
      // ou _remove-duplicates
    }

    // Remplissage de la section
    if full-section.len() >= 3 {
      line(..full-section, close: true, fill: section-fill, stroke: none)
    }

    // rgb(0, 102, 255, 35)

    // Arêtes cachées du solide (pointillés gris)
    for (k, (p1, p2)) in hidden-edges.enumerate() {
      line(p1, p2, stroke: (paint: gray.darken(20%), dash: hidden-style, thickness: 1pt), name:"h"+str(k))
    }

    // Traits de section cachés (pointillés bleus)
    for (k, (p1, p2)) in hidden-section.enumerate() {
      line(p1, p2, stroke: (paint: section-border, dash: hidden-style, thickness: 1pt), name:"hs"+str(k))
    }

    // Traits de section visibles (trait plein bleu)
    for (k, (p1, p2)) in visible-section.enumerate() {
      line(p1, p2, stroke: section-border + 1.2pt, name:"vs"+str(k))
    }

    // Arêtes visibles du solide (trait plein noir)
    for (k, (p1, p2)) in visible-edges.enumerate() {
      line(p1, p2, stroke: (cap:"round"), name:"v"+str(k))
    }

    for (k, pt) in vertices.enumerate() {
        // circle(pt, radius: 0.04, fill: blue, stroke: white + 0.5pt)
        anchor(str(k), pt)    
      }

    // Matérialisation des points d'intersection calculés pour les constructions
    
    for (k, pt) in extension-points.enumerate() {
        anchor(str(k+vertices.len()), pt)    
      }

    for (k, pt) in inter-points.enumerate() {
        anchor(str(k+vertices.len()+extension-points.len()), pt)    
      }
    

    if show-extensions or help {
      for (k, pt) in extension-points.enumerate() {
        circle(pt, radius: 0.04, fill: section-border, stroke: none)  
      }
    }

    if show-all or help {
      for (k, pt) in inter-points.enumerate() {
        circle(pt, radius: 0.04, fill: section-border, stroke: none)  
      }
    }

    if help {
      for k in range(vertices.len()+extension-points.len()+inter-points.len()) {
        content(str(k), text(red, .5em, str(k)), anchor: "south-east", padding:.05)
      }
    }

    // Calcul du centre 3D du solide pour les étiquettes
    let n-v = vertices.len()
    let c-x = vertices.map(v => v.at(0)).sum() / n-v
    let c-y = vertices.map(v => v.at(1)).sum() / n-v
    let c-z = vertices.map(v => v.at(2, default:0)).sum() / n-v
    let proj-center = _project-pt((c-x, c-y, c-z), x, y, z)

    // 1. Noms des sommets du polyèdre
    if vertices-names != none {
      for (idx, v) in vertices.enumerate() {
        if idx < vertices-names.len() {
          let name = vertices-names.at(idx)
          let pv = _project-pt(v, x, y, z)
          let pdx = pv.at(0) - proj-center.at(0)
          let pdy = pv.at(1) - proj-center.at(1)

          let anchor = if pdx >= 0 and pdy >= 0 { "south-west" }
                       else if pdx >= 0 and pdy < 0 { "north-west" }
                       else if pdx < 0 and pdy >= 0 { "south-east" }
                       else { "north-east" }

          let dist = _norm3(_sub3(v, (c-x, c-y, c-z)))
          let label-pos = if dist > 1e-5 {
            let dir = _sub3(v, (c-x, c-y, c-z))
            (v.at(0) + (dir.at(0)/dist)*0.12, v.at(1) + (dir.at(1)/dist)*0.12, v.at(2, default:0) + (dir.at(2)/dist)*0.12)
          } else { v }

          content(label-pos, [ #name ], anchor: anchor)
        }
      }
    }

    // 2. Noms des points du plan de section
    if plane-names != none and pos.len() == 3 {
      for (idx, P) in pos.enumerate() {
        if idx < plane-names.len() {
          let name = plane-names.at(idx)
          circle(P, radius: 0.05, fill: red, stroke: none)

          let pp = _project-pt(P, x, y, z)
          let pdx = pp.at(0) - proj-center.at(0)
          let pdy = pp.at(1) - proj-center.at(1)

          let anchor = if pdx >= 0 and pdy >= 0 { "south-west" }
                       else if pdx >= 0 and pdy < 0 { "north-west" }
                       else if pdx < 0 and pdy >= 0 { "south-east" }
                       else { "north-east" }

          let dist = _norm3(_sub3(P, (c-x, c-y, c-z)))
          let label-pos = if dist > 1e-5 {
            let dir = _sub3(P, (c-x, c-y, c-z))
            (P.at(0) + (dir.at(0)/dist)*0.12, P.at(1) + (dir.at(1)/dist)*0.12, P.at(2, default:0) + (dir.at(2, default:0)/dist)*0.12)
          } else { P }

          content(label-pos, [ #text(fill: red, name) ], anchor: anchor)
        }
      }
    }
    more
  })
}

// Point situé à une fraction du segment [A C], en partant de A (en 2D ou en 3D).
// Pratique pour placer des points dans `more`, par exemple le milieu d'une arête ou d'un segment de section.
// `ratio` est un nombre entre 0 et 1 ou un pourcentage : point-ratio((0, 0, 0), 25%, (4, 0, 0)) donne (1, 0, 0).
// -> array
#let point-ratio(
  // Point de départ (x, y) ou (x, y, z) -> array
  A,
  // Fraction du segment [A C] : nombre (0.25) ou pourcentage (25%) -> int | float | ratio
  ratio,
  // Point d'arrivée, de même dimension que A -> array
  C,
) = {
  // Conversion du ratio en valeur décimale entre 0 et 1
  let r = if type(ratio) == ratio {
    ratio / 100%
  } else {
    float(ratio)
  }

  let ax = A.at(0); let ay = A.at(1)
  let cx = C.at(0); let cy = C.at(1)

  let px = ax + r * (cx - ax)
  let py = ay + r * (cy - ay)

  if A.len() > 2 or C.len() > 2 {
    let az = A.at(2, default: 0)
    let cz = C.at(2, default: 0)
    let pz = az + r * (cz - az)
    (px, py, pz)
  } else {
    (px, py)
  }
}