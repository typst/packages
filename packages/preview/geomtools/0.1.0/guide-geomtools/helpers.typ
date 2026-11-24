// ---------------------------------------------------------------------------
//  Boîte à outils géométrique pour le guide geomtools.
//  Toutes les longueurs sont en centimètres, y vers le haut.
// ---------------------------------------------------------------------------
#import "@preview/geomtools:0.1.0": *

#let blue = rgb("#1864AB")
#let green = rgb("#2F9E44")
#let orange = rgb("#E8590C")
#let purple = rgb("#7048E8")
#let red = rgb("#C92A2A")
#let ink = rgb("#1B1B1B")
#let muted = luma(120)
#let paper = rgb("#F8F4EC")

#let A0 = (0.0, 0.0)
#let B0 = (7.2, 0.0)
#let C0 = (2.2, 4.8)

#let dotp(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1)
#let unit(v) = vmul(v, 1 / vnorm(v))
#let midp(a, b) = vmul(vadd(a, b), 0.5)
#let lerp(a, b, t) = vadd(a, vmul(vsub(b, a), t))

#let foot(P, A, B) = {
  let ab = vsub(B, A)
  let t = dotp(vsub(P, A), ab) / dotp(ab, ab)
  vadd(A, vmul(ab, t))
}

#let circ-inter(P, r1, Q, r2) = {
  let d = dist(P, Q)
  let a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
  let h = calc.sqrt(calc.max(0.0, r1 * r1 - a * a))
  let m = vadd(P, vmul(vsub(Q, P), a / d))
  let n = unit((-vsub(Q, P).at(1), vsub(Q, P).at(0)))
  (vadd(m, vmul(n, h)), vsub(m, vmul(n, h)))
}

#let line-inter(P1, P2, Q1, Q2) = {
  let r = vsub(P2, P1)
  let s = vsub(Q2, Q1)
  let den = r.at(0) * s.at(1) - r.at(1) * s.at(0)
  let qp = vsub(Q1, P1)
  let t = (qp.at(0) * s.at(1) - qp.at(1) * s.at(0)) / den
  vadd(P1, vmul(r, t))
}

#let circumcenter(A, B, C) = {
  let (ax, ay) = A
  let (bx, by) = B
  let (cx, cy) = C
  let d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
  let a2 = ax * ax + ay * ay
  let b2 = bx * bx + by * by
  let c2 = cx * cx + cy * cy
  (
    (a2 * (by - cy) + b2 * (cy - ay) + c2 * (ay - by)) / d,
    (a2 * (cx - bx) + b2 * (ax - cx) + c2 * (bx - ax)) / d,
  )
}

#let incenter(A, B, C) = {
  let a = dist(B, C)
  let b = dist(A, C)
  let c = dist(A, B)
  let p = a + b + c
  (
    (a * A.at(0) + b * B.at(0) + c * C.at(0)) / p,
    (a * A.at(1) + b * B.at(1) + c * C.at(1)) / p,
  )
}

#let centroid(A, B, C) = (
  (A.at(0) + B.at(0) + C.at(0)) / 3,
  (A.at(1) + B.at(1) + C.at(1)) / 3,
)

#let orthocenter(A, B, C) = {
  let Ha = foot(A, B, C)
  let Hb = foot(B, A, C)
  line-inter(A, Ha, B, Hb)
}

#let wrap180(d) = {
  let x = calc.rem(d / 1deg + 180.0, 360.0) - 180.0
  if x <= -180.0 { x += 360.0 }
  x * 1deg
}

#let ang-mark(V, P, Q, r: 0.42, stroke: ink, weight: 0.85) = {
  let a0 = vangle(vsub(P, V))
  let d = wrap180(vangle(vsub(Q, V)) - a0)
  p-arc(V, r, a0, a0 + d, stroke: stroke, weight: weight, role: "detail")
}

#let pt(P, fill: ink, r: 0.065) = p-circle(P, r, fill: fill, stroke: none, weight: 0)
#let lab(P, body, dx: 0, dy: 0, size: 10pt, fill: ink) = p-label(
  (P.at(0) + dx, P.at(1) + dy), body, size: size, fill: fill,
)

#let triangle(A, B, C, stroke: ink, weight: 1.35) = (
  p-line(A, B, stroke: stroke, weight: weight, role: "edge")
  + p-line(B, C, stroke: stroke, weight: weight, role: "edge")
  + p-line(C, A, stroke: stroke, weight: weight, role: "edge")
)

#let vertices(A, B, C) = (
  pt(A) + pt(B) + pt(C)
  + lab(A, [$A$], dx: -0.28, dy: -0.30)
  + lab(B, [$B$], dx: 0.28, dy: -0.30)
  + lab(C, [$C$], dy: 0.34)
)

#let line-ext(P, Q, beyond: 0.85, stroke: muted, weight: 0.75, dash: "dashed") = {
  let u = unit(vsub(Q, P))
  p-line(
    vsub(P, vmul(u, beyond)),
    vadd(Q, vmul(u, beyond)),
    stroke: stroke, weight: weight, dash: dash, role: "edge",
  )
}

#let ray(P, Q, extra: 1.1, stroke: muted, weight: 0.75, dash: "dashed") = {
  let u = unit(vsub(Q, P))
  p-line(P, vadd(Q, vmul(u, extra)), stroke: stroke, weight: weight, dash: dash, role: "edge")
}

/// Traits de codage d'égalité, au milieu de [PQ].
#let ticks(P, Q, n: 1, stroke: ink, span: 0.15, gap: 0.11) = {
  let m = midp(P, Q)
  let u = unit(vsub(Q, P))
  let nv = (-u.at(1), u.at(0))
  let out = ()
  for i in range(n) {
    let c = vadd(m, vmul(u, (i - (n - 1) / 2) * gap))
    out += p-line(
      vadd(c, vmul(nv, span)),
      vsub(c, vmul(nv, span)),
      stroke: stroke, weight: 0.95, role: "detail",
    )
  }
  out
}

#let square-on(at-pt, along, toward, length: 4.2, colour: luma(70)) = {
  let ang = vangle(along)
  let perp = (-along.at(1), along.at(0))
  let flip = dotp(perp, toward) < 0
  set-square(
    at: at-pt, rotate: ang, length: length, clamp: false,
    values: false, ticks: true, flip: flip, colour: colour, border: 1.15,
  )
}

/// Carré d'angle droit tourné vers `toward` (l'intérieur du triangle).
#let ra-in(at-pt, along, toward, size: 0.28, colour: ink) = {
  let a = vangle(along)
  let perp = (-along.at(1), along.at(0))
  let rot = if dotp(perp, toward) >= 0 { a } else { a - 90deg }
  right-angle(at: at-pt, rotate: rot, size: size, colour: colour)
}

#let farther(from, p, q) = if dist(from, p) >= dist(from, q) { p } else { q }

/// Arc de `p` à `q` vu de `center`, débordant de `extra` de chaque côté.
#let arc-through(center, p, q, extra: 30deg, stroke: muted, weight: 0.8) = {
  let a0 = vangle(vsub(p, center))
  let d = wrap180(vangle(vsub(q, center)) - a0)
  let e = if d >= 0deg { extra } else { -extra }
  p-arc(center, dist(center, p), a0 - e, a0 + d + e,
    stroke: stroke, weight: weight, dash: "dashed", role: "edge")
}

/// Arc centré en `center` qui s'arrête sur `through` (bout = mine du compas).
#let arc-to(center, through, back: 70deg, extra: 0deg, stroke: muted, weight: 0.8) = {
  let a = vangle(vsub(through, center))
  p-arc(center, dist(center, through), a - back, a + extra,
    stroke: stroke, weight: weight, dash: "dashed", role: "edge")
}

/// Les 3 arcs d'une bissectrice : sommet, puis les deux arcs égaux qui se coupent en R.
#let bisector-three-arcs(V, P, Q, R, rV, rS, stroke: muted) = (
  arc-through(V, P, Q, extra: 10deg, stroke: stroke, weight: 0.7)
  + arc-to(P, R, back: 50deg, extra: 18deg, stroke: stroke, weight: 0.75)
  + arc-to(Q, R, back: 65deg, extra: 6deg, stroke: stroke, weight: 0.75)
)

/// Deux tildes identiques au milieu de [PQ] — même codage sur OA, OB, OC.
#let waves(P, Q, n: 2, stroke: blue, amp: 0.08, width: 0.28, gap: 0.22) = {
  let m = midp(P, Q)
  let u = unit(vsub(Q, P))
  let nv = (-u.at(1), u.at(0))
  let out = ()
  for i in range(n) {
    let c = vadd(m, vmul(u, (i - (n - 1) / 2) * gap))
    let pt(s, t) = vadd(c, vadd(vmul(u, s), vmul(nv, t)))
    // un ~ : bas — haut — bas — haut
    out += p-poly(
      (pt(-width, -0.3 * amp), pt(-0.5 * width, amp),
       pt(0.5 * width, -amp), pt(width, 0.3 * amp)),
      closed: false, stroke: stroke, weight: 1.15, role: "detail",
    )
  }
  out
}

/// Crayon dont la mine est en `to`, le long du trait `from → to`.
#let pencil-tip(from, to, colour: rgb("#D62828"), lead: auto, length: 4.0, scale: 0.8) = {
  let a = vangle(vsub(to, from))
  pencil(at: to, rotate: a - 90deg, length: length, colour: colour, lead: lead, scale: scale)
}

#let abc-figure(A, B, C) = triangle(A, B, C) + vertices(A, B, C)
