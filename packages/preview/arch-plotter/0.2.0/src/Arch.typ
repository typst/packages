#import "@preview/cetz:0.5.2"
#import cetz.draw: *
#import cetz.vector

#import "Furniture.typ": *

#import "Arch-helper.typ": *

#import "Hatches.typ" as hatch


/// A dedicated canvas wrapper for interior architecture and floor plans.
/// 
/// - scale (length): The scale of the canvas.
/// - body (content): The drawing code.
#let arch-canvas(scale: 0.5cm, body) = {
  cetz.canvas(length: scale, body,)
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


/// --- ARCHITECTURAL ELEMENTS ---


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

    rect((-width/2, -(thickness + 0.15)/2), (width/2, (thickness + 0.15)/2), fill: none, stroke: none,)

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
      rect((0, -0.05), (width, 0.05), fill: none, stroke: 1pt)

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

    rect((-width/2, -(thickness + 0.05)/1.8), (width/2, (thickness + 0.05)/1.7), fill: none, stroke: none)
    
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

    // 1. Draw the complete outer frame of the window (Added stroke: 1pt)
    rect((-width/2, -thickness/2), (width/2, thickness/2), fill: white, stroke: 1pt)
    
    // 2. Draw the internal glass panes
    let offset = thickness / 4
    line((-width/2, -offset), (width/2, -offset), stroke: 0.5pt)
    line((-width/2, offset), (width/2, offset), stroke: 0.5pt)

    // 3. Add the label
    if label != none {
      content((0, label-offset), text(size: 8pt, label))
    }
  })
}


/// Creates a highly customizable wall opening, supporting empty pass-throughs, custom frames, and various sliding or folding door styles.
/// 
/// - from (coordinate): The starting point of the wall segment.
/// - to (coordinate): The ending point of the wall segment.
/// - dist (float): Distance from the start point to the center of the opening.
/// - width (float): The total width of the doorway.
/// - style (string): Visual style. Options: "empty", "line", "rect", "cross", "sliding" (bypass), "surface-sliding" (barn door), "bifold", or "pocket".
/// - thickness (float): Wall thickness.
/// - align (string): Wall alignment logic (e.g., "center", "inner", "outer").
/// - shift (float): Vertical shift for the inner style elements.
/// - label (content, string, none): Optional text label (e.g., "Closet").
/// - label-offset (float): Distance to nudge the label from the center.
/// - stroke (stroke): The stroke style of the internal graphics ("line", "rect", "cross" styles).
/// - open (float): Door open state from 0.0 (fully closed) to 1.0 (fully open). Used for "sliding", "surface-sliding", "bifold", and "pocket".
/// - flip (boolean): Reverses the mounting side or slide direction for "surface-sliding", "bifold", and "pocket" doors.
/// - double (boolean): If true, creates a 4-panel double door splitting in the center. Only applies to the "bifold" style.
#let opening(from, to, dist, width: 3.0, style: "empty", thickness: 0.75, align: "center", shift: 0.0, label: none, label-offset: 0.8, stroke: 1pt, open: 0.5, flip: false, double: false) = {
  let v = vector.sub(to, from)
  let angle = calc.atan2(v.at(0), v.at(1))
  let pos = vector.add(from, vector.scale(vector.norm(v), dist))
  let dy = get-align-dy(align, thickness)

  group({
    translate(pos)
    rotate(angle)
    translate((0, dy))

    rect((-width/2, -(thickness + 0.01)/1.7), (width/2, (thickness + 0.01)/1.7), fill: none, stroke: none)
    
    let f = 0.05
    rect((-width/2, -thickness/2), (-width/2 + f, thickness/2), fill: none, stroke:none) 
    rect((width/2 - f, -thickness/2), (width/2, thickness/2), fill: none, stroke:none)

    if style != "empty" {
      group({
        translate((0, shift))
        
        if style == "line" {
          line((-width/2, 0), (width/2, 0), stroke: stroke)
        } 
        else if style == "rect" {
          rect((-width/2, -thickness/2), (width/2, thickness/2), stroke: stroke)
        } 
        else if style == "cross" {
          line((-width/2, -thickness/2), (width/2, thickness/2), stroke: stroke)
          line((-width/2, thickness/2), (width/2, -thickness/2), stroke: stroke)
        }
        else if style == "sliding" {
          let overlap = width * 0.05
          let panel-w = (width / 2) + overlap
          let panel-t = thickness * 0.35
          let gap = thickness * 0.05
          
          rect((-width/2 + f, gap), (-width/2 + panel-w, gap + panel-t), fill: white, stroke: 0.75pt)
          
          let shift-x = - (width/2 - overlap) * open
          rect((width/2 - panel-w + shift-x, -gap), (width/2 - f + shift-x, -gap - panel-t), fill: white, stroke: 0.75pt)
          
          line((-width/2 + f, gap + panel-t/2), (-width/2 + panel-w, gap + panel-t/2), stroke: 0.25pt + luma(150))
          line((width/2 - panel-w + shift-x, -gap - panel-t/2), (width/2 - f + shift-x, -gap - panel-t/2), stroke: 0.25pt + luma(150))
        }
        else if style == "surface-sliding" {
          line((-width/2 + f, thickness/2), (width/2 - f, thickness/2), stroke: (paint: luma(150), thickness: 0.5pt, dash: "dashed"))
          line((-width/2 + f, -thickness/2), (width/2 - f, -thickness/2), stroke: (paint: luma(150), thickness: 0.5pt, dash: "dashed"))

          let panel-w = width + (width * 0.1)  
          let panel-t = thickness * 0.35       
          let clearance = thickness * 0.1      
          
          let face-dir = if flip { -1 } else { 1 }
          let face-y = (thickness / 2 + clearance) * face-dir
          
          let shift-x = width * open
          
          line((-width/2 - 0.1, face-y), (width/2 + width + 0.1, face-y), stroke: 0.75pt)
          
          rect(
            (-panel-w/2 + shift-x, face-y), 
            (panel-w/2 + shift-x, face-y + (panel-t * face-dir)), 
            fill: white, stroke: 1pt
          )
        }
        // --- NEW BIFOLD DOOR ---
        else if style == "bifold" {
          // Faint track line in the floor
          line((-width/2 + f, 0), (width/2 - f, 0), stroke: (paint: luma(150), thickness: 0.5pt, dash: "dashed"))

          let face-dir = if flip { -1 } else { 1 }
          
          // Max angle is 80deg so the panels don't visually merge into a single flat line when fully open
          let open-angle = open * 90deg 
          let panel-t = thickness * 0.20 
          
          // Thick rounded lines simulate the physical door panels
          let p-stroke = (paint: black, thickness: panel-t, cap: "round", join: "round")

          if not double {
            // Standard 2-Panel Bifold (Folds left)
            let p-len = (width - 2*f) / 2
            let hx = -width/2 + f + p-len * calc.cos(open-angle)
            let hy = p-len * calc.sin(open-angle) * face-dir
            let ex = -width/2 + f + 2 * p-len * calc.cos(open-angle)

            // Drawing all 3 points connects them with the smooth "join: round" hinge!
            line((-width/2 + f, 0), (hx, hy), (ex, 0), stroke: p-stroke)
          } else {
            // Wide 4-Panel Double Bifold (Splits in the middle and folds outward)
            let p-len = (width - 2*f) / 4
            
            // Left pair
            let hx1 = -width/2 + f + p-len * calc.cos(open-angle)
            let hy1 = p-len * calc.sin(open-angle) * face-dir
            let ex1 = -width/2 + f + 2 * p-len * calc.cos(open-angle)
            line((-width/2 + f, 0), (hx1, hy1), (ex1, 0), stroke: p-stroke)

            // Right pair
            let hx2 = width/2 - f - p-len * calc.cos(open-angle)
            let hy2 = p-len * calc.sin(open-angle) * face-dir
            let ex2 = width/2 - f - 2 * p-len * calc.cos(open-angle)
            line((width/2 - f, 0), (hx2, hy2), (ex2, 0), stroke: p-stroke)
          }
        }// --- NEW POCKET SLIDING DOOR ---
        else if style == "pocket" {
          let panel-w = width - 2*f          // Single panel covers the whole opening
          let panel-t = thickness * 0.25     // Thin panel so it fits inside the wall
          
          let face-dir = if flip { -1 } else { 1 } // Use flip to choose which wall it slides into
          let shift-x = (width * open) * face-dir  // Slides completely into the wall
          
          // 1. Draw the hollow "pocket" cavity inside the solid wall
          let cavity-start = if flip { -width/2 + f } else { width/2 - f }
          let cavity-end = cavity-start + (width * face-dir)
          
          line((cavity-start, panel-t), (cavity-end, panel-t), stroke: 0.25pt)
          line((cavity-start, -panel-t), (cavity-end, -panel-t), stroke: 0.25pt)
          
          // 2. Draw the door panel
          // When open: 0.0, it spans the doorway. When open: 1.0, it slides into the cavity.
          rect(
            (-width/2 + f + shift-x, -panel-t/2), 
            (-width/2 + f + panel-w + shift-x, panel-t/2), 
            fill: white, stroke: 0.75pt
          )
        }
      })
    }

    if label != none {
      let actual-offset = if style == "surface-sliding" and flip { -label-offset } else { label-offset }
      content((0, actual-offset), label, anchor: "center")
    }
  })
}



/// Renders your traced walls with dynamic thickness and clean corner joins.
/// 
/// - wall-data (dictionary, array): The data returned from trace-walls.
/// - default-thickness (float): The default thickness for all walls.
/// - wall-color (color): The interior fill color of the walls.
/// - debug (bool): Turn on debug mode.
/// - wall-stroke (stroke): The stroke style applied to the wall boundaries.
/// 
/// Renders your traced walls by computing perfect mathematical Miter joints!
/// Pure Mathematical Wall Engine (Zero visual masking tricks) - MAXIMUM SPEED + EPSILON SAFE
#let draw-walls(wall-data, default-thickness: 0.75, wall-color: white, wall-stroke: 1pt + black, debug: false) = {
  let EPS = 0.005
  let EPS_SQ = 0.000025

  let walls-list = if type(wall-data) == dictionary { wall-data.walls } else { wall-data }
  let hidden-zones = if type(wall-data) == dictionary and "hidden-zones" in wall-data { wall-data.hidden-zones } else { () }
  let all-segments = ()

  for w in walls-list {
    if w.at("style", default: "wall") == "line" { continue }
    let data = get-wall-corners(w, default-thickness)
    if data.len() == 0 { continue }
    let (c1, c2, c3, c4, ..rest) = data 
    
    for (pA, pB, edge-name) in ((c1, c2, "left"), (c3, c4, "right"), (c4, c1, "start"), (c2, c3, "end")) {
      all-segments.push((
        p1: pA, p2: pB, w: w, edge: edge-name,
        min-x: calc.min(pA.at(0), pB.at(0)), max-x: calc.max(pA.at(0), pB.at(0)),
        min-y: calc.min(pA.at(1), pB.at(1)), max-y: calc.max(pA.at(1), pB.at(1))
      ))
    }
  }

  let chopped-segments = ()
  for seg in all-segments {
    let cuts = ()
    for other in all-segments {
      if seg.max-x + EPS < other.min-x or seg.min-x - EPS > other.max-x { continue }
      if seg.max-y + EPS < other.min-y or seg.min-y - EPS > other.max-y { continue }

      let pt = intersect-segments(seg.p1, seg.p2, other.p1, other.p2)
      if pt != none { cuts.push(pt) }
      if point-on-segment(other.p1, seg.p1, seg.p2) { cuts.push(other.p1) }
      if point-on-segment(other.p2, seg.p1, seg.p2) { cuts.push(other.p2) }
    }
    
    cuts = cuts.sorted(key: pt => {
      let dx = pt.at(0) - seg.p1.at(0)
      let dy = pt.at(1) - seg.p1.at(1)
      return dx*dx + dy*dy
    })
    
    let current-p = seg.p1
    for cut in cuts {
      let dx = cut.at(0) - current-p.at(0)
      let dy = cut.at(1) - current-p.at(1)
      if dx*dx + dy*dy > EPS_SQ { 
        chopped-segments.push((
          p1: current-p, p2: cut, w: seg.w, edge: seg.edge,
          min-x: calc.min(current-p.at(0), cut.at(0)), max-x: calc.max(current-p.at(0), cut.at(0)),
          min-y: calc.min(current-p.at(1), cut.at(1)), max-y: calc.max(current-p.at(1), cut.at(1))
        ))
        current-p = cut
      }
    }
    
    let dx = seg.p2.at(0) - current-p.at(0)
    let dy = seg.p2.at(1) - current-p.at(1)
    if dx*dx + dy*dy > EPS_SQ {
      chopped-segments.push((
        p1: current-p, p2: seg.p2, w: seg.w, edge: seg.edge,
        min-x: calc.min(current-p.at(0), seg.p2.at(0)), max-x: calc.max(current-p.at(0), seg.p2.at(0)),
        min-y: calc.min(current-p.at(1), seg.p2.at(1)), max-y: calc.max(current-p.at(1), seg.p2.at(1))
      ))
    }
  }

  group({
    if wall-color != none {
      for w in walls-list {
        if w.at("style", default: "wall") == "line" { continue }
        let data = get-wall-corners(w, default-thickness)
        if data.len() > 0 {
           let (c1, c2, c3, c4, ..rest) = data
           line(c1, c2, c3, c4, close: true, fill: wall-color, stroke: none)
        }
      }
    }

    let fast-walls = walls-list.map(w => {
      let data = get-wall-corners(w, default-thickness)
      if data.len() >= 4 {
        let (c1, c2, c3, c4, ..r) = data
        let xs = (c1.at(0), c2.at(0), c3.at(0), c4.at(0))
        let ys = (c1.at(1), c2.at(1), c3.at(1), c4.at(1))
        return (w: w, min-x: calc.min(..xs) - 0.1, max-x: calc.max(..xs) + 0.1, min-y: calc.min(..ys) - 0.1, max-y: calc.max(..ys) + 0.1)
      }
      return none
    }).filter(x => x != none)

    let skip-list = ()
    
    for i in range(chopped-segments.len()) {
      if skip-list.contains(i) { continue }
      let seg1 = chopped-segments.at(i)
      
      let keep-req = seg1.w.at("keep", default: ())
      let keep-list = if type(keep-req) == str { (keep-req,) } else { keep-req }
      let force-keep = keep-list.contains(seg1.edge)

      if not force-keep {
        let mid-x = (seg1.p1.at(0) + seg1.p2.at(0)) / 2
        let mid-y = (seg1.p1.at(1) + seg1.p2.at(1)) / 2
        
        let possible-walls = fast-walls.filter(fw => mid-x >= fw.min-x and mid-x <= fw.max-x and mid-y >= fw.min-y and mid-y <= fw.max-y).map(fw => fw.w)
        if possible-walls.len() > 0 and is-inside-any-wall((mid-x, mid-y), possible-walls, default-thickness) { continue }
      }

      let is-internal-duplicate = false
      for j in range(i + 1, chopped-segments.len()) {
        if skip-list.contains(j) { continue }
        let seg2 = chopped-segments.at(j)
        
        if seg1.max-x + EPS < seg2.min-x or seg1.min-x - EPS > seg2.max-x { continue }
        if seg1.max-y + EPS < seg2.min-y or seg1.min-y - EPS > seg2.max-y { continue }
        
        let d1 = calc.abs(seg1.p1.at(0) - seg2.p1.at(0)) + calc.abs(seg1.p1.at(1) - seg2.p1.at(1))
        let d2 = calc.abs(seg1.p2.at(0) - seg2.p2.at(0)) + calc.abs(seg1.p2.at(1) - seg2.p2.at(1))
        let same-dir = (d1 < EPS and d2 < EPS)

        let d3 = calc.abs(seg1.p1.at(0) - seg2.p2.at(0)) + calc.abs(seg1.p1.at(1) - seg2.p2.at(1))
        let d4 = calc.abs(seg1.p2.at(0) - seg2.p1.at(0)) + calc.abs(seg1.p2.at(1) - seg2.p1.at(1))
        let opp-dir = (d3 < EPS and d4 < EPS)
        
        if opp-dir {
          if not force-keep { is-internal-duplicate = true }
          skip-list.push(j); break 
        } else if same-dir {
          skip-list.push(j) 
        }
      }
      
      if force-keep or not is-internal-duplicate {
        let hide-req = seg1.w.at("hide", default: ())
        let hide-list = if type(hide-req) == str { (hide-req,) } else { hide-req }
        
        if not hide-list.contains(seg1.edge) {
          let is-zone-hidden = false
          let mid-x = (seg1.p1.at(0) + seg1.p2.at(0)) / 2
          let mid-y = (seg1.p1.at(1) + seg1.p2.at(1)) / 2

          for hz in hidden-zones {
            let (hx1, hy1) = hz.at(0); let (hx2, hy2) = hz.at(1)
            let dx = hx2 - hx1; let dy = hy2 - hy1
            let len-sq = dx*dx + dy*dy

            if len-sq > 0 {
              let t = ((mid-x - hx1)*dx + (mid-y - hy1)*dy) / len-sq
              if t > 0.001 and t < 0.999 {
                let proj-x = hx1 + t * dx; let proj-y = hy1 + t * dy
                let dist-sq = calc.pow(mid-x - proj-x, 2) + calc.pow(mid-y - proj-y, 2)
                let current-t = seg1.w.at("thickness", default: default-thickness)
                
                if dist-sq <= calc.pow((current-t / 2) + EPS, 2) {
                  is-zone-hidden = true; break
                }
              }
            }
          }

          if not is-zone-hidden {
            let base-stroke = seg1.w.at("stroke", default: wall-stroke)
            line(seg1.p1, seg1.p2, stroke: base-stroke)
          }
        }
      }
    }
    
    for w in walls-list {
      if w.at("style", default: "wall") == "line" {
         line(w.from, w.to, stroke: w.at("stroke", default: 1pt+black))
      }
    }
  })

  if type(wall-data) == dictionary and "components" in wall-data {
    for comp in wall-data.components {
      let a = comp.wall-align
      let t = if comp.wall-thick != auto { comp.wall-thick } else { default-thickness }
      if comp.type == "door" { door(comp.from, comp.to, comp.dist, width: comp.width, thickness: t, align: a, ..comp.args) } 
      else if comp.type == "window" { window(comp.from, comp.to, comp.dist, width: comp.width, thickness: t, align: a, ..comp.args) } 
      else if comp.type == "opening" { opening(comp.from, comp.to, comp.dist, width: comp.width, thickness: t, align: a, ..comp.args) } 
      else if comp.type == "double-door" { double-door(comp.from, comp.to, comp.dist, width: comp.width, thickness: t, align: a, ..comp.args) }
    }
  }

  // Debug starts from here
  if debug {
    let draw-pro-tag(cx, cy, c-color, title, data-dict) = {
      content((cx, cy), box(fill: rgb(255, 255, 255, 220), stroke: 0.5pt + c-color, radius: 1.5pt, clip: true)[
        #stack(dir: ttb,
          box(fill: c-color, width: 100%, inset: (x: 3pt, y: 1.5pt))[
            #align(center)[#text(size: 4.5pt, fill: white, weight: "bold", title)]
          ],
          box(inset: (x: 3pt, y: 1.5pt))[
            #let items = ()
            #for (k, v) in data-dict {
              items.push([#text(weight: "bold", fill: c-color, k): #text(fill: black, v)])
            }
            #align(center)[#text(size: 4pt, font: "Cantarell", items.join([ | ]))]
          ]
        )
      ])
    }

    for (idx, w) in walls-list.enumerate() {
      if w.at("style", default: "wall") == "line" { continue }

      let dx = w.to.at(0) - w.from.at(0); let dy = w.to.at(1) - w.from.at(1)
      let w-len = calc.round(calc.sqrt(dx*dx + dy*dy), digits: 2)
      
      let w-thick = w.at("thickness", default: default-thickness)
      let w-align = w.at("align", default: "center")
      let short-align = if w-align == "left" { "L" } else if w-align == "right" { "R" } else { "C" }

      let min-x = calc.min(w.from.at(0), w.to.at(0)) - 0.5
      let max-x = calc.max(w.from.at(0), w.to.at(0)) + 0.5
      let min-y = calc.min(w.from.at(1), w.to.at(1)) - 0.5
      let max-y = calc.max(w.from.at(1), w.to.at(1)) + 0.5
      rect((min-x, min-y), (max-x, max-y), stroke: (thickness: 0.25pt, paint: rgb("ff00ff"), dash: "dotted"))

      line(w.from, w.to, stroke: (thickness: 0.75pt, paint: red, dash: "densely-dashed"), mark: (end: ">", fill: red, scale: 0.8))

      circle(w.from, radius: 0.15, fill: rgb("aa0000"), stroke: none)
      circle(w.to, radius: 0.15, fill: red, stroke: none)
      content(w.from, text(size: 3.5pt, fill: rgb("aa0000"), [(#calc.round(w.from.at(0), digits:1), #calc.round(w.from.at(1), digits:1))]), anchor: "south-east")

      let mid-x = (w.from.at(0) + w.to.at(0)) / 2
      let mid-y = (w.from.at(1) + w.to.at(1)) / 2
      
      draw-pro-tag(
        mid-x, mid-y, 
        red, 
        "WALL " + str(idx), 
        ("L": str(w-len), "T": str(calc.round(w-thick * 12, digits: 2)) + "\"", "A": short-align)
      )
    }
  }
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
  
  // THE FIX: Intercept invalid geometry before it breaks the math!
  let safe-sides = if sides < 3 { 4 } else { sides }

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

    if safe-sides == 4 {
      rect((-size/2, -size/2), (size/2, size/2), fill: fill, stroke: none)
    } else if safe-sides >= 30 {
      circle((0,0), radius: size/2, fill: fill, stroke: none)
    } else {
      let pts = ()
      let r = (size / 2) / calc.cos(180deg / safe-sides)
      let offset = -90deg - (180deg / safe-sides) 
      
      for i in range(safe-sides) {
        let a = offset + (i * 360deg / safe-sides)
        pts.push((r * calc.cos(a), r * calc.sin(a)))
      }
      line(..pts, close: true, fill: fill, stroke: none)
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
        content((width/2+0.6, 0.4), text(size: 0.6em, fill: black, "UP"), anchor: "south")
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
#let dim(from, to, offset: 0.0, label: auto, show-line: true, size: 8pt, shift: (0,0), units: "imperial", mark: (start: "|", end: "|"), ext-lines: true) = {
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
    
    // =====================================
    // NEW: ALIGNED EXTENSION LINES
    // Draws from the dimension line back down to the shifted wall points
    // =====================================
    if ext-lines and offset != 0.0 {
      line((0, 0), (0, -offset), stroke: 0.25pt + luma(180))
      line((dist, 0), (dist, -offset), stroke: 0.25pt + luma(180))
    }
    
    if show-line {
      // THE FIX: The mark parameter is now dynamically applied here!
      line((0, 0), (dist, 0), mark: mark, stroke: 0.25pt)
    }
    
    content((dist/2, 0), angle: if is-flipped { angle+180deg } else { angle }, {
        let txt = if label == auto { format-dist(dist, unit-system: units) } else { label }
        box(fill: white, inset: 0.5pt, text(size: size, txt))
    })
  })
}

/// Creates a strictly horizontal (X-axis) dimension line.
#let dim-x(from, to, offset: 0.0, label: auto, show-line: true, size: 8pt, shift: (0,0), units: "imperial", mark: (start: "|", end: "|"), ext-lines: true) = {
  let x1 = from.at(0)
  let x2 = to.at(0)
  let y1 = from.at(1)
  let y2 = to.at(1)

  // Sort left and right coordinates
  let (left-x, right-x) = if x1 < x2 { (x1, x2) } else { (x2, x1) }
  let (left-y, right-y) = if x1 < x2 { (y1, y2) } else { (y2, y1) }

  // Apply inward shifts
  let start-x = left-x + shift.at(0)
  let end-x = right-x - shift.at(1)

  let dist = calc.abs(end-x - start-x)

  // THE SMART OFFSET: Pushes away from the highest or lowest point
  let base-y = if offset >= 0 { calc.max(y1, y2) } else { calc.min(y1, y2) }
  let y-level = base-y + offset

  // =====================================
  // THE FIX: EXACT WALL HEIGHT CALCULATION
  // Calculates the exact Y-coordinate on the wall at the shifted X-position
  // =====================================
  let dx = right-x - left-x
  let dy = right-y - left-y
  
  let wall-start-y = if calc.abs(dx) < 0.001 { left-y } else { left-y + dy * (start-x - left-x) / dx }
  let wall-end-y   = if calc.abs(dx) < 0.001 { right-y } else { left-y + dy * (end-x - left-x) / dx }

  group({
    if show-line {
      line((start-x, y-level), (end-x, y-level), mark: mark, stroke: 0.25pt)
    }

    if ext-lines and offset != 0.0 {
      // Extension lines now drop exactly to the true wall height!
      // (Also changed the stroke to match the refined 0.25pt + luma(180) from dim-y)
      line((start-x, y-level), (start-x, wall-start-y), stroke: 0.25pt + luma(180))
      line((end-x, y-level), (end-x, wall-end-y), stroke: 0.25pt + luma(180))
    }

    let mid-x = (start-x + end-x) / 2
    content((mid-x, y-level), {
        let txt = if label == auto { format-dist(dist, unit-system: units) } else { label }
        box(fill: white, inset: 0.5pt, text(size: size, txt))
    })
  })
}

/// Creates a strictly vertical (Y-axis) dimension line.
#let dim-y(from, to, offset: 0.0, label: auto, show-line: true, size: 8pt, shift: (0,0), units: "imperial", mark: (start: "|", end: "|"), ext-lines: true) = {
  let y1 = from.at(1)
  let y2 = to.at(1)

  // 1. Sort top and bottom AND track their X-coordinates!
  let (top-y, bot-y) = if y1 < y2 { (y1, y2) } else { (y2, y1) }
  let (top-x, bot-x) = if y1 < y2 { (from.at(0), to.at(0)) } else { (to.at(0), from.at(0)) }

  // 2. Apply inward shifts
  let start-y = top-y + shift.at(0)
  let end-y = bot-y - shift.at(1)

  // 3. Calculate the distance AFTER the shifts are applied
  let dist = calc.abs(end-y - start-y)

  // Anchor the X position to the 'from' point, then apply absolute offset
  let x-level = from.at(0) + offset

  group({
    if show-line {
      line((x-level, start-y), (x-level, end-y), mark: mark, stroke: 0.25pt)
    }

    // =====================================
    // THE FIX: SHIFTED EXTENSION LINES
    // Now they draw perfectly horizontally at the new start-y and end-y levels!
    // =====================================
    if ext-lines and offset != 0.0 {
      line((top-x, start-y), (x-level, start-y), stroke: 0.25pt + luma(180))
      line((bot-x, end-y), (x-level, end-y), stroke: 0.25pt + luma(180))
    }

    let mid-y = (start-y + end-y) / 2
    content((x-level, mid-y), angle: -90deg, {
        let txt = if label == auto { format-dist(dist, unit-system: units) } else { label }
        box(fill: white, inset: 0.5pt, text(size: size, txt))
    })
  })
}

/// Creates a continuous string of dimensions aligned perfectly along one axis.
/// - points: An array of coordinates e.g., (ptA, ptB, ptC)
/// - axis: "x" for horizontal chains, "y" for vertical chains.
#let dim-chain(points, axis: "x", offset: 0.0, size: 8pt, units: "imperial", mark: (start: "|", end: "|"), ext-lines: true) = {
  if points.len() < 2 { return } // Need at least two points to measure!

  // 1. Find the global boundary so the entire chain sits on one straight line
  let base-level = 0.0
  if axis == "x" {
    let ys = points.map(p => p.at(1))
    base-level = if offset >= 0 { calc.max(..ys) } else { calc.min(..ys) }
  } else {
    let xs = points.map(p => p.at(0))
    base-level = if offset >= 0 { calc.max(..xs) } else { calc.min(..xs) }
  }

  let float-level = base-level + offset

  // 2. Sort the points sequentially (Left-to-Right or Bottom-to-Top)
  let sorted-pts = points.sorted(key: p => if axis == "x" { p.at(0) } else { p.at(1) })

  group({
    for i in range(sorted-pts.len() - 1) {
      let current = sorted-pts.at(i)
      let next-pt = sorted-pts.at(i + 1)

      if axis == "x" {
        let cx = current.at(0)
        let nx = next-pt.at(0)
        let dist = calc.abs(nx - cx)
        
        // Skip 0-distance segments to prevent overlapping text
        if dist > 0.001 {
          line((cx, float-level), (nx, float-level), mark: mark, stroke: 0.25pt)

          let mid-x = (cx + nx) / 2
          content((mid-x, float-level), {
            let txt = format-dist(dist, unit-system: units)
            box(fill: white, inset: 0.5pt, text(size: size, txt))
          })
        }

        // Drop the extension lines down to the original points
        if ext-lines and offset != 0.0 {
          line((cx, float-level), current, stroke: 0.5pt + gray)
          if i == sorted-pts.len() - 2 {
             line((nx, float-level), next-pt, stroke: 0.5pt + gray)
          }
        }
      } else { // Y-Axis Logic
        let cy = current.at(1)
        let ny = next-pt.at(1)
        let dist = calc.abs(ny - cy)

        if dist > 0.001 {
          line((float-level, cy), (float-level, ny), mark: mark, stroke: 0.25pt)

          let mid-y = (cy + ny) / 2
          content((float-level, mid-y), angle: -90deg, {
            let txt = format-dist(dist, unit-system: units)
            box(fill: white, inset: 0.5pt, text(size: size, txt))
          })
        }

        if ext-lines and offset != 0.0 {
          line((float-level, cy), current, stroke: 0.5pt + gray)
          if i == sorted-pts.len() - 2 {
             line((float-level, ny), next-pt, stroke: 0.5pt + gray)
          }
        }
      }
    }
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
/// - show-border (boolean): Show the outer boundary rectangle.
/// - wall-widths (array, none): Shrink boundary inward.
/// - show-area (boolean): Show area.
/// - show-dim (boolean): Show dimensions.
/// - stroke (stroke): Line style.
/// - size (length): Text size.
/// - shift (array): Offset for the text.
/// - units (string): "imperial" or "metric".
/// - fill (color): Background fill.
#let ots(pts, name: "O.T.S", show-border: true, wall-widths: none, show-area: false, show-dim: false, stroke: 0.5pt, size: 9pt, shift: (0, 0), units: "imperial", fill: none) = {
  
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
    // NEW: Conditionally draw the outer border
    let border-stroke = if show-border { stroke } else { none }
    line(..render-pts, close: true, stroke: border-stroke, fill: fill)
    
    // The "X" Cross (Always gets the stroke)
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


/// --- ADVANCED TRACING ENGINE COMMANDS ---

/// Tracing Command: Move Right
/// - val (float, string, ratio): Distance, "anchor", auto, or percentage like 50%.
#let R(val, skip: 0, ..args) = (type: "move", r: val, skip: skip, args: args.named())

/// Tracing Command: Move Left
/// - val (float, string, ratio): Distance, "anchor", auto, or percentage like 50%.
#let L(val, skip: 0, ..args) = (type: "move", l: val, skip: skip, args: args.named())

/// Tracing Command: Move Up
/// - val (float, string, ratio): Distance, "anchor", auto, or percentage like 50%.
#let U(val, skip: 0, ..args) = (type: "move", u: val, skip: skip, args: args.named())

/// Tracing Command: Move Down
/// - val (float, string, ratio): Distance, "anchor", auto, or percentage like 50%.
#let D(val, skip: 0, ..args) = (type: "move", d: val, skip: skip, args: args.named())


/// Tracing Command: Place a Door on the LAST drawn wall
#let t-door(dist, width: 3.0, ..args) = (type: "door", dist: dist, width: width, args: args.named())

/// Tracing Command: Place a Double Door on the LAST drawn wall
#let t-double-door(dist, width: 3.0, ..args) = (
  type: "double-door", 
  dist: dist, 
  width: width, 
  args: args.named()
)

/// Tracing Command: Place a Window on the LAST drawn wall
#let t-window(dist, width: 3.0, ..args) = (type: "window", dist: dist, width: width, args: args.named())

/// Tracing Command: Place a Cased Opening on the LAST drawn wall
#let t-opening(dist, width: 3.0, ..args) = (
  type: "opening", 
  dist: dist, 
  width: width, 
  args: args.named()
)


/// Tracing Command: Move at Diagonal Angle
/// - angle (angle): Direction (e.g., 45deg).
/// - val (float, string, ratio): Distance, "anchor", auto, or percentage like 50%.
#let A(angle, val, skip: 0, ..args) = (type: "move", a: angle, dist: val, skip: skip, args: args.named())


/// Tracing Command: Drop in Y direction until intersecting the line p1-p2
#let drop-y(p1, p2, ..args) = (type: "drop-y", p1: p1, p2: p2, args: args.named())

/// Tracing Command: Drop in X direction until intersecting the line p1-p2
#let drop-x(p1, p2, ..args) = (type: "drop-x", p1: p1, p2: p2, args: args.named())

/// Tracing Command: Jump Right (Lift pen)
#let JR(val, skip: 0, ..args) = (type: "jump", r: val, skip: skip, args: args.named())

/// Tracing Command: Jump Left (Lift pen)
#let JL(val, skip: 0, ..args) = (type: "jump", l: val, skip: skip, args: args.named())

/// Tracing Command: Jump Up (Lift pen)
#let JU(val, skip: 0, ..args) = (type: "jump", u: val, skip: skip, args: args.named())

/// Tracing Command: Jump Down (Lift pen)
#let JD(val, skip: 0, ..args) = (type: "jump", d: val, skip: skip, args: args.named())

/// Tracing Command: Jump at Angle (Lift pen)
#let JA(angle, val, skip: 0, ..args) = (type: "jump", a: angle, dist: val, skip: skip, args: args.named())

/// Tracing Command: Jump drop Y (intersect without drawing)
#let j-drop-y(p1, p2) = (type: "jump-drop-y", p1: p1, p2: p2)

/// Tracing Command: Jump drop X (intersect without drawing)
#let j-drop-x(p1, p2) = (type: "jump-drop-x", p1: p1, p2: p2)

/// Tracing Command: Teleport to (0,0) relative to trace start
#let home() = (type: "home", d: (0,0))

/// Tracing Command: Save coordinate into memory
#let mark(name) = (type: "mark", name: name)

/// Tracing Command: Shoots a ray and snaps to the nearest wall intersection.
/// Set `move-cursor: true` to instantly teleport to the intersection!
#let move-mark(name, u: none, d: none, l: none, r: none, skip: 0, move-cursor: false) = (
  type: "move-mark", 
  name: name, 
  u: u, d: d, l: l, r: r, 
  skip: skip,
  move-cursor: move-cursor
)

/// Tracing Command: Draw a wall directly to a previously saved mark
#let go-to-mark(name, ..args) = (type: "go-to-mark", name: name, args: args.named())

/// Tracing Command: Lift the pen and teleport to a saved mark
#let jump-to-mark(name) = (type: "jump-to-mark", name: name)

/// Tracing Command: Lift the pen and teleport to the midpoint of two marks/coordinates
#let jump-to-mid(p1, p2) = (type: "jump-to-mid", p1: p1, p2: p2)

/// Tracing Command: Draw a wall to the midpoint of two marks/coordinates
#let go-to-mid(p1, p2, ..args) = (type: "go-to-mid", p1: p1, p2: p2, args: args.named())

/// Tracing Command: Close the boundary back to the start coordinate.
#let C(..args) = (type: "close", d: (0,0), args: args.named())

/// Tracing Command: Hide any wall boundaries that fall strictly between these two points
/// Usage: hide-between("markA", "markB")
#let hide-between(p1, p2) = (type: "hide-between", p1: p1, p2: p2)


/// Continuous tracing engine for drafting walls and boundaries.
/// Returns a dictionary with `walls` (the line data) and `anchors` (saved marks).
/// 
/// - start (coordinate): The starting position.
/// - ops (array): A list of tracing commands (R, L, U, D, Mark, etc.).
/// - ..global-args (arguments): Default parameters applied to all walls in this trace.
/// Continuous tracing engine for drafting walls and boundaries.
/// Returns a dictionary with `walls` (the line data) and `anchors` (saved marks).
/// 
/// - start (coordinate): The starting position.
/// - ops (array): A list of tracing commands (R, L, U, D, Mark, etc.).
/// - ..global-args (arguments): Default parameters applied to all walls in this trace.
#let trace-walls(start: (0,0), mark-steps: true, default-thickness:0.75, default-align: "center", ops, ..global-args) = {
  let current = start
  let last-was-draw = false
  let walls = ()
  
  // NEW: w0 only generates if mark-steps is enabled
  let anchors = (start: start) 
  if mark-steps { anchors.insert("start", start) }
  
  let raw-hidden = ()
  
  let step-counter = 1 
  let jump-counter = 1 
  
  for op in ops {
    let args = op.at("args", default: (:))
    
    if op.type == "mark" {
      anchors.insert(op.name, current)
      continue
    } else if op.type == "hide-between" {
      raw-hidden.push(op)
      continue
    }

    if op.type == "door" or op.type == "double-door" or op.type == "window" or op.type == "opening"{
      if walls.len() > 0 {
        let last-wall = walls.pop() 
        if "openings" not in last-wall { last-wall.insert("openings", ()) }
        last-wall.openings.push(op) 
        walls.push(last-wall)       
      }
      continue
    }

    // --- THE UNIVERSAL CAD RAYCASTER ---
    let raycast(cx, cy, dx, dy, skip) = {
      let hits = () 
      for w in walls {
        let ax = w.from.at(0); let ay = w.from.at(1)
        let bx = w.to.at(0);   let by = w.to.at(1)
        let vx = bx - ax; let vy = by - ay
        
        let det = dx * vy - dy * vx
        if calc.abs(det) > 0.0001 {
          let t = ((ax - cx) * vy - (ay - cy) * vx) / det
          let u = ((ax - cx) * dy - (ay - cy) * dx) / det
          if t > 0.001 and u >= -0.001 and u <= 1.001 {
            hits.push((dist: t, pt: (cx + dx * t, cy + dy * t)))
          }
        }

        let L = calc.sqrt(vx*vx + vy*vy)
        let ux = if L > 0 { vx / L } else { 0 }
        let uy = if L > 0 { vy / L } else { 0 }
        
        let nodes = ( (ax, ay), (bx, by) ) 
        for f in w.at("openings", default: ()) {
          let f-dist = float(f.at("dist", default: 0.0))
          let f-w = f.at("width", default: 3.0)
          let f-width = float(if type(f-w) == str { 3.0 } else { f-w })
          nodes.push((ax + ux * f-dist, ay + uy * f-dist)) 
          nodes.push((ax + ux * (f-dist + f-width / 2.0), ay + uy * (f-dist + f-width / 2.0))) 
          nodes.push((ax + ux * (f-dist + f-width), ay + uy * (f-dist + f-width))) 
        }

        for pt in nodes {
          let px = pt.at(0); let py = pt.at(1)
          let t = (px - cx) * dx + (py - cy) * dy
          let cross = calc.abs((px - cx) * dy - (py - cy) * dx)
          if t > 0.001 and cross <= 1.5 {
            hits.push((dist: t, pt: (cx + dx * t, cy + dy * t)))
          }
        }
      }
      
      if hits.len() > 0 {
        let sorted = hits.sorted(key: h => h.dist)
        let unique-hits = ()
        let last-pt = (-9999.0, -9999.0)
        
        for h in sorted {
          let dx = h.pt.at(0) - last-pt.at(0); let dy = h.pt.at(1) - last-pt.at(1)
          if dx*dx + dy*dy > 0.0025 { 
            unique-hits.push(h)
            last-pt = h.pt
          }
        }
        if skip < unique-hits.len() { return unique-hits.at(skip).pt } 
        else if unique-hits.len() > 0 { return unique-hits.last().pt }
      }
      return none 
    }

    let apply-dir(val, dx, dy, cur-x, cur-y, skip) = {
      if val == none { return (cur-x, cur-y) }
      if type(val) == array { return (cur-x + val.at(0), cur-y + val.at(1)) }
      
      // NEW: Anchor Snapping Logic
      if type(val) == str and val in anchors {
        let target = anchors.at(val)
        let ax = target.at(0)
        let ay = target.at(1)
        
        // Mathematically projects the target anchor onto the drawing vector
        let t-proj = (ax - cur-x) * dx + (ay - cur-y) * dy
        let dist = calc.abs(t-proj)
        
        return (cur-x + dx * dist, cur-y + dy * dist)
      }

      let t = type(val)
      // 0 and "auto" handle intersections perfectly.
      let is-auto = val == auto or val == "auto" or val == 0 or val == 0.0 or val == "0" or val == "0.0"
      let is-native-ratio = t == ratio
      let is-string-ratio = t == str and val.ends-with("%")

      if is-auto or is-native-ratio or is-string-ratio {
        let res = raycast(cur-x, cur-y, dx, dy, skip)
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
        // ==========================================
        // NEW: CRASH-PROOF SAFETY NET
        // If it's a string that wasn't a valid anchor or percentage, safely ignore it!
        // ==========================================
        if type(val) == str { return (cur-x, cur-y) }
        
        let dist = float(val)
        return (cur-x + dx * dist, cur-y + dy * dist)
      }
    }

    // --- LOGIC B: MOVEMENT DELTA CALCULATION ---
    let delta = if op.type == "home" or op.type == "close" {
      (start.at(0) - current.at(0), start.at(1) - current.at(1))
    } else if op.type == "drop-y" or op.type == "jump-drop-y" {
      let x = current.at(0)
      let p1 = if type(op.p1) == str { anchors.at(op.p1, default: (0,0)) } else { op.p1 }
      let p2 = if type(op.p2) == str { anchors.at(op.p2, default: (0,0)) } else { op.p2 }
      let (x1, y1) = p1; let (x2, y2) = p2
      let target-y = if x1 == x2 { y1 } else { y1 + (y2 - y1) * (x - x1) / (x2 - x1) }
      (0, target-y - current.at(1))
    } else if op.type == "drop-x" or op.type == "jump-drop-x" {
      let y = current.at(1)
      let p1 = if type(op.p1) == str { anchors.at(op.p1, default: (0,0)) } else { op.p1 }
      let p2 = if type(op.p2) == str { anchors.at(op.p2, default: (0,0)) } else { op.p2 }
      let (x1, y1) = p1; let (x2, y2) = p2
      let target-x = if y1 == y2 { x1 } else { x1 + (x2 - x1) * (y - y1) / (y2 - y1) }
      (target-x - current.at(0), 0)
    } else if op.type == "go-to-mark" or op.type == "jump-to-mark" {
      if op.name in anchors {
        let pt = anchors.at(op.name)
        (pt.at(0) - current.at(0), pt.at(1) - current.at(1))
      } else { (0, 0) }
    } else if op.type == "jump-to-mid" or op.type == "go-to-mid" {
      let pt1 = if type(op.p1) == str { anchors.at(op.p1, default: current) } else { op.p1 }
      let pt2 = if type(op.p2) == str { anchors.at(op.p2, default: current) } else { op.p2 }
      let mid-x = (pt1.at(0) + pt2.at(0)) / 2.0
      let mid-y = (pt1.at(1) + pt2.at(1)) / 2.0
      (mid-x - current.at(0), mid-y - current.at(1))
      
    // THE SMART ENGINE: Handles all U, D, L, R, A and Jump Commands!
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
        // Prevents angle crash if already passed as degrees
        let ang = if type(val-a) == angle { val-a } else { val-a * 1deg }
        let dir-x = calc.cos(ang); let dir-y = calc.sin(ang)
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
    } else {
      op.at("d", default: (0,0))
    }
    
    let wall-from = current
    let wall-to = (current.at(0) + delta.at(0), current.at(1) + delta.at(1))
    let is-draw = op.type == "move" or op.type == "close" or op.type == "go-to-mark" or op.type == "go-to-mid" or op.type == "drop-x" or op.type == "drop-y"
    
    if is-draw {
      let t = if "thickness" in args { args.thickness } else { default-thickness }
      let a = if "align" in args { args.align } else { default-align } // <-- ADD THIS
      let props = global-args.named() + args
      
      let current-wall = (from: wall-from, to: wall-to, thickness: t, align: a, ..props) // <-- ADD align: a
      
      // NEW: Intercept explicit skew-start and skew-end from op or args
      if "skew-start" in op and "skew-start" not in current-wall { current-wall.insert("skew-start", op.at("skew-start")) }
      if "skew-end" in op and "skew-end" not in current-wall { current-wall.insert("skew-end", op.at("skew-end")) }

      if last-was-draw and walls.len() > 0 {
        let last-idx = walls.len() - 1
        let prev-w = walls.at(last-idx)
        
        let dx1 = prev-w.to.at(0) - prev-w.from.at(0); let dy1 = prev-w.to.at(1) - prev-w.from.at(1)
        let dx2 = current-wall.to.at(0) - current-wall.from.at(0); let dy2 = current-wall.to.at(1) - current-wall.from.at(1)
        let cross = (dx1 * dy2) - (dy1 * dx2)
        
        if cross != 0 {
          let outside = if cross > 0 { "left" } else { "right" }
          let prev-a = prev-w.at("align", default: default-align) // <-- CHANGED
          let prev-t = prev-w.at("thickness", default: default-thickness)
          let curr-a = current-wall.at("align", default: default-align) // <-- CHANGED
          
          let get-meat(align, thick, out-side) = {
            if out-side == "left" {
              if align == "right" { thick } else if align == "left" { 0.0 } else { thick / 2.0 }
            } else { 
              if align == "left" { thick } else if align == "right" { 0.0 } else { thick / 2.0 }
            }
          }
          
          let push-prev = get-meat(curr-a, t, outside)
          let push-curr = get-meat(prev-a, prev-t, outside)
          
          // SKEW OVERRIDE: If the user provides a skew, turn off the automatic extension hack!
          if "ext-end" not in walls.at(last-idx) and "skew-end" not in walls.at(last-idx) { walls.at(last-idx).insert("ext-end", push-prev) }
          if "ext-start" not in current-wall and "skew-start" not in current-wall { current-wall.insert("ext-start", push-curr) }
        }
      }
      walls.push(current-wall)
      last-was-draw = true
      
      // NEW: Toggleable Step Marks
      if mark-steps {
        anchors.insert("w" + str(step-counter), wall-to)
        step-counter += 1
      }

    } else {
      last-was-draw = false
      
      if op.type == "jump" {
        // NEW: Toggleable Jump Marks
        if mark-steps {
          anchors.insert("j" + str(jump-counter), wall-to)
          jump-counter += 1
        }
      }
    }
    current = wall-to
  }
  
  let final-walls = ()
  let components = ()

  for w in walls {
    if "openings" in w {
      let current-start = w.from
      let v = vector.sub(w.to, w.from)
      let total-len = vector.len(v)
      let dir = if total-len > 0 { vector.scale(v, 1/total-len) } else { (0,0) }

      // =====================================
      // CALCULATE DISTANCES FIRST
      // Converts ratios to floats before sorting
      // =====================================
      let processed-ops = ()
      
      for o in w.openings {
        let c-dist = 0.0
        let c-cut1 = 0.0
        let c-cut2 = 0.0
        let o-width = float(o.width)

        if type(o.dist) == ratio {
          let perc = float(o.dist / 100%)
          c-dist = total-len * perc
          c-cut1 = c-dist - (o-width / 2.0)
          c-cut2 = c-dist + (o-width / 2.0)
        } else {
          c-cut1 = float(o.dist)
          c-dist = c-cut1 + (o-width / 2.0)
          c-cut2 = c-cut1 + o-width
        }

        processed-ops.push((
          orig: o, 
          cut1: calc.max(0.0, c-cut1), 
          cut2: calc.min(total-len, c-cut2), 
          center: c-dist
        ))
      }

      // SAFE SORTING
      let ops = processed-ops.sorted(key: p => p.cut1) 

      // =====================================
      // APPLY THE CUTS (WITH EXTENSION FIX)
      // =====================================
      let is-first-piece = true

      for p in ops {
        if p.cut1 >= total-len { continue }

        let cut1-pt = vector.add(w.from, vector.scale(dir, p.cut1))
        let cut2-pt = vector.add(w.from, vector.scale(dir, p.cut2))

        let part1 = w
        let _ = part1.remove("openings", default: none)
        part1.from = current-start
        part1.to = cut1-pt

        // THE FIX: Prevent corners from bleeding into the door gap!
        if not is-first-piece {
          part1.insert("ext-start", 0.0)
          let _ = part1.remove("skew-start", default: none)
        }
        part1.insert("ext-end", 0.0)
        let _ = part1.remove("skew-end", default: none)

        final-walls.push(part1)

        components.push((
          type: p.orig.type, from: w.from, to: w.to,
          dist: p.center, width: p.orig.width, args: p.orig.args,
          wall-align: w.at("align", default: default-align),
          wall-thick: w.at("thickness", default: auto)
        ))
        current-start = cut2-pt 
        is-first-piece = false
      }
      
      let part-last = w
      let _ = part-last.remove("openings", default: none)
      part-last.from = current-start
      part-last.to = w.to

      // THE FIX: The final piece starts at a door, so it cannot have an ext-start
      if not is-first-piece {
        part-last.insert("ext-start", 0.0)
        let _ = part-last.remove("skew-start", default: none)
      }

      final-walls.push(part-last)

    } else {
      final-walls.push(w) 
    }
  }

  let auto-marks = (:) 
  let auto-mark-counter = 1
  let all-segs = ()
  let pts-to-check = ()
  
  for w in final-walls {
    let t = w.at("thickness", default: default-thickness)
    if w.at("style", default: "wall") != "line" {
      let data = get-wall-corners(w, t)
      if data != none and data.len() >= 4 {
        let (c1, c2, c3, c4, ..rest) = data
        for (pA, pB) in ((c1, c2), (c2, c3), (c3, c4), (c4, c1)) {
          all-segs.push((
            p1: pA, p2: pB,
            min-x: calc.min(pA.at(0), pB.at(0)), max-x: calc.max(pA.at(0), pB.at(0)),
            min-y: calc.min(pA.at(1), pB.at(1)), max-y: calc.max(pA.at(1), pB.at(1))
          ))
        }
        pts-to-check.push(w.from); pts-to-check.push(w.to)
        pts-to-check.push(c1); pts-to-check.push(c2)
        pts-to-check.push(c3); pts-to-check.push(c4)
      }
    }
  }

  let seg-int(p1, p2, p3, p4) = {
    let (x1, y1) = p1; let (x2, y2) = p2
    let (x3, y3) = p3; let (x4, y4) = p4
    let den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if den != 0 {
      let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
      let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
      if t >= -0.005 and t <= 1.005 and u >= -0.005 and u <= 1.005 {
        return (x1 + t * (x2 - x1), y1 + t * (y2 - y1))
      }
    }
    return none
  }

  let EPS = 0.005
  let EPS_SQ = 0.000025

  for i in range(all-segs.len()) {
    let s1 = all-segs.at(i)
    for j in range(i + 1, all-segs.len()) {
      let s2 = all-segs.at(j)
      if s1.max-x + EPS < s2.min-x or s1.min-x - EPS > s2.max-x { continue }
      if s1.max-y + EPS < s2.min-y or s1.min-y - EPS > s2.max-y { continue }
      
      let pt = seg-int(s1.p1, s1.p2, s2.p1, s2.p2)
      if pt != none { pts-to-check.push(pt) }
    }
  }

  for pt in pts-to-check {
    let exists = false
    for (k, v) in anchors {
      let dx = v.at(0) - pt.at(0); let dy = v.at(1) - pt.at(1)
      if dx*dx + dy*dy < EPS_SQ { exists = true; break }
    }
    if not exists {
      for (k, v) in auto-marks {
        let dx = v.at(0) - pt.at(0); let dy = v.at(1) - pt.at(1)
        if dx*dx + dy*dy < EPS_SQ { exists = true; break }
      }
    }
    if not exists {
      while "w" + str(auto-mark-counter) in anchors { auto-mark-counter += 1 }
      auto-marks.insert("w" + str(auto-mark-counter), pt)
      auto-mark-counter += 1
    }
  }

  let hidden-zones = ()
  let all-memory = anchors + auto-marks
  for h in raw-hidden {
    let pt1 = if type(h.p1) == str { all-memory.at(h.p1, default: (0,0)) } else { h.p1 }
    let pt2 = if type(h.p2) == str { all-memory.at(h.p2, default: (0,0)) } else { h.p2 }
    hidden-zones.push((pt1, pt2))
  }

  (walls: final-walls, anchors: anchors, auto-marks: auto-marks, components: components, hidden-zones: hidden-zones)
}

// ==========================================
// 3. THE RENDERING ENGINE (VISUALS & DEBUG)
// ==========================================

/// Renders your traced walls with dynamic thickness and clean corner joins.



/// Overlays crosshairs and text labels on saved Marks for debugging.
/// Automatically groups overlapping marks into a single comma-separated label.
/// 
/// - trace-data (dictionary): The result object from trace-walls.
/// - size (length): Text size.
/// - mark-size (float): The physical size of the crosshair and circle.
/// - color (color): Label color.
/// - offset (array): X/Y shift for the label.
/// - display (string): "all", "manual", or "auto" to filter which marks to display.
#let print-marks(trace-data, size: 13pt, mark-size: 0.25, color: blue, offset: (0.3, 0.2), display: "manual", overlap: "all") = {
  if type(trace-data) != dictionary { return }

  let s = mark-size
  let ox = offset.at(0)
  let oy = offset.at(1)
  let mark-stroke = 0.5pt + color

  let dicts-to-scan = ()
  if (display == "all" or display == "manual") and "anchors" in trace-data { 
    dicts-to-scan.push(trace-data.anchors) 
  }
  if (display == "all" or display == "auto") and "auto-marks" in trace-data { 
    dicts-to-scan.push(trace-data.auto-marks) 
  }

  // ==========================================
  // SPATIAL GROUPING ENGINE
  // Merges marks that share the exact same physical space
  // ==========================================
  let grouped-marks = (:)
  
  for mark-dict in dicts-to-scan {
    for (name, pos) in mark-dict {
      // 1. Create a spatial key (rounded to 3 decimal places to catch micro-overlaps)
      let key = str(calc.round(pos.at(0), digits: 3)) + "_" + str(calc.round(pos.at(1), digits: 3))
      
      // 2. If the key exists, add the name to the list. Otherwise, create a new entry.
      if key in grouped-marks {
        let current-entry = grouped-marks.at(key)
        current-entry.names.push(name)
        grouped-marks.insert(key, current-entry)
      } else {
        grouped-marks.insert(key, (pos: pos, names: (name,)))
      }
    }
  }

  // ==========================================
  // RENDERING PHASE
  // ==========================================
  for (key, data) in grouped-marks {
    let px = data.pos.at(0)
    let py = data.pos.at(1)

    // =====================================
    // THE FIX: OVERLAP FILTER
    // =====================================
    let combined-label = if overlap == "first" {
      data.names.first()
    } else if overlap == "last" {
      data.names.last()
    } else {
      data.names.join(", ")
    }

    line((px - s, py), (px + s, py), stroke: mark-stroke)
    line((px, py - s), (px, py + s), stroke: mark-stroke)
    circle((px, py), radius: s/2, fill: none, stroke: mark-stroke)

    content(
      (px + ox, py + oy), 
      text(fill: color, size: size, weight: "bold", font: "Barlow", combined-label),
      anchor: "south-west" 
    )
  }
}


/// Draws a drafting callout (leader line with a shoulder) to point at details.
/// 
/// - target (coordinate): The exact coordinate you are pointing at.
/// - dx (int): Where the text and the shoulder line begin x axis.
/// - dy (int): Where the text and the shoulder line begin y axis.
/// - label (content, string): The text to display.
/// - shoulder (float): The length of the flat landing line.
/// - stroke (stroke): Line style.
/// - size (length): Text size.
#let callout(target, label, dx: 2.0, dy: 2.0, shoulder: 0.5, stroke: 0.5pt, size: 8pt) = {
  let (x, y) = target
  
  // Calculate text position relative to the target
  let tx = x + dx
  let ty = y + dy
  let text-pos = (tx, ty)
  
  // If dx is negative, the text is on the left, so shoulder points right (1)
  // If dx is positive, the text is on the right, so shoulder points left (-1)
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
#let drafting-grid(width, height, step: 10.0, stroke: 0.5pt + luma(220), text-size: 5pt) = {
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
              text(size: safe-text-size, fill: luma(150), "("+ lbl-x + ", " + lbl-y + ")" ),
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

/// Stamps a door and erases the wall behind it
/// - pos: (x,y) location on the curve
/// - angle: The tangent rotation of the curve at that point
/// - width: Width of the door
/// - thickness: The thickness of the wall you are erasing
#let manual-curved-door(pos, angle, width: 3, thickness: 0.75) = {
  group({
    translate(pos)
    rotate(angle)
    
    // 1. THE ERASER: A white box slightly thicker than the wall to hide the lines
    rect(
      (-width / 2, -thickness / 2 - 0.1), 
      (width / 2, thickness / 2 + 0.1), 
      fill: white, 
      stroke: none
    )
    
    // 2. THE DOOR COMPONENT
    // Draw your door geometry here! For example:
    line((-width/2, 0), (-width/2, width), stroke: 1pt + black) // Door leaf
    // (Add your standard door arcs/frames here)
  })
}


// ==========================================
// ARCHITECTURAL AUTO-DIMENSIONS (ROUTER)
// ==========================================
#let draw-auto-dims(
  anchors, 
  path: auto,          
  offset: 1.5,         
  flip: false,         
  close: false,        
  ortho: true,         
  display: auto,
  hide: auto,          // NEW: Array of dimensions to hide! e.g., (2, 5, 6)
  override: (:),
  units: "imperial",
  mark: (start: "|", end: "|"),
  size: 8pt,
  ext-lines: true,
  show-line: true,
  debug: false
) = {
  import cetz.draw: group, content

  let pts = ()
  let pt-names = () 
  
  if type(path) == array {
    for p in path {
      if type(p) == str { 
        pts.push(anchors.at(p))
        pt-names.push(p) 
      } else { 
        pts.push(p)
        pt-names.push("custom") 
      }
    }
  } else {
    for (k, v) in anchors {
      pts.push(v)
      pt-names.push(k)
    }
  }

  if close and pts.len() > 2 {
    pts.push(pts.first())
    pt-names.push(pt-names.first())
  }

  if pts.len() < 2 { return }

  group({
    for i in range(pts.len() - 1) {
      let p1 = pts.at(i)
      let p2 = pts.at(i + 1)
      
      let name1 = pt-names.at(i)
      let name2 = pt-names.at(i + 1)

      // DEBUG MODE
      if debug {
        let mid-x = (p1.at(0) + p2.at(0)) / 2
        let mid-y = (p1.at(1) + p2.at(1)) / 2
        content(
          (mid-x, mid-y), 
          box(fill: rgb(255, 255, 255, 100), inset: 2pt, radius: 2pt, stroke: 0.5pt + red)[
            #align(center)[
              #text(fill: red, size: 8pt, weight: "bold", str(i + 1)) \
              #text(fill: black, size: 4.5pt, name1 + " -> " + name2)
            ]
          ]
        )
      }

      // =====================================
      // NEW: VISIBILITY FILTERS
      // =====================================
      
      // 1. Only show these (if provided)
      if type(display) == array and not display.contains(i + 1) {
        continue
      }
      
      // 2. Hide these (if provided)
      if type(hide) == array and hide.contains(i + 1) {
        continue
      }

      let c-over = (:)
      if type(override) == dictionary {
        if str(i + 1) in override { c-over = override.at(str(i + 1)) }
      }
      
      let c-offset = c-over.at("offset", default: offset)
      let c-flip   = c-over.at("flip", default: flip)
      let c-shift  = c-over.at("shift", default: (0.0, 0.0))
      let c-ortho  = c-over.at("ortho", default: ortho)
      let c-units  = c-over.at("units", default: units)
      let c-mark   = c-over.at("mark", default: mark)
      let c-size   = c-over.at("size", default: size)
      let c-ext    = c-over.at("ext-lines", default: ext-lines)
      let c-show   = c-over.at("show-line", default: show-line)
      let c-label  = c-over.at("label", default: auto)

      let dx = p2.at(0) - p1.at(0)
      let dy = p2.at(1) - p1.at(1)
      let L = calc.sqrt(dx*dx + dy*dy)
      if L < 0.001 { continue }

      let nx = -dy / L
      let ny = dx / L
      if c-flip { nx = -nx; ny = -ny }

      if c-ortho {
        let is-horiz = calc.abs(dx) >= calc.abs(dy)
        if is-horiz {
          let push-dir = if ny >= 0 { 1 } else { -1 }
          dim-x(
            p1, p2, 
            offset: c-offset * push-dir, 
            shift: c-shift, 
            label: c-label,
            show-line: c-show,
            units: c-units, mark: c-mark, size: c-size, ext-lines: c-ext
          )
        } else {
          let push-dir = if nx >= 0 { 1 } else { -1 }
          dim-y(
            p1, p2, 
            offset: c-offset * push-dir, 
            shift: c-shift, 
            label: c-label,
            show-line: c-show,
            units: c-units, mark: c-mark, size: c-size, ext-lines: c-ext
          )
        }
      } else {
        let final-offset = if c-flip { -c-offset } else { c-offset }
        dim(
          p1, p2, 
          offset: final-offset, 
          shift: c-shift, 
          label: c-label,
          show-line: c-show,
          units: c-units, mark: c-mark, size: c-size
        )
      }
    }
  })
}



/// This function takes a 2D floor plan generated by `trace-walls` and extrudes it into a fully rotatable, 3D isometric view with translucent X-Ray sorting.
///
/// - plan (dictionary): The output dictionary from `trace-walls(...)`.
/// - height (float): The total Z-axis ceiling height of the 3D walls.
/// - wall-fill (color): The base color of the walls. (Use `.transparentize()` for X-Ray).
/// - stroke (stroke): The outline style of the 3D geometry.
/// - spin (angle): Orbits the camera around the Z-axis (Yaw). 
///   Tip: Add `180deg` to look at the back of the building!
/// - pitch (angle): Tilts the camera up/down. 
///   Tip: `35deg` = Isometric. `90deg` = Top-Down Drone View.
/// - position (array): Shifts the entire 3D drawing (X, Y) on the CeTZ canvas.
/// - scale (float): Zooms in or out of the 3D drawing.
/// - glass-color (color): The color/opacity used for "window" components.
/// - roof-lighten (ratio): How much to brighten the top flat caps of the walls.
/// - shadow-darken (ratio): How much to darken the Y-facing side walls for depth.
#let draw-3d-walls(
  plan, 
  height: 8.0, 
  wall-fill: rgb("E2E8F0").transparentize(50%), 
  stroke: 0.25pt + black, 
  spin: 45deg, 
  pitch: 35deg,
  position: (0, 0),             
  scale: 1.0,                   
  glass-color: rgb("44AAFF88"), 
  roof-lighten: 20%,            
  shadow-darken: 15%            
) = {
  import cetz.draw: group, line

  // 1. Dynamic 3D Camera Math
  let project(x, y, z) = {
    let rx = x * calc.cos(spin) - y * calc.sin(spin)
    let ry = x * calc.sin(spin) + y * calc.cos(spin)
    let px = rx
    let py = z * calc.cos(pitch) + ry * calc.sin(pitch)
    
    // Apply position and scale to the final 2D coordinates
    return (
      position.at(0) + px * scale, 
      position.at(1) + py * scale
    )
  }

  let boxes = ()

  // 2. Build 3D Geometry for standard walls
  for w in plan.walls {
    let t = w.at("thickness", default: 0.75)
    let data = get-wall-corners(w, t)
    if data == none or data.len() < 4 { continue }

    let (c1, c2, c3, c4) = (data.at(0), data.at(1), data.at(2), data.at(3))
    let cx = (w.from.at(0) + w.to.at(0)) / 2
    let cy = (w.from.at(1) + w.to.at(1)) / 2
    let depth = -(cx * calc.sin(spin) + cy * calc.cos(spin))

    boxes.push((
      depth: depth, fill: wall-fill, is-glass: false,
      b1: (c1.at(0), c1.at(1), 0.0), b2: (c2.at(0), c2.at(1), 0.0),
      b3: (c3.at(0), c3.at(1), 0.0), b4: (c4.at(0), c4.at(1), 0.0),
      t1: (c1.at(0), c1.at(1), height), t2: (c2.at(0), c2.at(1), height),
      t3: (c3.at(0), c3.at(1), height), t4: (c4.at(0), c4.at(1), height)
    ))
  }

  // =======================================================
  // 2.5 Build 3D Headers, Sills, and Glass for Components
  // =======================================================
  for comp in plan.components {
    let v-x = comp.to.at(0) - comp.from.at(0)
    let v-y = comp.to.at(1) - comp.from.at(1)
    let len = calc.sqrt(v-x*v-x + v-y*v-y)
    if len == 0 { continue }
    
    // Find exact 2D gap coordinates
    let dx = v-x / len; let dy = v-y / len
    let start-d = comp.dist - (comp.width / 2)
    let end-d = comp.dist + (comp.width / 2)
    let p1 = (comp.from.at(0) + dx * start-d, comp.from.at(1) + dy * start-d)
    let p2 = (comp.from.at(0) + dx * end-d, comp.from.at(1) + dy * end-d)

    // Reconstruct the missing gap as a perfect flat wall block
    let gap-w = (from: p1, to: p2, align: comp.wall-align, ext-start: 0.0, ext-end: 0.0)
    let t = if comp.wall-thick == auto { 0.75 } else { comp.wall-thick }
    
    let data = get-wall-corners(gap-w, t)
    if data == none or data.len() < 4 { continue }
    let (c1, c2, c3, c4) = (data.at(0), data.at(1), data.at(2), data.at(3))

    let cx = (p1.at(0) + p2.at(0)) / 2
    let cy = (p1.at(1) + p2.at(1)) / 2
    let depth = -(cx * calc.sin(spin) + cy * calc.cos(spin))

    let chunks = ()
    let c-args = comp.args

    // A. WINDOW LOGIC (Sill at bottom, Header at top, Glass in middle)
    if comp.type == "window" {
      let sill = c-args.at("sill", default: height * 0.3) 
      let head = c-args.at("head", default: height * 0.75) 
      chunks.push((z1: 0.0, z2: sill, fill: wall-fill, is-glass: false)) 
      if head < height {
        chunks.push((z1: head, z2: height, fill: wall-fill, is-glass: false)) 
      }
      chunks.push((z1: sill, z2: head, fill: glass-color, is-glass: true)) 
    } 
    // B. DOOR LOGIC (Header at top only)
    else if comp.type == "door" or comp.type == "double-door" {
      let head = c-args.at("head", default: height * 0.75) 
      if head < height { // FIX: Only build a wall above if head is lower than ceiling!
        chunks.push((z1: head, z2: height, fill: wall-fill, is-glass: false)) 
      }
    }
    // C. OPENING LOGIC (Defaults to fully open, no floating roof)
    else if comp.type == "opening" {
      let head = c-args.at("head", default: height) 
      if head < height { // FIX: A 100% height opening creates ZERO chunks, so no roof is drawn!
        chunks.push((z1: head, z2: height, fill: wall-fill, is-glass: false))
      }
    }

    // Build the 3D boxes for the chunks
    for ch in chunks {
      let box-c1 = c1; let box-c2 = c2; let box-c3 = c3; let box-c4 = c4
      // Shrink the glass pane so it is thin and sits inside the window frame!
      if ch.is-glass {
         let glass-data = get-wall-corners(gap-w, t * 0.2)
         box-c1 = glass-data.at(0); box-c2 = glass-data.at(1)
         box-c3 = glass-data.at(2); box-c4 = glass-data.at(3)
      }
      boxes.push((
        depth: depth, fill: ch.fill, is-glass: ch.is-glass,
        b1: (box-c1.at(0), box-c1.at(1), ch.z1), b2: (box-c2.at(0), box-c2.at(1), ch.z1),
        b3: (box-c3.at(0), box-c3.at(1), ch.z1), b4: (box-c4.at(0), box-c4.at(1), ch.z1),
        t1: (box-c1.at(0), box-c1.at(1), ch.z2), t2: (box-c2.at(0), box-c2.at(1), ch.z2),
        t3: (box-c3.at(0), box-c3.at(1), ch.z2), t4: (box-c4.at(0), box-c4.at(1), ch.z2)
      ))
    }
  }

  // 3. Dynamic Painter's Algorithm
  let sorted-boxes = boxes.sorted(key: b => b.depth)

  group({
    for b in sorted-boxes {
      let base-color = b.fill
      
      // Dynamic shading
      let top-color = if b.is-glass { base-color } else { base-color.lighten(roof-lighten) }
      let side1-color = base-color
      let side2-color = if b.is-glass { base-color } else { base-color.darken(shadow-darken) }

      let faces = (
        (pts: (b.b1, b.b2, b.t2, b.t1), color: side1-color),
        (pts: (b.b2, b.b3, b.t3, b.t2), color: side2-color),
        (pts: (b.b3, b.b4, b.t4, b.t3), color: side1-color),
        (pts: (b.b4, b.b1, b.t1, b.t4), color: side2-color),
      )

      let sorted-faces = faces.sorted(key: f => {
        let pA = f.pts.at(0)
        let pC = f.pts.at(2) 
        let mid-x = (pA.at(0) + pC.at(0)) / 2
        let mid-y = (pA.at(1) + pC.at(1)) / 2
        return -(mid-x * calc.sin(spin) + mid-y * calc.cos(spin))
      })

      for f in sorted-faces {
        line(project(..f.pts.at(0)), project(..f.pts.at(1)), project(..f.pts.at(2)), project(..f.pts.at(3)), close: true, fill: f.color, stroke: stroke)
      }
      
      // Draw the flat top roof last
      line(project(..b.t1), project(..b.t2), project(..b.t3), project(..b.t4), close: true, fill: top-color, stroke: stroke)
    }
  })
}