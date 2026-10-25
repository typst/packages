// Las vistas: una parte de un tablero, como quedó al terminar, en medio del texto.

#import "options.typ": current, apply
#import "board.typ": board, resolve
#import "coordinates.typ": corners
#import "draw/goban.typ": draw

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

// Dibuja la parte part ("C3" o "B2:E4") del tablero (un board(...) o un elemento, como una partida) en el texto,
// con su centro a raise sobre la línea de base. Las opciones son las de la rama view (goban-set(view: ...)). No
// cambia lo que dicen goban-score, goban-prisoners, goban-notes ni goban-region.
#let goban-view(value, part, ..args) = context {
  if args.pos().len() > 0 { panic("goban-view recibe un tablero, la parte y opciones con nombre") }
  let b = if type(value) == dictionary and "goban-board" in value { value }
    else if type(value) == dictionary and "kind" in value { board(value) }
    else { panic("goban-view espera un tablero hecho con board(...) o una partida: " + repr(value)) }
  if type(part) != str { panic("goban-view espera la parte como texto, \"C3\" o \"B2:E4\": " + repr(part)) }
  let global = current()
  let v = apply(global, (view: args.named())).view
  for key in ("marks", "arrows", "lines", "numbers", "territory", "forgotten") {
    if type(v.at(key)) != bool { panic("view." + key + " es true o false: " + repr(v.at(key))) }
  }
  if v.raise != auto and type(v.raise) != length { panic("view.raise es auto o una longitud: " + repr(v.raise)) }
  for key in v.goban.keys() {
    if key in game-keys { panic("view.goban no puede cambiar " + key + ": es del tablero que se ve") }
  }

  let resolved = seen(resolve(b, global), v)
  let tree = apply(resolved.tree, v.goban)
  let part = part.trim()
  tree.partial = if part.contains(":") { part } else { part + ":" + part }
  let c = corners(tree.partial, tree.use-i)
  if c == none or tree.partial.matches(":").len() != 1 {
    panic("goban-view espera una intersección o dos esquinas, \"C3\" o \"B2:E4\": «" + part + "»")
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
