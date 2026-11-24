// Public API. diagram-data is pure data; feynman returns CeTZ draw elements.
#import "src/styles.typ": styles, register-style
#import "src/model.typ": normalize
#import "src/layout.typ": layout as layout-graph
#import "src/paths.typ": prepare
#import "src/render.typ": draw-diagram, render
/// Normalize, lay out and sample a diagram. Return vertices, edges, positions and routes without drawing.
/// With explicit vertices, specify external roles on each vertex.
/// -> dictionary
#let diagram-data(
  /// Edge tuples or dictionaries. Cannot be combined with non-empty edges.
  /// -> array | dictionary
  ..connections,
  /// Vertex dictionaries. If omitted, infer vertices from edge endpoints.
  /// -> array
  vertices: (),
  /// An array of edges; tuples and dictionaries may be mixed.
  /// -> array
  edges: (),
  /// Incoming external IDs when vertices are inferred.
  /// -> array
  incoming: (),
  /// Outgoing external IDs when vertices are inferred. Must not overlap incoming.
  /// -> array
  outgoing: (),
  /// A mapping from particle names to propagator styles.
  /// -> dictionary
  registry: styles,
  /// Optional main lines, external ordering and spacing. See the layout fields.
  /// -> dictionary
  layout: (:),
) = {
  assert(connections.named() == (:), message: "unknown feynman option")
  assert(edges.len() == 0 or connections.pos().len() == 0, message: "use edges or positional connections, not both")
  let input = if edges.len() > 0 {edges} else {connections.pos()}
  if vertices.len() == 0 {
    let ids = input.map(e => if type(e) == array {e.slice(0, 2)} else {(e.from, e.to)}).flatten().dedup()
    assert(not incoming.any(id => outgoing.contains(id)), message: "external roles overlap")
    assert((incoming+outgoing).all(id => ids.contains(id)), message: "unknown external vertex")
    vertices = ids.map(id => (id: id, role: if incoming.contains(id) {"incoming"} else if outgoing.contains(id) {"outgoing"} else {"interaction"}))
  } else {
    assert(incoming.len() == 0 and outgoing.len() == 0, message: "set roles on explicit vertices")
  }
  prepare(layout-graph(normalize(vertices, input, registry: registry), options: layout))
}
/// Call inside cetz.canvas to return CeTZ drawing elements.
/// -> array
#let feynman(
  /// Accepts all diagram-data arguments, including edges, vertices, registry and layout.
  /// -> any
  ..args,
  /// Crossing gap half-length in canvas units. Zero disables gaps; only arrowless wave/wave crossings are handled.
  /// -> int | float
  crossing-gap: 0,
) = draw-diagram(diagram-data(..args), crossing-gap: crossing-gap)
