// Los problemas (tsumego): sgf-problem dibuja el enunciado (la posición inicial con sus marcas, quién juega y
// el comentario de la raíz) y un diagrama por cada línea del árbol (cada variante de la solución), numerada
// desde 1, con sus notas y sus comentarios. Con varias partidas, primero todos los enunciados y después las
// soluciones. Todos los diagramas de un problema ven la misma parte del tablero: la vista del archivo (VW)
// o, sin vista, con partial: auto, la que usa el problema. Los diagramas se disponen como los de
// sgf-diagrams.

#import "options.typ": current, apply
#import "board.typ": board, resolve, point-name
#import "texts.typ": word
#import "sgf.typ": check-game, query, sgf, sgf-options, shown-numbers, comment-body, view-between
#import "diagrams.typ": check-shared
#import "arrange.typ": layout-options, arrange

// Las opciones de sgf que fija cada diagrama: no pueden venir en la partida.
#let own-keys = ("from", "to", "variation", "numbers", "last-mark", "step", "restart", "view")

// Las opciones de problems, comprobadas.
#let check-options(d) = {
  check-shared("problems", d)
  if d.statement not in (true, false, "alone") {
    panic("problems.statement es true, false o \"alone\": " + repr(d.statement))
  }
  for key in ("solutions", "verdict", "links", "view") {
    if type(d.at(key)) != bool { panic("problems." + key + " es true o false: " + repr(d.at(key))) }
  }
  if d.to-play not in (auto, "black", "white", none) {
    panic("problems.to-play es auto, \"black\", \"white\" o none: " + repr(d.to-play))
  }
  if d.partial not in (none, auto) and type(d.partial) != str {
    panic("problems.partial es none, auto o dos esquinas, \"A1:E5\": " + repr(d.partial))
  }
  if d.variation-title != auto and type(d.variation-title) != function {
    panic("problems.variation-title es auto o una función del número: n => ...")
  }
  d
}

// Quién juega en la línea leída r: el PL del principio o, si no está, el color de la primera jugada; none si
// no hay ninguno.
#let first-player(r) = {
  for e in r.events {
    if e.kind in ("player", "move") { return e.player }
  }
  none
}

// Si la línea leída r es correcta para player (quien juega): "correct", "wrong" o none. Decide el último GB o
// GW (la posición es buena para Negras o para Blancas); si no hay, la primera jugada con TE o BM (las impares
// son de quien juega: su BM es un error, el del rival no); si no, la palabra RIGHT en un comentario (como en
// goproblems.com).
#let verdict(r, player) = {
  let (position, move, right) = (none, none, false)
  for (k, step) in r.steps.enumerate() {
    for n in step.notes {
      if n.property in ("GB", "GW") and player != none {
        position = if (n.property == "GB") == (player == "black") { "correct" } else { "wrong" }
      } else if n.property in ("TE", "BM") and move == none and k > 0 {
        move = if (n.property == "TE") == calc.odd(k) { "correct" } else { "wrong" }
      }
    }
    if step.comment.contains("RIGHT") { right = true }
  }
  if position != none { position } else if move != none { move } else if right { "correct" }
}

// Con links, el destino de los enlaces de un problema: su enunciado ("statement") o su primera solución ("1"),
// por la partida y un hash del archivo, así se encuentra también desde otro sgf-problem.
#let anchor(game, part) = label("gobanist-problem-" + query(game, (kind: "hash")) + "-" + str(game.game) + "-" + part)

// body con un enlace a target, si está una sola vez en el documento; si no, solo. Necesita context.
#let linked(target, body) = if std.query(target).len() == 1 { link(target, body) } else { body }

// Los diagramas de los problemas games con las opciones de problems options, para arrange: (style, layout,
// items), las opciones comprobadas, la disposición y los diagramas. Necesita context.
#let problem-group(games, options) = {
  let global = current()
  let tree = apply(global, (problems: options))
  let d = check-options(tree.problems)
  let c = d.comments
  let lay = layout-options(tree, "problems")
  let several = games.len() > 1
  // El comienzo del epígrafe: title; con varias partidas, title (o «Problema») y el número de la partida en
  // su archivo.
  let title = if d.title != auto { d.title } else if several { word(tree, "problem") }
  let variation-title = if d.variation-title != auto { d.variation-title }
    else { n => [#word(tree, "variation")~#str(n)] }

  // Cada problema: sus líneas, quién juega, el comienzo de su epígrafe y la parte del tablero que se ve.
  let problems = games.map(game => {
    let shape = query(game, (kind: "shape"))
    let r = query(game, (kind: "read", path: (numbers: ()), chat: d.chat))
    let head = if not several { title } else if title == none { str(game.game) } else [#title~#str(game.game)]
    let rect = if d.view and type(d.partial) != str { view-between(r, 0, 0) }
    let window = if type(d.partial) == str { (partial: d.partial) } else if rect != none {
      let (x1, y1, x2, y2) = rect
      (partial: point-name((x1, y1), tree.use-i) + ":" + point-name((x2, y2), tree.use-i))
    } else if d.partial == auto { (partial: auto) } else { (:) }
    (game: game, paths: shape.paths, root: r, head: head, window: window,
      extent: if rect == none and d.partial == auto { shape.rect },
      player: if d.to-play == auto { first-player(r) } else { d.to-play })
  })

  // El tablero del problema p hasta la jugada to de la línea path, numerado desde 1 y sin marca de la
  // última jugada; lo que capturan sus jugadas no se quita.
  let diagram(p, path, to) = {
    let g = sgf(p.game, from: 1, to: to, variation: path, restart: false, numbers: true, last-mark: none,
      view: false) + (keep: true)
    let resolved = resolve(board(board(captures: "remove", notes: true, ..p.window), ..d.goban, g), global, replace: true)
    if p.extent != none { resolved.extent = p.extent }
    (g, resolved)
  }

  let items = ()
  if d.statement != false {
    for p in problems {
      let (_, resolved) = diagram(p, (), 0)
      let says = if p.player != none { word(tree, p.player + "-to-play") }
      let caption = if p.head == none { says } else if says == none { p.head } else [#p.head: #says]
      let root = comment-body(tree, p.root.steps.at(0), d.annotations)
      let first = p.paths.position(path => query(p.game, (kind: "read", path: (numbers: path), chat: false)).moves > 0)
      if d.links and caption != none and first != none { caption = linked(anchor(p.game, "1"), caption) }
      items.push((resolved: resolved, caption: caption, comments: if c.on and root != none { (root,) } else { () },
        extra: none, alone: d.statement == "alone", anchor: if d.links { anchor(p.game, "statement") }))
    }
  }
  if d.solutions {
    for p in problems {
      for (i, path) in p.paths.enumerate() {
        let line = query(p.game, (kind: "read", path: (numbers: path), chat: d.chat))
        if line.moves == 0 { continue }
        let (g, resolved) = diagram(p, path, auto)
        let numbers = shown-numbers(line, sgf-options(g, resolved.tree))
        let said = if d.verdict { verdict(line, p.player) }
        let caption = [#(if several and p.head != none [#p.head: ])#variation-title(i + 1)#(
          if said != none [ (#word(tree, said))])]
        if d.links { caption = linked(anchor(p.game, "statement"), caption) }
        let parts = ()
        if c.on {
          for k in range(1, line.moves + 1) {
            let body = comment-body(tree, line.steps.at(k), d.annotations)
            if body != none { parts.push((c.number)(numbers.at(k - 1)) + body) }
          }
        }
        let first = d.links and p.paths.slice(0, i).all(path =>
          query(p.game, (kind: "read", path: (numbers: path), chat: false)).moves == 0)
        items.push((resolved: resolved, caption: caption, comments: parts, extra: none, alone: false,
          anchor: if first { anchor(p.game, "1") }))
      }
    }
  }
  (style: d, layout: lay, items: items)
}

// Dibuja un problema, o varios: las partidas van sin nombre (sgf-problem(problema)). Las opciones son las de
// la rama problems (gobanist-set(problems: ...)); las de sgf de cada partida valen en sus tableros, salvo las que
// fija cada diagrama. El metadata de adelante es para goban-layout, que pone los diagramas en su disposición.
#let sgf-problem(..args) = {
  let games = args.pos()
  if games.len() == 0 { panic("sgf-problem espera una partida leída con sgf-read(...), o varias") }
  for game in games {
    check-game("sgf-problem", game)
    for o in game.options {
      for key in o.keys() {
        if key in own-keys { panic("sgf-problem: " + key + " no va en sgf(...): lo fija cada diagrama") }
      }
    }
  }
  let options = args.named()
  [#metadata((kind: "problem", games: games, options: options))<goban-cells>#layout(size => context {
    let group = problem-group(games, options)
    arrange(group.layout, size.width, (group,))
  })]
}
