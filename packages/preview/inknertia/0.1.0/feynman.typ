#import "@preview/cetz:0.4.2"


// Vector helpers
#let vec-sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vec-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vec-scale(v, s) = (v.at(0) * s, v.at(1) * s)
#let vec-norm(v) = calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))
#let vec-rotate-90(v) = (-v.at(1), v.at(0))

// --- Internal Draw Helpers ---

// Helper to map straight-line (x, y) to path (Straight or Arc)
#let map-to-path(start, end, L, u, n, origin, x, y) = {
  if origin == none {
    // Straight line
    vec-add(start, vec-add(vec-scale(u, x), vec-scale(n, y)))
  } else {
    // Arc logic
    let diff-start = vec-sub(start, origin)

    // Angles
    let ang-start = calc.atan2(diff-start.at(0), diff-start.at(1))

    // Determine delta angle for arc of length L_path = da * R
    let R = vec-norm(diff-start)
    if R == 0 { return start }

    // da should be an angle
    let da = (x / R) * 1rad

    // Interpolate angle
    let angle = ang-start + da
    let r = R + y // Radial offset
    vec-add(origin, (r * calc.cos(angle), r * calc.sin(angle)))
  }
}

#let draw-propagator(
  start,
  end,
  type: "fermion",
  amplitude: 0.2, // Amplitude of the wave
  period: 0.5, // Length of one wave cycle
  color: black,
  stroke-width: 1pt,
  label: none,
  label-dist: 0.3,
  label-anchor: "auto",
  arrow-size: 0.6,
  momentum: none,
  label-fill: black,
  momentum-stroke: black,
  momentum-fill: black,
  ..args,
) = {
  import cetz.draw: *

  let origin = args.named().at("origin", default: none)

  // Calculate Basis
  let diff = vec-sub(end, start)
  let L-straight = vec-norm(diff)
  let u-straight = (1, 0)
  let n-straight = (0, 1) // Dummy defaults
  if L-straight > 0 {
    u-straight = vec-scale(diff, 1 / L-straight)
    n-straight = vec-rotate-90(u-straight)
  }

  // Calculate Path Parameters
  let L-path = L-straight
  if origin != none {
    let diff-start = vec-sub(start, origin)
    let diff-end = vec-sub(end, origin)
    let R = vec-norm(diff-start)
    let ang-start = calc.atan2(diff-start.at(0), diff-start.at(1))
    let ang-end = calc.atan2(diff-end.at(0), diff-end.at(1))

    let da = ang-end - ang-start
    // Normalize da to be positive (counter-clockwise)
    if da <= 0deg { da += 360deg }

    L-path = (da / 1rad) * R
  }

  let stroke-style = (paint: color, thickness: stroke-width)

  // Midpoint calculation
  let mid = map-to-path(start, end, L-path, u-straight, n-straight, origin, L-path / 2, 0)

  let draw-arrow-head(pos, direction, size, color) = {
    let tip = vec-add(pos, vec-scale(direction, size * 0.5))
    let back-center = vec-add(pos, vec-scale(direction, size * -0.5))
    let n = vec-rotate-90(direction)
    let half-width = size * 0.35
    let w1 = vec-add(back-center, vec-scale(n, half-width))
    let w2 = vec-add(back-center, vec-scale(n, -half-width))
    let recess = vec-add(back-center, vec-scale(direction, size * 0.15))
    line(tip, w1, recess, w2, close: true, fill: color, stroke: none)
  }

  // Tangent Helper
  let get-path-tangent(t-param) = {
    let delta = 0.001
    let p1 = map-to-path(start, end, L-path, u-straight, n-straight, origin, (t-param - delta) * L-path, 0)
    let p2 = map-to-path(start, end, L-path, u-straight, n-straight, origin, (t-param + delta) * L-path, 0)
    let tan = vec-sub(p2, p1)
    let norm = vec-norm(tan)
    if norm > 0 { vec-scale(tan, 1.0 / norm) } else { (1, 0) }
  }

  if type == "fermion" or type == "antifermion" or type == "majorana" or type == "anti-majorana" {
    let pts = ()
    let samples = 40
    for i in range(samples + 1) {
      let t = i / samples
      pts.push(map-to-path(start, end, L-path, u-straight, n-straight, origin, t * L-path, 0))
    }
    line(..pts, stroke: stroke-style)

    let loop-u = get-path-tangent(0.5)
    if type == "fermion" {
      draw-arrow-head(mid, loop-u, arrow-size, color)
    } else if type == "antifermion" {
      draw-arrow-head(mid, vec-scale(loop-u, -1), arrow-size, color)
    } else if type == "majorana" {
      let sep = arrow-size * 0.5
      let p1 = map-to-path(start, end, L-path, u-straight, n-straight, origin, 0.5 * L-path - sep, 0)
      let p2 = map-to-path(start, end, L-path, u-straight, n-straight, origin, 0.5 * L-path + sep, 0)
      draw-arrow-head(p1, loop-u, arrow-size, color)
      draw-arrow-head(p2, vec-scale(loop-u, -1), arrow-size, color)
    } else if type == "anti-majorana" {
      let sep = arrow-size * 0.5
      let p1 = map-to-path(start, end, L-path, u-straight, n-straight, origin, 0.5 * L-path - sep, 0)
      let p2 = map-to-path(start, end, L-path, u-straight, n-straight, origin, 0.5 * L-path + sep, 0)
      draw-arrow-head(p1, vec-scale(loop-u, -1), arrow-size, color)
      draw-arrow-head(p2, loop-u, arrow-size, color)
    }
  } else if type == "photon" or type == "boson" {
    let pts = ()
    let cycles = calc.round(L-path / period * 2) / 2
    if cycles < 0.5 { cycles = 0.5 }
    let samples = int(cycles * 20)
    if samples < 2 { samples = 2 }
    for i in range(samples + 1) {
      let t = i / samples
      let x-local = t * L-path
      let y-local = amplitude * calc.sin(t * cycles * 2 * calc.pi)
      pts.push(map-to-path(start, end, L-path, u-straight, n-straight, origin, x-local, y-local))
    }
    line(..pts, stroke: stroke-style)
  } else if type == "charged-boson" or type == "anti-charged-boson" {
    let pts = ()
    let cycles = calc.round(L-path / period * 2) / 2
    if cycles < 0.5 { cycles = 0.5 }
    let samples = int(cycles * 20)
    if samples < 2 { samples = 2 }
    for i in range(samples + 1) {
      let t = i / samples
      let x-local = t * L-path
      let y-local = amplitude * calc.sin(t * cycles * 2 * calc.pi)
      pts.push(map-to-path(start, end, L-path, u-straight, n-straight, origin, x-local, y-local))
    }
    line(..pts, stroke: stroke-style)

    let loop-u = get-path-tangent(0.5)
    if type == "charged-boson" {
      draw-arrow-head(mid, loop-u, arrow-size, color)
    } else {
      draw-arrow-head(mid, vec-scale(loop-u, -1), arrow-size, color)
    }
  } else if type == "scalar" or type == "charged-scalar" or type == "anti-charged-scalar" {
    let pts = ()
    let samples = 40
    for i in range(samples + 1) {
      let t = i / samples
      pts.push(map-to-path(start, end, L-path, u-straight, n-straight, origin, t * L-path, 0))
    }
    line(..pts, stroke: (paint: color, thickness: stroke-width, dash: "dashed"))

    if L-path > 0 and (type == "charged-scalar" or type == "anti-charged-scalar") {
      let loop-u = get-path-tangent(0.5)
      if type == "charged-scalar" {
        draw-arrow-head(mid, loop-u, arrow-size, color)
      } else {
        draw-arrow-head(mid, vec-scale(loop-u, -1), arrow-size, color)
      }
    }
  } else if type == "ghost" {
    let pts = ()
    let samples = 40
    for i in range(samples + 1) {
      let t = i / samples
      pts.push(map-to-path(start, end, L-path, u-straight, n-straight, origin, t * L-path, 0))
    }
    line(..pts, stroke: (paint: color, thickness: stroke-width, dash: "dotted"))
  } else if type == "gluon" {
    if L-path > 0 {
      let R-coil = amplitude * 0.8
      let coils = calc.max(1, calc.round(L-path / (period * 0.8)))
      let L-spine = L-path - 2 * R-coil
      let pts = ()
      let samples = int(coils * 40)
      if samples < 2 { samples = 2 }
      for i in range(samples + 1) {
        let t = i / samples
        let phase = (2 * coils - 1) * calc.pi * t - calc.pi
        let x-local = R-coil + t * L-spine + R-coil * calc.cos(phase)
        let y-local = R-coil * calc.sin(phase)
        pts.push(map-to-path(start, end, L-path, u-straight, n-straight, origin, x-local, y-local))
      }
      line(..pts, stroke: stroke-style)
    }
  } else {
    line(start, end, stroke: stroke-style)
  }

  // Draw Label if present
  if label != none {
    // Determine normal at mid for label
    let tan-u = get-path-tangent(0.5)

    // Default normal is 90 deg CCW (Left of curve)
    let normal-u = vec-rotate-90(tan-u)

    let anchor = label-anchor
    if anchor == "auto" {
      // Resolve auto anchor based on normal direction
      // We want the text to be placed in the direction of 'normal-u'.
      // So the text box anchor should be the opposite side.
      // e.g. Normal is Up (North). Text is Above. Anchor should be Bottom (South).

      let ang = calc.atan2(normal-u.at(0), normal-u.at(1))
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

    let dist = label-dist
    if type in ("photon", "boson", "charged-boson", "anti-charged-boson", "gluon") {
      dist += amplitude
    }

    content(mid, text(fill: label-fill, label), anchor: anchor, padding: dist)
  }

  // Momentum
  if momentum != none and L-path > 0 {
    let t1 = 0.2
    let t2 = 0.8
    let momentum-dist = if "momentum-dist" in args.named() { args.named().momentum-dist } else { 0.5 }
    let momentum-flip = args.named().at("momentum-flip", default: false)

    // Calculate y-offset for map-to-path
    let y-offset = 0.0
    if origin == none {
      // Straight: Left is +y, Right is -y
      if momentum-flip { y-offset = momentum-dist } else { y-offset = -momentum-dist }
    } else {
      // Arc: Left is -y (Inwards), Right is +y (Outwards)
      if momentum-flip { y-offset = -momentum-dist } else { y-offset = momentum-dist }
    }

    // Generate points for momentum path (Straight line or Arc)
    let pts = ()
    let samples = 20
    for i in range(samples + 1) {
      let t = t1 + (t2 - t1) * (i / samples)
      pts.push(map-to-path(start, end, L-path, u-straight, n-straight, origin, t * L-path, y-offset))
    }

    line(
      ..pts,
      stroke: (paint: momentum-stroke, thickness: 0.5pt),
      mark: (end: "stealth", size: 0.2, fill: momentum-fill),
    )

    // Label Position
    let t-mid = (t1 + t2) / 2
    let p-mid = map-to-path(start, end, L-path, u-straight, n-straight, origin, t-mid * L-path, y-offset)

    // Determine anchor based on offset direction relative to path normal
    // Normal to path at midpoint (Left)
    let tan-idx = int(samples / 2) // approx midpoint index
    let p-A = pts.at(tan-idx)
    let p-B = pts.at(tan-idx + 1)
    let tan-vec = vec-sub(p-B, p-A)
    let norm-vec = vec-rotate-90(tan-vec) // Left normal

    // Offset vector from main path to momentum path at midpoint
    let p-main-mid = map-to-path(start, end, L-path, u-straight, n-straight, origin, t-mid * L-path, 0)
    let offset-vec = vec-sub(p-mid, p-main-mid)

    // Project offset onto Left Normal
    let proj = offset-vec.at(0) * norm-vec.at(0) + offset-vec.at(1) * norm-vec.at(1)

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
    // So Target Direction is `norm-vec`.
    // Anchor should be Opposite(`norm-vec`).

    // If proj < 0 (Momentum is Right of Line). Text should be Right of Momentum.
    // Target Direction is `-norm-vec` (Right).
    // Anchor should be Opposite(`-norm-vec`) = `norm-vec`.

    let target-n = if proj > 0 { norm-vec } else { vec-scale(norm-vec, -1.0) }

    let ang = calc.atan2(target-n.at(0), target-n.at(1)) // Angle of Normal (text direction)
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

    content(p-mid, text(fill: momentum-fill, momentum), anchor: anchor, padding: 0.2)
  }
}

// --- Public API ---

#import "layout.typ": compute-layout

#let vertex(..args) = {
  // Parse unnamed args -> (id) or (id, pos)
  let pos-args = args.pos()
  let id = if pos-args.len() > 0 { pos-args.at(0) } else { "node" + str(datetime.today().to-astronomic-year()) } // fallback ID

  // Extract named args
  let label = args.named().at("label", default: none)
  let shape = args.named().at("shape", default: none) // "dot", "square", etc.
  let label-anchor = args.named().at("label-anchor", default: "auto")
  let label-padding = args.named().at("label-padding", default: 0.2)
  let fill = args.named().at("fill", default: black)
  let stroke = args.named().at("stroke", default: none)
  let label-fill = args.named().at("label-fill", default: black)
  let hatch-spacing = args.named().at("hatch-spacing", default: 5.0pt)
  let size = args.named().at("size", default: none)

  (
    kind: "node",
    id: id,
    pos: if pos-args.len() > 1 { pos-args.at(1) } else { none },
    label: label,
    shape: shape,
    label-anchor: label-anchor,
    label-padding: label-padding,
    fill: fill,
    stroke: stroke,
    label-fill: label-fill,
    hatch-spacing: hatch-spacing,
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
  label-anchor: "auto",
  momentum: none,
  color: black,
  label-fill: black,
  momentum-stroke: black,
  momentum-fill: black,
  ..args,
) = {
  (
    kind: "edge",
    start: start,
    end: end,
    type: type,
    label: label,
    label-anchor: label-anchor,
    momentum: momentum,
    color: color,
    label-fill: label-fill,
    momentum-stroke: momentum-stroke,
    momentum-fill: momentum-fill,
    extra: args.named(),
  )
}

// Helper to create hatching pattern (must be before cetz.draw import)
#let make-hatch(stroke-color, spacing: 2.5pt) = {
  tiling(size: (spacing, spacing))[
    #place(rect(width: 100%, height: 100%, fill: white, stroke: none))
    #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt + stroke-color))
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
    let needs-layout = false
    for (id, n) in nodes {
      if n.pos == none {
        needs-layout = true
        break
      }
    }

    // 1. Compute Layout
    if needs-layout {
      let align-start = none
      let align-end = none

      // Determine anchors based on orientation and params
      // Horizontal: Start=Left, End=Right
      // Vertical: Start=Bottom, End=Top
      // We check explicit params first.

      if orientation == "horizontal" {
        align-start = left
        align-end = right
      } else {
        align-start = bottom
        align-end = top
      }

      let layout-edges = edges.map(e => {
        if "layout-end" in e {
          e + (end: e.layout-end)
        } else {
          e
        }
      })

      let layout-positions = compute-layout(
        nodes,
        layout-edges,
        orientation: orientation,
        align-start: align-start,
        align-end: align-end,
        method: layout,
      )
      // Update nodes with computed positions
      for (id, pos) in layout-positions {
        if id in nodes {
          let n = nodes.at(id)
          n.insert("pos", pos)
          nodes.insert(id, n)
        }
      }
    }

    // Auto-anchor logic helpers
    let centroid = (0.0, 0.0)
    let node-count = 0
    for (id, n) in nodes {
      if n.pos != none {
        centroid = vec-add(centroid, n.pos)
        node-count = node-count + 1
      }
    }
    if node-count > 0 {
      centroid = vec-scale(centroid, 1.0 / node-count)
    }

    let resolve-anchor(pos, defined-anchor) = {
      if defined-anchor != "auto" { return defined-anchor }

      let diff = vec-sub(pos, centroid)
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
      let start-node = nodes.at(e.start, default: none)
      let end-node = nodes.at(e.end, default: none)

      if start-node != none and end-node != none {
        draw-propagator(
          start-node.pos,
          end-node.pos,
          type: e.type,
          label: e.label,
          label-anchor: e.label-anchor,
          momentum: e.momentum,
          color: e.color,
          label-fill: e.label-fill,
          momentum-stroke: e.momentum-stroke,
          momentum-fill: e.momentum-fill,
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
      let current-stroke = if n.stroke != none { n.stroke } else {
        if n.shape == "crossed-dot" { black } else { none }
      }

      // Draw node shape/label
      if n.shape == "dot" {
        let r = if n.size != none { n.size } else { 0.1 }
        circle(n.pos, radius: r, fill: n.fill, stroke: current-stroke)
      } else if n.shape == "crossed-dot" {
        let r = if n.size != none { n.size } else { 0.45 }
        circle(n.pos, radius: r, fill: white, stroke: current-stroke)
        let s = r * 0.707 // approx cos(45)
        line(vec-add(n.pos, (-s, -s)), vec-add(n.pos, (s, s)), stroke: current-stroke)
        line(vec-add(n.pos, (-s, s)), vec-add(n.pos, (s, -s)), stroke: current-stroke)
      } else if n.shape == "square" {
        let r = if n.size != none { n.size } else { 0.15 }
        rect(vec-add(n.pos, (-r, -r)), vec-add(n.pos, (r, r)), fill: n.fill, stroke: current-stroke)
      } else if n.shape == "blob" {
        let r = if n.size != none { n.size } else { 0.5 }
        let blob-fill = if n.fill == black { white } else { n.fill }
        let blob-stroke = if current-stroke == none { black } else { current-stroke }

        // Create hatching pattern using helper (avoids cetz.draw shadowing)
        let hatch-pattern = make-hatch(blob-stroke, spacing: n.hatch-spacing)

        // Draw blob with hatched fill
        circle(n.pos, radius: r, fill: hatch-pattern, stroke: blob-stroke)
      }

      if n.label != none {
        content(
          n.pos,
          text(fill: n.label-fill, n.label),
          anchor: resolve-anchor(n.pos, n.label-anchor),
          padding: n.label-padding,
        )
      }

      if debug {
        content(n.pos, text(size: 8pt, fill: blue)[#id], anchor: "south", padding: 0.2)
      }
    }
  })
}

// Re-export core propagator for manual use if needed
#let propagator = draw-propagator

#let cross(e1, e2) = {
  // e1 and e2 are edge objects (dictionaries)
  // We swap their end points for drawing, but keep original for layout
  let e1-draw = e1 + (end: e2.end, layout-end: e1.end)
  let e2-draw = e2 + (end: e1.end, layout-end: e2.end)
  (e1-draw, e2-draw)
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
  let angle-step = 2 * calc.pi / N

  // Extract and Position Nodes
  let nodes-with-pos = ()

  for i in range(N) {
    let item = inputs.at(i)
    let node = none

    if type(item) == array {
      node = item.at(0)
    } else {
      node = item
    }

    let angle = i * angle-step
    let x = center.at(0) + radius * calc.cos(angle)
    let y = center.at(1) + radius * calc.sin(angle)

    let new-node = node + (pos: (x, y), in-loop: true)
    nodes-with-pos.push(new-node)
    items.push(new-node)
  }

  // Create Edges
  for i in range(N) {
    let current = nodes-with-pos.at(i)
    let next-idx = calc.rem(i + 1, N)
    let next = nodes-with-pos.at(next-idx)

    let item = inputs.at(i)
    let props = (:)
    if type(item) == array and item.len() > 1 {
      let e = item.at(1)
      if type(e) == str { props.insert("type", e) } else if type(e) == dictionary { props = e }
    }

    // Inject origin for circular arc
    let e = edge(current.id, next.id, ..props)
    let e-final = e + (extra: e.extra + (origin: center))

    items.push(e-final)
  }

  items
}
