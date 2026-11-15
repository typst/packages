#import "../core/targets.typ": _deixis-check-setup-state
#import "../route-group.typ": deixis-route-group
#import "scene.typ": deixis-routing-scene
#import "document-nodes.typ": _deixis-scene-node-selector

// Native boundary locations form lexical scopes without a mutable state chain
// through nested wrappers. Markers are placed immediately; only declarations
// query them. The body remains inspectable by presentation frameworks.
#let _deixis-routing-policy() = {
  let stack = ()
  for marker in query(selector(<deixis-routing-start>).or(<deixis-routing-end>).before(here())) {
    if marker.label == <deixis-routing-start> {
      stack.push(marker.value + (identity: marker.location()))
    } else if stack.len() > 0 { let _ = stack.pop() }
  }
  stack.at(-1, default: none)
}

// Freeze only geometric lengths at the declaration's native context. Painting
// retains the original options and captured styles. Thus collecting endpoints
// from late note frames adds no extra layout/evidence pass per connection.
#let _deixis-routing-lengths(value) = {
  if type(value) == length { value.to-absolute() }
  else if type(value) == relative { value.length.to-absolute() + value.ratio }
  else if type(value) == array { value.map(_deixis-routing-lengths) }
  else if type(value) == dictionary {
    value.pairs().fold((:), (out, pair) => out + ((pair.first()): _deixis-routing-lengths(pair.last())))
  } else { value }
}

#let _deixis-routing-options(options) = {
  let result = (:)
  for key in ("route", "ports", "via", "radius", "spill") {
    result.insert(key, _deixis-routing-lengths(options.at(key, default: auto)))
  }
  result
}

// Capture at the declaration, including a note body's shorthand edge. Native
// geometry and enabling/disabling a shorthand remain owned by its connector.
#let _deixis-capture-routing(options, routing: auto) = {
  let routing = if routing == auto { _deixis-routing-policy() } else { routing }
  let collected = routing != none and routing.mode != "manual"
  assert(not collected or options.scene == none,
    message: "deixis: A collected connection uses its routing scope's registered nodes; connector.scene is only available outside deixis-routing or with policy: manual.")
  (routing: if collected { routing } else { none },
    routing-options: if collected { _deixis-routing-options(options) } else { (:) })
}

/// Scopes the routing policy for independent and margin/inset shorthand edges.
/// Attach geometry where it is rendered with deixis-attach(id: ...)[...]. Nodes
/// stay fixed; searched connections in this lexical scope are planned per
/// physical page and overlay layer, independently of declaration position.
/// Nested wrappers form separate groups. All explicitly attached routing nodes
/// on a page supply its obstacles. Optional nodes adds existing scene selectors
/// for accepted notes/pins or literal bounds with an explicit physical page.
/// The list belongs to this wrapper, with geometry resolved only for searched
/// groups. Padding lengths freeze in the wrapper's declaration font context.
/// Shorthand captures at the body declaration;
/// it keeps its enabled state and geometry, and body placement stays unchanged.
/// policy is manual (native geometry, no automatic registered-scene search),
/// avoid (independent obstacle routing) or separate (checked group repair).
/// Search policies require sharp orthogonal routes; manual also permits curves
/// and exact mixed sections. Heads/cuts/renderers retain the connector API.
/// Requires setup. No automatic discovery of other ink.
#let deixis-routing(
  /// Content in this lexical routing scope; native content brackets alone do not establish a policy.
  /// -> content
  body,
  /// manual uses native routes, avoid searches obstacles independently, separate repairs a page/layer group.
  /// -> str
  policy: "separate",
  /// Additional accepted note/pin selectors or literal bounds with physical page; attached routing nodes are included automatically.
  /// -> array
  nodes: (),
  /// Nonnegative avoidance padding, resolved in the declaration font context. Centerline clearance only.
  /// -> length
  clearance: 4pt,
  /// Positive endpoint escape distance.
  /// -> length
  escape: 4pt,
  /// Nonnegative orthogonal turn penalty.
  /// -> length
  bend-cost: 12pt,
  /// Positive centerline proximity distance for separate groups.
  /// -> length
  spacing: 3pt,
  /// Finite nonnegative proximity penalty weight.
  /// -> int | float
  weight: 4,
  /// Finite nonnegative ratio limiting additional length per independent route.
  /// -> ratio
  max-detour: 25%,
  /// Integer repair-round budget from zero through four.
  /// -> int
  rounds: 2,
  /// Positive integer shared group search budget.
  /// -> int
  max-searches: 64,
  /// Positive integer expansion budget.
  /// -> int
  max-expansions: 50000,
  /// Positive integer per-search grid-cell budget.
  /// -> int
  max-cells: 65536,
) = {
  assert(policy in ("manual", "avoid", "separate"),
    message: "deixis: Routing policy must be manual, avoid or separate.")
  assert(type(nodes) == array and nodes.len() <= 128,
    message: "deixis: Routing nodes must be an array of at most 128 scene node specifications.")
  for node in nodes {
    let selector = _deixis-scene-node-selector(node)
    assert(selector != "bounds" or (type(node.at("page", default: none)) == int and node.page > 0),
      message: "deixis: Routing literal bounds need an explicit positive physical page; unpaged bounds belong to deixis-routing-scene.")
  }
  // Reuse the public numeric validation without searching or laying out content.
  let _ = deixis-routing-scene(nodes: nodes.filter(n => "bounds" in n),
    clearance: clearance, escape: escape, bend-cost: bend-cost,
    max-cells: max-cells, max-expansions: max-expansions)
  let _ = deixis-route-group((), spacing: spacing, weight: weight, max-detour: max-detour,
    rounds: rounds, max-searches: max-searches, max-expansions: max-expansions)
  let policy = (mode: policy, nodes: nodes, scene: (clearance: clearance, escape: escape, bend-cost: bend-cost,
      max-cells: max-cells, max-expansions: max-expansions),
    group: (spacing: spacing, weight: weight, max-detour: max-detour, rounds: rounds,
      max-searches: max-searches, max-expansions: max-expansions))
  context _deixis-check-setup-state()
  if nodes.len() == 0 { [#metadata(policy)<deixis-routing-start>] }
  else {
    context {
      let frozen = policy + (nodes: _deixis-routing-lengths(nodes))
      [#metadata(frozen)<deixis-routing-start>]
    }
  }
  body
  [#metadata(none)<deixis-routing-end>]
}
