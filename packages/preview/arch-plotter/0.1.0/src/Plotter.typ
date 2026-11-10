#import "@preview/cetz:0.4.2"
#import cetz.draw: *
#import cetz.vector


// A dedicated canvas for land surveying and property boundaries
#let plot-canvas(scale: 0.5cm, body) = {
  cetz.canvas(length: scale, body)
}

// ==========================================
// 0. GLOBAL SETTINGS
// ==========================================
#let global-dim-size = 11pt
#let global-mark-size = 10pt
#let global-angle-size = 12pt
#let global-area-size = 12pt
#let global-name-size = 16pt

#let drawing-ops = ("move", "home", "drop-y", "drop-x", "drop-perp",  "go-x", "go-y", "go-to", "go-frac", "move-along", "drop-a", "drop-parallel", "int-move", "a-to", "go-to-mark", "go-x-mark", "go-y-mark")

// ==========================================
// 1. UNIT & STRING FORMATTING
// ==========================================

#let to-arch-str(value) = {
  let total-inches = calc.round(value * 12 * 4) / 4
  let feet = calc.floor(total-inches / 12)
  let rest-inches = calc.rem(total-inches, 12)
  let inch-whole = calc.floor(rest-inches)
  let quarters = (rest-inches - inch-whole) * 4 
  let fraction = if quarters == 1 { [ $1/4$] } else if quarters == 2 { [ $1/2$] } else if quarters == 3 { [ $3/4$] } else { [] }
  str(feet) + "'" + str(inch-whole) + fraction + "\""
}

// ==========================================
// 2. PLOT ENGINE (LINES & JUMPS)
// ==========================================
// 

// Switches the active drawing layer inside a trace
#let Layer(name) = (type: "layer", name: name)

// Drop at Y direction till the intersecting point
#let DropY(p1, p2) = (type: "drop-y", p1: p1, p2: p2)
// Drop at X direction till the intersecting point
#let DropX(p1, p2) = (type: "drop-x", p1: p1, p2: p2)

// Go at X position with given length
#let GoX(x) = (type: "go-x", x: x)

// Go at Y position with given length
#let GoY(y) = (type: "go-y", y: y)

// Goto to the given point
#let GoTo(pt) = (type: "go-to", pt: pt)

// Draw a line directly to a previously marked anchor inside the same trace
#let GoToMark(name) = (type: "go-to-mark", name: name)

// Go to the X coordinate of a previously marked anchor (with an optional offset)
#let GoXMark(name, offset: 0) = (type: "go-x-mark", name: name, offset: offset)

// Go to the Y coordinate of a previously marked anchor (with an optional offset)
#let GoYMark(name, offset: 0) = (type: "go-y-mark", name: name, offset: offset)


// Right turn till given length
#let R(len) = (type: "move", d: (len, 0))

// Left turn till given length
#let L(len) = (type: "move", d: (-len, 0))

// Goint Up till given length
#let U(len) = (type: "move", d: (0, len))

// Goint Down till given length
#let D(len) = (type: "move", d: (0, -len))

// Goint at given angle till given length
#let A(angle, len) = (type: "move", d: (calc.cos(angle * 1deg) * len, calc.sin(angle * 1deg) * len))


// ==========================================
// NEW: INTERSECTING MOVE COMMANDS
// ==========================================

// Intersect Up: Move up by 'len' but stop if hitting line p1-p2
#let IU(len, p1: none, p2: none) = (type: "int-move", d: (0, len), p1: p1, p2: p2, dir: "y")
// Intersect Down
#let ID(len, p1: none, p2: none) = (type: "int-move", d: (0, -len), p1: p1, p2: p2, dir: "y")
// Intersect Left
#let IL(len, p1: none, p2: none) = (type: "int-move", d: (-len, 0), p1: p1, p2: p2, dir: "x")
// Intersect Right
#let IR(len, p1: none, p2: none) = (type: "int-move", d: (len, 0), p1: p1, p2: p2, dir: "x")

// Move at an angle, but stop if hitting segment p1-p2
#let IA(angle, len, p1: none, p2: none) = (
  type: "int-move", 
  d: (calc.cos(angle * 1deg) * len, calc.sin(angle * 1deg) * len), 
  p1: p1, p2: p2
)

// Move toward a specific point, but stop if hitting segment p1-p2
#let ITo(pt, p1: none, p2: none) = (
  type: "int-move", 
  target-pt: pt, // We'll calculate the delta inside trace
  p1: p1, p2: p2
)

// Move at a specific angle until it aligns with the target point
#let ATo(angle, pt) = (type: "a-to", angle: angle, pt: pt)


// --- Advanced Surveying Moves ---

// Drop exactly perpendicular to a slanted line
#let DropPerp(p1, p2) = (type: "drop-perp", p1: p1, p2: p2)

// Go to a fractional point between two anchors (0.5 is exactly the middle)
#let GoFrac(p1, p2, frac) = (type: "go-frac", p1: p1, p2: p2, f: frac)

// Go to a mid point between two anchors
#let GoMid(p1, p2) = (type: "go-frac", p1: p1, p2: p2, f: 0.5)

// Move a specific distance perfectly parallel to an existing slanted line
#let MoveAlong(p1, p2, dist) = (type: "move-along", p1: p1, p2: p2, dist: dist)

// Shoot a line at a specific angle until it hits a target line (p1 to p2)
#let DropA(angle, p1, p2) = (type: "drop-a", angle: angle, p1: p1, p2: p2)

// Shoot a line parallel to a reference wall (ref1 to ref2) until it hits a target line (t1 to t2)
#let DropParallel(ref1, ref2, t1, t2) = (type: "drop-parallel", ref1: ref1, ref2: ref2, t1: t1, t2: t2)

//Jumping Commands

//Jumping right
#let JR(len) = (type: "jump", d: (len, 0))

//Jumping left at given length
#let JL(len) = (type: "jump", d: (-len, 0))

//Jumping up at given length
#let JU(len) = (type: "jump", d: (0, len))

//Jumping down at given length
#let JD(len) = (type: "jump", d: (0, -len))

//Jump Home command (Moves to start without drawing a line)
#let JumpHome() = (type: "jump-home")

// Move to a previously marked anchor without drawing a line
#let JumpToMark(name) = (type: "jump-to-mark", name: name)

//Jump at given angle till the length
#let JA(angle, len) = (type: "jump", d: (calc.cos(angle * 1deg) * len, calc.sin(angle * 1deg) * len))

//Marks an anchor
#let Mark(name) = (type: "mark", name: name)

//Home command which will add to the list, Use JumpHome if you dont want to add to the array list
#let Home() = (type: "home")

// --- THE SMART TRACE FUNCTION THAT MANAGES CO-ORDINATES SMARTLY ---
#let trace-plot(start: (0,0), ops) = {
  let current = start
  let pts = (start,)
  let anchors = (start: start)
  let segments = ((start,),) // NEW: Keeps track of separate lines

  // --- NEW: LAYER SYSTEM SETUP ---
  // We initialize the default "Boundary" layer
  let current-layer = "Boundary"
  let layers = (
    "Boundary": (pts: (start,), segments: ((start,),))
  )
  
  for op in ops {
    // 1. Handle Marks (Save position and skip delta calculations)
    if op.type == "mark" {
      anchors.insert(op.name, current)
      continue
    }

    // 2. NEW: Handle Layer Switches
    if op.type == "layer" {
      current-layer = op.name
      // If the layer doesn't exist yet, create it starting at the current cursor!
      if current-layer not in layers {
        layers.insert(current-layer, (pts: (current,), segments: ((current,),)))
      }
      continue
    }
    
    // 2. Calculate the movement (delta) based on the operation type
    let delta = if op.type == "home" or op.type == "jump-home" {
      // Return exactly to the 'start' coordinate
      (start.at(0) - current.at(0), start.at(1) - current.at(1))
      
    }else if op.type == "go-to-mark" or op.type == "jump-to-mark" {
      // Look up the coordinate in the engine's live memory!
      if op.name in anchors {
        let pt = anchors.at(op.name)
        (pt.at(0) - current.at(0), pt.at(1) - current.at(1))
      } else {
        (0, 0) // Failsafe if you type a mark name that doesn't exist yet
      }} else if op.type == "drop-y" {
      // Drop vertically to hit a slanted line
      let x = current.at(0)
      let (x1, y1) = op.p1
      let (x2, y2) = op.p2
      // Linear equation: y = y1 + m*(x - x1)
      let target-y = if x1 == x2 { y1 } else { y1 + (y2 - y1) * (x - x1) / (x2 - x1) }
      (0, target-y - current.at(1))
      
    } else if op.type == "drop-x" {
      // Move horizontally to hit a slanted line
      let y = current.at(1)
      let (x1, y1) = op.p1
      let (x2, y2) = op.p2
      // Linear equation rearranged for X: x = x1 + (x2-x1)*(y-y1)/(y2-y1)
      let target-x = if y1 == y2 { x1 } else { x1 + (x2 - x1) * (y - y1) / (y2 - y1) }
      (target-x - current.at(0), 0)
      
    } else if op.type == "go-x" {
      // Snap to an exact X coordinate
      (op.x - current.at(0), 0)
      
    } else if op.type == "go-y" {
      // Snap to an exact Y coordinate
      (0, op.y - current.at(1))
      
    } else if op.type == "go-to" {
      // Snap directly to a specific point
      (op.pt.at(0) - current.at(0), op.pt.at(1) - current.at(1))
      
    }else if op.type == "go-x-mark" {
      // Look up the mark in the engine's live memory!
      if op.name in anchors {
        let target-x = anchors.at(op.name).at(0) + op.offset
        (target-x - current.at(0), 0)
      } else { (0, 0) } // Failsafe if the mark doesn't exist
      
    } else if op.type == "go-y-mark" {
      if op.name in anchors {
        let target-y = anchors.at(op.name).at(1) + op.offset
        (0, target-y - current.at(1))
      } else { (0, 0) }} else if op.type == "drop-perp" {
      // Vector math to find the closest 90-degree intersection on a slanted line
      let v-line = vector.sub(op.p2, op.p1)
      let v-pt = vector.sub(current, op.p1)
      let line-len-sq = (v-line.at(0) * v-line.at(0)) + (v-line.at(1) * v-line.at(1))
      
      // Prevent division by zero if p1 and p2 are the exact same point
      let t = if line-len-sq == 0 { 0 } else { (v-pt.at(0) * v-line.at(0) + v-pt.at(1) * v-line.at(1)) / line-len-sq }
      let target-x = op.p1.at(0) + (t * v-line.at(0))
      let target-y = op.p1.at(1) + (t * v-line.at(1))
      (target-x - current.at(0), target-y - current.at(1))
      
    } else if op.type == "go-frac" {
      // Linear interpolation between two points
      let target-x = op.p1.at(0) + ((op.p2.at(0) - op.p1.at(0)) * op.f)
      let target-y = op.p1.at(1) + ((op.p2.at(1) - op.p1.at(1)) * op.f)
      (target-x - current.at(0), target-y - current.at(1))
      
    } else if op.type == "move-along" {
      // Get the direction of the reference line and travel 'dist' along it
      let v = vector.sub(op.p2, op.p1)
      let current-len = vector.len(v)
      if current-len == 0 { (0,0) } else {
        ((v.at(0) / current-len) * op.dist, (v.at(1) / current-len) * op.dist)
      }}else if op.type == "drop-a" {
      // Raycast at an angle to hit p1-p2
      let dx = calc.cos(op.angle * 1deg)
      let dy = calc.sin(op.angle * 1deg)
      let vx = op.p2.at(0) - op.p1.at(0)
      let vy = op.p2.at(1) - op.p1.at(1)
      let wx = current.at(0) - op.p1.at(0)
      let wy = current.at(1) - op.p1.at(1)
      
      let det = (dx * vy) - (dy * vx)
      if det == 0 { (0, 0) } else { // Prevent crash if parallel
        let t = (wy * vx - wx * vy) / det
        (t * dx, t * dy)
      }
      
    }else if op.type == "a-to" {
      // 1. Get current position and target
      let (x0, y0) = current
      let (xt, yt) = op.pt
      
      // 2. Calculate the unit vector for the given angle
      let dx = calc.cos(op.angle * 1deg)
      let dy = calc.sin(op.angle * 1deg)
      
      // 3. Vector from current position to the target point
      let wx = xt - x0
      let wy = yt - y0
      
      // 4. Use the Dot Product to find the distance along the angle 
      // needed to reach the projection of the target point
      let dist = (wx * dx) + (wy * dy)
      
      (dist * dx, dist * dy)}
    else if op.type == "int-move" {
      // 1. Determine intended movement vector (V)
      let (dx, dy) = if "target-pt" in op {
        (op.target-pt.at(0) - current.at(0), op.target-pt.at(1) - current.at(1))
      } else { op.d }
      
      let final-delta = (dx, dy)

      // 2. Check for intersection with boundary segment (P1 to P2)
      if op.p1 != none and op.p2 != none {
        let (x1, y1) = current
        let (x2, y2) = (x1 + dx, y1 + dy)
        let (x3, y3) = op.p1
        let (x4, y4) = op.p2

        let den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
        
        if den != 0 { // Not parallel
          let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
          let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den

          // If t is between 0-1, the intersection is within our move
          // If u is between 0-1, the intersection is within the boundary segment
          if t > 0 and t < 1 and u >= 0 and u <= 1 {
            final-delta = (dx * t, dy * t)
          }
        }
      }
      final-delta}
    else if op.type == "drop-parallel" {
      // Raycast parallel to a reference line to hit target t1-t2
      let dx = op.ref2.at(0) - op.ref1.at(0)
      let dy = op.ref2.at(1) - op.ref1.at(1)
      let vx = op.t2.at(0) - op.t1.at(0)
      let vy = op.t2.at(1) - op.t1.at(1)
      let wx = current.at(0) - op.t1.at(0)
      let wy = current.at(1) - op.t1.at(1)
      
      let det = (dx * vy) - (dy * vx)
      if det == 0 { (0, 0) } else {
        let t = (wy * vx - wx * vy) / det
        (t * dx, t * dy)
      }}
    else {
      // Standard Move or Jump
      op.d
    }
    
    // 3. Update the cursor position
    current = (current.at(0) + delta.at(0), current.at(1) + delta.at(1))
    
    // 3. NEW: If it's a jump, start a new segment. Otherwise, add to the current segment.
    let is-jump = op.type == "jump" or op.type == "jump-home" or op.type == "jump-to-mark"

    // Extract the active layer's data so we can update it
    let active-data = layers.at(current-layer)
    
    
    if is-jump {
      active-data.segments.push((current,))
    } else if op.type in drawing-ops {
      active-data.pts.push(current)
      active-data.segments.last().push(current)
    }

    // Save it back to the layers dictionary
    layers.insert(current-layer, active-data)
  }
  
  // Return the data! 
  // We map 'pts' strictly to the Boundary layer so your area/dim math NEVER breaks!
  (
    pts: layers.at("Boundary").pts, 
    segments: layers.at("Boundary").segments, 
    anchors: anchors,
    layers: layers // Export the full layer system for drawing
  )
}


// ==========================================
// 3. DIMENSIONING & AREA
// ==========================================

#let get-area(pts) = {
  let n = pts.len()
  let sum = 0.0
  for i in range(n) {
    let p1 = pts.at(i)
    let p2 = pts.at(calc.rem(i + 1, n))
    sum += (p1.at(0) * p2.at(1) - p2.at(0) * p1.at(1))
  }
  0.5 * calc.abs(sum)
}

#let get-angle(v) = { calc.atan2(v.at(0), v.at(1)) }

#let dim(from, to, offset: 2.0, label: auto, show-line: true, size:global-dim-size,) = {
  let v = vector.sub(to, from)
  let dist = vector.len(v)
  let angle = get-angle(v)
  let is-flipped = angle > 90deg or angle < -90deg
  
  group({
    translate(from); rotate(angle); translate((0, offset))
    
    // Toggle the line and marks
    if show-line {
      line((0, 0), (dist, 0), mark: (start: "|", end: "|"), stroke: 0.25pt)
    }
    
    content((dist/2, 0), angle: if is-flipped { angle+180deg } else { angle }, {
        let txt = if label == auto { to-arch-str(dist) } else { label }
        box(fill: white, inset: 0.5pt, text(size: size, txt))
    })
  })
  
}

//Automatically adds dimension lines to the sides of the plot
#let auto-dim-plot(plot-data, offset: 3.0, sides: none, size:global-dim-size, show-line: true) = {
  let pts = plot-data.pts
  let n = pts.len()
  for i in range(n) {
    if sides == none or i in sides {
      let p1 = pts.at(i)
      let p2 = pts.at(calc.rem(i + 1, n))
      
      //Check distance before attempting to draw dimension
      let d = vector.len(vector.sub(p2, p1))
      if d > 0.01 {
         dim(p1, p2, offset: offset, size: size , show-line: show-line)
      }
    }
  }
}



#let print-marks(trace-data, size: global-mark-size, color: blue, offset: (0.3, 0.2)) = {
  // 1. Safety check
  if type(trace-data) != dictionary or "anchors" not in trace-data { return }

  // 2. Loop through all named anchors
  for (name, pos) in trace-data.anchors {
    group({
      // A. Draw a visual "Crosshair" at the exact point
      let s = 0.25 // size of crosshair arms
      line(vector.add(pos, (-s, 0)), vector.add(pos, (s, 0)), stroke: 0.5pt + color)
      line(vector.add(pos, (0, -s)), vector.add(pos, (0, s)), stroke: 0.5pt + color)
      
      // B. Draw a circle to highlight the intersection
      circle(pos, radius: s/2, fill: none, stroke: 0.5pt + color)

      // C. Draw the Label Name
      // We apply the offset so the text doesn't obscure the geometry corner
      let text-pos = vector.add(pos, offset)
      content(
        text-pos, 
        text(fill: color, size: size, weight: "bold", font: "Barlow", name),
        anchor: "south-west" // Anchors text bottom-left to the offset point
      )
    })
  }
}



#let get-length(p1, p2) = {
  vector.len(vector.sub(p2, p1))
}

#let get-angle-between(p1, vertex, p2) = {
  // 1. Get the vectors from the vertex to each point
  let v1 = vector.sub(p1, vertex)
  let v2 = vector.sub(p2, vertex)
  
  // 2. Calculate the absolute angle of each line
  let a1 = calc.atan2(v1.at(0), v1.at(1))
  let a2 = calc.atan2(v2.at(0), v2.at(1))
  
  // 3. Find the difference
  let diff = calc.abs(a1 - a2)
  
  // 4. Ensure we always get the interior angle (<= 180deg)
  let final-angle = if diff > 180deg {
    360deg - diff
  } else {
    diff
  }
  
  // 5. Return as a pure number instead of an 'angle' type
  final-angle / 1deg
}


#let draw-angle-mark(vertex, p1, p2, radius: 3, size: global-angle-size, color: red, flip: false, label-radius: auto) = {
  // 1. Swap the points if flip is true
  let (start-p, end-p) = if flip {
    (p2, p1)
  } else {
    (p1, p2)
  }
  
  // 2. Calculate the TRUE counter-clockwise angle matching the CeTZ arc
  let v1 = vector.sub(start-p, vertex)
  let v2 = vector.sub(end-p, vertex)
  
  // (Corrected: Typst atan2 requires X first, then Y!)
  let a1 = calc.atan2(v1.at(0), v1.at(1))
  let a2 = calc.atan2(v2.at(0), v2.at(1))
  
  let diff = a2 - a1
  
  // If the difference is negative, add 360 to get the true CCW rotation
  let final-angle = if diff < 0deg { 
    diff + 360deg 
  } else { 
    diff 
  }
  
  // 3. Format the true angle text
  let ang-val = final-angle / 1deg
  let ang-str = str(calc.round(ang-val, digits: 2)) + "°"
  
  // 4. Draw the angle and label!
  cetz.angle.angle(
    vertex, start-p, end-p, 
    label: text(size: size, fill: color, weight: "bold", ang-str), 
    radius: radius, 
    stroke: 0.5pt + color,
    fill: color.transparentize(85%), 
    // NEW: Uses your custom distance, or defaults to radius + 3
    label-radius: if label-radius == auto { radius + 3 } else { label-radius }
  )
}

//Automatically calculate angles of the plot, use flip to get angles from other side
#let auto-angle-plot(plot-data, radius: 3, size: global-angle-size, color: red, flip: false, label-radius: auto,) = {
  // 1. Clean the points (remove consecutive duplicates caused by drops/jumps)
  let raw-pts = plot-data.pts
  let pts = ()
  for p in raw-pts {
    if pts.len() == 0 or get-length(p, pts.last()) > 0.01 {
      pts.push(p)
    }
  }
  
  // Remove the final "Home" duplicate if it exists
  if pts.len() > 1 and get-length(pts.last(), pts.first()) < 0.01 {
    pts.pop()
  }

  let n = pts.len()
  if n < 3 { return } // Safety check: can't draw angles on a line
  
  // 2. Wrap in a group so CeTZ safely renders the loop
  group({
    for i in range(n) {
      // Find the three points that make up the corner
      let prev = pts.at(calc.rem(i - 1 + n, n))
      let vertex = pts.at(i)
      let next = pts.at(calc.rem(i + 1, n))
      
      let ang = get-angle-between(prev, vertex, next)
      
      // 3. Only draw if it's a real corner (skip straight 180° walls)
      if ang > 1.0 and ang < 179.0 {
        // Pass the points directly, and hand the 'flip' parameter straight to your draw function!
        draw-angle-mark(
          vertex, prev, next, 
          radius: radius, 
          label-radius: label-radius,
          size: size, 
          color: color, 
          flip: flip
        )
      }
    }
  })
}


// Draws the plot and places the name/area in center
#let draw-plot(
  plot-data, name: "", fill: none, stroke: 1pt + black, 
  show-area: false, show-dim: false, dim-offset: 3.0, 
  sides: none, area-size: global-area-size, name-size: global-name-size, 
  dim-size: global-dim-size, show-dim-line: true, 
  shift-name: (0, 0),
  name-angle: 0deg , close-path: true, show-angle:(false, false), show-markers:false, angle-radius:3, angle-label-radius:auto, angle-size:9pt, layer-styles: (:)
) = {
  let pts = plot-data.pts

  // 1. DRAW ALL LAYERS
  if "layers" in plot-data {
    for (l-name, l-data) in plot-data.layers {
      // Look up the custom stroke, or default to the main stroke
      let l-stroke = layer-styles.at(l-name, default: stroke)
      
      for (i, seg) in l-data.segments.enumerate() {
        if seg.len() > 1 {
          // Only close the Boundary's first segment. Leave other layers open.
          let do-close = if i == 0 and l-name == "Boundary" { close-path } else { false }
          line(..seg, close: do-close, fill: if i == 0 and l-name == "Boundary" { fill } else { none }, stroke: l-stroke)
        }
      }
    }
  }
   
  //line(..pts, close: close-path, fill: fill, stroke: stroke)
  
  // Calculate default center for label
  let cx = pts.map(p => p.at(0)).sum() / pts.len()
  let cy = pts.map(p => p.at(1)).sum() / pts.len()
  
  // Apply the manual shift
  let label-x = cx + shift-name.at(0)
  let label-y = cy + shift-name.at(1)
  
  // Conditionally draw the Name and Area text at the shifted and rotated position
  content((label-x, label-y), angle: name-angle, align(center)[ // <-- NEW: Applied angle here
    #if name != "" {
      text(weight: "bold", size: name-size, name)
    }
    #if name != "" and show-area {
      linebreak() 
      v(-0.7em)
    }
    #if show-area {
      text(size: area-size, str(calc.round(get-area(pts), digits: 2)) + " ft²")
    }
  ])

  // Conditionally draw the dimensions
  if show-dim {
    auto-dim-plot(plot-data, offset: dim-offset, sides: sides, size: dim-size, show-line: show-dim-line)
  }
  // Show the dimension
  if show-angle.at(0){
    auto-angle-plot(plot-data, radius: angle-radius, label-radius:angle-label-radius, size: angle-size,  flip:show-angle.at(1))
  }

  //Show the Markers
  if show-markers{
      print-marks(plot-data)
  }
}

#let draw-arc-to(p1, p2, radius, ccw: true, large: false, steps: 32, stroke: 1.5pt + black) = {
  // 1. Calculate the distance between the two anchors
  let dx = p2.at(0) - p1.at(0)
  let dy = p2.at(1) - p1.at(1)
  let d = calc.sqrt(dx * dx + dy * dy)

  if d == 0 { return } // Safety check

  // 2. Safety check: Prevent crashing if the radius is too small
  let actual-r = if radius < d / 2.0 { d / 2.0 } else { radius }

  // 3. Find the invisible center point of the circle
  let mx = (p1.at(0) + p2.at(0)) / 2.0
  let my = (p1.at(1) + p2.at(1)) / 2.0
  let h = calc.sqrt(actual-r * actual-r - (d / 2.0) * (d / 2.0))

  let nx = -dy / d
  let ny = dx / d

  let sign = if ccw == large { -1.0 } else { 1.0 }
  let cx = mx + sign * h * nx
  let cy = my + sign * h * ny

  // 4. Calculate the sweep angles (X first, then Y!)
  let start-ang = calc.atan2(p1.at(0) - cx, p1.at(1) - cy)
  let end-ang = calc.atan2(p2.at(0) - cx, p2.at(1) - cy)

  let sweep = end-ang - start-ang
  if ccw and sweep < 0deg { sweep += 360deg }
  if not ccw and sweep > 0deg { sweep -= 360deg }

  // 5. Generate the smooth curve points
  let pts = ()
  let step-ang = sweep / steps
  for i in range(steps + 1) {
    let a = start-ang + (step-ang * i)
    let px = cx + actual-r * calc.cos(a)
    let py = cy + actual-r * calc.sin(a)
    pts.push((px, py))
  }

  // 6. Draw the curve!
  cetz.draw.line(..pts, stroke: stroke)
}


// Generate a grid of plots using EXACT widths and heights inside a 4-sided boundary
// p1: Bottom-Left, p2: Bottom-Right, p3: Top-Right, p4: Top-Left
#let generate-custom-grid(p1, p2, p3, p4, widths: (), heights: (), auto-fill-x: true, auto-fill-y: true, start-idx: 1, names: ()) = {
  let generated-plots = ()
  
  // 1. Get total lengths of the bottom and left reference edges
  let len-bottom = get-length(p1, p2)
  let len-left = get-length(p1, p4)

  if len-bottom == 0 or len-left == 0 { return () }

  // 2. AUTO-FILL WIDTHS: Add the leftover horizontal space!
  let final-widths = widths
  let used-w = widths.sum(default: 0)
  if auto-fill-x and used-w < len-bottom - 0.1 {
    final-widths.push(len-bottom - used-w)
  }

  // 3. AUTO-FILL HEIGHTS: Add the leftover vertical space!
  let final-heights = heights
  let used-h = heights.sum(default: 0)
  if auto-fill-y and used-h < len-left - 0.1 {
    final-heights.push(len-left - used-h)
  }

  // 4. Convert to percentages and CLAMP to 1.0 to prevent weird overlaps!
  let u-vals = (0.0,)
  let current-u = 0.0
  for w in final-widths {
    current-u += (w / len-bottom)
    u-vals.push(calc.min(1.0, current-u)) // Safety Lock!
  }

  let v-vals = (0.0,)
  let current-v = 0.0
  for h in final-heights {
    current-v += (h / len-left)
    v-vals.push(calc.min(1.0, current-v)) // Safety Lock!
  }

  //Safe Bilinear Math Helper
  let get-pt(u, v) = {
    let lx = p1.at(0) + v * (p4.at(0) - p1.at(0))
    let ly = p1.at(1) + v * (p4.at(1) - p1.at(1))
    
    let rx = p2.at(0) + v * (p3.at(0) - p2.at(0))
    let ry = p2.at(1) + v * (p3.at(1) - p2.at(1))
    
    (lx + u * (rx - lx), ly + u * (ry - ly))
  }

  // 6. Trace every individual plot
  let count = start-idx
  let idx = 0 // Keeps track of where we are in the custom names list

  for r in range(final-heights.len()) {
    for c in range(final-widths.len()) {
      let u1 = u-vals.at(c)
      let u2 = u-vals.at(c + 1)
      let v1 = v-vals.at(r)
      let v2 = v-vals.at(r + 1)

      let c1 = get-pt(u1, v1) 
      let c2 = get-pt(u2, v1) 
      let c3 = get-pt(u2, v2) 
      let c4 = get-pt(u1, v2) 

      let p = trace-plot(start: c1, (
        GoTo(c2), Mark("br"),
        GoTo(c3), Mark("tr"),
        GoTo(c4), Mark("tl"),
        JumpHome()
      ))

      // Get custom name or fallback to the counter
      let raw-name = if idx < names.len() {
        names.at(idx)
      } else {
        str(count)
      }

      // Create a safe string ID for the overrides dictionary
      let safe-id = if type(raw-name) == str { raw-name } 
      else if type(raw-name) == int { str(raw-name) } 
      else { str(count) } // Failsafe for content blocks

      generated-plots.push((
        data: p, 
        name: raw-name, 
        id: safe-id
      ))
      
      count += 1
      idx += 1
    }
  }
  
  generated-plots
}


// UTILITY: CALCULATE ANY POINT FROM A COMMAND (current point, then use any tracing command)
#let get-pt(current, op) = {
  if op.type == "drop-y" {
    let x = current.at(0)
    let (x1, y1) = op.p1; let (x2, y2) = op.p2
    let target-y = if x1 == x2 { y1 } else { y1 + (y2 - y1) * (x - x1) / (x2 - x1) }
    (x, target-y)
    
  } else if op.type == "drop-x" {
    let y = current.at(1)
    let (x1, y1) = op.p1; let (x2, y2) = op.p2
    let target-x = if y1 == y2 { x1 } else { x1 + (x2 - x1) * (y - y1) / (y2 - y1) }
    (target-x, y)
    
  } else if op.type == "go-x" { (op.x, current.at(1))
  } else if op.type == "go-y" { (current.at(0), op.y)
  } else if op.type == "go-to" { op.pt
    
  } else if op.type == "drop-perp" {
    let v-line = vector.sub(op.p2, op.p1)
    let v-pt = vector.sub(current, op.p1)
    let line-len-sq = (v-line.at(0) * v-line.at(0)) + (v-line.at(1) * v-line.at(1))
    let t = if line-len-sq == 0 { 0 } else { (v-pt.at(0) * v-line.at(0) + v-pt.at(1) * v-line.at(1)) / line-len-sq }
    (op.p1.at(0) + (t * v-line.at(0)), op.p1.at(1) + (t * v-line.at(1)))
    
  } else if op.type == "go-frac" {
    (op.p1.at(0) + ((op.p2.at(0) - op.p1.at(0)) * op.f), op.p1.at(1) + ((op.p2.at(1) - op.p1.at(1)) * op.f))
    
  } else if op.type == "move-along" {
    let v = vector.sub(op.p2, op.p1)
    let current-len = vector.len(v)
    if current-len == 0 { current } else {
      (current.at(0) + (v.at(0) / current-len) * op.dist, current.at(1) + (v.at(1) / current-len) * op.dist)
    }
    
  } else if op.type == "drop-a" {
    let dx = calc.cos(op.angle * 1deg); let dy = calc.sin(op.angle * 1deg)
    let vx = op.p2.at(0) - op.p1.at(0); let vy = op.p2.at(1) - op.p1.at(1)
    let wx = current.at(0) - op.p1.at(0); let wy = current.at(1) - op.p1.at(1)
    let det = (dx * vy) - (dy * vx)
    if det == 0 { current } else { 
      let t = (wy * vx - wx * vy) / det
      (current.at(0) + t * dx, current.at(1) + t * dy)
    }
    
  } else if op.type == "drop-parallel" {
    let dx = op.ref2.at(0) - op.ref1.at(0); let dy = op.ref2.at(1) - op.ref1.at(1)
    let vx = op.t2.at(0) - op.t1.at(0); let vy = op.t2.at(1) - op.t1.at(1)
    let wx = current.at(0) - op.t1.at(0); let wy = current.at(1) - op.t1.at(1)
    let det = (dx * vy) - (dy * vx)
    if det == 0 { current } else {
      let t = (wy * vx - wx * vy) / det
      (current.at(0) + t * dx, current.at(1) + t * dy)
    }
    
  } else if op.type == "a-to" {
    let (x0, y0) = current
    let (xt, yt) = op.pt
    let dx = calc.cos(op.angle * 1deg); let dy = calc.sin(op.angle * 1deg)
    let wx = xt - x0; let wy = yt - y0
    let dist = (wx * dx) + (wy * dy)
    (x0 + dist * dx, y0 + dist * dy)
    
  } else if op.type == "int-move" {
    let (dx, dy) = if "target-pt" in op {
      (op.target-pt.at(0) - current.at(0), op.target-pt.at(1) - current.at(1))
    } else { op.d }
    let final-delta = (dx, dy)
    if op.p1 != none and op.p2 != none {
      let (x1, y1) = current
      let (x2, y2) = (x1 + dx, y1 + dy)
      let (x3, y3) = op.p1; let (x4, y4) = op.p2
      let den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
      if den != 0 {
        let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
        let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
        if t > 0 and t < 1 and u >= 0 and u <= 1 { final-delta = (dx * t, dy * t) }
      }
    }
    (current.at(0) + final-delta.at(0), current.at(1) + final-delta.at(1))
    
  } else if "d" in op {
    // Handles basic moves like U(10), D(10), R(10), L(10), A(angle, len)
    (current.at(0) + op.d.at(0), current.at(1) + op.d.at(1))
  } else {
    current // Failsafe
  }
}


// UTILITY: DRAW GRID WITH OVERRIDES
#let draw-grid-plots(grid-data, default-props: (:), overrides: (:)) = {
  for p in grid-data {
    
    // 1. Safe name formatting (Adds "Plot" automatically to raw strings)
    let final-name = if type(p.name) == content { p.name } else { [#p.name] }
    
    let current-props = (name: final-name)
    
    // 2. Apply any global defaults
    for (k, v) in default-props {
      current-props.insert(k, v)
    }
    
    // 3. Look up overrides using the pure string ID! 
    let plot-id = if "id" in p { p.id } else { str(p.name) }
    
    if plot-id in overrides {
      for (k, v) in overrides.at(plot-id) {
        current-props.insert(k, v)
      }
    }
    
    // 4. Draw the plot!
    draw-plot(p.data, ..current-props)
  }
}


// Get total perimeter (running length) for given vertices
#let get-perimeter(vertices) = {
  if type(vertices) != array or vertices.len() < 2 { return 0.0 }
  let p = 0.0
  let n = vertices.len()
  for i in range(n) {
    let current = vertices.at(i)
    let next = vertices.at(calc.rem(i + 1, n))
    p += get-length(current, next)
  }
  return p
}


/// --- SMART MULTI-PLOT SUMMARY TABLE ---
// Accepts multiple subdivisions, single traces, or custom dictionaries
#let plot-summary-table(..plots) = {
  let cells = ()
  let flat-plots = ()
  
  // 1. Flatten all inputs into a single list
  for item in plots.pos() {
    if type(item) == array {
      // It's a subdivision (array of plots), so pull them all out
      for p in item { flat-plots.push(p) }
    } else if type(item) == dictionary {
      // It's a single trace or manual plot dictionary
      flat-plots.push(item)
    }
  }

  // 2. Header Row
  let header(txt) = table.cell(fill: luma(230), align: center, text(weight: "bold", size: 9pt, txt))
  cells.push(header("Plot No."))
  cells.push(header("Perimeter"))
  cells.push(header("Area"))
  
  // 3. Loop through the flattened plots
  for (idx, p) in flat-plots.enumerate() {
    
    // A. Figure out the Name
    // If it came from a grid, it has a name. If it's a raw trace, we auto-number it.
    let plot-name = if "name" in p { 
      p.name 
    } else { 
      "Trace " + str(idx + 1) 
    }
    
    // B. Extract the Trace Data
    let trace-data = if "data" in p { p.data } else { p }
    
    let perim-str = "-"
    let area-str = "-"
    
    // C. Calculate Math if we have valid points
    if type(trace-data) == dictionary and "pts" in trace-data {
      let pts = trace-data.pts
      if pts.len() > 2 {
        let perim-val = get-perimeter(pts)
        let area-val = get-area(pts)
        
        perim-str = to-arch-str(perim-val)
        area-str = str(calc.round(area-val, digits: 2)) + " sq ft"
      }
    }
    
    // D. Push the row to the table
    cells.push(align(center, text(size: 9pt, str(plot-name))))
    cells.push(align(center, text(size: 9pt, perim-str)))
    cells.push(align(center, text(size: 9pt, area-str)))
  }
  
  // 4. Render Table
  block(
    table(
      columns: (auto, auto, auto), 
      stroke: 0.5pt + black, inset: 4pt,
      ..cells
    )
  )
}
