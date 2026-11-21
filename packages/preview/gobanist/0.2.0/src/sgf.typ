// Las partidas en SGF. sgf-read lee un archivo; lo que devuelve es un elemento de tablero, que dibuja la
// línea principal, y sgf lo refina (otra línea, hasta qué jugada, la numeración). sgf-info da sus
// propiedades. El archivo lo lee el kernel (kernel/src/sgf.rs); aquí se pasa a lo que dibuja un tablero.

#import "kernel.typ": sgf-query
#import "coordinates.typ": point
#import "options.typ": merge-sgf, current
#import "elements.typ": stone-mark
#import "texts.typ": word

#let query(game, q) = sgf-query(game.data, (charset: game.charset, game: game.game, origin: game.origin,
  transpose: game.transpose, syntax: game.syntax, query: q))

#let check-game(name, game) = {
  if type(game) != dictionary or game.at("kind", default: none) != "sgf" {
    panic(name + " espera una partida leída con sgf-read(...)")
  }
}

// Lee un archivo SGF: un path es un archivo (path("partida.sgf")), bytes su contenido y una cadena, el texto
// SGF. game es la partida de una colección; charset, la codificación de un archivo que no es UTF-8 (con auto,
// la de CA o, sin CA, Latin-1). origin es la esquina donde va el punto aa del archivo y, con transpose, la
// primera letra de cada punto es la fila: entre las dos, las ocho simetrías del tablero. syntax es "sgf",
// "sensei" (los diagramas de Sensei's Library, kernel/src/sgf/sensei.rs) o auto. Los puntos _ de un diagrama
// (blank, como (x, y)) son el blank de su tablero.
#let sgf-read(source, game: 1, charset: auto, origin: top + left, transpose: false, syntax: auto) = {
  let data = if type(source) == path { read(source, encoding: none) }
    else if type(source) == bytes { source }
    else if type(source) == str { bytes(source) }
    else { panic("sgf-read espera un archivo (path(\"partida.sgf\")), bytes o el texto SGF: " + repr(source)) }
  if type(game) != int or game < 1 { panic("sgf-read: game es un número desde 1: " + repr(game)) }
  if charset != auto and type(charset) != str { panic("sgf-read: charset es auto o un nombre: " + repr(charset)) }
  let charset = if charset == auto { none } else { charset }
  let corners = ((top + left, "top-left"), (top + right, "top-right"), (bottom + left, "bottom-left"),
    (bottom + right, "bottom-right"))
  let corner = corners.find(((a, _)) => a == origin)
  if corner == none {
    panic("sgf-read: origin es una esquina, como top + left o bottom + right: " + repr(origin))
  }
  let origin = corner.at(1)
  if type(transpose) != bool { panic("sgf-read: transpose es true o false: " + repr(transpose)) }
  if syntax not in (auto, "sgf", "sensei") { panic("sgf-read: syntax es auto, \"sgf\" o \"sensei\": " + repr(syntax)) }
  let syntax = if syntax == auto { none } else { syntax }
  let request = (charset: charset, origin: origin, transpose: transpose, syntax: syntax)
  let sizes = sgf-query(data, request + (query: (kind: "games")))
  if game > sizes.len() {
    panic("el archivo SGF tiene " + str(sizes.len()) + " partidas: no tiene la " + str(game))
  }
  let (cols, rows) = sizes.at(game - 1)
  let code(c) = if c >= "a" { c.to-unicode() - "a".to-unicode() + 1 } else { c.to-unicode() - "A".to-unicode() + 27 }
  let blank = sgf-query(data, request + (game: game, query: (kind: "info", property: "_blank"))).map(p =>
    (code(p.at(0)), rows - code(p.at(1)) + 1))
  (kind: "sgf", data: data, charset: charset, origin: origin, transpose: transpose, syntax: syntax, game: game,
    size: (cols, rows), blank: blank, options: ())
}

#let sgf-keys = ("from", "to", "variation", "marks", "numbers", "step", "restart", "last-mark", "letters", "view",
  "forget")

// La partida con otras opciones, que se suman a las que tenía: sgf(partida, to: 7, variation: (2, 1)).
#let sgf(game, ..args) = {
  check-game("sgf", game)
  if args.pos().len() > 0 { panic("sgf recibe una partida y opciones con nombre") }
  let options = args.named()
  for key in options.keys() {
    if key not in sgf-keys { panic("sgf no tiene la opción " + key) }
  }
  game.options.push(options)
  game
}

// El camino de variation para el kernel: none es la línea principal; un arreglo, la variante que se toma en
// cada bifurcación; un texto, las jugadas de la línea desde la primera ("C5, C3, pass").
#let variation-path(variation, use-i) = {
  if variation == none { return (numbers: ()) }
  if type(variation) == array {
    if variation.any(n => type(n) != int or n < 1) {
      panic("variation espera números desde 1: " + repr(variation))
    }
    return (numbers: variation)
  }
  if type(variation) != str { panic("variation espera números, como (2, 1), o jugadas: " + repr(variation)) }
  (moves: variation.split(regex("[,\s]+")).filter(s => s != "").map(s => {
    if s == "pass" { return none }
    let p = point(s, use-i)
    if p == none { panic("variation: «" + s + "» no es una jugada") }
    p
  }))
}

#let variation-text(variation) = if type(variation) == array { variation.map(str).join(".") } else { variation }

// Una propiedad de la partida, como texto (varios valores, separados por comas): la de la raíz o, con move, la
// de esa jugada de la línea de variation (sus jugadas, con las letras del go). Si no está, "".
#let sgf-info(game, property, move: 0, variation: none) = {
  check-game("sgf-info", game)
  if type(property) != str { panic("sgf-info espera el nombre de una propiedad, como \"PB\"") }
  if type(move) != int or move < 0 { panic("sgf-info: move es un número desde 0: " + repr(move)) }
  query(game, (kind: "info", path: variation-path(variation, false), move: move, property: property)).join(", ", default: "")
}

// Los textos de las anotaciones, con valor 1 y 2 (DO, IT, DM y UC enfatizados usan el mismo).
#let note-keys = (
  TE: ("tesuji", "very-good-tesuji"),
  BM: ("bad-move", "very-bad-move"),
  DO: ("doubtful", "doubtful"),
  IT: ("interesting", "interesting"),
  GB: ("good-for-black", "very-good-for-black"),
  GW: ("good-for-white", "very-good-for-white"),
  DM: ("even", "even"),
  UC: ("unclear", "unclear"),
)

// El comentario de una jugada leída (un step del kernel): con annotations, su nombre (N) en negrita y sus
// anotaciones, cada una seguida de un punto; después, el comentario (C). none si no tiene nada. Necesita
// context.
#let comment-body(tree, step, annotations) = {
  let notes = if annotations {
    step.notes.map(n => if n.property == "N" { strong(n.text) } else { word(tree, note-keys.at(n.property).at(n.value - 1)) })
  } else { () }
  if notes.len() == 0 and step.comment == "" { return none }
  let head = if notes.len() > 0 { notes.join(". ") + "." + if step.comment != "" { " " } }
  [#head#step.comment]
}

// El comentario de la jugada move de la línea variation (0: el de antes de la primera jugada): su nombre, sus
// anotaciones y su comentario. annotations: false deja solo el comentario; chat: false le quita el chat de KGS
// y OGS.
#let sgf-comment(game, move, variation: none, annotations: true, chat: true) = {
  check-game("sgf-comment", game)
  if type(move) != int or move < 0 { panic("sgf-comment: move es un número desde 0: " + repr(move)) }
  for (key, value) in (annotations: annotations, chat: chat) {
    if type(value) != bool { panic("sgf-comment: " + key + " es true o false: " + repr(value)) }
  }
  context {
    let tree = current()
    let r = query(game, (kind: "read", path: variation-path(variation, tree.use-i), chat: chat))
    if r.missing { panic("la partida no tiene la variante " + variation-text(variation)) }
    if move > r.moves { panic("sgf-comment: la partida tiene " + str(r.moves) + " jugadas: no tiene la " + str(move)) }
    comment-body(tree, r.steps.at(move), annotations)
  }
}

#let other(player) = if player == "black" { "white" } else { "black" }

// La primera jugada del tramo de step en que cae el número n (step: el tamaño de cada tramo; el último se
// repite).
#let block(n, step) = {
  let (first, i) = (1, 0)
  while true {
    let size = calc.max(1, step.at(calc.min(i, step.len() - 1)))
    if n <= first + size - 1 { break }
    if i < step.len() - 1 {
      first += size
      i += 1
    } else {
      first += calc.quo(n - first, size) * size
      break
    }
  }
  first
}

// Las opciones de sgf, comprobadas: las globales con las de la partida encima (forget solo está en las de la
// partida).
#let sgf-options(game, tree) = {
  let o = game.options.fold(tree.sgf + (forget: false), merge-sgf)
  if type(o.from) != int or o.from < 1 { panic("sgf.from es un número desde 1: " + repr(o.from)) }
  if o.to != auto and (type(o.to) != int or o.to < 0) { panic("sgf.to es auto o un número: " + repr(o.to)) }
  for key in ("marks",) {
    if type(o.at(key)) != bool { panic("sgf." + key + " es true o false: " + repr(o.at(key))) }
  }
  if o.numbers != auto and type(o.numbers) != bool { panic("sgf.numbers es auto, true o false") }
  let step = if type(o.step) == int { (o.step,) } else { o.step }
  if type(step) != array or step.len() == 0 or step.any(n => type(n) != int or n < 1) {
    panic("sgf.step es un número o un arreglo de números: " + repr(o.step))
  }
  o.step = step
  if type(o.restart.from) != int { panic("sgf.restart.from es un número: " + repr(o.restart.from)) }
  if o.letters not in (none, auto, "children", "siblings") {
    panic("sgf.letters es none, auto, \"children\" o \"siblings\": " + repr(o.letters))
  }
  if type(o.view) != bool and (type(o.view) != int or o.view < 0) {
    panic("sgf.view es true, false o un número: " + repr(o.view))
  }
  o.last-mark = stone-mark(o.last-mark)
  if o.forget not in (true, false, "number") { panic("forget acepta true, false o \"number\": " + repr(o.forget)) }
  o
}

// El número que se muestra de cada jugada de la línea leída r, en orden. Sigue a MN; restart: true reinicia
// cada tramo de step desde el segundo (desde restart.from), y auto con PM[2], cada 100. first (lo usa
// sgf-diagrams, sin restart): la jugada from se muestra con ese número y las siguientes siguen desde ahí.
#let shown-numbers(r, o, first: none) = {
  let restart = if o.restart.on == true { 1 } else if o.restart.on == auto and r.print == 2 { 2 } else { 0 }
  let (mn, count, shift, list) = (0, 0, 0, ())
  for e in r.events {
    if e.kind == "number" {
      mn = e.number - 1
    } else if e.kind == "move" {
      count += 1
      mn += 1
      if first != none and count == o.from { shift = first - mn }
      list.push(if restart == 1 {
        let start = block(mn, o.step)
        if start == 1 { mn } else { o.restart.from + mn - start }
      } else if restart == 2 { calc.rem(mn - 1, 100) + 1 } else { mn + shift })
    }
  }
  list
}

// La vista (VW) que abarca las de las jugadas k1 a k2 de la línea leída r: el rectángulo (x1, y1, x2, y2) que
// contiene las de esas jugadas, o none si en alguna se ve todo el tablero (antes de la primera vista, o con
// VW[]). La jugada 0 tiene la vista de la 1.
#let view-between(r, k1, k2) = {
  let k1 = calc.max(k1, 1)
  let k2 = calc.max(k2, k1)
  let views = r.views
  if views.len() == 0 or views.first().start > k1 { return none }
  let rect = none
  for (i, v) in views.enumerate() {
    let last = if i + 1 < views.len() { views.at(i + 1).start - 1 } else { calc.inf }
    if v.start <= k2 and last >= k1 {
      if v.rect == none { return none }
      rect = if rect == none { v.rect } else {
        let (a, b, c, d) = rect
        (calc.min(a, v.rect.at(0)), calc.min(b, v.rect.at(1)), calc.max(c, v.rect.at(2)), calc.max(d, v.rect.at(3)))
      }
    }
  }
  rect
}

// La vista (VW) que muestra el tablero de la partida, como (x1, y1, x2, y2), o none si se ve todo: con view:
// true, la que abarca las de las jugadas from a to; con un número, la de esa jugada (0: la del principio).
#let sgf-view(game, tree) = {
  let o = sgf-options(game, tree)
  if o.view == false { return none }
  let r = query(game, (kind: "read", path: variation-path(o.variation, tree.use-i), chat: true))
  if r.missing { panic("la partida no tiene la variante " + variation-text(o.variation)) }
  if o.view == true {
    view-between(r, o.from, if o.to == auto { r.moves } else { calc.min(o.to, r.moves) })
  } else {
    if o.view > r.moves { panic("sgf.view: la partida tiene " + str(r.moves) + " jugadas: no tiene la " + str(o.view)) }
    view-between(r, o.view, o.view)
  }
}

// Las formas de las marcas del archivo (SL es selected).
#let file-shapes = (triangle: "triangle", square: "square", circle: "circle", cross: "cross",
  selected: "filled-square")

// Lo que dibuja la partida en un tablero de cols × rows, como los items de resolve (board.typ): las piedras
// iniciales, las jugadas hasta to (antes de from, sin número), los pases y las piedras que quitan o agregan los
// nodos, y las marcas, flechas, líneas, territorio y letras de la última jugada que se muestra. Las jugadas se
// numeran como en el archivo, desde 1; turn es el jugador que seguiría. Devuelve (items, number, turn): el
// número y el jugador con que sigue el tablero.
#let expand(game, tree, cols, rows, turn) = {
  let number = 1
  let o = sgf-options(game, tree)
  let r = query(game, (kind: "read", path: variation-path(o.variation, tree.use-i), chat: true))
  if r.missing { panic("la partida no tiene la variante " + variation-text(o.variation)) }
  if r.size != (cols, rows) {
    panic("la partida es de " + str(r.size.at(0)) + "×" + str(r.size.at(1)) + " y el tablero, de " + str(cols)
      + "×" + str(rows))
  }
  let numbers = if o.numbers == auto { r.print != 0 } else { o.numbers }
  let shown = shown-numbers(r, o, first: game.at("first", default: none))
  // keep (lo usan sgf-diagrams y sgf-problem): las jugadas desde from no se quitan cuando las capturan, ni
  // quitan lo que capturan (draw).
  let keep = game.at("keep", default: false)
  let last = if o.to == auto { r.moves } else { calc.min(o.to, r.moves) }
  let step = r.steps.at(last)
  let key((x, y)) = str(x) + "," + str(y)
  let item-forget = if o.forget == "number" { false } else { o.forget }

  // Las letras de las variantes de la última jugada: children, las que pueden seguir; siblings, las
  // alternativas a ella. Con auto, lo que dice ST. Solo si hay más de una.
  let letters = if o.letters != auto { o.letters } else if calc.rem(r.style, 4) >= 2 { none }
    else if calc.rem(r.style, 2) == 1 { "siblings" } else { "children" }
  let lettered = if letters == none { () } else {
    let list = step.at(letters)
    if list.len() < 2 { () } else {
      list.enumerate().filter(((_, at)) => at != none).map(((i, at)) => (at: at, letter: str.from-unicode(65 + i)))
    }
  }
  // Los puntos que marca el archivo y los de las letras: sus jugadas no llevan número. Las etiquetas (LB) y
  // los puntos atenuados no lo quitan.
  let marked = (
    (if o.marks { step.marks.filter(m => m.shape != "label").map(m => key(m.at)) } else { () })
      + lettered.map(l => key(l.at))
  )
  let labeled = if o.marks { step.marks.filter(m => m.shape == "label").map(m => key(m.at)) } else { () }

  let stone-item(x, y, player, ..extra) = (kind: "stone", x: x, y: y, player: player, options: (:), mark: none,
    prisoner: false, number: none, numbered: false, move: false, resumed: false, move-options: (:),
    forget: item-forget, captured: none) + extra.named()
  let mark-item(at, shape, ..options) = (kind: "mark", x: at.at(0), y: at.at(1), shape: shape, player: auto,
    options: options.named(), number: none, forget: item-forget, captured: none)

  let items = ()
  for (x, y) in r.black { items.push(stone-item(x, y, "black")) }
  for (x, y) in r.white { items.push(stone-item(x, y, "white")) }
  // count: la posición de la jugada en el archivo.
  let count = 0
  let numbered-points = ()
  let last-move = none
  for e in r.events {
    if e.kind == "player" {
      turn = e.player
    } else if e.kind == "add" {
      items.push(stone-item(..e.at, e.player))
    } else if e.kind == "remove" {
      if tree.captures == none { panic("la partida quita piedras (AE): hace falta captures") }
      items.push((kind: "remove", x: e.at.at(0), y: e.at.at(1), forget: item-forget))
    } else if e.kind == "move" {
      count += 1
      if o.to != auto and count > o.to { break }
      let n = shown.at(count - 1)
      let counted = numbers and count >= o.from
      if e.at == none {
        // Un pase cuenta, pero no se dibuja; con notes, si se numeraría, se anota (salvo los que terminan la
        // línea).
        items.push((kind: "pass", player: e.player, number: n, numbered: counted and not e.end, forget: item-forget))
      } else {
        if counted { numbered-points.push(key(e.at)) }
        items.push(stone-item(..e.at, e.player, number: n, numbered: counted and key(e.at) not in marked,
          move: true, forget: o.forget, keep: keep and count >= o.from))
      }
      if count == last { last-move = e }
      number = n + 1
      turn = other(e.player)
    }
  }

  if o.marks {
    // Primero los puntos atenuados, para que las demás marcas queden encima.
    for at in step.dim { items.push(mark-item(at, "dim")) }
    let territory = ()
    for m in step.marks {
      if m.shape in ("black-territory", "white-territory") {
        territory.push((..m.at, m.shape.split("-").first()))
      } else if m.shape == "label" {
        // Una etiqueta no tapa el número de una jugada: sobre una que se ve, no se dibuja (board.typ).
        items.push(mark-item(m.at, "custom", content: m.text) + (over-number: "hide"))
      } else {
        items.push(mark-item(m.at, file-shapes.at(m.shape)))
      }
    }
    for s in step.strokes {
      let kind = if s.kind == "arrow" { "arrows" } else { "lines" }
      items.push((kind: kind, x: s.from.at(0), y: s.from.at(1), to: s.to, options: (:), forget: item-forget))
    }
    // TB y TW: territorio, como el de territory; una piedra del rival en esos puntos está muerta.
    if territory.len() > 0 {
      items.push((kind: "territory", player: none, mode: "points", vertices: (), points: territory, dame: false,
        options: (draw: tree.territory.draw), forget: item-forget, kill: true))
    }
  }
  for l in lettered { items.push(mark-item(l.at, "custom", content: l.letter)) }
  // La marca de la última jugada: no si es un pase, si el archivo marca ese punto ni si tiene número.
  if o.last-mark != none and last-move != none and last-move.at != none {
    let k = key(last-move.at)
    if k not in marked and k not in labeled and k not in numbered-points {
      let options = o.last-mark
      let shape = options.remove("shape")
      items.push(mark-item(last-move.at, shape, ..options))
    }
  }
  (items, number, turn)
}
