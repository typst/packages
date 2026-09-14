// Vector math helpers
#let vec-sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vec-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vec-scale(v, s) = (v.at(0) * s, v.at(1) * s)
#let vec-norm-sq(v) = calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2)
#let vec-norm(v) = calc.sqrt(vec-norm-sq(v))

// Layout Constants
#let ITERATIONS = 600
#let K = 3.0 // Increased K to spread out more
#let REPULSION-STRENGTH = 2.0
#let ATTRACTION-STRENGTH = 1.0
#let COOLING-FACTOR = 0.99 // Much slower cooling to allow untangling
#let TOL = 0.01

// Initial layout on a grid to avoid worst-case circular crossings
#let initial-pos(index, total) = {
  let cols = int(calc.ceil(calc.sqrt(total)))
  if cols == 0 { cols = 1 }
  let row = int(index / cols)
  let col = calc.rem(index, cols)
  // Center the grid roughly
  let x = col * 5.0
  let y = row * 5.0
  (x, y)
}

// --- Layered Layout Implementation ---

#let get-degrees(nodes, edges) = {
  let in-degree = (:)
  let out-degree = (:)
  let incoming = (:)
  let outgoing = (:)

  for id in nodes.keys() {
    in-degree.insert(id, 0)
    out-degree.insert(id, 0)
    incoming.insert(id, ())
    outgoing.insert(id, ())
  }

  for e in edges {
    let u = e.start
    let v = e.end
    if u in nodes and v in nodes {
      out-degree.insert(u, out-degree.at(u) + 1)
      in-degree.insert(v, in-degree.at(v) + 1)
      outgoing.insert(u, outgoing.at(u) + (v,))
      incoming.insert(v, incoming.at(v) + (u,))
    }
  }
  (in-degree, out-degree, incoming, outgoing)
}

#let compute-layered-layout(nodes, edges, node-sep: 4.0, rank-sep: 6.0) = {
  let node-ids = nodes.keys()

  // Preserve original definition order for later sorting
  let definition-order = (:)
  for (i, id) in node-ids.enumerate() { definition-order.insert(id, i) }

  // 1. Cycle Removal (Greedy Heuristic)
  // G is modified destructively in the algo description, so we simulate that with sets.
  let remaining-nodes = node-ids.map(x => x) // copy
  let edges-acyclic = ()
  let edges-original = edges

  // We need to re-compute degrees dynamically as we remove nodes
  // But strictly following the algo:
  // "remove INCOMING-EDGES(G, v) from E(G)" implies we only consider edges between remaining nodes.

  let left-seq = ()
  let right-seq = ()

  // Helper to re-calc degrees for remaining sub-graph
  let recalc-graph(current-nodes, all-edges) = {
    let in-d = (:)
    let out-d = (:)
    let sources = ()
    let sinks = ()

    for u in current-nodes {
      in-d.insert(u, 0)
      out-d.insert(u, 0)
    }

    for e in all-edges {
      if e.start in current-nodes and e.end in current-nodes {
        out-d.insert(e.start, out-d.at(e.start) + 1)
        in-d.insert(e.end, in-d.at(e.end) + 1)
      }
    }

    for u in current-nodes {
      if in-d.at(u) == 0 { sources.push(u) }
      if out-d.at(u) == 0 { sinks.push(u) }
    }
    (in-d, out-d, sources, sinks)
  }

  while remaining-nodes.len() > 0 {
    let (in-d, out-d, sources, sinks) = recalc-graph(remaining-nodes, edges-original)

    // Handle Sinks
    while sinks.len() > 0 {
      let v = sinks.pop()
      if v not in remaining-nodes { continue }
      // Prepend to right sequence so outer sinks are at the very end
      right-seq.insert(0, v)
      remaining-nodes = remaining-nodes.filter(n => n != v)

      let res = recalc-graph(remaining-nodes, edges-original)
      in-d = res.at(0)
      out-d = res.at(1)
      sources = res.at(2)
      sinks = res.at(3)
    }

    if remaining-nodes.len() == 0 { break }

    // Handle Sources
    while sources.len() > 0 {
      let v = sources.pop()
      if v not in remaining-nodes { continue }
      // Append to left sequence
      left-seq.push(v)
      remaining-nodes = remaining-nodes.filter(n => n != v)
      let res = recalc-graph(remaining-nodes, edges-original)
      in-d = res.at(0)
      out-d = res.at(1)
      sources = res.at(2)
      sinks = res.at(3)
    }

    if remaining-nodes.len() == 0 { break }

    // Handle remaining (Max diff)
    let max-diff = -99999
    let candidate = none
    for u in remaining-nodes {
      let diff = out-d.at(u) - in-d.at(u)
      if diff > max-diff {
        max-diff = diff
        candidate = u
      }
    }

    if candidate != none {
      left-seq.push(candidate) // Treat as source
      remaining-nodes = remaining-nodes.filter(n => n != candidate)
    }
  }

  let layout-sequence = left-seq + right-seq

  // 2. Layer Assignment using BFS (Minimum Distance from Sources)
  // This places nodes as early as possible, so "vertical" edges inside a box
  // don't push nodes to later layers unnecessarily.

  let layers = (:)
  for id in layout-sequence { layers.insert(id, -1) } // -1 = unvisited

  // Find sources (nodes with no incoming edges from within the node set)
  let has-incoming = (:)
  for id in node-ids { has-incoming.insert(id, false) }
  for e in edges {
    if e.end in has-incoming { has-incoming.insert(e.end, true) }
  }

  // BFS Queue: Start with sources
  let queue = ()
  for id in node-ids {
    if not has-incoming.at(id) {
      layers.insert(id, 0)
      queue.push(id)
    }
  }

  // BFS: Assign minimum layer to each node
  while queue.len() > 0 {
    let u = queue.remove(0)
    let u-layer = layers.at(u)

    // Visit all outgoing neighbors
    for e in edges {
      if e.start == u {
        let v = e.end
        if v in layers and layers.at(v) == -1 {
          // First time visiting v
          layers.insert(v, u-layer + 1)
          queue.push(v)
        }
        // If already visited, we keep the earlier (smaller) layer
      }
    }
  }

  // Handle any remaining unvisited nodes (isolated or in cycles)
  for id in node-ids {
    if layers.at(id) == -1 {
      layers.insert(id, 0)
    }
  }

  // Map ID to Sequence Index (for tie-breaking in coordinate assignment)
  let seq-map = (:)
  for (i, id) in layout-sequence.enumerate() { seq-map.insert(id, i) }

  // 3. Coordinate Assignment
  // Refined: Sort nodes within layers to minimize crossings (Barycenter Heuristic - One Pass)

  // Group by Layer
  let layer-groups = (:)
  let max-layer = 0
  for (id, l) in layers {
    if l > max-layer { max-layer = l }
    let g = layer-groups.at(str(l), default: ())
    g.push(id)
    layer-groups.insert(str(l), g)
  }

  let final-positions = (:)
  let previous-positions = (:) // Map id -> index in its layer (0..N)

  // Iterate layers forward
  for l in range(max-layer + 1) {
    let group = layer-groups.at(str(l), default: ())

    // Sort group
    if l == 0 {
      // Layer 0: Sort by original definition order
      group = group.sorted(key: id => definition-order.at(id))
    } else {
      // Other Layers: Sort by average position of incoming neighbors
      // We need edges that go from L_prev -> L_curr.
      // Since we don't have easy access to "incoming" edges here efficiently without a map:
      // Let's assume most edges are previous layer.

      let barycenters = (:)
      for u in group {
        let sum-pos = 0.0
        let count = 0
        // Find incoming neighbors (inefficient scan, but graph is small)
        for e in edges {
          if e.end == u {
            let v = e.start
            // Check if v is in a processed layer (should be, if DAG)
            if v in previous-positions {
              sum-pos += previous-positions.at(v)
              count += 1
            }
          }
        }
        let avg = if count > 0 { sum-pos / count } else { seq-map.at(u) } // Fallback to seq order
        barycenters.insert(u, avg)
      }
      group = group.sorted(key: u => barycenters.at(u))
    }

    // Store positions (indices) for next layer
    for (i, u) in group.enumerate() {
      previous-positions.insert(u, i)
    }

    // Assign physical coords
    let row-width = (group.len() - 1) * node-sep
    let start-x = -row-width / 2.0 // Center the row

    for (i, id) in group.enumerate() {
      // Invert index so first-defined nodes appear at top (higher Y after X/Y swap for horizontal)
      let inverted-i = group.len() - 1 - i
      let x = start-x + inverted-i * node-sep
      let y = l * rank-sep
      final-positions.insert(id, (x, y))
    }
  }

  final-positions
}

// --- Reingold-Tilford Tree Layout Implementation ---

#let compute-tree-layout(nodes, edges, node-sep: 5.0, rank-sep: 3.0, extend-leaves: true) = {
  let node-ids = nodes.keys()
  if node-ids.len() == 0 { return (:) }

  // Build adjacency: parent -> children
  let children-map = (:)
  let parent-map = (:)
  for id in node-ids {
    children-map.insert(id, ())
    parent-map.insert(id, none)
  }

  for e in edges {
    let u = e.start
    let v = e.end
    if u in children-map and v in children-map {
      children-map.insert(u, children-map.at(u) + (v,))
      parent-map.insert(v, u)
    }
  }

  // Find root (first node with no parent)
  let root = none
  for id in node-ids {
    if parent-map.at(id) == none {
      root = id
      break
    }
  }
  if root == none { root = node-ids.at(0) } // Fallback

  // Store prelim-x, modifier, and depth for each node
  let prelim = (:)
  let modifier = (:)
  let depth = (:)
  for id in node-ids {
    prelim.insert(id, 0.0)
    modifier.insert(id, 0.0)
    depth.insert(id, 0)
  }

  // Compute depths via BFS from root
  let queue = ((root, 0),)
  while queue.len() > 0 {
    let (node, d) = queue.remove(0)
    depth.insert(node, d)
    for child in children-map.at(node, default: ()) {
      queue.push((child, d + 1))
    }
  }

  // Get leftmost sibling
  let get-left-sibling(node) = {
    let p = parent-map.at(node)
    if p == none { return none }
    let siblings = children-map.at(p)
    let idx = siblings.position(x => x == node)
    if idx > 0 { siblings.at(idx - 1) } else { none }
  }

  // First Walk (Post-order): Compute prelim and modifier
  // We'll use a stack-based post-order traversal
  let visited = (:)
  let stack = (root,)
  let post-order = ()

  while stack.len() > 0 {
    let node = stack.pop()
    if node in visited { continue }

    let kids = children-map.at(node, default: ())
    let all-kids-visited = true
    for kid in kids {
      if kid not in visited {
        all-kids-visited = false
        break
      }
    }

    if all-kids-visited {
      visited.insert(node, true)
      post-order.push(node)
    } else {
      stack.push(node) // Re-push to process after children
      for kid in kids {
        if kid not in visited { stack.push(kid) }
      }
    }
  }

  // Process nodes in post-order
  for node in post-order {
    let kids = children-map.at(node, default: ())
    let left-sib = get-left-sibling(node)

    if kids.len() == 0 {
      // Leaf node
      if left-sib != none {
        prelim.insert(node, prelim.at(left-sib) + node-sep)
      } else {
        prelim.insert(node, 0.0)
      }
    } else {
      // Internal node: center over children
      let first-child = kids.at(0)
      let last-child = kids.at(kids.len() - 1)
      let mid = (prelim.at(first-child) + prelim.at(last-child)) / 2.0

      if left-sib != none {
        prelim.insert(node, prelim.at(left-sib) + node-sep)
        modifier.insert(node, prelim.at(node) - mid)
      } else {
        prelim.insert(node, mid)
      }
    }

    // Contour separation: shift subtree if overlapping with left subtree
    // Simplified: just ensure separation from left sibling's rightmost descendant
    if left-sib != none and children-map.at(node, default: ()).len() > 0 {
      // Get right contour of left sibling's subtree
      // Get left contour of current node's subtree
      // For simplicity, we'll do a level-by-level comparison

      let left-contour = (:)
      let right-contour = (:)

      // BFS to get contours
      let q = ((left-sib, prelim.at(left-sib), 0),)
      while q.len() > 0 {
        let (n, x, lv) = q.remove(0)
        let current = right-contour.at(str(lv), default: -99999.0)
        if x > current { right-contour.insert(str(lv), x) }
        for c in children-map.at(n, default: ()) {
          q.push((c, x + modifier.at(n) + prelim.at(c), lv + 1))
        }
      }

      let q2 = ((node, prelim.at(node), 0),)
      while q2.len() > 0 {
        let (n, x, lv) = q2.remove(0)
        let current = left-contour.at(str(lv), default: 99999.0)
        if x < current { left-contour.insert(str(lv), x) }
        for c in children-map.at(n, default: ()) {
          q2.push((c, x + modifier.at(n) + prelim.at(c), lv + 1))
        }
      }

      // Find maximum overlap
      let max-shift = 0.0
      for (lv, right-x) in right-contour {
        if lv in left-contour {
          let left-x = left-contour.at(lv)
          let overlap = right-x + node-sep - left-x
          if overlap > max-shift { max-shift = overlap }
        }
      }

      if max-shift > 0 {
        prelim.insert(node, prelim.at(node) + max-shift)
        modifier.insert(node, modifier.at(node) + max-shift)
      }
    }
  }

  // Second Walk (Pre-order): Compute final positions
  // First, compute max depth so we can extend leaves
  let max-depth = 0
  for (id, d) in depth {
    if d > max-depth { max-depth = d }
  }

  let final-positions = (:)
  // Track parent position for each node (for scaling extended leaves)
  let node-parent-pos = (:)
  let pre-stack = ((root, 0.0, none, (0.0, 0.0)),) // (node, acc_mod, parent_id, parent_pos)

  while pre-stack.len() > 0 {
    let (node, acc-mod, parent-id, parent-pos) = pre-stack.pop()
    let x = prelim.at(node) + acc-mod
    let node-depth = depth.at(node)

    // Check if this is a leaf node
    let kids = children-map.at(node, default: ())
    let is-leaf = kids.len() == 0

    // For leaf nodes at shallower depths, extend to max depth with proportional scaling
    if extend-leaves and is-leaf and node-depth < max-depth and parent-id != none {
      // Calculate original delta from parent
      let orig-delta-x = x - parent-pos.at(0)
      let orig-delta-depth = node-depth - depth.at(parent-id)

      // Scale factor to reach max-depth
      let new-delta-depth = max-depth - depth.at(parent-id)
      let scale = if orig-delta-depth > 0 { new-delta-depth / orig-delta-depth } else { 1.0 }

      // Apply scaled position
      let final-x = parent-pos.at(0) + orig-delta-x * scale
      let final-y = max-depth * rank-sep
      final-positions.insert(node, (final-x, final-y))
    } else {
      let y = node-depth * rank-sep
      final-positions.insert(node, (x, y))
    }

    // Store this node's position for children
    let my-pos = final-positions.at(node)

    let new-acc = acc-mod + modifier.at(node)
    // Push in reverse order so leftmost is processed first
    for i in range(kids.len()) {
      let idx = kids.len() - 1 - i
      pre-stack.push((kids.at(idx), new-acc, node, my-pos))
    }
  }

  final-positions
}

#let compute-layout(
  nodes,
  edges,
  k: 3.0,
  iterations: 600,
  orientation: "horizontal",
  align-start: none,
  align-end: none,
  method: "spring", // "spring", "layered", or "tree"
) = {
  if method == "layered" {
    // For layered, "vertical" is natural (Y increases).
    // "horizontal" requires swapping X/Y.
    let positions = compute-layered-layout(nodes, edges)

    if orientation == "horizontal" {
      let rotated = (:)
      for (id, pos) in positions {
        rotated.insert(id, (pos.at(1), pos.at(0))) // Swap X/Y
      }
      return rotated
    }
    return positions
  }

  if method == "tree" {
    // Reingold-Tilford tree layout
    // "vertical" is natural (root at top, children below)
    // "horizontal" swaps X/Y to put root on left
    let positions = compute-tree-layout(nodes, edges)

    if orientation == "horizontal" {
      let rotated = (:)
      for (id, pos) in positions {
        rotated.insert(id, (pos.at(1), pos.at(0))) // Swap X/Y
      }
      return rotated
    }
    return positions
  }

  // --- Existing Spring Layout Logic ---
  let current-positions = (:)
  let node-ids = nodes.keys()
  let count = node-ids.len()

  // 1. Initialize on a grid
  for (i, id) in node-ids.enumerate() {
    let n = nodes.at(id)
    if n.pos != none {
      current-positions.insert(id, n.pos)
    } else {
      current-positions.insert(id, initial-pos(i, count))
    }
  }

  // 2. Main Spring Loop
  let temp = 5.0

  for iter in range(iterations) {
    let forces = (:)
    for id in node-ids { forces.insert(id, (0.0, 0.0)) }

    // A. Repulsion
    for (i, u) in node-ids.enumerate() {
      for (j, v) in node-ids.enumerate() {
        if i == j { continue }
        let pu = current-positions.at(u)
        let pv = current-positions.at(v)
        let delta = vec-sub(pu, pv)
        let dist-sq = vec-norm-sq(delta)
        let dist = calc.sqrt(dist-sq)
        if dist > 0.0001 {
          let force = (REPULSION-STRENGTH * k * k) / dist
          let fx = (delta.at(0) / dist) * force
          let fy = (delta.at(1) / dist) * force
          let f = forces.at(u)
          forces.insert(u, vec-add(f, (fx, fy)))
        }
      }
    }

    // B. Attraction
    for e in edges {
      let u = e.start
      let v = e.end
      if u in current-positions and v in current-positions {
        let pu = current-positions.at(u)
        let pv = current-positions.at(v)
        let delta = vec-sub(pv, pu)
        let dist = vec-norm(delta)
        if dist > 0.0001 {
          let k-eff = k
          let u-node = nodes.at(u, default: (:))
          let v-node = nodes.at(v, default: (:))
          if u-node.at("in-loop", default: false) or v-node.at("in-loop", default: false) {
            k-eff = k / 8.0
          }

          let force = (ATTRACTION-STRENGTH * dist * dist) / k-eff
          let fx = (delta.at(0) / dist) * force
          let fy = (delta.at(1) / dist) * force
          let fu = forces.at(u)
          forces.insert(u, vec-add(fu, (fx, fy)))
          let fv = forces.at(v)
          forces.insert(v, vec-sub(fv, (fx, fy)))
        }
      }
    }

    // C. Update
    let next-positions = (:)
    for id in node-ids {
      let n = nodes.at(id)
      if n.pos != none {
        next-positions.insert(id, n.pos)
      } else {
        let p = current-positions.at(id)
        let f = forces.at(id)
        let f-mag = vec-norm(f)
        if f-mag > 0.0001 {
          let step = calc.min(f-mag, temp)
          let dx = (f.at(0) / f-mag) * step
          let dy = (f.at(1) / f-mag) * step
          next-positions.insert(id, vec-add(p, (dx, dy)))
        } else {
          next-positions.insert(id, p)
        }
      }
    }
    current-positions = next-positions
    temp = temp * COOLING-FACTOR
  }

  // 3. Post-processing: Rotation and Alignment (Only for Spring)
  let final-positions = (:)
  let rotation-angle = 0.0

  if align-start != none and align-end != none and align-start in current-positions and align-end in current-positions {
    let p1 = current-positions.at(align-start)
    let p2 = current-positions.at(align-end)
    let delta = vec-sub(p2, p1)
    let current-angle = calc.atan2(delta.at(0), delta.at(1))
    let target-angle = if orientation == "vertical" { -90deg } else { 0deg }
    rotation-angle = target-angle - current-angle
  } else {
    // PCA Fallback
    let cx = 0.0
    let cy = 0.0
    let n = 0
    for id in node-ids {
      let p = current-positions.at(id)
      cx += p.at(0)
      cy += p.at(1)
      n += 1
    }
    if n > 0 {
      cx /= n
      cy /= n
    }

    let s-xx = 0.0
    let s-xy = 0.0
    let s-yy = 0.0
    for id in node-ids {
      let p = current-positions.at(id)
      let dx = p.at(0) - cx
      let dy = p.at(1) - cy
      s-xx += dx * dx
      s-xy += dx * dy
      s-yy += dy * dy
    }

    let pca-angle = 0.5 * calc.atan2(s-xx - s-yy, 2.0 * s-xy)
    rotation-angle = -pca-angle
  }

  let c = calc.cos(rotation-angle)
  let s = calc.sin(rotation-angle)

  let rotated-map = (:)
  for (id, p) in current-positions {
    let rx = p.at(0) * c - p.at(1) * s
    let ry = p.at(0) * s + p.at(1) * c
    rotated-map.insert(id, (rx, ry))
  }

  if align-start == none or align-end == none {
    let min-x = 10000.0
    let max-x = -10000.0
    let min-y = 10000.0
    let max-y = -10000.0
    for (id, p) in rotated-map {
      if p.at(0) < min-x { min-x = p.at(0) }
      if p.at(0) > max-x { max-x = p.at(0) }
      if p.at(1) < min-y { min-y = p.at(1) }
      if p.at(1) > max-y { max-y = p.at(1) }
    }
    let w = max-x - min-x
    let h = max-y - min-y
    let is-tall = h > w
    let want-tall = (orientation == "vertical")

    if is-tall != want-tall {
      let corrected = (:)
      for (id, p) in rotated-map { corrected.insert(id, (p.at(1), -p.at(0))) }
      rotated-map = corrected
    }
  }

  // Final Flip Check
  if align-start == none and align-end == none and node-ids.len() > 0 {
    let first-id = node-ids.at(0)
    if first-id in rotated-map {
      let p = rotated-map.at(first-id)
      let cx = 0.0
      let cy = 0.0
      let n = 0
      for (_, val) in rotated-map {
        cx += val.at(0)
        cy += val.at(1)
        n += 1
      }
      cx /= n
      cy /= n

      if orientation == "vertical" {
        if p.at(1) < cy {
          for (id, val) in rotated-map { rotated-map.insert(id, (val.at(0), -val.at(1))) }
        }
      } else {
        if p.at(0) > cx {
          for (id, val) in rotated-map { rotated-map.insert(id, (-val.at(0), val.at(1))) }
        }
      }
    }
  }

  rotated-map
}
