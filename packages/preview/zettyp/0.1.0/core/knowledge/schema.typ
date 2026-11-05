/// Knowledge declarations reuse the graph's structural types.
#import "../graph-schema.typ" as graph
#import "../graph-schema.typ": checked

#let raw-to-local = graph.record("RawToLocalDefinition", (
  stage: graph.one-of(("raw-to-local",)),
  observe: graph.typed("function", (function,)),
))
#let registry = graph.dictionary-of("ObserverRegistry", raw-to-local)

#let no-positional = graph.array(graph.opaque, max: 0)

#let reference = graph.record("ReferenceDeclaration", (
  id: graph.id,
  target: graph.id,
  value: graph.opaque,
  origin: graph.opaque,
))
#let references = graph.array(reference)

#let local = graph.record("Local", (
  node: graph.node-declaration,
  references: graph.array(graph.edge-declaration),
  data: graph.typed("open dictionary", (dictionary,)),
))
#let locals = graph.array(local)
