#import "@preview/cetz:0.5.2" as cetz: canvas, draw

// =============================================================================
// solidsection.typ
// Section plane d'un cylindre, d'un cône, d'un double cône (sablier) ou d'une
// sphère (CeTZ 0.5.2)
//
//   cylsection(..plan, radius:, height:, base:, axis:, ...)
//   conesection(..plan, radius:, height:, base:, axis:, ...)
//   doubleconesection(..plan, radius:, height:, apex:, axis:, ...)
//   spheresection(..plan, radius:, center:, ...)
//   globe(..plan, radius:, points:, ...)      coordonnées terrestres (voir plus bas)
//   globe-view(lon:, lat:)                    vue orthographique pour `globe`
//
// Le plan se donne comme dans `polysection` :
//   - 3 points            : (A), (B), (C)
//   - 4 coefficients      : a, b, c, d   (plan  a·x + b·y + c·z + d = 0)
//   - ou un seul argument : dictionnaire (a:, b:, c:, d:), tableau de 4 nombres
//                           ou tableau de 3 points
//
// Options communes d'annotation :
//   show-radius: true         trace un rayon (avec l'étiquette `radius-label`)
//   show-centers: true        marque les centres (bases, sphère, centre de la
//                             section quand il est évident)
//   show-apex: true           (cônes) marque le sommet
//   show-foci: true           (cylindre, cônes) marque les foyers de la section
//                             quand ils existent (ancres "f0", "f1")
//   point-labels: (c0: $O$, s: $S$, ...)   étiquettes placées sur les ancres
//
// Convention de visibilité identique à `polysection` : la direction de
// projection est le noyau de (x, y, z), orientée vers l'observateur (z > 0).
// =============================================================================

#let _tau = 2 * calc.pi

// -----------------------------------------------------------------------------
// Outils vectoriels 3D
// -----------------------------------------------------------------------------
#let _p3(p) = (p.at(0), p.at(1), p.at(2, default: 0))
#let _sub3(u, v) = (u.at(0) - v.at(0), u.at(1) - v.at(1), u.at(2) - v.at(2))
#let _dot3(u, v) = u.at(0) * v.at(0) + u.at(1) * v.at(1) + u.at(2) * v.at(2)
#let _cross3(u, v) = (
  u.at(1) * v.at(2) - u.at(2) * v.at(1),
  u.at(2) * v.at(0) - u.at(0) * v.at(2),
  u.at(0) * v.at(1) - u.at(1) * v.at(0),
)
#let _norm3(v) = calc.sqrt(_dot3(v, v))
#let _mul3(k, u) = (k * u.at(0), k * u.at(1), k * u.at(2))
#let _unit3(u) = _mul3(1 / _norm3(u), u)

/// c + somme des coef * vecteur, pour terms = ((coef, vecteur), ...)
#let _lc(c, terms) = {
  let r = (c.at(0), c.at(1), c.at(2))
  for (k, w) in terms {
    r = (r.at(0) + k * w.at(0), r.at(1) + k * w.at(1), r.at(2) + k * w.at(2))
  }
  r
}

#let _mid(a, b) = _lc(a, ((0.5, _sub3(b, a)),))

/// Angle (en radians) du vecteur (a, b), mesuré depuis l'axe des a.
#let _ang(a, b) = calc.atan2(a, b).rad()

#let _project-pt(pt, x, y, z) = (
  pt.at(0) * x.at(0) + pt.at(1) * y.at(0) + pt.at(2, default: 0) * z.at(0),
  pt.at(0) * x.at(1) + pt.at(1) * y.at(1) + pt.at(2, default: 0) * z.at(1),
)

/// Base orthonormée (u, v) du plan perpendiculaire au vecteur unitaire e,
/// avec (u, v, e) directe.
#let _frame(e) = {
  let t = if calc.abs(e.at(0)) < 0.9 { (1, 0, 0) } else { (0, 1, 0) }
  let u = _unit3(_cross3(e, t))
  let v = _cross3(e, u)
  (u, v)
}

/// Direction de projection unitaire, orientée vers l'observateur (z > 0),
/// c'est-à-dire la même convention que `polysection`.
#let _view-k(x, y, z) = {
  let r1 = (x.at(0), y.at(0), z.at(0))
  let r2 = (x.at(1), y.at(1), z.at(1))
  let v = _cross3(r1, r2)
  if v.at(2) < 0 { v = _mul3(-1, v) }
  _unit3(v)
}

/// Point du cercle (centre C, rayon R, base (u, v)) le plus à droite à l'écran :
/// le rayon [C, P] est ainsi le plus « horizontal » possible dans le dessin.
#let _radius-pt(C, R, u, v, x, y, z) = {
  let rx = (x.at(0), y.at(0), z.at(0))
  let th = _ang(_dot3(u, rx), _dot3(v, rx))
  _lc(C, ((R * calc.cos(th), u), (R * calc.sin(th), v)))
}

// -----------------------------------------------------------------------------
// Lecture du plan
// -----------------------------------------------------------------------------
#let _parse-plane(pos) = {
  let a = pos
  if pos.len() == 1 {
    let arg = pos.at(0)
    a = if type(arg) == dictionary { (arg.a, arg.b, arg.c, arg.d) } else { arg }
  }
  if a.len() == 3 {
    let A = _p3(a.at(0))
    let B = _p3(a.at(1))
    let C = _p3(a.at(2))
    let nn = _cross3(_sub3(B, A), _sub3(C, A))
    assert(_norm3(nn) > 1e-12, message: "Les 3 points définissant le plan ne doivent pas être alignés.")
    let n = _unit3(nn)
    (n: n, d: -_dot3(n, A))
  } else if a.len() == 4 {
    let nn = (a.at(0), a.at(1), a.at(2))
    let l = _norm3(nn)
    assert(l > 1e-12, message: "Équation de plan invalide : a, b, c ne peuvent pas être tous nuls.")
    (n: _unit3(nn), d: a.at(3) / l)
  } else {
    panic("Format d'arguments de plan invalide.")
  }
}

/// Les trois points qui définissent le plan (ou none si le plan est donné par une équation).
#let _plane-points(pos) = {
  let a = if pos.len() == 1 and type(pos.at(0)) == array { pos.at(0) } else { pos }
  if a.len() == 3 and type(a.at(0)) == array { a.map(_p3) } else { none }
}

// -----------------------------------------------------------------------------
// Découpage exact des courbes paramétrées par un angle en arcs visibles / cachés
// -----------------------------------------------------------------------------
#let _na(t) = t - _tau * calc.floor(t / _tau)

/// Angles th tels que cos(th - psi) = c.
#let _cos-roots(c, psi) = {
  if c > 1 - 1e-12 or c < -1 + 1e-12 { () } else {
    let a = calc.acos(c).rad()
    (psi + a, psi - a)
  }
}

/// Découpe le cercle aux angles `breaks` et garde les arcs où `f-in` est vrai
/// (testé au milieu de l'arc) ; chaque arc reçoit son état `vis` (`f-vis`).
#let _split-arcs(breaks, f-in, f-vis) = {
  let bs = breaks.map(_na).sorted()
  let u = ()
  for b in bs {
    if u.len() == 0 or b - u.last() > 1e-9 { u.push(b) }
  }
  if u.len() == 0 { u = (0.0,) }
  let res = ()
  let n = u.len()
  for i in range(n) {
    let lo = u.at(i)
    let hi = if i + 1 < n { u.at(i + 1) } else { u.at(0) + _tau }
    if hi - lo < 1e-9 { continue }
    let m = (lo + hi) / 2
    if f-in(m) { res.push((a: lo, b: hi, vis: f-vis(m))) }
  }
  res
}

/// Fusionne les arcs consécutifs de même visibilité (évite les ruptures de pointillés).
#let _merge-arcs(arcs) = {
  let out = ()
  for ar in arcs {
    if out.len() > 0 and out.last().vis == ar.vis and calc.abs(out.last().b - ar.a) < 1e-9 {
      let l = out.pop()
      out.push((a: l.a, b: ar.b, vis: ar.vis))
    } else {
      out.push(ar)
    }
  }
  if out.len() >= 2 {
    let f = out.first()
    let l = out.last()
    if f.vis == l.vis and calc.abs(l.b - (f.a + _tau)) < 1e-9 {
      let _ = out.remove(0)
      let _ = out.pop()
      out.push((a: l.a, b: f.b + _tau, vis: f.vis))
    }
  }
  out
}

#let _arc-pts(f, lo, hi, per-turn) = {
  let m = calc.max(2, calc.ceil(calc.abs(hi - lo) / _tau * per-turn))
  range(m + 1).map(i => f(lo + (hi - lo) * i / m))
}

/// Corde du disque (centre C, rayon R, base (u, v)) coupé par le plan (n, d).
#let _disk-chord(C, R, u, v, n, d) = {
  let nu = _dot3(n, u)
  let nv = _dot3(n, v)
  let hyp = calc.sqrt(nu * nu + nv * nv)
  if hyp < 1e-9 { return none }
  let sc = _dot3(n, C) + d
  let m = -sc / (R * hyp)
  if calc.abs(m) >= 1 - 1e-9 { return none }
  let wa = nu / hyp
  let wb = nv / hyp
  let h = calc.sqrt(1 - m * m)
  let pt(sgn) = _lc(C, ((R * (m * wa - sgn * h * wb), u), (R * (m * wb + sgn * h * wa), v)))
  (pt(1), pt(-1))
}

/// Trie les points d'une section convexe autour de leur centre (dans le plan de normale n).
#let _sort-poly(pts, n) = {
  if pts.len() < 3 { return pts }
  let (pu, pv) = _frame(n)
  let cnt = pts.len()
  let c = (
    pts.map(p => p.at(0)).sum() / cnt,
    pts.map(p => p.at(1)).sum() / cnt,
    pts.map(p => p.at(2)).sum() / cnt,
  )
  pts.sorted(key: p => {
    let w = _sub3(p, c)
    _ang(_dot3(w, pu), _dot3(w, pv))
  })
}

/// Version « cachée » (pointillée) d'un trait : accepte un trait, un dictionnaire ou une couleur.
#let _hidden-of(st, style) = {
  if type(st) == dictionary { st + (dash: style) }
  else if type(st) == color { (paint: st, thickness: 1pt, dash: style) }
  else { (paint: st.paint, thickness: st.thickness, dash: style) }
}

/// Trait du rayon : plein s'il est visible, pointillé sinon.
#let _radius-stroke(st, vis, hidden-style) = if vis { st } else { _hidden-of(st, hidden-style) }

/// Ancre de l'étiquette d'un point P : on s'éloigne du point c, dans l'écran.
#let _away(P, c, x, y, z) = {
  let pp = _project-pt(P, x, y, z)
  let pc = _project-pt(c, x, y, z)
  let dx = pp.at(0) - pc.at(0)
  let dy = pp.at(1) - pc.at(1)
  if calc.abs(dx) < 1e-6 and calc.abs(dy) < 1e-6 { "south-east" }
  else if dx >= 0 and dy >= 0 { "south-west" }
  else if dx >= 0 { "north-west" }
  else if dy >= 0 { "south-east" }
  else { "north-east" }
}

// -----------------------------------------------------------------------------
// Découpage d'un intervalle de paramètre en morceaux visibles / cachés
// -----------------------------------------------------------------------------
/// `cuts` : valeurs triées, extrémités comprises ; l'état est testé au milieu.
#let _pieces(cuts, f-vis) = {
  let res = ()
  for i in range(cuts.len() - 1) {
    let p = cuts.at(i)
    let q = cuts.at(i + 1)
    if q - p < 1e-9 { continue }
    let vis = f-vis((p + q) / 2)
    if res.len() > 0 and res.last().vis == vis {
      let l = res.pop()
      res.push((a: l.a, b: q, vis: vis))
    } else {
      res.push((a: p, b: q, vis: vis))
    }
  }
  res
}

/// Paramètre linéaire (abscisse sur une droite) : coupures `br` quelconques.
#let _split-lin(lo, hi, br, f-vis) = {
  let a = calc.min(lo, hi)
  let b = calc.max(lo, hi)
  _pieces((a,) + br.filter(t => t > a + 1e-9 and t < b - 1e-9).sorted() + (b,), f-vis)
}

/// Paramètre angulaire sur [lo, hi] : les coupures `br` sont définies modulo 2π.
#let _split-range(lo, hi, br, f-vis) = {
  let a = calc.min(lo, hi)
  let b = calc.max(lo, hi)
  let cuts = ()
  for r in br {
    let t = a + _na(r - a)
    while t < b - 1e-9 {
      if t > a + 1e-9 { cuts.push(t) }
      t += _tau
    }
  }
  _pieces((a,) + cuts.sorted() + (b,), f-vis)
}

/// Courbe tracée sur la sphère (centre O) : P(t) = C + cos t · A + sin t · B,
/// pour t dans [lo, hi] ; renvoie des éléments (pts, vis, stroke) prêts à tracer.
#let _sphere-curve(O, C, A, B, k, lo, hi, st, hs, per-turn) = {
  let f(t) = _lc(C, ((calc.cos(t), A), (calc.sin(t), B)))
  let c0 = _dot3(_sub3(C, O), k)
  let a = _dot3(A, k)
  let b = _dot3(B, k)
  let rho = calc.sqrt(a * a + b * b)
  let br = if rho > 1e-12 { _cos-roots(-c0 / rho, _ang(a, b)) } else { () }
  let vis(t) = _dot3(_sub3(f(t), O), k) > 1e-9
  let arcs = if hi - lo >= _tau - 1e-9 {
    _merge-arcs(_split-arcs(br, t => true, vis))
  } else {
    _split-range(lo, hi, br, vis)
  }
  arcs.map(ar => (
    pts: _arc-pts(f, ar.a, ar.b, per-turn),
    vis: ar.vis,
    stroke: if ar.vis { st } else { _hidden-of(st, hs) },
  ))
}

/// Section d'une sphère (centre O, rayon R) par le plan (n, d).
#let _sphere-section(O, R, n, d, k, eps, per-turn) = {
  let hh = _dot3(n, O) + d
  if calc.abs(hh) >= R - eps { return (sec: (), poly: (), sc: none, rc: 0) }
  let rc = calc.sqrt(R * R - hh * hh)
  let Cc = _lc(O, ((-hh, n),))
  let (pu, pv) = _frame(n)
  let circ(th) = _lc(Cc, ((rc * calc.cos(th), pu), (rc * calc.sin(th), pv)))
  let vis(th) = _dot3(_sub3(circ(th), O), k) > 1e-9
  let pa = _dot3(pu, k)
  let pb = _dot3(pv, k)
  let pkap = calc.sqrt(pa * pa + pb * pb)
  let br = if pkap > 1e-9 { _cos-roots(hh * _dot3(n, k) / (rc * pkap), _ang(pa, pb)) } else { () }
  let sec = ()
  let poly = ()
  for ar in _merge-arcs(_split-arcs(br, th => true, vis)) {
    let pts = _arc-pts(circ, ar.a, ar.b, per-turn)
    sec.push((pts: pts, vis: ar.vis))
    poly += pts
  }
  (sec: sec, poly: _sort-poly(poly, n), sc: Cc, rc: rc)
}

// -----------------------------------------------------------------------------
// Foyers des sections coniques (sphères de Dandelin)
//   Les sphères inscrites dans le solide et tangentes au plan touchent le plan
//   aux foyers. `inside` filtre les foyers qui tombent dans le solide fini.
// -----------------------------------------------------------------------------
#let _dedupe-pts(ps) = {
  let out = ()
  for p in ps {
    if not out.any(q => _norm3(_sub3(p, q)) < 1e-7) { out.push(p) }
  }
  out
}

/// Cône (ou double cône) de sommet S, d'axe unitaire a, de rayon R et de hauteur H.
#let _foci-cone(S, a, R, H, n, d, inside) = {
  let nS = _dot3(n, S) + d
  let ne = _dot3(n, a)
  if calc.abs(nS) < 1e-7 * (1 + H + R) or calc.abs(calc.abs(ne) - 1) < 1e-9 { return () }
  let sa = R / calc.sqrt(R * R + H * H)
  let fs = ()
  for sg in (1, -1) {
    let den = sg * sa - ne
    if calc.abs(den) > 1e-9 {
      let Cc = _lc(S, ((nS / den, a),))
      fs.push(_lc(Cc, ((-(_dot3(n, Cc) + d), n),)))
    }
  }
  _dedupe-pts(fs).filter(inside)
}

/// Cylindre de base C0, d'axe unitaire a et de rayon R.
#let _foci-cyl(C0, a, R, n, d, inside) = {
  let s0 = _dot3(n, C0) + d
  let ne = _dot3(n, a)
  if calc.abs(ne) < 1e-8 or calc.abs(calc.abs(ne) - 1) < 1e-9 { return () }
  let fs = ()
  for sg in (1, -1) {
    let Cc = _lc(C0, ((((sg * R - s0) / ne), a),))
    fs.push(_lc(Cc, ((-(_dot3(n, Cc) + d), n),)))
  }
  _dedupe-pts(fs).filter(inside)
}

// -----------------------------------------------------------------------------
// Étiquettes numériques (valeur auto) et cotes de la section
// -----------------------------------------------------------------------------
/// Nombre -> (texte, approx) : arrondi, zéros inutiles supprimés, virgule décimale si `comma`,
/// vrai signe moins ; `approx` vaut true si l'arrondi change la valeur.
#let _fmt(v, digits, comma) = {
  let r = calc.round(v, digits: digits)
  let s = str(r)
  if s.ends-with(".0") { s = s.slice(0, -2) }
  if comma { s = s.replace(".", ",") }
  s = s.replace("-", "−")
  (s, calc.abs(v - r) > 1e-9)
}

/// Étiquette numérique d'une valeur (précédée de ≈ si elle est arrondie et si `mark`).
#let _num-label(v, digits, comma, unit, suffix: "", mark: true) = {
  let (s, approx) = _fmt(v, digits, comma)
  let u = if unit != none { "\u{a0}" + unit } else { "" }
  let txt = (if approx and mark { "≈\u{a0}" } else { "" }) + s + suffix + u
  [#txt]
}

/// Étiquettes finales : `user` vaut auto (toutes numériques) ou un dictionnaire dont les
/// valeurs remplacent les étiquettes symboliques (auto : valeur numérique).
#let _merge-labels(user, symbolic, autos) = {
  if user == auto { return autos }
  let l = symbolic
  for (k, v) in user {
    l.insert(k, if v == auto { autos.at(k) } else { v })
  }
  l
}

/// Ancre du texte : le coin ou le bord du cadre du texte le plus proche de la ligne,
/// (px, py) étant la direction écran allant de la ligne vers l'étiquette.
#let _label-anchor(px, py) = {
  let k = calc.rem(calc.round(_ang(px, py) / (calc.pi / 4)) + 8, 8)
  ("west", "south-west", "south", "south-east", "east", "north-east", "north", "north-west").at(int(k))
}

/// Ancre de l'étiquette d'une cote [P Q] : à côté du segment, jamais dessus (sous la ligne,
/// ou à droite si elle est plus raide que 45° à l'écran).
#let _dim-anchor(P, Q, x, y, z) = {
  let ds = _project-pt(_sub3(Q, P), x, y, z)
  let l = calc.sqrt(ds.at(0) * ds.at(0) + ds.at(1) * ds.at(1))
  if l < 1e-9 { return "north" }
  let px = -ds.at(1) / l
  let py = ds.at(0) / l
  let flip = if calc.abs(px) > calc.abs(py) { px < 0 } else { py > 0 }
  if flip {
    px = -px
    py = -py
  }
  _label-anchor(px, py)
}

/// Cylindre (base C0, axe unitaire e, rayon R) coupé par le plan (n, d) : cercle ou ellipse
/// (centre, demi-axes a >= b, c = distance du centre aux foyers, directions w, m des axes) ; none sinon.
#let _cyl-conic(C0, e, R, n, d) = {
  let ne = _dot3(n, e)
  if calc.abs(ne) < 1e-8 { return none }
  let t0 = -(_dot3(n, C0) + d) / ne
  let center = _lc(C0, ((t0, e),))
  if calc.abs(calc.abs(ne) - 1) < 1e-9 {
    return (kind: "circle", center: center, a: R, b: R, c: 0, w: none, m: none)
  }
  let a = R / calc.abs(ne)
  let w = _unit3(_sub3(e, _mul3(ne, n)))
  (kind: "ellipse", center: center, a: a, b: R, c: calc.sqrt(a * a - R * R), w: w, m: _unit3(_cross3(n, w)))
}

/// Cône (ou double cône) de sommet S, d'axe unitaire a, de rayon R et de hauteur H, coupé par le
/// plan (n, d) : cercle ou ellipse, calculés avec les sphères de Dandelin (2a = distance, le long
/// d'une génératrice, entre les deux cercles de contact) ; none pour une parabole, une hyperbole
/// ou un plan passant par le sommet.
#let _cone-conic(S, a, R, H, n, d) = {
  let nS = _dot3(n, S) + d
  let ne = _dot3(n, a)
  if calc.abs(nS) < 1e-7 * (1 + H + R) { return none }
  let ell = calc.sqrt(R * R + H * H)
  let sa = R / ell
  let ca = H / ell
  if calc.abs(ne) <= sa + 1e-9 { return none }
  if calc.abs(calc.abs(ne) - 1) < 1e-9 {
    let r = calc.abs(nS) * R / H
    return (kind: "circle", center: _lc(S, ((-nS / ne, a),)), a: r, b: r, c: 0, w: none, m: none)
  }
  let lams = (1, -1).map(sg => nS / (sg * sa - ne))
  let Fs = lams.map(l => {
    let Cc = _lc(S, ((l, a),))
    _lc(Cc, ((-(_dot3(n, Cc) + d), n),))
  })
  let ra = calc.abs(lams.at(0) - lams.at(1)) * ca / 2
  let rc = _norm3(_sub3(Fs.at(0), Fs.at(1))) / 2
  let center = _lc(Fs.at(0), ((0.5, _sub3(Fs.at(1), Fs.at(0))),))
  if rc < 1e-9 {
    return (kind: "circle", center: center, a: ra, b: ra, c: 0, w: none, m: none)
  }
  let w = _unit3(_sub3(Fs.at(0), Fs.at(1)))
  (kind: "ellipse", center: center, a: ra, b: calc.sqrt(calc.max(0, ra * ra - rc * rc)), c: rc,
   w: w, m: _unit3(_cross3(n, w)))
}

/// Segments de cote d'une conique `ci` (de la section par le plan de normale n) : rayon du cercle,
/// ou demi-axes a et b de l'ellipse (et c vers le foyer opposé si `foci`). Chaque segment est un
/// dictionnaire (P:, Q:, key:, dash:).
#let _conic-segs(ci, n, foci, x, y, z) = {
  if ci == none { return () }
  let rowx = (x.at(0), y.at(0), z.at(0))
  let rowy = (x.at(1), y.at(1), z.at(1))
  if ci.kind == "circle" {
    let (pu, pv) = _frame(n)
    return ((P: ci.center, Q: _radius-pt(ci.center, ci.a, pu, pv, x, y, z), key: "r"),)
  }
  let w = if _dot3(ci.w, rowx) < 0 { _mul3(-1, ci.w) } else { ci.w }
  let m = if _dot3(ci.m, rowy) < 0 { _mul3(-1, ci.m) } else { ci.m }
  let segs = (
    (P: ci.center, Q: _lc(ci.center, ((ci.a, w),)), key: "a"),
    (P: ci.center, Q: _lc(ci.center, ((ci.b, m),)), key: "b"),
  )
  if foci and ci.c > 1e-9 {
    segs.push((P: ci.center, Q: _lc(ci.center, ((-ci.c, w),)), key: "c", dash: "dashed"))
  }
  segs
}

/// Étiquettes des dimensions d'une conique (symboliques ou, avec auto, numériques).
#let _dims-labels(user, ci, digits, comma, unit) = {
  let autos = (
    r: _num-label(ci.a, digits, comma, unit),
    a: _num-label(ci.a, digits, comma, unit),
    b: _num-label(ci.b, digits, comma, unit),
    c: _num-label(ci.c, digits, comma, unit),
  )
  _merge-labels(user, (r: $r'$, a: $a$, b: $b$, c: $c$), autos)
}

/// Traits et textes pour `_render` à partir des segments de cote, dans la couleur de la section.
#let _dim-items(segs, lab, col, x, y, z) = {
  let edges = ()
  let texts = ()
  for sg in segs {
    edges.push((pts: (sg.P, sg.Q), vis: true, stroke: (paint: col, thickness: 0.9pt, dash: sg.at("dash", default: none))))
    texts.push((pos: _mid(sg.P, sg.Q), body: text(fill: col, lab.at(sg.key)), anchor: _dim-anchor(sg.P, sg.Q, x, y, z)))
  }
  (edges, texts)
}

// -----------------------------------------------------------------------------
// Rendu commun
//   edges, sec : listes de (pts: (...), vis: bool, stroke: optionnel)
//   polys      : liste de polygones ordonnés (remplissage de la section)
//   anchors    : liste de (nom, point)
//   dots       : liste de (point, couleur)
//   texts      : liste de (pos:, body:, anchor:)
// -----------------------------------------------------------------------------
#let _render(
  edges, sec, polys, anchors, dots, texts,
  plane-pts, plane-names, point-labels, center3,
  x, y, z,
  section-border, section-fill, hidden-style, more, length
) = canvas(x: x, y: y, z: z, length: length, {
  import draw: *

  // ancre de l'étiquette : on s'éloigne du centre du solide, dans l'écran
  let away(P) = _away(P, center3, x, y, z)

  for poly in polys {
    if poly.len() >= 3 {
      line(..poly, close: true, fill: section-fill, stroke: none)
    }
  }

  for it in edges.filter(it => not it.vis) {
    line(..it.pts, stroke: it.at("stroke", default: (paint: gray.darken(20%), dash: hidden-style, thickness: 1pt)))
  }
  for it in sec.filter(it => not it.vis) {
    line(..it.pts, stroke: (paint: section-border, dash: hidden-style, thickness: 1pt))
  }
  for it in sec.filter(it => it.vis) {
    line(..it.pts, stroke: section-border + 1.2pt)
  }
  for it in edges.filter(it => it.vis) {
    line(..it.pts, stroke: it.at("stroke", default: (cap: "round")))
  }

  for (name, p) in anchors {
    anchor(name, p)
  }

  for dt in dots {
    // (point, couleur) ou (point, couleur, creux)
    let hollow = dt.at(2, default: false)
    circle(
      dt.at(0), radius: 0.045,
      fill: if hollow { white } else { dt.at(1) },
      stroke: if hollow { dt.at(1) + 0.6pt } else { none },
    )
  }

  for t in texts {
    content(t.pos, t.body, anchor: t.anchor, padding: 0.06)
  }

  for (name, body) in point-labels {
    let a = anchors.find(a => a.at(0) == name)
    if a != none { content(a.at(1), body, anchor: away(a.at(1)), padding: 0.1) }
  }

  if plane-names != none and plane-pts != none {
    for (i, P) in plane-pts.enumerate() {
      if i < plane-names.len() {
        circle(P, radius: 0.05, fill: red, stroke: none)
        content(P, text(fill: red, plane-names.at(i)), anchor: away(P), padding: 0.08)
      }
    }
  }

  more
})

// Dessine un cylindre et sa section par un plan, en projection oblique (CeTZ).
// Le cylindre est défini par son rayon, sa hauteur, le centre de sa base et la direction de son axe. Le plan se donne comme pour `polysection` (trois points ou quatre coefficients). Les arêtes et les parties cachées de la section sont en pointillés. Les cas particuliers sont traités : plan parallèle à l'axe (rectangle), perpendiculaire à l'axe (cercle) ; l'ellipse peut montrer ses foyers.
// Ancres : "c0", "c1" (centres des bases), "i0", "i1", ... (extrémités des cordes de la section sur les bases), "sc" (centre de la section quand c'est une ellipse complète), "f0", "f1" (foyers).
// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
// Exemples d'utilisation :
// ```example
// #cylsection((0, 0.5, 0.5), (1, 0.3, -0.2), (-0.6, 1.4, 0.1), plane-names: ($A$, $B$, $C$))
// ```
// Plan parallèle à l'axe (rectangle)
// ```example
// #cylsection(1, 0, 0, -0.5, radius: 1, height: 2)
// ```
// Ellipse complète avec un rayon, les centres et les foyers
// ```example
// #cylsection(0.6, 1, 0, -1, show-radius: true, show-centers: true, show-foci: true,
//   point-labels: (c0: $O$, c1: $O'$, f0: $F$, f1: $F'$))
// ```
// ```example
// // Dimensions de l'ellipse (a, b, c) avec leurs vraies valeurs
// #cylsection(0.6, 1, 0, -1, show-dims: true, show-foci: true, dims-labels: auto, label-unit: "cm")
// ```
// -> content
#let cylsection(
  // Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by +
  // cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de
  // 3 points) -> array | dictionary
  ..plane-args,
  // Rayon du cylindre -> int | float
  radius: 1,
  // Hauteur du cylindre (distance entre les deux bases) -> int | float
  height: 2,
  // Centre de la base « inférieure » -> array
  base: (0, 0, 0),
  // Direction de l'axe, de la base vers la face supérieure (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné
  // par une équation) -> none | array
  plane-names: none,
  // Trace l'axe en tirets-points -> bool
  show-axis: false,
  // Marque les foyers de la section quand ils existent (ellipse, parabole, hyperbole) -> bool
  show-foci: false,
  // Trace un rayon, avec son étiquette, sur la base visible -> bool
  show-radius: false,
  // Étiquette du rayon ; auto : sa valeur numérique ; none pour ne pas en mettre -> auto | none | content
  radius-label: $r$,
  // Trait du rayon -> stroke
  radius-stroke: black + 0.8pt,
  // Marque les centres des bases et le centre de la section quand il est évident -> bool
  show-centers: false,
  // Trace les dimensions de la section avec leurs étiquettes : rayon d'un cercle, ou demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec show-foci) -> bool
  show-dims: false,
  // Étiquettes des dimensions de la section : dictionnaire (r:, a:, b:, c:) dont les valeurs remplacent les
  // étiquettes symboliques ($r'$, $a$, $b$, $c$) (la valeur auto donne la vraie valeur), ou auto pour tout
  // remplacer -> auto | dictionary
  dims-labels: (:),
  // Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (c0: $O$, s:
  // $S$) ; elles se placent vers l'extérieur du solide -> dictionary
  point-labels: (:),
  // Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  label-unit: none,
  // Nombre de décimales en mode auto -> int
  label-digits: 2,
  // Séparateur décimal en mode auto : "," ou "." -> str
  label-decimal: ",",
  // Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5,
  // -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  // Tolérance numérique (distances) -> float
  eps: 1e-6,
  // Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  // Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres)
  // -> content
  more: (),
  // Couleur du contour de la section -> color
  section-border: blue,
  // Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  // Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) ->
  // str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {
  let pos = plane-args.pos()
  let pl = _parse-plane(pos)
  let n = pl.n
  let d = pl.d

  let R = radius
  let rlab = if radius-label == auto {
    _num-label(R, label-digits, label-decimal == ",", label-unit)
  } else { radius-label }
  let H = height
  let e = _unit3(_p3(axis))
  let (u, v) = _frame(e)
  let C0 = _p3(base)
  let C1 = _lc(C0, ((H, e),))
  let k = _view-k(x, y, z)

  let circ(C, th) = _lc(C, ((R * calc.cos(th), u), (R * calc.sin(th), v)))
  let ncirc(th) = _lc((0, 0, 0), ((calc.cos(th), u), (calc.sin(th), v)))
  let lat-vis(th) = _dot3(ncirc(th), k) > 1e-9
  let top-vis = _dot3(e, k) > 1e-9
  let bot-vis = _dot3(e, k) < -1e-9

  let ku = _dot3(u, k)
  let kv = _dot3(v, k)
  let kap = calc.sqrt(ku * ku + kv * kv)
  let phi = _ang(ku, kv)
  let vb = if kap > 1e-9 { (phi + calc.pi / 2, phi - calc.pi / 2) } else { () }

  // --- arêtes du solide ------------------------------------------------------
  let edges = ()
  for (C, fv) in ((C0, bot-vis), (C1, top-vis)) {
    let arcs = _merge-arcs(_split-arcs(vb, th => true, th => fv or lat-vis(th)))
    for ar in arcs {
      edges.push((pts: _arc-pts(th => circ(C, th), ar.a, ar.b, per-turn), vis: ar.vis))
    }
  }
  for th in vb {
    edges.push((pts: (circ(C0, th), circ(C1, th)), vis: true))
  }
  if show-axis {
    edges.push((pts: (C0, C1), vis: true, stroke: (paint: gray, dash: "dash-dotted", thickness: 0.6pt)))
  }

  // --- section ---------------------------------------------------------------
  let sec = ()
  let poly = ()
  let anchors = (("c0", C0), ("c1", C1))
  let chord-pts = ()
  let sc-pt = none

  let ne = _dot3(n, e)
  let nu = _dot3(n, u)
  let nv = _dot3(n, v)
  let hyp = calc.sqrt(nu * nu + nv * nv)
  let s0 = _dot3(n, C0) + d
  let psi = _ang(nu, nv)

  if calc.abs(ne) > 1e-8 {
    // plan non parallèle à l'axe : arc d'ellipse sur la surface latérale + cordes
    let t-of(th) = -(s0 + R * (nu * calc.cos(th) + nv * calc.sin(th))) / ne
    let inside(th) = {
      let t = t-of(th)
      t >= -eps and t <= H + eps
    }
    let rho = R * hyp
    let br = vb
    if rho > 1e-12 {
      for tb in (0, H) {
        br += _cos-roots((-s0 - tb * ne) / rho, psi)
      }
    }
    let pt-of(th) = _lc(C0, ((t-of(th), e), (R * calc.cos(th), u), (R * calc.sin(th), v)))
    for ar in _merge-arcs(_split-arcs(br, inside, lat-vis)) {
      let pts = _arc-pts(pt-of, ar.a, ar.b, per-turn)
      sec.push((pts: pts, vis: ar.vis))
      poly += pts
    }
    for (C, fv) in ((C0, bot-vis), (C1, top-vis)) {
      let ch = _disk-chord(C, R, u, v, n, d)
      if ch != none {
        sec.push((pts: ch, vis: fv))
        poly += ch
        chord-pts += ch
      }
    }
    // ellipse complète : son centre est le point où le plan coupe l'axe
    let t0 = -s0 / ne
    if chord-pts.len() == 0 and sec.len() > 0 and t0 >= -eps and t0 <= H + eps {
      sc-pt = _lc(C0, ((t0, e),))
    }
  } else {
    // plan parallèle à l'axe : deux génératrices + deux cordes (rectangle)
    let rts = _cos-roots(-s0 / (R * hyp), psi)
    if rts.len() == 2 {
      let (t1, t2) = rts
      let b1 = circ(C0, t1)
      let b2 = circ(C0, t2)
      let q1 = circ(C1, t1)
      let q2 = circ(C1, t2)
      sec.push((pts: (b1, q1), vis: lat-vis(t1)))
      sec.push((pts: (b2, q2), vis: lat-vis(t2)))
      sec.push((pts: (b1, b2), vis: bot-vis))
      sec.push((pts: (q1, q2), vis: top-vis))
      poly = (b1, b2, q2, q1)
      chord-pts = (b1, b2, q1, q2)
    }
  }
  for (i, p) in chord-pts.enumerate() {
    anchors.push(("i" + str(i), p))
  }
  if sc-pt != none { anchors.push(("sc", sc-pt)) }

  // --- foyers (ellipse) --------------------------------------------------------
  let foci = _foci-cyl(C0, e, R, n, d, F => {
    let t = _dot3(_sub3(F, C0), e)
    t >= -eps and t <= H + eps
  })
  for (i, F) in foci.enumerate() {
    anchors.push(("f" + str(i), F))
  }

  // --- annotations -----------------------------------------------------------
  let dots = ()
  let texts = ()
  if show-foci {
    for F in foci { dots.push((F, section-border)) }
  }
  if show-centers {
    dots.push((C0, black))
    dots.push((C1, black))
    if sc-pt != none { dots.push((sc-pt, section-border)) }
  }
  if show-radius {
    // rayon tracé sur la base visible (la base supérieure à défaut)
    let (Cf, vf) = if top-vis { (C1, true) } else { (C0, bot-vis) }
    let Pr = _radius-pt(Cf, R, u, v, x, y, z)
    edges.push((pts: (Cf, Pr), vis: vf, stroke: _radius-stroke(radius-stroke, vf, hidden-style)))
    if rlab != none {
      texts.push((pos: _mid(Cf, Pr), body: rlab, anchor: "south"))
    }
  }

  // --- dimensions de la section (cercle : rayon ; ellipse complète : demi-axes) -----
  if show-dims and sc-pt != none {
    let ci = _cyl-conic(C0, e, R, n, d)
    if ci != none {
      let dl = _dims-labels(dims-labels, ci, label-digits, label-decimal == ",", label-unit)
      let (de, dt) = _dim-items(_conic-segs(ci, n, show-foci, x, y, z), dl, section-border, x, y, z)
      edges += de
      texts += dt
    }
  }

  _render(
    edges, sec, (_sort-poly(poly, n),), anchors, dots, texts,
    _plane-points(pos), plane-names, point-labels, _lc(C0, ((H / 2, e),)),
    x, y, z, section-border, section-fill, hidden-style, more, length
  )
}

// -----------------------------------------------------------------------------
// Bloc « cône » réutilisé par `conesection` et `doubleconesection`.
//   C0 : centre de la base ; e : direction de la base vers le sommet.
// -----------------------------------------------------------------------------
#let _cone-parts(C0, e, R, H, n, d, k, eps, per-turn) = {
  let (u, v) = _frame(e)
  let S = _lc(C0, ((H, e),))
  let ek = _dot3(e, k)

  let circ(th) = _lc(C0, ((R * calc.cos(th), u), (R * calc.sin(th), v)))
  let ncirc(th) = _lc((0, 0, 0), ((calc.cos(th), u), (calc.sin(th), v)))
  // la normale à la surface latérale est proportionnelle à H·n(th) + R·e
  let lat-vis(th) = H * _dot3(ncirc(th), k) + R * ek > 1e-9
  let base-vis = ek < -1e-9

  let ku = _dot3(u, k)
  let kv = _dot3(v, k)
  let kap = calc.sqrt(ku * ku + kv * kv)
  let phi = _ang(ku, kv)
  let vb = if kap > 1e-9 { _cos-roots(-R * ek / (H * kap), phi) } else { () }

  // --- arêtes du solide ------------------------------------------------------
  let edges = ()
  for ar in _merge-arcs(_split-arcs(vb, th => true, th => base-vis or lat-vis(th))) {
    edges.push((pts: _arc-pts(circ, ar.a, ar.b, per-turn), vis: ar.vis))
  }
  for th in vb {
    edges.push((pts: (S, circ(th)), vis: true))
  }

  // --- section ---------------------------------------------------------------
  let sec = ()
  let poly = ()
  let chord-pts = ()
  let sc-pt = none

  let ne = _dot3(n, e)
  let nu = _dot3(n, u)
  let nv = _dot3(n, v)
  let hyp = calc.sqrt(nu * nu + nv * nv)
  let nS = _dot3(n, S) + d
  let psi = _ang(nu, nv)

  if calc.abs(nS) < 1e-7 * (1 + H + R) {
    // plan passant par le sommet : triangle (sommet + corde de la base)
    let ch = _disk-chord(C0, R, u, v, n, d)
    if ch != none {
      let (P, Q) = ch
      for Pt in (P, Q) {
        let w = _sub3(Pt, C0)
        let th = _ang(_dot3(w, u), _dot3(w, v))
        sec.push((pts: (S, Pt), vis: lat-vis(th)))
      }
      sec.push((pts: (P, Q), vis: base-vis))
      poly = (S, P, Q)
      chord-pts = (P, Q)
    }
  } else {
    // section générale : conique sur la surface latérale + corde sur la base
    //   point de la génératrice d'angle th :  S + s(th)·(B(th) − S)
    let sg = -nS
    let D0 = -H * ne
    let den(th) = D0 + R * (nu * calc.cos(th) + nv * calc.sin(th))
    let inside(th) = {
      let dd = den(th)
      if calc.abs(dd) < 1e-12 { false } else {
        let s = sg / dd
        s >= -eps and s <= 1 + eps
      }
    }
    let rho = R * hyp
    let br = vb
    if rho > 1e-12 {
      br += _cos-roots(-D0 / rho, psi)
      br += _cos-roots((sg - D0) / rho, psi)
    }
    let pt-of(th) = _lc(S, ((sg / den(th), _sub3(circ(th), S)),))
    for ar in _merge-arcs(_split-arcs(br, inside, lat-vis)) {
      let pts = _arc-pts(pt-of, ar.a, ar.b, per-turn)
      sec.push((pts: pts, vis: ar.vis))
      poly += pts
    }
    let ch = _disk-chord(C0, R, u, v, n, d)
    if ch != none {
      sec.push((pts: ch, vis: base-vis))
      poly += ch
      chord-pts = ch
    }
    if hyp < 1e-9 and sec.len() > 0 {
      sc-pt = _lc(S, ((sg / D0, _sub3(C0, S)),))
    }
  }

  (
    edges: edges, sec: sec, poly: _sort-poly(poly, n), chord-pts: chord-pts,
    sc: sc-pt, S: S, u: u, v: v, base-vis: base-vis,
  )
}

// Dessine un cône et sa section par un plan, en projection oblique (CeTZ).
// Le cône est défini par le rayon et le centre de sa base, sa hauteur et la direction de son axe. Le plan se donnecomme pour `polysection`. Selon le plan, la section est un cercle, une ellipse, une parabole ou un morceau d'hyperbole ; un plan passant par le sommet donne un triangle. Les foyers sont calculés avec les sphères de Dandelin. Les parties cachées sont en pointillés.
// Ancres : "c0" (centre de la base), "s" (sommet), "i0", "i1", ... (extrémités de la corde sur la base), "sc" (centre de la section quand c'est un cercle), "f0", "f1" (foyers).
// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
// Exemples d'utilisation :
// ```example
// #conesection((0.3, 0.2, 0.5), (0.6, 0.4, -0.7), (-0.6, 0.3, 0.1), plane-names: ($A$, $B$, $C$))
// ```
// Plan contenant l'axe (triangle)
// ```example
// #conesection(1, 0, 0, 0, show-axis: true)
// ```
// Ellipse avec ses foyers
// ```example
// #conesection(0.3, 1, 0, -0.9, show-foci: true, point-labels: (f0: $F$, f1: $F'$))
// ```
// Dimensions de l'ellipse et rayon de la base avec leurs vraies valeurs
// ```example
// #conesection(0.3, 1, 0, -0.9, show-dims: true, dims-labels: auto, show-radius: true, radius-label: auto)
// ```
// -> content
#let conesection(
  // Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by +
  // cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de
  // 3 points) -> array | dictionary
  ..plane-args,
  // Rayon de la base -> int | float
  radius: 1,
  // Hauteur du cône (distance de la base au sommet) -> int | float
  height: 2,
  // Centre de la base -> array
  base: (0, 0, 0),
  // Direction de l'axe, de la base vers le sommet (pas besoin qu'elle soit unitaire) -> array
  axis: (0, 1, 0),
  // Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné
  // par une équation) -> none | array
  plane-names: none,
  // Trace l'axe en tirets-points -> bool
  show-axis: false,
  // Marque les foyers de la section quand ils existent (ellipse, parabole, hyperbole) -> bool
  show-foci: false,
  // Trace un rayon, avec son étiquette, sur la base (en pointillés si elle est cachée) -> bool
  show-radius: false,
  // Étiquette du rayon ; auto : sa valeur numérique ; none pour ne pas en mettre -> auto | none | content
  radius-label: $r$,
  // Trait du rayon -> stroke
  radius-stroke: black + 0.8pt,
  // Marque le centre de la base et le centre de la section quand c'est un cercle -> bool
  show-centers: false,
  // Marque le sommet -> bool
  show-apex: false,
  // Trace les dimensions de la section avec leurs étiquettes : rayon d'un cercle, ou demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec show-foci) -> bool
  show-dims: false,
  // Étiquettes des dimensions de la section : dictionnaire (r:, a:, b:, c:) dont les valeurs remplacent les
  // étiquettes symboliques ($r'$, $a$, $b$, $c$) (la valeur auto donne la vraie valeur), ou auto pour tout
  // remplacer -> auto | dictionary
  dims-labels: (:),
  // Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (c0: $O$, s:
  // $S$) ; elles se placent vers l'extérieur du solide -> dictionary
  point-labels: (:),
  // Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  label-unit: none,
  // Nombre de décimales en mode auto -> int
  label-digits: 2,
  // Séparateur décimal en mode auto : "," ou "." -> str
  label-decimal: ",",
  // Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5,
  // -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  // Tolérance numérique (distances) -> float
  eps: 1e-6,
  // Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  // Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres)
  // -> content
  more: (),
  // Couleur du contour de la section -> color
  section-border: blue,
  // Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  // Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) ->
  // str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {
  let pos = plane-args.pos()
  let pl = _parse-plane(pos)
  let n = pl.n
  let d = pl.d

  let R = radius
  let rlab = if radius-label == auto {
    _num-label(R, label-digits, label-decimal == ",", label-unit)
  } else { radius-label }
  let H = height
  let e = _unit3(_p3(axis))
  let C0 = _p3(base)
  let k = _view-k(x, y, z)

  let cp = _cone-parts(C0, e, R, H, n, d, k, eps, per-turn)
  let S = cp.S
  let edges = cp.edges
  if show-axis {
    edges.push((pts: (C0, S), vis: true, stroke: (paint: gray, dash: "dash-dotted", thickness: 0.6pt)))
  }

  let anchors = (("c0", C0), ("s", S))
  for (i, p) in cp.chord-pts.enumerate() {
    anchors.push(("i" + str(i), p))
  }
  if cp.sc != none { anchors.push(("sc", cp.sc)) }

  // foyers (ellipse, parabole) : sphères de Dandelin
  let foci = _foci-cone(S, e, R, H, n, d, F => {
    let w = _sub3(F, C0)
    let t = _dot3(w, e)
    let r = calc.sqrt(calc.max(0, _dot3(w, w) - t * t))
    t >= -eps and t <= H + eps and r <= R * (H - t) / H + 1e-6
  })
  for (i, F) in foci.enumerate() {
    anchors.push(("f" + str(i), F))
  }

  let dots = ()
  let texts = ()
  if show-foci {
    for F in foci { dots.push((F, section-border)) }
  }
  if show-centers {
    dots.push((C0, black))
    if cp.sc != none { dots.push((cp.sc, section-border)) }
  }
  if show-apex { dots.push((S, black)) }
  if show-radius {
    let Pr = _radius-pt(C0, R, cp.u, cp.v, x, y, z)
    edges.push((pts: (C0, Pr), vis: cp.base-vis, stroke: _radius-stroke(radius-stroke, cp.base-vis, hidden-style)))
    if rlab != none {
      texts.push((pos: _mid(C0, Pr), body: rlab, anchor: "south"))
    }
  }

  // --- dimensions de la section (cercle : rayon ; ellipse complète : demi-axes) -----
  if show-dims and cp.chord-pts.len() == 0 and cp.sec.len() > 0 {
    let ci = _cone-conic(S, e, R, H, n, d)
    if ci != none {
      let dl = _dims-labels(dims-labels, ci, label-digits, label-decimal == ",", label-unit)
      let (de, dt) = _dim-items(_conic-segs(ci, n, show-foci, x, y, z), dl, section-border, x, y, z)
      edges += de
      texts += dt
    }
  }

  _render(
    edges, cp.sec, (cp.poly,), anchors, dots, texts,
    _plane-points(pos), plane-names, point-labels, _lc(C0, ((H / 3, e),)),
    x, y, z, section-border, section-fill, hidden-style, more, length
  )
}

// Dessine un double cône (« sablier ») et sa section par un plan, en projection oblique (CeTZ).
// Deux cônes de même sommet et de même axe, opposés par le sommet ; chacun a pour hauteur `height` et pour rayon de base `radius`. Les sections possibles : cercle, ellipse, parabole, hyperbole (deux branches, une par nappe), deux droites sécantes (plan passant par le sommet), point ou droite.
// Ancres : "s" (sommet), "c0" (centre de la base du bas), "c1" (centre de la base du haut), "i0", "i1", ... (extrémités des cordes sur les bases), "sc" (centre d'une section circulaire), "f0", "f1" (foyers).
// Limite : le tracé suppose que les deux nappes ne se masquent pas l'une l'autre, ce qui est le cas tant que l'angle entre la direction de vue et l'axe dépasse le demi-angle au sommet.
// Avec `show-dims`, la section montre ses dimensions : rayon d'un cercle, demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec `show-foci`). Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
// Exemples d'utilisation :
// ```example
// #doubleconesection(1, 0, 0, -0.4, show-foci: true, show-apex: true,
//   point-labels: (s: $S$, f0: $F$, f1: $F'$))
// ```
// Parabole (plan parallèle à une génératrice)
// ```example
// #doubleconesection(0.894, -0.447, 0, 0.447, show-foci: true)
// ```
// Plan passant par le sommet
// ```example
// #doubleconesection(1, 0, 0, 0, show-axis: true, show-apex: true)
// ```
// Rayon du cercle de section (plan perpendiculaire à l'axe) avec sa vraie valeur
// ```example
// #doubleconesection(0, 1, 0, -1, show-dims: true, dims-labels: auto)
// ```
// -> content
#let doubleconesection(
  // Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by +
  // cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de
  // 3 points) -> array | dictionary
  ..plane-args,
  // Rayon de la base de chaque nappe -> int | float
  radius: 1,
  // Hauteur de chaque nappe (distance du sommet à chaque base) -> int | float
  height: 2,
  // Sommet commun des deux cônes -> array
  apex: (0, 0, 0),
  // Direction de l'axe, de la nappe du bas vers la nappe du haut (pas besoin qu'elle soit unitaire) ->
  // array
  axis: (0, 1, 0),
  // Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné
  // par une équation) -> none | array
  plane-names: none,
  // Trace l'axe en tirets-points -> bool
  show-axis: false,
  // Marque les foyers de la section quand ils existent (ellipse, parabole, hyperbole) -> bool
  show-foci: false,
  // Trace un rayon, avec son étiquette, sur la base tournée vers l'observateur -> bool
  show-radius: false,
  // Étiquette du rayon ; auto : sa valeur numérique ; none pour ne pas en mettre -> auto | none | content
  radius-label: $r$,
  // Trait du rayon -> stroke
  radius-stroke: black + 0.8pt,
  // Marque les centres des deux bases et le centre de la section quand c'est un cercle -> bool
  show-centers: false,
  // Marque le sommet -> bool
  show-apex: false,
  // Trace les dimensions de la section avec leurs étiquettes : rayon d'un cercle, ou demi-axes a et b d'une ellipse complète (et c, distance du centre à un foyer, avec show-foci) -> bool
  show-dims: false,
  // Étiquettes des dimensions de la section : dictionnaire (r:, a:, b:, c:) dont les valeurs remplacent les
  // étiquettes symboliques ($r'$, $a$, $b$, $c$) (la valeur auto donne la vraie valeur), ou auto pour tout
  // remplacer -> auto | dictionary
  dims-labels: (:),
  // Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (c0: $O$, s:
  // $S$) ; elles se placent vers l'extérieur du solide -> dictionary
  point-labels: (:),
  // Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  label-unit: none,
  // Nombre de décimales en mode auto -> int
  label-digits: 2,
  // Séparateur décimal en mode auto : "," ou "." -> str
  label-decimal: ",",
  // Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5,
  // -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  // Tolérance numérique (distances) -> float
  eps: 1e-6,
  // Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  // Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres)
  // -> content
  more: (),
  // Couleur du contour de la section -> color
  section-border: blue,
  // Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  // Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) ->
  // str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {
  let pos = plane-args.pos()
  let pl = _parse-plane(pos)
  let n = pl.n
  let d = pl.d

  let R = radius
  let rlab = if radius-label == auto {
    _num-label(R, label-digits, label-decimal == ",", label-unit)
  } else { radius-label }
  let H = height
  let e = _unit3(_p3(axis))
  let S = _p3(apex)
  let k = _view-k(x, y, z)

  let Cb = _lc(S, ((-H, e),))  // centre de la base du bas
  let Ct = _lc(S, ((H, e),))   // centre de la base du haut
  let lo = _cone-parts(Cb, e, R, H, n, d, k, eps, per-turn)
  let up = _cone-parts(Ct, _mul3(-1, e), R, H, n, d, k, eps, per-turn)

  let edges = lo.edges + up.edges
  if show-axis {
    edges.push((pts: (Cb, Ct), vis: true, stroke: (paint: gray, dash: "dash-dotted", thickness: 0.6pt)))
  }
  let sec = lo.sec + up.sec

  let anchors = (("s", S), ("c0", Cb), ("c1", Ct))
  for (i, p) in (lo.chord-pts + up.chord-pts).enumerate() {
    anchors.push(("i" + str(i), p))
  }
  let sc-pt = if lo.sc != none { lo.sc } else { up.sc }
  if sc-pt != none { anchors.push(("sc", sc-pt)) }

  // foyers (ellipse, parabole, hyperbole) : sphères de Dandelin
  let foci = _foci-cone(S, e, R, H, n, d, F => {
    let w = _sub3(F, S)
    let a = _dot3(w, e)
    let r = calc.sqrt(calc.max(0, _dot3(w, w) - a * a))
    calc.abs(a) <= H + eps and r <= R * calc.abs(a) / H + 1e-6
  })
  for (i, F) in foci.enumerate() {
    anchors.push(("f" + str(i), F))
  }

  let dots = ()
  let texts = ()
  if show-foci {
    for F in foci { dots.push((F, section-border)) }
  }
  if show-centers {
    dots.push((Cb, black))
    dots.push((Ct, black))
    if sc-pt != none { dots.push((sc-pt, section-border)) }
  }
  if show-apex { dots.push((S, black)) }
  if show-radius {
    // rayon tracé sur la base tournée vers l'observateur (celle du haut à défaut)
    let (Cf, cpf) = if up.base-vis or not lo.base-vis { (Ct, up) } else { (Cb, lo) }
    let Pr = _radius-pt(Cf, R, cpf.u, cpf.v, x, y, z)
    edges.push((pts: (Cf, Pr), vis: cpf.base-vis, stroke: _radius-stroke(radius-stroke, cpf.base-vis, hidden-style)))
    if rlab != none {
      texts.push((pos: _mid(Cf, Pr), body: rlab, anchor: "south"))
    }
  }

  // --- dimensions de la section (cercle : rayon ; ellipse complète : demi-axes) -----
  if show-dims and (lo.chord-pts + up.chord-pts).len() == 0 and (lo.sec + up.sec).len() > 0 {
    let ci = _cone-conic(S, e, R, H, n, d)
    if ci != none {
      let dl = _dims-labels(dims-labels, ci, label-digits, label-decimal == ",", label-unit)
      let (de, dt) = _dim-items(_conic-segs(ci, n, show-foci, x, y, z), dl, section-border, x, y, z)
      edges += de
      texts += dt
    }
  }

  _render(
    edges, sec, (lo.poly, up.poly), anchors, dots, texts,
    _plane-points(pos), plane-names, point-labels, S,
    x, y, z, section-border, section-fill, hidden-style, more, length
  )
}


// Dessine une sphère et sa section par un plan, en projection oblique (CeTZ).
// Le contour apparent est calculé exactement (c'est une ellipse en projection oblique) ; un équateur facultatif
// donne l'impression de relief. La section est un cercle dont les parties cachées sont en pointillés.
// Ancres : "o" (centre), "sc" (centre du cercle de section).
// Avec `show-dims`, le rayon du cercle de section est tracé et étiqueté. Les valeurs `auto` de `radius-label` et de `dims-labels` affichent les vraies valeurs (arrondies, précédées de ≈ si besoin ; `label-unit`, `label-digits`, `label-decimal`).
// Exemples d'utilisation :
// ```example
// #spheresection(1, 1, 1, -0.5)
// ```
// Plan horizontal avec un rayon, les centres et des étiquettes
// ```example
// #spheresection(0, 1, 0, -0.6, center: (0, 1, 0), show-radius: true, show-centers: true,
//   point-labels: (o: $O$, sc: $I$))
// ```
// Rayon de la sphère et du cercle de section avec leurs vraies valeurs
// ```example
// #spheresection(0, 1, 0, -0.6, center: (0, 1, 0), show-radius: true, radius-label: auto, show-dims: true, dims-labels: auto)
// ```
// -> content
#let spheresection(
  // Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by +
  // cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de
  // 3 points) -> array | dictionary
  ..plane-args,
  // Rayon de la sphère -> int | float
  radius: 1,
  // Centre de la sphère -> array
  center: (0, 0, 0),
  // Direction des pôles (sert seulement à tracer l'équateur) -> array
  axis: (0, 1, 0),
  // Trace l'équateur (cercle perpendiculaire à l'axe), qui donne du relief -> bool
  show-equator: true,
  // Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné
  // par une équation) -> none | array
  plane-names: none,
  // Trace un rayon sur le contour apparent, où il apparaît en vraie grandeur -> bool
  show-radius: false,
  // Étiquette du rayon ; auto : sa valeur numérique ; none pour ne pas en mettre -> auto | none | content
  radius-label: $r$,
  // Trait du rayon -> stroke
  radius-stroke: black + 0.8pt,
  // Marque le centre de la sphère et celui du cercle de section -> bool
  show-centers: false,
  // Trace les dimensions de la section avec leurs étiquettes : le rayon du cercle de section -> bool
  show-dims: false,
  // Étiquettes des dimensions de la section : dictionnaire (r:, a:, b:, c:) dont les valeurs remplacent les
  // étiquettes symboliques ($r'$, $a$, $b$, $c$) (la valeur auto donne la vraie valeur), ou auto pour tout
  // remplacer -> auto | dictionary
  dims-labels: (:),
  // Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (o: $O$, sc:
  // $I$) -> dictionary
  point-labels: (:),
  // Unité ajoutée aux longueurs en mode auto, par exemple "cm" -> none | str
  label-unit: none,
  // Nombre de décimales en mode auto -> int
  label-digits: 2,
  // Séparateur décimal en mode auto : "," ou "." -> str
  label-decimal: ",",
  // Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5,
  // -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  // Tolérance numérique (distances) -> float
  eps: 1e-6,
  // Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  // Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres)
  // -> content
  more: (),
  // Couleur du contour de la section -> color
  section-border: blue,
  // Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  // Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) ->
  // str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {
  let pos = plane-args.pos()
  let pl = _parse-plane(pos)
  let n = pl.n
  let d = pl.d

  let R = radius
  let rlab = if radius-label == auto {
    _num-label(R, label-digits, label-decimal == ",", label-unit)
  } else { radius-label }
  let O = _p3(center)
  let k = _view-k(x, y, z)

  // --- contour apparent : grand cercle perpendiculaire à la direction de vue --
  let (k1, k2) = _frame(k)
  let edges = ()
  edges.push((
    pts: _arc-pts(th => _lc(O, ((R * calc.cos(th), k1), (R * calc.sin(th), k2))), 0, _tau, per-turn),
    vis: true,
  ))

  // --- équateur (facultatif) -------------------------------------------------
  if show-equator {
    let e = _unit3(_p3(axis))
    let (a1, a2) = _frame(e)
    let eq(th) = _lc(O, ((R * calc.cos(th), a1), (R * calc.sin(th), a2)))
    let ea = _dot3(a1, k)
    let eb = _dot3(a2, k)
    let ekap = calc.sqrt(ea * ea + eb * eb)
    let eb-br = if ekap > 1e-9 { (_ang(ea, eb) + calc.pi / 2, _ang(ea, eb) - calc.pi / 2) } else { () }
    let evis(th) = _dot3(_sub3(eq(th), O), k) > 1e-9
    for ar in _merge-arcs(_split-arcs(eb-br, th => true, evis)) {
      edges.push((
        pts: _arc-pts(eq, ar.a, ar.b, per-turn),
        vis: ar.vis,
        stroke: if ar.vis { gray + 0.5pt } else { (paint: gray, dash: hidden-style, thickness: 0.5pt) },
      ))
    }
  }

  // --- section ---------------------------------------------------------------
  let ss = _sphere-section(O, R, n, d, k, eps, per-turn)
  let sec = ss.sec
  let sc-pt = ss.sc
  let anchors = (("o", O),)
  if sc-pt != none { anchors.push(("sc", sc-pt)) }

  // --- annotations -----------------------------------------------------------
  let dots = ()
  let texts = ()
  if show-centers {
    dots.push((O, black))
    if sc-pt != none { dots.push((sc-pt, section-border)) }
  }
  if show-radius {
    // rayon sur le contour apparent : il apparaît en vraie grandeur
    let Pr = _radius-pt(O, R, k1, k2, x, y, z)
    edges.push((pts: (O, Pr), vis: true, stroke: radius-stroke))
    if rlab != none {
      texts.push((pos: _mid(O, Pr), body: rlab, anchor: "south"))
    }
  }

  // --- rayon du cercle de section ------------------------------------------------------
  if show-dims and sc-pt != none {
    let ci = (kind: "circle", center: sc-pt, a: ss.rc, b: ss.rc, c: 0, w: none, m: none)
    let dl = _dims-labels(dims-labels, ci, label-digits, label-decimal == ",", label-unit)
    let (de, dt) = _dim-items(_conic-segs(ci, n, false, x, y, z), dl, section-border, x, y, z)
    edges += de
    texts += dt
  }

  _render(
    edges, sec, (ss.poly,), anchors, dots, texts,
    _plane-points(pos), plane-names, point-labels, O,
    x, y, z, section-border, section-fill, hidden-style, more, length
  )
}

// Coordonnées (latitude, longitude), en degrés, de 50 grandes villes : Paris, Londres, Tokyo, New York, Los Angeles, Sydney, Rio de Janeiro, Le Cap, Le Caire, Moscou, Dakar, Nouméa etc. Elles s'utilisent par leur nom dans `points` de `globe`, ou se lisent directement : globe-cities.at("Paris") donne (48.8566, 2.3522). -> dictionary
#let globe-cities = (
  // Villes initiales
  "Paris": (48.8566, 2.3522),
  "Londres": (51.5074, -0.1278),
  "Tokyo": (35.6762, 139.6503),
  "New York": (40.7128, -74.0060),
  "Los Angeles": (34.0522, -118.2437),
  "Sydney": (-33.8688, 151.2093),
  "Rio de Janeiro": (-22.9068, -43.1729),
  "Le Cap": (-33.9249, 18.4241),
  "Le Caire": (30.0444, 31.2357),
  "Moscou": (55.7558, 37.6173),
  "Dakar": (14.7167, -17.4677),
  "Nouméa": (-22.2758, 166.4580),

  // Ajouts précédents
  "Berlin": (52.5200, 13.4050),
  "Rome": (41.9028, 12.4964),
  "Madrid": (40.4168, -3.7038),
  "Pékin": (39.9042, 116.4074),
  "Washington": (38.9072, -77.0369),
  "Ottawa": (45.4215, -75.6972),
  "Brasília": (-15.7975, -47.8919),
  "Buenos Aires": (-34.6037, -58.3816),
  "Mexico": (19.4326, -99.1332),
  "New Delhi": (28.6139, 77.2090),
  "Singapour": (1.3521, 103.8198),
  "Séoul": (37.5665, 126.9780),
  "Nairobi": (-1.2921, 36.8219),
  "Lagos": (6.5244, 3.3792),
  "Canberra": (-35.2809, 149.1300),
  "Wellington": (-41.2924, 174.7787),
  "Kyoto": (35.0116, 135.7681),
  "Kaboul": (34.5553, 69.2075),

  // Nouveaux ajouts (Europe & Asie)
  "Athènes": (37.9838, 23.7275),
  "Stockholm": (59.3293, 18.0686),
  "Istanbul": (41.0082, 28.9784),
  "Dubaï": (25.2048, 55.2708),
  "Bangkok": (13.7563, 100.5018),
  "Jakarta": (-6.2088, 106.8456),
  "Riyad": (24.7136, 46.6753),
  "Tachkent": (41.2995, 69.2401),
  "Oulan-Bator": (47.8864, 106.9057),
  "Manille": (14.5995, 120.9842),

  // Nouveaux ajouts (Amériques)
  "Chicago": (41.8781, -87.6298),
  "Vancouver": (49.2827, -123.1207),
  "Lima": (-12.0464, -77.0428),
  "Santiago": (-33.4489, -70.6693),
  "Bogota": (4.7110, -74.0721),

  // Nouveaux ajouts (Afrique & Océanie/Pacifique)
  "Casablanca": (33.5731, -7.5898),
  "Johannesburg": (-26.2041, 28.0473),
  "Antananarivo": (-18.8792, 47.5079),
  "Papeete": (-17.5516, -149.5584),
  "Auckland": (-36.8485, 174.7633),
)

// Paramètres de vue (x, y, z) d'une projection orthographique centrée sur le point de longitude `lon` et de
// latitude `lat`. La sphère apparaît alors comme un cercle, avec l'axe sud-nord vertical. À utiliser avec
// l'orientation par défaut de `globe` (axe (0, 1, 0), Greenwich (0, 0, 1)).
// Plus `lat` est grand, plus l'équateur s'ouvre (effet de relief) et plus le pôle Nord s'éloigne du bord haut
// du dessin ; entre 10 et 20 il en paraît pratiquement le point le plus haut.
// Exemple d'utilisation :
// ```example
// #globe(..globe-view(lon: 0, lat: 15), show-axis: true)
// ```
// -> dictionary
#let globe-view(
  // Longitude du point au centre du dessin, en degrés (est positif) -> int | float
  lon: 20,
  // Latitude du point au centre du dessin, en degrés (nord positif) -> int | float
  lat: 25,
) = {
  let a = lon * calc.pi / 180
  let b = lat * calc.pi / 180
  (
    x: (calc.cos(a), -calc.sin(b) * calc.sin(a)),
    y: (0, calc.cos(b)),
    z: (-calc.sin(a), -calc.sin(b) * calc.cos(a)),
  )
}

#let _resolve-point(p) = {
  if type(p) == str {
    assert(p in globe-cities, message: "Ville inconnue : " + p + ". Donne un dictionnaire (name:, lat:, lon:).")
    let (la, lo) = globe-cities.at(p)
    (name: p, lat: la, lon: lo)
  } else if "city" in p {
    let (la, lo) = globe-cities.at(p.city)
    (name: p.city, lat: la, lon: lo) + p
  } else {
    p
  }
}

// Dessine un globe terrestre (variante de `spheresection`) pour expliquer les coordonnées géographiques.
// Latitude : angle depuis l'équateur, de -90° (sud) à +90° (nord). Longitude : angle depuis le méridien de
// Greenwich, de -180° (ouest) à +180° (est). Tous les angles se donnent en degrés.
// On peut afficher l'équateur, les tropiques, le méridien de Greenwich, des parallèles et des méridiens (isolés
// ou en quadrillage), l'axe sud-nord, des villes (voir `globe-cities`) ou des points de coordonnées quelconques
// et, pour un point, la construction de ses coordonnées : angle de longitude dans le plan de l'équateur et angle de
// latitude dans le plan de son méridien. Un plan peut aussi être donné pour dessiner une section (un parallèle est
// un plan perpendiculaire à l'axe, un méridien un plan qui le contient).
// La projection oblique déforme la sphère en ellipse : `globe-view` donne une vue orthographique.
// Ancres : "o" (centre), "n", "s" (pôles), "g" (point de coordonnées (0, 0)), "p0", "p1", ... et le nom de chaque
// point, "sc" (centre de la section).
// Avec `angles: auto` pour un point (ou `lon-label: auto` / `lat-label: auto` pour tous), les angles de la construction
// affichent leurs valeurs en degrés au lieu de θ et φ (`label-digits`, `label-decimal`).
// Exemples d'utilisation :
// ```example
// #globe(..globe-view(lon: 20, lat: 20), show-axis: true, show-tropics: true, graticule: 30,
//   points: ("Paris", "Le Caire", "Dakar"))
// ```
// Construction de la longitude et de la latitude d'une ville
// ```example
// #globe(..globe-view(lon: 60, lat: 20), show-axis: true, show-centers: true,
//   points: (("city": "Tokyo", angles: true),), point-labels: (o: $O$, g: $G$))
// ```
// Point de coordonnées quelconques
// ```example
// #globe(..globe-view(lon: 40, lat: 20), points: ((name: "M", lat: 35, lon: 60, angles: true),))
// ```
// Construction avec les valeurs numériques de la longitude et de la latitude
// ```example
// #globe(..globe-view(lon: 60, lat: 20), points: (("city": "Tokyo", angles: auto),))
// ```
// -> content
#let globe(
  // Plan de coupe : trois points (A, B, C), ou quatre coefficients a, b, c, d de l'équation ax + by +
  // cz + d = 0, ou un seul argument (dictionnaire (a:, b:, c:, d:), tableau de 4 nombres ou tableau de
  // 3 points) -> array | dictionary
  ..plane-args,
  // Rayon de la sphère -> int | float
  radius: 1,
  // Centre de la sphère -> array
  center: (0, 0, 0),
  // Direction de l'axe sud-nord, du pôle Sud vers le pôle Nord -> array
  axis: (0, 1, 0),
  // Direction du point de latitude 0 et de longitude 0, projetée perpendiculairement à l'axe ; avec les
  // valeurs par défaut, le méridien de Greenwich fait face à l'observateur et l'est est à droite ->
  // array
  greenwich: (0, 0, 1),
  // Trace l'équateur -> bool
  show-equator: true,
  // Trace le méridien de Greenwich (demi-cercle de pôle à pôle) -> bool
  show-greenwich: true,
  // Trace les tropiques du Cancer et du Capricorne (latitudes ±23,44°) -> bool
  show-tropics: false,
  // Latitudes supplémentaires à tracer, en degrés, par exemple (30, -45) -> array
  parallels: (),
  // Longitudes supplémentaires à tracer, en degrés, par exemple (90, -120) -> array
  meridians: (),
  // Pas, en degrés, d'un quadrillage de parallèles et de méridiens (par exemple 30) ; none pour aucun
  // -> none | int | float
  graticule: none,
  // Trace l'axe sud-nord (en pointillés à l'intérieur de la sphère et derrière elle) -> bool
  show-axis: false,
  // Longueur dont l'axe dépasse chaque pôle, en fraction du rayon -> int | float
  axis-extension: 0.3,
  // Marque le centre de la sphère et celui de la section -> bool
  show-centers: false,
  // Points à placer : noms de villes de `globe-cities` ou dictionnaires (name:, lat:, lon:, color:,
  // label:, angles:) ; `angles: true` ajoute la construction des coordonnées du point, `angles: auto` la fait avec les valeurs numériques des angles -> array
  points: (),
  // Étiquette de l'angle de longitude ; auto : sa valeur en degrés -> auto | content
  lon-label: $theta$,
  // Étiquette de l'angle de latitude ; auto : sa valeur en degrés -> auto | content
  lat-label: $phi$,
  // Nombre de décimales des angles en mode auto -> int
  label-digits: 2,
  // Séparateur décimal des angles en mode auto : "," ou "." -> str
  label-decimal: ",",
  // Couleur de la construction des angles -> color
  angle-color: rgb("#8e44ad"),
  // Trait de l'équateur -> stroke
  equator-stroke: rgb("#c0392b") + 1pt,
  // Trait du méridien de Greenwich -> stroke
  greenwich-stroke: rgb("#2a9d4a") + 1pt,
  // Trait des tropiques -> stroke
  tropics-stroke: rgb("#e67e22") + 0.8pt,
  // Trait des parallèles et méridiens du quadrillage -> stroke
  grid-stroke: gray + 0.4pt,
  // Trait de l'axe sud-nord -> stroke
  axis-stroke: black + 0.8pt,
  // Noms des trois points qui définissent le plan, affichés en rouge (sans effet si le plan est donné
  // par une équation) -> none | array
  plane-names: none,
  // Étiquettes posées sur des ancres (clé = nom de l'ancre, valeur = contenu), par exemple (o: $O$, n: $N$) -> dictionary
  point-labels: (:),
  // Image à l'écran du vecteur unitaire de l'axe x (projection oblique) -> array
  x: (1, 0),
  // Image à l'écran du vecteur unitaire de l'axe y (projection oblique) -> array
  y: (0, 1),
  // Image à l'écran du vecteur unitaire de l'axe z, c'est-à-dire de la profondeur : par défaut (-0.5, -0.5), l'axe z pointe vers l'observateur -> array
  z: (-0.5, -0.5),
  // Tolérance numérique (distances) -> float
  eps: 1e-6,
  // Nombre de segments utilisés pour tracer un tour complet de cercle ou d'ellipse -> int
  per-turn: 144,
  // Commandes CeTZ supplémentaires dessinées dans le même canevas (elles peuvent utiliser les ancres)
  // -> content
  more: (),
  // Couleur du contour de la section -> color
  section-border: blue,
  // Remplissage de la section (en général semi-transparent) -> color
  section-fill: rgb(0, 102, 255, 35),
  // Style des traits cachés : valeur de `dash` d'un trait Typst ("dashed", "dotted", ...) ->
  // str | array | dictionary
  hidden-style: "dashed",
  // Échelle du dessin : longueur d'une unité du repère -> length
  length: 1cm,
) = {
  let pos = plane-args.pos()
  let R = radius
  let O = _p3(center)
  let N = _unit3(_p3(axis))
  let g0 = _p3(greenwich)
  let g1 = _sub3(g0, _mul3(_dot3(g0, N), N))
  let g = if _norm3(g1) > 1e-9 { _unit3(g1) } else { _frame(N).at(0) }
  let E = _cross3(N, g)  // direction de l'est (longitude +90°)
  let k = _view-k(x, y, z)
  let deg = calc.pi / 180

  let eqv(lon) = _lc((0, 0, 0), ((calc.cos(lon), g), (calc.sin(lon), E)))
  let surf(lat, lon) = _lc(O, ((R * calc.cos(lat), eqv(lon)), (R * calc.sin(lat), N)))

  // --- contour apparent --------------------------------------------------------
  let (k1, k2) = _frame(k)
  let edges = ()
  edges.push((
    pts: _arc-pts(th => _lc(O, ((R * calc.cos(th), k1), (R * calc.sin(th), k2))), 0, _tau, per-turn),
    vis: true,
  ))

  // --- parallèles et méridiens (latitudes / longitudes en degrés) -----------------
  let parallel(lat, st) = {
    let la = lat * deg
    let ct = calc.cos(la)
    if ct < 1e-9 { () } else {
      _sphere-curve(
        O, _lc(O, ((R * calc.sin(la), N),)), _mul3(R * ct, g), _mul3(R * ct, E),
        k, 0, _tau, st, hidden-style, per-turn,
      )
    }
  }
  let meridian(lon, st) = {
    _sphere-curve(
      O, O, _mul3(R, eqv(lon * deg)), _mul3(R, N),
      k, -calc.pi / 2, calc.pi / 2, st, hidden-style, per-turn,
    )
  }

  if graticule != none {
    let nlat = calc.floor((90 - 1e-9) / graticule)
    for i in range(1, nlat + 1) {
      edges += parallel(graticule * i, grid-stroke)
      edges += parallel(-graticule * i, grid-stroke)
    }
    if not show-equator { edges += parallel(0, grid-stroke) }
    let nlon = calc.floor(360 / graticule - 1e-9)
    for i in range(nlon + 1) {
      if i == 0 and show-greenwich { continue }
      edges += meridian(graticule * i, grid-stroke)
    }
  }
  for lat in parallels { edges += parallel(lat, grid-stroke) }
  for lon in meridians { edges += meridian(lon, grid-stroke) }
  if show-tropics {
    edges += parallel(23.44, tropics-stroke)
    edges += parallel(-23.44, tropics-stroke)
  }
  if show-equator { edges += parallel(0, equator-stroke) }
  if show-greenwich { edges += meridian(0, greenwich-stroke) }

  // --- axe sud-nord : caché à l'intérieur de la sphère et derrière elle ---------
  if show-axis {
    let ext = (1 + axis-extension) * R
    let nk = _dot3(N, k)
    let perp = calc.sqrt(calc.max(0, 1 - nk * nk))
    let br = (-R, R)
    if perp > 1e-9 { br += (-R / perp, R / perp) }
    let avis(s) = {
      let wk = s * nk
      if s * s < R * R { false } else if wk >= 0 { true } else { s * s - wk * wk >= R * R }
    }
    for ar in _split-lin(-ext, ext, br, avis) {
      edges.push((
        pts: (_lc(O, ((ar.a, N),)), _lc(O, ((ar.b, N),))),
        vis: ar.vis,
        stroke: if ar.vis { axis-stroke } else { _hidden-of(axis-stroke, hidden-style) },
      ))
    }
  }

  // --- section par un plan (facultative) ------------------------------------------
  let sec = ()
  let polys = ()
  let anchors = (
    ("o", O), ("n", _lc(O, ((R, N),))), ("s", _lc(O, ((-R, N),))), ("g", _lc(O, ((R, g),))),
  )
  let sc-pt = none
  if pos.len() > 0 {
    let pl = _parse-plane(pos)
    let ss = _sphere-section(O, R, pl.n, pl.d, k, eps, per-turn)
    sec = ss.sec
    polys = (ss.poly,)
    sc-pt = ss.sc
    if sc-pt != none { anchors.push(("sc", sc-pt)) }
  }

  // --- points (villes) et construction des angles ----------------------------------
  let dots = ()
  let texts = ()
  if show-centers {
    dots.push((O, black))
    if sc-pt != none { dots.push((sc-pt, section-border)) }
  }
  for (i, p0) in points.enumerate() {
    let p = _resolve-point(p0)
    let lat = p.lat * deg
    let lon = p.lon * deg
    let M = surf(lat, lon)
    let vis = _dot3(_sub3(M, O), k) > 1e-9
    anchors.push(("p" + str(i), M))
    if "name" in p and type(p.name) == str { anchors.push((p.name, M)) }
    dots.push((M, p.at("color", default: black), not vis))
    let lab = p.at("label", default: p.at("name", default: none))
    if vis and lab != none {
      texts.push((pos: M, body: lab, anchor: _away(M, O, x, y, z)))
    }

    let ang = p.at("angles", default: false)
    if ang == true or ang == auto {
      // étiquettes des angles : symboliques, ou valeurs numériques (angles: auto ou lon-label / lat-label: auto)
      let lonl = if ang == auto or lon-label == auto {
        _num-label(p.lon, label-digits, label-decimal == ",", none, suffix: "°", mark: false)
      } else { lon-label }
      let latl = if ang == auto or lat-label == auto {
        _num-label(p.lat, label-digits, label-decimal == ",", none, suffix: "°", mark: false)
      } else { lat-label }
      let ec = _lc(O, ((R, eqv(lon)),))  // projection de M sur l'équateur
      let G = _lc(O, ((R, g),))
      for (P, Q) in ((O, G), (O, ec), (O, M)) {
        if _norm3(_sub3(P, Q)) > 1e-9 {
          edges.push((pts: (P, Q), vis: true, stroke: angle-color + 0.7pt))
        }
      }
      let r-arc = 0.32 * R
      if calc.abs(lat) > 1e-9 {
        // latitude : arc de méridien sur la sphère, angle dans le plan du méridien
        edges.push((
          pts: (M, ec), vis: true,
          stroke: (paint: angle-color, thickness: 0.7pt, dash: "dotted"),
        ))
        edges += _sphere-curve(
          O, O, _mul3(R, eqv(lon)), _mul3(R, N), k, 0, lat,
          angle-color + 1.5pt, hidden-style, per-turn,
        )
        edges.push((
          pts: _arc-pts(t => _lc(O, ((r-arc * calc.cos(t), eqv(lon)), (r-arc * calc.sin(t), N))), 0, lat, per-turn),
          vis: true, stroke: angle-color + 0.9pt,
        ))
        texts.push((
          pos: _lc(O, ((1.55 * r-arc * calc.cos(lat / 2), eqv(lon)), (1.55 * r-arc * calc.sin(lat / 2), N))),
          body: text(fill: angle-color, latl), anchor: "center",
        ))
      }
      if calc.abs(lon) > 1e-9 {
        // longitude : arc d'équateur sur la sphère, angle dans le plan de l'équateur
        edges += _sphere-curve(
          O, O, _mul3(R, g), _mul3(R, E), k, 0, lon,
          angle-color + 1.5pt, hidden-style, per-turn,
        )
        edges.push((
          pts: _arc-pts(t => _lc(O, ((r-arc * calc.cos(t), g), (r-arc * calc.sin(t), E))), 0, lon, per-turn),
          vis: true, stroke: angle-color + 0.9pt,
        ))
        texts.push((
          pos: _lc(O, ((1.55 * r-arc * calc.cos(lon / 2), g), (1.55 * r-arc * calc.sin(lon / 2), E))),
          body: text(fill: angle-color, lonl), anchor: "center",
        ))
      }
      dots.push((ec, angle-color))
      dots.push((G, angle-color))
    }
  }

  _render(
    edges, sec, polys, anchors, dots, texts,
    _plane-points(pos), plane-names, point-labels, O,
    x, y, z, section-border, section-fill, hidden-style, more, length
  )
}
