// Graph-specific argument, structure, and reference validation.
//
// These checks run at public calls. They understand adjacency entries, graph
// edges, and relative placements and therefore remain in the graph domain.

#import "style.typ": (
  validate-style, check-coordinate-pair, check-edge-customization-options,
  check-node-customization-options, check-node-label-override,
)
#import "validate.typ": (
  check-array, check-bool, check-customization-entries, check-dictionary,
  check-enum, check-id-value-references, check-known-keys, check-number,
  check-positive, check-reference, fail, is-number,
  normalize-id-value-entries, show-list, show-value,
)
#import "graph-model.typ": (
  _collect-graph-edges, _collect-graph-node-ids, _edge-target-id,
  _normalize-undirected-edge-key,
)

// ── Validation ───────────────────────────────────────────────────────────────
//
// Identity comes from the adjacency keys, so everything else — labels,
// positions, customizations, traversal endpoints — is checked against the node
// set those keys produce. A neighbour that appears only as someone else's
// target is a declared node too, by design.

#let graph-layouts = ("auto", "linear", "manual")

#let _validate-graph-adjacency(where, adjacency) = {
  check-dictionary(
    where, "adjacency", adjacency,
    fix: "pass a dictionary, for example (\"a\": (\"b\",), \"b\": ())",
  )
  for (from-node-id, edge-entries) in adjacency {
    let entries-name = "adjacency entry \"" + from-node-id + "\""
    check-array(
      where, entries-name, edge-entries,
      fix: "list the neighbours in an array, for example \"" + from-node-id + "\": (\"b\",)",
    )
    for (entry-index, edge-entry) in edge-entries.enumerate() {
      let entry-name = entries-name + " neighbour " + str(entry-index)
      if type(edge-entry) == str { continue }
      let is-labelled-pair = (
        type(edge-entry) == array
          and edge-entry.len() in (1, 2)
          and type(edge-entry.at(0)) == str
      )
      if is-labelled-pair { continue }
      fail(
        where,
        entry-name + " is " + show-value(edge-entry),
        expected: "a neighbour name, or a (neighbour, edge-label) pair",
        fix: "write it as \"b\", or (\"b\", [w]) to label the edge",
      )
    }
  }
}

#let _graph-edge-key(from-node-id, to-node-id, directed) = if directed {
  from-node-id + "\u{0}" + to-node-id
} else {
  _normalize-undirected-edge-key(from-node-id, to-node-id)
}

#let _show-graph-edges(graph-edges, directed) = if graph-edges.len() == 0 {
  "(the graph has no edges)"
} else {
  graph-edges.map(
    edge => edge.at(0) + (if directed { " -> " } else { " -- " }) + edge.at(1),
  ).join(", ")
}

#let _validate-graph-edge-references(where, adjacency, directed, edge-customizations) = {
  check-customization-entries(
    where,
    "edge-customizations:",
    edge-customizations,
    3,
    check-edge-customization-options,
  )
  let graph-edges = _collect-graph-edges(adjacency, directed)
  let declared-edge-keys = graph-edges.map(
    edge => _graph-edge-key(edge.at(0), edge.at(1), directed),
  )
  for (custom-from-id, custom-to-id, _) in edge-customizations {
    let customized-edge-key = _graph-edge-key(custom-from-id, custom-to-id, directed)
    if customized-edge-key in declared-edge-keys { continue }
    fail(
      where,
      "edge-customizations: refers to edge " + custom-from-id + " -> " + custom-to-id + ", which does not exist in the graph",
      expected: "one of the edges: " + _show-graph-edges(graph-edges, directed),
      fix: if directed {
        "a directed edge is customized in its declared direction"
      } else {
        "declare the edge in the adjacency dictionary first"
      },
    )
  }
}

// A relative position that eventually points back at itself can never be
// resolved, so the placement loop would silently leave those nodes wherever
// the base layout happened to put them.
#let _check-relative-position-cycles(where, positions) = {
  for start-node-id in positions.keys() {
    let visited-node-ids = (start-node-id,)
    let current-node-id = start-node-id
    while true {
      let position-specification = positions.at(current-node-id, default: none)
      let is-relative = (
        type(position-specification) == dictionary
          and "rel" in position-specification
      )
      if not is-relative { break }
      let reference-node-id = position-specification.rel
      if reference-node-id in visited-node-ids {
        fail(
          where,
          "positions: relative placements form a cycle: " + (visited-node-ids + (reference-node-id,)).join(" -> "),
          expected: "every relative chain to end at an absolute (x, y) position",
          fix: "give one node in the cycle an absolute position",
        )
      }
      visited-node-ids.push(reference-node-id)
      current-node-id = reference-node-id
    }
  }
}

#let _validate-graph-positions(where, positions, node-ids) = {
  check-dictionary(
    where, "positions:", positions,
    fix: "pass a dictionary keyed by node name",
  )
  for (node-id, position-specification) in positions {
    check-reference(where, "positions:", node-id, node-ids)
    let what = "positions.\"" + node-id + "\""
    if type(position-specification) == dictionary {
      check-known-keys(where, what, position-specification, ("rel", "offset"))
      if "rel" not in position-specification {
        fail(
          where,
          what + " has no \"rel\" entry",
          expected: "an (x, y) pair, or (rel: other-node, offset: (dx, dy))",
          fix: "name the node this one is placed against",
        )
      }
      check-reference(where, what + ".rel", position-specification.rel, node-ids)
      if "offset" in position-specification {
        check-coordinate-pair(where, what + ".offset", position-specification.offset)
      }
      continue
    }
    check-coordinate-pair(where, what, position-specification)
  }
  _check-relative-position-cycles(where, positions)
}

#let _validate-graph-layout(where, layout, radius, gap, positions, node-ids) = {
  check-enum(where, "layout:", layout, graph-layouts)
  if radius != auto {
    check-positive(where, "radius:", radius)
    if layout != "auto" {
      fail(
        where,
        "radius: was given with layout \"" + layout + "\"",
        expected: "radius: only applies to layout \"auto\", which places nodes on a circle",
        fix: "drop radius:, or switch to layout: \"auto\"",
      )
    }
  }
  if gap != auto {
    check-positive(where, "gap:", gap)
    if layout != "linear" {
      fail(
        where,
        "gap: was given with layout \"" + layout + "\"",
        expected: "gap: only applies to layout \"linear\", which spaces nodes in a row",
        fix: "drop gap:, or switch to layout: \"linear\"",
      )
    }
  }
  _validate-graph-positions(where, positions, node-ids)
  if layout != "manual" { return }
  for node-id in node-ids {
    if node-id in positions { continue }
    fail(
      where,
      "layout \"manual\" has no position for node \"" + node-id + "\"",
      expected: "a positions: entry for every node: " + show-list(node-ids),
      fix: "add \"" + node-id + "\": (x, y), or use layout: \"auto\"",
    )
  }
}

#let _validate-graph-arguments(
  where,
  adjacency,
  directed,
  labels,
  positions,
  layout,
  radius,
  gap,
  edge-customizations,
  node-customizations,
  node-labels,
  style,
) = {
  _validate-graph-adjacency(where, adjacency)
  check-bool(where, "directed:", directed)
  validate-style(where, style)
  let node-ids = _collect-graph-node-ids(adjacency)
  _validate-graph-layout(where, layout, radius, gap, positions, node-ids)
  check-dictionary(
    where, "labels:", labels,
    fix: "pass a dictionary keyed by node name, for example labels: (\"a\": [$alpha$])",
  )
  check-id-value-references(where, "labels:", labels, node-ids)
  check-id-value-references(where, "node-labels:", node-labels, node-ids)
  for (_, label-value) in normalize-id-value-entries(where, "node-labels:", node-labels) {
    check-node-label-override(where, "node-labels: entry", label-value)
  }
  check-customization-entries(
    where,
    "node-customizations:",
    node-customizations,
    2,
    check-node-customization-options,
  )
  for (node-id, _) in node-customizations {
    check-reference(where, "node-customizations:", node-id, node-ids)
  }
  _validate-graph-edge-references(where, adjacency, directed, edge-customizations)
  node-ids
}
