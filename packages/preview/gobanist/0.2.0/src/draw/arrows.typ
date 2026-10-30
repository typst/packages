// Las flechas y las líneas, de un punto a otro del dibujo, con su halo.

#import "util.typ": paint

// La punta tip, apuntando hacia +x con el extremo en el origen, para un trazo de grosor w (en puntos):
// los vértices y cuánto entra el trazo en ella. Crece con el grosor, como en arrows.meta.
#let tip-shape(tip, w) = {
  let l = 3 + 4.5 * w
  if tip == "stealth" { (polygon: ((0, 0), (-l, 0.375 * l), (-0.675 * l, 0), (-l, -0.375 * l)), back: 0.3 * l) }
  else if tip == "triangle" { (polygon: ((0, 0), (-l, 0.5 * l), (-l, -0.5 * l)), back: 0.5 * l) }
  else if tip == "circle" { (circle: l / 2, back: 0.5 * l) }
  else { panic("arrow.tip es stealth, triangle o circle: " + repr(tip)) }
}

#let pt(p) = (p.at(0) * 1pt, p.at(1) * 1pt)

// La punta en el punto at, en la dirección u (un vector de largo 1). halo: el ancho del halo, o none.
#let tip-draw(shape, at, u, color, halo) = {
  let (x, y) = at
  if "circle" in shape {
    let r = shape.circle
    let (cx, cy) = (x - u.at(0) * r, y - u.at(1) * r)
    let grow = if halo == none { 0 } else { halo.width }
    let r2 = r + grow
    place(top + left, dx: (cx - r2) * 1pt, dy: (cy - r2) * 1pt,
      circle(radius: r2 * 1pt, fill: if halo == none { color } else { halo.color }))
  } else {
    let points = shape.polygon.map(((px, py)) => pt((x + px * u.at(0) - py * u.at(1), y + px * u.at(1) + py * u.at(0))))
    if halo == none {
      place(top + left, polygon(fill: color, ..points))
    } else {
      place(top + left, polygon(fill: halo.color, stroke: (paint: halo.color, thickness: 2 * halo.width * 1pt, join: "round"), ..points))
    }
  }
}

// Una flecha (tip: la punta y tips: "end" o "both") o una línea (tip: none) de p0 a p3. halo-color: el
// color del halo si es auto. factor multiplica los grosores.
#let draw-stroke(p0, p3, style, tip, tips, halo-color, factor) = {
  let f(l) = l / 1pt
  let (x0, y0, x3, y3) = (f(p0.at(0)), f(p0.at(1)), f(p3.at(0)), f(p3.at(1)))
  let (dx, dy) = (x3 - x0, y3 - y0)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return none }
  // Las direcciones en la y de Typst: girar hacia la izquierda es restar el ángulo.
  let phi = calc.atan2(dx, dy)
  let dir(a) = (calc.cos(a), calc.sin(a))
  let out = dir(phi - style.bend)
  let into = dir(phi + 180deg + style.bend)
  let add(p, v, k) = (p.at(0) + k * v.at(0), p.at(1) + k * v.at(1))
  let k = 0.3915 * len
  let (c1, c2) = (add((x0, y0), out, k), add((x3, y3), into, k))
  let short = f(style.shorten)
  let (a, b) = (add((x0, y0), out, short), add((x3, y3), into, short))
  let w = f(style.width * factor)
  let shape = if tip == none { none } else { tip-shape(tip, w) }
  let both = shape != none and tips == "both"
  if shape != none and tips not in ("end", "both") { panic("arrow.tips es end o both: " + repr(tips)) }
  // El trazo termina adentro de la punta.
  let a2 = if both { add(a, out, shape.back) } else { a }
  let b2 = if shape != none { add(b, into, shape.back) } else { b }
  let path(stroke) = place(top + left, curve(stroke: stroke, curve.move(pt(a2)),
    if style.bend == 0deg { curve.line(pt(b2)) } else { curve.cubic(pt(c1), pt(c2), pt(b2)) }))
  let color = paint(style.color, style.opacity)
  let dash = if style.dash == "solid" { none } else { style.dash }
  let halo = if style.halo.on {
    (color: if style.halo.color == auto { halo-color } else { style.halo.color }, width: f(style.halo.width * factor))
  } else { none }
  let ends = if shape == none { () } else {
    ((b, (-into.at(0), -into.at(1))),) + if both { ((a, (-out.at(0), -out.at(1))),) } else { () }
  }
  if halo != none {
    path((paint: halo.color, thickness: (w + 2 * halo.width) * 1pt, cap: "butt"))
    for (at, u) in ends { tip-draw(shape, at, u, color, halo) }
  }
  path((paint: color, thickness: w * 1pt, cap: "butt", dash: dash))
  for (at, u) in ends { tip-draw(shape, at, u, color, none) }
}
