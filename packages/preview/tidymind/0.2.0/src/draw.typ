#import "@preview/cetz:0.5.2"
#import "style.typ": edge-width, node-body, node-paint, node-spec

// Cor do ramo. O `branch` explícito do chamador (1..n) vence a posição natural,
// e a raiz — que não pertence a ramo nenhum — usa a primeira cor da paleta.
#let _branch-color(n, palette) = {
  let idx = if n.at("branch", default: none) != none {
    n.branch - 1
  } else if n.branch-index < 0 {
    0
  } else {
    n.branch-index
  }
  palette.at(calc.rem(idx, palette.len()))
}

#let _emphasis-color(n, emphasis-colors) = {
  let role = n.at("emphasis", default: none)
  if role == none { none } else { emphasis-colors.at(role, default: none) }
}

// Arestas pai→filho (bezier horizontal). Recursivo.
#let _draw-edges(n, palette, style, depth) = {
  import cetz.draw: *
  let w = edge-width(style, depth)
  for c in n.children {
    let col = _branch-color(c, palette)
    let px = n.x + n.w // borda direita do pai
    let py = -n.y
    let cx = c.x // borda esquerda do filho
    let cy = -c.y
    let mid = (px + cx) / 2
    bezier((px, py), (cx, cy), (mid, py), (mid, cy), stroke: w + col)
  }
  for c in n.children { _draw-edges(c, palette, style, depth + 1) }
}

// Nós. Recursivo. A caixa vem de `style.typ` — a MESMA que foi medida.
#let _draw-nodes(n, palette, style, font, text-size, ink, emphasis-colors, depth) = {
  import cetz.draw: *
  let emphasis = _emphasis-color(n, emphasis-colors)
  // Mesmo spec que `layout.typ` mediu — inclusive o peso que a ênfase impõe.
  let spec = node-spec(style, depth, emphasized: emphasis != none)
  let paint = node-paint(spec, depth, _branch-color(n, palette), ink, emphasis)
  // Âncora à esquerda do nó (x é a borda esquerda); centro vertical em -y.
  // `width: n.w` casa o desenho com a medição: rótulos longos quebram em
  // node-max-width em vez de vazar em linha única para fora da página.
  content(
    (n.x, -n.y),
    anchor: "west",
    node-body(n.content, spec, paint, font, text-size, width: n.w * 1pt),
  )
  for c in n.children {
    _draw-nodes(c, palette, style, font, text-size, ink, emphasis-colors, depth + 1)
  }
}

/// Draws the already positioned mind map (the output of `layout-tree`).
#let draw-mindmap(n, palette, style, font, text-size, ink, emphasis-colors) = {
  _draw-edges(n, palette, style, 0)
  _draw-nodes(n, palette, style, font, text-size, ink, emphasis-colors, 0)
}
