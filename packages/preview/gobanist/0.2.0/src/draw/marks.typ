// Las marcas, con centro en el origen. r es el radio de la piedra del jugador de la marca, ya escalado.

#import "util.typ": paint, fills, layered, disc, square, fitted-size, number-length, plain, unbroken
#import "images.typ": picture, pick

// El texto de una marca (sequence o custom), centrado.
#let label(body, length, one, style, scale) = {
  let size = if style.label.size == auto { fitted-size(length, one) } else { style.label.size }
  let options = style.label.text
  options.insert("size", size * scale)
  options.insert("top-edge", "bounds")
  options.insert("bottom-edge", "bounds")
  place(center + horizon, unbroken(text(..options, body)))
}

// Un tramado de líneas diagonales en un cuadrado de medio lado s.
#let hatch(s, color, width) = place(top + left, dx: -s, dy: -s, box(width: 2 * s, height: 2 * s, clip: true, {
  let step = 3pt
  let n = calc.ceil(4 * s / step)
  for i in range(-n, n + 1) {
    place(top + left, line(start: (i * step - 2 * s, 0pt), end: (i * step, 2 * s),
      stroke: (paint: color, thickness: width)))
  }
}))

// Una forma propia (de shapes). Lo que devuelve una función se dibuja con su origen en el punto; recibe el
// radio de la piedra (con la escala de la marca), el trazo, el relleno (none si está apagado) y el color de
// las líneas. Un contenido y una imagen van centrados; la imagen mide 1.2 radios sin width, y con varios
// archivos cada punto usa uno.
#let defined(shape, r, style, stroke, context-info) = {
  if type(shape) == function {
    let fill = if style.fill.on { paint(style.fill.color, style.fill.opacity) }
    place(top + left, shape((radius: r, stroke: stroke, fill: fill, color: style.line.color)))
  } else if type(shape) == dictionary {
    let width = if shape.image.width == auto { 1.2 * r } else { shape.image.width * context-info.scale }
    place(center + horizon, picture(pick(shape.image.file, ..context-info.point), width))
  } else { place(center + horizon, shape) }
}

// La marca. context-info: (tree, cell: (ux, uy), stone-fill (los rellenos de la piedra), number, content,
// scale, factor, ground, point). factor multiplica los grosores (scale-line-width); ground, si el fondo tiene
// imagen, dibuja lo que hay en el fondo debajo de la marca (ver cover); point es la intersección.
#let shape(name, r, style, context-info) = {
  let factor = context-info.factor
  let stroke = (paint: paint(style.line.color, style.line.opacity), thickness: style.line.width * factor)
  let own = context-info.tree.shapes.at(name, default: none)
  if own != none { return defined(own, r, style, stroke, context-info) }
  let fill = fills(style.fill)
  let grid = context-info.tree.grid.line
  let territory = (paint: paint(grid.color, grid.opacity), thickness: grid.width * factor)
  let k = 0.7071 * 0.6 * r
  if name == "circle" { disc(0.6 * r, stroke: stroke) }
  else if name == "triangle" {
    place(top + left, polygon(stroke: (..stroke, join: "miter"),
      (0pt, -0.6 * r), (-0.866 * 0.6 * r, 0.3 * r), (0.866 * 0.6 * r, 0.3 * r)))
  }
  else if name == "square" { square(k, stroke: stroke) }
  else if name == "cross" {
    place(top + left, line(start: (-k, -k), end: (k, k), stroke: stroke))
    place(top + left, line(start: (-k, k), end: (k, -k), stroke: stroke))
  }
  else if name == "filled-square" { layered(square.with(0.7071 * 0.5 * r), fill) }
  else if name == "filled-circle" { layered(disc.with(0.5 * r), fill) }
  else if name == "hatched-lines" {
    if style.fill.on and style.fill.color != none { hatch(r, paint(style.fill.color, style.fill.opacity), 0.4pt * factor) }
  }
  else if name == "t-circle" { layered(disc.with(0.35 * r), context-info.stone-fill, stroke: territory) }
  else if name == "t-square" { layered(square.with(0.25 * r), context-info.stone-fill, stroke: territory) }
  else if name == "dim" {
    let (ux, uy) = context-info.cell
    if context-info.ground != none { return (context-info.ground)(ux, uy, opacity: 0.6) }
    let background = context-info.tree.background.fill.color
    place(top + left, dx: -ux / 2, dy: -uy / 2, rect(width: ux, height: uy, fill: paint(background, 0.6)))
  }
  else if name == "sequence" {
    let body = numbering(style.label.format, context-info.number)
    label(body, number-length(body), 10pt, style, context-info.scale)
  }
  else if name == "custom" {
    let body = context-info.content
    label(body, plain(body).clusters().len(), 10pt, style, context-info.scale)
  }
  else { panic("forma de marca desconocida: " + name) }
}

// El círculo del color del fondo que tapa la cuadrícula debajo de una marca sobre un punto vacío. Las
// marcas t- y dim no lo llevan. Si el fondo tiene imagen, ground(ancho, alto, radius: ...) dibuja lo que hay
// en el fondo en ese punto: el color, la imagen y el patrón.
#let cover(name, r, tree, ground: none) = {
  if name in ("t-circle", "t-square", "dim") { return none }
  let k = if name == "hatched-lines" { 1 } else { 0.8 }
  if ground != none { return ground(2 * k * r, 2 * k * r, radius: k * r) }
  layered(disc.with(k * r), fills(tree.background.fill + (on: true)))
}
