// Las piedras y los números de las jugadas, con centro en el origen.

#import "util.typ": paint, fills, layered, line-stroke, disc, fitted-size, number-length, polar, arc, unbroken
#import "images.typ": pick, turn, picture, centered

// El radio de la piedra con su estilo, en un tablero con esa escala.
#let radius(style, scale) = style.radius * style.scale * scale

// El ancho de la imagen de una piedra, su sombra o su brillo: el diámetro de la piedra, sin width.
#let image-width(options, r, scale) = if options.width == auto { 2 * r } else { options.width * scale }

// La imagen propia de la sombra o del brillo (shadow.image o shine.image), con su opacidad y, con silhouette,
// pintada de su color. No gira con la imagen de la piedra.
#let overlay(style, r, scale, at) = {
  let options = style.image
  centered(options.rotate, picture(pick(options.file, ..at), image-width(options, r, scale),
    opacity: style.opacity, silhouette: if options.silhouette { style.color }))
}

// La sombra, corrida offset hacia angle y agrandada scale veces: su imagen propia o la silueta de la piedra
// (el círculo o, si la piedra es una imagen, la forma de la imagen, girada como ella).
#let shadow(shadow, r, scale, at, stone-image: none) = {
  let (dx, dy) = polar(shadow.angle, shadow.offset * scale)
  let body = if shadow.image.file != none {
    overlay(shadow, r, scale, at)
  } else if stone-image != none {
    let (file, width, a) = stone-image
    centered(a, picture(file, width, opacity: shadow.opacity, silhouette: shadow.color))
  } else {
    return place(top + left, dx: dx, dy: dy, disc(r * shadow.scale, fill: paint(shadow.color, shadow.opacity)))
  }
  place(top + left, dx: dx, dy: dy, box(width: 0pt, height: 0pt,
    if shadow.scale == 1 { body } else { std.scale(shadow.scale * 100%, origin: top + left, body) }))
}

// El brillo dibujado: un trazo curvo y una elipse, proporcionales al radio. Con angle 0, como en pgf-go.
#let shine(shine, r) = {
  let rot = -45deg + shine.angle
  let big = 0.8 * r
  let at(a) = polar(a + rot, big)
  let color = paint(shine.color, shine.opacity)
  place(top + left, curve(fill: color, stroke: none,
    curve.move(at(135deg)),
    ..arc(135deg + rot, 190deg + rot, big),
    curve.quad(at(135deg), at(80deg)),
    ..arc(80deg + rot, 135deg + rot, big),
    curve.close(),
  ))
  // La elipse, en la dirección -45 grados del brillo, con los semiejes 4/17 y 1/17 del radio.
  let (cx, cy) = polar(-45deg + rot, big)
  let (a, b) = (4 / 17 * r, 1 / 17 * r)
  place(top + left, dx: cx - a, dy: cy - b, rotate(-(rot + 45deg), ellipse(width: 2 * a, height: 2 * b, fill: color)))
}

// La piedra en el punto at: la sombra, el círculo (o la imagen, sin relleno ni borde) y el brillo, que no gira
// con la imagen. factor multiplica los grosores (scale-line-width).
#let stone(style, scale, factor, at) = {
  let r = radius(style, scale)
  let stone-image = if style.image.file != none {
    (pick(style.image.file, ..at), image-width(style.image, r, scale), turn(style.image.rotate, ..at))
  }
  if style.shadow.on { shadow(style.shadow, r, scale, at, stone-image: stone-image) }
  if stone-image != none {
    let (file, width, a) = stone-image
    let opacity = style.image.opacity * if style.fill.on { style.fill.opacity } else { 1 }
    centered(a, picture(file, width, opacity: opacity))
  } else {
    layered(disc.with(r), fills(style.fill), stroke: line-stroke(style.line, factor: style.scale * factor))
  }
  if style.shine.on {
    if style.shine.image.file != none { overlay(style.shine, r, scale, at) } else { shine(style.shine, r) }
  }
}

// El número n con el estilo de la jugada (move) sobre una piedra de ese estilo.
#let number(n, move, style, scale) = {
  let body = numbering(move.label.format, n)
  let size = if move.label.size == auto { fitted-size(number-length(body), 1em) } else { move.label.size }
  let options = move.label.text
  options.insert("size", size * style.scale * scale)
  options.insert("top-edge", "bounds")
  options.insert("bottom-edge", "bounds")
  place(center + horizon, unbroken(text(..options, body)))
}
