#import "@preview/cetz:0.5.2" as cetz: canvas, draw
#import "solidsection.typ": _p3, _sub3, _dot3, _cross3, _norm3, _mul3, _unit3, _lc, _ang, _frame, _view-k, _project-pt, _tau, _cos-roots, _mid, _fmt, _num-label

// =============================================================================
// solidunfold.typ
// Solides et patrons, avec étapes intermédiaires du dépliage (CeTZ 0.5.2)
//
//   polyunfold(vertices: (...), steps: (0, 0.5, 1), ...)    polyèdre convexe
//   cylunfold(radius:, height:, steps: ..., ...)             cylindre
//   coneunfold(radius:, height:, steps: ..., ...)            cône
//
// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat).
//   steps: (0, 0.5, 1)   les étapes à afficher côte à côte (ou t: 0.4 pour une seule)
//   columns: 2           nombre de figures par ligne (auto : une seule ligne)
//   labels: ($1$, $2$)   légendes sous les figures
//   arrows: true         flèches entre deux figures consécutives
//   length: 0.7cm        échelle du dessin (unité du canevas)
//   cotes: true          (cylindre, cône) ajoute les cotes : r, h, g sur le solide
//                        fermé (t = 0, vue oblique) ; 2πr, h, g, r sur le patron
//                        (view: "top"), plus l'angle du secteur du cône (clé a).
//                        cote-labels: (r: $3$, h: $5$, g:, p:, a:) remplace les
//                        étiquettes ; auto (seul, ou comme valeur d'une clé) donne
//                        les vraies valeurs : cote-labels: auto, (r: auto, g: auto).
//                        cote-unit: "cm", cote-digits: 2, cote-decimal: "," règlent
//                        l'écriture ; un nombre arrondi est précédé de ≈.
//                        cote-color change la couleur.
//
// Ancres, utilisables dans `more` (suffixées -1, -2, ... s'il y a plusieurs étapes ;
// la première figure garde ses coordonnées d'origine) :
//   polyunfold   f0, f1, ...   centres des faces
//                v0, v1, ...   sommets (ordre de `vertices` ; un sommet est pris
//                              sur la première face de l'arbre qui le contient)
//   cylunfold    c0, c1        centres du disque fixe et du disque qui bascule
//                pc, qc        points de contact (bas et haut)
//   coneunfold   c0, s, pc     centre de la base, sommet, point de contact
//   cotes        cote-r, cote-h, cote-g, cote-p, cote-a   milieux des lignes de cote
//                (cote-r2 : rayon du second disque du cylindre)
//   view: "top"          patron à plat vu de dessus, en vraie grandeur
//                        (par défaut : la vue oblique x, y, z, comme polysection)
//
// Le solide est posé sur sa base « inférieure », qui reste fixe : les autres
// faces se déplient autour d'elle. Les faces sont opaques, ombrées, et triées
// de la plus lointaine à la plus proche.
// Dépend de solidsection.typ (outils vectoriels).
// =============================================================================

// -----------------------------------------------------------------------------
// Géométrie
// -----------------------------------------------------------------------------
#let _add3(u, v) = (u.at(0) + v.at(0), u.at(1) + v.at(1), u.at(2) + v.at(2))

#let _centroid(pts) = {
  let n = pts.len()
  (
    pts.map(p => p.at(0)).sum() / n,
    pts.map(p => p.at(1)).sum() / n,
    pts.map(p => p.at(2)).sum() / n,
  )
}

/// Rotation du point p d'angle phi autour de la droite (A, direction unitaire a).
#let _rot(p, A, a, phi) = {
  let w = _sub3(p, A)
  let c = calc.cos(phi)
  let s = calc.sin(phi)
  _lc(A, ((c, w), (s, _cross3(a, w)), ((1 - c) * _dot3(a, w), a)))
}

/// Rotation d'un vecteur (autour d'un axe passant par l'origine).
#let _rotv(w, a, phi) = {
  let c = calc.cos(phi)
  let s = calc.sin(phi)
  _lc((0, 0, 0), ((c, w), (s, _cross3(a, w)), ((1 - c) * _dot3(a, w), a)))
}

#let _circ-pts(C, R, u, v, n) = range(n).map(i => {
  let th = _tau * i / n
  _lc(C, ((R * calc.cos(th), u), (R * calc.sin(th), v)))
})

/// Couleur ombrée selon l'inclinaison de la face par rapport à la lumière.
#let _shade(c, pts, light) = {
  let n = _cross3(_sub3(pts.at(1), pts.at(0)), _sub3(pts.at(2), pts.at(0)))
  let l = _norm3(n)
  if l < 1e-12 { c } else {
    let m = calc.abs(_dot3(n, light)) / l
    c.darken(28% * (1 - m))
  }
}

/// Une face : pts (polygone), fill, stroke (contour du polygone ou none),
/// lines (polylignes tracées en noir par-dessus), nout (normale sortante ou none).
#let _face(pts, fill, stroke, lines: (), nout: none) = (
  pts: pts, cen: _centroid(pts), fill: fill, stroke: stroke, lines: lines, nout: nout,
)

// -----------------------------------------------------------------------------
// Polyèdre convexe : faces, adjacences, arbre de dépliage
// -----------------------------------------------------------------------------
#let _convex-faces(V) = {
  let n = V.len()
  let c = _centroid(V)
  let faces = ()
  let seen = ()
  for i in range(n) {
    for j in range(i + 1, n) {
      for l in range(j + 1, n) {
        let nn = _cross3(_sub3(V.at(j), V.at(i)), _sub3(V.at(l), V.at(i)))
        let len = _norm3(nn)
        if len < 1e-9 { continue }
        nn = _mul3(1 / len, nn)
        let dd = _dot3(nn, V.at(i))
        let pos = 0
        let neg = 0
        for m in range(n) {
          let s = _dot3(nn, V.at(m)) - dd
          if s > 1e-7 { pos += 1 } else if s < -1e-7 { neg += 1 }
        }
        if (pos > 0 and neg > 0) or (pos == 0 and neg == 0) { continue }
        if _dot3(nn, c) - dd > 0 {
          nn = _mul3(-1, nn)
          dd = -dd
        }
        let idx = range(n).filter(m => calc.abs(_dot3(nn, V.at(m)) - dd) < 1e-7)
        let key = idx.map(str).join(",")
        if seen.contains(key) { continue }
        seen.push(key)
        let cen = _centroid(idx.map(m => V.at(m)))
        let (pu, pv) = _frame(nn)
        idx = idx.sorted(key: m => {
          let w = _sub3(V.at(m), cen)
          _ang(_dot3(w, pu), _dot3(w, pv))
        })
        faces.push((idx: idx, n: nn))
      }
    }
  }
  faces
}

/// Voisinages (liste par face) et arêtes communes (dictionnaire "i,j" -> (a, b)).
#let _adjacency(faces) = {
  let F = faces.len()
  let adj = range(F).map(_ => ())
  let edges = (:)
  for i in range(F) {
    for j in range(i + 1, F) {
      let common = faces.at(i).idx.filter(m => faces.at(j).idx.contains(m))
      if common.len() == 2 {
        let li = adj.at(i)
        li.push(j)
        adj.at(i) = li
        let lj = adj.at(j)
        lj.push(i)
        adj.at(j) = lj
        edges.insert(str(i) + "," + str(j), common)
      }
    }
  }
  (adj: adj, edges: edges)
}

#let _edge-between(edges, i, j) = edges.at(str(calc.min(i, j)) + "," + str(calc.max(i, j)))

/// Arbre couvrant du graphe des faces : parent de chaque face et ordre de parcours.
#let _span-tree(adj, root, mode, rev) = {
  let F = adj.len()
  let visited = range(F).map(i => i == root)
  let parent = range(F).map(_ => none)
  let order = ()
  let work = (root,)
  while work.len() > 0 {
    let cur = if mode == "bfs" { work.remove(0) } else { work.pop() }
    order.push(cur)
    let nb = adj.at(cur)
    if rev { nb = nb.rev() }
    for g in nb {
      if not visited.at(g) {
        visited.at(g) = true
        parent.at(g) = cur
        work.push(g)
      }
    }
  }
  (parent: parent, order: order)
}

/// Charnière de chaque face non racine : (A, axe, angle signé d'ouverture).
#let _hinges(V, faces, tree, edges) = {
  let F = faces.len()
  let hs = range(F).map(_ => none)
  for f in range(F) {
    let p = tree.parent.at(f)
    if p == none { continue }
    let com = _edge-between(edges, f, p)
    let A = V.at(com.at(0))
    let ax = _unit3(_sub3(V.at(com.at(1)), A))
    let Phi = calc.acos(calc.max(-1, calc.min(1, _dot3(faces.at(f).n, faces.at(p).n)))).rad()
    let cf = _centroid(faces.at(f).idx.map(m => V.at(m)))
    let cp = _centroid(faces.at(p).idx.map(m => V.at(m)))
    let hd = _sub3(cp, A)
    hd = _sub3(hd, _mul3(_dot3(hd, ax), ax))
    let side-plus = _dot3(_sub3(_rot(cf, A, ax, Phi), A), hd)
    let side-minus = _dot3(_sub3(_rot(cf, A, ax, -Phi), A), hd)
    hs.at(f) = (A: A, ax: ax, ang: if side-plus < side-minus { Phi } else { -Phi })
  }
  hs
}

/// Applique à un point (ou à un vecteur si `vec`) les rotations de la chaîne de
/// charnières de la face f, de la face jusqu'à la racine.
#let _chain(p, f, hs, tree, t, vec: false) = {
  let q = p
  let cur = f
  while tree.parent.at(cur) != none {
    let h = hs.at(cur)
    q = if vec { _rotv(q, h.ax, t * h.ang) } else { _rot(q, h.A, h.ax, t * h.ang) }
    cur = tree.parent.at(cur)
  }
  q
}

// --- test de recouvrement du patron (polygones convexes, plan) ----------------
#let _sep-axis(P, Q) = {
  let nP = P.len()
  for i in range(nP) {
    let a = P.at(i)
    let b = P.at(calc.rem(i + 1, nP))
    let nx = -(b.at(1) - a.at(1))
    let ny = b.at(0) - a.at(0)
    let tol = 1e-6 * calc.sqrt(nx * nx + ny * ny)
    let pmin = 1e18
    let pmax = -1e18
    for p in P {
      let s = nx * p.at(0) + ny * p.at(1)
      pmin = calc.min(pmin, s)
      pmax = calc.max(pmax, s)
    }
    let qmin = 1e18
    let qmax = -1e18
    for q in Q {
      let s = nx * q.at(0) + ny * q.at(1)
      qmin = calc.min(qmin, s)
      qmax = calc.max(qmax, s)
    }
    if pmax <= qmin + tol or qmax <= pmin + tol { return true }
  }
  false
}

#let _has-overlap(polys) = {
  let n = polys.len()
  for i in range(n) {
    for j in range(i + 1, n) {
      if not (_sep-axis(polys.at(i), polys.at(j)) or _sep-axis(polys.at(j), polys.at(i))) {
        return true
      }
    }
  }
  false
}

// -----------------------------------------------------------------------------
// Dessin : faces triées + mise en page des étapes
// -----------------------------------------------------------------------------
#let _shift(pts, sh) = pts.map(p => _add3(p, sh))

#let _draw-faces(faces, k, sh, edge-stroke, cull) = {
  let visible = if cull {
    faces.filter(f => f.nout != none and _dot3(f.nout, k) > 1e-9)
  } else { faces }
  for f in visible.sorted(key: f => _dot3(f.cen, k)) {
    draw.line(.._shift(f.pts, sh), close: true, fill: f.fill, stroke: f.stroke)
    for l in f.lines {
      draw.line(.._shift(l, sh), stroke: edge-stroke)
    }
  }
}

// --- cotes -----------------------------------------------------------------
/// Segment mesuré avec une étiquette au milieu (rayon, hauteur...).
#let _seg(P, Q, body, name, marks, dash) = (
  (kind: "line", pts: (P, Q), marks: marks, dash: dash),
  (kind: "text", pos: _mid(P, Q), body: body, name: name, dir: _sub3(Q, P)),
)

/// Cote entre P et Q : traits de rappel, ligne de cote à flèches décalée de `off`
/// (none : la ligne de cote passe par P et Q) et étiquette au milieu.
#let _dim(P, Q, off, body, name) = {
  let P2 = if off == none { P } else { _add3(P, off) }
  let Q2 = if off == none { Q } else { _add3(Q, off) }
  let items = ()
  if off != none {
    items.push((kind: "line", pts: (P, P2), marks: false, dash: none, thin: true))
    items.push((kind: "line", pts: (Q, Q2), marks: false, dash: none, thin: true))
  }
  items.push((kind: "line", pts: (P2, Q2), marks: true, dash: none))
  items.push((kind: "text", pos: _mid(P2, Q2), body: body, name: name, dir: _sub3(Q2, P2), side: off))
  items
}

/// Ancre du texte : le coin ou le bord du cadre du texte le plus proche de la ligne,
/// (px, py) étant la direction écran allant de la ligne vers l'étiquette.
#let _label-anchor(px, py) = {
  let k = calc.rem(calc.round(_ang(px, py) / (calc.pi / 4)) + 8, 8)
  ("west", "south-west", "south", "south-east", "east", "north-east", "north", "north-west").at(int(k))
}

/// Étiquettes posées à côté de leur ligne, jamais dessus : du côté extérieur
/// (`side`, pour les cotes décalées) ; sinon sous la ligne, ou à droite si elle est
/// plus raide que 45° à l'écran.
#let _draw-dims(items, sh, col, x, y, z) = {
  for it in items {
    if it.kind == "line" {
      let st = (
        paint: col,
        thickness: if it.at("thin", default: false) { 0.4pt } else { 0.8pt },
        dash: it.at("dash", default: none),
      )
      if it.marks {
        draw.line(.._shift(it.pts, sh), stroke: st, mark: (start: ">", end: ">", fill: col, scale: 0.7))
      } else {
        draw.line(.._shift(it.pts, sh), stroke: st)
      }
    } else {
      let an = "north"
      let dir = it.at("dir", default: none)
      if dir != none {
        let ds = _project-pt(dir, x, y, z)
        let l = calc.sqrt(ds.at(0) * ds.at(0) + ds.at(1) * ds.at(1))
        if l > 1e-9 {
          // normale écran à la ligne
          let px = -ds.at(1) / l
          let py = ds.at(0) / l
          let side = it.at("side", default: none)
          let flip = if side != none {
            let sp = _project-pt(side, x, y, z)
            px * sp.at(0) + py * sp.at(1) < 0
          } else if calc.abs(px) > calc.abs(py) {
            px < 0
          } else {
            py > 0
          }
          if flip {
            px = -px
            py = -py
          }
          an = _label-anchor(px, py)
        }
      }
      draw.content(_add3(it.pos, sh), text(fill: col, .9em, it.body), anchor: an, padding: 0.1)
    }
  }
}

// --- étiquettes numériques des cotes (cote-labels: auto) -------------------------
/// Valeurs réelles d'un cylindre / cône de rayon R et de hauteur H : rayon,
/// hauteur, génératrice, périmètre 2πR (écrit « 2R π », valeur exacte) et angle
/// du secteur du cône (en degrés).
#let _auto-labels(R, H, digits, comma, unit) = {
  let ell = calc.sqrt(R * R + H * H)
  (
    r: _num-label(R, digits, comma, unit),
    h: _num-label(H, digits, comma, unit),
    g: _num-label(ell, digits, comma, unit),
    p: _num-label(2 * R, digits, comma, unit, suffix: "π"),
    a: _num-label(360 * R / ell, digits, comma, none, suffix: "°"),
  )
}

/// Étiquettes finales : `user` vaut auto (toutes numériques) ou un dictionnaire
/// dont les valeurs remplacent les étiquettes symboliques (auto : numérique).
#let _cote-labels(user, symbolic, autos) = {
  if user == auto { return autos }
  let l = symbolic
  for (k, v) in user {
    l.insert(k, if v == auto { autos.at(k) } else { v })
  }
  l
}

/// Dessine toutes les étapes (build-at(t) donne faces, cotes et ancres à l'instant t)
/// dans un seul canevas, avec la même échelle, alignées par lignes. La première
/// figure garde ses coordonnées d'origine (utile pour `more`) ; les ancres de
/// chaque figure sont suffixées par -1, -2, ... quand il y a plusieurs étapes.
#let _unfold-canvas(
  build-at, ts, x, y, z, k, cull-zero,
  columns, gap, labels, arrows, edge-stroke, more, length, cote-color, angle
) = {
  let scenes = ts.map(t => build-at(t))
  let boxes = scenes.map(sc => {
    let pts = ()
    for f in sc.faces { pts += f.pts }
    for it in sc.dims {
      if it.kind == "line" { pts += it.pts } else { pts.push(it.pos) }
    }
    let xs = ()
    let ys = ()
    for p in pts {
      let q = _project-pt(p, x, y, z)
      xs.push(q.at(0))
      ys.push(q.at(1))
    }
    (xmin: calc.min(..xs), xmax: calc.max(..xs), ymin: calc.min(..ys), ymax: calc.max(..ys))
  })

  let N = ts.len()
  let cols = if columns == auto { N } else { calc.min(columns, N) }
  let nr = calc.ceil(N / cols)
  let X = range(N).map(_ => 0.0)
  let row-lo = range(nr).map(_ => 1e9)
  let row-hi = range(nr).map(_ => -1e9)
  for r in range(nr) {
    let cursor = 0.0
    for c in range(cols) {
      let i = r * cols + c
      if i >= N { break }
      let b = boxes.at(i)
      X.at(i) = cursor
      cursor += b.xmax - b.xmin + gap
      row-lo.at(r) = calc.min(row-lo.at(r), b.ymin)
      row-hi.at(r) = calc.max(row-hi.at(r), b.ymax)
    }
  }
  let extra = if labels != none { 0.6 } else { 0 }
  let yref = (0.0,)
  for r in range(1, nr) {
    yref.push(row-lo.at(r - 1) + yref.at(r - 1) - gap - extra - row-hi.at(r))
  }

  // point 3D dont la projection est le point d'écran (sx, sy) : on résout avec
  // les deux axes de projection les plus indépendants
  let dxy = x.at(0) * y.at(1) - x.at(1) * y.at(0)
  let dxz = x.at(0) * z.at(1) - x.at(1) * z.at(0)
  let dyz = y.at(0) * z.at(1) - y.at(1) * z.at(0)
  let scr3(sx, sy) = {
    let m = calc.max(calc.abs(dxy), calc.abs(dxz), calc.abs(dyz))
    if calc.abs(dxy) == m {
      ((sx * y.at(1) - sy * y.at(0)) / dxy, (x.at(0) * sy - x.at(1) * sx) / dxy, 0)
    } else if calc.abs(dxz) == m {
      ((sx * z.at(1) - sy * z.at(0)) / dxz, 0, (x.at(0) * sy - x.at(1) * sx) / dxz)
    } else {
      (0, (sx * z.at(1) - sy * z.at(0)) / dyz, (y.at(0) * sy - y.at(1) * sx) / dyz)
    }
  }
  // la première figure ne bouge pas : tout est décalé de gx
  let gx = boxes.at(0).xmin

  canvas(x: x, y: y, z: z, length: length, {
    import draw: *
    rotate(y:angle)
    for (i, sc) in scenes.enumerate() {
      let r = calc.quo(i, cols)
      let b = boxes.at(i)
      let w = b.xmax - b.xmin
      let sh = scr3(X.at(i) - b.xmin + gx, yref.at(r))
      let suffix = if N == 1 { "" } else { "-" + str(i + 1) }
      _draw-faces(sc.faces, k, sh, edge-stroke, cull-zero and ts.at(i) < 1e-9)
      _draw-dims(sc.dims, sh, cote-color, x, y, z)
      for (nm, p) in sc.anchors {
        anchor(nm + suffix, _add3(p, sh))
      }
      for it in sc.dims.filter(it => it.kind == "text" and it.at("name", default: none) != none) {
        anchor(it.name + suffix, _add3(it.pos, sh))
      }
      if labels != none and i < labels.len() {
        content(scr3(X.at(i) + gx + w / 2, row-lo.at(r) + yref.at(r) - 0.15), labels.at(i), anchor: "north")
      }
      if arrows and i + 1 < N and calc.rem(i + 1, cols) != 0 {
        let ym = (row-lo.at(r) + row-hi.at(r)) / 2 + yref.at(r)
        line(
          scr3(X.at(i) + gx + w + gap * 0.18, ym), scr3(X.at(i + 1) + gx - gap * 0.18, ym),
          mark: (end: ">", fill: black), stroke: 0.8pt + black,
        )
      }
    }
    more
  })
}

/// Vue de dessus (vraie grandeur) : écran de droite r et de haut `up`, vue selon k.
#let _top-view(r, up) = (
  x: (r.at(0), up.at(0)),
  y: (r.at(1), up.at(1)),
  z: (r.at(2), up.at(2)),
)

#let _steps-of(steps, t, view) = {
  if t != none { (t,) }
  else if steps != auto { steps }
  else if view == "top" { (1,) }
  else { (0, 0.5, 1) }
}

#let _light = _unit3((0.35, 0.8, 0.5))

// Affiche un polyèdre convexe, son patron et les étapes intermédiaires de son dépliage (CeTZ).
// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat). Les étapes demandées (`steps`) sont dessinées
// côte à côte, à la même échelle. Le solide est posé sur sa face du dessous, qui reste fixe : les autres faces se
// déplient autour d'elle. Le patron est choisi parmi plusieurs arbres de dépliage (parcours en largeur et en profondeur) :
// le premier dont les faces ne se recouvrent pas est retenu. Les faces sont opaques, ombrées et triées de la plus
// lointaine à la plus proche ; le solide fermé est dessiné sans arêtes cachées.
// Ancres, suffixées -1, -2, ... s'il y a plusieurs étapes : "f0", "f1", ... (centres des faces) et "v0", "v1", ...
// (sommets, dans l'ordre de `vertices` ; un sommet est pris sur la première face de l'arbre qui le contient).
// Exemples d'utilisation :
// ```example
// #polyunfold(steps: (0, 0.4, 0.75, 1), labels: ($t = 0$, $t = 0.4$, $t = 0.75$, $t = 1$))
// ```
// Patron à plat, en vraie grandeur, d'une pyramide
// ```example
// #polyunfold(vertices: regpyramid(5, side: 2, height: 3), view: "top")
// ```
// Une couleur par face et numéros des sommets
// ```example
// #polyunfold(t: 0, length: 1.2cm,
//   palette: (red, green, blue, yellow, orange, purple).map(c => c.lighten(60%)),
//   more: {
//     import cetz.draw: *
//     for i in range(8) {
//       content("v" + str(i), text(size: 8pt, str(i)), anchor: "south-west", padding: 0.05)
//     }
//   })
// ```
// -> content
#let polyunfold(
  // Sommets du polyèdre convexe (par défaut le cube [-1, 1]³), comme pour polysection ; les fonctions
  // de solidvertices en fournissent -> array
  vertices: (
    (-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
    (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1),
  ),
  // Valeurs du paramètre de dépliage t à afficher côte à côte, de 0 (solide fermé) à 1 (patron à plat).
  // Par défaut (0, 0.5, 1), ou (1,) avec view: "top" -> auto | array
  steps: auto,
  // Une seule valeur de t (prioritaire sur steps) -> none | int | float
  t: none,
  // Indice de la face qui reste fixe ; auto : la face du dessous -> auto | int
  root: auto,
  // Direction « vers le haut », utilisée pour reconnaître la face du dessous -> array
  up: (0, 1, 0),
  // "oblique" : projection oblique x, y, z (par défaut) ; "top" : patron à plat vu de dessus, en vraie
  // grandeur, orienté comme la vue oblique -> str
  view: "oblique",
  // Nombre de figures par ligne ; auto : toutes sur une seule ligne -> auto | int
  columns: auto,
  // Espace entre les figures (unités du repère) -> int | float
  gap: 0.8,
  // Légendes placées sous les figures (une par étape) -> none | array
  labels: none,
  // Flèches entre deux figures consécutives d'une même ligne -> bool
  arrows: true,
  // Couleur des faces -> color
  fill: rgb("#a9cce3"),
  // Couleur de la face qui reste fixe (la base) -> color
  base-fill: rgb("#f5b7b1"),
  // Couleurs des faces, répétées si besoin ; remplace fill et base-fill -> none | array
  palette: none,
  // Trait des arêtes -> stroke
  edge-stroke: 0.7pt + black,
  // Image à l'écran du vecteur unitaire de l'axe x (vue oblique, comme pour polysection) ; sans effet
  // avec view: "top" -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (vue oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur (vue oblique) ->
  // array
  z: (-0.5, -0.5),
  // Commandes CeTZ supplémentaires dessinées dans le même canevas ; la première figure garde ses
  // coordonnées d'origine, les ancres existent pour toutes -> content
  more: (),
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
  // Angle de rotation du dessin en vue:"top" -> angle
  angle: 0deg,
) = {
  angle = if view == "top" {angle} else {0deg}
  let V = vertices.map(_p3)
  let faces = _convex-faces(V)
  let F = faces.len()
  let ad = _adjacency(faces)
  let upv = _unit3(_p3(up))

  // face fixe : celle dont la normale sortante est la plus tournée vers le bas
  let r0 = if root == auto {
    let best = 0
    let bs = 1e9
    for (i, f) in faces.enumerate() {
      let s = _dot3(f.n, upv)
      if s < bs - 1e-9 { best = i; bs = s }
    }
    best
  } else { root }

  // plan de la face fixe : repère (ru, rv) pour tester le recouvrement du patron
  let (ru, rv) = _frame(faces.at(r0).n)
  let flat2d(tree, hs) = range(F).map(f => faces.at(f).idx.map(m => {
    let p = _chain(V.at(m), f, hs, tree, 1)
    (_dot3(p, ru), _dot3(p, rv))
  }))

  // premier arbre sans recouvrement
  let tree = none
  let hs = none
  for (mode, rev) in (("bfs", false), ("dfs", false), ("bfs", true), ("dfs", true)) {
    let tr = _span-tree(ad.adj, r0, mode, rev)
    let h = _hinges(V, faces, tr, ad.edges)
    if tree == none { tree = tr; hs = h }
    if not _has-overlap(flat2d(tr, h)) {
      tree = tr
      hs = h
      break
    }
  }

  let build-at(tt) = {
    let fs = range(F).map(f => {
      let pts = faces.at(f).idx.map(m => _chain(V.at(m), f, hs, tree, tt))
      let nout = _chain(faces.at(f).n, f, hs, tree, tt, vec: true)
      let col = if palette != none { palette.at(calc.rem(f, palette.len())) }
        else if f == r0 { base-fill } else { fill }
      _face(pts, _shade(col, pts, _light), edge-stroke, nout: nout)
    })
    // ancres : centres des faces (f0, f1...) et sommets (v0, v1...), un sommet
    // étant pris sur la première face de l'arbre qui le contient
    let anchors = ()
    for f in range(F) { anchors.push(("f" + str(f), fs.at(f).cen)) }
    for m in range(V.len()) {
      let fo = tree.order.find(f => faces.at(f).idx.contains(m))
      anchors.push(("v" + str(m), _chain(V.at(m), fo, hs, tree, tt)))
    }
    (faces: fs, dims: (), anchors: anchors)
  }

  let n0 = faces.at(r0).n
  let e0 = _sub3(V.at(faces.at(r0).idx.at(1)), V.at(faces.at(r0).idx.at(0)))
  // Vue de dessus : même orientation que la vue oblique. L'écran de droite r est
  // l'axe du repère contenu dans le plan du patron qui apparaît le plus vers la
  // droite dans la vue oblique ; à défaut, la projection de cette direction.
  let top = if view == "top" {
    let kk = _mul3(-1, n0)
    let rowx = (x.at(0), y.at(0), z.at(0))
    let cands = ((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1))
      .filter(a => calc.abs(_dot3(a, kk)) < 1e-6 and _dot3(a, rowx) > 1e-6)
    let pr = _sub3(rowx, _mul3(_dot3(rowx, kk), kk))
    let r = if cands.len() > 0 {
      cands.sorted(key: a => -_dot3(a, rowx)).first()
    } else if _norm3(pr) > 1e-9 {
      _unit3(pr)
    } else {
      _unit3(_sub3(e0, _mul3(_dot3(e0, kk), kk)))
    }
    (.._top-view(r, _cross3(kk, r)), k: kk)
  } else { (x: x, y: y, z: z, k: _view-k(x, y, z)) }

  _unfold-canvas(
    build-at, _steps-of(steps, t, view), top.x, top.y, top.z, top.k, true,
    columns, gap, labels, arrows, edge-stroke, more, length, black, angle
  )
}

// Affiche un cylindre, son patron et les étapes intermédiaires de son dépliage (CeTZ).
// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat). Le disque de base reste fixe ; la surface
// latérale se déroule (la longueur de ses arcs est conservée) en un rectangle de longueur 2πr tangent au disque, et le
// second disque bascule avec elle. Les faces sont opaques, ombrées et triées de la plus lointaine à la plus proche.
// Avec `cotes: true`, on ajoute les cotes (r, h sur le solide fermé ; 2πr, h, r sur le patron) ; les étiquettes
// sont à l'extérieur pour les hauteurs et sous les lignes pour les autres.
// Ancres, suffixées -1, -2, ... s'il y a plusieurs étapes : "c0" (centre du disque fixe), "c1" (centre du second
// disque), "pc", "qc" (points de contact, en bas et en haut), "cote-r", "cote-h", "cote-p" (milieux des lignes de cote).
// Avec `base-ratio`, on choisit où chaque disque touche la surface latérale du patron (ratio mesuré depuis l'extrémité gauche en vue de dessus) : un nombre pour les deux disques, ou (bas, haut) pour les placer indépendamment.
// Exemples d'utilisation :
// ```example
// #cylunfold(steps: (0, 0.3, 0.6, 1))
// ```
// Cotes sur le solide fermé
// ```example
// #cylunfold(t: 0, cotes: true)
// ```
// Patron à plat avec les vraies valeurs
// ```example
// #cylunfold(view: "top", cotes: true, radius: 1.5, height: 2.5, cote-labels: auto, cote-unit: "cm")
// ```
// Disques décalés sur le patron (à 25 % et à 75 % de la longueur du rectangle)
// ```example
// #cylunfold(view: "top", cotes: true, base-ratio: (0.25, 0.75))
// ```
// -> content
#let cylunfold(
  // Rayon du cylindre -> int | float
  radius: 1,
  // Hauteur du cylindre -> int | float
  height: 2,
  // Centre du disque de base, qui reste fixe -> array
  base: (0, 0, 0),
  // Direction de l'axe, du disque de base vers l'autre disque (pas besoin qu'elle soit unitaire) ->
  // array
  axis: (0, 1, 0),
  // Direction, dans le plan de la base, du point où le solide touche son patron ; auto : le côté opposé à l'observateur, le patron se déplie alors vers le fond -> auto | array
  contact: auto,
  // Position du ou des disques le long de la surface latérale du patron : ratio entre 0 et 1 mesuré depuis
  // l'extrémité gauche du rectangle en vue de dessus (0.5 : au milieu) ; un nombre pour les deux disques, ou un
  // tableau (bas, haut) pour les placer indépendamment -> int | float | array
  base-ratio: 0.5,
  // Valeurs du paramètre de dépliage t à afficher côte à côte, de 0 (solide fermé) à 1 (patron à plat).
  // Par défaut (0, 0.5, 1), ou (1,) avec view: "top" -> auto | array
  steps: auto,
  // Une seule valeur de t (prioritaire sur steps) -> none | int | float
  t: none,
  // "oblique" : projection oblique x, y, z (par défaut) ; "top" : patron à plat vu de dessus, en vraie
  // grandeur, orienté comme la vue oblique -> str
  view: "oblique",
  // Nombre de figures par ligne ; auto : toutes sur une seule ligne -> auto | int
  columns: auto,
  // Espace entre les figures (unités du repère) -> int | float
  gap: 0.8,
  // Légendes placées sous les figures (une par étape) -> none | array
  labels: none,
  // Flèches entre deux figures consécutives d'une même ligne -> bool
  arrows: true,
  // Couleur des faces -> color
  fill: rgb("#a9cce3"),
  // Couleur du disque fixe -> color
  base-fill: rgb("#f5b7b1"),
  // Couleur du second disque -> color
  top-fill: rgb("#f9e79f"),
  // Finesse du maillage de la surface latérale (nombre de facettes par tour) -> int
  segments: 60,
  // Ajoute les cotes : r et h sur le solide fermé (t = 0, vue oblique) ; 2πr, h et r sur le patron
  // (view: "top") -> bool
  cotes: false,
  // Étiquettes des cotes : dictionnaire (r:, h:, g:, p:, a:) dont les valeurs remplacent les étiquettes
  // symboliques (la valeur auto donne la vraie valeur), ou auto pour tout remplacer ->
  // auto | dictionary
  cote-labels: (:),
  // Couleur des cotes -> color
  cote-color: rgb("#7b241c"),
  // Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  cote-unit: none,
  // Nombre de décimales en mode auto -> int
  cote-digits: 2,
  // Séparateur décimal en mode auto : "," ou "." -> str
  cote-decimal: ",",
  // Trait des arêtes -> stroke
  edge-stroke: 0.7pt + black,
  // Image à l'écran du vecteur unitaire de l'axe x (vue oblique, comme pour polysection) ; sans effet
  // avec view: "top" -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (vue oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur (vue oblique) ->
  // array
  z: (-0.5, -0.5),
  // Commandes CeTZ supplémentaires dessinées dans le même canevas ; la première figure garde ses
  // coordonnées d'origine, les ancres existent pour toutes -> content
  more: (),
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
  // Angle de rotation du dessin en vue:"top" -> angle
  angle: 0deg,
) = {
  angle = if view == "top" {angle} else {0deg}
  let R = radius
  let H = height
  let e = _unit3(_p3(axis))
  let C0 = _p3(base)
  let kv = if view == "top" { e } else { _view-k(x, y, z) }
  // direction de contact : dans le plan de la base
  let c0 = if contact == auto { _mul3(-1, kv) } else { _p3(contact) }
  let c1 = _sub3(c0, _mul3(_dot3(c0, e), e))
  let uc = if _norm3(c1) > 1e-9 { _unit3(c1) } else { _frame(e).at(0) }
  let v = _cross3(e, uc)

  // position des disques le long de la surface latérale (ratios mesurés depuis l'extrémité gauche du
  // patron en vue de dessus) : le disque de base touche la surface en sg = 0, les extrémités de la
  // surface sont en sg-lo et sg-hi, et le disque supérieur touche son bord haut en sg-t
  let (rb, rt) = if type(base-ratio) == array {
    (base-ratio.at(0), base-ratio.at(1, default: base-ratio.at(0)))
  } else { (base-ratio, base-ratio) }
  assert(0 <= rb and rb <= 1 and 0 <= rt and rt <= 1, message: "base-ratio : des valeurs entre 0 et 1 sont attendues")
  let L = 2 * calc.pi * R
  let sg-lo = -(1 - rb) * L
  let sg-hi = rb * L
  let sg-t = (rb - rt) * L

  let lab = _cote-labels(
    cote-labels, (r: $r$, h: $h$, p: $2 pi r$),
    _auto-labels(R, H, cote-digits, cote-decimal == ",", cote-unit),
  )

  let build-at(tt) = {
    let psi = calc.pi / 2 * tt
    let d = _lc((0, 0, 0), ((calc.cos(psi), uc), (-calc.sin(psi), e)))
    let w = _lc((0, 0, 0), ((calc.sin(psi), uc), (calc.cos(psi), e)))
    let Pc = _lc(C0, ((R, uc),))
    let kap = (1 - tt) / R
    // arc de la base de la surface latérale, abscisse curviligne sg depuis le contact
    let arc(sg) = if kap < 1e-9 { _lc(Pc, ((sg, v),)) } else {
      let al = kap * sg
      _lc(Pc, ((calc.sin(al) / kap, v), (-(1 - calc.cos(al)) / kap, d)))
    }
    let nq = segments
    let Bs = range(nq + 1).map(i => arc(sg-lo + L * i / nq))
    let Ts = Bs.map(b => _lc(b, ((H, w),)))
    let out = ()
    for i in range(nq) {
      let quad = (Bs.at(i), Bs.at(i + 1), Ts.at(i + 1), Ts.at(i))
      let ln = ((Bs.at(i), Bs.at(i + 1)), (Ts.at(i), Ts.at(i + 1)))
      if i == 0 { ln += ((Bs.at(0), Ts.at(0)),) }
      if i == nq - 1 { ln += ((Bs.at(nq), Ts.at(nq)),) }
      let col = _shade(fill, quad, _light)
      out.push(_face(quad, col, 0.5pt + col, lines: ln))
    }
    // disque de base (fixe)
    let bd = _circ-pts(C0, R, uc, v, segments)
    out.push(_face(bd, _shade(base-fill, bd, _light), edge-stroke))
    // disque supérieur : charnière tangente au bord supérieur, au point de contact d'abscisse sg-t
    let al-t = kap * sg-t
    let Tt = _lc((0, 0, 0), ((calc.cos(al-t), v), (-calc.sin(al-t), d)))   // tangente au bord
    let Nt = _lc((0, 0, 0), ((calc.cos(al-t), d), (calc.sin(al-t), v)))    // normale sortante
    let Qc = _lc(arc(sg-t), ((H, w),))
    let dl = calc.pi / 2 + calc.pi / 2 * tt
    let a = _lc((0, 0, 0), ((-calc.cos(dl), w), (-calc.sin(dl), Nt)))
    let C1t = _lc(Qc, ((R, a),))   // centre du disque supérieur
    let td = _circ-pts(C1t, R, Tt, a, segments)
    out.push(_face(td, _shade(top-fill, td, _light), edge-stroke))

    let anchors = (("c0", C0), ("c1", C1t), ("pc", Pc), ("qc", Qc))

    // cotes : solide fermé (vue oblique) ou patron (vue de dessus)
    let dims = ()
    if cotes and ((view != "top" and tt < 1e-9) or (view == "top" and tt > 1 - 1e-9)) {
      let off = 0.25 * R + 0.25
      if view == "top" {
        let B0 = _lc(Pc, ((sg-lo, v),))
        let B1 = _lc(Pc, ((sg-hi, v),))
        dims += _dim(_lc(B0, ((H / 2, uc),)), _lc(B1, ((H / 2, uc),)), none, lab.p, "cote-p")
        dims += _dim(B1, _lc(B1, ((H, uc),)), _mul3(off, v), lab.h, "cote-h")
        dims += _seg(C0, _lc(C0, ((-R, v),)), lab.r, "cote-r", false, none)
        dims += _seg(C1t, _lc(C1t, ((-R, v),)), lab.r, "cote-r2", false, none)
      } else {
        // génératrice de contour apparent la plus à droite
        let rowx = (x.at(0), y.at(0), z.at(0))
        let ph = _ang(_dot3(uc, kv), _dot3(v, kv))
        let nr = (ph + calc.pi / 2, ph - calc.pi / 2)
          .map(th => _lc((0, 0, 0), ((calc.cos(th), uc), (calc.sin(th), v))))
          .sorted(key: n => -_dot3(n, rowx)).first()
        let Cf = if _dot3(e, kv) > 0 { C1t } else { C0 }
        dims += _dim(_lc(C0, ((R, nr),)), _lc(C1t, ((R, nr),)), _mul3(off, nr), lab.h, "cote-h")
        dims += _seg(Cf, _lc(Cf, ((R, nr),)), lab.r, "cote-r", false, none)
      }
    }
    (faces: out, dims: dims, anchors: anchors)
  }

  let top = if view == "top" {
    (.._top-view(_mul3(-1, v), uc), k: e)
  } else { (x: x, y: y, z: z, k: kv) }

  _unfold-canvas(
    build-at, _steps-of(steps, t, view), top.x, top.y, top.z, top.k, false,
    columns, gap, labels, arrows, edge-stroke, more, length, cote-color, angle
  )
}

// Affiche un cône, son patron et les étapes intermédiaires de son dépliage (CeTZ).
// Le paramètre d'avancement t va de 0 (solide fermé) à 1 (patron à plat). Le disque de base reste fixe ; la surface
// latérale se déroule en un secteur circulaire de rayon égal à la génératrice, tangent au disque. Les faces sont
// opaques, ombrées et triées de la plus lointaine à la plus proche.
// Avec `cotes: true`, on ajoute les cotes (r, h, g sur le solide fermé ; g, 2πr, angle du secteur et r sur le
// patron) ; les étiquettes sont à l'extérieur pour les génératrices et sous les lignes pour les autres.
// Ancres, suffixées -1, -2, ... s'il y a plusieurs étapes : "c0" (centre de la base), "s" (sommet), "pc" (point de
// contact), "cote-r", "cote-h", "cote-g", "cote-p", "cote-a" (milieux des lignes de cote).
// Avec `base-ratio`, on choisit où le disque de base touche l'arc du secteur (ratio mesuré depuis l'extrémité gauche de l'arc en vue de dessus).
// Exemples d'utilisation :
// ```example
// #coneunfold(steps: (0, 0.3, 0.6, 1))
// ```
// Cotes sur le solide fermé, avec les vraies valeurs
// ```example
// #coneunfold(t: 0, cotes: true, radius: 1.5, height: 2.5, cote-labels: auto, cote-unit: "cm")
// ```
// Patron à plat : génératrice, longueur 2πr de l'arc et angle du secteur
// ```example
// #coneunfold(view: "top", cotes: true, radius: 3, height: 4, cote-labels: auto, cote-unit: "cm", length: 0.6cm)
// ```
// Disque de base placé à 20 % de l'arc, depuis la gauche
// ```example
// #coneunfold(view: "top", cotes: true, base-ratio: 0.2)
// ```
// -> content
#let coneunfold(
  // Rayon du cône -> int | float
  radius: 1,
  // Hauteur du cône -> int | float
  height: 2,
  // Centre de la base, qui reste fixe -> array
  base: (0, 0, 0),
  // Direction de l'axe, de la base vers le sommet (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Direction, dans le plan de la base, du point où le solide touche son patron ; auto : le côté opposé
  // à l'observateur, le patron se déplie alors vers le fond -> auto | array
  contact: auto,
  // Position du disque de base le long de l'arc du secteur : ratio entre 0 et 1 mesuré depuis l'extrémité
  // gauche de l'arc en vue de dessus (0.5 : au milieu) -> int | float
  base-ratio: 0.5,
  // Valeurs du paramètre de dépliage t à afficher côte à côte, de 0 (solide fermé) à 1 (patron à plat).
  // Par défaut (0, 0.5, 1), ou (1,) avec view: "top" -> auto | array
  steps: auto,
  // Une seule valeur de t (prioritaire sur steps) -> none | int | float
  t: none,
  // "oblique" : projection oblique x, y, z (par défaut) ; "top" : patron à plat vu de dessus, en vraie
  // grandeur, orienté comme la vue oblique -> str
  view: "oblique",
  // Nombre de figures par ligne ; auto : toutes sur une seule ligne -> auto | int
  columns: auto,
  // Espace entre les figures (unités du repère) -> int | float
  gap: 0.8,
  // Légendes placées sous les figures (une par étape) -> none | array
  labels: none,
  // Flèches entre deux figures consécutives d'une même ligne -> bool
  arrows: true,
  // Couleur des faces -> color
  fill: rgb("#a9cce3"),
  // Couleur de la base -> color
  base-fill: rgb("#f5b7b1"),
  // Finesse du maillage de la surface latérale (nombre de facettes par tour) -> int
  segments: 60,
  // Ajoute les cotes : r, h et g sur le solide fermé (t = 0, vue oblique) ; g, 2πr, angle du secteur
  // (clé a) et r sur le patron (view: "top") -> bool
  cotes: false,
  // Étiquettes des cotes : dictionnaire (r:, h:, g:, p:, a:) dont les valeurs remplacent les étiquettes
  // symboliques (la valeur auto donne la vraie valeur), ou auto pour tout remplacer ->
  // auto | dictionary
  cote-labels: (:),
  // Couleur des cotes -> color
  cote-color: rgb("#7b241c"),
  // Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  cote-unit: none,
  // Nombre de décimales en mode auto -> int
  cote-digits: 2,
  // Séparateur décimal en mode auto : "," ou "." -> str
  cote-decimal: ",",
  // Trait des arêtes -> stroke
  edge-stroke: 0.7pt + black,
  // Image à l'écran du vecteur unitaire de l'axe x (vue oblique, comme pour polysection) ; sans effet
  // avec view: "top" -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (vue oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur (vue oblique) ->
  // array
  z: (-0.5, -0.5),
  // Commandes CeTZ supplémentaires dessinées dans le même canevas ; la première figure garde ses
  // coordonnées d'origine, les ancres existent pour toutes -> content
  more: (),
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
  // Angle de rotation du dessin en vue:"top" -> angle
  angle: 0deg,
) = {
  angle = if view == "top" {angle} else {0deg}
  let R = radius
  let H = height
  let e = _unit3(_p3(axis))
  let C0 = _p3(base)
  let kv = if view == "top" { e } else { _view-k(x, y, z) }
  let c0 = if contact == auto { _mul3(-1, kv) } else { _p3(contact) }
  let c1 = _sub3(c0, _mul3(_dot3(c0, e), e))
  let uc = if _norm3(c1) > 1e-9 { _unit3(c1) } else { _frame(e).at(0) }
  let v = _cross3(e, uc)
  assert(0 <= base-ratio and base-ratio <= 1, message: "base-ratio : une valeur entre 0 et 1 est attendue")

  let ell = calc.sqrt(R * R + H * H)           // longueur d'une génératrice
  let al0 = calc.atan(R / H).rad()              // demi-angle au sommet
  let om0 = _ang(-R, H)                         // inclinaison initiale de la génératrice de contact

  let lab = _cote-labels(
    cote-labels, (r: $r$, h: $h$, g: $g$, p: $2 pi r$, a: $alpha$),
    _auto-labels(R, H, cote-digits, cote-decimal == ",", cote-unit),
  )

  let build-at(tt) = {
    let om = om0 * (1 - tt)
    let alp = al0 + tt * (calc.pi / 2 - al0)    // demi-angle de la surface partiellement déroulée
    let Pc = _lc(C0, ((R, uc),))
    let gp = _lc((0, 0, 0), ((calc.cos(om), uc), (calc.sin(om), e)))   // de Pc vers le sommet
    let A = _lc(Pc, ((ell, gp),))
    let aa = _lc((0, 0, 0), ((calc.cos(om + calc.pi - alp), uc), (calc.sin(om + calc.pi - alp), e)))
    let n1 = _mul3(1 / calc.sin(alp), _sub3(_mul3(-1, gp), _mul3(calc.cos(alp), aa)))
    let phm = calc.pi * calc.sin(al0) / calc.sin(alp)
    // extrémités du secteur, en azimut : le contact est à φ = 0, à base-ratio depuis l'extrémité gauche
    let ph-lo = -2 * phm * (1 - base-ratio)
    let ph-hi = 2 * phm * base-ratio
    let nq = segments
    let Es = range(nq + 1).map(i => {
      let ph = ph-lo + (ph-hi - ph-lo) * i / nq
      let dir = _lc((0, 0, 0), ((calc.cos(alp), aa), (calc.sin(alp) * calc.cos(ph), n1), (calc.sin(alp) * calc.sin(ph), v)))
      _lc(A, ((ell, dir),))
    })
    let out = ()
    for i in range(nq) {
      let tri = (A, Es.at(i), Es.at(i + 1))
      let ln = ((Es.at(i), Es.at(i + 1)),)
      if i == 0 { ln += ((A, Es.at(0)),) }
      if i == nq - 1 { ln += ((A, Es.at(nq)),) }
      let col = _shade(fill, tri, _light)
      out.push(_face(tri, col, 0.5pt + col, lines: ln))
    }
    let bd = _circ-pts(C0, R, uc, v, segments)
    out.push(_face(bd, _shade(base-fill, bd, _light), edge-stroke))

    let anchors = (("c0", C0), ("s", A), ("pc", Pc))

    // cotes : solide fermé (vue oblique) ou patron (vue de dessus)
    let dims = ()
    if cotes and ((view != "top" and tt < 1e-9) or (view == "top" and tt > 1 - 1e-9)) {
      let off = 0.25 * R + 0.25
      if view == "top" {
        // génératrice : bord du secteur, cote décalée vers l'extérieur
        let dirE(ph) = _lc((0, 0, 0), (
          (calc.cos(alp), aa), (calc.sin(alp) * calc.cos(ph), n1), (calc.sin(alp) * calc.sin(ph), v),
        ))
        let Eend = _lc(A, ((ell, dirE(ph-hi)),))
        let tdir = _unit3(_lc((0, 0, 0), (
          (-calc.sin(alp) * calc.sin(ph-hi), n1), (calc.sin(alp) * calc.cos(ph-hi), v),
        )))
        dims += _dim(A, Eend, _mul3(off, tdir), lab.g, "cote-g")
        // longueur de l'arc 2πr : arc de cote à l'intérieur du secteur
        let rho = 0.8 * ell
        let arcp = range(41).map(i => {
          let ph = ph-lo + (ph-hi - ph-lo) * i / 40
          _lc(A, ((rho * calc.cos(alp), aa), (rho * calc.sin(alp) * calc.cos(ph), n1), (rho * calc.sin(alp) * calc.sin(ph), v)))
        })
        dims.push((kind: "line", pts: arcp, marks: true, dash: none))
        dims.push((kind: "text", pos: arcp.at(20), body: lab.p, name: "cote-p", dir: _sub3(arcp.at(21), arcp.at(19)), side: _sub3(A, arcp.at(20))))
        // angle du secteur (au sommet) : arc de cote de petit rayon
        let rho-a = 0.3 * ell
        let arca = range(41).map(i => {
          let ph = ph-lo + (ph-hi - ph-lo) * i / 40
          _lc(A, ((rho-a * calc.cos(alp), aa), (rho-a * calc.sin(alp) * calc.cos(ph), n1), (rho-a * calc.sin(alp) * calc.sin(ph), v)))
        })
        dims.push((kind: "line", pts: arca, marks: true, dash: none))
        dims.push((kind: "text", pos: arca.at(20), body: lab.a, name: "cote-a", dir: _sub3(arca.at(21), arca.at(19))))
        dims += _seg(C0, _lc(C0, ((-R, v),)), lab.r, "cote-r", false, none)
      } else {
        // génératrice de contour apparent la plus à droite
        let rowx = (x.at(0), y.at(0), z.at(0))
        let ek = _dot3(e, kv)
        let ku = _dot3(uc, kv)
        let kw = _dot3(v, kv)
        let kap = calc.sqrt(ku * ku + kw * kw)
        let roots = if kap > 1e-9 { _cos-roots(-R * ek / (H * kap), _ang(ku, kw)) } else { () }
        let cands = if roots.len() > 0 { roots } else { (_ang(_dot3(uc, rowx), _dot3(v, rowx)),) }
        let nr = cands
          .map(th => _lc((0, 0, 0), ((calc.cos(th), uc), (calc.sin(th), v))))
          .sorted(key: n => -_dot3(n, rowx)).first()
        let rim = _lc(C0, ((R, nr),))
        dims += _seg(A, C0, lab.h, "cote-h", false, "dashed")
        dims += _seg(C0, rim, lab.r, "cote-r", false, if ek < -1e-9 { none } else { "dashed" })
        dims += _dim(A, rim, _mul3(off, nr), lab.g, "cote-g")
      }
    }
    (faces: out, dims: dims, anchors: anchors)
  }

  let top = if view == "top" {
    (.._top-view(_mul3(-1, v), uc), k: e)
  } else { (x: x, y: y, z: z, k: kv) }

  _unfold-canvas(
    build-at, _steps-of(steps, t, view), top.x, top.y, top.z, top.k, false,
    columns, gap, labels, arrows, edge-stroke, more, length, cote-color, angle
  )
}
