// Lo que va en un tablero: piedras, jugadas, prisioneros y marcas. Cada función devuelve un diccionario
// con las coordenadas sin leer; se leen al dibujar el tablero, cuando se conocen su tamaño y su parte
// visible.

// Las opciones de marks: ninguna forma, ni las del paquete ni las propias (shapes), puede llamarse así.
#let mark-keys = ("line", "fill", "label", "scale", "player", "from", "content", "forget", "shift")

#let stone-keys = ("fill", "line", "radius", "scale", "shadow", "shine", "image")

// Una marca sobre una piedra: el nombre de la forma o un diccionario con shape y las opciones de la marca.
// Si la forma existe se sabe al dibujarla, cuando se conocen las propias (shapes).
#let stone-mark(mark) = {
  if mark == none { return none }
  let mark = if type(mark) == str { (shape: mark) } else { mark }
  if type(mark) != dictionary or "shape" not in mark or type(mark.shape) != str {
    panic("mark espera una forma (\"triangle\") o un diccionario con shape")
  }
  mark
}

// shift: (columnas, filas), lo que se corren las coordenadas, a la derecha y arriba.
#let shift(value) = {
  if type(value) != array or value.len() != 2 or value.any(n => type(n) != int) {
    panic("shift espera (columnas, filas), dos números enteros: " + repr(value))
  }
  value
}

// forget: resume no trae lo que lo tiene (con "number", una jugada viene sin su número).
#let forget(value, allowed) = {
  if value not in allowed { panic("forget acepta " + allowed.map(repr).join(", ") + ": " + repr(value)) }
  value
}

// Separa las opciones con nombre: las coordenadas de cada jugador y lo demás.
#let split(kind, args, allowed) = {
  let pos = args.pos()
  if pos.len() > 1 or pos.any(p => type(p) != str) {
    panic(kind + " recibe las coordenadas como texto, en una sola cadena por jugador")
  }
  let groups = ()
  let options = (:)
  for (key, value) in args.named() {
    if key in ("black", "white", "neutral") {
      groups.push((player: key, at: value))
    } else if key in allowed {
      options.insert(key, value)
    } else {
      panic(kind + " no tiene la opción " + key)
    }
  }
  (pos: pos, groups: groups, options: options)
}

// Piedras. Sin jugador, son neutrales: stones("C3"), stones(black: "C2, D3", white: "B4").
#let stones(..args) = {
  let (pos, groups, options) = split("stones", args, stone-keys + ("mark", "forget", "shift"))
  options.mark = stone-mark(options.at("mark", default: none))
  options.shift = shift(options.at("shift", default: (0, 0)))
  options.forget = forget(options.at("forget", default: false), (true, false))
  (kind: "stones", groups: pos.map(at => (player: "neutral", at: at)) + groups, options: options, prisoner: false)
}

// Prisioneros: piedras capturadas que siguen en el tablero.
#let prisoners(..args) = {
  let s = stones(..args)
  s.kind = "prisoners"
  s.prisoner = true
  s
}

// Jugadas, numeradas, alternando negras y blancas. Sin jugador siguen el turno; con uno, empiezan con él:
// moves("C3, D4"), moves(white: "D2, B3").
#let moves(..args) = {
  let (pos, groups, options) = split("moves", args, stone-keys + ("mark", "numbers", "label", "from", "forget", "shift"))
  if pos.len() + groups.len() != 1 { panic("moves recibe una sola secuencia de jugadas") }
  let first = if groups.len() > 0 { groups.first().player } else { auto }
  if first == "neutral" { panic("las jugadas son de negras o de blancas") }
  options.mark = stone-mark(options.at("mark", default: none))
  options.shift = shift(options.at("shift", default: (0, 0)))
  options.forget = forget(options.at("forget", default: false), (true, false, "number"))
  (kind: "moves", first: first, at: (pos + groups.map(g => g.at)).first(), options: options)
}

// Marcas. La forma es la clave y el valor, las coordenadas: marks(triangle: "C3", circle: "E5"). Sin
// forma, una cruz. Sin player, una marca sobre una piedra es de su jugador, y sobre un punto vacío, neutral.
// Toda clave que no es una opción es una forma: si existe se sabe al dibujarla.
#let marks(..args) = {
  let pos = args.pos()
  if pos.len() > 1 or pos.any(p => type(p) != str) {
    panic("marks recibe las coordenadas como texto, en una sola cadena por forma")
  }
  let groups = pos.map(at => (shape: "cross", at: at))
  let options = (:)
  for (key, value) in args.named() {
    if key in mark-keys {
      options.insert(key, value)
    } else {
      if type(value) != str { panic("marks: las coordenadas de " + key + " son texto: " + repr(value)) }
      groups.push((shape: key, at: value))
    }
  }
  if groups.any(g => g.shape == "custom") and "content" not in options {
    panic("la marca custom necesita content")
  }
  let player = options.at("player", default: auto)
  if player != auto and player not in ("neutral", "black", "white") {
    panic("jugador desconocido: " + repr(player))
  }
  options.shift = shift(options.at("shift", default: (0, 0)))
  options.forget = forget(options.at("forget", default: false), (true, false))
  (kind: "marks", groups: groups, options: options)
}

// Flechas y líneas: cada par va de una intersección a otra. arrows(("B3", "F3"), ("C7", "G9"), color: red).
#let strokes(kind, args, allowed) = {
  let pairs = args.pos()
  if pairs.len() == 0 or pairs.any(p => type(p) != array or p.len() != 2 or p.any(c => type(c) != str)) {
    panic(kind + " recibe pares de intersecciones: " + kind + "((\"B3\", \"F3\"))")
  }
  let options = args.named()
  for key in options.keys() {
    if key not in allowed + ("forget",) { panic(kind + " no tiene la opción " + key) }
  }
  options.forget = forget(options.at("forget", default: false), (true, false))
  (kind: kind, pairs: pairs, options: options)
}

#let stroke-keys = ("color", "width", "opacity", "dash", "shorten", "bend", "halo")

#let arrows(..args) = strokes("arrows", args, stroke-keys + ("tip", "tips"))

#let lines(..args) = strokes("lines", args, stroke-keys)

// Territorio. La clave es el jugador y el valor, los vértices de un polígono (con la sintaxis de las
// coordenadas, en orden) o auto, que lo busca solo: territory(black: "A1, A5, B5, B1"), territory(auto).
// Sin jugador, un polígono es neutral y auto marca el de los dos colores.
#let territory(..args) = {
  let pos = args.pos()
  if pos.len() > 1 { panic("territory recibe un solo polígono o auto por jugador") }
  let requests = pos.map(area => (player: none, area: area))
  let options = (:)
  for (key, value) in args.named() {
    if key in ("black", "white", "neutral") {
      requests.push((player: key, area: value))
    } else if key in ("draw", "dame", "forget", "mark", "fill", "line", "vertices") {
      options.insert(key, value)
    } else {
      panic("territory no tiene la opción " + key)
    }
  }
  if requests.len() == 0 { panic("territory necesita un polígono o auto") }
  for r in requests {
    if r.area != auto and type(r.area) != str { panic("territory espera los vértices como texto, o auto") }
  }
  if "draw" in options and options.draw not in ("marks", "fill", "region") {
    panic("territory.draw es \"marks\", \"fill\" o \"region\": " + repr(options.draw))
  }
  if "mark" in options { options.mark = stone-mark(options.mark) }
  options.forget = forget(options.at("forget", default: false), (true, false))
  (kind: "territory", requests: requests, options: options)
}
