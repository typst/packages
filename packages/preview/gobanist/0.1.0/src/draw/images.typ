// Las imágenes: de las piedras, sus sombras y sus brillos, del fondo, de la cuadrícula y de los puntos de
// estrella. Un archivo es un path (path("madera.jpg")) o sus bytes; varios, un arreglo.

#import "../kernel.typ": image-transform

#let check(file) = {
  if type(file) not in (path, bytes) {
    panic("una imagen es un path (path(\"piedra.png\")) o sus bytes: " + repr(file))
  }
  file
}

// Los archivos de una opción file.
#let files(file) = if type(file) == array {
  if file.len() == 0 { panic("file: el arreglo de imágenes está vacío") }
  file.map(check)
} else { (check(file),) }

// La parte fraccionaria de sin(a x + b y) c: un pseudoazar que solo depende del lugar (x, y), el de pgf-go.
#let noise(x, y, a, b, c) = {
  let v = calc.sin(x * a + y * b) * c
  v - calc.floor(v)
}

// Con varios archivos, el que va en el lugar (x, y): siempre el mismo en cada lugar.
#let pick(file, x, y) = {
  let all = files(file)
  if all.len() == 1 { all.first() } else { all.at(calc.floor(noise(x, y, 39.3468, 11.135, 24634.6345) * all.len())) }
}

// El giro en el lugar (x, y): un ángulo, "random" o un rango (mínimo, máximo), elegido por el lugar. Un giro
// distinto del de pick: el archivo y el giro no van juntos.
#let turn(rotate, x, y) = {
  let (low, high) = if rotate == "random" { (0deg, 360deg) } else if type(rotate) == array and rotate.len() == 2 {
    rotate
  } else if type(rotate) == angle { return rotate } else {
    panic("rotate espera un ángulo, \"random\" o (mínimo, máximo): " + repr(rotate))
  }
  low + noise(x, y, 12.9898, 78.233, 43758.5453) * (high - low)
}

// El ángulo en cuartos de vuelta: 0, 90, 180 o 270 grados.
#let quarter(a) = calc.rem-euclid(calc.round(a / 90deg), 4) * 90deg

// El color, de 0 a 255, para el kernel.
#let rgba(color) = color.rgb().components().map(c => int(calc.round(c / 100% * 255)))

// La imagen del archivo, de ese ancho y, sin height, con su proporción; con su opacidad (de 0 a 1) o, con
// silhouette (un color), su forma pintada de ese color. Las demás opciones van a image. El alto va siempre:
// puesta en un punto (un lugar de alto cero), sin él la imagen no se vería. Necesita context.
#let picture(file, width, height: auto, opacity: 1, silhouette: none, ..options) = {
  let height = if height != auto { height } else {
    let natural = measure(image(file))
    width * (natural.height / natural.width)
  }
  if opacity >= 1 and silhouette == none { return image(file, width: width, height: height, ..options) }
  let data = if type(file) == bytes { file } else { read(file, encoding: none) }
  let request = (opacity: calc.max(0, opacity))
  if silhouette != none { request.silhouette = rgba(silhouette) }
  image(image-transform(data, request), format: "png", width: width, height: height, ..options)
}

// La imagen girada en sentido antihorario, centrada en el origen.
#let centered(a, body) = place(center + horizon, if a == 0deg { body } else { rotate(-a, body) })

// make(ancho, alto) girada a en cuartos de vuelta. Con 90 o 270 grados, make recibe el ancho y el alto
// intercambiados, para que la imagen girada ocupe width por height.
#let quarter-turned(a, width, height, make) = {
  let a = quarter(a)
  if a == 0deg { make(width, height) }
  else if a == 180deg { rotate(-a, make(width, height)) }
  else { rotate(-a, reflow: true, make(height, width)) }
}

// Dónde empiezan las baldosas de largo t que cubren el tramo de start a start + length: desde el principio
// ("start"), desde el final ("end") o con una en el medio ("center").
#let tile-starts(start, length, t, from) = {
  let n = calc.ceil(length / t)
  if from == "start" { range(n).map(k => start + k * t) }
  else if from == "end" { range(n).map(k => start + length - (k + 1) * t) }
  else {
    let middle = start + length / 2 - t / 2
    let m = calc.ceil((length / 2 - t / 2) / t)
    range(-m, m + 1).map(k => middle + k * t)
  }
}

// Las baldosas: cells son (i, j, x, y, ancho, alto), el lugar en la malla (que elige el archivo y el giro) y
// el rectángulo. Cada una es la imagen estirada a su celda.
#let tiles(file, rotate, cells, opacity) = for (i, j, x, y, w, h) in cells {
  let f = pick(file, i, j)
  place(top + left, dx: x, dy: y, quarter-turned(turn(rotate, i, j), w, h,
    (w, h) => picture(f, w, height: h, fit: "stretch", opacity: opacity)))
}

// La malla de columns por rows celdas en el rectángulo (x, y, ancho, alto), para tiles.
#let mesh(x, y, width, height, columns, rows) = {
  let (w, h) = (width / columns, height / rows)
  for i in range(columns) { for j in range(rows) { ((i + 1, j + 1, x + i * w, y + j * h, w, h),) } }
}

// tiles: n o (columnas, filas).
#let mesh-size(tiles) = if type(tiles) == int { (tiles, tiles) } else if type(tiles) == array and tiles.len() == 2 {
  tiles
} else { panic("tiles espera un número o (columnas, filas): " + repr(tiles)) }
