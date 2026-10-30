// El tablero como valor: sus opciones y lo que tiene, sin resolver. Se resuelve al dibujarlo, cuando se
// conocen las opciones globales.

#import "options.typ": apply
#import "coordinates.typ": parse, corners, column-letter
#import "kernel.typ": simulate
#import "sgf.typ": expand, sgf-view

// Un tablero: board(size: 5, stones(black: "C2, D3"), moves("C3")). Un tablero hecho con board puede ir primero:
// es ese tablero, con sus opciones y lo que tiene, más lo que se agrega (board(base, moves("C3")), goban(base)).
// layers son las opciones en el orden en que se dieron: se aplican una tras otra, rama por rama (options las junta,
// para saber si el tablero da una). Se guardan una sola vez: con resume encadenado, guardarlas también juntas
// duplicaría el tablero de resume en cada paso.
#let board(..args) = {
  let elements = args.pos()
  let (layers, own) = ((), ())
  if elements.len() > 0 and type(elements.first()) == dictionary and "goban-board" in elements.first() {
    let base = elements.remove(0)
    (layers, own) = (base.layers, base.elements)
  }
  for e in elements {
    if type(e) == dictionary and "goban-board" in e {
      panic("un tablero hecho con board(...) va primero, y uno solo; para seguir desde otro, resume")
    }
    if type(e) != dictionary or "kind" not in e {
      panic("lo que va en un tablero son piedras, jugadas, marcas o una partida: stones(...), moves(...), marks(...)")
    }
  }
  let layers = layers + (args.named(),)
  (goban-board: true, layers: layers, elements: own + elements)
}

// Las opciones del tablero, todas juntas: para saber si da una (size, partial, resume, captures).
#let options(b) = b.layers.fold((:), (a, layer) => a + layer)

// resume: un tablero (trae solo las piedras) o (board: ..., numbers: true, marks: true, territory: true).
#let resume-spec(value) = {
  let spec = if type(value) == dictionary and "goban-board" in value {
    (board: value)
  } else if type(value) == dictionary and "board" in value {
    for key in value.keys() {
      if key not in ("board", "numbers", "marks", "territory") { panic("resume no tiene la opción " + key) }
    }
    value
  } else {
    panic("resume espera un tablero hecho con board(...) o (board: ..., numbers: ..., marks: ..., territory: ...)")
  }
  if type(spec.board) != dictionary or "goban-board" not in spec.board {
    panic("resume espera un tablero hecho con board(...)")
  }
  (
    board: spec.board,
    numbers: spec.at("numbers", default: false),
    marks: spec.at("marks", default: false),
    territory: spec.at("territory", default: false),
  )
}

// El tamaño que da el propio tablero, el del que retoma o el de su partida (SGF); none si no da ninguno (vale
// el global).
#let own-size(b) = {
  let game = b.elements.find(e => e.kind == "sgf")
  let given = options(b)
  if "size" in given { given.size }
  else if "resume" in given { own-size(resume-spec(given.resume).board) }
  else if game != none { game.size }
  else { none }
}

// Columnas y filas.
#let dimensions(size) = {
  let (cols, rows) = if type(size) == int { (size, size) } else if type(size) == array and size.len() == 2 {
    size
  } else {
    panic("size espera un número o (columnas, filas)")
  }
  if cols < 2 or rows < 2 or cols > 25 or rows > 99 { panic("tamaño fuera de rango: " + repr(size)) }
  (cols, rows)
}

#let point-name(p, use-i) = column-letter(p.at(0), use-i) + str(p.at(1))

// La parte de partial = "A1:E5": (x1, y1, x2, y2), de abajo a la izquierda a arriba a la derecha.
#let partial-window(text, tree, cols, rows) = {
  let c = corners(text.trim(), tree.use-i)
  if c == none or text.matches(":").len() != 1 {
    panic("partial espera dos esquinas, como \"B2:D4\": «" + text + "»")
  }
  let (x1, y1, x2, y2) = c
  for (x, y) in ((x1, y1), (x2, y2)) {
    if x > cols or y > rows { panic("partial: «" + text + "» no está en el tablero") }
  }
  (calc.min(x1, x2), calc.min(y1, y2), calc.max(x1, x2), calc.max(y1, y2))
}

// Las intersecciones de las coordenadas; todas tienen que estar en el tablero.
#let points(at, tree, window, cols, rows, moves: false) = {
  if type(at) != str { panic("las coordenadas son texto: " + repr(at)) }
  let result = parse(at, use-i: tree.use-i, window: window, moves: moves)
  for p in result.points {
    if p.at(0) < 1 or p.at(1) < 1 or p.at(0) > cols or p.at(1) > rows {
      panic(point-name(p, tree.use-i) + " no está en el tablero de " + str(cols) + "×" + str(rows))
    }
  }
  result.points
}

#let other(player) = if player == "black" { "white" } else { "black" }

// Lo que el kernel tiene que saber de cada cosa del tablero (none si no le importa): las piedras, las
// jugadas, las piedras que se quitan y los territorios.
#let event(item) = {
  if item.kind == "stone" {
    let kind = if item.move and not item.resumed { "move" } else { "stone" }
    (kind: kind, x: item.x, y: item.y, player: item.player, dead: item.prisoner)
  } else if item.kind == "remove" {
    (kind: "remove", x: item.x, y: item.y)
  } else if item.kind == "territory" {
    (kind: "territory", mode: item.mode, player: item.player, vertices: item.vertices, points: item.points,
      dame: item.dame, region: item.options.draw == "region", kill: item.at("kill", default: false))
  } else { none }
}

// Resuelve el tablero con el árbol global: devuelve su árbol de opciones, su tamaño, lo que dibuja (items,
// en orden), con qué número y qué jugador sigue y, del kernel, los prisioneros, el territorio que queda al
// final (territory: (x, y, dueño, el item que lo marcó)), las regiones y el puntaje.
//   piedra: (kind: "stone", x, y, player, options, mark, prisoner, number, numbered, move, resumed,
//            move-options, forget, captured)
//   marca:  (kind: "mark", x, y, shape, player, options, number, forget, captured)
//   flecha o línea: (kind: "arrows" o "lines", x, y, to: (x, y), options, forget)
//   territorio: (kind: "territory", player, mode, vertices, points, dame, options, forget)
//   pase (de una partida): (kind: "pass", player, number, numbered, forget)
//   piedra que se quita (AE de una partida): (kind: "remove", x, y, forget)
// captured es none o el item de la jugada que capturó la piedra (o el de la piedra de la marca, con
// captured-marks: "remove"; o el del remove que la quitó, y entonces la piedra tiene removed: true). Una
// marca con over-number: "hide" (una etiqueta de una partida) no se dibuja sobre una jugada numerada que se
// ve. Con replace, una jugada en un punto ocupado quita la piedra que había (sin replace, es un error).
#let resolve(b, global, replace: false) = {
  let options = options(b)
  let spec = if "resume" in options { resume-spec(options.remove("resume")) } else { none }
  let tree = b.layers.fold(global, (t, layer) => {
    let layer = layer
    let _ = layer.remove("resume", default: none)
    apply(t, layer)
  })
  let size = own-size(b)
  if size != none { tree.size = size }
  let (cols, rows) = dimensions(tree.size)
  // La vista de la partida es su partial, salvo que el tablero dé el suyo.
  let game = b.elements.find(e => e.kind == "sgf")
  let rect = if game != none and "partial" not in options { sgf-view(game, tree) }
  if rect != none {
    let (x1, y1, x2, y2) = rect
    tree.partial = point-name((x1, y1), tree.use-i) + ":" + point-name((x2, y2), tree.use-i)
  }
  let window = if type(tree.partial) == str { partial-window(tree.partial, tree, cols, rows) } else {
    (1, 1, cols, rows)
  }
  if tree.captures not in (none, "remove", "fade") { panic("captures es none, \"remove\" o \"fade\"") }
  if tree.captured-marks not in ("keep", "remove") { panic("captured-marks es \"keep\" o \"remove\"") }

  let items = ()
  let number = 1
  let turn = "black"
  let prisoners = (black: 0, white: 0)
  if spec != none {
    // El tablero como quedó: sin lo capturado (o con lo capturado como prisionero, con captures: "fade").
    let source = resolve(spec.board, global)
    if source.tree.captures != none and "captures" not in options { tree.captures = source.tree.captures }
    for it in source.items {
      if it.forget == true or it.kind in ("territory", "pass", "remove") or it.at("removed", default: false) {
        continue
      }
      if it.kind in ("mark", "arrows", "lines") and not spec.marks { continue }
      if it.at("captured", default: none) != none {
        if it.kind == "mark" or source.tree.captures == "remove" { continue }
        it.prisoner = true
        it.captured = none
      }
      if it.kind == "stone" {
        if not spec.marks { it.mark = none }
        if not spec.numbers or it.forget == "number" { it.numbered = false }
        it.resumed = true
      }
      it.forget = false
      items.push(it)
    }
    if spec.territory {
      // Cada territorio trae los puntos que le quedaron.
      for (i, it) in source.items.enumerate() {
        if it.kind != "territory" or it.forget { continue }
        let mine = source.territory.filter(t => t.at(3) == i)
        if mine.len() == 0 { continue }
        it.mode = "points"
        it.points = mine.map(((x, y, o, _)) => (x, y, o))
        items.push(it)
      }
    }
    (number, turn, prisoners) = (source.number, source.turn, source.prisoners)
  }

  for e in b.elements {
    if e.kind in ("stones", "prisoners") {
      let style = e.options
      let mark = style.remove("mark")
      let forget = style.remove("forget")
      for g in e.groups {
        for (x, y) in points(g.at, tree, window, cols, rows) {
          items.push((kind: "stone", x: x, y: y, player: g.player, options: style, mark: mark,
            prisoner: e.prisoner, number: none, numbered: false, move: false, resumed: false,
            move-options: (:), forget: forget, captured: none))
        }
      }
    } else if e.kind == "moves" {
      let style = e.options
      let mark = style.remove("mark")
      let forget = style.remove("forget")
      let move-options = (:)
      for key in ("numbers", "label") {
        if key in style { move-options.insert(key, style.remove(key)) }
      }
      if "from" in style { number = style.remove("from") }
      if e.first != auto { turn = e.first }
      for (x, y) in points(e.at, tree, window, cols, rows, moves: true) {
        items.push((kind: "stone", x: x, y: y, player: turn, options: style, mark: mark,
          prisoner: false, number: number, numbered: true, move: true, resumed: false,
          move-options: move-options, forget: forget, captured: none))
        number += 1
        turn = other(turn)
      }
    } else if e.kind == "marks" {
      let style = e.options
      let player = style.remove("player", default: auto)
      let sequence = style.remove("from", default: 1)
      let forget = style.remove("forget")
      for g in e.groups {
        for (x, y) in points(g.at, tree, window, cols, rows) {
          items.push((kind: "mark", x: x, y: y, shape: g.shape, player: player, options: style,
            number: if g.shape == "sequence" { sequence } else { none }, forget: forget, captured: none))
          if g.shape == "sequence" { sequence += 1 }
        }
      }
    } else if e.kind in ("arrows", "lines") {
      let style = e.options
      let forget = style.remove("forget")
      for (from, to) in e.pairs {
        let (a, b) = (from, to).map(c => {
          let p = points(c, tree, window, cols, rows)
          if p.len() != 1 { panic(e.kind + " va de una intersección a otra: «" + c + "»") }
          p.first()
        })
        // x e y son el primer extremo: con él se decide si se ve y la parte de partial: auto.
        items.push((kind: e.kind, x: a.at(0), y: a.at(1), to: b, options: style, forget: forget))
      }
    } else if e.kind == "sgf" {
      let (more, next, player) = expand(e, tree, cols, rows, turn)
      items += more
      (number, turn) = (next, player)
    } else if e.kind == "territory" {
      let style = e.options
      let forget = style.remove("forget")
      let dame = style.remove("dame", default: tree.territory.dame)
      if "draw" not in style { style.draw = tree.territory.draw }
      for r in e.requests {
        let (mode, vertices) = if r.area == auto { ("auto", ()) } else {
          ("polygon", points(r.area, tree, window, cols, rows))
        }
        items.push((kind: "territory", player: r.player, mode: mode, vertices: vertices, points: (),
          dame: dame, options: style, forget: forget))
      }
    } else {
      panic("elemento desconocido: " + repr(e.kind))
    }
  }

  // El kernel juega la partida si hay capturas o territorio.
  let territory = ()
  let regions = (black: none, white: none)
  let score = (black: 0, white: 0, neutral: 0)
  if tree.captures != none or items.any(i => i.kind == "territory") {
    let events = ()
    let owners = ()
    for (i, it) in items.enumerate() {
      let e = event(it)
      if e != none {
        events.push(e)
        owners.push(i)
      }
    }
    let result = simulate((size: (cols, rows), captures: tree.captures != none, replace: replace,
      prisoners: prisoners, events: events))
    for (move, stones) in result.captured {
      let by = owners.at(move)
      for s in stones.map(e => owners.at(e)) {
        items.at(s).captured = by
        // Con captured-marks: "remove", las marcas que se pusieron sobre la piedra se van con ella.
        if tree.captured-marks == "remove" {
          let (x, y) = (items.at(s).x, items.at(s).y)
          for k in range(s + 1, by) {
            let it = items.at(k)
            if it.kind == "mark" and it.x == x and it.y == y and it.captured == none { items.at(k).captured = s }
          }
          items.at(s).mark = none
        }
      }
    }
    for (by, s) in result.removed {
      items.at(owners.at(s)).captured = owners.at(by)
      items.at(owners.at(s)).removed = true
    }
    prisoners = result.prisoners
    territory = result.territory.map(((x, y, o, e)) => (x, y, o, owners.at(e)))
    regions = (black: result.black, white: result.white)
    score = result.score
  }
  // Las etiquetas de una partida no tapan el número de una jugada que se ve: quedan con captured y over, el
  // item de la jugada (goban-view las muestra si esconde el número).
  for (k, it) in items.enumerate() {
    if it.kind != "mark" or it.at("over-number", default: none) != "hide" or it.captured != none { continue }
    let below = items.slice(0, k).enumerate().find(((_, s)) => s.kind == "stone" and s.x == it.x and s.y == it.y
      and s.numbered and s.captured == none)
    if below != none {
      items.at(k).captured = below.at(0)
      items.at(k).over = below.at(0)
    }
  }
  (tree: tree, cols: cols, rows: rows, items: items, number: number, turn: turn, prisoners: prisoners,
    territory: territory, regions: regions, score: score)
}
