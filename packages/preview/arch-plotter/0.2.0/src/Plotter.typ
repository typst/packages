#import "@preview/cetz:0.5.2"
#import cetz.draw: *
#import cetz.vector


/// A dedicated canvas for land surveying and property boundaries
/// - scale (length): The scale of the canvas.
/// - body (any): The drawing code
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

#let drawing-ops = ("move", "home", "drop-y", "drop-x", "drop-perp",  "go-x", "go-y", "go-to", "go-frac", "move-along", "drop-a", "drop-parallel", "int-move", "a-to", "go-to-mark", "go-x-mark", "go-y-mark", "curve-to", "gap-to", "remove-line")

// ==========================================
// 1. UNIT & STRING FORMATTING
// ==========================================

// ==========================================
// GLOBAL PRECISION SETTING
// Change this to: 4 (Quarters), 8 (Eighths), or 16 (Sixteenths)
// ==========================================
#let global-precision = 4 

/// Converts decimal value to a formatted string (feet and inches)
#let to-arch-str(value) = {
  let total-inches = calc.round(value * 12 * global-precision) / global-precision
  let feet = calc.floor(total-inches / 12)
  let rest-inches = calc.rem(total-inches, 12)
  let inch-whole = calc.floor(rest-inches)
  
  // Calculate fractional parts based on your global setting
  let parts = calc.round((rest-inches - inch-whole) * global-precision)
  
  // Dynamically simplify the fraction (e.g., 2/4 automatically becomes 1/2)
  let fraction = if parts == 0 { 
    [] 
  } else {
    let n = parts
    let d = global-precision
    // Keep dividing by 2 to reduce the fraction
    while calc.rem(n, 2) == 0 and calc.rem(d, 2) == 0 {
      n = calc.trunc(n / 2)
      d = calc.trunc(d / 2)
    }
    [ $#n/#d$]
  }
  
  str(feet) + "'" + str(inch-whole) + fraction + "\""
}

// ==========================================
// 2. PLOT ENGINE (LINES & JUMPS)
// ==========================================
// 

///Switches the active drawing layer inside a trace
/// - name (str): Name of the layer
#let Layer(name) = (type: "layer", name: name)

/// Drop at Y direction till the intersecting point
#let DropY(p1, p2) = (type: "drop-y", p1: p1, p2: p2)
/// Drop at X direction till the intersecting point
#let DropX(p1, p2) = (type: "drop-x", p1: p1, p2: p2)

/// Go at X position with given length
#let GoX(x) = (type: "go-x", x: x)

/// Go at Y position with given length
#let GoY(y) = (type: "go-y", y: y)

/// Goto to the given point
#let GoTo(pt) = (type: "go-to", pt: pt)

/// Draw a line directly to a previously marked anchor fractionally (f: 0.5 is midpoint)
#let GoToMark(name, f: 1.0) = (type: "go-to-mark", name: name, f: f)

/// Go to the X coordinate of a previously marked anchor fractionally
#let GoXMark(name, offset: 0, f: 1.0) = (type: "go-x-mark", name: name, offset: offset, f: f)

/// Go to the Y coordinate of a previously marked anchor fractionally
#let GoYMark(name, offset: 0, f: 1.0) = (type: "go-y-mark", name: name, offset: offset, f: f)


/// Go right use "int" for intersecting line
#let R(val, skip: 0, ..args) = (type: "move", r: val, skip: skip, args: args.named())

/// Go left use "int" for intersecting line
#let L(val, skip: 0, ..args) = (type: "move", l: val, skip: skip, args: args.named())

/// Go up use "int" for intersecting line
#let U(val, skip: 0, ..args) = (type: "move", u: val, skip: skip, args: args.named())

/// Go down use "int" for intersecting line
#let D(val, skip: 0, ..args) = (type: "move", d: val, skip: skip, args: args.named())

/// Go angle with length or use "int" for intersecting line
#let A(angle, val, skip: 0, ..args) = (type: "move", a: angle, dist: val, skip: skip, args: args.named())

/// Draws a smooth curve to a target using a control point. 
/// It converts the curve into tiny straight lines so Area and Raycasting still work!
#let CurveTo(target, control, steps: 20) = (type: "curve-to", target: target, control: control, steps: steps)

/// Moves the cursor to a target, keeping Area math perfect, but leaves a transparent gap in the wall.
#let GapTo(target) = (type: "gap-to", target: target)


/// Retroactively searches memory and deletes the drawn line between two points, without breaking Area math.
#let RemoveLine(m1, m2) = (type: "remove-line", m1: m1, m2: m2)


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

#let JR(val, skip: 0, ..args) = (type: "jump", r: val, skip: skip, args: args.named())
#let JL(val, skip: 0, ..args) = (type: "jump", l: val, skip: skip, args: args.named())
#let JU(val, skip: 0, ..args) = (type: "jump", u: val, skip: skip, args: args.named())
#let JD(val, skip: 0, ..args) = (type: "jump", d: val, skip: skip, args: args.named())
#let JA(angle, val, skip: 0, ..args) = (type: "jump", a: angle, dist: val, skip: skip, args: args.named())

//Jump Home command (Moves to start without drawing a line)
#let JumpHome() = (type: "jump-home")

// Move to a previously marked anchor without drawing a line
#let JumpToMark(name) = (type: "jump-to-mark", name: name)


//Marks an anchor
#let Mark(name) = (type: "mark", name: name)

/// Raycasts to find the nearest plotted segment and snaps to it.
/// Use `a: angle` to shoot diagonally! (e.g., a: 45)
#let MoveMark(name, u: none, d: none, l: none, r: none, a: none, skip: 0, move-cursor: false) = (
  type: "move-mark", 
  name: name, 
  u: u, d: d, l: l, r: r, a: a, 
  skip: skip,
  move-cursor: move-cursor
)

//Home command which will add to the list, Use JumpHome if you dont want to add to the array list
#let Home() = (type: "home")

// --- THE SMART TRACE FUNCTION THAT MANAGES CO-ORDINATES SMARTLY ---
#let trace-plot(start: (0,0), ctx: (), mark-steps: false, ops) = {
  let current = start
  let pts = (start,)
  
  let anchors = (start: start)
  if mark-steps { anchors.insert("start", start) }
  
  let segments = ((start,),) 

  // --- LAYER SYSTEM SETUP ---
  let current-layer = "Boundary"
  let layers = (
    "Boundary": (pts: (start,), segments: ((start,),))
  )
  
  let step-counter = 1 
  let jump-counter = 1 

  // ==========================================
  // SPEED OPTIMIZATION: STATIC CONTEXT MEMORY
  // Reads previous plots ONCE to make Raycasting lightning fast!
  // ==========================================
  let static-ctx-segs = ()
  let ctx-list = if type(ctx) == array { ctx } else if type(ctx) == dictionary { (ctx,) } else { () }
  
  for prev-plot in ctx-list {
    let target-plot = if type(prev-plot) == dictionary and "data" in prev-plot {
      prev-plot.data 
    } else { prev-plot }

    if type(target-plot) == dictionary and "layers" in target-plot {
      for (l-name, l-data) in target-plot.layers { 
        for (i, seg) in l-data.segments.enumerate() {
          let temp-seg = seg
          if i == 0 and l-name == "Boundary" and temp-seg.len() > 2 { temp-seg.push(temp-seg.first()) }
          static-ctx-segs.push(temp-seg)
        }
      }
    } else if type(target-plot) == dictionary and "segments" in target-plot {
      for (i, seg) in target-plot.segments.enumerate() {
        let temp-seg = seg
        if i == 0 and temp-seg.len() > 2 { temp-seg.push(temp-seg.first()) }
        static-ctx-segs.push(temp-seg)
      }
    }
  }

  for op in ops {

    // ==========================================
    // 0. THE GLOBAL RAYCASTER
    // ==========================================
    let raycast(dx, dy, skip) = {
      let cx = current.at(0)
      let cy = current.at(1)
      let hits = () 
      
      // Safely clone the static context memory
      let all-segs = () + static-ctx-segs 

      // Add the currently active layers
      for (l-name, l-data) in layers { 
        for (i, seg) in l-data.segments.enumerate() {
          let temp-seg = seg
          if i == 0 and l-name == "Boundary" and temp-seg.len() > 2 { temp-seg.push(temp-seg.first()) }
          all-segs.push(temp-seg)
        }
      }

      for seg in all-segs {
        if seg.len() > 1 {
          for i in range(seg.len() - 1) {
            let ax = seg.at(i).at(0); let ay = seg.at(i).at(1)
            let bx = seg.at(i+1).at(0); let by = seg.at(i+1).at(1)
            let vx = bx - ax; let vy = by - ay
            let wx = ax - cx; let wy = ay - cy
            let det = dx * vy - dy * vx
            
            if calc.abs(det) > 0.000001 {
              let t = (wx * vy - wy * vx) / det
              let u = (wx * dy - wy * dx) / det
              let L = calc.sqrt(vx * vx + vy * vy)
              let margin = if L > 0 { 0.005 / L } else { 0.0 }
              
              if t > 0.001 and u >= -margin and u <= 1.0 + margin {
                hits.push((dist: t, pt: (cx + dx * t, cy + dy * t)))
              }
            }
          }
        }
      }
      
      if hits.len() > 0 {
        let sorted = hits.sorted(key: h => h.dist)
        let unique-hits = ()
        let last-pt = (-9999.0, -9999.0)
        
        for h in sorted {
          let dist-from-last = calc.abs(h.pt.at(0) - last-pt.at(0)) + calc.abs(h.pt.at(1) - last-pt.at(1))
          if dist-from-last > 0.01 { 
            unique-hits.push(h)
            last-pt = h.pt
          }
        }
        if skip < unique-hits.len() { return unique-hits.at(skip).pt } 
        else if unique-hits.len() > 0 { return unique-hits.last().pt }
      }
      return none 
    }

    // ==========================================
    // 0.5 SMART FRACTION & SNAP CONVERTER
    // ==========================================
    let apply-dir(val, dx, dy, cur-x, cur-y, skip) = {
      if val == none { return (cur-x, cur-y) }
      if type(val) == array { return (cur-x + val.at(0), cur-y + val.at(1)) }
      
      // Anchor Snapping Logic
      if type(val) == str and val in anchors {
        let target = anchors.at(val)
        let t-proj = (target.at(0) - cur-x) * dx + (target.at(1) - cur-y) * dy
        let dist = calc.abs(t-proj)
        return (cur-x + dx * dist, cur-y + dy * dist)
      }

      let t = type(val)
      let is-auto = val == auto or val == "auto" or val == "int" or val == 0 or val == 0.0 or val == "0" or val == "0.0"
      let is-native-ratio = t == ratio
      let is-string-ratio = t == str and val.ends-with("%")

      if is-auto or is-native-ratio or is-string-ratio {
        let res = raycast(dx, dy, skip) 
        if res != none {
          let tx = res.at(0); let ty = res.at(1)
          if is-auto { 
            return (tx, ty) 
          } else {
            let mult = if is-native-ratio { float(val / 100%) } else { float(val.trim("%")) / 100.0 }
            return (cur-x + (tx - cur-x) * mult, cur-y + (ty - cur-y) * mult)
          }
        }
        return (cur-x, cur-y)
      } else {
        // Crash-Proof Safety Net
        if type(val) == str { return (cur-x, cur-y) }
        let dist = float(val)
        return (cur-x + dx * dist, cur-y + dy * dist)
      }
    }

    if op.type == "mark" {
      anchors.insert(op.name, current)
      continue
    }

    if op.type == "layer" {
      current-layer = op.name
      if current-layer not in layers {
        layers.insert(current-layer, (pts: (current,), segments: ((current,),)))
      }
      continue
    }
    
    // ==========================================
    // 3. MOVEMENT DELTA CALCULATION
    // ==========================================
    let delta = if op.type == "home" or op.type == "jump-home" {
      (start.at(0) - current.at(0), start.at(1) - current.at(1))
      
    } else if op.type == "go-to-mark" or op.type == "jump-to-mark" {
      if op.name in anchors {
        let pt = anchors.at(op.name)
        let frac = op.at("f", default: 1.0) 
        ((pt.at(0) - current.at(0)) * frac, (pt.at(1) - current.at(1)) * frac)
      } else { (0, 0) } 
      
    } else if op.type == "drop-y" {
      let x = current.at(0)
      let (x1, y1) = op.p1; let (x2, y2) = op.p2
      let target-y = if x1 == x2 { y1 } else { y1 + (y2 - y1) * (x - x1) / (x2 - x1) }
      (0, target-y - current.at(1))
      
    } else if op.type == "drop-x" {
      let y = current.at(1)
      let (x1, y1) = op.p1; let (x2, y2) = op.p2
      let target-x = if y1 == y2 { x1 } else { x1 + (x2 - x1) * (y - y1) / (y2 - y1) }
      (target-x - current.at(0), 0)
      
    } else if op.type == "go-x" {
      (op.x - current.at(0), 0)
      
    } else if op.type == "go-y" {
      (0, op.y - current.at(1))
      
    } else if op.type == "go-to" {
      (op.pt.at(0) - current.at(0), op.pt.at(1) - current.at(1))
      
    } else if op.type == "go-x-mark" {
      if op.name in anchors {
        let target-x = anchors.at(op.name).at(0)
        let frac = op.at("f", default: 1.0)
        (((target-x - current.at(0)) * frac) + op.offset, 0)
      } else { (0, 0) } 
      
    } else if op.type == "go-y-mark" {
      if op.name in anchors {
        let target-y = anchors.at(op.name).at(1)
        let frac = op.at("f", default: 1.0)
        (0, ((target-y - current.at(1)) * frac) + op.offset)
      } else { (0, 0) }
      
    } else if op.type == "drop-perp" {
      let v-line = vector.sub(op.p2, op.p1)
      let v-pt = vector.sub(current, op.p1)
      let line-len-sq = (v-line.at(0) * v-line.at(0)) + (v-line.at(1) * v-line.at(1))
      let t = if line-len-sq == 0 { 0 } else { (v-pt.at(0) * v-line.at(0) + v-pt.at(1) * v-line.at(1)) / line-len-sq }
      let target-x = op.p1.at(0) + (t * v-line.at(0))
      let target-y = op.p1.at(1) + (t * v-line.at(1))
      (target-x - current.at(0), target-y - current.at(1))
      
    } else if op.type == "go-frac" {
      let target-x = op.p1.at(0) + ((op.p2.at(0) - op.p1.at(0)) * op.f)
      let target-y = op.p1.at(1) + ((op.p2.at(1) - op.p1.at(1)) * op.f)
      (target-x - current.at(0), target-y - current.at(1))
      
    } else if op.type == "move-along" {
      let v = vector.sub(op.p2, op.p1)
      let current-len = vector.len(v)
      if current-len == 0 { (0,0) } else {
        ((v.at(0) / current-len) * op.dist, (v.at(1) / current-len) * op.dist)
      }
      
    } else if op.type == "drop-a" {
      let dx = calc.cos(op.angle * 1deg); let dy = calc.sin(op.angle * 1deg)
      let vx = op.p2.at(0) - op.p1.at(0); let vy = op.p2.at(1) - op.p1.at(1)
      let wx = current.at(0) - op.p1.at(0); let wy = current.at(1) - op.p1.at(1)
      let det = (dx * vy) - (dy * vx)
      if det == 0 { (0, 0) } else { 
        let t = (wy * vx - wx * vy) / det
        (t * dx, t * dy)
      }
      
    } else if op.type == "a-to" {
      let (x0, y0) = current
      let (xt, yt) = op.pt
      let dx = calc.cos(op.angle * 1deg); let dy = calc.sin(op.angle * 1deg)
      let wx = xt - x0; let wy = yt - y0
      let dist = (wx * dx) + (wy * dy)
      (dist * dx, dist * dy)
      
    } else if op.type == "int-move" {
      let (dx, dy) = if "target-pt" in op {
        (op.target-pt.at(0) - current.at(0), op.target-pt.at(1) - current.at(1))
      } else { op.d }
      let final-delta = (dx, dy)
      if op.p1 != none and op.p2 != none {
        let (x1, y1) = current
        let (x2, y2) = (x1 + dx, y1 + dy)
        let (x3, y3) = op.p1
        let (x4, y4) = op.p2
        let den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
        if den != 0 { 
          let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
          let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
          if t > 0 and t < 1 and u >= 0 and u <= 1 { final-delta = (dx * t, dy * t) }
        }
      }
      final-delta
      
    } else if op.type == "drop-parallel" {
      let dx = op.ref2.at(0) - op.ref1.at(0); let dy = op.ref2.at(1) - op.ref1.at(1)
      let vx = op.t2.at(0) - op.t1.at(0); let vy = op.t2.at(1) - op.t1.at(1)
      let wx = current.at(0) - op.t1.at(0); let wy = current.at(1) - op.t1.at(1)
      let det = (dx * vy) - (dy * vx)
      if det == 0 { (0, 0) } else {
        let t = (wy * vx - wx * vy) / det
        (t * dx, t * dy)
      }
      
    // ==========================================
    // THE SMART ENGINE 
    // ==========================================
    } else if op.type == "move" or op.type == "jump" or op.type == "move-mark" or "u" in op or "d" in op or "l" in op or "r" in op or "a" in op {
      let val-skip = op.at("skip", default: 0)
      let pos = current
      
      pos = apply-dir(op.at("r", default: none), 1, 0, pos.at(0), pos.at(1), val-skip)
      pos = apply-dir(op.at("l", default: none), -1, 0, pos.at(0), pos.at(1), val-skip)
      pos = apply-dir(op.at("u", default: none), 0, 1, pos.at(0), pos.at(1), val-skip)
      pos = apply-dir(op.at("d", default: none), 0, -1, pos.at(0), pos.at(1), val-skip)
      
      let val-a = op.at("a", default: none)
      let val-dist = op.at("dist", default: none)
      if val-a != none and val-dist != none {
        let dir-x = calc.cos(val-a * 1deg); let dir-y = calc.sin(val-a * 1deg)
        pos = apply-dir(val-dist, dir-x, dir-y, pos.at(0), pos.at(1), val-skip)
      }

      if op.type == "move-mark" {
        anchors.insert(op.name, pos)
        if op.at("move-cursor", default: false) {
          (pos.at(0) - current.at(0), pos.at(1) - current.at(1))
        } else { (0, 0) }
      } else {
        (pos.at(0) - current.at(0), pos.at(1) - current.at(1))
      }

    // ==========================================
    // RESTORED FALLBACK: For Custom Ops and Curves
    // ==========================================
    } else {
      if "d" in op and op.d == "int" {
        let res = raycast(op.at("dx", default: 0), op.at("dy", default: 0), 0)
        if res != none {
          (res.at(0) - current.at(0), res.at(1) - current.at(1))
        } else { (0, 0) }
      } else if "d" in op {
        op.d
      } else if op.type == "curve-to" {
        let p0 = current
        let p1 = if type(op.control) == str { anchors.at(op.control, default: current) } else { op.control }
        let p2 = if type(op.target) == str { anchors.at(op.target, default: current) } else { op.target }
        
        let active-data = layers.at(current-layer)
        for i in range(1, op.steps + 1) {
          let t = i / op.steps
          let nx = (1 - t) * (1 - t) * p0.at(0) + 2 * (1 - t) * t * p1.at(0) + t * t * p2.at(0)
          let ny = (1 - t) * (1 - t) * p0.at(1) + 2 * (1 - t) * t * p1.at(1) + t * t * p2.at(1)
          let new-pt = (nx, ny)
          
          active-data.pts.push(new-pt)
          active-data.segments.last().push(new-pt)
          current = new-pt
        }
        layers.insert(current-layer, active-data)
        (0, 0)
      } else if op.type == "gap-to" {
        let target-pt = if type(op.target) == str { anchors.at(op.target, default: current) } else { op.target }
        let active-data = layers.at(current-layer)
        active-data.pts.push(target-pt)
        active-data.segments.push((target-pt,))
        current = target-pt
        layers.insert(current-layer, active-data)
        (0, 0)
      } else if op.type == "remove-line" {
        let p1 = if type(op.m1) == str { anchors.at(op.m1, default: none) } else { op.m1 }
        let p2 = if type(op.m2) == str { anchors.at(op.m2, default: none) } else { op.m2 }
        if p1 != none and p2 != none {
          let active-data = layers.at(current-layer)
          let new-segments = ()
          for seg in active-data.segments {
            let split-seg = ()
            let i = 0
            while i < seg.len() {
              split-seg.push(seg.at(i))
              if i < seg.len() - 1 {
                let curr = seg.at(i)
                let next = seg.at(i + 1)
                if (curr == p1 and next == p2) or (curr == p2 and next == p1) {
                  new-segments.push(split-seg)
                  split-seg = () 
                }
              }
              i += 1
            }
            if split-seg.len() > 0 { new-segments.push(split-seg) }
          }
          active-data.segments = new-segments
          layers.insert(current-layer, active-data)
        }
        (0, 0)
      } else {
        (0, 0)
      }
    }
    
    // ==========================================
    // 4. UPDATE CURSOR & AUTO-MARK
    // ==========================================
    current = (current.at(0) + delta.at(0), current.at(1) + delta.at(1))
    
    let is-jump = op.type in ("jump", "jump-home", "jump-to-mark")
    let self-handling = op.type in ("curve-to", "gap-to", "remove-line")
    let is-meta = op.type in ("mark", "layer", "move-mark")
    
    let active-data = layers.at(current-layer)
    
    if is-jump {
      active-data.segments.push((current,))
      if mark-steps { 
        anchors.insert("j" + str(jump-counter), current)
        jump-counter += 1 
      }
    } else if not self-handling and not is-meta {
      active-data.pts.push(current)
      active-data.segments.last().push(current)
      if mark-steps { 
        anchors.insert("w" + str(step-counter), current)
        step-counter += 1 
      }
    }

    layers.insert(current-layer, active-data)
  }
  
  (
    pts: layers.at("Boundary").pts, 
    segments: layers.at("Boundary").segments, 
    anchors: anchors,
    layers: layers 
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

#let dim(from, to, offset: 2.0, label: auto, show-line: true, size:global-dim-size, mark: (start: "|", end: "|")) = {
  let v = vector.sub(to, from)
  let dist = vector.len(v)
  let angle = get-angle(v)
  let is-flipped = angle > 90deg or angle < -90deg
  
  group({
    translate(from); rotate(angle); translate((0, offset))
    
    // Toggle the line and marks
    if show-line {
      line((0, 0), (dist, 0), mark: mark, stroke: 0.25pt)
    }
    
    content((dist/2, 0), angle: if is-flipped { angle+180deg } else { angle }, {
        let txt = if label == auto { to-arch-str(dist) } else { label }
        box(fill: white, inset: 0.5pt, text(size: size, txt))
    })
  })
  
}

//Automatically adds dimension lines to the sides of the plot
#let auto-dim-plot(plot-data, offset: 1.0, sides: none, size:global-dim-size, show-line: true, mark: (start: "|", end: "|")) = {
  let pts = plot-data.pts
  let n = pts.len()
  for i in range(n) {
    if sides == none or i in sides {
      let p1 = pts.at(i)
      let p2 = pts.at(calc.rem(i + 1, n))
      
      //Check distance before attempting to draw dimension
      let d = vector.len(vector.sub(p2, p1))
      if d > 0.01 {
         dim(p1, p2, offset: offset, size: size , show-line: show-line, mark: mark)
      }
    }
  }
}



#let print-marks(trace-data, size: global-mark-size, color: blue, offset: (0.3, 0.2)) = {
  // 1. Safety check
  if type(trace-data) != dictionary or "anchors" not in trace-data { return }

  // ==========================================
  // SPATIAL GROUPING ENGINE
  // Merges marks that share the exact same physical space
  // ==========================================
  let grouped-marks = (:)
  
  for (name, pos) in trace-data.anchors {
    // Create a spatial key (rounded to 3 decimal places to catch micro-overlaps)
    let key = str(calc.round(pos.at(0), digits: 3)) + "_" + str(calc.round(pos.at(1), digits: 3))
    
    // If the key exists, add the name to the list. Otherwise, create a new entry.
    if key in grouped-marks {
      let current-entry = grouped-marks.at(key)
      current-entry.names.push(name)
      grouped-marks.insert(key, current-entry)
    } else {
      grouped-marks.insert(key, (pos: pos, names: (name,)))
    }
  }

  // ==========================================
  // RENDERING PHASE
  // ==========================================
  for (key, data) in grouped-marks {
    group({
      let pos = data.pos
      
      // Join all names sharing this coordinate with a comma
      let combined-label = data.names.join(", ")

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
        text(fill: color, size: size, weight: "bold", font: "Barlow", combined-label),
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
    let _ =pts.pop()
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

// Calculates the true geometric center (Centroid) of any closed shape
#let get-center(pts) = {
  let n = pts.len()
  // Failsafe: If it's just a line or a dot, return the first point
  if n < 3 { return pts.first() } 

  let sum-x = 0.0
  let sum-y = 0.0
  let signed-area = 0.0 

  for i in range(n) {
    let p1 = pts.at(i)
    let p2 = pts.at(calc.rem(i + 1, n))
    
    // The Cross Product
    let cross = (p1.at(0) * p2.at(1)) - (p2.at(0) * p1.at(1))
    signed-area += cross
    
    // Centroid summation
    sum-x += (p1.at(0) + p2.at(0)) * cross
    sum-y += (p1.at(1) + p2.at(1)) * cross
  }

  let final-area = signed-area / 2.0
  
  // Failsafe: If area is 0 (a perfectly flat line), fallback to a basic average
  if final-area == 0.0 {
    let cx = pts.map(p => p.at(0)).sum() / n
    let cy = pts.map(p => p.at(1)).sum() / n
    return (cx, cy)
  }

  // The final Centroid coordinates
  (sum-x / (6.0 * final-area), sum-y / (6.0 * final-area))
}

/// Automatically calculates the center and area of a specific layer and draws a label.
#let draw-layer-label(
  layer-data, name: "", show-area: true, 
  name-size: 14pt, area-size: 11pt, color: black,
  shift: (0, 0) // <-- NEW: Added shift parameter (Defaults to no shift)
) = {
  // 1. Safety check to make sure the layer is valid
  if type(layer-data) != dictionary or "pts" not in layer-data { return }
  
  let pts = layer-data.pts
  if pts.len() < 3 { return } // A shape needs at least 3 points to have an area!

  // 2. Calculate the exact center
  let center-pt = get-center(pts)
  
  // NEW: Apply the manual shift to the X and Y coordinates
  let label-x = center-pt.at(0) + shift.at(0)
  let label-y = center-pt.at(1) + shift.at(1)

  // 3. Drop the text onto the canvas at the shifted location!
  content((label-x, label-y), align(center)[
    #if name != "" {
      text(weight: "bold", size: name-size, fill: color, name)
    }
    
    // Only calculate and show the area if the toggle is true
    #if show-area {
      // Only add a line break if there is actually a name above it!
      if name != "" {
        linebreak()
        v(-2.9em)
      }
      let area-val = get-area(pts)
      text(size: area-size, fill: color, str(calc.round(area-val, digits: 2)) + [ ft²])
    }
  ])
}


// Draws the plot and places the name/area in center
#let draw-plot(
  plot-data, name: "", fill: none, stroke: (thickness:1pt, paint:black, cap:"round"), 
  show-area: false, show-dim: false, dim-offset: 1.0, 
  sides: none, area-size: global-area-size, name-size: global-name-size, 
  dim-size: global-dim-size, show-dim-line: true, 
  shift-name: (0, 0),
  name-angle: 0deg, close-path: true, show-angle:(false, false), show-markers:false, angle-radius:3, angle-label-radius:auto, angle-size:9pt, layer-styles: (:),
  custom-stroke: (), debug-mode: false, mark:(start:"|", end:"|")
) = {
  // THE FIX: Explicitly import only line and content to prevent overwriting 'stroke' and 'fill'
  import cetz.draw: line, content
  
  let pts = plot-data.pts

  // ==========================================
  // PHASE 1: DEDUPLICATION MATH
  // Find overlaps and preserve custom layer strokes
  // ==========================================
  let drawn-walls = ()
  let clean-segments = ()

  if "layers" in plot-data {
    for (l-name, l-data) in plot-data.layers {
      
      // 1. BULLETPROOF DICTIONARY CHECK
      let l-style = layer-styles.at(l-name, default: (:))
      let is-dict = type(l-style) == dictionary or type(l-style) == "dictionary"
      
      // 2. BULLETPROOF STROKE EXTRACTION
      let l-stroke = if is-dict {
        if "stroke" in l-style { l-style.stroke }        // (fill: blue, stroke: red)
        else if "fill" in l-style { stroke }             // (fill: blue) -> Fallback stroke
        else { l-style }                                 // (thickness: 2pt) -> Pure stroke dict
      } else if l-style != (:) { 
        l-style                                          // Raw color like `red`
      } else { 
        stroke                                           // Nothing found -> Global stroke
      }
      
      for (i, seg) in l-data.segments.enumerate() {
        if seg.len() > 1 {
          let do-close = if i == 0 and l-name == "Boundary" { close-path } else { false }
          
          let check-pts = seg
          if do-close and check-pts.first() != check-pts.last() { check-pts.push(check-pts.first()) }
          
          for j in range(check-pts.len() - 1) {
            let pA = check-pts.at(j)
            let pB = check-pts.at(j + 1)
            
            if not drawn-walls.contains((pA, pB)) and not drawn-walls.contains((pB, pA)) {
              drawn-walls.push((pA, pB))
              clean-segments.push((pA: pA, pB: pB, line-stroke: l-stroke))
            }
          }
        }
      }
    }
  }

  // ==========================================
  // PHASE 2: DRAW FILLS (No Strokes)
  // ==========================================
  if "layers" in plot-data {
    for (l-name, l-data) in plot-data.layers {
      
      // 1. BULLETPROOF DICTIONARY CHECK
      let l-style = layer-styles.at(l-name, default: (:))
      let is-dict = type(l-style) == dictionary or type(l-style) == "dictionary"

      for (i, seg) in l-data.segments.enumerate() {
        if seg.len() > 1 {
          let do-close = if i == 0 and l-name == "Boundary" { close-path } else { false }
          let default-fill = if i == 0 and l-name == "Boundary" { fill } else { none }
          
          // 2. BULLETPROOF FILL EXTRACTION
          let l-fill = if is-dict and "fill" in l-style { l-style.fill } else { default-fill }
          
          line(..seg, close: do-close, fill: l-fill, stroke: none)
        }
      }
    }
  }

  // ==========================================
  // PHASE 3: DRAW CLEAN WALLS
  // ==========================================
  
  // 1. Resolve any Marks in the custom-stroke list into actual coordinates
  let resolved-customs = ()
  let safe-anchors = plot-data.at("anchors", default: (:))
  
  for cw in custom-stroke {
    let p1 = if type(cw.at(0)) == str { safe-anchors.at(cw.at(0), default: cw.at(0)) } else { cw.at(0) }
    let p2 = if type(cw.at(1)) == str { safe-anchors.at(cw.at(1), default: cw.at(1)) } else { cw.at(1) }
    resolved-customs.push((pA: p1, pB: p2, stroke: cw.at(2)))
  }

  // 2. Draw the walls, checking for overrides
  for clean-seg in clean-segments {
    let final-stroke = clean-seg.line-stroke // Default to the layer style
    
    // Check if this specific segment is on our hit-list!
    for cw in resolved-customs {
      if (clean-seg.pA == cw.pA and clean-seg.pB == cw.pB) or (clean-seg.pA == cw.pB and clean-seg.pB == cw.pA) {
        final-stroke = cw.stroke // Override the stroke!
      }
    }
    
    line(clean-seg.pA, clean-seg.pB, stroke: final-stroke)
  }
   
  // ==========================================
  // PHASE 4: ANNOTATIONS (Text, Dims, Marks)
  // ==========================================
  let cx = pts.map(p => p.at(0)).sum() / pts.len()
  let cy = pts.map(p => p.at(1)).sum() / pts.len()

  
  let label-x = cx + shift-name.at(0)
  let label-y = cy + shift-name.at(1)
  
  content((label-x, label-y), angle: name-angle, align(center)[ 
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

  if show-dim {
    auto-dim-plot(plot-data, offset: dim-offset, sides: sides, size: dim-size, show-line: show-dim-line, mark: mark)
  }
  
  if show-angle.at(0) {
    auto-angle-plot(plot-data, radius: angle-radius, label-radius:angle-label-radius, size: angle-size, flip:show-angle.at(1))
  }

  if show-markers {
      print-marks(plot-data)
  }

// ==========================================
  // PHASE 5: PRO DIAGNOSTIC HUD (X-Ray Mode)
  // ==========================================
  if debug-mode {
    let step-counter = 1
    let layer-idx = 0 

    for (l-name, l-data) in plot-data.layers {
      let previous-end = none

      for seg in l-data.segments {
        if seg.len() > 0 {
          if previous-end != none and previous-end != seg.first() {
            line(previous-end, seg.first(), stroke: (thickness:0.5pt, paint:green, dash:"dashed"), mark: (end: ">", fill: green, scale: 0.9))
            let mid-x = (previous-end.at(0) + seg.first().at(0)) / 2; let mid-y = (previous-end.at(1) + seg.first().at(1)) / 2
            content((mid-x, mid-y), text(size: 5pt, fill: rgb("d95f02"), weight: "bold", [JUMP]))
          }

          if seg.len() > 1 {
            circle(seg.first(), radius: 0.25, fill: rgb("00aa00"), stroke: none) 
            for j in range(seg.len() - 1) {
              let pA = seg.at(j); let pB = seg.at(j + 1)
              let dist = calc.sqrt(calc.pow(pB.at(0) - pA.at(0), 2) + calc.pow(pB.at(1) - pA.at(1), 2))
              if dist < 0.5 and dist > 0 { line(pA, pB, stroke: 3pt + rgb("ff00ff")) }
              
              line(pA, pB, stroke: (thickness:1.0pt, paint:red, dash:"densely-dash-dotted") , mark: (end: ">", fill: red, scale: 0.8))
              let mid-x = (pA.at(0) + pB.at(0)) / 2; let mid-y = (pA.at(1) + pB.at(1)) / 2
              content((mid-x, mid-y), text(size: 9.5pt, fill: blue, weight: "bold", [[#step-counter]]))
              content(pB, text(size: 5pt, fill: luma(100), [(#calc.round(pB.at(0), digits:1), #calc.round(pB.at(1), digits:1))]), anchor: "south-west")
              step-counter += 1
            }
            circle(seg.last(), radius: 0.25, fill: red, stroke: none) 
          }
          previous-end = seg.last()
        }
      }
      
      if l-data.pts.len() > 2 {
        let xs = l-data.pts.map(p => p.at(0)); let ys = l-data.pts.map(p => p.at(1))
        let min-x = calc.min(..xs); let max-x = calc.max(..xs)
        let min-y = calc.min(..ys); let max-y = calc.max(..ys)
        let text-shift = layer-idx * 1.5 
        
        rect((min-x, min-y), (max-x, max-y), stroke: (thickness:1pt, paint:rgb("9c27b0"), dash:"dashed"))
        content((max-x, min-y - text-shift), text(size: 6pt, fill: rgb("9c27b0"), [BOUNDS: #l-name]), anchor: "south-east")
        
        let raw-area = 0
        let pts = l-data.pts
        for i in range(pts.len()) {
          let j = calc.rem(i + 1, pts.len())
          raw-area += (pts.at(i).at(0) * pts.at(j).at(1)) - (pts.at(j).at(0) * pts.at(i).at(1))
        }
        raw-area = raw-area / 2

        let winding = if raw-area >= 0 { "SOLID (CW)" } else { "HOLE (CCW)" }
        let w-color = if raw-area >= 0 { rgb("008000") } else { red } 
        let cx = xs.sum() / xs.len(); let cy = ys.sum() / ys.len()
        content((cx, cy + 2 - text-shift), text(size: 8pt, weight: "bold", fill: w-color, [#winding]))
      }
      layer-idx += 1 
    }
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
#let generate-custom-grid(p1, p2, p3, p4, widths: (), heights: (), auto-fill-x: true, auto-fill-y: true, start-idx: 1, names: ()) = {
  let generated-plots = ()
  let drawn-walls = () // The registry to track overlaps
  
  let len-bottom = get-length(p1, p2)
  let len-left = get-length(p1, p4)
  if len-bottom == 0 or len-left == 0 { return () }

  let final-widths = widths
  let used-w = widths.sum(default: 0)
  if auto-fill-x and used-w < len-bottom - 0.1 { final-widths.push(len-bottom - used-w) }

  let final-heights = heights
  let used-h = heights.sum(default: 0)
  if auto-fill-y and used-h < len-left - 0.1 { final-heights.push(len-left - used-h) }

  let u-vals = (0.0,); let current-u = 0.0
  for w in final-widths { current-u += (w / len-bottom); u-vals.push(calc.min(1.0, current-u)) }

  let v-vals = (0.0,); let current-v = 0.0
  for h in final-heights { current-v += (h / len-left); v-vals.push(calc.min(1.0, current-v)) }

  let get-pt(u, v) = {
    let lx = p1.at(0) + v * (p4.at(0) - p1.at(0)); let ly = p1.at(1) + v * (p4.at(1) - p1.at(1))
    let rx = p2.at(0) + v * (p3.at(0) - p2.at(0)); let ry = p2.at(1) + v * (p3.at(1) - p2.at(1))
    (lx + u * (rx - lx), ly + u * (ry - ly))
  }

  let count = start-idx
  let idx = 0 

  for r in range(final-heights.len()) {
    for c in range(final-widths.len()) {
      let u1 = u-vals.at(c); let u2 = u-vals.at(c + 1)
      let v1 = v-vals.at(r); let v2 = v-vals.at(r + 1)

      let c1 = get-pt(u1, v1); let c2 = get-pt(u2, v1) 
      let c3 = get-pt(u2, v2); let c4 = get-pt(u1, v2) 

      // --- NEW: Calculate Deduplicated Lines ---
      let closed-pts = (c1, c2, c3, c4, c1)
      let clean-segments = ()
      for i in range(4) {
        let pA = closed-pts.at(i); let pB = closed-pts.at(i + 1)
        if not drawn-walls.contains((pA, pB)) and not drawn-walls.contains((pB, pA)) {
          clean-segments.push((pA, pB)); drawn-walls.push((pA, pB))
        }
      }
      // -----------------------------------------

      let p = trace-plot(start: c1, (
        GoTo(c2), Mark("br"), GoTo(c3), Mark("tr"), GoTo(c4), Mark("tl"), JumpHome()
      ))
      
      // Attach the clean lines directly to the plot memory!
      p.insert("clean-lines", clean-segments)

      let raw-name = if idx < names.len() { names.at(idx) } else { str(count) }
      let safe-id = if type(raw-name) == str { raw-name } else if type(raw-name) == int { str(raw-name) } else { str(count) } 

      generated-plots.push((data: p, name: raw-name, id: safe-id))
      count += 1; idx += 1
    }
  }
  generated-plots
}

// UTILITY: DRAW GRID WITH OVERRIDES
#let draw-grid-plots(grid-data, default-props: (:), overrides: (:)) = {
  import cetz.draw: line
  
  for p in grid-data {
    let final-name = if type(p.name) == content { p.name } else { [#p.name] }
    let current-props = (name: final-name)
    
    for (k, v) in default-props { current-props.insert(k, v) }
    
    let plot-id = if "id" in p { p.id } else { str(p.name) }
    if plot-id in overrides {
      for (k, v) in overrides.at(plot-id) { current-props.insert(k, v) }
    }
    
    // --- THE "DOUBLE PASS" MAGIC ---
    
    // 1. Save the stroke you ACTUALLY wanted (or default to black)
    let user-stroke = current-props.at("stroke", default: 1pt + black)
    
    // 2. Force the main shape to have NO STROKE. 
    // This draws the fills, labels, and area perfectly without overlapping borders!
    current-props.insert("stroke", none)
    draw-plot(p.data, ..current-props)
    
    // 3. Draw the deduplicated walls right over the top using your original stroke!
    for seg in p.data.clean-lines {
      line(..seg, stroke: user-stroke)
    }
  }
}


// UTILITY: CALCULATE ANY POINT FROM A COMMAND (current point, then use any tracing command)
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
      let t = (wy * vx - wx * wy) / det
      (current.at(0) + t * dx, current.at(1) + t * dy)
    }
    
  } else if op.type == "drop-parallel" {
    let dx = op.ref2.at(0) - op.ref1.at(0); let dy = op.ref2.at(1) - op.ref1.at(1)
    let vx = op.t2.at(0) - op.t1.at(0); let vy = op.t2.at(1) - op.t1.at(1)
    let wx = current.at(0) - op.t1.at(0); let wy = current.at(1) - op.t1.at(1)
    let det = (dx * vy) - (dy * vx)
    if det == 0 { current } else {
      let t = (wy * vx - wx * wy) / det
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
    
  // ==========================================
  // UPGRADE: SMART ENGINE TRANSLATOR
  // ==========================================
  } else if "d" in op and type(op.d) == array {
    // 1. Backward Compatibility for old op.d: (x, y) arrays
    (current.at(0) + op.d.at(0), current.at(1) + op.d.at(1))

  } else if op.type == "move" or op.type == "jump" or op.type == "move-mark" or "u" in op or "d" in op or "l" in op or "r" in op or "a" in op {
    // 2. Extracts new Smart Macros (R, L, U, D, A)
    let nx = current.at(0)
    let ny = current.at(1)

    // Helper: Safely converts standard numbers, ignores strings/"int"
    let get-val(val) = {
      if type(val) == int or type(val) == float { float(val) } else { 0.0 }
    }

    if op.at("r", default: none) != none { nx += get-val(op.r) }
    if op.at("l", default: none) != none { nx -= get-val(op.l) }
    if op.at("u", default: none) != none { ny += get-val(op.u) }
    if op.at("d", default: none) != none { ny -= get-val(op.d) }
    
    let val-a = op.at("a", default: none)
    let val-dist = op.at("dist", default: none)
    if val-a != none and val-dist != none {
      let dist = get-val(val-dist)
      nx += calc.cos(val-a * 1deg) * dist
      ny += calc.sin(val-a * 1deg) * dist
    }

    (nx, ny)
  } else {
    current 
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
#let plot-summary-table(
  ..plots, 
  // Options: "none", "name", "perimeter", "area"
  sort-by: "none",
  // Options: "asc" (A-Z / Low-High), "desc" (Z-A / High-Low)
  sort-dir: "asc",
  text-size:9pt,
) = {
  let cells = ()
  let flat-plots = ()
  
  // 1. Flatten all inputs into a single list
  for item in plots.pos() {
    if type(item) == array {
      for p in item { flat-plots.push(p) }
    } else if type(item) == dictionary {
      flat-plots.push(item)
    }
  }

  // 2. Build a structured database of rows (so we can mathematically sort them!)
  let row-data = ()
  
  for (idx, p) in flat-plots.enumerate() {
    let plot-name = if "name" in p { p.name } else { "Trace " + str(idx + 1) }
    let trace-data = if "data" in p { p.data } else { p }
    
    // Default values (Using -1 so invalid plots sink to the bottom when sorted)
    let perim-val = -1.0
    let area-val = -1.0
    let perim-str = "-"
    let area-str = "-"
    
    if type(trace-data) == dictionary and "pts" in trace-data {
      let pts = trace-data.pts
      if pts.len() > 2 {
        perim-val = get-perimeter(pts)
        area-val = get-area(pts)
        
        perim-str = to-arch-str(perim-val)
        area-str = str(calc.round(area-val, digits: 2)) + " ft²"
      }
    }
    
    // Push both the raw numbers (for sorting) and strings (for display)
    row-data.push((
      raw-id: idx, // <-- NEW: A pure number representing its original creation order!
      name: str(plot-name),
      raw-perim: perim-val,
      raw-area: area-val,
      display-perim: perim-str,
      display-area: area-str
    ))
  }

  // 3. Apply the Sorting Logic!
  if sort-by == "name" or sort-by == "plot-no" {
    // Sorts purely by the integer ID (1, 2, 3... 10), ignoring the text string!
    row-data = row-data.sorted(key: r => r.raw-id) 
  } else if sort-by == "perimeter" {
    row-data = row-data.sorted(key: r => r.raw-perim)
  } else if sort-by == "area" {
    row-data = row-data.sorted(key: r => r.raw-area)
  }

  // Reverse the array if the user wants Descending (Z-A / High to Low)
  if sort-dir == "desc" and sort-by != "none" {
    row-data = row-data.rev()
  }

  // 4. Header Row
  let header(txt) = table.cell(fill: luma(230), align: center, text(weight: "bold", size: text-size, txt))
  cells.push(header("Plot No."))
  cells.push(header("Perimeter"))
  cells.push(header("Area"))
  
  // 5. Loop through the SORTED data and build the table cells
  for r in row-data {
    cells.push(align(center, text(size: text-size, r.name)))
    cells.push(align(center, text(size: text-size, r.display-perim)))
    cells.push(align(center, text(size: text-size, r.display-area)))
  }

  // 6. Render Table
  block(
    table(
      columns: (auto, auto, auto), 
      stroke: 0.5pt + black, inset: 4pt,
      ..cells
    )
  )
}