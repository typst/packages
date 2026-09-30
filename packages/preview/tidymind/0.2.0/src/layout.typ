#import "style.typ": node-body, node-paint, node-spec

// Cores neutras para a passada de medição: a geometria é a mesma do desenho,
// e é só ela que interessa aqui.
#let _neutral-ink = (strong: black, soft: black)

/// Measures one node, honoring `node-max-width` (the label wraps past it).
/// Returns `(w, h)` in points. MUST be called inside `context`.
///
/// `emphasized` must match what the drawing pass will do with this node: an
/// emphasized label is heavier, therefore wider.
#let measure-node(
  content,
  node-max-width,
  font,
  text-size,
  style,
  depth,
  emphasized: false,
) = {
  let spec = node-spec(style, depth, emphasized: emphasized)
  let paint = node-paint(spec, depth, black, _neutral-ink, none, neutral: true)
  let natural = measure(node-body(content, spec, paint, font, text-size))
  if natural.width <= node-max-width {
    return (w: natural.width.pt(), h: natural.height.pt())
  }
  // A largura entra na PRÓPRIA caixa do nó (não numa caixa em volta): assim o
  // texto quebra dentro do inset, e a caixa desenhada tem exatamente esta
  // largura. Medir por fora era o que deixava o rótulo vazar para fora dela.
  let wrapped = measure(
    node-body(content, spec, paint, font, text-size, width: node-max-width),
  )
  (w: node-max-width.pt(), h: wrapped.height.pt())
}

/// Annotates every node of the tree with `w`/`h` (in points).
/// MUST be called inside `context`. `depth` picks the measured style, which is
/// what keeps the measuring and the drawing passes in agreement.
#let measure-tree(n, node-max-width, font, text-size, style, depth: 0) = {
  let m = measure-node(
    n.content,
    node-max-width,
    font,
    text-size,
    style,
    depth,
    emphasized: n.at("emphasis", default: none) != none,
  )
  (
    ..n,
    children: n.children.map(c => measure-tree(
      c,
      node-max-width,
      font,
      text-size,
      style,
      depth: depth + 1,
    )),
    w: m.w,
    h: m.h,
  )
}

// Pós-ordem: anota cada nó com `ext` (faixa vertical da subárvore, pt).
#let _assign-extent(n, v-gap) = {
  if n.children.len() == 0 {
    return (..n, ext: n.h)
  }
  let kids = n.children.map(c => _assign-extent(c, v-gap))
  let kids-ext = kids.fold(0.0, (a, c) => a + c.ext) + v-gap * (kids.len() - 1)
  (..n, children: kids, ext: calc.max(n.h, kids-ext))
}

// Pré-ordem: atribui x/y/branch-index. `branch-index` é a POSIÇÃO do ramo
// (0..n-1), herdada por toda a descendência; o `branch` que o chamador pediu,
// quando existe, vence no desenho.
#let _place(n, x, top, h-gap, v-gap, branch) = {
  let y = top + n.ext / 2 // centro vertical do nó na sua faixa
  let child-x = x + n.w + h-gap
  // span vertical ocupado pelos filhos (com v-gaps entre eles)
  let kids-span = if n.children.len() == 0 { 0.0 } else {
    n.children.fold(0.0, (a, c) => a + c.ext) + v-gap * (n.children.len() - 1)
  }
  // centra o bloco de filhos dentro da faixa do nó → pai alinhado ao centro deles
  let cursor = top + (n.ext - kids-span) / 2
  let kids = ()
  let i = 0
  for c in n.children {
    let b = if branch == -1 { i } else { branch }
    kids.push(_place(c, child-x, cursor, h-gap, v-gap, b))
    cursor = cursor + c.ext + v-gap
    i = i + 1
  }
  (..n, children: kids, x: x, y: y, branch-index: branch)
}

/// Annotates the (already measured) tree with `x`/`y`/`branch-index`/`ext`.
/// The root gets `branch-index: -1`. Coordinates are floats in points, and `y`
/// grows downwards.
#let layout-tree(n, h-gap, v-gap) = {
  // Aceita length (ex.: 40pt) ou float; trabalha internamente em float pt.
  let hg = if type(h-gap) == length { h-gap.pt() } else { h-gap }
  let vg = if type(v-gap) == length { v-gap.pt() } else { v-gap }
  let e = _assign-extent(n, vg)
  _place(e, 0.0, 0.0, hg, vg, -1)
}
