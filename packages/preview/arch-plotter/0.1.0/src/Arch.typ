#import "@preview/cetz:0.4.2"
#import cetz.draw: *
#import cetz.vector

#import "Furniture.typ": *

/// A dedicated canvas wrapper for interior architecture and floor plans.
/// 
/// - scale (length): The scale of the canvas.
/// - body (content): The drawing code.
#let arch-canvas(scale: 0.5cm, body) = {
  cetz.canvas(length: scale, body)
}

/// --- 1. UNIT HELPERS (FEET & INCHES) ---

/// Helper to convert Feet + Inches to Decimal Feet.
/// Usage: `ft(5, 6)` -> `5.5`
/// 
/// - feet (int, float): The feet value.
/// - inches (int, float): The inches value.
#let ft(feet, inches) = {
  feet + (inches / 12.0)
}

/// Converts Meters into Decimal Feet.
/// Usage: `m(2)` -> `6.561...` (Allows you to type metric into your feet-based grid)
/// 
/// - meters (float): The measurement in meters.
#let m(meters) = {
  meters / 0.3048
}

/// Converts Centimeters into Decimal Feet.
/// 
/// - centimeters (float): The measurement in centimeters.
#let cm(centimeters) = {
  centimeters / 30.48
}

/// Takes a distance in feet and formats it as text.
/// 
/// - dist-in-feet (float): The raw distance in decimal feet.
/// - unit-system (string): "metric" (m/cm) or "imperial" (feet/inches).
#let format-dist(dist-in-feet, unit-system: "imperial") = {
  if unit-system == "metric" {
    // 1. Convert the feet to meters mathematically
    let meters = dist-in-feet * 0.3048
    
    // 2. Display logic (>= 1m shows meters, < 1m shows cm)
    if meters >= 1.0 {
      str(calc.round(meters, digits: 2)) + " m"
    } else {
      str(calc.round(meters * 100, digits: 1)) + " cm"
    }
    
  } else {
    // IMPERIAL LOGIC
    let total-inches = calc.round(dist-in-feet * 12 * 4) / 4
    let feet = calc.floor(total-inches / 12)
    let rest-inches = calc.rem(total-inches, 12)
    let inch-whole = calc.floor(rest-inches)
    let quarters = calc.round((rest-inches - inch-whole) * 4) // Fixed rounding issue
    
    let fraction = if quarters == 1 { [ $1/4$] } 
      else if quarters == 2 { [ $1/2$] } 
      else if quarters == 3 { [ $3/4$] } 
      else { [] }
    
    str(feet) + "'" + str(inch-whole) + fraction + "\""
  }
}


/// --- HELPER FUNCTIONS ---

/// Internal helper: Calculate angle manually using standard Typst math
/// 
/// - v (array): The vector.
#let get-angle(v) = {
  // calc.atan2(x, y) returns the angle of the vector relative to X-axis
  calc.atan2(v.at(0), v.at(1))
}

/// Internal helper: Calculates the perpendicular shift based on alignment
/// 
/// - align (string): "left", "right", or "center"
/// - thickness (float): Wall thickness
#let get-align-dy(align, thickness) = {
  if align == "left" { thickness / 2 } 
  else if align == "right" { -thickness / 2 } 
  else { 0 }
}

/// --- ARCHITECTURAL ELEMENTS ---

/// Internal helper: Renders an individual wall segment.
#let wall-shape(from, to, thickness: 0.75, shift: 0, join: "", stroke: none, fill: black, ext-start: auto, ext-end: auto) = {
  let v = vector.sub(to, from)
  let angle = get-angle(v)
  let len = vector.len(v)

  // Extension Logic
  let actual-ext-start = if ext-start != auto { ext-start } else if join == "start" or join == "both" { thickness / 2 } else { 0 }
  let actual-ext-end   = if ext-end != auto { ext-end } else if join == "end" or join == "both" { thickness / 2 } else { 0 }

  let x-start = -actual-ext-start
  let x-end   = len + actual-ext-end

  group({
    translate(from)
    rotate(angle)
    translate((0, shift)) 

    rect(
      (x-start, -thickness/2), 
      (x-end, thickness/2), 
      stroke: stroke,
      fill: fill
    )
  })
}


/// Renders your traced walls with dynamic thickness and clean corner joins.
/// 
/// - wall-data (dictionary, array): The data returned from trace-walls.
/// - default-thickness (float): The default thickness for all walls.
/// - border-width (float): The thickness of the outer stroke lines.
/// - wall-color (color): The interior fill color of the walls.
#let draw-walls(wall-data, default-thickness: 0.75, border-width: 0.02, wall-color: white) = {
  let walls-list = if type(wall-data) == dictionary { wall-data.walls } else { wall-data }
  
  let get-shift(t, align) = {
    if align == "left" { t / 2 } 
    else if align == "right" { -t / 2 } 
    else { 0 }
  }

  // PASS 1: The Border (Skip simple lines here)
  group({
    for w in walls-list {
      if w.at("style", default: "wall") == "line" { continue }
      
      let t = w.at("thickness", default: default-thickness)
      let align = w.at("align", default: "center")
      let total-shift = w.at("shift", default: 0.0) + get-shift(t, align)
      
      let e-start = w.at("ext-start", default: auto)
      let e-end = w.at("ext-end", default: auto)
      
      wall-shape(w.from, w.to, thickness: t + (border-width * 2), shift: total-shift, join: w.at("join", default: ""), fill: black, ext-start: e-start, ext-end: e-end, stroke: (join:"bevel", cap:"round"))
    }
  })

  // PASS 2: The Fill (And drawing the simple lines)
  group({
    for w in walls-list {
      if w.at("style", default: "wall") == "line" {
        let line-stroke = w.at("stroke", default: 1pt + black)
        line(w.from, w.to, stroke: line-stroke)
        continue
      }
      
      let t = w.at("thickness", default: default-thickness)
      let align = w.at("align", default: "center")
      let total-shift = w.at("shift", default: 0.0) + get-shift(t, align)
      
      let e-start = w.at("ext-start", default: auto)
      let e-end = w.at("ext-end", default: auto)

      wall-shape(w.from, w.to, thickness: t, shift: total-shift, join: w.at("join", default: ""), fill: wall-color, ext-start: e-start, ext-end: e-end)
    }
  })
}

/// Draws an N-sided structural column.
/// 
/// - pos (coordinate): Coordinate location.
/// - size (float): Diameter or width of the column.
/// - sides (int): 4 (Square), 6 (Hexagon), 30+ (Circle).
/// - fill (color): Fill color.
/// - align (string): Alignment shift ("center", "left", "right").
/// - angle (angle): Rotation angle.
/// - shift (array, float): Manual X/Y shift.
#let column(pos, size: 0.75, sides: 4, fill: black, align: "center", angle: 0deg, shift: (0, 0)) = {
  
  let (sx, sy) = if type(shift) == array { 
    (shift.at(0), shift.at(1)) 
  } else { 
    (0, shift) 
  }

  let align-dy = if align == "left" { size / 2 } 
  else if align == "right" { -size / 2 } 
  else { 0 }
  
  let final-dx = sx
  let final-dy = align-dy + sy

  group({
    translate(pos)
    rotate(angle)
    translate((final-dx, final-dy))

    if sides == 4 {
      rect((-size/2, -size/2), (size/2, size/2), fill: fill, stroke: none)
    } else if sides >= 30 {
      circle((0,0), radius: size/2, fill: fill, stroke: none)
    } else {
      let pts = ()
      let r = (size / 2) / calc.cos(180deg / sides)
      let offset = -90deg - (180deg / sides) 
      
      for i in range(sides) {
        let a = offset + (i * 360deg / sides)
        pts.push((r * calc.cos(a), r * calc.sin(a)))
      }
      line(..pts, close: true, fill: fill, stroke: none)
    }
  })
}

/// Places a parametric single door along a wall segment.
/// 
/// - from (coordinate): The starting point of the wall segment.
/// - to (coordinate): The ending point of the wall segment.
/// - dist (float): Distance from the `from` point to the center of the door.
/// - width (float): The width of the door opening.
/// - hinge (string): Which side the hinge is on ("left" or "right").
/// - swing (string): Which way the door opens ("in" or "out").
/// - open (angle): The angle the door leaf is open.
/// - thickness (float): Thickness of the wall to match.
/// - align (string): Wall alignment logic.
/// - label (content, string, none): Optional text to display on the door.
/// - label-offset (array): An optional (X, Y) array to nudge the label.
#let door(from, to, dist, width: 3.0, hinge: "left", swing: "in", open: 90deg, thickness: 0.75, align: "center", label: none, label-offset:(0,0)) = {
  let v = vector.sub(to, from)
  let angle = calc.atan2(v.at(0), v.at(1))
  let pos = vector.add(from, vector.scale(vector.norm(v), dist))
  let dy = get-align-dy(align, thickness)

  group({
    translate(pos)
    rotate(angle)
    translate((0, dy))

    rect((-width/2, -(thickness + 0.15)/2), (width/2, (thickness + 0.15)/2), fill: white, stroke: none,)

    let f = 0.15
    rect((-width/2, -thickness/2), (-width/2 + f, thickness/2), fill: black) 
    rect((width/2 - f, -thickness/2), (width/2, thickness/2), fill: black)

    let hx = if hinge == "left" { -width/2 } else { width/2 }
    let hy = if swing == "out"  { thickness/2 } else { -thickness/2 }

    let start-angle = if hinge == "left" { 0deg } else { 180deg }
    let is-left = (hinge == "left")
    let is-out  = (swing == "out")
    let dir = if is-left == is-out { 1 } else { -1 }
    let delta = open * dir

    arc((-hx, hy), radius: width, start: start-angle, delta: delta, mode: "OPEN", stroke: (dash: "dotted", thickness: 1.5pt))

    group({
      translate((hx, hy))
      rotate(start-angle + delta)
      rect((0, -0.05), (width, 0.05), fill: white, stroke: 1pt)

      if label != none {
        content((width/2-label-offset.at(0), width/2-label-offset.at(1)), label, anchor: "center")
      }
    })
  })
}

/// Places a parametric double door along a wall segment.
/// 
/// - from (coordinate): The starting point of the wall segment.
/// - to (coordinate): The ending point of the wall segment.
/// - dist (float): Distance from the `from` point to the center of the door.
/// - width (float): The total width of the double door opening.
/// - swing (string): Which way the doors open ("in" or "out").
/// - open (angle): The angle the door leaves are open.
/// - thickness (float): Thickness of the wall to match.
/// - align (string): Wall alignment logic.
/// - label (content, string, none): Optional text to display between the leaves.
#let double-door(from, to, dist, width: 3.0, swing: "out", open: 90deg, thickness: 0.75, align: "center", label:none) = {
  let v = vector.sub(to, from)
  let angle = calc.atan2(v.at(0), v.at(1))
  let pos = vector.add(from, vector.scale(vector.norm(v), dist))
  let dy = get-align-dy(align, thickness)

  group({
    translate(pos)
    rotate(angle)
    translate((0, dy))

    rect((-width/2, -(thickness + 0.05)/1.8), (width/2, (thickness + 0.05)/1.7), fill: white, stroke: none)
    
    let f = 0.15
    rect((-width/2, -thickness/2), (-width/2 + f, thickness/2), fill: black) 
    rect((width/2 - f, -thickness/2), (width/2, thickness/2), fill: black)

    let leaf-w = width / 2
    let hy = if swing == "out" { thickness/2 } else { -thickness/2 }
    
    let hx-left = -width/2
    let dir-left = if swing == "out" { 1 } else { -1 }
    let delta-left = open * dir-left
    
    arc((-hx-left/1000, hy), radius: leaf-w, start: 0deg, delta: delta-left, mode: "OPEN", stroke: (dash: "dotted", thickness: 1pt))
    
    group({
      translate((hx-left, hy))
      rotate(0deg + delta-left)
      rect((0, -0.05), (leaf-w, 0.05), fill: white, stroke: 1pt)
    })

    let hx-right = width/2
    let dir-right = if swing == "out" { -1 } else { 1 }
    let delta-right = open * dir-right
    
    arc((-hx-right/2000, hy), radius: leaf-w, start: 180deg, delta: delta-right, mode: "OPEN", stroke: (dash: "dotted", thickness: 1pt))
    
    group({
      translate((hx-right, hy))
      rotate(180deg + delta-right)
      rect((0, -0.05), (leaf-w, 0.05), fill: white, stroke: 1pt)
    })

    if label != none {
      content((width/2-1, 0), label, anchor: "center")
    }
  })
}

/// Creates a cased opening or pass-through in a wall without a door leaf.
/// 
/// - from (coordinate): The starting point of the wall segment.
/// - to (coordinate): The ending point of the wall segment.
/// - dist (float): Distance from the start point to the center.
/// - width (float): The width of the opening.
/// - style (string): "empty", "line", "rect", or "cross".
/// - thickness (float): Wall thickness.
/// - align (string): Wall alignment logic.
/// - shift (float): Vertical shift for the inner style elements.
/// - label (content, string, none): Optional text.
/// - label-offset (float): Distance to nudge the label from center.
/// - stroke (stroke): The stroke style of the internal graphics.
#let opening(from, to, dist, width: 3.0, style: "empty", thickness: 0.75, align: "center", shift: 0.0, label: none, label-offset: 0.8, stroke: 1pt) = {
  let v = vector.sub(to, from)
  let angle = calc.atan2(v.at(0), v.at(1))
  let pos = vector.add(from, vector.scale(vector.norm(v), dist))
  let dy = get-align-dy(align, thickness)

  group({
    translate(pos)
    rotate(angle)
    translate((0, dy))

    rect((-width/2, -(thickness + 0.05)/1.7), (width/2, (thickness + 0.05)/1.7), fill: white, stroke: none)
    
    let f = 0.01
    rect((-width/2, -thickness/2), (-width/2 + f, thickness/2), fill: black) 
    rect((width/2 - f, -thickness/2), (width/2, thickness/2), fill: black)

    if style != "empty" {
      group({
        translate((0, shift))
        
        if style == "line" {
          line((-width/2, 0), (width/2, 0), stroke: stroke,)
        } 
        else if style == "rect" {
          rect((-width/2, -thickness/2), (width/2, thickness/2), stroke: stroke, )
        }else if style == "cross" {
          line((-width/2, -thickness/2), (width/2, thickness/2), stroke: stroke)
          line((-width/2, thickness/2), (width/2, -thickness/2), stroke: stroke,)
        }
      })
    }

    if label != none {
      content((0, label-offset), label, anchor: "center")
    }
  })
}

/// Places a window along a wall, drawing glass panes and erasing the wall line.
/// 
/// - wall-start (coordinate): The starting point of the wall.
/// - wall-end (coordinate): The ending point of the wall.
/// - dist (float): Distance from the start point to the center of the window.
/// - width (float): The width of the window.
/// - thickness (float): The thickness of the wall.
/// - align (string): Wall alignment logic.
/// - label (content, string, none): Optional text tag.
/// - label-offset (float): Distance to shift the label away from the glass.
#let window(wall-start, wall-end, dist, width: 1.0, thickness: 0.75, align: "center", label: none, label-offset: 0.8) = {
  let v = vector.sub(wall-end, wall-start)
  let angle = get-angle(v)
  let pos = vector.add(wall-start, vector.scale(vector.norm(v), dist))
  let dy = get-align-dy(align, thickness)

  group({
    translate(pos)
    rotate(angle)
    translate((0, dy))

    rect((-width/2, -(thickness + 0.01)/2), (width/2, (thickness + 0.01)/2), fill: white, stroke: none)
    
    line((-width/2, -thickness/2), (-width/2, thickness/2), stroke: 1pt)
    line((width/2, -thickness/2), (width/2, thickness/2), stroke: 1pt)
    
    let offset = thickness / 4
    line((-width/2, -offset), (width/2, -offset), stroke: 0.5pt)
    line((-width/2, offset), (width/2, offset), stroke: 0.5pt)

    if label != none {
      content((0, label-offset), text(size: 8pt, label))
    }
  })
}

/// Generates a parametric staircase (Straight, L-Shape, or U-Shape).
/// 
/// - pos (coordinate): The starting bottom-left coordinate.
/// - steps (int, array): Number of steps, or array for multiple runs separated by landings (e.g. `(5, 5)`).
/// - width (float): The width of the staircase.
/// - run (float): The depth of each individual tread.
/// - angle (angle): Global rotation of the entire staircase.
/// - turn (string, array): Direction the landing turns ("right" or "left").
/// - split-landing (boolean): True to draw a diagonal winder line on landings.
#let stairs(pos, steps: 12, width: 3.0, run: 0.75, angle: 0deg, turn: "right", split-landing: false) = {
  let runs = if type(steps) == array { steps } else { (steps,) }
  let turns = if type(turn) == array { turn } else { range(runs.len()).map(_ => turn) }

  group({
    translate(pos)
    rotate(angle)

    for (i, count) in runs.enumerate() {
      let is-last = (i == runs.len() - 1)
      let len = count * run
        
      for k in range(count) {
        rect((0, k*run), (width, (k+1)*run), stroke: 0.8pt)
      }

      let start-y = if i == 0 { 0 } else { -width/2 }
      let end-y = if is-last { len } else { len + width/2 }
      let mark = if is-last { (end: ">>") } else { none }
        
      line((width/2, start-y), (width/2, end-y), mark: mark, stroke: 0.8pt)
        
      if i == 0 {
        content((width/2+0.6, 0.4), text(size: 0.6em, fill: black)[UP], anchor: "south")
      }

      if not is-last {
        let current-turn = turns.at(calc.rem(i, turns.len()))
        rect((0, len), (width, len + width), stroke: 0.8pt)
          
        if split-landing {
          if current-turn == "right" {
            line((0, len + width), (width, len), stroke: 0.8pt)
          } else {
            line((0, len), (width, len + width), stroke: 0.8pt)
          }
        }
          
        let rot-dir = if current-turn == "right" { -1 } else { 1 }

        translate((width/2, len + width/2))
        rotate(90deg * rot-dir)             
        translate((-width/2, width/2))      
      }
    }
  })
}

/// Calculate the exact distance between any two coordinates.
/// 
/// - p1 (coordinate): First point.
/// - p2 (coordinate): Second point.
#let get-length(p1, p2) = {
  let dx = p2.at(0) - p1.at(0)
  let dy = p2.at(1) - p1.at(1)
  calc.sqrt((dx * dx) + (dy * dy))
}

/// Creates an external dimension line between two points.
/// 
/// - from (coordinate): Start point.
/// - to (coordinate): End point.
/// - offset (float): Distance to pull the dimension line away.
/// - label (auto, content): Optional manual label override.
/// - show-line (boolean): Show the physical line.
/// - size (length): Text size.
/// - shift (array): Array to pull the endpoints inwards (e.g. `(0.5, 0.5)`).
/// - units (string): "imperial" or "metric".
#let dim(from, to, offset: 2.0, label: auto, show-line: true, size:8pt, shift: (0,0), units:"imperial") = {
  let v-orig = vector.sub(to, from)
  let dist-orig = vector.len(v-orig)
  let u = if dist-orig != 0 { vector.scale(v-orig, 1/dist-orig) } else { (0,0) }
  
  let from = vector.add(from, vector.scale(u, shift.at(0)))
  let to   = vector.add(to, vector.scale(u, -shift.at(1)))

  let v = vector.sub(to, from)
  let dist = vector.len(v)
  let angle = get-angle(v)
  let is-flipped = angle > 90deg or angle < -90deg
  
  group({
    translate(from); rotate(angle); translate((0, offset))
    
    if show-line {
      line((0, 0), (dist, 0), mark: (start: "|", end: "|"), stroke: 0.25pt)
    }
    
    content((dist/2, 0), angle: if is-flipped { angle+180deg } else { angle }, {
        let txt = if label == auto { format-dist(dist, unit-system: units) } else { label }
        box(fill: white, inset: 0.5pt, text(size: size, txt))
    })
  })
}

/// Calculates area for a given array of vertices using the Shoelace formula.
/// 
/// - vertices (array): List of coordinates.
#let get-area(vertices) = {
  if type(vertices) != array or vertices.len() < 3 { return 0.0 }
  
  let n = vertices.len()
  let sum = 0.0
  for i in range(n) {
    let current = vertices.at(i)
    let next = vertices.at(calc.rem(i + 1, n)) 
    sum = sum + (current.at(0) * next.at(1) - next.at(0) * current.at(1))
  }
  return 0.5 * calc.abs(sum)
}

/// Formats the raw square feet into display text.
/// 
/// - sq-feet (float): The raw calculated area in square feet.
/// - unit-system (string): "imperial" or "metric".
#let format-area(sq-feet, unit-system: "imperial") = {
  if unit-system == "metric" {
    let sq-meters = sq-feet * 0.092903
    str(calc.round(sq-meters, digits: 2)) + " sq.m"
  } else {
    str(calc.round(sq-feet, digits: 2)) + " sq.ft"
  }
}

/// --- MATH HELPERS FOR INSETTING ---

/// Internal math helper to find the intersection of two vector lines.
#let intersect-lines(p1, v1, p2, v2) = {
  let det = v1.at(0) * v2.at(1) - v1.at(1) * v2.at(0)
  if calc.abs(det) < 0.0001 { return p1 } // Parallel safety
  
  let dx = p2.at(0) - p1.at(0)
  let dy = p2.at(1) - p1.at(1)
  let t = (dx * v2.at(1) - dy * v2.at(0)) / det
  
  (p1.at(0) + t * v1.at(0), p1.at(1) + t * v1.at(1))
}

/// Internal math helper to offset a polygon inward by given widths.
#let inset-polygon(pts, widths) = {
  let n = pts.len()
  let new-pts = ()
  let lines = ()
  
  for i in range(n) {
    let p-curr = pts.at(i)
    let p-next = pts.at(calc.rem(i + 1, n))
    let w = widths.at(calc.rem(i, widths.len())) 
    
    let dx = p-next.at(0) - p-curr.at(0)
    let dy = p-next.at(1) - p-curr.at(1)
    let dist = calc.sqrt(dx*dx + dy*dy)
    
    let nx = -dy / dist
    let ny = dx / dist
    
    lines.push((
      start: (p-curr.at(0) + nx*w, p-curr.at(1) + ny*w),
      dir: (dx, dy)
    ))
  }
  
  for i in range(n) {
    let l1 = lines.at(calc.rem(i - 1 + n, n))
    let l2 = lines.at(i)
    new-pts.push(intersect-lines(l1.start, l1.dir, l2.start, l2.dir))
  }
  return new-pts
}


/// Automatically generates, insets, and dimensions a multi-sided room.
/// 
/// - pts (array): An array of coordinates.
/// - name (string, content): The label for the room.
/// - wall-widths (array, none): Array of wall thicknesses to inset the boundary.
/// - show-area (boolean): Displays calculated area.
/// - show-dim (boolean): Displays Width x Height.
/// - stroke (stroke): Boundary line style.
/// - shift (array): Offset for the text label.
/// - size (length): Text size.
/// - fill (color): Room fill color.
/// - units (string): "imperial" or "metric".
#let poly-room(pts, name, wall-widths: none, show-area: true, show-dim: true, stroke: 1pt, shift: (0, 0), size:9pt, fill: luma(240).transparentize(80%), units:"imperial") = {
  
  let points = if type(pts.at(0)) == int or type(pts.at(0)) == float {
    let new-v = ()
    for i in range(0, pts.len(), step: 2) {
       if i + 1 < pts.len() { new-v.push((pts.at(i), pts.at(i+1))) }
    }
    new-v
  } else { pts }

  let render-pts = if wall-widths != none {
    inset-polygon(points, wall-widths)
  } else {
    points
  }

  let cx = 0.0; let cy = 0.0
  let min-x = render-pts.at(0).at(0); let max-x = render-pts.at(0).at(0)
  let min-y = render-pts.at(0).at(1); let max-y = render-pts.at(0).at(1)

  for p in render-pts { 
    cx += p.at(0); cy += p.at(1)
    if p.at(0) < min-x { min-x = p.at(0) }
    if p.at(0) > max-x { max-x = p.at(0) }
    if p.at(1) < min-y { min-y = p.at(1) }
    if p.at(1) > max-y { max-y = p.at(1) }
  }

  let center-base = (cx / render-pts.len(), cy / render-pts.len())
  let width = max-x - min-x
  let height = max-y - min-y

  let (sx, sy) = if type(shift) == array { 
    (shift.at(0), shift.at(1)) 
  } else { 
    (0, shift) 
  }
  let text-pos = (center-base.at(0) + sx, center-base.at(1) + sy)

  line(..render-pts, close: true, fill: fill, stroke: stroke)

  content(text-pos, align(center)[ 
    #text(weight: "bold", name) \ #v(-0.5em)
    
    #if show-dim {
      let w-str = format-dist(width, unit-system: units)
      let h-str = format-dist(height, unit-system:units)
      text(size: size, fill: black, w-str + $times$ + h-str)
      if show-area { linebreak() } 
    }
    #v(-0.7em)
    #if show-area {
      let area-val = get-area(render-pts)
      text(size: size, fill: black, format-area(area-val, unit-system: units))
    }
  ])
}

/// Takes an array of points and draws an "X" across them to denote a shaft or void.
/// 
/// - pts (array): Coordinates defining the boundary.
/// - name (string): Label.
/// - wall-widths (array, none): Shrink boundary inward.
/// - show-area (boolean): Show area.
/// - show-dim (boolean): Show dimensions.
/// - stroke (stroke): Line style.
/// - size (length): Text size.
/// - shift (array): Offset for the text.
/// - units (string): "imperial" or "metric".
/// - fill (color): Background fill.
#let ots(pts, name: "O.T.S", wall-widths: none, show-area: false, show-dim: false, stroke: 0.5pt, size: 9pt, shift: (0, 0), units: "imperial", fill: none) = {
  
  let points = if type(pts.at(0)) == int or type(pts.at(0)) == float {
    let new-v = ()
    for i in range(0, pts.len(), step: 2) {
       if i + 1 < pts.len() { new-v.push((pts.at(i), pts.at(i+1))) }
    }
    new-v
  } else { pts }

  let render-pts = if wall-widths != none {
    inset-polygon(points, wall-widths)
  } else {
    points
  }

  let min-x = render-pts.at(0).at(0); let max-x = render-pts.at(0).at(0)
  let min-y = render-pts.at(0).at(1); let max-y = render-pts.at(0).at(1)

  for p in render-pts { 
    if p.at(0) < min-x { min-x = p.at(0) }
    if p.at(0) > max-x { max-x = p.at(0) }
    if p.at(1) < min-y { min-y = p.at(1) }
    if p.at(1) > max-y { max-y = p.at(1) }
  }
  
  let cx = (min-x + max-x) / 2
  let cy = (min-y + max-y) / 2
  let width = max-x - min-x
  let height = max-y - min-y

  let (sx, sy) = if type(shift) == array { 
    (shift.at(0), shift.at(1)) 
  } else { 
    (0, shift) 
  }
  let text-pos = (cx + sx, cy + sy)

  group({
    line(..render-pts, close: true, stroke: stroke, fill: fill)
    
    if render-pts.len() == 4 {
      line(render-pts.at(0), render-pts.at(2), stroke: stroke)
      line(render-pts.at(1), render-pts.at(3), stroke: stroke)
    } else {
      line((min-x, min-y), (max-x, max-y), stroke: stroke)
      line((min-x, max-y), (max-x, min-y), stroke: stroke)
    }

    content(text-pos, box(fill: white, inset: 2pt, align(center)[ 
      #text(weight: "bold", size: size, name) 
      
      #if show-dim {
        linebreak()
        v(-2.7em)
        let w-str = format-dist(width, unit-system: units)
        let h-str = format-dist(height, unit-system: units)
        text(size: size, fill: black, w-str + $times$ + h-str)
      }
      
      #if show-area {
        linebreak()
        v(-2.7em)
        let area-val = get-area(render-pts)
        text(size: size, fill: black, format-area(area-val, unit-system: units))
      }
    ]))
  })
}


/// --- GRID SYSTEM HELPERS ---

/// GENERATE GRID: Takes a dictionary of X positions and Y positions
/// Returns a function 'get-node(x-key, y-key)'
/// 
/// - x-grids (dictionary): X coordinates.
/// - y-grids (dictionary): Y coordinates.
#let create-grid(x-grids, y-grids) = {
  return (x-key, y-key) => {
    let x = x-grids.at(x-key)
    let y = y-grids.at(y-key)
    (x, y)
  }
}

/// RELATIVE MOVER: Moves a point relative to a grid intersection
/// Usage: `rel("A-1", dx: 0.5, dy: -0.75)`
/// 
/// - pt (coordinate): Base coordinate.
/// - dx (float): X shift.
/// - dy (float): Y shift.
#let move(pt, dx: 0, dy: 0) = {
  (pt.at(0) + dx, pt.at(1) + dy)
}


/// ADVANCED INTERNAL DIMENSION HELPER
/// 
/// - from (coordinate): Start point.
/// - to (coordinate): End point.
/// - thick-start (float): How much to shrink from the 'from' point (e.g. 0.75)
/// - thick-end (float): How much to shrink from the 'to' point (e.g. 0.375)
/// - offset (float): Distance to move the dimension line sideways
/// - size (length): Text size.
#let i-dim(from, to, thick-start: 0.75, thick-end: 0.75, offset: 0, size:8pt) = {
  
  let v = vector.sub(to, from)
  let dist = vector.len(v)
  if dist == 0 { return }

  let dir = vector.scale(v, 1/dist)
  
  let start-shift = vector.scale(dir, thick-start)
  let new-from = vector.add(from, start-shift)
  
  let end-shift = vector.scale(dir, -thick-end)
  let new-to = vector.add(to, end-shift)
  
  dim(new-from, new-to, offset: offset, label: auto, size:size)
}


/// --- ADVANCED TRACING ENGINE COMMANDS ---

/// Tracing Command: Move Right
/// - len (float): Distance to move.
#let R(len, ..args) = (type: "move", d: (len, 0), args: args.named())

/// Tracing Command: Move Left
/// - len (float): Distance to move.
#let L(len, ..args) = (type: "move", d: (-len, 0), args: args.named())

/// Tracing Command: Move Up
/// - len (float): Distance to move.
#let U(len, ..args) = (type: "move", d: (0, len), args: args.named())

/// Tracing Command: Move Down
/// - len (float): Distance to move.
#let D(len, ..args) = (type: "move", d: (0, -len), args: args.named())

/// Tracing Command: Move at Angle
/// - angle (angle): Direction.
/// - len (float): Distance.
#let A(angle, len, ..args) = (type: "move", d: (
  calc.cos(angle) * len, 
  calc.sin(angle) * len
), args: args.named())

/// Tracing Command: Drop in Y direction until intersecting the line p1-p2
#let drop-y(p1, p2, ..args) = (type: "drop-y", p1: p1, p2: p2, args: args.named())

/// Tracing Command: Drop in X direction until intersecting the line p1-p2
#let drop-x(p1, p2, ..args) = (type: "drop-x", p1: p1, p2: p2, args: args.named())

/// Tracing Command: Jump Right (Lift pen)
#let JR(len) = (type: "jump", d: (len, 0))

/// Tracing Command: Jump Left (Lift pen)
#let JL(len) = (type: "jump", d: (-len, 0))

/// Tracing Command: Jump Up (Lift pen)
#let JU(len) = (type: "jump", d: (0, len))

/// Tracing Command: Jump Down (Lift pen)
#let JD(len) = (type: "jump", d: (0, -len))

/// Tracing Command: Jump at Angle (Lift pen)
#let JA(angle, len) = (type: "jump", d: (calc.cos(angle) * len, calc.sin(angle) * len))

/// Tracing Command: Jump drop Y (intersect without drawing)
#let j-drop-y(p1, p2) = (type: "jump-drop-y", p1: p1, p2: p2)

/// Tracing Command: Jump drop X (intersect without drawing)
#let j-drop-x(p1, p2) = (type: "jump-drop-x", p1: p1, p2: p2)

/// Tracing Command: Teleport to (0,0) relative to trace start
#let home() = (type: "home", d: (0,0))

/// Tracing Command: Save coordinate into memory
#let mark(name) = (type: "mark", name: name)

/// Tracing Command: Draw a wall directly to a previously saved mark
#let go-to-mark(name, ..args) = (type: "go-to-mark", name: name, args: args.named())

/// Tracing Command: Lift the pen and teleport to a saved mark
#let jump-to-mark(name) = (type: "jump-to-mark", name: name)

/// Tracing Command: Close the boundary back to the start coordinate.
#let C(..args) = (type: "close", d: (0,0), args: args.named())


/// Continuous tracing engine for drafting walls and boundaries.
/// Returns a dictionary with `walls` (the line data) and `anchors` (saved marks).
/// 
/// - start (coordinate): The starting position.
/// - ops (array): A list of tracing commands (R, L, U, D, Mark, etc.).
/// - ..global-args (arguments): Default parameters applied to all walls in this trace.
#let trace-walls(start: (0,0), ops, ..global-args) = {
  let current = start
  let walls = ()
  let anchors = (start: start) // The engine's live memory!
  
  for op in ops {
    let args = op.at("args", default: (:))
    
    // Logic A: Save the memory and skip drawing
    if op.type == "mark" {
      anchors.insert(op.name, current)
      continue
    }

    // Logic B: Calculate Movement Delta
    let delta = if op.type == "home" or op.type == "close" {
      (start.at(0) - current.at(0), start.at(1) - current.at(1))
    }else if op.type == "drop-y" or op.type == "jump-drop-y" {
      let x = current.at(0)
      
      let p1 = if type(op.p1) == str { anchors.at(op.p1, default: (0,0)) } else { op.p1 }
      let p2 = if type(op.p2) == str { anchors.at(op.p2, default: (0,0)) } else { op.p2 }
      
      let (x1, y1) = p1
      let (x2, y2) = p2
      let target-y = if x1 == x2 { y1 } else { y1 + (y2 - y1) * (x - x1) / (x2 - x1) }
      (0, target-y - current.at(1))
      
    // INTERSECTION MATH: DropX & JumpDropX
    } else if op.type == "drop-x" or op.type == "jump-drop-x" {
      let y = current.at(1)
      
      let p1 = if type(op.p1) == str { anchors.at(op.p1, default: (0,0)) } else { op.p1 }
      let p2 = if type(op.p2) == str { anchors.at(op.p2, default: (0,0)) } else { op.p2 }
      
      let (x1, y1) = p1
      let (x2, y2) = p2
      let target-x = if y1 == y2 { x1 } else { x1 + (x2 - x1) * (y - y1) / (y2 - y1) }
      (target-x - current.at(0), 0)
    } 
      
      else if op.type == "go-to-mark" or op.type == "jump-to-mark" {
      if op.name in anchors {
        let pt = anchors.at(op.name)
        (pt.at(0) - current.at(0), pt.at(1) - current.at(1))
      } else {
        (0, 0) 
      }
    } else {
      op.d
    }
    
    // Logic C: Define Segment Points
    let wall-from = current
    let wall-to = (current.at(0) + delta.at(0), current.at(1) + delta.at(1))
    
    // Logic D: Draw physical walls
    let is-draw = op.type == "move" or op.type == "close" or op.type == "go-to-mark" or op.type == "drop-x" or op.type == "drop-y"
    
    if is-draw {
      let props = global-args.named() + args
      walls.push((from: wall-from, to: wall-to, ..props))
    }
    
    // Update cursor position
    current = wall-to
  }
  
  (walls: walls, anchors: anchors)
}


/// Helper to extract an array of plain coordinates from a list of wall dictionaries.
/// 
/// - wall-list (array): Sliced array of walls.
#let get-pts(wall-list) = {
  if wall-list.len() == 0 { return () }
  let pts = (wall-list.first().from,)
  for w in wall-list {
    pts.push(w.to)
  }
  return pts
}


/// Overlays crosshairs and text labels on all saved Marks for debugging.
/// 
/// - trace-data (dictionary): The result object from trace-walls.
/// - size (length): Text size.
/// - color (color): Label color.
/// - offset (array): X/Y shift for the label.
#let print-marks(trace-data, size: 13pt, color: blue, offset: (0.3, 0.2)) = {
  if type(trace-data) != dictionary or "anchors" not in trace-data { return }

  for (name, pos) in trace-data.anchors {
    group({
      let s = 0.25 
      line(vector.add(pos, (-s, 0)), vector.add(pos, (s, 0)), stroke: 0.5pt + color)
      line(vector.add(pos, (0, -s)), vector.add(pos, (0, s)), stroke: 0.5pt + color)
      
      circle(pos, radius: s/2, fill: none, stroke: 0.5pt + color)

      let text-pos = vector.add(pos, offset)
      content(
        text-pos, 
        text(fill: color, size: size, weight: "bold", font: "Barlow", name),
        anchor: "south-west" 
      )
    })
  }
}


/// Draws a drafting callout (leader line with a shoulder) to point at details.
/// 
/// - target (coordinate): The exact coordinate you are pointing at.
/// - text-pos (coordinate): Where the text and the shoulder line begin.
/// - label (content, string): The text to display.
/// - shoulder (float): The length of the flat landing line.
/// - stroke (stroke): Line style.
/// - size (length): Text size.
#let callout(target, text-pos, label, shoulder: 2.0, stroke: 0.5pt, size: 8pt) = {
  let (tx, ty) = text-pos
  let (x, y) = target
  
  let dir = if x >= tx { 1 } else { -1 }
  let shoulder-pt = (tx + (shoulder * dir), ty)
  
  group({
    line(text-pos, shoulder-pt, target, mark: (end: ">", fill: black), stroke: stroke)
    
    let text-anchor = if dir == 1 { "south-west" } else { "south-east" }
    let nudge-y = 0.2 
    
    content(
      (tx, ty + nudge-y), 
      text(size: size, weight: "bold", label), 
      anchor: text-anchor
    )
  })
}


/// Draws a light background grid and labels every intersection.
/// 
/// - width (float): Canvas width.
/// - height (float): Canvas height.
/// - step (float): Grid spacing.
/// - stroke (stroke): Line style.
/// - text-size (length): Label text size.
#let drafting-grid(width, height, step: 5.0, stroke: 0.5pt + luma(220), text-size: 5pt) = {
  let safe-text-size = calc.max(2pt, calc.min(text-size, 8pt))

  group({
    grid((0,0), (width, height), step: step, stroke: stroke)
    
    if step >= 1.0 {
      let x-lines = int(calc.ceil(float(width) / float(step))) + 1
      let y-lines = int(calc.ceil(float(height) / float(step))) + 1

      for i in range(x-lines) {
        let current-x = i * step
        
        for j in range(y-lines) {
          let current-y = j * step
          
          if current-x <= width + 0.01 and current-y <= height + 0.01 {
            let lbl-x = str(calc.round(current-x, digits: 1))
            let lbl-y = str(calc.round(current-y, digits: 1))
            
            content(
              (current-x + 0.2, current-y + 0.2), 
              text(size: safe-text-size, fill: luma(150), lbl-x + ", " + lbl-y),
              anchor: "south-west"
            )
          }
        }
      }
    }
  })
}


/// Draws CAD-style coordinate rulers strictly on the Left and Top edges.
/// 
/// - width (float): Canvas width.
/// - height (float): Canvas height.
/// - step (float): Tick spacing.
/// - stroke (stroke): Line style.
/// - text-size (length): Label text size.
/// - tick (float): Length of the tick marks.
#let drafting-ruler(
width, height, step: 5.0, stroke: 0.5pt + black, text-size: 5pt, tick: 0.5) = {
  let safe-text-size = calc.max(2pt, calc.min(text-size, 8pt))

  group({
    if step >= 0.5 {
      let x-lines = int(calc.ceil(float(width) / float(step))) + 1
      let y-lines = int(calc.ceil(float(height) / float(step))) + 1

      line((0, 0), (0, height), stroke: stroke)
      
      for j in range(y-lines) {
        let current-y = j * step
        if current-y <= height + 0.01 {
          line((0, current-y), (-tick, current-y), stroke: stroke)
          
          let lbl = str(calc.round(current-y, digits: 1))
          content(
            (-tick - 0.2, current-y), 
            text(size: safe-text-size, fill: luma(100), lbl),
            anchor: "east" 
          )
        }
      }

      line((0, height), (width, height), stroke: stroke)
      
      for i in range(x-lines) {
        let current-x = i * step
        if current-x <= width + 0.01 {
          line((current-x, height), (current-x, height + tick), stroke: stroke)
          
          let lbl = str(calc.round(current-x, digits: 1))
          content(
            (current-x, height + tick + 0.2), 
            text(size: safe-text-size, fill: luma(100), lbl),
            anchor: "south" 
          )
        }
      }
    }
  })
}


/// Built-in material hatch pattern: Bricks
#let bricks-fill = tiling(size: (40pt, 20pt))[
  #let stroke-style = 0.6pt 
  #std.place(std.line(start: (0pt, 0pt), end: (40pt, 0pt), stroke: stroke-style))
  #std.place(std.line(start: (0pt, 10pt), end: (40pt, 10pt), stroke: stroke-style))
  #std.place(std.line(start: (0pt, 0pt), end: (0pt, 10pt), stroke: stroke-style))
  #std.place(std.line(start: (20pt, 10pt), end: (20pt, 20pt), stroke: stroke-style))
]

/// Built-in material hatch pattern: Diagonal Lines
#let hatch-fill = tiling(size: (10pt, 10pt))[
  #std.line(start: (0pt, 0pt), end: (10pt, 10pt), stroke: 0.5pt + black)
]

/// Built-in material hatch pattern: Grass
#let grass-fill = tiling(size: (5pt, 8pt))[
  #std.rotate(270deg)[
  #text(fill: green)[#sym.prec]]
]
