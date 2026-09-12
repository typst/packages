// ===========================================================================
//  geomtools/tools.typ — the instruments.
//
//  A port of Cédric Pierquet's `OutilsGeomTikZ` (LPPL 1.3c): the drawing
//  instruments a maths teacher puts on a figure — pen, ruler, set square,
//  protractor, compass.
//
//  Each tool is a FUNCTION RETURNING GEOMETRY, never content. The renderer in
//  canvas.typ then draws that geometry crisp or hand-drawn. Describing a tool
//  twice — once per mode — would guarantee the two drift apart.
//
//  The French key names of the original map to English ones here; the
//  measurements, proportions and graduation patterns are the original's.
// ===========================================================================

#import "canvas.typ": *

// ---------------------------------------------------------------------------
//  placement
// ---------------------------------------------------------------------------

/// Apply a tool's `at` / `rotate` / `scale` to a primitive list.
#let placed(prims, at: (0, 0), rotate: 0deg, scale: 1.0, flip-y: false) = {
  let T(p) = xform(p, at: at, rot: rotate, scale: scale, flip-y: flip-y)
  prims.map(c => {
    let k = c.kind
    if k == "poly" {
      c + (pts: c.pts.map(T))
    } else if k == "circle" {
      c + (centre: T(c.centre), r: c.r * scale)
    } else if k == "arc" {
      // a mirrored arc runs the other way round
      let (a0, a1) = if flip-y { (-c.a1, -c.a0) } else { (c.a0, c.a1) }
      c + (centre: T(c.centre), r: c.r * scale, a0: a0 + rotate,
           a1: a1 + rotate)
    } else if k == "label" {
      c + (pos: T(c.pos), size: c.size * scale,
           rotate: c.rotate + rotate)
    } else { c }
  })
}

// ---------------------------------------------------------------------------
//  the pencil — \tkzCrayon
// ---------------------------------------------------------------------------

/// A pencil, tip at the origin, pointing up.
///
///   length   the whole pencil, in cm (the original clamps to 2.5 minimum)
#let pencil(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  length: 5.0,
  colour: rgb("#D62828"),
  wood: rgb("#D9B98B"),
  ferrule: black,
  // LA MINE A SA PROPRE COULEUR. Un crayon de couleur a une mine assortie
  // à son corps, et c'est ce qu'on veut quand on pose trois crayons côte à
  // côte. `auto` garde le graphite noir du crayon à papier — le défaut ne
  // change donc pas — et `lead: colour` suffit à assortir la mine au fût.
  lead: auto,
) = {
  let lead-colour = if lead == auto { black } else { lead }
  let L = calc.max(2.5, length)
  let out = ()
  // barrel
  out += p-poly(
    ((-0.2, L - 0.3), (0.2, L - 0.3), (0.2, 0.8), (0.1, 0.65), (0, 0.8),
     (-0.1, 0.66), (-0.2, 0.8)),
    fill: colour.lighten(25%), stroke: colour.darken(15%), weight: 0.8)
  // the white highlight down the barrel
  out += p-line((0, L - 0.3), (0, 0.6), stroke: white, weight: 1.6,
    role: "detail")
  // ferrule / end cap
  out += p-poly(
    ((-0.2, L - 0.6), (0, L - 0.65), (0.2, L - 0.6), (0.2, L - 0.12),
     (-0.2, L - 0.12)),
    fill: ferrule, stroke: ferrule, weight: 0.6)
  // the sharpened wood cone
  out += p-poly(
    ((-0.2, 0.8), (0, 0), (0.2, 0.8), (0.1, 0.65), (0, 0.8), (-0.1, 0.66)),
    fill: wood, stroke: wood.darken(25%), weight: 0.7)
  // LA MINE DOIT TENIR DANS LE BOIS DONT ELLE SORT.
  //
  // Elle valait `((-0.14, 0.24), (0, 0), (0.14, 0.24))` : le x était pris à
  // 70 % de la demi-largeur du cône (0,7 × 0,2 = 0,14) et le y à 30 % de sa
  // hauteur (0,3 × 0,8 = 0,24) — DEUX fractions différentes mélangées. Or à
  // y = 0,24 le cône ne fait que 0,2 × 0,24/0,8 = 0,06 de demi-largeur : la
  // mine était 2,3 fois trop large et débordait de 0,8 mm de chaque côté,
  // en chapeau noir posé sur la pointe. Mesuré sur le rendu à 300 ppi : la
  // silhouette passait de 17 à 34 px en DESCENDANT, ce qui est impossible
  // sur un cône.
  //
  // Une seule fraction, donc : la mine est le cône lui-même tronqué, et ses
  // flancs sont exactement ceux du bois. 0,36 comparé au rendu contre 0,30
  // (mine trop maigre) et 0,42 (trop longue) — c'est la proportion d'un
  // crayon taillé.
  let tip = 0.36
  out += p-poly(((-0.2 * tip, 0.8 * tip), (0, 0), (0.2 * tip, 0.8 * tip)),
    fill: lead-colour, stroke: lead-colour, weight: 0.6)
  placed(out, at: at, rotate: rotate, scale: scale)
}

/// A pencil whose tip sits at `to`, pointing along `from → to`.
///
/// `pencil` itself has its tip at the origin, pointing up. This helper
/// rotates it so the lead lands on the end of a stroke.
#let pencil-tip(
  from,
  to,
  colour: rgb("#D62828"),
  lead: auto,
  length: 4.0,
  scale: 0.8,
) = {
  let a = vangle(vsub(to, from))
  pencil(at: to, rotate: a - 90deg, length: length, colour: colour,
    lead: lead, scale: scale)
}

// ---------------------------------------------------------------------------
//  the ruler — \tkzRegle
// ---------------------------------------------------------------------------

/// A ruler with its zero at the origin, running right along the x axis.
///
///   length / width   in cm (clamped to 3 and 1.5, as the original does)
///   values           "h" above, "m" middle, "b" upside-down along the bottom
#let ruler(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  length: 12.0,
  width: 1.5,
  colour: black,
  fill: none,
  opacity: 50%,
  ticks: true,
  values: true,
  value-pos: "m",
  value-size: 0.8,
  // Le rayon des coins, en fraction de la largeur. 0 = coins vifs.
  corner: 0.12,
  // Applique les minimums de l'original (longueur 3, largeur 1,5).
  clamp: true,
) = {
  let L = calc.max(3.0, length)
  // LE PLANCHER DE LARGEUR EST CELUI DE L'ORIGINAL, MAIS IL SE LÈVE.
  //
  // `width` était ramené à 1,5 en silence : demander une règle fine donnait
  // une règle de 1,5, sans le dire, et l'écart se payait au placement — une
  // règle censée affleurer une équerre s'en trouvait à 20 pt. Le plancher
  // reste (il vient de `tkz-euclide` et convient à une règle isolée), mais
  // `clamp: false` le lève pour qui sait ce qu'il fait.
  let W = if clamp { calc.max(1.5, width) } else { calc.max(0.05, width) }
  let show-values = values and ticks
  let out = ()

  // LES BOUTS : UN COIN ARRONDI, PAS UNE GÉLULE.
  //
  // Les deux extrémités étaient des arcs de 120° de rayon ≈ W/2, c'est-à-dire
  // des demi-disques : la règle avait la silhouette d'une gélule. Une vraie
  // règle a des angles simplement ADOUCIS. `corner` est le rayon de cet
  // arrondi, en fraction de la largeur ; il vaut 0 pour un bout carré et se
  // plafonne à la moitié de la largeur, au-delà de quoi les deux arrondis se
  // rejoignent et l'on retombe sur le demi-disque.
  let r = calc.min(corner * W, W / 2)
  let x0 = -0.375
  let x1 = L + 0.375
  let quart(cx, cy, a0, a1) = if r <= 0 { () } else {
    arc-pts((cx, cy), r, a0, a1, steps: 6)
  }
  // À `corner: 0` les arcs disparaissent et les quatre coins sont des points
  // simples : le contour doit alors compter EXACTEMENT quatre sommets, sans
  // doublon — un point répété se voit au tracé (jointure épaissie) et fausse
  // tout test qui compte les sommets.
  let outline = if r <= 0 {
    ((x0, 0), (x1, 0), (x1, -W), (x0, -W))
  } else {
    let o = ((x0 + r, 0), (x1 - r, 0))
    let o2 = o + quart(x1 - r, -r, 90deg, 0deg)
    let o3 = o2 + ((x1, -W + r),)
    let o4 = o3 + quart(x1 - r, -W + r, 0deg, -90deg)
    let o5 = o4 + ((x0 + r, -W),)
    let o6 = o5 + quart(x0 + r, -W + r, -90deg, -180deg)
    let o7 = o6 + ((x0, -r),)
    o7 + quart(x0 + r, -r, 180deg, 90deg)
  }

  out += p-poly(outline, fill: if fill == none { none } else { fill },
    stroke: colour, weight: 1.0)
  // the hanging hole
  out += p-circle((0.5, -W / 2), 0.125 * W, stroke: colour, weight: 1.0)

  if ticks {
    // three graduation depths, exactly as the original: 0.25 / 0.375 / 0.5
    let n = int(L * 10)
    for i in range(n + 1) {
      let x = i / 10
      let d = if calc.rem(i, 10) == 0 { 0.5 }
              else if calc.rem(i, 5) == 0 { 0.375 } else { 0.25 }
      out += p-line((x, 0), (x, -d), stroke: colour, weight: 0.5)
      out += p-line((x, -W), (x, -W + d), stroke: colour, weight: 0.5)
    }
  }

  if show-values {
    let n = int(L)
    for i in range(n + 1) {
      if value-pos.contains("h") {
        out += p-label((i, -0.62), [#i],
          size: 6pt * value-size / 0.8, fill: colour)
      }
      if value-pos.contains("m") {
        out += p-label((i, -W / 2), [#i],
          size: 6pt * value-size / 0.8, fill: colour)
      }
      if value-pos.contains("b") {
        out += p-label((i, -W + 0.38), std.rotate(180deg)[#(n - i)],
          size: 6pt * value-size / 0.8, fill: colour)
      }
    }
  }
  placed(out, at: at, rotate: rotate, scale: scale)
}

// ---------------------------------------------------------------------------
//  the set square — \tkzEquerre
// ---------------------------------------------------------------------------

/// A 30-60-90 set square, right angle at the origin.
///
/// The original derives the base from the height: width = length * tan(30).
#let set-square(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  length: 10.0,
  colour: black,
  fill: none,
  opacity: 50%,
  ticks: true,
  values: true,
  border: 1.0,
  value-size: 0.8,
  // RETOURNER L'ÉQUERRE, l'angle droit passant d'un côté à l'autre.
  //
  // Une équerre est un objet physique : on la retourne sur la table. Sans
  // cela il faudrait la tourner de 180°, ce qui met le sommet en bas — ce
  // n'est pas le même geste, et la graduation ne tombe plus sur la droite
  // qu'on suit. `compass` a déjà ce `flip` ; l'équerre en a autant besoin.
  flip: false,
  // Applique le minimum de longueur de l'original (4,5 cm).
  //
  // Comme pour `ruler`, ce plancher s'appliquait EN SILENCE : demander une
  // équerre de 3,6 en donnait une de 4,5, et tout placement calculé sur la
  // longueur demandée se trouvait faux de la différence — 3 mm ici, ce qui
  // décollait la règle censée l'affleurer.
  clamp: true,
) = {
  let L = if clamp { calc.max(4.5, length) } else { calc.max(0.1, length) }
  let W = L * calc.tan(30deg)
  let b = if ticks { border * 0.2 * W } else { W / 5 }
  let out = ()

  let outer = ((0, 0), (W, 0), (0, L))
  let inner = (
    (b, b),
    (W - b * calc.sqrt(3), b),
    (b, L - b * (2 + calc.sqrt(3))),
  )

  if fill != none {
    // even-odd, so the middle is a hole rather than a slab
    out += ((kind: "poly", pts: outer, closed: true, fill: fill,
             stroke: none, weight: 0, role: "fill"),)
    out += ((kind: "poly", pts: inner, closed: true, fill: white,
             stroke: none, weight: 0, role: "fill"),)
  }
  out += p-poly(outer, stroke: colour, weight: 1.0)
  out += p-poly(inner, stroke: colour, weight: 1.0)

  if ticks {
    // along the base, clipped to the triangle at 92.5% as the original does
    let lim = 0.925 * W
    let n = int(lim * 10)
    for i in range(1, n + 1) {
      let x = i / 10
      if x > lim { break }
      let d = if calc.rem(i, 10) == 0 { 0.3 }
              else if calc.rem(i, 5) == 0 { 0.3 } else { 0.2 }
      out += p-line((x, 0), (x, d), stroke: colour, weight: 0.5)
    }
    // up the vertical leg
    let lim2 = 0.925 * L
    let m = int(lim2 * 10)
    for i in range(1, m + 1) {
      let y = i / 10
      if y > lim2 { break }
      let d = if calc.rem(i, 10) == 0 { 0.3 }
              else if calc.rem(i, 5) == 0 { 0.3 } else { 0.2 }
      out += p-line((0, y), (d, y), stroke: colour, weight: 0.5)
    }
  }

  if values and ticks {
    for i in range(1, int(0.9 * W) + 1) {
      out += p-label((i, 0.45), [#i],
        size: 6pt * value-size / 0.8, fill: colour)
    }
    for i in range(1, int(0.9 * L) + 1) {
      out += p-label((0.45, i), [#i],
        size: 6pt * value-size / 0.8, fill: colour)
    }
  }
  placed(out, at: at, rotate: rotate, scale: scale, flip-y: flip)
}

/// A small plain set square — \tkzMiniEquerre. No graduations, just the
/// right-angle corner; for marking a perpendicular on a diagram.
// ---------------------------------------------------------------------------
//  the right-angle mark
// ---------------------------------------------------------------------------

/// The right-angle mark: the small open square drawn INSIDE an angle.
///
/// This is a piece of NOTATION, not an instrument — which is why it is not
/// `mini-square`. That one is a small set square, a physical tool with a
/// hypotenuse; using it to code a right angle draws a visible diagonal
/// across the corner, which is wrong. The mark is two segments and no
/// hypotenuse: it must stay open.
///
///   at      the vertex of the angle
///   rotate  the direction of the first arm
///   size    the side of the square, in cm
///
/// The two arms are drawn as ONE open polyline, so the corner is a single
/// mitred join rather than two strokes crossing at their ends.
#let right-angle(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  size: 0.32,
  colour: black,
  weight: 0.9,
  fill: none,
) = {
  let out = ()
  if fill != none {
    out += p-poly(((0, 0), (size, 0), (size, size), (0, size)),
      fill: fill, stroke: none, weight: 0)
  }
  out += p-poly(((size, 0), (size, size), (0, size)),
    closed: false, stroke: colour, weight: weight, role: "edge")
  placed(out, at: at, rotate: rotate, scale: scale)
}

#let mini-square(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  colour: black,
  shade: true,
) = {
  let out = ()
  if shade {
    out += p-poly(((0, 0), (1, 0), (1, 0.088), (0, 0.088)),
      fill: colour.lighten(90%), stroke: none, weight: 0)
    out += p-poly(((0, 0), (0.088, 0), (0.088, 2), (0, 2)),
      fill: colour.lighten(90%), stroke: none, weight: 0)
  }
  out += p-poly(((0, 0), (1, 0), (0, 1.8)), stroke: colour, weight: 0.9)
  placed(out, at: at, rotate: rotate, scale: scale)
}

/// A small plain ruler — \tkzMiniRegle.
#let mini-ruler(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  colour: black,
  shade: true,
) = {
  let out = ()
  if shade {
    out += p-poly(rect-pts((0, 0), (2, -0.088)),
      fill: colour.lighten(90%), stroke: none, weight: 0)
  }
  out += p-poly(rect-pts((0, 0), (2, -0.3)), stroke: colour, weight: 0.9)
  out += p-circle((0.35, -0.185), 0.05, stroke: colour, weight: 0.8)
  for i in range(21) {
    let x = i / 10
    let d = if calc.rem(i, 5) == 0 { 0.07 } else { 0.053 }
    out += p-line((x, 0), (x, -d), stroke: colour, weight: 0.5)
  }
  placed(out, at: at, rotate: rotate, scale: scale)
}

// ---------------------------------------------------------------------------
//  the graduated square — \tkzRequerre
// ---------------------------------------------------------------------------

/// A rectangular "ruler-square": a ruler with a graduated short edge.
#let ruler-square(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  length: 12.0,
  width: 3.0,
  colour: black,
  fill: none,
  ticks: true,
  values: true,
  value-size: 0.8,
) = {
  let L = calc.max(3.0, length)
  let W = calc.max(1.5, width)
  let out = ()
  out += p-poly(rect-pts((0, 0), (L, -W)),
    fill: fill, stroke: colour, weight: 1.0)
  if ticks {
    let n = int(L * 10)
    for i in range(n + 1) {
      let x = i / 10
      let d = if calc.rem(i, 10) == 0 { 0.5 }
              else if calc.rem(i, 5) == 0 { 0.375 } else { 0.25 }
      out += p-line((x, 0), (x, -d), stroke: colour, weight: 0.5)
    }
    let m = int(W * 10)
    for i in range(m + 1) {
      let y = i / 10
      let d = if calc.rem(i, 10) == 0 { 0.5 }
              else if calc.rem(i, 5) == 0 { 0.375 } else { 0.25 }
      out += p-line((0, -y), (d, -y), stroke: colour, weight: 0.5)
    }
  }
  if values and ticks {
    for i in range(int(L) + 1) {
      out += p-label((i, -0.68), [#i],
        size: 6pt * value-size / 0.8, fill: colour)
    }
    for i in range(1, int(W) + 1) {
      out += p-label((0.68, -i), [#i],
        size: 6pt * value-size / 0.8, fill: colour)
    }
  }
  placed(out, at: at, rotate: rotate, scale: scale)
}

// ---------------------------------------------------------------------------
//  the protractor — \tkzRapporteur
// ---------------------------------------------------------------------------

/// A protractor, centred on the origin.
///
/// Follows the original's radii exactly: outer 3.75, inner 2.5, degree ticks
/// down to 3.55 / 3.45 / 3.35, and the radian band between 2.5 and 3.1.
#let protractor(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  colour: black,
  fill: none,
  full: false,          // true = the whole 360 disc
  angles: true,         // the numerals
  ticks: true,
  radians: true,        // the pi/6, pi/4 ... band
  value-size: 0.8,
  angle-size: 1.0,
) = {
  let out = ()
  let R = 3.75
  let r = 2.5
  // `value-size` est une FRACTION DE LA TAILLE D'ORIGINE, dont la valeur
  // neutre est 0,8 — comme pour la règle et l'équerre. Sans le `/ 0.8`, la
  // taille par défaut ne rendrait pas les 5 pt de l'original.
  let vs = 5pt * value-size / 0.8 * angle-size

  let (a0, a1) = if full { (0deg, 360deg) } else { (0deg, 180deg) }

  if fill != none {
    out += p-arc((0, 0), R, a0, a1, wedge: not full, fill: fill,
      stroke: none, weight: 0)
  }
  // the two rims and the base line
  if full {
    out += p-circle((0, 0), R, stroke: colour, weight: 1.0)
    out += p-circle((0, 0), r, stroke: colour, weight: 1.0)
    out += p-line((-r, 0), (r, 0), stroke: colour, weight: 1.0)
    out += p-line((0, -r), (0, r), stroke: colour, weight: 1.0)
  } else {
    out += p-arc((0, 0), R, 0deg, 180deg, stroke: colour, weight: 1.0)
    out += p-arc((0, 0), r, 0deg, 180deg, stroke: colour, weight: 1.0)
    out += p-line((-R, 0), (R, 0), stroke: colour, weight: 1.0)
  }

  if ticks {
    let hi = if full { 360 } else { 180 }
    for d in range(hi + 1) {
      let inner = if calc.rem(d, 10) == 0 { 3.35 }
                  else if calc.rem(d, 5) == 0 { 3.45 } else { 3.55 }
      let a = d * 1deg
      out += p-line((inner * calc.cos(a), inner * calc.sin(a)),
        (R * calc.cos(a), R * calc.sin(a)), stroke: colour,
        weight: if calc.rem(d, 10) == 0 { 0.6 } else { 0.4 })
    }
    if radians {
      for d in (0, 30, 45, 60, 90, 120, 135, 150, 180) {
        if not full and d > 180 { continue }
        let a = d * 1deg
        out += p-line((2.5 * calc.cos(a), 2.5 * calc.sin(a)),
          (2.65 * calc.cos(a), 2.65 * calc.sin(a)), stroke: colour,
          weight: 0.5)
        out += p-line((2.9 * calc.cos(a), 2.9 * calc.sin(a)),
          (3.1 * calc.cos(a), 3.1 * calc.sin(a)), stroke: colour,
          weight: 0.5)
      }
    }
  }

  if angles {
    // degrees, every 10, set radially like a real protractor
    for d in range(0, 181, step: 10) {
      let a = d * 1deg
      out += p-label((3.25 * calc.cos(a), 3.25 * calc.sin(a)),
        [#d], size: vs, fill: colour,
        rotate: a - 90deg)
    }
    if radians {
      let frac = (
        (30, $pi/6$), (45, $pi/4$), (60, $pi/3$), (90, $pi/2$),
        (120, $2pi/3$), (135, $3pi/4$), (150, $5pi/6$),
      )
      for (d, lab) in frac {
        let a = d * 1deg
        out += p-label((2.75 * calc.cos(a), 2.75 * calc.sin(a)),
          lab, size: vs * 0.92, fill: colour,
          rotate: a - 90deg)
      }
      out += p-label((2.75, 0), [$0$], size: vs * 0.92,
        fill: colour, rotate: -90deg)
      out += p-label((-2.75, 0), [$plus.minus pi$],
        size: vs * 0.92, fill: colour, rotate: -90deg)
    }
  }
  placed(out, at: at, rotate: rotate, scale: scale)
}

/// The percent dial — \tkzPourcenteur. The same disc graduated 0..100.
#let percent-dial(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  colour: black,
  fill: none,
  values: true,
  value-size: 0.8,
) = {
  let out = ()
  let R = 3.75
  let r = 2.5
  if fill != none {
    out += p-circle((0, 0), R, fill: fill, stroke: none, weight: 0)
  }
  out += p-circle((0, 0), R, stroke: colour, weight: 1.0)
  out += p-circle((0, 0), r, stroke: colour, weight: 1.0)
  // 100 divisions, every 5th and 10th longer
  for i in range(100) {
    let a = 90deg - i * 3.6deg
    let inner = if calc.rem(i, 10) == 0 { 3.35 }
                else if calc.rem(i, 5) == 0 { 3.45 } else { 3.55 }
    out += p-line((inner * calc.cos(a), inner * calc.sin(a)),
      (R * calc.cos(a), R * calc.sin(a)), stroke: colour,
      weight: if calc.rem(i, 10) == 0 { 0.6 } else { 0.4 })
  }
  if values {
    for i in range(0, 100, step: 10) {
      let a = 90deg - i * 3.6deg
      out += p-label((3.15 * calc.cos(a), 3.15 * calc.sin(a)),
        [#i], size: 5pt * value-size / 0.8, fill: colour,
        rotate: a - 90deg)
    }
  }
  placed(out, at: at, rotate: rotate, scale: scale)
}

/// The protractor-square — \tkzRappEquerre: a half-disc protractor sitting on
/// a straight graduated edge.
#let protractor-square(
  at: (0, 0),
  rotate: 0deg,
  scale: 1.0,
  width: 6.0,
  colour: black,
  fill: none,
  angles: true,
  values: true,
  value-size: 1.0,
) = {
  let W = calc.max(4.0, width)
  let R = W / 2
  let out = ()
  let body = ((-R, 0), (R, 0)) + arc-pts((0, 0), R, 0deg, 180deg, steps: 48)
  if fill != none {
    out += ((kind: "poly", pts: body, closed: true, fill: fill,
             stroke: none, weight: 0, role: "fill"),)
  }
  out += p-poly(body, stroke: colour, weight: 1.0)
  // degree ticks around the arc
  for d in range(181) {
    let a = d * 1deg
    let inner = if calc.rem(d, 10) == 0 { R - 0.4 }
                else if calc.rem(d, 5) == 0 { R - 0.3 } else { R - 0.2 }
    out += p-line((inner * calc.cos(a), inner * calc.sin(a)),
      (R * calc.cos(a), R * calc.sin(a)), stroke: colour,
      weight: if calc.rem(d, 10) == 0 { 0.6 } else { 0.4 })
  }
  if angles {
    // Les chiffres sont plus petits que la base d'origine (5 pt) : deux
    // couronnes de nombres dans un demi-disque de 6 cm se touchaient près de
    // l'horizontale, là où les rayons convergent. 4 pt laisse la place aux
    // deux lectures sans les tasser.
    let num = 4pt * value-size
    // LA DOUBLE GRADUATION, ET LE SENS DE LECTURE.
    //
    // Relevé sur le source de `OutilsGeomTikZ` (`tkzRapporteurEquerre`),
    // dont ce paquet est le portage :
    //
    //     \foreach \i in {10,20,...,170}
    //       (-\i : 0.6125*L) node[rotate={90-\i}] {\i}
    //       (-\i : 0.6375*L) node[rotate={90-\i}] {180-\i}
    //
    // Trois choses en découlent, qui manquaient toutes :
    //
    //   * DEUX séries de chiffres, `d` et `180 - d`, sur deux rayons
    //     voisins — un rapporteur se lit dans les deux sens, et c'est
    //     précisément ce dont on se sert pour reporter un angle depuis
    //     l'un ou l'autre côté ;
    //   * la rotation vaut `90° - d`, et non `d - 90°` : les deux diffèrent
    //     de 180°, si bien que les chiffres étaient tête-bêche ;
    //   * la plage va de 10 à 170 — le 0 et le 180 sont portés par la
    //     réglette du bas, pas par la couronne.
    // QUELLE SÉRIE VA DEHORS. La couronne EXTÉRIEURE est celle qu'on lit en
    // premier, et elle part de 0 à DROITE : à l'angle `d`, elle porte donc
    // `d` lui-même (10 tout à droite, 170 tout à gauche), et la couronne
    // intérieure porte le complément `180 - d`. C'était l'inverse ici, si
    // bien qu'un rapporteur posé à plat se lisait à rebours du geste
    // habituel — poser le zéro sur le côté droit de l'angle.
    for d in range(10, 171, step: 10) {
      let a = d * 1deg
      let r-lab = 90deg - a
      // Les deux couronnes sont ÉCARTÉES : deux séries trop proches se
      // croisent près de l'horizontale. Le LaTeX les met à 0,6125·L et
      // 0,6375·L du centre, soit un écart de 4 % du rayon ; ici on prend
      // 0,62 (dehors) et 1,08 (dedans) depuis le bord — la couronne
      // extérieure passe SOUS les graduations, qui descendent jusqu'à
      // R − 0,4 : plus haut, les chiffres mordraient sur les traits.
      out += p-label(((R - 0.62) * calc.cos(a), (R - 0.62) * calc.sin(a)),
        [#d], size: num, fill: colour,
        rotate: r-lab)
      out += p-label(((R - 1.08) * calc.cos(a), (R - 1.08) * calc.sin(a)),
        [#(180 - d)], size: num, fill: colour,
        rotate: r-lab)
    }
  }
  // the graduated straight edge
  if values {
    let n = int(R * 10)
    for i in range(-n, n + 1) {
      let x = i / 10
      let d = if calc.rem(i, 10) == 0 { 0.28 }
              else if calc.rem(i, 5) == 0 { 0.2 } else { 0.13 }
      out += p-line((x, 0), (x, d), stroke: colour, weight: 0.4)
    }
  }
  placed(out, at: at, rotate: rotate, scale: scale)
}

// ---------------------------------------------------------------------------
//  the compass — \tkzCompas
// ---------------------------------------------------------------------------

/// A pair of compasses, spanning from `from` to `to`.
///
/// The original opens the legs to exactly match the span:
///     half-angle = asin(|from - to| / (2 * leg))
/// so the instrument really does reach from one point to the other.
#let compass(
  from,
  to,
  scale: 1.0,
  leg: 6.0,
  pencil-length: 5.0,
  pencil-scale: 1.0,
  pencil-colour: rgb("#D62828"),
  // La mine du crayon du compas, comme celle de `pencil`. Sans ce relais,
  // l'option s'arrêterait à mi-chemin : on pourrait colorer un crayon posé
  // sur la figure mais pas celui qui trace l'arc.
  pencil-lead: auto,
  colour: luma(128),
  show-pencil: true,
  flip: false,
) = {
  let span = dist(from, to)
  let a = vangle(vsub(to, from))
  // the legs cannot open wider than they are long
  let ratio = calc.min(1.0, span / (2 * leg * scale))
  let half = calc.asin(ratio)
  let sgn = if flip { -1.0 } else { 1.0 }

  let out = ()
  // Both legs hinge at the top. Build the instrument in its own frame with
  // the NEEDLE FOOT at the origin, so placing it is a plain rotate-about-the-
  // needle: rotating about the hinge instead swings the foot away from the
  // point it is supposed to be standing on.
  let rot-about-hinge(p, s) = {
    let (co, si) = (calc.cos(s), calc.sin(s))
    (p.at(0) * co - (p.at(1) - leg) * si,
     leg + p.at(0) * si + (p.at(1) - leg) * co)
  }
  // where each foot lands once the legs are opened
  let foot-n = rot-about-hinge((0, 0), -half)
  let foot-p = rot-about-hinge((0, 0), half)
  // shift everything so the needle foot sits at (0, 0)
  let O(p) = (p.at(0) - foot-n.at(0), p.at(1) - foot-n.at(1))

  let leg-poly(sign) = {
    let s = sign * half
    ((0, leg), (0, 0), (sign * 0.2, 0.8), (sign * 0.2, leg))
      .map(q => O(rot-about-hinge(q, s)))
  }

  // needle leg, then pencil leg
  out += p-poly(leg-poly(-1), fill: colour.lighten(20%), stroke: colour,
    weight: 0.9)
  out += p-poly(leg-poly(1), fill: colour.lighten(20%), stroke: colour,
    weight: 0.9)

  // the head sits on the hinge
  let hinge = O((0, leg))
  out += p-poly(rect-pts((hinge.at(0) - 0.1, hinge.at(1)),
                         (hinge.at(0) + 0.1, hinge.at(1) + 0.85)),
    fill: colour.lighten(20%), stroke: colour, weight: 0.8)
  out += p-circle(hinge, 0.25, fill: luma(220), stroke: colour, weight: 0.8)
  out += p-circle(hinge, 0.05, fill: colour.darken(30%), stroke: none,
    weight: 0)

  // the pencil, clamped to the far leg and pointing down it
  if show-pencil {
    let foot = O(foot-p)
    out += pencil(at: foot, rotate: half - 15deg,
      scale: pencil-scale * 0.75, length: pencil-length / 0.75,
      colour: pencil-colour, lead: pencil-lead)
    out += p-circle((foot.at(0) + leg / 30, foot.at(1) + leg / 5), leg / 36,
      fill: luma(225), stroke: colour, weight: 0.7)
  }

  // Stand it up. The frame has the needle at the origin and the pencil foot
  // out along +x, so aiming at `to` is just a rotation by that bearing.
  placed(out, at: from, rotate: a, scale: scale, flip-y: flip)
}
