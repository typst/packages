#import "internals.typ": render, engine-list
#import "adjacency.typ": adjacency
#import "selector.typ": select-graph

/// Renders a graph with Graphviz.
///
/// See `render`'s documentation in `internals.typ` for a list of valid
/// arguments and their descriptions.
#let raw-render(
  /// A `raw` element containing Dot code.
  raw,
  ..args,
) = {
  assert(raw.has("text"), message: "`raw-render` expects a `raw` element")
  return render(raw.text, ..args)
}
