// sgf-graph: el winrate y el puntaje de cada posición de una partida analizada, como el gráfico de los
// programas de análisis. El winrate va de 0 a 100 (la escala a la izquierda) y el puntaje de −M a M (a la
// derecha; M es el mayor, redondeado a 5, 10, 20, 30...), desde Negro (desde Blanco con perspective: "white"). La
// línea punteada es la mitad. Las jugadas de mistakes llevan un punto con su número.

#import "options.typ": current, apply, merge-analysis
#import "analysis.typ": check-analysis, loss-color, mistakes, minus
#import "sgf.typ": check-game, query, variation-path, variation-text, shown-numbers

// Las opciones de graph, comprobadas.
#let check-graph(g) = {
  if type(g.width) not in (length, ratio, relative) { panic("graph.width es una longitud: " + repr(g.width)) }
  if type(g.height) != length { panic("graph.height es una longitud: " + repr(g.height)) }
  if type(g.from) != int or g.from < 0 { panic("graph.from es un número desde 0: " + repr(g.from)) }
  if g.to != auto and (type(g.to) != int or g.to < 0) { panic("graph.to es auto o un número: " + repr(g.to)) }
  if g.step != auto and (type(g.step) != int or g.step < 1) { panic("graph.step es auto o un número: " + repr(g.step)) }
  if type(g.marks) != array or g.marks.any(n => type(n) != int) {
    panic("graph.marks es un arreglo de números: " + repr(g.marks))
  }
  for key in ("winrate", "lead") {
    if type(g.at(key).on) != bool { panic("graph." + key + " es true, false o un diccionario") }
  }
  g
}

// Algo en el punto (x, y), con anchor: la parte de lo que se escribe que queda en ese punto.
#let at(x, y, anchor, body) = place(top + left, dx: x, dy: y, box(width: 0pt, height: 0pt, place(anchor, body)))

// Dibuja el gráfico de la partida. Las opciones son las de la rama graph (gobanist-set(graph: ...)); analysis
// (perspective, mistakes, colored, colors) va encima del de todo el documento.
#let sgf-graph(game, ..args) = {
  check-game("sgf-graph", game)
  if args.pos().len() > 0 { panic("sgf-graph recibe una partida y opciones con nombre") }
  let options = args.named()
  layout(size => context {
    let tree = apply(current(), (graph: options))
    let g = check-graph(tree.graph)
    let a = check-analysis(merge-analysis(tree.analysis, g.analysis))
    let path = variation-path(g.variation, tree.use-i)
    let r = query(game, (kind: "read", path: path, chat: true))
    if r.missing { panic("la partida no tiene la variante " + variation-text(g.variation)) }
    let series = query(game, (kind: "series", path: path))
    let total = series.len() - 1
    let last = if g.to == auto { total } else { calc.min(g.to, total) }
    let first = calc.max(0, calc.min(g.from, last))
    // Los datos, desde quien se mira: k → (winrate en %, puntaje).
    let sign = if a.perspective == "white" { -1 } else { 1 }
    let data = range(first, last + 1).map(k => {
      let e = series.at(k)
      (k: k,
        winrate: if e.winrate != none { if sign > 0 { e.winrate * 100 } else { 100 - e.winrate * 100 } },
        lead: if e.lead != none { sign * e.lead })
    }).filter(d => d.winrate != none or d.lead != none)
    if data.len() == 0 {
      panic("sgf-graph: la partida no tiene análisis (KT, LZ, QKGV, QLZV, SBKV, SBKS u OGSC)")
    }
    let has-winrate = g.winrate.on and data.any(d => d.winrate != none)
    let has-lead = g.lead.on and data.any(d => d.lead != none)
    let biggest = data.filter(d => d.lead != none).fold(0, (m, d) => calc.max(m, calc.abs(d.lead)))
    let max = if biggest > 5 { calc.ceil(biggest / 10) * 10 } else { 5 }
    let step = if g.step != auto { g.step } else {
      let n = last - first
      if n > 300 { 100 } else if n > 150 { 50 } else if n > 60 { 20 } else if n > 30 { 10 } else { 5 }
    }
    let label(body) = text(..g.text, body)
    // Las escalas: el ancho de sus números a cada lado.
    let left-scale = if has-winrate { measure(label("100")).width + 0.3em.to-absolute() } else { 0pt }
    let right-scale = if has-lead { measure(label(minus + str(max))).width + 0.3em.to-absolute() } else { 0pt }
    let full = if type(g.width) == length { g.width.to-absolute() } else if type(g.width) == ratio { g.width * size.width }
      else { g.width.ratio * size.width + g.width.length.to-absolute() }
    let width = full - left-scale - right-scale
    let height = g.height.to-absolute()
    let line-height = measure(label("0")).height
    let x(k) = (k - first) * width / calc.max(1, last - first)
    let y-winrate(w) = height - w / 100 * height
    let y-lead(l) = height - (l / max + 1) / 2 * height

    // Una curva (winrate o lead): el área entre ella y la mitad, y la línea.
    let draw-curve(key, y) = {
      let style = g.at(key)
      let points = data.filter(d => d.at(key) != none).map(d => (x(d.k), y(d.at(key))))
      if points.len() == 0 { return }
      if style.fill != none {
        place(top + left, curve(fill: style.fill, stroke: none,
          curve.move((points.first().at(0), height / 2)),
          ..points.map(p => curve.line(p)),
          curve.line((points.last().at(0), height / 2)),
          curve.close()))
      }
      place(top + left, curve(stroke: (paint: style.color, thickness: style.width, join: "round"),
        curve.move(points.first()), ..points.slice(1).map(p => curve.line(p))))
    }

    let worst = if a.mistakes.count > 0 { mistakes(a, series).filter(k => first <= k and k <= last) } else { () }
    let numbers = shown-numbers(r, (restart: (on: false), step: (100,), from: 1))
    let thin = (paint: black, thickness: 0.4pt)
    let dashed = (paint: luma(50%), thickness: 0.4pt, dash: (2pt, 2pt))
    let body = {
      place(top + left, rect(width: width, height: height, stroke: thin))
      place(top + left, line(start: (0pt, height / 2), end: (width, height / 2), stroke: dashed))
      for k in g.marks.filter(k => first <= k and k <= last) {
        place(top + left, line(start: (x(k), 0pt), end: (x(k), height), stroke: dashed))
      }
      // Los números de las posiciones, abajo.
      for k in range(0, last + 1, step: step).filter(k => k >= first) {
        place(top + left, line(start: (x(k), height), end: (x(k), height - 2pt), stroke: thin))
        at(x(k), height + 2pt, center + top, label(str(k)))
      }
      if has-winrate {
        for w in (0, 50, 100) { at(-0.3em, y-winrate(w), right + horizon, label(str(w))) }
      }
      if has-lead {
        at(width + 0.3em, 0pt, left + horizon, label("+" + str(max)))
        at(width + 0.3em, height / 2, left + horizon, label("0"))
        at(width + 0.3em, height, left + horizon, label(minus + str(max)))
      }
      if has-lead { draw-curve("lead", y-lead) }
      if has-winrate { draw-curve("winrate", y-winrate) }
      // Las jugadas de mistakes: un punto en la curva del winrate (o del puntaje) y su número, arriba o, cerca del
      // borde de arriba, abajo.
      for k in worst {
        let d = data.find(d => d.k == k)
        if d == none { continue }
        let y = if has-winrate and d.winrate != none { y-winrate(d.winrate) }
          else if has-lead and d.lead != none { y-lead(d.lead) }
        if y == none { continue }
        let color = if a.colored { loss-color(a, series.at(k).loss) }
        if color == none { color = g.winrate.color }
        place(top + left, dx: x(k) - 1.5pt, dy: y - 1.5pt, circle(radius: 1.5pt, fill: color, stroke: none))
        let n = label(str(numbers.at(k - 1)))
        if y < 0.2 * height { at(x(k), y + 2pt, center + top, n) } else { at(x(k), y - 2pt, center + bottom, n) }
      }
    }
    block(width: full, height: line-height / 2 + height + 2pt + line-height, inset: (top: line-height / 2),
      pad(left: left-scale, box(width: width, height: height, body)))
  })
}
