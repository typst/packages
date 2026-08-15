/// Substitui rótulo vazio por um marcador para não gerar nó nulo.
#let _nonempty(c) = {
  if c == [] or c == "" or c == none { [—] } else { c }
}

/// Normalizes any input into `(content, children, branch, emphasis)`.
/// Accepts a dictionary carrying `content` (plus optional attributes), or raw
/// content, which becomes a leaf.
///
/// `branch` is the INDEX of a branch color (1..n), for when the caller wants to
/// override the natural position; `emphasis` is the ROLE of the node. Both
/// arrive by NAME — the package is never handed a color, it resolves one.
#let normalize(n) = {
  if type(n) == dictionary and "content" in n {
    let children = n.at("children", default: ())
    return (
      content: _nonempty(n.content),
      children: children.map(normalize),
      branch: n.at("branch", default: none),
      emphasis: n.at("emphasis", default: none),
    )
  }
  // conteúdo cru → folha
  (content: _nonempty(n), children: (), branch: none, emphasis: none)
}

/// Prunes the tree at `max-depth` (root = depth 0). Past the limit, children
/// are dropped — this is what keeps a runaway tree from growing a huge canvas.
#let prune(n, max-depth, depth: 0) = {
  if depth >= max-depth {
    return (..n, children: ())
  }
  (..n, children: n.children.map(c => prune(c, max-depth, depth: depth + 1)))
}
