// WASM bridge. Rendering stays in the calling Typst document.
#let _engine = plugin("../plugin/fast_layout_engine.wasm")

// CBOR distinguishes integers from floats; Rust's numeric fields expect floats.
#let _float(value) = if type(value) == int { float(value) } else { value }

/// Returns the bundled engine version string.
#let engine-version() = str(_engine.version())

/// Computes coordinates for an indexed graph.
///
/// Node indices are zero-based. The returned `positions` preserve node order.
#let layout(
  node-count,
  edges,
  algorithm: "stress",
  stress-method: "sgd",
  dim: 2,
  seed: 1,
  iterations: none,
  tolerance: 1e-5,
  initial: (),
  pins: (),
  edge-weights: (),
  theta: none,
  c: none,
  temperature: none,
  node-weights: (),
  shells: (),
  node-sizes: (),
  root: 0,
) = {
  let algorithm = if algorithm == "circular" { "shell" } else { algorithm }
  if not ("stress", "spring", "spectral", "shell", "buchheim").contains(algorithm) {
    panic("unknown algorithm: " + repr(algorithm))
  }
  let request = cbor.encode((
    nodes: node-count,
    edges: edges,
    algorithm: algorithm,
    stress_method: stress-method,
    dim: dim,
    seed: seed,
    iterations: iterations,
    tolerance: _float(tolerance),
    initial: initial.map(point => if point == none { none } else { point.map(_float) }),
    pins: pins,
    edge_weights: edge-weights.map(_float),
    theta: _float(theta),
    c: _float(c),
    temperature: _float(temperature),
    node_weights: node-weights.map(_float),
    shells: shells,
    node_sizes: node-sizes.map(_float),
    root: root,
  ))
  cbor(_engine.layout(request))
}
