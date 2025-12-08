// Vector math helpers
#let vec_sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vec_add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vec_scale(v, s) = (v.at(0) * s, v.at(1) * s)
#let vec_norm_sq(v) = calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2)
#let vec_norm(v) = calc.sqrt(vec_norm_sq(v))

// Layout Constants
#let ITERATIONS = 600
#let K = 3.0 // Increased K to spread out more
#let REPULSION_STRENGTH = 2.0
#let ATTRACTION_STRENGTH = 1.0
#let COOLING_FACTOR = 0.99 // Much slower cooling to allow untangling
#let TOL = 0.01

// Initial layout on a grid to avoid worst-case circular crossings
#let initial_pos(index, total) = {
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

#let get_degrees(nodes, edges) = {
  let in_degree = (:)
  let out_degree = (:)
  let incoming = (:)
  let outgoing = (:)

  for id in nodes.keys() {
    in_degree.insert(id, 0)
    out_degree.insert(id, 0)
    incoming.insert(id, ())
    outgoing.insert(id, ())
  }

  for e in edges {
    let u = e.start
    let v = e.end
    if u in nodes and v in nodes {
      out_degree.insert(u, out_degree.at(u) + 1)
      in_degree.insert(v, in_degree.at(v) + 1)
      outgoing.insert(u, outgoing.at(u) + (v,))
      incoming.insert(v, incoming.at(v) + (u,))
    }
  }
  (in_degree, out_degree, incoming, outgoing)
}

#let compute_layered_layout(nodes, edges, node_sep: 4.0, rank_sep: 6.0) = {
  let node_ids = nodes.keys()

  // Preserve original definition order for later sorting
  let definition_order = (:)
  for (i, id) in node_ids.enumerate() { definition_order.insert(id, i) }

  // 1. Cycle Removal (Greedy Heuristic)
  // G is modified destructively in the algo description, so we simulate that with sets.
  let remaining_nodes = node_ids.map(x => x) // copy
  let Edges_Acyclic = ()
  let Edges_Original = edges

  // We need to re-compute degrees dynamically as we remove nodes
  // But strictly following the algo:
  // "remove INCOMING-EDGES(G, v) from E(G)" implies we only consider edges between remaining nodes.

  let left_seq = ()
  let right_seq = ()

  // Helper to re-calc degrees for remaining sub-graph
  let recalc_graph(current_nodes, all_edges) = {
    let in_d = (:)
    let out_d = (:)
    let sources = ()
    let sinks = ()

    for u in current_nodes {
      in_d.insert(u, 0)
      out_d.insert(u, 0)
    }

    for e in all_edges {
      if e.start in current_nodes and e.end in current_nodes {
        out_d.insert(e.start, out_d.at(e.start) + 1)
        in_d.insert(e.end, in_d.at(e.end) + 1)
      }
    }

    for u in current_nodes {
      if in_d.at(u) == 0 { sources.push(u) }
      if out_d.at(u) == 0 { sinks.push(u) }
    }
    (in_d, out_d, sources, sinks)
  }

  while remaining_nodes.len() > 0 {
    let (in_d, out_d, sources, sinks) = recalc_graph(remaining_nodes, Edges_Original)

    // Handle Sinks
    while sinks.len() > 0 {
      let v = sinks.pop()
      if v not in remaining_nodes { continue }
      // Prepend to right sequence so outer sinks are at the very end
      right_seq.insert(0, v)
      remaining_nodes = remaining_nodes.filter(n => n != v)

      let res = recalc_graph(remaining_nodes, Edges_Original)
      in_d = res.at(0)
      out_d = res.at(1)
      sources = res.at(2)
      sinks = res.at(3)
    }

    if remaining_nodes.len() == 0 { break }

    // Handle Sources
    while sources.len() > 0 {
      let v = sources.pop()
      if v not in remaining_nodes { continue }
      // Append to left sequence
      left_seq.push(v)
      remaining_nodes = remaining_nodes.filter(n => n != v)
      let res = recalc_graph(remaining_nodes, Edges_Original)
      in_d = res.at(0)
      out_d = res.at(1)
      sources = res.at(2)
      sinks = res.at(3)
    }

    if remaining_nodes.len() == 0 { break }

    // Handle remaining (Max diff)
    let max_diff = -99999
    let candidate = none
    for u in remaining_nodes {
      let diff = out_d.at(u) - in_d.at(u)
      if diff > max_diff {
        max_diff = diff
        candidate = u
      }
    }

    if candidate != none {
      left_seq.push(candidate) // Treat as source
      remaining_nodes = remaining_nodes.filter(n => n != candidate)
    }
  }

  let layout_sequence = left_seq + right_seq

  // 2. Layer Assignment using BFS (Minimum Distance from Sources)
  // This places nodes as early as possible, so "vertical" edges inside a box
  // don't push nodes to later layers unnecessarily.

  let layers = (:)
  for id in layout_sequence { layers.insert(id, -1) } // -1 = unvisited

  // Find sources (nodes with no incoming edges from within the node set)
  let has_incoming = (:)
  for id in node_ids { has_incoming.insert(id, false) }
  for e in edges {
    if e.end in has_incoming { has_incoming.insert(e.end, true) }
  }

  // BFS Queue: Start with sources
  let queue = ()
  for id in node_ids {
    if not has_incoming.at(id) {
      layers.insert(id, 0)
      queue.push(id)
    }
  }

  // BFS: Assign minimum layer to each node
  while queue.len() > 0 {
    let u = queue.remove(0)
    let u_layer = layers.at(u)

    // Visit all outgoing neighbors
    for e in edges {
      if e.start == u {
        let v = e.end
        if v in layers and layers.at(v) == -1 {
          // First time visiting v
          layers.insert(v, u_layer + 1)
          queue.push(v)
        }
        // If already visited, we keep the earlier (smaller) layer
      }
    }
  }

  // Handle any remaining unvisited nodes (isolated or in cycles)
  for id in node_ids {
    if layers.at(id) == -1 {
      layers.insert(id, 0)
    }
  }

  // Map ID to Sequence Index (for tie-breaking in coordinate assignment)
  let seq_map = (:)
  for (i, id) in layout_sequence.enumerate() { seq_map.insert(id, i) }

  // 3. Coordinate Assignment
  // Refined: Sort nodes within layers to minimize crossings (Barycenter Heuristic - One Pass)

  // Group by Layer
  let layer_groups = (:)
  let max_layer = 0
  for (id, l) in layers {
    if l > max_layer { max_layer = l }
    let g = layer_groups.at(str(l), default: ())
    g.push(id)
    layer_groups.insert(str(l), g)
  }

  let final_positions = (:)
  let previous_positions = (:) // Map id -> index in its layer (0..N)

  // Iterate layers forward
  for l in range(max_layer + 1) {
    let group = layer_groups.at(str(l), default: ())

    // Sort group
    if l == 0 {
      // Layer 0: Sort by original definition order
      group = group.sorted(key: id => definition_order.at(id))
    } else {
      // Other Layers: Sort by average position of incoming neighbors
      // We need edges that go from L_prev -> L_curr.
      // Since we don't have easy access to "incoming" edges here efficiently without a map:
      // Let's assume most edges are previous layer.

      let barycenters = (:)
      for u in group {
        let sum_pos = 0.0
        let count = 0
        // Find incoming neighbors (inefficient scan, but graph is small)
        for e in edges {
          if e.end == u {
            let v = e.start
            // Check if v is in a processed layer (should be, if DAG)
            if v in previous_positions {
              sum_pos += previous_positions.at(v)
              count += 1
            }
          }
        }
        let avg = if count > 0 { sum_pos / count } else { seq_map.at(u) } // Fallback to seq order
        barycenters.insert(u, avg)
      }
      group = group.sorted(key: u => barycenters.at(u))
    }

    // Store positions (indices) for next layer
    for (i, u) in group.enumerate() {
      previous_positions.insert(u, i)
    }

    // Assign physical coords
    let row_width = (group.len() - 1) * node_sep
    let start_x = -row_width / 2.0 // Center the row

    for (i, id) in group.enumerate() {
      // Invert index so first-defined nodes appear at top (higher Y after X/Y swap for horizontal)
      let inverted_i = group.len() - 1 - i
      let x = start_x + inverted_i * node_sep
      let y = l * rank_sep
      final_positions.insert(id, (x, y))
    }
  }

  final_positions
}

// --- Reingold-Tilford Tree Layout Implementation ---

#let compute_tree_layout(nodes, edges, node_sep: 5.0, rank_sep: 3.0, extend_leaves: true) = {
  let node_ids = nodes.keys()
  if node_ids.len() == 0 { return (:) }

  // Build adjacency: parent -> children
  let children_map = (:)
  let parent_map = (:)
  for id in node_ids {
    children_map.insert(id, ())
    parent_map.insert(id, none)
  }

  for e in edges {
    let u = e.start
    let v = e.end
    if u in children_map and v in children_map {
      children_map.insert(u, children_map.at(u) + (v,))
      parent_map.insert(v, u)
    }
  }

  // Find root (first node with no parent)
  let root = none
  for id in node_ids {
    if parent_map.at(id) == none {
      root = id
      break
    }
  }
  if root == none { root = node_ids.at(0) } // Fallback

  // Store prelim_x, modifier, and depth for each node
  let prelim = (:)
  let modifier = (:)
  let depth = (:)
  for id in node_ids {
    prelim.insert(id, 0.0)
    modifier.insert(id, 0.0)
    depth.insert(id, 0)
  }

  // Compute depths via BFS from root
  let queue = ((root, 0),)
  while queue.len() > 0 {
    let (node, d) = queue.remove(0)
    depth.insert(node, d)
    for child in children_map.at(node, default: ()) {
      queue.push((child, d + 1))
    }
  }

  // Get leftmost sibling
  let get_left_sibling(node) = {
    let p = parent_map.at(node)
    if p == none { return none }
    let siblings = children_map.at(p)
    let idx = siblings.position(x => x == node)
    if idx > 0 { siblings.at(idx - 1) } else { none }
  }

  // First Walk (Post-order): Compute prelim and modifier
  // We'll use a stack-based post-order traversal
  let visited = (:)
  let stack = (root,)
  let post_order = ()

  while stack.len() > 0 {
    let node = stack.pop()
    if node in visited { continue }

    let kids = children_map.at(node, default: ())
    let all_kids_visited = true
    for kid in kids {
      if kid not in visited {
        all_kids_visited = false
        break
      }
    }

    if all_kids_visited {
      visited.insert(node, true)
      post_order.push(node)
    } else {
      stack.push(node) // Re-push to process after children
      for kid in kids {
        if kid not in visited { stack.push(kid) }
      }
    }
  }

  // Process nodes in post-order
  for node in post_order {
    let kids = children_map.at(node, default: ())
    let left_sib = get_left_sibling(node)

    if kids.len() == 0 {
      // Leaf node
      if left_sib != none {
        prelim.insert(node, prelim.at(left_sib) + node_sep)
      } else {
        prelim.insert(node, 0.0)
      }
    } else {
      // Internal node: center over children
      let first_child = kids.at(0)
      let last_child = kids.at(kids.len() - 1)
      let mid = (prelim.at(first_child) + prelim.at(last_child)) / 2.0

      if left_sib != none {
        prelim.insert(node, prelim.at(left_sib) + node_sep)
        modifier.insert(node, prelim.at(node) - mid)
      } else {
        prelim.insert(node, mid)
      }
    }

    // Contour separation: shift subtree if overlapping with left subtree
    // Simplified: just ensure separation from left sibling's rightmost descendant
    if left_sib != none and children_map.at(node, default: ()).len() > 0 {
      // Get right contour of left sibling's subtree
      // Get left contour of current node's subtree
      // For simplicity, we'll do a level-by-level comparison

      let left_contour = (:)
      let right_contour = (:)

      // BFS to get contours
      let q = ((left_sib, prelim.at(left_sib), 0),)
      while q.len() > 0 {
        let (n, x, lv) = q.remove(0)
        let current = right_contour.at(str(lv), default: -99999.0)
        if x > current { right_contour.insert(str(lv), x) }
        for c in children_map.at(n, default: ()) {
          q.push((c, x + modifier.at(n) + prelim.at(c), lv + 1))
        }
      }

      let q2 = ((node, prelim.at(node), 0),)
      while q2.len() > 0 {
        let (n, x, lv) = q2.remove(0)
        let current = left_contour.at(str(lv), default: 99999.0)
        if x < current { left_contour.insert(str(lv), x) }
        for c in children_map.at(n, default: ()) {
          q2.push((c, x + modifier.at(n) + prelim.at(c), lv + 1))
        }
      }

      // Find maximum overlap
      let max_shift = 0.0
      for (lv, right_x) in right_contour {
        if lv in left_contour {
          let left_x = left_contour.at(lv)
          let overlap = right_x + node_sep - left_x
          if overlap > max_shift { max_shift = overlap }
        }
      }

      if max_shift > 0 {
        prelim.insert(node, prelim.at(node) + max_shift)
        modifier.insert(node, modifier.at(node) + max_shift)
      }
    }
  }

  // Second Walk (Pre-order): Compute final positions
  // First, compute max depth so we can extend leaves
  let max_depth = 0
  for (id, d) in depth {
    if d > max_depth { max_depth = d }
  }

  let final_positions = (:)
  // Track parent position for each node (for scaling extended leaves)
  let node_parent_pos = (:)
  let pre_stack = ((root, 0.0, none, (0.0, 0.0)),) // (node, acc_mod, parent_id, parent_pos)

  while pre_stack.len() > 0 {
    let (node, acc_mod, parent_id, parent_pos) = pre_stack.pop()
    let x = prelim.at(node) + acc_mod
    let node_depth = depth.at(node)

    // Check if this is a leaf node
    let kids = children_map.at(node, default: ())
    let is_leaf = kids.len() == 0

    // For leaf nodes at shallower depths, extend to max depth with proportional scaling
    if extend_leaves and is_leaf and node_depth < max_depth and parent_id != none {
      // Calculate original delta from parent
      let orig_delta_x = x - parent_pos.at(0)
      let orig_delta_depth = node_depth - depth.at(parent_id)

      // Scale factor to reach max_depth
      let new_delta_depth = max_depth - depth.at(parent_id)
      let scale = if orig_delta_depth > 0 { new_delta_depth / orig_delta_depth } else { 1.0 }

      // Apply scaled position
      let final_x = parent_pos.at(0) + orig_delta_x * scale
      let final_y = max_depth * rank_sep
      final_positions.insert(node, (final_x, final_y))
    } else {
      let y = node_depth * rank_sep
      final_positions.insert(node, (x, y))
    }

    // Store this node's position for children
    let my_pos = final_positions.at(node)

    let new_acc = acc_mod + modifier.at(node)
    // Push in reverse order so leftmost is processed first
    for i in range(kids.len()) {
      let idx = kids.len() - 1 - i
      pre_stack.push((kids.at(idx), new_acc, node, my_pos))
    }
  }

  final_positions
}

#let compute_layout(
  nodes,
  edges,
  k: 3.0,
  iterations: 600,
  orientation: "horizontal",
  align_start: none,
  align_end: none,
  method: "spring", // "spring", "layered", or "tree"
) = {
  if method == "layered" {
    // For layered, "vertical" is natural (Y increases).
    // "horizontal" requires swapping X/Y.
    let positions = compute_layered_layout(nodes, edges)

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
    let positions = compute_tree_layout(nodes, edges)

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
  let current_positions = (:)
  let node_ids = nodes.keys()
  let count = node_ids.len()

  // 1. Initialize on a grid
  for (i, id) in node_ids.enumerate() {
    let n = nodes.at(id)
    if n.pos != none {
      current_positions.insert(id, n.pos)
    } else {
      current_positions.insert(id, initial_pos(i, count))
    }
  }

  // 2. Main Spring Loop
  let temp = 5.0

  for iter in range(iterations) {
    let forces = (:)
    for id in node_ids { forces.insert(id, (0.0, 0.0)) }

    // A. Repulsion
    for (i, u) in node_ids.enumerate() {
      for (j, v) in node_ids.enumerate() {
        if i == j { continue }
        let pu = current_positions.at(u)
        let pv = current_positions.at(v)
        let delta = vec_sub(pu, pv)
        let dist_sq = vec_norm_sq(delta)
        let dist = calc.sqrt(dist_sq)
        if dist > 0.0001 {
          let force = (REPULSION_STRENGTH * k * k) / dist
          let fx = (delta.at(0) / dist) * force
          let fy = (delta.at(1) / dist) * force
          let f = forces.at(u)
          forces.insert(u, vec_add(f, (fx, fy)))
        }
      }
    }

    // B. Attraction
    for e in edges {
      let u = e.start
      let v = e.end
      if u in current_positions and v in current_positions {
        let pu = current_positions.at(u)
        let pv = current_positions.at(v)
        let delta = vec_sub(pv, pu)
        let dist = vec_norm(delta)
        if dist > 0.0001 {
          let k_eff = k
          let u_node = nodes.at(u, default: (:))
          let v_node = nodes.at(v, default: (:))
          if u_node.at("in_loop", default: false) or v_node.at("in_loop", default: false) {
            k_eff = k / 8.0
          }

          let force = (ATTRACTION_STRENGTH * dist * dist) / k_eff
          let fx = (delta.at(0) / dist) * force
          let fy = (delta.at(1) / dist) * force
          let fu = forces.at(u)
          forces.insert(u, vec_add(fu, (fx, fy)))
          let fv = forces.at(v)
          forces.insert(v, vec_sub(fv, (fx, fy)))
        }
      }
    }

    // C. Update
    let next_positions = (:)
    for id in node_ids {
      let n = nodes.at(id)
      if n.pos != none {
        next_positions.insert(id, n.pos)
      } else {
        let p = current_positions.at(id)
        let f = forces.at(id)
        let f_mag = vec_norm(f)
        if f_mag > 0.0001 {
          let step = calc.min(f_mag, temp)
          let dx = (f.at(0) / f_mag) * step
          let dy = (f.at(1) / f_mag) * step
          next_positions.insert(id, vec_add(p, (dx, dy)))
        } else {
          next_positions.insert(id, p)
        }
      }
    }
    current_positions = next_positions
    temp = temp * COOLING_FACTOR
  }

  // 3. Post-processing: Rotation and Alignment (Only for Spring)
  let final_positions = (:)
  let rotation_angle = 0.0

  if align_start != none and align_end != none and align_start in current_positions and align_end in current_positions {
    let p1 = current_positions.at(align_start)
    let p2 = current_positions.at(align_end)
    let delta = vec_sub(p2, p1)
    let current_angle = calc.atan2(delta.at(0), delta.at(1))
    let target_angle = if orientation == "vertical" { -90deg } else { 0deg }
    rotation_angle = target_angle - current_angle
  } else {
    // PCA Fallback
    let cx = 0.0
    let cy = 0.0
    let n = 0
    for id in node_ids {
      let p = current_positions.at(id)
      cx += p.at(0)
      cy += p.at(1)
      n += 1
    }
    if n > 0 {
      cx /= n
      cy /= n
    }

    let s_xx = 0.0
    let s_xy = 0.0
    let s_yy = 0.0
    for id in node_ids {
      let p = current_positions.at(id)
      let dx = p.at(0) - cx
      let dy = p.at(1) - cy
      s_xx += dx * dx
      s_xy += dx * dy
      s_yy += dy * dy
    }

    let pca_angle = 0.5 * calc.atan2(s_xx - s_yy, 2.0 * s_xy)
    rotation_angle = -pca_angle
  }

  let c = calc.cos(rotation_angle)
  let s = calc.sin(rotation_angle)

  let rotated_map = (:)
  for (id, p) in current_positions {
    let rx = p.at(0) * c - p.at(1) * s
    let ry = p.at(0) * s + p.at(1) * c
    rotated_map.insert(id, (rx, ry))
  }

  if align_start == none or align_end == none {
    let min_x = 10000.0
    let max_x = -10000.0
    let min_y = 10000.0
    let max_y = -10000.0
    for (id, p) in rotated_map {
      if p.at(0) < min_x { min_x = p.at(0) }
      if p.at(0) > max_x { max_x = p.at(0) }
      if p.at(1) < min_y { min_y = p.at(1) }
      if p.at(1) > max_y { max_y = p.at(1) }
    }
    let w = max_x - min_x
    let h = max_y - min_y
    let is_tall = h > w
    let want_tall = (orientation == "vertical")

    if is_tall != want_tall {
      let corrected = (:)
      for (id, p) in rotated_map { corrected.insert(id, (p.at(1), -p.at(0))) }
      rotated_map = corrected
    }
  }

  // Final Flip Check
  if align_start == none and align_end == none and node_ids.len() > 0 {
    let first_id = node_ids.at(0)
    if first_id in rotated_map {
      let p = rotated_map.at(first_id)
      let cx = 0.0
      let cy = 0.0
      let n = 0
      for (_, val) in rotated_map {
        cx += val.at(0)
        cy += val.at(1)
        n += 1
      }
      cx /= n
      cy /= n

      if orientation == "vertical" {
        if p.at(1) < cy {
          for (id, val) in rotated_map { rotated_map.insert(id, (val.at(0), -val.at(1))) }
        }
      } else {
        if p.at(0) > cx {
          for (id, val) in rotated_map { rotated_map.insert(id, (-val.at(0), val.at(1))) }
        }
      }
    }
  }

  rotated_map
}

