// Automatic placement for two-terminal electrical networks.

#import "../vector.typ"

#let _empty-layout(width, top: 0.7, bottom: 0.7) = (
  width: width,
  top: top,
  bottom: bottom,
  entry: (0, 0),
  exit: (width, 0),
  components: (),
  wires: (),
  junctions: (),
)

#let _component-layout(component, diagram-style) = {
  let layout = _empty-layout(diagram-style.component-length)
  layout.components.push((
    component: component,
    start: (0, 0),
    end: (diagram-style.component-length, 0),
    label-side: 1,
  ))
  layout
}

#let _translate-layout(layout, displacement) = (
  width: layout.width,
  top: layout.top + displacement.at(1),
  bottom: layout.bottom - displacement.at(1),
  entry: vector.add(layout.entry, displacement),
  exit: vector.add(layout.exit, displacement),
  components: layout.components.map(placed-component => (
    placed-component
      + (
        start: vector.add(placed-component.start, displacement),
        end: vector.add(placed-component.end, displacement),
        label-side: placed-component.label-side,
      )
  )),
  wires: layout.wires.map(path => path.map(
    point => vector.add(point, displacement),
  )),
  junctions: layout.junctions.map(
    point => vector.add(point, displacement),
  ),
)

#let _series-layout(network, diagram-style, layout-network) = {
  let child-layouts = network.branches.map(
    branch => layout-network(branch, diagram-style),
  )
  let combined = _empty-layout(0)
  let horizontal-position = 0
  let preceding-exit = (0, 0)
  for child-layout in child-layouts {
    let placed-child = _translate-layout(
      child-layout,
      (
        horizontal-position - child-layout.entry.at(0),
        preceding-exit.at(1) - child-layout.entry.at(1),
      ),
    )
    combined.components += placed-child.components
    combined.wires += placed-child.wires
    combined.junctions += placed-child.junctions
    combined.top = calc.max(combined.top, placed-child.top)
    combined.bottom = calc.max(combined.bottom, placed-child.bottom)
    preceding-exit = placed-child.exit
    horizontal-position += child-layout.width
  }
  combined.width = horizontal-position
  combined.exit = preceding-exit
  combined
}

#let _branch-baselines(child-layouts, gap) = {
  let full-height = child-layouts.map(
    child => child.top + child.bottom,
  ).sum() + gap * (child-layouts.len() - 1)
  let current-top = full-height / 2
  let baselines = ()
  for child in child-layouts {
    let baseline = current-top - child.top
    baselines.push(baseline)
    current-top = baseline - child.bottom - gap
  }
  baselines
}

#let _orthogonal-parallel-layout(network, diagram-style, layout-network) = {
  let child-layouts = network.branches.map(
    branch => layout-network(branch, diagram-style),
  )
  let branch-width = 0
  for child in child-layouts {
    branch-width = calc.max(branch-width, child.width)
  }
  let width = branch-width + 2 * diagram-style.branch-lead
  let split-x = diagram-style.branch-lead
  let join-x = width - diagram-style.branch-lead
  let baselines = _branch-baselines(child-layouts, diagram-style.parallel-gap)
  let combined = _empty-layout(width, top: 0, bottom: 0)

  let highest-point = 0
  let lowest-point = 0
  for (index, child-layout) in child-layouts.enumerate() {
    let baseline = baselines.at(index)
    let child-start-x = (width - child-layout.width) / 2
    let placed-child = _translate-layout(
      child-layout,
      (
        child-start-x - child-layout.entry.at(0),
        baseline - child-layout.entry.at(1),
      ),
    )
    combined.components += placed-child.components
    combined.wires += placed-child.wires
    combined.junctions += placed-child.junctions
    combined.wires.push(((split-x, baseline), placed-child.entry))
    combined.wires.push((
      placed-child.exit,
      (join-x, placed-child.exit.at(1)),
    ))
    highest-point = calc.max(highest-point, placed-child.top)
    lowest-point = calc.min(lowest-point, -placed-child.bottom)
  }

  let highest-baseline = baselines.fold(0, calc.max)
  let lowest-baseline = baselines.fold(0, calc.min)
  let exit-baselines = child-layouts.enumerate().map(((index, child-layout)) => (
    baselines.at(index)
      + child-layout.exit.at(1)
      - child-layout.entry.at(1)
  ))
  let highest-exit-baseline = exit-baselines.fold(0, calc.max)
  let lowest-exit-baseline = exit-baselines.fold(0, calc.min)
  combined.wires.push(((0, 0), (split-x, 0)))
  combined.wires.push(((split-x, lowest-baseline), (split-x, highest-baseline)))
  combined.wires.push((
    (join-x, lowest-exit-baseline),
    (join-x, highest-exit-baseline),
  ))
  combined.wires.push(((join-x, 0), (width, 0)))
  combined.junctions += ((split-x, 0), (join-x, 0))
  combined.top = highest-point
  combined.bottom = -lowest-point
  combined
}

// A parallel network whose branches declare routes is drawn as a frame: the
// split and join nodes are two corners, and each branch travels between them
// along one side, along the diagonal, or around the far corner.
#let _frame-routes(network) = {
  if network.kind != "parallel" { return none }
  let routed-branches = network.branches.filter(branch => branch.route != auto)
  if routed-branches.len() == 0 { return none }
  let branch-on(route-name) = {
    let matching = network.branches.filter(branch => branch.route == route-name)
    if matching.len() == 0 { none } else { matching.first() }
  }
  (
    over: branch-on("over"),
    direct: branch-on("direct"),
    under: branch-on("under"),
  )
}

#let _frame-branch-components(branch) = if branch.kind == "component" {
  (branch,)
} else {
  branch.branches
}

// Components spread evenly along one straight leg of the frame.
#let _components-along(components, leg-start, leg-end, label-side) = {
  let step = 1 / components.len()
  components.enumerate().map(((index, component)) => (
    component: component,
    start: vector.lerp(leg-start, leg-end, index * step),
    end: vector.lerp(leg-start, leg-end, (index + 1) * step),
    label-side: label-side,
  ))
}

// A branch that turns at a corner puts its first component on the leg out of
// the split node. With only one component the second leg is plain wire.
#let _placed-cornering-branch(branch, split, corner, join) = {
  let components = _frame-branch-components(branch)
  if components.len() == 1 {
    return (
      components: _components-along(components, split, corner, 1),
      wires: ((corner, join),),
    )
  }
  (
    components: (
      _components-along((components.first(),), split, corner, 1)
        + _components-along((components.last(),), corner, join, 1)
    ),
    wires: (),
  )
}

#let _frame-layout(network, diagram-style) = {
  let routes = _frame-routes(network)
  assert(routes != none)

  // Only a frame carrying branches on both sides needs its split and join at
  // different heights; otherwise they stay level and a branch peaks midway.
  let frame-descends = routes.over != none and routes.under != none
  let width = if frame-descends {
    diagram-style.component-length * 3.1 - 2 * diagram-style.branch-lead
  } else {
    diagram-style.component-length * 2.5
  }
  let label-clearance = if frame-descends { 0.9 } else { 0.75 }
  let half-rise = diagram-style.frame-rise / 2
  let split-node = if frame-descends { (0, half-rise) } else { (0, 0) }
  let join-node = if frame-descends { (width, -half-rise) } else { (width, 0) }
  let over-corner = if frame-descends { (width, half-rise) } else {
    (width / 2, diagram-style.apex-rise)
  }
  let under-corner = if frame-descends { (0, -half-rise) } else {
    (width / 2, -diagram-style.apex-rise)
  }

  let placed-components = ()
  let placed-wires = ()
  if routes.over != none {
    let placed = _placed-cornering-branch(
      routes.over,
      split-node,
      over-corner,
      join-node,
    )
    placed-components += placed.components
    placed-wires += placed.wires
  }
  if routes.direct != none {
    placed-components += _components-along(
      _frame-branch-components(routes.direct),
      split-node,
      join-node,
      // The direct branch is the lower edge of a level frame that bulges
      // upward, and the upper edge of one that bulges down.
      if not frame-descends and routes.over != none { -1 } else { 1 },
    )
  }
  if routes.under != none {
    let placed = _placed-cornering-branch(
      routes.under,
      split-node,
      under-corner,
      join-node,
    )
    placed-components += placed.components
    placed-wires += placed.wires
  }

  let highest-point = calc.max(
    split-node.at(1),
    if routes.over == none { split-node.at(1) } else { over-corner.at(1) },
  )
  let lowest-point = calc.min(
    join-node.at(1),
    if routes.under == none { join-node.at(1) } else { under-corner.at(1) },
  )
  (
    width: width,
    top: highest-point + label-clearance,
    bottom: -lowest-point + label-clearance,
    entry: split-node,
    exit: join-node,
    components: placed-components,
    wires: placed-wires,
    junctions: (split-node, join-node),
  )
}

#let network-layout(network, diagram-style) = {
  if network.kind == "component" {
    return _component-layout(network, diagram-style)
  }
  if network.kind == "series" {
    return _series-layout(network, diagram-style, network-layout)
  }
  if _frame-routes(network) != none {
    return _frame-layout(network, diagram-style)
  }
  _orthogonal-parallel-layout(network, diagram-style, network-layout)
}

#let _network-contains-parallel-branches(network) = {
  if network.kind == "parallel" { return true }
  if network.kind == "component" { return false }
  network.branches.any(_network-contains-parallel-branches)
}

#let _series-of(branches) = if branches.len() == 1 {
  branches.first()
} else {
  (kind: "series", branches: branches, route: auto)
}

// A DC circuit is a loop, so a series load that continues past its last
// parallel network belongs on both rails: the outgoing run leaves the source
// along the top, and the trailing branches come back along the return rail
// instead of pushing the loop further to the right.
#let _split-load-across-rails(network, diagram-style) = {
  let single-rail = (outgoing: network, returning: none)
  if network.kind != "series" { return single-rail }

  // A parallel network is the widest thing on the loop and anchors the
  // outgoing rail; nothing before or including it may return.
  let anchored-branch-count = 0
  for (index, branch) in network.branches.enumerate() {
    if _network-contains-parallel-branches(branch) {
      anchored-branch-count = index + 1
    }
  }

  let branch-widths = network.branches.map(
    branch => network-layout(branch, diagram-style).width,
  )
  let total-width = branch-widths.sum(default: 0)

  // Among the branches free to go either way, take the split that leaves the
  // two rails closest in width. Keeping everything on one rail is the starting
  // candidate, so a load with nothing worth folding stays as it is.
  let balanced-branch-count = network.branches.len()
  let smallest-difference = total-width
  for branch-count in range(
    calc.max(anchored-branch-count, 1),
    network.branches.len(),
  ) {
    let outgoing-width = branch-widths.slice(0, branch-count).sum(default: 0)
    let difference = calc.abs(outgoing-width - (total-width - outgoing-width))
    // Ties keep the longer run on the outgoing rail, where the eye starts.
    if difference <= smallest-difference {
      smallest-difference = difference
      balanced-branch-count = branch-count
    }
  }
  if balanced-branch-count == network.branches.len() { return single-rail }

  (
    outgoing: _series-of(network.branches.slice(0, balanced-branch-count)),
    // The returning run is walked from right to left, so its declared order is
    // reversed before it is laid out from the left edge like any other run.
    returning: _series-of(network.branches.slice(balanced-branch-count).rev()),
  )
}

// The leftmost x at which a placed run already occupies a level, used to decide
// whether returning components can share that level as the return rail.
#let _leftmost-content-x-at-or-below(layout, level) = {
  let occupied-x = ()
  for placement in layout.components {
    for point in (placement.start, placement.end) {
      if point.at(1) <= level { occupied-x.push(point.at(0)) }
    }
  }
  for wire-path in layout.wires {
    for point in wire-path {
      if point.at(1) <= level { occupied-x.push(point.at(0)) }
    }
  }
  if occupied-x.len() == 0 { return none }
  occupied-x.fold(occupied-x.first(), calc.min)
}

#let _frame-descends(network) = {
  let routes = _frame-routes(network)
  routes != none and routes.over != none and routes.under != none
}

#let circuit-layout(circuit, diagram-style, fold: auto) = {
  let rails = if fold == false {
    (outgoing: circuit.network, returning: none)
  } else {
    _split-load-across-rails(circuit.network, diagram-style)
  }
  assert(
    fold != true or rails.returning != none,
    message: "typed-physics: electricity.diagram(fold: true) found nothing to place on the return rail; that needs a series(...) load whose branches can be split between the two rails, and a single component, a bare parallel network, or a series ending in its parallel network cannot be. Use fold: auto or false for this topology",
  )

  let outgoing-layout = network-layout(rails.outgoing, diagram-style)
  // A frame's split and join dots are its own corners, so the outer loop needs
  // room to leave them horizontally before it turns toward the source.
  let corner-clearance = if _frame-descends(rails.outgoing) {
    diagram-style.branch-lead
  } else {
    0
  }
  let returning-layout = if rails.returning == none { none } else {
    network-layout(rails.returning, diagram-style)
  }
  let returning-width = if returning-layout == none { 0 } else {
    returning-layout.width
  }
  let returning-clearance = if returning-layout == none { 0 } else {
    returning-layout.top
  }

  // The source spans a component length down the left edge, so a load only one
  // component wide would close as a tall narrow loop. Widening the loop to a
  // floor keeps small circuits in a readable proportion. That added width
  // belongs to neither end, so it is split evenly and the runs sit centred on
  // their rails; a loop already wider than the floor keeps its runs against
  // the source, where the return rail can still meet a descending load.
  let content-width = calc.max(
    outgoing-layout.width + 2 * corner-clearance,
    returning-width,
  )
  let stretch = calc.max(
    0,
    diagram-style.minimum-loop-width - content-width,
  ) / 2
  let loop-width = content-width + 2 * stretch
  let returning-offset = if returning-layout == none { 0 } else { stretch }
  let placed-outgoing = _translate-layout(
    outgoing-layout,
    (corner-clearance + stretch, 0),
  )

  // The outgoing run's own exit level becomes the return rail when a load that
  // already descends can close directly along it. That needs room for the
  // source between the two levels on the left edge, and returning components
  // that stay left of wherever the outgoing run reaches down to that level.
  let entry-level = placed-outgoing.entry.at(1)
  let exit-level = placed-outgoing.exit.at(1)
  let descent-x = _leftmost-content-x-at-or-below(
    placed-outgoing,
    exit-level + returning-clearance,
  )
  let return-rail-shares-exit-level = (
    entry-level - exit-level >= diagram-style.component-length
      and descent-x != none
      and returning-offset + returning-width <= descent-x
  )

  let return-rail-y = if return-rail-shares-exit-level { exit-level } else {
    (
      -placed-outgoing.bottom
        - diagram-style.source-clearance
        - calc.max(diagram-style.component-length, returning-clearance)
    )
  }
  let placed-returning = if returning-layout == none { none } else {
    _translate-layout(returning-layout, (returning-offset, return-rail-y))
  }

  let source-start = (0, return-rail-y)
  let source-end = (0, return-rail-y + diagram-style.component-length)
  let outgoing-terminal = placed-outgoing.exit
  let return-rail-terminal = (
    returning-offset + returning-width,
    return-rail-y,
  )
  // A centred returning run needs a lead back to the source along its rail.
  let return-rail-lead = if returning-offset > 0 {
    ((source-start, (returning-offset, return-rail-y)),)
  } else {
    ()
  }

  (
    width: loop-width,
    top: placed-outgoing.top,
    // A rail that shares the load's exit level sits above the load's own
    // lowest point, so the load still sets the extent there.
    bottom: calc.max(
      placed-outgoing.bottom,
      -return-rail-y + 0.65,
      if placed-returning == none { 0 } else { placed-returning.bottom },
    ),
    components: (
      placed-outgoing.components
        + if placed-returning == none { () } else {
          placed-returning.components
        }
        + ((
          component: circuit.source,
          start: source-start,
          end: source-end,
          label-side: 1,
        ),)
    ),
    wires: (
      placed-outgoing.wires
        + if placed-returning == none { () } else { placed-returning.wires }
        + (
          (
            placed-outgoing.entry,
            (0, placed-outgoing.entry.at(1)),
            source-end,
          ),
        )
        + return-rail-lead
        + if return-rail-shares-exit-level {
          ((outgoing-terminal, return-rail-terminal),)
        } else {
          ((
            outgoing-terminal,
            (loop-width, outgoing-terminal.at(1)),
            (loop-width, return-rail-y),
            return-rail-terminal,
          ),)
        }
    ),
    junctions: (
      placed-outgoing.junctions
        + if placed-returning == none { () } else {
          placed-returning.junctions
        }
    ),
  )
}
