// El tablero dibujado: fondo, cuadrícula, puntos de estrella, etiquetas, piedras, marcas, flechas y líneas.

#import "../options.typ": current, merge, player-names
#import "../board.typ": board, resolve, partial-window
#import "../coordinates.typ": parse, column-letter
#import "util.typ": paint, fills, layered, line-stroke, origin, centered, disc, polar, unbroken
#import "stones.typ": stone, number, radius
#import "images.typ": picture, pick, turn, quarter-turned, tile-starts, tiles, mesh, mesh-size
#import "marks.typ": shape, cover
#import "arrows.typ": draw-stroke
#import "../game.typ": last

// Los puntos de estrella de siempre: en cada lado, la cuarta línea desde el borde (la tercera con menos de
// 13 líneas); el centro si los dos lados son impares; y, desde 15 líneas, el medio de los lados.
#let hoshi-points(cols, rows) = {
  if cols < 7 or rows < 7 { return () }
  let axis(n) = (near: if n < 13 { 3 } else { 4 }, mid: if calc.odd(n) { calc.quo(n + 1, 2) } else { 0 })
  let (x, y) = (axis(cols), axis(rows))
  let center = x.mid > 0 and y.mid > 0
  let sides = center and cols >= 15 and rows >= 15
  let row(r, corners, middle) = {
    let points = ()
    if corners { points.push((x.near, r)) }
    if middle { points.push((x.mid, r)) }
    if corners { points.push((cols - x.near + 1, r)) }
    points
  }
  row(y.near, true, sides) + (if y.mid > 0 { row(y.mid, sides, center) } else { () }) + row(rows - y.near + 1, true, sides)
}

// Los puntos que ocupa lo que se dibuja: el de cada piedra y marca, y los dos extremos de cada flecha.
#let item-points(items) = items.map(i => {
  if "to" in i { ((i.x, i.y), i.to) } else { ((i.x, i.y),) }
}).join(default: ())

// La parte visible con partial: auto: lo que se dibuja (y las esquinas de extent, si no es none), con margin
// líneas más. Un lado que queda a dos líneas
// o menos del borde llega hasta el borde. Sin nada dibujado, el tablero entero.
#let auto-window(items, cols, rows, margin, extent: none) = {
  let points = item-points(items)
  if extent != none { points += ((extent.at(0), extent.at(1)), (extent.at(2), extent.at(3))) }
  if points.len() == 0 { return (1, 1, cols, rows) }
  let (xs, ys) = (points.map(p => p.at(0)), points.map(p => p.at(1)))
  let low(v) = { let v = calc.max(1, v - margin); if v - 1 <= 2 { 1 } else { v } }
  let high(v, n) = { let v = calc.min(n, v + margin); if n - v <= 2 { n } else { v } }
  (low(calc.min(..xs)), low(calc.min(..ys)), high(calc.max(..xs), cols), high(calc.max(..ys), rows))
}

// La etiqueta de la línea n (de 1 a count) con el formato pattern: "A" son las letras del go (sin la I salvo
// con use-i); lo demás, un patrón de numbering ("1", "一").
#let label-name(n, count, pattern, direction, forward, use-i) = {
  let n = if direction == forward { n } else { count - n + 1 }
  if pattern == "A" { column-letter(n, use-i) } else { numbering(pattern, n) }
}

// Dibuja un tablero resuelto (resolve, en board.typ): devuelve (body, notes), el tablero y sus notas «N en M»
// ((n, m), o (n, none) para un pase). Con partial: auto, el rectángulo extent del resuelto (x1, y1, x2, y2; lo
// pone sgf-diagrams) también se ve. Necesita context.
#let draw(resolved) = {
  let tree = resolved.tree
  let players = tree.players
  let (cols, rows) = (resolved.cols, resolved.rows)
  let s = tree.scale
  let factor = if tree.scale-line-width { s } else { 1 }
  let captured(i) = i.at("captured", default: none) != none
  // Lo que se ve: sin lo capturado (con captures: "fade", las piedras capturadas quedan como prisioneros, pero
  // no las que quitó una partida; lo que capturan las jugadas con keep, de sgf-diagrams y sgf-problem, queda
  // como estaba, salvo que otra piedra ocupe después su punto), el territorio, los pases, lo que quita las
  // piedras ni lo que esconde una vista (hide).
  let fade = tree.captures == "fade"
  let removed(i) = i.at("removed", default: false)
  let faded(i) = fade and i.kind == "stone" and not removed(i)
  let kept-by(k, i) = (captured(i) and not removed(i) and resolved.items.at(i.captured).at("keep", default: false)
    and not resolved.items.slice(k + 1).any(j => j.kind == "stone" and j.x == i.x and j.y == i.y))
  let items = resolved.items.enumerate().map(((k, i)) => if kept-by(k, i) { i + (keep: true) } else { i })
  let kept(i) = i.at("keep", default: false)
  let hidden-kinds = ("territory", "pass", "remove")
  let hide(i) = i.at("hide", default: false)
  let shown = items.filter(i => i.kind not in hidden-kinds and not hide(i)
    and (not captured(i) or faded(i) or kept(i)))
  let marked = resolved.territory.map(((x, y, ..)) => (x: x, y: y))
  let (fx, fy, tx, ty) = if tree.partial == none { (1, 1, cols, rows) }
    else if tree.partial == auto { auto-window(shown + marked, cols, rows, tree.partial-margin,
      extent: resolved.at("extent", default: none)) }
    else { partial-window(tree.partial, tree, cols, rows) }
  let inside((x, y)) = x >= fx and x <= tx and y >= fy and y <= ty

  // Notas: una jugada numerada en un punto donde ya hubo una jugada numerada de este goban no se dibuja; el
  // punto sigue mostrando la primera, aunque la hayan capturado, y se anota «N en M». Un pase numerado de una
  // partida se anota «N: pasa» (m es none).
  let numbered(i) = i.numbered and merge(players.at(i.player).move, i.move-options, path: ("move",)).numbers
  let (notes, hidden, first-shown) = ((), (), ())
  if tree.notes.on {
    let first = (:)
    for (k, i) in items.enumerate() {
      if i.kind == "pass" and i.numbered and players.at(i.player).move.numbers {
        notes.push((i.number, none))
        continue
      }
      if i.kind != "stone" or not i.move or i.resumed or hide(i) or not inside((i.x, i.y)) or not numbered(i) {
        continue
      }
      let key = str(i.x) + "," + str(i.y)
      if key in first {
        notes.push((i.number, resolved.items.at(first.at(key)).number))
        hidden.push(k)
        first-shown.push(first.at(key))
      } else {
        first.insert(key, k)
      }
    }
  }
  let items = items.enumerate().filter(((k, i)) => {
    if i.kind in hidden-kinds or hide(i) or k in hidden { return false }
    if captured(i) and not (k in first-shown or faded(i) or kept(i)) { return false }
    item-points((i,)).all(inside)
  }).map(((k, i)) => {
    if captured(i) and not (k in first-shown or kept(i)) { i.prisoner = true }
    i
  })

  // Medidas.
  let ux = (tree.grid.sep.x * s).to-absolute()
  let uy = (tree.grid.sep.y * s).to-absolute()
  let neutral-radius = radius(players.neutral.stone, s).to-absolute()
  let largest = calc.max(..player-names.map(p => radius(players.at(p).stone, s).to-absolute()))
  let bg = tree.background
  let sep = (bg.sep * s).to-absolute()
  let edge = if bg.on { sep + if bg.line.on { bg.line.width * factor / 2 } else { 0pt } } else { 0pt }
  let base = calc.max(edge, largest)

  // Etiquetas: las columnas arriba y abajo, las filas a los costados.
  let label = tree.label
  let sides = label.at
  if type(sides) != array { sides = (sides,) }
  for side in sides {
    if side not in (top, bottom, left, right) { panic("label.at espera top, bottom, left o right: " + repr(side)) }
  }
  if label.columns-direction not in (ltr, rtl) { panic("label.columns-direction es ltr o rtl") }
  if label.rows-direction not in (btt, ttb) { panic("label.rows-direction es btt o ttb") }
  let label-text(body) = unbroken(text(..label.text, body))
  let columns = range(fx, tx + 1).map(x => (x, label-text(
    label-name(x, cols, label.columns, label.columns-direction, ltr, tree.use-i))))
  let rows-labels = range(fy, ty + 1).map(y => (y, label-text(
    label-name(y, rows, label.rows, label.rows-direction, btt, tree.use-i))))
  let gap = (label.sep + neutral-radius + 5pt).to-absolute()
  // Los kanji de las filas se alinean del lado del tablero, para que los de dos caracteres no lo pisen.
  let kanji-rows = label.rows == "一"
  let row-gap = if kanji-rows { (label.sep + neutral-radius).to-absolute() } else { gap }
  let tallest = calc.max(..columns.map(c => measure(c.at(1)).height))
  let widest = calc.max(..rows-labels.map(r => measure(r.at(1)).width))
  let margin(side, gap, size) = if side in sides { calc.max(base, gap + size) } else { base }
  let row-size = if kanji-rows { widest } else { widest / 2 }
  let (ml, mr) = (margin(left, row-gap, row-size), margin(right, row-gap, row-size))
  let (mt, mb) = (margin(top, gap, tallest / 2), margin(bottom, gap, tallest / 2))

  let px(x) = ml + (x - fx) * ux
  let py(y) = mt + (ty - y) * uy
  let width = ml + (tx - fx) * ux + mr
  let height = mt + (ty - fy) * uy + mb

  // La imagen del fondo, con la opacidad que se pide, en el lugar que le toca en el tablero completo (que va de
  // left a left + full-w y de top a top + full-h): con partial se ve una parte. none si no hay imagen.
  let (left-edge, top-edge) = (px(1) - sep, py(rows) - sep)
  let (full-w, full-h) = ((cols - 1) * ux + 2 * sep, (rows - 1) * uy + 2 * sep)
  let bg-image = bg.fill.image
  let backdrop = if bg.on and bg.fill.on and bg-image.file != none { opacity => {
    let opacity = opacity * bg.fill.opacity
    if bg-image.fit in ("stretch", "cover") {
      let file = pick(bg-image.file, 1, 1)
      place(top + left, dx: left-edge, dy: top-edge, quarter-turned(bg-image.rotate, full-w, full-h,
        (w, h) => picture(file, w, height: h, fit: bg-image.fit, opacity: opacity)))
    } else if bg-image.fit == "tile" {
      let cells = if bg-image.tiles != auto {
        let (c, r) = mesh-size(bg-image.tiles)
        mesh(left-edge, top-edge, full-w, full-h, c, r)
      } else {
        let first = pick(bg-image.file, 1, 1)
        let natural = measure(image(first))
        let tw = if bg-image.width == auto { natural.width } else { (bg-image.width * s).to-absolute() }
        let th = tw * (natural.height / natural.width)
        let anchor = bg-image.anchor
        let (ax, ay) = if anchor.axis() == "horizontal" { (anchor, horizon) }
          else if anchor.axis() == "vertical" { (center, anchor) } else { (anchor.x, anchor.y) }
        let from-x = if ax == left { "start" } else if ax == right { "end" } else { "center" }
        let from-y = if ay == top { "start" } else if ay == bottom { "end" } else { "center" }
        let xs = tile-starts(left-edge, full-w, tw, from-x)
        let ys = tile-starts(top-edge, full-h, th, from-y)
        for (i, x) in xs.enumerate() { for (j, y) in ys.enumerate() { ((i + 1, j + 1, x, y, tw, th),) } }
      }
      tiles(bg-image.file, bg-image.rotate, cells, opacity)
    } else {
      panic("background.fill.image.fit es \"stretch\", \"cover\" o \"tile\": " + repr(bg-image.fit))
    }
  } }
  // Lo que hay en el fondo en (x, y), recortado en un rectángulo de w por h centrado en el origen, con esas
  // esquinas: el color, la imagen (con la opacidad) y el patrón. Las marcas sobre puntos vacíos lo usan.
  let ground(x, y, w, h, radius: 0pt, opacity: 1) = place(top + left, dx: -w / 2, dy: -h / 2, {
    let piece(fill) = place(top + left, rect(width: w, height: h, radius: radius, fill: fill))
    piece(paint(bg.fill.color, opacity))
    if backdrop != none {
      place(top + left, box(width: w, height: h, radius: radius, clip: true,
        place(top + left, dx: -(x - w / 2), dy: -(y - h / 2), backdrop(opacity))))
    }
    if bg.fill.pattern != none { piece(bg.fill.pattern) }
  })

  // Fondo, borde y sombra. Las esquinas del tablero completo van con outer; las demás, con inner.
  let background = if bg.on {
    let rc = bg.rounded-corners
    let corner(x, y) = if x and y { rc.outer } else { rc.inner }
    let corners = (
      top-left: corner(fx == 1, ty == rows), top-right: corner(tx == cols, ty == rows),
      bottom-left: corner(fx == 1, fy == 1), bottom-right: corner(tx == cols, fy == 1),
    )
    let (w, h) = ((tx - fx) * ux + 2 * sep, (ty - fy) * uy + 2 * sep)
    let board-rect(..style) = rect(width: w, height: h, radius: corners, ..style)
    let (x0, y0) = (px(fx) - sep, py(ty) - sep)
    if bg.shadow.on {
      let (dx, dy) = polar(bg.shadow.angle, bg.shadow.offset)
      place(top + left, dx: x0 + dx, dy: y0 + dy, board-rect(fill: paint(bg.shadow.color, bg.shadow.opacity)))
    }
    let at-board(body) = place(top + left, dx: x0, dy: y0, body)
    if backdrop == none {
      layered((..style) => at-board(board-rect(..style)), fills(bg.fill), stroke: line-stroke(bg.line, factor: factor))
    } else {
      // La imagen va sobre el color y debajo del patrón, recortada por el borde.
      if bg.fill.color != none { at-board(board-rect(fill: paint(bg.fill.color, bg.fill.opacity))) }
      at-board(box(width: w, height: h, radius: corners, clip: true, place(top + left, dx: -x0, dy: -y0, backdrop(1))))
      if bg.fill.pattern != none { at-board(board-rect(fill: bg.fill.pattern)) }
      if bg.line.on { at-board(board-rect(stroke: line-stroke(bg.line, factor: factor))) }
    }
  }

  // Cuadrícula: en un tablero parcial, las líneas siguen media casilla más allá de la parte visible. Con
  // imagen, la imagen en lugar de las líneas: estirada de A1 a la esquina opuesta del tablero completo o, con
  // tile, una por casilla (o por celda de la malla tiles), y recortada como las líneas.
  let grid = tree.grid
  let (y1, y2) = (py(ty) - if ty < rows { uy / 2 } else { 0pt }, py(fy) + if fy > 1 { uy / 2 } else { 0pt })
  let (x1, x2) = (px(fx) - if fx > 1 { ux / 2 } else { 0pt }, px(tx) + if tx < cols { ux / 2 } else { 0pt })
  let grid-image = grid.image
  let lines = if grid.on and grid-image.file != none {
    let (gw, gh) = ((cols - 1) * ux, (rows - 1) * uy)
    let opacity = grid.line.opacity
    let body = if grid-image.fit == "stretch" {
      let file = pick(grid-image.file, 1, 1)
      place(top + left, dx: px(1), dy: py(rows), quarter-turned(grid-image.rotate, gw, gh,
        (w, h) => picture(file, w, height: h, fit: "stretch", opacity: opacity)))
    } else if grid-image.fit == "tile" {
      let (c, r) = if grid-image.tiles == auto { (cols - 1, rows - 1) } else { mesh-size(grid-image.tiles) }
      tiles(grid-image.file, grid-image.rotate, mesh(px(1), py(rows), gw, gh, c, r), opacity)
    } else {
      panic("grid.image.fit es \"stretch\" o \"tile\": " + repr(grid-image.fit))
    }
    place(top + left, dx: x1, dy: y1, box(width: x2 - x1, height: y2 - y1, clip: true,
      place(top + left, dx: -x1, dy: -y1, body)))
  } else if grid.on and grid.line.on {
    let stroke = line-stroke(grid.line, factor: factor)
    for x in range(fx, tx + 1) { place(top + left, line(start: (px(x), y1), end: (px(x), y2), stroke: stroke)) }
    for y in range(fy, ty + 1) { place(top + left, line(start: (x1, py(y)), end: (x2, py(y)), stroke: stroke)) }
  }

  let hoshi = tree.hoshi
  let stars = if grid.on and hoshi.on {
    let points = if hoshi.at == auto { hoshi-points(cols, rows) } else {
      parse(hoshi.at, use-i: tree.use-i, window: (fx, fy, tx, ty)).points
    }
    let color = if hoshi.color == auto { grid.line.color } else { hoshi.color }
    let opacity = if hoshi.opacity == auto { grid.line.opacity } else { hoshi.opacity }
    let star(x, y) = if hoshi.image.file == none { disc(hoshi.radius * s, fill: paint(color, opacity)) } else {
      let width = if hoshi.image.width == auto { 2 * hoshi.radius * s } else { hoshi.image.width * s }
      let a = turn(hoshi.image.rotate, x, y)
      place(center + horizon, rotate(-a, picture(pick(hoshi.image.file, x, y), width, opacity: opacity)))
    }
    for (x, y) in points.filter(inside) { origin(px(x), py(y), star(x, y)) }
  }

  let labels = {
    if top in sides { for (x, body) in columns { centered(px(x), py(ty) - gap, body) } }
    if bottom in sides { for (x, body) in columns { centered(px(x), py(fy) + gap, body) } }
    for (side, x, align) in ((left, px(fx) - row-gap, right), (right, px(tx) + row-gap, left)) {
      if side not in sides { continue }
      for (y, body) in rows-labels {
        if kanji-rows {
          origin(x, py(y), place(align + horizon, body))
        } else {
          centered(x, py(y), body)
        }
      }
    }
  }

  // La piedra de arriba en cada punto.
  let on-top = (:)
  for i in items.filter(i => i.kind == "stone") { on-top.insert(str(i.x) + "," + str(i.y), i) }

  let stone-style(p, item) = {
    let base = players.at(p).stone
    if item.prisoner { base = merge(base, players.at(p).prisoner, path: ("prisoner",)) }
    merge(base, item.options, path: ("stone",))
  }
  let mark-style(p, options) = {
    let options = options
    for key in ("shape", "content") { let _ = options.remove(key, default: none) }
    merge(players.at(p).mark, options, path: ("mark",))
  }
  // Lo que hay en el fondo en el punto (x, y), si tiene imagen (ver ground).
  let ground-at(x, y) = if backdrop != none { ground.with(x, y) }
  let mark-info(p, number, content, scale, at, point) = (
    tree: tree, cell: (ux, uy), stone-fill: fills(players.at(p).stone.fill + (on: true)),
    number: number, content: content, scale: scale, factor: factor, ground: ground-at(..at), point: point,
  )
  let halo-color = bg.fill.color

  let (covers, stones, stone-marks, marks, strokes) = ((), (), (), (), ())
  for item in items {
    let (x, y) = (px(item.x), py(item.y))
    if item.kind == "stone" {
      let p = item.player
      let style = stone-style(p, item)
      let move = merge(players.at(p).move, item.move-options, path: ("move",))
      stones.push(origin(x, y, stone(style, s, factor, (item.x, item.y)),
        if item.numbered and move.numbers { number(item.number, move, style, s) }))
      if item.mark != none {
        let m = mark-style(p, item.mark)
        let r = radius(style, s).to-absolute() * m.scale
        stone-marks.push(origin(x, y, shape(item.mark.shape, r, m,
          mark-info(p, 1, item.mark.at("content", default: none), s * style.scale * m.scale, (x, y), (item.x, item.y)))))
      }
    } else if item.kind == "mark" {
      let below = on-top.at(str(item.x) + "," + str(item.y), default: none)
      let p = if item.player != auto { item.player } else if below != none { below.player } else { "neutral" }
      let m = mark-style(p, item.options)
      let r = radius(players.at(p).stone, s).to-absolute() * m.scale
      if below == none { covers.push(origin(x, y, cover(item.shape, r, tree, ground: ground-at(x, y)))) }
      marks.push(origin(x, y, shape(item.shape, r, m,
        mark-info(p, item.number, item.options.at("content", default: none), s * m.scale, (x, y), (item.x, item.y)))))
    } else {
      let key = if item.kind == "arrows" { "arrow" } else { "line" }
      let style = merge(tree.at(key), item.options, path: (key,))
      let (tip, tips) = if key == "arrow" { (style.tip, style.tips) } else { (none, none) }
      strokes.push(draw-stroke((x, y), (px(item.to.at(0)), py(item.to.at(1))), style, tip, tips, halo-color, factor))
    }
  }

  // Territorio: cada punto con el último territory que lo marcó. Con draw: "marks", la marca del jugador;
  // con "fill", su casilla; con "region", la región de cada color, que se dibuja al final con el estilo del
  // último territory que la usó.
  let clipped(extra, body) = {
    let (x0, y0) = (px(fx) - extra * ux, py(ty) - extra * uy)
    place(top + left, dx: x0, dy: y0, box(width: (tx - fx + 2 * extra) * ux, height: (ty - fy + 2 * extra) * uy,
      clip: true, place(top + left, dx: -x0, dy: -y0, body)))
  }
  let territory-style(p, options) = {
    let options = options
    let _ = options.remove("draw", default: none)
    merge(players.at(p).territory, options, path: ("territory",))
  }
  let territory = resolved.territory.filter(((x, y, ..)) => inside((x, y)))
  let (under, above) = ((), ())
  let region-style = (:)
  for (k, it) in resolved.items.enumerate() {
    if it.kind != "territory" or hide(it) { continue }
    let draw = it.options.draw
    if draw == "region" {
      for p in ("black", "white") {
        if it.player in (none, p) { region-style.insert(p, territory-style(p, it.options)) }
      }
    }
    let mine = territory.filter(t => t.at(3) == k)
    for p in player-names {
      let points = mine.filter(t => t.at(2) == p)
      if points.len() == 0 or (draw == "region" and p != "neutral") { continue }
      let style = territory-style(p, it.options)
      if draw == "marks" {
        let mark = if type(style.mark) == str { (shape: style.mark) } else { style.mark }
        let m = mark-style(p, mark)
        let r = radius(players.at(p).stone, s).to-absolute() * m.scale
        for (x, y, ..) in points {
          if on-top.at(str(x) + "," + str(y), default: none) == none {
            covers.push(origin(px(x), py(y), cover(mark.shape, r, tree, ground: ground-at(px(x), py(y)))))
          }
          marks.push(origin(px(x), py(y), shape(mark.shape, r, m,
            mark-info(p, 1, mark.at("content", default: none), s * m.scale, (px(x), py(y)), (x, y)))))
        }
      } else {
        for fill in fills(style.fill) {
          under.push(clipped(0, for (x, y, ..) in points {
            place(top + left, dx: px(x) - ux / 2, dy: py(y) - uy / 2, rect(width: ux, height: uy, fill: fill))
          }))
        }
      }
    }
  }
  for p in ("black", "white") {
    let region = resolved.regions.at(p)
    if region == none or p not in region-style or region.contours.len() == 0 { continue }
    let style = region-style.at(p)
    let segments = region.contours.map(c => {
      let ((x0, y0), ..rest) = c
      ((curve.move((px(x0), py(y0))),) + rest.map(((x, y)) => curve.line((px(x), py(y)))) + (curve.close(),))
    }).flatten()
    let path(..options) = place(top + left, curve(..options, ..segments))
    for fill in fills(style.fill) { under.push(clipped(0, path(fill: fill))) }
    if style.line.on or style.vertices.on {
      let color = paint(style.line.color, style.line.opacity)
      let drawn = clipped(0.5, {
        if style.line.on { path(stroke: (paint: color, thickness: style.line.width * factor, join: "miter")) }
        if style.vertices.on {
          let dot = if style.vertices.color == auto { color } else { paint(style.vertices.color, style.line.opacity) }
          for c in region.contours {
            for (x, y) in c { origin(px(x), py(y), disc(style.vertices.radius * s, fill: dot)) }
          }
        }
      })
      if style.line.above { above.push(drawn) } else { under.push(drawn) }
    }
  }

  let body = box(width: width, height: height, {
    background
    lines
    stars
    labels
    under.join()
    covers.join()
    stones.join()
    stone-marks.join()
    marks.join()
    above.join()
    strokes.join()
  })
  (body: body, notes: notes)
}

// Guarda lo que queda del tablero, para goban-prisoners, goban-score, goban-notes y goban-region.
#let record(resolved, notes) = last.update((prisoners: resolved.prisoners, score: resolved.score, notes: notes,
  regions: resolved.regions, use-i: resolved.tree.use-i))

// Dibuja un tablero. Recibe las opciones del tablero (con nombre) y lo que tiene (stones(...), moves(...),
// marks(...), arrows(...), lines(...)), como board.
#let goban(..args) = context {
  let resolved = resolve(board(..args), current())
  let drawn = draw(resolved)
  drawn.body
  record(resolved, drawn.notes)
}
