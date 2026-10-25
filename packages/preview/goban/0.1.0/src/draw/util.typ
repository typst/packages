// Lo que comparten las partes del dibujo.

// El color con la opacidad (de 0 a 1).
#let paint(color, opacity) = if color == none or opacity == 1 { color } else {
  color.transparentize((1 - opacity) * 100%)
}

// Los rellenos de una rama fill (on, color, opacity, pattern): el color y, encima, el patrón (un tiling).
#let fills(fill) = if not fill.on { () } else {
  (paint(fill.color, fill.opacity), fill.pattern).filter(f => f != none)
}

// Una figura con cada relleno y, encima, el trazo: draw recibe fill y stroke. Con un solo relleno, una figura.
#let layered(draw, fills, stroke: none) = {
  if fills.len() <= 1 { return draw(fill: fills.at(0, default: none), stroke: stroke) }
  for f in fills { draw(fill: f, stroke: none) }
  if stroke != none { draw(fill: none, stroke: stroke) }
}

// El trazo de una rama line (color, width, opacity), o none si está apagada. factor multiplica el grosor
// (la escala de la piedra y, con scale-line-width, la del tablero).
#let line-stroke(line, factor: 1) = {
  if not line.at("on", default: true) { return none }
  (paint: paint(line.color, line.opacity), thickness: line.width * factor, cap: "square")
}

// El punto a distancia r en la dirección a, en el sentido de las matemáticas (0deg a la derecha, 90deg
// arriba), con la y de Typst (hacia abajo).
#let polar(a, r) = (r * calc.cos(a), -r * calc.sin(a))

// Las curvas de un arco de radio r con centro en el origen, de a1 a a2 (crece en sentido antihorario),
// en tramos de hasta 90 grados.
#let arc(a1, a2, r) = {
  let n = calc.max(1, calc.ceil(calc.abs((a2 - a1) / 90deg)))
  let step = (a2 - a1) / n
  let k = 4 / 3 * calc.tan(step / 4)
  range(n).map(i => {
    let (a, b) = (a1 + i * step, a1 + (i + 1) * step)
    let (p, q) = (polar(a, r), polar(b, r))
    // La tangente en el sentido del arco: en la y de Typst, (-sen, -cos).
    let c1 = (p.at(0) - k * r * calc.sin(a), p.at(1) - k * r * calc.cos(a))
    let c2 = (q.at(0) + k * r * calc.sin(b), q.at(1) + k * r * calc.cos(b))
    curve.cubic(c1, c2, q)
  })
}

// Pone el contenido con su origen en (x, y): adentro, place(top + left, dx: ..., dy: ...) se mide desde ese
// punto, también hacia arriba y hacia la izquierda.
#let origin(x, y, ..children) = place(top + left, dx: x, dy: y, box(width: 0pt, height: 0pt, children.pos().join()))

// El texto en una caja de su ancho: puesto en un punto (un lugar de ancho cero), no se parte en renglones
// (el CJK se puede partir entre dos caracteres cualesquiera).
#let unbroken(body) = context block(width: measure(body).width, body)

// Pone el contenido centrado en (x, y).
#let centered(x, y, body) = origin(x, y, place(center + horizon, body))

// Un círculo de radio r con centro en el origen.
#let disc(r, ..style) = place(top + left, dx: -r, dy: -r, circle(radius: r, ..style))

// Un cuadrado de medio lado s con centro en el origen.
#let square(s, ..style) = place(top + left, dx: -s, dy: -s, rect(width: 2 * s, height: 2 * s, ..style))

// El tamaño de un texto que va sobre una piedra, según su largo n: con un carácter, one.
#let fitted-size(n, one) = if n <= 1 { one } else if n == 2 { 0.65em } else { 0.45em }

// El largo de un número escrito con su formato: las letras y las cifras latinas, y dos por cada kanji.
#let number-length(text) = text.clusters().map(c => {
  if c.match(regex("^[a-zA-Z0-9]$")) != none { 1 } else if c.codepoints().first().to-unicode() > 127 { 2 } else { 0 }
}).sum(default: 0)

// El texto plano de un contenido, si lo tiene.
#let plain(body) = {
  if type(body) == str { body }
  else if type(body) == content and body.has("text") { body.text }
  else { "?" }
}
