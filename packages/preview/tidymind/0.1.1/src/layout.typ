// Caixa visual de um nó (mesmo inset/radius/font usados no desenho em draw.typ),
// para medir e desenhar igual. `weight` importa: bold é mais largo que regular,
// então a raiz (desenhada em bold) precisa ser MEDIDA em bold.
#let _node-body(content, font, text-size, weight, fill, stroke) = box(
  fill: fill, inset: (x: 8pt, y: 4pt), radius: 4pt, stroke: stroke,
  text(font: font, size: text-size, weight: weight)[#content],
)

/// Mede um nó respeitando `node-max-width` (com wrap quando excede). Retorna (w, h) em pt.
/// DEVE ser chamado dentro de `context`.
#let measure-node(content, node-max-width, font, text-size, weight) = {
  let body = _node-body(content, font, text-size, weight, none, none)
  let nat = measure(body)
  if nat.width <= node-max-width {
    return (w: nat.width.pt(), h: nat.height.pt())
  }
  let wrapped = measure(box(width: node-max-width, body))
  (w: node-max-width.pt(), h: wrapped.height.pt())
}

/// Anota cada nó da árvore com `w`/`h` (pt). DEVE ser chamado dentro de `context`.
/// `is-root` define o peso da fonte (raiz em bold), espelhando o desenho.
#let measure-tree(n, node-max-width, font, text-size, is-root: true) = {
  let weight = if is-root { "bold" } else { "regular" }
  let m = measure-node(n.content, node-max-width, font, text-size, weight)
  (
    content: n.content,
    children: n.children.map(c => measure-tree(c, node-max-width, font, text-size, is-root: false)),
    w: m.w, h: m.h,
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

// Pré-ordem: atribui x/y/branch. `top` = topo da faixa deste nó (y cresce pra baixo).
#let _place(n, x, top, h-gap, v-gap, branch) = {
  let y = top + n.ext / 2          // centro vertical do nó na sua faixa
  let child-x = x + n.w + h-gap
  // span vertical ocupado pelos filhos (com v-gaps entre eles)
  let kids-span = if n.children.len() == 0 { 0.0 } else {
    n.children.fold(0.0, (a, c) => a + c.ext) + v-gap * (n.children.len() - 1)
  }
  // centra o bloco de filhos dentro da faixa do nó → pai alinhado ao centro dos filhos
  let cursor = top + (n.ext - kids-span) / 2
  let kids = ()
  let i = 0
  for c in n.children {
    let b = if branch == -1 { i } else { branch }
    kids.push(_place(c, child-x, cursor, h-gap, v-gap, b))
    cursor = cursor + c.ext + v-gap
    i = i + 1
  }
  (..n, children: kids, x: x, y: y, branch: branch)
}

/// Anota a árvore (já medida) com `x`/`y`/`branch`/`ext`. Raiz tem branch = -1.
/// Coordenadas em float pt; `y` cresce pra baixo.
#let layout-tree(n, h-gap, v-gap) = {
  // Aceita length (ex.: 40pt) ou float; trabalha internamente em float pt.
  let hg = if type(h-gap) == length { h-gap.pt() } else { h-gap }
  let vg = if type(v-gap) == length { v-gap.pt() } else { v-gap }
  let e = _assign-extent(n, vg)
  _place(e, 0.0, 0.0, hg, vg, -1)
}
