#import "attached.typ": _deixis-attached-nodes
#import "pins.typ": _deixis-resolve-edge-pins, _deixis-has-routing-pins
#import "../core/query.typ": _deixis-pin-index
#import "../render/body.typ": _deixis-inherited-content
#import "../render/commands.typ": _deixis-paint-command
#import "path.typ": _deixis-route-connection, _deixis-paint-route-fragment
#import "scene.typ": deixis-routing-scene
#import "connector-scene.typ": _deixis-scene-connector-port, _deixis-scene-entity, _deixis-scene-connector-choices
#import "scene-path.typ": _deixis-scene-search-endpoint
#import "group-plan.typ": _deixis-plan-group
#import "../route-group.typ": _deixis-group-result
#import "notes.typ": _deixis-paint-connection-highlight

// Geometry lengths were frozen at declaration; accepted endpoint frames can be
// collected and planned in the same native pass. No head/painter runs here.
#let _deixis-routing-fragments(layer, members) = {
  let page = here().page()
  let pins = if members.any(p => _deixis-has-routing-pins(p.edge.options)) { _deixis-pin-index() } else { auto }
  let records = ()
  for prepared in members {
    let edge = _deixis-resolve-edge-pins(prepared.edge, index: pins)
    if edge == none { continue }
    let fragment = _deixis-route-connection(edge, page, prepare-only: true)
    records.push((fragment: fragment, policy: prepared.routing, identity: prepared.identity,
      page: page, layer: edge.layer, render-context: prepared.render-context,
      highlight: if page == edge.source.page { prepared.highlight } else { none },
      z-index: edge.options.at("z-index", default: 0)))
  }
  records
}

#let _deixis-collected-scene(nodes, policy, page) = {
  let nodes = nodes.filter(n => n.page == page and not n.hidden)
  let frame = query(<deixis-page-frame>).find(f => f.value.page == page)
  assert(frame != none, message: "deixis: Collected routing requires the physical page background hook; install deixis-page-overlay(layer: background).")
  let scene = deixis-routing-scene(nodes: nodes.map(n => (
    bounds: n.bounds.pairs().filter(((k, v)) => k in ("left", "right", "top", "bottom"))
      .fold((:), (out, p) => out + ((p.first()): p.last())),
    behavior: n.behavior, page: page)) + policy.at("nodes", default: ()),
    pages: ((page: page, bounds: (left: 0pt, top: 0pt, right: frame.value.width, bottom: frame.value.height)),),
    ..policy.scene)
  // The pure scene constructor owns geometry validation/indexes. Add semantic
  // ownership at this document boundary, without weakening public numeric input.
  let owned(n) = if n.index < nodes.len() {
    n + (entity: _deixis-scene-entity("node", nodes.at(n.index).identity))
  } else { n }
  scene.nodes = scene.nodes.map(owned)
  scene.planes = scene.planes.map(p => p + (nodes: p.nodes.map(owned)))
  scene
}

// Immutable plans per lexical policy, physical page and layer. Priority bands
// consume the same numeric result; live output never participates in searching.
#let _deixis-routing-plans(layer, connections) = {
  let page = here().page()
  let records = _deixis-routing-fragments(layer, connections)
  if records.len() == 0 { return () }
  let nodes = _deixis-attached-nodes()
  let groups = records.map(r => r.policy.identity).dedup()
  let plans = ()
  for identity in groups {
    let members = records.filter(r => r.policy.identity == identity)
    assert(members.len() <= 16, message: "deixis: Collected routing supports at most sixteen connections per scope, physical page and layer; use separate routing wrappers.")
    let policy = members.first().policy
    let scene = _deixis-collected-scene(nodes, policy, page)
    let plane = scene.planes.find(p => p.page == page)
    let edges = members.map(m => {
      let f = m.fragment
      let logical = f.document.fragment.logical
      let owned(port, node, role) = {
        _deixis-scene-connector-port(plane, port.point, port.normal, node, role)
      }
      let source-node = if f.document.is-incoming { none } else { logical.source }
      let target-node = if f.document.is-outgoing { none } else { logical.target }
      let source = owned(f.from, source-node, "mark")
      let target = owned(f.to, target-node, "body")
      let visits = f.via.map(p => p.map(v => v.pt()))
      let choices = _deixis-scene-connector-choices(scene, plane, source, target, visits, f.document, f.choices)
      let endpoint(port, node, role) = {
        let numeric = _deixis-scene-search-endpoint(port)
        let entity = if node == none { none } else { _deixis-scene-entity(role, node.identity) }
        numeric + (junction: if entity == none { none } else { (entity, numeric.point) })
      }
      let edge = (id: none, page: page, via: visits,
        reselect: f.boundary != none or (not f.document.is-incoming and not f.document.is-outgoing),
        from: endpoint(source, source-node, "mark"), to: endpoint(target, target-node, "body"))
      let sources = choices.source.map(p => endpoint(p, source-node, "mark"))
      let targets = choices.target.map(p => endpoint(p, target-node, "body"))
      if sources.len() > 1 or targets.len() > 1 or f.boundary != none {
        edge += (allocation: (source: sources, target: targets, boundary: f.boundary,
          reverse: f.boundary != none and f.document.is-incoming))
      }
      edge
    })
    let options = policy.group
    let raw = _deixis-plan-group(scene, edges, spacing: options.spacing.pt(), weight: options.weight,
      length-ratio: 1 + options.max-detour / 100%, rounds: options.rounds,
      max-searches: options.max-searches, max-expansions: options.max-expansions,
      independent: policy.mode == "avoid", reselect: policy.mode == "separate")
    let plan = _deixis-group-result(scene, raw)
    plans.push((identity: identity, page: page, layer: layer, policy: policy.mode, members: members, plan: plan))
  }
  plans
}

#let _deixis-routing-paint-commands(layer, connections, start-order: 0) = {
  let commands = ()
  let ordinal = start-order
  for data in _deixis-routing-plans(layer, connections) {
    commands.push(_deixis-paint-command("routing-plan", data.identity,
      () => [#metadata(data)<deixis-routing-plan>]))
    for (member, route) in data.members.zip(data.plan.routes) {
      let order = (member.z-index, ordinal)
      ordinal += 1
      if route.status != "ok" { continue }
      commands.push(_deixis-paint-command("connection", member.identity,
        () => _deixis-inherited-content(member, context {
          _deixis-paint-connection-highlight(member.highlight, member.fragment.draw.named().link-stroke)
          _deixis-paint-route-fragment(member.fragment, route, crossing-order: order)
        }),
        priority: member.z-index))
    }
  }
  commands
}

#let _deixis-validate-routing-plans() = {
  for item in query(<deixis-routing-plan>) {
    for route in item.value.plan.routes {
      assert(route.status == "ok", message: "deixis: Collected routing failed on physical page "
        + str(item.value.page) + ": " + route.status + " (" + route.at("detail", default: "unknown")
        + "). Adjust nodes, ports, waypoints or routing limits; no unchecked fallback was painted.")
    }
  }
}
