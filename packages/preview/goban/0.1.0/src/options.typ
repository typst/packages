// El árbol de opciones y su mezcla.
//
// Las opciones se mezclan rama por rama. En una rama que tiene on, true y false solo cambian on: prenden
// y apagan; un diccionario ajusta las demás ramas sin prender. Una longitud sobre una rama de longitudes
// (sep, rounded-corners) va a todas. En una rama de imagen (la que tiene file), lo que no es un diccionario
// es el archivo. Cualquier otro valor reemplaza al anterior.

#import "texts.typ": texts
#import "profiles.typ": profiles
#import "elements.typ": mark-keys

#let player-names = ("neutral", "black", "white")

// Las ramas cuyas claves no se conocen de antemano: text es lo que recibe text(); prisoner, las opciones de
// piedra de los prisioneros (se comprueban al mezclarlas con las de la piedra); texts, los idiomas.
#let open-branches = ("text", "prisoner", "texts")
// Los subárboles abiertos hasta el fondo: las opciones de los tableros de sgf-diagrams y sgf-problem y su
// layout, que se comprueban al usarlas.
#let open-trees = ("diagrams.goban", "diagrams.layout", "problems.goban", "problems.layout", "view.goban")

#let path-text(path) = path.join(".")

#let merge(base, new, path: (), open: false) = {
  if type(base) != dictionary { return new }
  // restart también acepta auto (lo que dice PM).
  if (type(new) == bool or (new == auto and path.last(default: none) == "restart")) and "on" in base {
    base.on = new
    return base
  }
  if "file" in base and type(new) != dictionary {
    base.file = new
    return base
  }
  if type(new) == length and base.len() > 0 and base.values().all(v => type(v) == length) {
    return base.keys().fold((:), (d, k) => { d.insert(k, new); d })
  }
  if type(new) != dictionary {
    panic("la opción " + path-text(path) + " no acepta " + repr(new))
  }
  let deep = open or path-text(path) in open-trees
  let open = deep or (path.len() > 0 and path.last() in open-branches)
  for (key, value) in new {
    if key in base {
      base.insert(key, merge(base.at(key), value, path: path + (key,), open: deep))
    } else if open {
      base.insert(key, value)
    } else {
      panic("opción desconocida: " + path-text(path + (key,)))
    }
  }
  base
}

// Los colores de pgf-go (los de xcolor): gray es la mitad de negro, y el brillo, gray!50!white.
#let pgf-gray = luma(50%)
#let shine-gray = luma(75%)

// La imagen de la sombra o del brillo de una piedra.
#let overlay-image = (file: none, width: auto, rotate: 0deg, silhouette: false)

// El estilo inicial de un jugador: el relleno de sus piedras, el color de lo que se escribe encima y su
// territorio.
#let player-defaults(fill, ink, territory) = (
  stone: (
    fill: (on: true, color: fill, opacity: 1, pattern: none),
    line: (on: true, color: black, width: 0.7pt, opacity: 1),
    radius: 5.5pt,
    scale: 1,
    shadow: (on: false, angle: 0deg, offset: 1pt, opacity: 0.5, color: black, scale: 1, image: overlay-image),
    shine: (on: false, angle: 0deg, opacity: 1, color: shine-gray, image: overlay-image),
    image: (file: none, width: auto, rotate: 0deg, opacity: 1),
  ),
  prisoner: (fill: (opacity: 0.5)),
  move: (
    numbers: true,
    label: (format: "1", size: auto, text: (weight: "bold", fill: ink)),
  ),
  mark: (
    line: (color: ink, width: 1pt, opacity: 1),
    fill: (on: true, color: pgf-gray, opacity: 1, pattern: none),
    label: (format: "1", size: auto, text: (fill: ink)),
    scale: 1,
  ),
  territory: territory,
)

// El territorio de un jugador: la marca de cada punto (draw: "marks"), el relleno ("fill" y "region") y, con
// "region", el contorno y sus vértices.
#let territory-defaults(mark, fill, opacity, line) = (
  mark: mark,
  fill: (on: true, color: fill, opacity: opacity, pattern: none),
  line: (on: false, color: line, width: 1.2pt, opacity: 1, above: true),
  vertices: (on: false, radius: 2pt, color: auto),
)

// Las flechas y las líneas.
#let stroke-defaults = (
  color: black,
  width: 1.2pt,
  opacity: 1,
  dash: "solid",
  shorten: 0pt,
  bend: 0deg,
  halo: (on: true, color: auto, width: 0.8pt),
)

// El epígrafe y los comentarios de los diagramas (sgf-diagrams y sgf-problem).
#let caption-defaults = (text: (size: 0.9em), min-width: 8em)
#let comments-defaults = (
  text: (:),
  align: left,
  justify: false,
  number: n => [#strong(str(n)): ],
  separator: parbreak(),
  position: bottom,
  width: auto,
  sep: 1em,
  height: none,
)

// Los valores iniciales: los del perfil default de pgf-go.
#let defaults = (
  size: 9,
  use-i: false,
  partial: none,
  partial-margin: 1,
  scale: 1,
  scale-line-width: false,
  background: (
    on: true,
    fill: (
      on: true, color: white, opacity: 1, pattern: none,
      image: (file: none, fit: "cover", anchor: bottom + left, width: auto, tiles: auto, rotate: 0deg),
    ),
    line: (on: true, color: black, width: 0.75pt, opacity: 1),
    sep: 0.825em,
    rounded-corners: (outer: 0pt, inner: 0pt),
    shadow: (on: false, angle: -45deg, offset: 1.5pt, opacity: 0.5, color: black),
  ),
  grid: (
    on: true,
    line: (on: true, color: black, width: 0.55pt, opacity: 1),
    sep: (x: 1.25em, y: 1.25em),
    image: (file: none, fit: "stretch", tiles: auto, rotate: 0deg),
  ),
  hoshi: (on: true, radius: 1.5pt, color: auto, opacity: auto, at: auto, image: (file: none, width: auto, rotate: 0deg)),
  label: (
    at: (),
    sep: 0.35cm,
    text: (:),
    columns: "A",
    rows: "1",
    columns-direction: ltr,
    rows-direction: btt,
  ),
  players: (
    neutral: player-defaults(pgf-gray, black, territory-defaults("t-square", pgf-gray, 0.35, pgf-gray)),
    black: player-defaults(black, white, territory-defaults("t-circle", black, 0.35, black)),
    white: player-defaults(white, black, territory-defaults("t-square", luma(80%), 0.7, luma(40%))),
  ),
  arrow: stroke-defaults + (tip: "stealth", tips: "end"),
  line: stroke-defaults,
  // El juego: captures es none, "remove" o "fade"; captured-marks, "keep" o "remove".
  captures: none,
  captured-marks: "keep",
  notes: (on: false, at: auto, separator: ", "),
  territory: (draw: "marks", dame: false),
  score: (komi: 0),
  // El elemento sgf: qué jugadas se juegan y cómo se numeran, las marcas del archivo y las letras de las
  // variantes.
  sgf: (
    from: 1,
    to: auto,
    variation: none,
    marks: true,
    numbers: auto,
    step: 100,
    restart: (on: auto, from: 1),
    last-mark: none,
    letters: none,
    view: false,
  ),
  // sgf-diagrams: los tramos de jugadas y su numeración, las variantes, el epígrafe y lo que va debajo (las
  // notas, los comentarios y el resultado), las opciones de cada tablero y su disposición (encima de la de
  // layout).
  diagrams: (
    step: 50,
    figures: true,
    view: true,
    partial: none,
    from: 1,
    to: auto,
    variation: none,
    variations: (on: false, select: "commented", depth: 1, from: 1, paths: ()),
    variation-title: auto,
    numbers: true,
    marks: true,
    last-mark: none,
    restart: (on: auto, from: 1),
    notes: true,
    title: auto,
    caption: caption-defaults,
    comments: comments-defaults + (on: false, root: false),
    annotations: true,
    chat: true,
    result: (on: true, title: auto, format: "text", black: auto, white: auto),
    goban: (:),
    layout: (:),
  ),
  // sgf-problem: el enunciado y las soluciones (una por línea del árbol), su epígrafe, lo que va debajo, la
  // parte del tablero que se ve, las opciones de cada tablero y su disposición.
  problems: (
    statement: true,
    solutions: true,
    title: auto,
    to-play: auto,
    variation-title: auto,
    verdict: false,
    view: true,
    partial: auto,
    notes: true,
    caption: caption-defaults,
    comments: comments-defaults + (on: true),
    annotations: true,
    chat: true,
    goban: (:),
    layout: (:),
  ),
  // La disposición de los diagramas: columns: auto los pone en el párrafo, uno al lado del otro; un número,
  // en una grilla. width: auto, columnas del ancho del diagrama más ancho; per-page, cada cuántos diagramas
  // empieza una página.
  layout: (columns: auto, width: 100%, column-sep: 1em, row-sep: 1em, fit: false, align: center, per-page: none),
  // goban-view: lo que se dibuja, a qué altura sobre la línea de base queda el centro y las opciones del tablero,
  // encima de las suyas.
  view: (
    marks: true,
    arrows: true,
    lines: true,
    numbers: true,
    territory: true,
    forgotten: false,
    raise: auto,                // auto: la mitad del alto de las minúsculas
    goban: (scale: 0.8),
  ),
  texts: texts,
  // Las formas de marca propias, por su nombre: una función, un contenido o (image: ...).
  shapes: (:),
)

// Mezcla las opciones de sgf: restart es una rama con on (true, false o auto); lo demás se reemplaza.
#let merge-sgf(base, new) = {
  if type(new) != dictionary { panic("la opción sgf espera un diccionario") }
  for (key, value) in new {
    if key not in base { panic("opción desconocida: sgf." + key) }
    if key == "restart" {
      if type(value) == bool or value == auto {
        base.restart.on = value
      } else if type(value) == dictionary {
        base.restart = merge(base.restart, value, path: ("sgf", "restart"))
      } else {
        panic("sgf.restart espera true, false, auto o un diccionario: " + repr(value))
      }
    } else {
      base.insert(key, value)
    }
  }
  base
}

// label.style fija las columnas, las filas y sus direcciones según la costumbre de cada lugar.
#let label-styles = (
  western: (columns: "A", rows: "1", columns-direction: ltr, rows-direction: btt),
  japanese: (columns: "1", rows: "一", columns-direction: rtl, rows-direction: ttb),
  chinese: (columns: "1", rows: "一", columns-direction: ltr, rows-direction: ttb),
)

// Las opciones de label, con style cambiado por lo que fija, en su lugar.
#let label-options(value) = {
  if type(value) != dictionary or "style" not in value { return value }
  let result = (:)
  for (key, v) in value {
    if key == "style" {
      if v not in label-styles { panic("label.style es western, japanese o chinese: " + repr(v)) }
      result += label-styles.at(v)
    } else {
      result.insert(key, v)
    }
  }
  result
}

// Las ramas de un jugador que también se dan para los tres a la vez (stone: ... es players: (all: (stone: ...))).
#let player-branches = ("stone", "prisoner", "move", "mark")

// Vuelve el estilo del tablero y de los jugadores al inicial. Lo que no es estilo queda: el tamaño, partial,
// la escala, dónde van las etiquetas y cuáles son, hoshi.at, si se numeran las jugadas, el juego, las flechas
// y las líneas, y las opciones de las partidas y los diagramas.
#let reset-style(tree) = {
  tree.background = defaults.background
  tree.grid = defaults.grid
  tree.hoshi = defaults.hoshi + (at: tree.hoshi.at)
  let label = defaults.label
  for key in ("at", "columns", "rows", "columns-direction", "rows-direction") { label.insert(key, tree.label.at(key)) }
  tree.label = label
  for p in player-names {
    let player = defaults.players.at(p)
    player.move.numbers = tree.players.at(p).move.numbers
    tree.players.insert(p, player)
  }
  tree
}

// Una forma de marca propia: una función (que recibe radius, stroke, fill y color, y devuelve lo que se dibuja,
// centrado en el punto), un contenido o una imagen, (image: archivo) o (image: (file: ..., width: ...)).
#let shape-definition(name, value) = {
  if name in mark-keys { panic("una forma de marca no puede llamarse " + name + ": es una opción de marks") }
  if type(value) in (function, content, str) { return value }
  if type(value) != dictionary or value.keys() != ("image",) {
    panic("la forma " + name + " es una función, un contenido o (image: ...): " + repr(value))
  }
  let image = if type(value.image) == dictionary { value.image } else { (file: value.image) }
  for key in image.keys() {
    if key not in ("file", "width") { panic("opción desconocida: shapes." + name + ".image." + key) }
  }
  if image.at("file", default: none) == none { panic("la forma " + name + " necesita image.file") }
  (image: (width: auto) + image)
}

// Agrega las opciones al árbol, en el orden en que se escriben.
#let apply(tree, options) = {
  for (key, value) in options {
    if key == "profile" {
      let profile = if type(value) == str {
        if value not in profiles { panic("perfil desconocido: " + value + " (son " + profiles.keys().join(", ") + ")") }
        profiles.at(value)
      } else if type(value) == dictionary { value } else {
        panic("profile espera el nombre de un perfil o un diccionario de opciones: " + repr(value))
      }
      tree = apply(reset-style(tree), profile)
    } else if key == "shapes" {
      if type(value) != dictionary { panic("shapes espera un diccionario: (nombre: forma, ...)") }
      for (name, shape) in value { tree.shapes.insert(name, shape-definition(name, shape)) }
    } else if key in player-branches {
      for p in player-names {
        tree.players.at(p).insert(key, merge(tree.players.at(p).at(key), value, path: (key,)))
      }
    } else if key == "players" {
      if type(value) != dictionary { panic("la opción players espera un diccionario") }
      for (who, branch) in value {
        let targets = if who == "all" { player-names } else if who in player-names { (who,) } else {
          panic("jugador desconocido: " + who + " (son neutral, black, white y all)")
        }
        for p in targets {
          tree.players.insert(p, merge(tree.players.at(p), branch, path: ("players", who)))
        }
      }
    } else if key == "sgf" {
      tree.sgf = merge-sgf(tree.sgf, value)
    } else if key == "label" {
      tree.label = merge(tree.label, label-options(value), path: ("label",))
    } else if key in tree {
      tree.insert(key, merge(tree.at(key), value, path: (key,)))
    } else {
      panic("opción desconocida: " + key)
    }
  }
  tree
}

// Las opciones globales, en el orden en que se dieron.
#let global = state("goban-options", ())

// Fija opciones para todos los tableros que siguen.
#let goban-set(..args) = {
  if args.pos().len() > 0 { panic("goban-set solo recibe opciones con nombre") }
  global.update(list => list + (args.named(),))
}

// El árbol con los valores iniciales y las opciones globales. Necesita context.
#let current() = global.get().fold(defaults, apply)
