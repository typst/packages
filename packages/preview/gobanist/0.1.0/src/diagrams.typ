// Los diagramas como en los libros: sgf-diagrams dibuja la partida en tramos de step jugadas (o uno por cada
// figura que marca el archivo, FG), cada uno en su tablero, con su epígrafe («Diagrama 2 (51–100)») y, debajo, sus notas «N en M», los comentarios de sus
// jugadas y, en el último, el resultado. Cada tablero parte de la posición real: las jugadas anteriores van
// sin número y con sus capturas, y lo que capturan las jugadas del tramo no se quita (se
// quitan en el diagrama siguiente). Con variations, después del diagrama donde nace cada variante, su
// diagrama («Diagrama 2a (variante en 3)»), con sus jugadas numeradas desde 1. Si el archivo tiene vista (VW),
// cada diagrama muestra la que abarca las de sus jugadas; donde no, con partial: auto, todos muestran la parte que
// usan las líneas que se dibujan.

#import "options.typ": current, apply
#import "board.typ": board, resolve, point-name
#import "texts.typ": word
#import "arrange.typ": layout-options, arrange
#import "sgf.typ": (
  check-game, query, variation-path, variation-text, sgf, sgf-options, sgf-info, shown-numbers, comment-body,
  view-between,
)

// Las opciones de sgf que fija cada diagrama: no pueden venir en la partida.
#let own-keys = ("from", "to", "variation", "numbers", "marks", "last-mark", "step", "restart", "view")

// Las opciones que sgf-diagrams y sgf-problem comparten (las de la rama name), comprobadas: notes,
// annotations, chat y comments (sin root); goban lo comprueba merge.
#let check-shared(name, d) = {
  for key in ("notes", "annotations", "chat") {
    if type(d.at(key)) != bool { panic(name + "." + key + " es true o false: " + repr(d.at(key))) }
  }
  let c = d.comments
  if type(c.on) != bool { panic(name + ".comments es true, false o un diccionario") }
  if c.position not in (bottom, left, right, "after") {
    panic(name + ".comments.position es bottom, left, right o \"after\": " + repr(c.position))
  }
  if c.width != auto and type(c.width) != length { panic(name + ".comments.width es auto o una longitud") }
  if c.height != none and type(c.height) != length { panic(name + ".comments.height es none o una longitud") }
  if type(c.number) != function { panic(name + ".comments.number es una función del número: n => ...") }
  if type(c.justify) != bool { panic(name + ".comments.justify es true o false") }
}

// Las opciones de diagrams, comprobadas; step queda como arreglo.
#let check-options(d) = {
  check-shared("diagrams", d)
  let step = if type(d.step) == int { (d.step,) } else { d.step }
  if type(step) != array or step.len() == 0 or step.any(n => type(n) != int or n < 1) {
    panic("diagrams.step es un número o un arreglo de números: " + repr(d.step))
  }
  d.step = step
  if type(d.from) != int or d.from < 1 { panic("diagrams.from es un número desde 1: " + repr(d.from)) }
  if d.to != auto and (type(d.to) != int or d.to < 0) { panic("diagrams.to es auto o un número: " + repr(d.to)) }
  for key in ("figures", "view", "numbers", "marks") {
    if type(d.at(key)) != bool { panic("diagrams." + key + " es true o false: " + repr(d.at(key))) }
  }
  if d.partial not in (none, auto) { panic("diagrams.partial es none o auto: " + repr(d.partial)) }
  if d.restart.on not in (true, false, auto) { panic("diagrams.restart es true, false, auto o un diccionario") }
  if type(d.restart.from) != int { panic("diagrams.restart.from es un número: " + repr(d.restart.from)) }
  if type(d.comments.root) != bool { panic("diagrams.comments.root es true o false") }
  if d.result.format not in ("text", "raw") { panic("diagrams.result.format es \"text\" o \"raw\"") }
  let v = d.variations
  if type(v.on) != bool { panic("diagrams.variations es true, false o un diccionario") }
  if v.select not in ("commented", "all") {
    panic("diagrams.variations.select es \"commented\" o \"all\": " + repr(v.select))
  }
  for key in ("depth", "from") {
    if type(v.at(key)) != int or v.at(key) < 1 {
      panic("diagrams.variations." + key + " es un número desde 1: " + repr(v.at(key)))
    }
  }
  if type(v.paths) != array or v.paths.any(p => type(p) not in (array, str)) {
    panic("diagrams.variations.paths es un arreglo de caminos, como ((2,), \"E5, C7, G7\"): " + repr(v.paths))
  }
  if d.variation-title != auto and type(d.variation-title) != function {
    panic("diagrams.variation-title es auto o una función del número: n => ...")
  }
  d
}

// Las variantes que dibuja sgf-diagrams, de las que se apartan de la línea de variation, por la jugada donde
// nacen (las del kernel, branches): con variations.on, las que elige select hasta depth y desde from; y,
// siempre, las de paths.
#let chosen-branches(game, d, use-i) = {
  let v = d.variations
  if not v.on and v.paths.len() == 0 { return () }
  let all = query(game, (kind: "branches", path: variation-path(d.variation, use-i)))
  let paths = all.map(b => b.path)
  let found = v.paths.map(p => {
    let n = query(game, (kind: "numbers", path: variation-path(p, use-i)))
    if n not in paths {
      panic("diagrams.variations.paths: la partida no tiene la variante " + variation-text(p)
        + " o no se aparta de la línea que se dibuja")
    }
    n
  })
  all.filter(b => b.path in found or (v.on and b.depth <= v.depth and b.born >= v.from
    and (v.select == "all" or b.commented)))
}

// Con partial: auto, el rectángulo (x1, y1, x2, y2) con las piedras y las jugadas de las líneas de entries (las de
// sgf-diagrams: la de variation y las de las variantes que se dibujan), aunque pasen de to; none sin piedras.
#let drawn-extent(game, entries, use-i) = {
  let paths = entries.map(e => if e.main { variation-path(e.variation, use-i) } else { (numbers: e.variation) })
  query(game, (kind: "extent", paths: paths.dedup()))
}

// Los tramos de los diagramas hasta la jugada last, cada uno con su número n, sus jugadas (de start a to; from
// es la primera que se dibuja numerada) y el nombre de su figura (name, none sin nombre). Si el archivo marca
// figuras (FG, las del kernel) y d.figures, un tramo por figura, desde donde empieza hasta antes de la
// siguiente, y las jugadas antes de la primera son un tramo más; si no, el tramo n tiene tantas jugadas como
// el elemento n de step (o el último). Con d.from, los mismos tramos (con el mismo número), pero solo los
// que llegan a from, y el primero empieza ahí.
#let diagram-spans(d, figures, last) = {
  let list = ()
  if d.figures and figures.len() > 0 {
    let marks = figures.map(f => (start: f.start, name: f.title))
    if marks.first().start > 1 { marks.insert(0, (start: 1, name: none)) }
    marks.push((start: last + 1, name: none))
    let n = 0
    for (f, next) in marks.zip(marks.slice(1)) {
      if f.start >= next.start or f.start > last { continue }
      n += 1
      let end = calc.min(next.start - 1, last)
      if end >= d.from { list.push((n: n, start: f.start, from: calc.max(f.start, d.from), to: end, name: f.name)) }
    }
    return list
  }
  let (start, n) = (1, 0)
  while start <= last {
    n += 1
    let length = d.step.at(calc.min(n, d.step.len()) - 1)
    let end = calc.min(start + length - 1, last)
    if end >= d.from { list.push((n: n, start: start, from: calc.max(start, d.from), to: end, name: none)) }
    start += length
  }
  list
}

// El resultado re (RE) en palabras, con los textos del idioma: 0 o Draw, Void, ?, y B+ o W+ seguido de nada,
// de los puntos, de R (Resign), T (Time) o F (Forfeit). Otra cosa queda como está. names: los nombres del
// ganador.
#let result-text(tree, re, names) = {
  let w(key) = word(tree, key)
  let low = lower(re)
  if low in ("0", "draw") { return w("draw") }
  if low == "void" { return w("void") }
  if low == "?" { return w("unknown-result") }
  let m = re.match(regex("^([BbWw])\+(.*)$"))
  if m == none { return re }
  let winner = if upper(m.captures.at(0)) == "B" { names.black } else { names.white }
  let rest = m.captures.at(1)
  let kind = lower(rest)
  if kind == "" { w("win")(winner) }
  else if kind in ("r", "resign") { w("win-by-resignation")(winner) }
  else if kind in ("t", "time") { w("win-on-time")(winner) }
  else if kind in ("f", "forfeit") { w("win-by-forfeit")(winner) }
  else if rest.match(regex("^\d+(\.\d*)?$")) != none { w("win-by-points")(winner, rest) }
  else { re }
}

// Los diagramas de la partida game con las opciones de diagrams options, para arrange: (style, layout, items),
// las opciones comprobadas, la disposición y los diagramas. Necesita context.
#let diagram-group(game, options) = {
  let global = current()
  let tree = apply(global, (diagrams: options))
  let d = check-options(tree.diagrams)
  let c = d.comments
  let lay = layout-options(tree, "diagrams")

  let r = query(game, (kind: "read", path: variation-path(d.variation, tree.use-i), chat: d.chat))
  if r.missing { panic("la partida no tiene la variante " + variation-text(d.variation)) }
  let total = r.moves
  let last = if d.to == auto { total } else { calc.min(d.to, total) }
  let spans = diagram-spans(d, r.figures, last)
  if spans.len() == 0 { return (style: d, layout: lay, items: ()) }

  let title = if d.title == auto { word(tree, "diagram") } else { d.title }
  let variation-title = if d.variation-title == auto { word(tree, "variation-at") } else { d.variation-title }
  // Los diagramas: el de cada tramo (con el nombre de su figura, si lo tiene, en lugar de «Diagrama n») y,
  // después, las variantes que nacen en él («Diagrama 3a», «3b»...), cada una entera, desde su primera
  // jugada propia (la que reemplaza), numerada desde 1.
  let branches = chosen-branches(game, d, tree.use-i)
  let entries = ()
  for span in spans {
    let head = if span.name != none { span.name } else [#title~#str(span.n)]
    entries.push((main: true, span: span, variation: d.variation, line: r,
      caption: [#head (#str(span.from)–#str(span.to))]))
    for (i, b) in branches.filter(b => span.start <= b.born and b.born <= span.to).enumerate() {
      entries.push((main: false, span: (n: span.n, start: b.start, from: b.start, to: b.last),
        variation: b.path, line: query(game, (kind: "read", path: (numbers: b.path), chat: d.chat)),
        caption: [#title~#str(span.n)#numbering("a", i + 1) (#variation-title(b.start))]))
    }
  }

  // Cada tablero, resuelto. Con restart: true, desde el segundo tramo la primera jugada se muestra como
  // restart.from, y el tablero no reinicia por su cuenta. Con view, la vista de sus jugadas es su partial;
  // si no tiene, con partial: auto, ve lo que dibuja y extent (el partial de goban les gana).
  let extent = if d.partial == auto { drawn-extent(game, entries, tree.use-i) }
  let diagrams = entries.map(entry => {
    let span = entry.span
    let first = if not entry.main { 1 }
      else if d.restart.on == true and span.start > 1 { d.restart.from + span.from - span.start }
    let g = sgf(game, from: span.from, to: span.to, variation: entry.variation,
      restart: if entry.main and d.restart.on == auto { auto } else { false }, numbers: d.numbers,
      marks: d.marks, last-mark: d.last-mark, view: false) + (keep: true, first: first)
    let rect = if d.view { view-between(entry.line, span.from, span.to) }
    let window = if rect == none { if d.partial == auto { (partial: auto) } else { (:) } } else {
      let (x1, y1, x2, y2) = rect
      (partial: point-name((x1, y1), tree.use-i) + ":" + point-name((x2, y2), tree.use-i))
    }
    let resolved = resolve(board(captures: "remove", notes: true, ..window, ..d.goban, g), global, replace: true)
    if rect == none and extent != none { resolved.extent = extent }
    entry + (resolved: resolved, numbers: shown-numbers(entry.line, sgf-options(g, resolved.tree), first: first))
  })

  // Los comentarios del diagrama, cada uno con el número que se ve de su jugada; con root, el de la raíz
  // antes (no en las variantes).
  let comments(item) = {
    let span = item.span
    let steps = item.line.steps
    let parts = ()
    if c.root and item.main and span.from == 1 {
      let body = comment-body(tree, steps.at(0), d.annotations)
      if body != none { parts.push(body) }
    }
    for k in range(span.from, span.to + 1) {
      let body = comment-body(tree, steps.at(k), d.annotations)
      if body != none { parts.push((c.number)(item.numbers.at(k - 1)) + body) }
    }
    parts
  }
  // El resultado (RE) y, si el archivo marca territorio (TB, TW), el puntaje, con el komi de KM.
  let names = (
    black: if d.result.black == auto { word(tree, "black") } else { d.result.black },
    white: if d.result.white == auto { word(tree, "white") } else { d.result.white },
  )
  let result(resolved) = {
    let re = sgf-info(game, "RE").trim()
    let territory = resolved.territory.len() > 0
    if re == "" and not territory { return none }
    let said = if re == "" { none } else if d.result.format == "raw" { re } else { result-text(tree, re, names) }
    let score = if territory {
      let s = resolved.score
      let body = [#names.black~#str(s.black), #names.white~#str(s.white + float(r.komi))]
      if said == none { body } else { [ (#body)] }
    }
    [#(if d.result.title == auto { word(tree, "result") } else { d.result.title }): #said#score]
  }

  (style: d, layout: lay, items: diagrams.map(item => (
    resolved: item.resolved,
    caption: item.caption,
    comments: if c.on { comments(item) } else { () },
    extra: if d.result.on and item.main and item.span.to == total { result(item.resolved) },
    alone: false,
  )))
}

// Dibuja la partida en diagramas. Las opciones son las de la rama diagrams (gobanist-set(diagrams: ...)); las de
// sgf de la partida (sgf(partida, ...)) valen en cada tablero, salvo las que fija cada diagrama. El metadata de
// adelante es para goban-layout, que pone los diagramas en su disposición.
#let sgf-diagrams(game, ..args) = {
  check-game("sgf-diagrams", game)
  if args.pos().len() > 0 { panic("sgf-diagrams recibe una partida y opciones con nombre") }
  for o in game.options {
    for key in o.keys() {
      if key in own-keys { panic("sgf-diagrams: " + key + " va en sgf-diagrams(...), no en sgf(...)") }
    }
  }
  let options = args.named()
  [#metadata((kind: "diagrams", game: game, options: options))<goban-cells>#layout(size => {
    let group = diagram-group(game, options)
    arrange(group.layout, size.width, (group,))
  })]
}
