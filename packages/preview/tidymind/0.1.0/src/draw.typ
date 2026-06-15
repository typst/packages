#import "@preview/cetz:0.5.2"

#let _branch-color(n, palette) = {
  if n.branch < 0 { palette.at(0) } else { palette.at(calc.rem(n.branch, palette.len())) }
}

// Desenha arestas pai→filho (bezier horizontal). Recursivo.
#let _draw-edges(n, palette) = {
  import cetz.draw: *
  for c in n.children {
    let col = _branch-color(c, palette)
    let px = n.x + n.w        // borda direita do pai
    let py = -n.y
    let cx = c.x              // borda esquerda do filho
    let cy = -c.y
    let mid = (px + cx) / 2
    bezier((px, py), (cx, cy), (mid, py), (mid, cy), stroke: 1pt + col)
  }
  for c in n.children { _draw-edges(c, palette) }
}

// Desenha as caixas dos nós. Recursivo.
#let _draw-nodes(n, palette, font, text-size, is-root) = {
  import cetz.draw: *
  let col = _branch-color(n, palette)
  let fill = if is-root { col } else { white }
  let txt = if is-root { white } else { rgb("#1e293b") }
  let stroke = if is-root { none } else { 0.8pt + col }
  // âncora à esquerda do nó (x é a borda esquerda); centro vertical em -y
  content((n.x, -n.y), anchor: "west", box(
    fill: fill, inset: (x: 8pt, y: 4pt), radius: 4pt, stroke: stroke,
    text(font: font, size: text-size, fill: txt, weight: if is-root { "bold" } else { "regular" })[#n.content],
  ))
  for c in n.children { _draw-nodes(c, palette, font, text-size, false) }
}

/// Desenha o mapa mental já posicionado (saída de `layout-tree`).
#let draw-mindmap(n, palette, font, text-size) = {
  _draw-edges(n, palette)
  _draw-nodes(n, palette, font, text-size, true)
}
