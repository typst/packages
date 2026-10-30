// Las vistas: una parte de un tablero, como quedó al terminar, en medio del texto.

#import "options.typ": current, apply
#import "board.typ": board, resolve
#import "coordinates.typ": corners
#import "draw/goban.typ": draw
#import "texts.typ": word
#import "elements.typ": stones, prisoners, moves, stone-keys

// Las opciones de tablero que cambian la partida o lo que se ve de ella: en una vista son error, porque la
// partida ya está jugada y la parte es la de la vista.
#let game-keys = ("size", "use-i", "partial", "captures", "captured-marks", "territory", "sgf")

// El tablero resuelto, con hide en lo que la vista no dibuja (lo olvidado, salvo con forgotten; las marcas, las
// flechas, las líneas y el territorio que se apagan) y sin los números o las marcas de las piedras que se apagan.
// Las etiquetas de una partida escondidas bajo el número de una jugada se ven si la vista esconde el número.
#let seen(resolved, v) = {
  let off = (mark: v.marks, arrows: v.arrows, lines: v.lines, territory: v.territory)
  let hidden(i) = (i.forget == true and not v.forgotten) or not off.at(i.kind, default: true)
  resolved.items = resolved.items.map(i => {
    if hidden(i) { i.hide = true }
    if i.kind == "stone" {
      if not v.marks { i.mark = none }
      if not v.numbers or (i.forget == "number" and not v.forgotten) { i.numbered = false }
    }
    i
  })
  let items = resolved.items
  resolved.items = items.map(i => {
    let over = i.at("over", default: none)
    if over != none and (not items.at(over).numbered or items.at(over).at("hide", default: false)) {
      i.captured = none
    }
    i
  })
  let items = resolved.items
  resolved.territory = resolved.territory.filter(t => not items.at(t.at(3)).at("hide", default: false))
  if not v.territory { resolved.regions = (black: none, white: none) }
  resolved
}

// La vista de una parte ("C3" o "B2:E4") del tablero resuelto, con las opciones v de la rama view y, encima,
// las de tablero extra.
#let view-part(resolved, v, part, extra) = {
  let tree = apply(apply(resolved.tree, v.goban), extra)
  let part = part.trim()
  tree.partial = if part.contains(":") { part } else { part + ":" + part }
  let c = corners(tree.partial, tree.use-i)
  if c == none or tree.partial.matches(":").len() != 1 {
    panic("goban-view espera intersecciones o rectángulos separados por comas, \"C3, B2:E4\": «" + part + "»")
  }
  if calc.max(c.at(0), c.at(2)) > resolved.cols or calc.max(c.at(1), c.at(3)) > resolved.rows {
    panic("goban-view: «" + part + "» no está en el tablero de " + str(resolved.cols) + "×" + str(resolved.rows))
  }
  resolved.tree = tree
  let raise = if v.raise == auto {
    measure(text(top-edge: "x-height", bottom-edge: "baseline", "x")).height / 2
  } else { v.raise }
  box(baseline: 50% - raise, draw(resolved).body)
}

// Dibuja las partes de un tablero (un board(...) o un elemento, como una partida) en el texto, cada una con su
// centro a raise sobre la línea de base: una intersección ("C3"), un rectángulo ("B2:E4") o varias, separadas
// por comas ("F15, G15, C3:E5"), unidas con separator y, antes de la última, last. Las opciones son las de la
// rama view (gobanist-set(view: ...)). No cambia lo que dicen goban-score, goban-prisoners, goban-notes ni
// goban-region.
#let views(value, part, args, extra) = context {
  if args.pos().len() > 0 { panic("goban-view recibe un tablero, la parte y opciones con nombre") }
  let b = if type(value) == dictionary and "goban-board" in value { value }
    else if type(value) == dictionary and "kind" in value { board(value) }
    else { panic("goban-view espera un tablero hecho con board(...) o una partida: " + repr(value)) }
  if type(part) != str { panic("goban-view espera la parte como texto, \"C3\", \"B2:E4\" o \"C3, D4\": " + repr(part)) }
  let global = current()
  let v = apply(global, (view: args.named())).view
  for key in ("marks", "arrows", "lines", "numbers", "territory", "forgotten") {
    if type(v.at(key)) != bool { panic("view." + key + " es true o false: " + repr(v.at(key))) }
  }
  if v.raise != auto and type(v.raise) != length { panic("view.raise es auto o una longitud: " + repr(v.raise)) }
  for key in ("separator", "last") {
    let value = v.at(key)
    if not (key == "last" and value == auto) and type(value) not in (str, content) {
      panic("view." + key + " es un texto o un contenido" + if key == "last" { ", o auto" } + ": " + repr(value))
    }
  }
  for key in v.goban.keys() {
    if key in game-keys { panic("view.goban no puede cambiar " + key + ": es del tablero que se ve") }
  }

  let resolved = seen(resolve(b, global), v)
  let drawn = part.split(",").map(p => view-part(resolved, v, p, extra))
  if drawn.len() == 1 { return drawn.first() }
  let last = if v.last == auto { " " + word(global, "and") + " " } else { v.last }
  drawn.slice(0, -1).join(v.separator) + last + drawn.last()
}

#let goban-view(value, part, ..args) = views(value, part, args, (:))

// Una piedra sola en el texto, sin tablero: la de player ("black", "white" o, sin él, neutral), con mark,
// prisoner y el estilo de la piedra (las opciones de stones); con number, una jugada con ese número. Lleva el
// estilo de ese lugar y, encima, el de las vistas (view.goban, view.raise), como la vista de una intersección.
#let goban-stone(..args) = {
  let pos = args.pos()
  if pos.len() > 1 or pos.any(p => p not in ("black", "white", "neutral")) {
    panic("goban-stone recibe el jugador, \"black\", \"white\" o \"neutral\": " + pos.map(repr).join(", "))
  }
  let player = pos.at(0, default: "neutral")
  let options = args.named()
  let number = options.remove("number", default: none)
  let prisoner = options.remove("prisoner", default: false)
  if type(prisoner) != bool { panic("goban-stone: prisoner es true o false: " + repr(prisoner)) }
  for key in options.keys() {
    if key not in stone-keys + ("mark",) { panic("goban-stone no tiene la opción " + key) }
  }
  let element = if number != none {
    if type(number) != int or number < 1 { panic("goban-stone: number es un número desde 1: " + repr(number)) }
    if player == "neutral" { panic("goban-stone: una piedra con number es de negras o de blancas") }
    if prisoner { panic("goban-stone: una piedra con number no puede ser prisionera") }
    moves(..((player): "A1"), from: number, ..options)
  } else if prisoner { prisoners(..((player): "A1"), ..options) } else { stones(..((player): "A1"), ..options) }
  // Sin grilla ni fondo, aunque view.goban traiga un perfil.
  views(board(size: 2, partial: none, element), "A1", arguments(),
    (grid: false, hoshi: false, background: false, label: (at: ())))
}
