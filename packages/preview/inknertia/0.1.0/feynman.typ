#import "@preview/cetz:0.4.2"


// Vector helpers
#let vec_sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vec_add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vec_scale(v, s) = (v.at(0) * s, v.at(1) * s)
#let vec_norm(v) = calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))
#let vec_rotate_90(v) = (-v.at(1), v.at(0))

// --- Internal Draw Helpers ---

// Helper to map straight-line (x, y) to path (Straight or Arc)
#let map_to_path(start, end, L, u, n, origin, x, y) = {
  if origin == none {
    // Straight line
    vec_add(start, vec_add(vec_scale(u, x), vec_scale(n, y)))
  } else {
    // Arc logic
    let diff_start = vec_sub(start, origin)

    // Angles
    let ang_start = calc.atan2(diff_start.at(0), diff_start.at(1))

    // Determine delta angle for arc of length L_path = da * R
    let R = vec_norm(diff_start)
    if R == 0 { return start }

    // da should be an angle
    let da = (x / R) * 1rad

    // Interpolate angle
    let angle = ang_start + da
    let r = R + y // Radial offset
    vec_add(origin, (r * calc.cos(angle), r * calc.sin(angle)))
  }
}

#let draw_propagator(
  start,
  end,
  type: "fermion",
  amplitude: 0.2, // Amplitude of the wave
  period: 0.5, // Length of one wave cycle
  color: black,
  stroke_width: 1pt,
  label: none,
  label_dist: 0.3,
  label_anchor: "auto",
  arrow_size: 0.6,
  momentum: none,
  label_fill: black,
  momentum_stroke: black,
  momentum_fill: black,
  ..args,
) = {
  import cetz.draw: *

  let origin = args.named().at("origin", default: none)

  // Calculate Basis
  let diff = vec_sub(end, start)
  let L_straight = vec_norm(diff)
  let u_straight = (1, 0)
  let n_straight = (0, 1) // Dummy defaults
  if L_straight > 0 {
    u_straight = vec_scale(diff, 1 / L_straight)
    n_straight = vec_rotate_90(u_straight)
  }

  // Calculate Path Parameters
  let L_path = L_straight
  if origin != none {
    let diff_start = vec_sub(start, origin)
    let diff_end = vec_sub(end, origin)
    let R = vec_norm(diff_start)
    let ang_start = calc.atan2(diff_start.at(0), diff_start.at(1))
    let ang_end = calc.atan2(diff_end.at(0), diff_end.at(1))

    let da = ang_end - ang_start
    // Normalize da to be positive (counter-clockwise)
    if da <= 0deg { da += 360deg }

    L_path = (da / 1rad) * R
  }

  let stroke_style = (paint: color, thickness: stroke_width)

  // Midpoint calculation
  let mid = map_to_path(start, end, L_path, u_straight, n_straight, origin, L_path / 2, 0)

  let draw_arrow_head(pos, direction, size, color) = {
    let tip = vec_add(pos, vec_scale(direction, size * 0.5))
    let back_center = vec_add(pos, vec_scale(direction, size * -0.5))
    let n = vec_rotate_90(direction)
    let half_width = size * 0.35
    let w1 = vec_add(back_center, vec_scale(n, half_width))
    let w2 = vec_add(back_center, vec_scale(n, -half_width))
    let recess = vec_add(back_center, vec_scale(direction, size * 0.15))
    line(tip, w1, recess, w2, close: true, fill: color, stroke: none)
  }

  // Tangent Helper
  let get_path_tangent(t_param) = {
    let delta = 0.001
    let p1 = map_to_path(start, end, L_path, u_straight, n_straight, origin, (t_param - delta) * L_path, 0)
    let p2 = map_to_path(start, end, L_path, u_straight, n_straight, origin, (t_param + delta) * L_path, 0)
    let tan = vec_sub(p2, p1)
    let norm = vec_norm(tan)
    if norm > 0 { vec_scale(tan, 1.0 / norm) } else { (1, 0) }
  }

  if type == "fermion" or type == "antifermion" or type == "majorana" or type == "anti-majorana" {
    let pts = ()
    let samples = 40
    for i in range(samples + 1) {
      let t = i / samples
      pts.push(map_to_path(start, end, L_path, u_straight, n_straight, origin, t * L_path, 0))
    }
    line(..pts, stroke: stroke_style)

    let loop_u = get_path_tangent(0.5)
    if type == "fermion" {
      draw_arrow_head(mid, loop_u, arrow_size, color)
    } else if type == "antifermion" {
      draw_arrow_head(mid, vec_scale(loop_u, -1), arrow_size, color)
    } else if type == "majorana" {
      let sep = arrow_size * 0.5
      let p1 = map_to_path(start, end, L_path, u_straight, n_straight, origin, 0.5 * L_path - sep, 0)
      let p2 = map_to_path(start, end, L_path, u_straight, n_straight, origin, 0.5 * L_path + sep, 0)
      draw_arrow_head(p1, loop_u, arrow_size, color)
      draw_arrow_head(p2, vec_scale(loop_u, -1), arrow_size, color)
    } else if type == "anti-majorana" {
      let sep = arrow_size * 0.5
      let p1 = map_to_path(start, end, L_path, u_straight, n_straight, origin, 0.5 * L_path - sep, 0)
      let p2 = map_to_path(start, end, L_path, u_straight, n_straight, origin, 0.5 * L_path + sep, 0)
      draw_arrow_head(p1, vec_scale(loop_u, -1), arrow_size, color)
      draw_arrow_head(p2, loop_u, arrow_size, color)
    }
  } else if type == "photon" or type == "boson" {
    let pts = ()
    let cycles = calc.round(L_path / period * 2) / 2
    if cycles < 0.5 { cycles = 0.5 }
    let samples = int(cycles * 20)
    if samples < 2 { samples = 2 }
    for i in range(samples + 1) {
      let t = i / samples
      let x_local = t * L_path
      let y_local = amplitude * calc.sin(t * cycles * 2 * calc.pi)
      pts.push(map_to_path(start, end, L_path, u_straight, n_straight, origin, x_local, y_local))
    }
    line(..pts, stroke: stroke_style)
  } else if type == "charged-boson" or type == "anti-charged-boson" {
    let pts = ()
    let cycles = calc.round(L_path / period * 2) / 2
    if cycles < 0.5 { cycles = 0.5 }
    let samples = int(cycles * 20)
    if samples < 2 { samples = 2 }
    for i in range(samples + 1) {
      let t = i / samples
      let x_local = t * L_path
      let y_local = amplitude * calc.sin(t * cycles * 2 * calc.pi)
      pts.push(map_to_path(start, end, L_path, u_straight, n_straight, origin, x_local, y_local))
    }
    line(..pts, stroke: stroke_style)

    let loop_u = get_path_tangent(0.5)
    if type == "charged-boson" {
      draw_arrow_head(mid, loop_u, arrow_size, color)
    } else {
      draw_arrow_head(mid, vec_scale(loop_u, -1), arrow_size, color)
    }
  } else if type == "scalar" or type == "charged-scalar" or type == "anti-charged-scalar" {
    let pts = ()
    let samples = 40
    for i in range(samples + 1) {
      let t = i / samples
      pts.push(map_to_path(start, end, L_path, u_straight, n_straight, origin, t * L_path, 0))
    }
    line(..pts, stroke: (paint: color, thickness: stroke_width, dash: "dashed"))

    if L_path > 0 and (type == "charged-scalar" or type == "anti-charged-scalar") {
      let loop_u = get_path_tangent(0.5)
      if type == "charged-scalar" {
        draw_arrow_head(mid, loop_u, arrow_size, color)
      } else {
        draw_arrow_head(mid, vec_scale(loop_u, -1), arrow_size, color)
      }
    }
  } else if type == "ghost" {
    let pts = ()
    let samples = 40
    for i in range(samples + 1) {
      let t = i / samples
      pts.push(map_to_path(start, end, L_path, u_straight, n_straight, origin, t * L_path, 0))
    }
    line(..pts, stroke: (paint: color, thickness: stroke_width, dash: "dotted"))
  } else if type == "gluon" {
    if L_path > 0 {
      let R_coil = amplitude * 0.8
      let coils = calc.max(1, calc.round(L_path / (period * 0.8)))
      let L_spine = L_path - 2 * R_coil
      let pts = ()
      let samples = int(coils * 40)
      if samples < 2 { samples = 2 }
      for i in range(samples + 1) {
        let t = i / samples
        let phase = (2 * coils - 1) * calc.pi * t - calc.pi
        let x_local = R_coil + t * L_spine + R_coil * calc.cos(phase)
        let y_local = R_coil * calc.sin(phase)
        pts.push(map_to_path(start, end, L_path, u_straight, n_straight, origin, x_local, y_local))
      }
      line(..pts, stroke: stroke_style)
    }
  } else {
    line(start, end, stroke: stroke_style)
  }

  // Draw Label if present
  if label != none {
    // Determine normal at mid for label
    let tan_u = get_path_tangent(0.5)

    // Default normal is 90 deg CCW (Left of curve)
    let normal_u = vec_rotate_90(tan_u)

    let anchor = label_anchor
    if anchor == "auto" {
      // Resolve auto anchor based on normal direction
      // We want the text to be placed in the direction of 'normal_u'.
      // So the text box anchor should be the opposite side.
      // e.g. Normal is Up (North). Text is Above. Anchor should be Bottom (South).

      let ang = calc.atan2(normal_u.at(0), normal_u.at(1))
      // Normalize to positive [0, 360deg)
      // atan2(x,y) -> angle of vector (y, x)? No. calc.atan2(x, y) = atan(y/x).
      // Wait, check standard.
      // If x=1, y=0. atan(0/1) = 0.
      // If x=0, y=1. atan(1/0) = 90.
      // So calc.atan2(x, y) behaves like typical atan2(y, x).
      // ang is angle of normal.

      if ang < 0deg { ang += 360deg }

      // Map normal angle to text anchor (opposite)
      // Normal 0 (East) -> Anchor West
      // Normal 90 (North) -> Anchor South
      // Normal 180 (West) -> Anchor East
      // Normal 270 (South) -> Anchor North

      if ang >= 315deg or ang < 45deg { anchor = "west" } // Normal East
      else if ang >= 45deg and ang < 135deg { anchor = "south" } // Normal North
      else if ang >= 135deg and ang < 225deg { anchor = "east" } // Normal West
      else { anchor = "north" } // Normal South
    }

    let dist = label_dist
    if type in ("photon", "boson", "charged-boson", "anti-charged-boson", "gluon") {
      dist += amplitude
    }

    content(mid, text(fill: label_fill, label), anchor: anchor, padding: dist)
  }

  // Momentum
  if momentum != none and L_path > 0 {
    let t1 = 0.2
    let t2 = 0.8
    let momentum_dist = if "momentum_dist" in args.named() { args.named().momentum_dist } else { 0.5 }
    let momentum_flip = args.named().at("momentum_flip", default: false)

    // Calculate y_offset for map_to_path
    let y_offset = 0.0
    if origin == none {
      // Straight: Left is +y, Right is -y
      if momentum_flip { y_offset = momentum_dist } else { y_offset = -momentum_dist }
    } else {
      // Arc: Left is -y (Inwards), Right is +y (Outwards)
      if momentum_flip { y_offset = -momentum_dist } else { y_offset = momentum_dist }
    }

    // Generate points for momentum path (Straight line or Arc)
    let pts = ()
    let samples = 20
    for i in range(samples + 1) {
      let t = t1 + (t2 - t1) * (i / samples)
      pts.push(map_to_path(start, end, L_path, u_straight, n_straight, origin, t * L_path, y_offset))
    }

    line(
      ..pts,
      stroke: (paint: momentum_stroke, thickness: 0.5pt),
      mark: (end: "stealth", size: 0.2, fill: momentum_fill),
    )

    // Label Position
    let t_mid = (t1 + t2) / 2
    let p_mid = map_to_path(start, end, L_path, u_straight, n_straight, origin, t_mid * L_path, y_offset)

    // Determine anchor based on offset direction relative to path normal
    // Normal to path at midpoint (Left)
    let tan_idx = int(samples / 2) // approx midpoint index
    let p_A = pts.at(tan_idx)
    let p_B = pts.at(tan_idx + 1)
    let tan_vec = vec_sub(p_B, p_A)
    let norm_vec = vec_rotate_90(tan_vec) // Left normal

    // Offset vector from main path to momentum path at midpoint
    let p_main_mid = map_to_path(start, end, L_path, u_straight, n_straight, origin, t_mid * L_path, 0)
    let offset_vec = vec_sub(p_mid, p_main_mid)

    // Project offset onto Left Normal
    let proj = offset_vec.at(0) * norm_vec.at(0) + offset_vec.at(1) * norm_vec.at(1)

    // If proj > 0 (Left), Text should be "More Left" -> Anchor East/South-East?
    // Or just use South/North logic for simple horizontal lines?
    // Let's use the auto-anchor logic similarly to labels.

    // If we are on the Left (proj > 0), we want text text to be Left of Momentum Line.
    // So if Normal is Left, we want Anchor "East" (Right of text is at point).
    // If we are on the Right (proj < 0), we want text Right of Momentum Line.
    // Left Normal points away. Right Normal points to text.
    // So Anchor "West".

    // Refined Logic using angle:
    // Label Normal direction:
    // If proj > 0 (Momentum is Left of Line). Text should be Left of Momentum.
    // So Target Direction is `norm_vec`.
    // Anchor should be Opposite(`norm_vec`).

    // If proj < 0 (Momentum is Right of Line). Text should be Right of Momentum.
    // Target Direction is `-norm_vec` (Right).
    // Anchor should be Opposite(`-norm_vec`) = `norm_vec`.

    let target_n = if proj > 0 { norm_vec } else { vec_scale(norm_vec, -1.0) }

    let ang = calc.atan2(target_n.at(0), target_n.at(1)) // Angle of Normal (text direction)
    // We want anchor to be opposite to text direction.
    // So we add 180 to ang to get anchor direction.
    // Or use the inverse logic directly.

    // Let's reuse the angle mapping from label
    // If Text Direction is North (90), Anchor is South.

    if ang < 0deg { ang += 360deg }

    let anchor = "north"
    if ang >= 315deg or ang < 45deg { anchor = "west" } // Text East -> Anchor West
    else if ang >= 45deg and ang < 135deg { anchor = "south" } // Text North -> Anchor South
    else if ang >= 135deg and ang < 225deg { anchor = "east" } // Text West -> Anchor East
    else { anchor = "north" } // Text South -> Anchor North

    content(p_mid, text(fill: momentum_fill, momentum), anchor: anchor, padding: 0.2)
  }
}

// --- Public API ---

#import "layout.typ": compute_layout

#let vertex(..args) = {
  // Parse unnamed args -> (id) or (id, pos)
  let pos_args = args.pos()
  let id = if pos_args.len() > 0 { pos_args.at(0) } else { "node" + str(datetime.today().to-astronomic-year()) } // fallback ID

  // Extract named args
  let label = args.named().at("label", default: none)
  let shape = args.named().at("shape", default: none) // "dot", "square", etc.
  let label_anchor = args.named().at("label_anchor", default: "auto")
  let label_padding = args.named().at("label_padding", default: 0.2)
  let fill = args.named().at("fill", default: black)
  let stroke = args.named().at("stroke", default: none)
  let label_fill = args.named().at("label_fill", default: black)
  let hatch_spacing = args.named().at("hatch_spacing", default: 5.0pt)
  let size = args.named().at("size", default: none)

  (
    kind: "node",
    id: id,
    pos: if pos_args.len() > 1 { pos_args.at(1) } else { none },
    label: label,
    shape: shape,
    label_anchor: label_anchor,
    label_padding: label_padding,
    fill: fill,
    stroke: stroke,
    label_fill: label_fill,
    hatch_spacing: hatch_spacing,
    size: size,
    extra: args.named(),
  )
}

// Alias for backward compatibility (optional, but good practice)
#let node = vertex


#let edge(
  start,
  end,
  type: "fermion",
  label: none,
  label_anchor: "auto",
  momentum: none,
  color: black,
  label_fill: black,
  momentum_stroke: black,
  momentum_fill: black,
  ..args,
) = {
  (
    kind: "edge",
    start: start,
    end: end,
    type: type,
    label: label,
    label_anchor: label_anchor,
    momentum: momentum,
    color: color,
    label_fill: label_fill,
    momentum_stroke: momentum_stroke,
    momentum_fill: momentum_fill,
    extra: args.named(),
  )
}

// Helper to create hatching pattern (must be before cetz.draw import)
#let make_hatch(stroke_color, spacing: 2.5pt) = {
  tiling(size: (spacing, spacing))[
    #place(rect(width: 100%, height: 100%, fill: white, stroke: none))
    #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt + stroke_color))
  ]
}

#let feynman(
  items,
  debug: false,
  length: 0.5cm,
  orientation: "horizontal",
  left: none,
  right: none,
  top: none,
  bottom: none,
  layout: "spring",
  ..args,
) = {
  import cetz.draw: *

  cetz.canvas(length: length, ..args, {
    let nodes = (:)
    let edges = ()

    // Pass 1: Collect nodes and separate edges
    // Pass 1: Collect nodes and separate edges
    for item in items.flatten() {
      if type(item) == dictionary and "kind" in item {
        if item.kind == "node" {
          nodes.insert(item.id, item)
        } else if item.kind == "edge" {
          edges.push(item)
        }
      }
    }

    // Pass 1.5: Run Layout if any node has no position
    let needs_layout = false
    for (id, n) in nodes {
      if n.pos == none {
        needs_layout = true
        break
      }
    }

    // 1. Compute Layout
    if needs_layout {
      let align_start = none
      let align_end = none

      // Determine anchors based on orientation and params
      // Horizontal: Start=Left, End=Right
      // Vertical: Start=Bottom, End=Top
      // We check explicit params first.

      if orientation == "horizontal" {
        align_start = left
        align_end = right
      } else {
        align_start = bottom
        align_end = top
      }

      let layout_edges = edges.map(e => {
        if "layout_end" in e {
          e + (end: e.layout_end)
        } else {
          e
        }
      })

      let layout_positions = compute_layout(
        nodes,
        layout_edges,
        orientation: orientation,
        align_start: align_start,
        align_end: align_end,
        method: layout,
      )
      // Update nodes with computed positions
      for (id, pos) in layout_positions {
        if id in nodes {
          let n = nodes.at(id)
          n.insert("pos", pos)
          nodes.insert(id, n)
        }
      }
    }

    // Auto-anchor logic helpers
    let centroid = (0.0, 0.0)
    let node_count = 0
    for (id, n) in nodes {
      if n.pos != none {
        centroid = vec_add(centroid, n.pos)
        node_count = node_count + 1
      }
    }
    if node_count > 0 {
      centroid = vec_scale(centroid, 1.0 / node_count)
    }

    let resolve_anchor(pos, defined_anchor) = {
      if defined_anchor != "auto" { return defined_anchor }

      let diff = vec_sub(pos, centroid)
      let angle = calc.atan2(diff.at(0), diff.at(1)) // Typst atan2(x, y) = atan(y/x). Wait, standard is atan2(y, x).
      // Typst docs: atan2(x, y) returns angle of point (x, y). Correct.
      // So angle is in (-pi, pi].

      let deg = angle / 1deg

      // Map angle to "opposite" anchor to push text away
      // 0 deg (East) -> anchor "west"
      // 90 deg (North) -> anchor "south"
      // 180 deg (West) -> anchor "east"
      // -90 deg (South) -> anchor "north"

      // Normalize to [0, 360)
      if deg < 0.0 { deg = deg + 360.0 }

      if deg >= 315.0 or deg < 45.0 { return "west" } // Right -> Anchor West
      if deg >= 45.0 and deg < 135.0 { return "south" } // Top -> Anchor South
      if deg >= 135.0 and deg < 225.0 { return "east" } // Left -> Anchor East
      if deg >= 225.0 and deg < 315.0 { return "north" } // Bottom -> Anchor North

      return "center" // fallback
    }

    // Pass 2: Draw Edges
    for e in edges {
      let start_node = nodes.at(e.start, default: none)
      let end_node = nodes.at(e.end, default: none)

      if start_node != none and end_node != none {
        draw_propagator(
          start_node.pos,
          end_node.pos,
          type: e.type,
          label: e.label,
          label_anchor: e.label_anchor,
          momentum: e.momentum,
          color: e.color,
          label_fill: e.label_fill,
          momentum_stroke: e.momentum_stroke,
          momentum_fill: e.momentum_fill,
          ..e.extra,
        )
      } else {
        if debug {
          content((0, 0), text(fill: red)[Missing Node: #e.start -> #e.end])
        }
      }
    }

    // Pass 3: Draw Nodes
    for (id, n) in nodes {
      // Determine stroke color (default to black for crossed-dot if none, else n.stroke)
      let current_stroke = if n.stroke != none { n.stroke } else {
        if n.shape == "crossed-dot" { black } else { none }
      }

      // Draw node shape/label
      if n.shape == "dot" {
        let r = if n.size != none { n.size } else { 0.1 }
        circle(n.pos, radius: r, fill: n.fill, stroke: current_stroke)
      } else if n.shape == "crossed-dot" {
        let r = if n.size != none { n.size } else { 0.45 }
        circle(n.pos, radius: r, fill: white, stroke: current_stroke)
        let s = r * 0.707 // approx cos(45)
        line(vec_add(n.pos, (-s, -s)), vec_add(n.pos, (s, s)), stroke: current_stroke)
        line(vec_add(n.pos, (-s, s)), vec_add(n.pos, (s, -s)), stroke: current_stroke)
      } else if n.shape == "square" {
        let r = if n.size != none { n.size } else { 0.15 }
        rect(vec_add(n.pos, (-r, -r)), vec_add(n.pos, (r, r)), fill: n.fill, stroke: current_stroke)
      } else if n.shape == "blob" {
        let r = if n.size != none { n.size } else { 0.5 }
        let blob_fill = if n.fill == black { white } else { n.fill }
        let blob_stroke = if current_stroke == none { black } else { current_stroke }

        // Create hatching pattern using helper (avoids cetz.draw shadowing)
        let hatch_pattern = make_hatch(blob_stroke, spacing: n.hatch_spacing)

        // Draw blob with hatched fill
        circle(n.pos, radius: r, fill: hatch_pattern, stroke: blob_stroke)
      }

      if n.label != none {
        content(
          n.pos,
          text(fill: n.label_fill, n.label),
          anchor: resolve_anchor(n.pos, n.label_anchor),
          padding: n.label_padding,
        )
      }

      if debug {
        content(n.pos, text(size: 8pt, fill: blue)[#id], anchor: "south", padding: 0.2)
      }
    }
  })
}

// Re-export core propagator for manual use if needed
#let propagator = draw_propagator

#let cross(e1, e2) = {
  // e1 and e2 are edge objects (dictionaries)
  // We swap their end points for drawing, but keep original for layout
  let e1_draw = e1 + (end: e2.end, layout_end: e1.end)
  let e2_draw = e2 + (end: e1.end, layout_end: e2.end)
  (e1_draw, e2_draw)
}

#let loop(
  radius: 2.0,
  center: (0, 0),
  ..args,
) = {
  let items = ()
  let inputs = args.pos()

  if inputs.len() == 0 { return items }

  let N = inputs.len()
  let angle_step = 2 * calc.pi / N

  // Extract and Position Nodes
  let nodes_with_pos = ()

  for i in range(N) {
    let item = inputs.at(i)
    let node = none

    if type(item) == array {
      node = item.at(0)
    } else {
      node = item
    }

    let angle = i * angle_step
    let x = center.at(0) + radius * calc.cos(angle)
    let y = center.at(1) + radius * calc.sin(angle)

    let new_node = node + (pos: (x, y), in_loop: true)
    nodes_with_pos.push(new_node)
    items.push(new_node)
  }

  // Create Edges
  for i in range(N) {
    let current = nodes_with_pos.at(i)
    let next_idx = calc.rem(i + 1, N)
    let next = nodes_with_pos.at(next_idx)

    let item = inputs.at(i)
    let props = (:)
    if type(item) == array and item.len() > 1 {
      let e = item.at(1)
      if type(e) == str { props.insert("type", e) } else if type(e) == dictionary { props = e }
    }

    // Inject origin for circular arc
    let e = edge(current.id, next.id, ..props)
    let e_final = e + (extra: e.extra + (origin: center))

    items.push(e_final)
  }

  items
}
