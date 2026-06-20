/// Substitui rótulo vazio por um marcador para não gerar caixa nula.
#let _nonempty(c) = {
  if c == [] or c == "" or c == none { [—] } else { c }
}

/// Normaliza qualquer entrada para `(content, children)`.
/// Aceita: dict `(content:, children:)`, dict só com `content`, ou conteúdo cru (folha).
#let normalize(n) = {
  if type(n) == dictionary and "content" in n {
    let children = n.at("children", default: ())
    return (content: _nonempty(n.content), children: children.map(normalize))
  }
  // conteúdo cru → folha
  (content: _nonempty(n), children: ())
}

/// Poda a árvore em `max-depth` (raiz = profundidade 0). Acima do limite, descarta filhos.
#let prune(n, max-depth, depth: 0) = {
  if depth >= max-depth {
    return (content: n.content, children: ())
  }
  (content: n.content, children: n.children.map(c => prune(c, max-depth, depth: depth + 1)))
}
