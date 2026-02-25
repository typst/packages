#let shorten-node(node) = {
  if "entries" in node {
    (
      name: node.name,
      arguments: node.entries.filter(e => e.name == none).map(e => e.value),
      properties: node.entries.filter(e => e.name != none).map(e => (e.name, e.value)).to-dict(),
      children: node.children.map(c => shorten-node(c))
    )
  } else {
    node
  }
}

#let collapse-node(node) = (
  arguments: node.arguments,
  properties: node.properties,
  children: node.children.map(c => (c.name, collapse-node(c))).to-dict(),
)

#let minimalize-node(node) = {
  arguments(..node.arguments, ..node.properties, ..node.children.pairs().map(((k, v)) => (k, minimalize-node(v))).to-dict())
}

#let shorten(doc) = doc.map(shorten-node)
#let collapse(doc) = doc.map(n => (n.name, collapse-node(n))).to-dict()
#let minimalize(doc) = doc.pairs().map(((k, v)) => (k, minimalize-node(v))).to-dict()