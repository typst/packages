#import "routing/numeric.typ": _deixis-numeric-length, _deixis-numeric-point
#import "routing/scene.typ": deixis-routing-scene, _deixis-scene-pair
#import "routing/scene-path.typ": _deixis-scene-search-endpoint, _deixis-scene-search-geometry
#import "routing/scene-interactions.typ": _deixis-scene-complete
#import "routing/group-plan.typ": _deixis-plan-group

#let _deixis-group-edges(scene, edges) = {
  let resolved = ()
  let keys = ()
  for (index, edge) in edges.enumerate() {
    assert(type(edge) == dictionary and ("from", "to").all(k => k in edge)
      and edge.keys().all(k => k in ("from", "to", "via", "page", "id")),
      message: "deixis: Routing group edges require from and to; optional fields are via, page and id.")
    let id = edge.at("id", default: none)
    if type(id) == label { id = str(id) }
    assert(id == none or (type(id) == str and id != ""),
      message: "deixis: Routing group edge id must be none or a nonempty string or label.")
    let via = edge.at("via", default: none)
    if via == none { via = () }
    assert(type(via) == array, message: "deixis: Routing group via must be an array of absolute points.")
    via = via.map(_deixis-numeric-point).map(p => p.map(v => v.pt()))
    let pair = _deixis-scene-pair(scene, edge.from, edge.to, edge.at("page", default: none))
    let key = (id, pair.page)
    if id != none {
      assert(key not in keys, message: "deixis: Routing group has a duplicate edge ID on the same page.")
      keys.push(key)
    }
    if pair.kind == "deixis-route-failure" {
      resolved.push((id: id, page: pair.page, failure: pair))
      continue
    }
    let endpoint(port, node) = {
      let e = _deixis-scene-search-endpoint(port)
      // Existing scene identity plus the literal resolved socket. No public
      // junction namespace; anonymous coincident coordinates remain accidental.
      e + (junction: if node == none { none } else { (node.index, e.point) })
    }
    resolved.push((id: id, page: pair.page, via: via,
      from: endpoint(pair.start, pair.source.node), to: endpoint(pair.end, pair.target.node)))
  }
  resolved
}

#let _deixis-group-quality(metrics) = {
  let result = (:)
  for key in ("missing", "contacts", "crossings") { result.insert(key, metrics.at(key)) }
  for key in ("length", "score", "exposure", "overlap", "shared", "energy") {
    let value = metrics.at(key)
    assert(value == value and calc.abs(value) < calc.inf,
      message: "deixis: Routing group costs overflow; reduce coordinate magnitudes or weight.")
    result.insert(key, value * 1pt)
  }
  result
}

#let _deixis-group-result(scene, plan) = {
  let routes = plan.records.enumerate().map(((index, record)) => {
    let geometry = _deixis-scene-search-geometry(record, record.page)
    if geometry.status == "ok" {
      let prepared = scene.planes.find(p => p.page == record.page)
      geometry = _deixis-scene-complete(geometry, prepared, record.page)
    }
    geometry + (index: index, id: record.id)
  })
  (kind: "deixis-route-group", routes: routes,
    quality: if plan.metrics == none { none } else {
      (before: _deixis-group-quality(plan.baseline-metrics), after: _deixis-group-quality(plan.metrics))
    },
    stats: (searches: plan.searches.len(), expanded: plan.expanded, rounds: plan.rounds-run, limits-hit: plan.limits-hit))
}

/// Plans up to sixteen explicit sharp orthogonal page fragments together.
/// Each edge uses from/to scene endpoints, optional exact via points, page and
/// caller id. Anonymous edges need no identity. Array order sets priority/ties.
///
/// spacing measures centerline proximity, not stroke/head clearance. Accepted
/// repairs preserve successful routes, independent detour limits and per-page
/// contact/crossing/overlap guards. Budgets retain checked incumbent geometry;
/// complete separation and globally optimal packing are not guaranteed.
///
/// Returns routes in input order, native-length before/after quality, and work
/// statistics. Successful entries are ordinary deixis-route geometry, ready for
/// deixis-prepare-connector. No setup, registration or painting is performed.
#let deixis-route-group(
  /// Up to sixteen from/to fragment records, optional exact via, page and caller ID; array order sets priority.
  /// -> array
  edges,
  /// Prepared routing scene shared by all edges; none supplies an empty scene.
  /// -> none | dictionary
  scene: none,
  /// Positive absolute centerline proximity distance; separate from ink/head clearance.
  /// -> length
  spacing: 3pt,
  /// Finite nonnegative proximity penalty weight.
  /// -> int | float
  weight: 4,
  /// Finite nonnegative ratio limiting additional length relative to each independent route.
  /// -> ratio
  max-detour: 25%,
  /// Integer repair-round budget from zero through four; zero retains the initial independent and soft planning.
  /// -> int
  rounds: 2,
  /// Positive integer shared search budget; checked incumbent geometry survives exhausted budgets.
  /// -> int
  max-searches: 64,
  /// Positive integer shared expansion budget for the group.
  /// -> int
  max-expansions: 50000,
) = {
  assert(type(edges) == array and edges.len() <= 16,
    message: "deixis: Routing group edges must be an array of at most sixteen fragments.")
  assert(_deixis-numeric-length(spacing) and spacing > 0pt,
    message: "deixis: Routing group spacing needs a finite positive absolute length.")
  assert(type(weight) in (int, float) and weight == weight and 0 <= weight and weight < calc.inf,
    message: "deixis: Routing group weight must be a finite nonnegative number.")
  assert(type(max-detour) == ratio and max-detour == max-detour and 0% <= max-detour and max-detour / 100% < calc.inf,
    message: "deixis: Routing group max-detour must be a finite nonnegative ratio.")
  assert(type(rounds) == int and rounds in range(5),
    message: "deixis: Routing group rounds must be an integer from zero through four.")
  assert(type(max-searches) == int and max-searches > 0 and type(max-expansions) == int and max-expansions > 0,
    message: "deixis: Routing group search/expansion limits must be positive integers.")
  if scene == none { scene = deixis-routing-scene() }
  assert(type(scene) == dictionary and scene.at("kind", default: none) == "deixis-routing-scene",
    message: "deixis: Numeric routing scene must come from deixis-routing-scene.")
  let edges = _deixis-group-edges(scene, edges)
  let plan = _deixis-plan-group(scene, edges, spacing: spacing.pt(), weight: weight,
    length-ratio: 1 + max-detour / 100%, rounds: rounds,
    max-searches: max-searches, max-expansions: max-expansions)
  _deixis-group-result(scene, plan)
}
