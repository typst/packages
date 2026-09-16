#import "@preview/cetz:0.5.2": canvas, draw
#import draw: rect, circle, line, bezier, content, group

#import "themes.typ": themes

// ============================================================================
// section 1: theme
// ============================================================================

// resolves and extracts the active theme array mapping with default theme set to default-green
#let resolve-theme-palette(theme-name, adjust-theme: (:)) = {
  let base-palette = themes.at(theme-name, default: themes.at("default-green"))
  let palette = base-palette + adjust-theme
  return (
    palette.at("bg"),
    palette.at("dark-tri"),
    palette.at("light-tri"),
    palette.at("text"),
    palette.at("bar"),
    palette.at("border"),
    palette.at("light-checker"),
    palette.at("light-border"),
    palette.at("dark-checker"),
    palette.at("dark-border"),
    palette.at("cube-bg"),
    palette.at("cube-text"),
    palette.at("arrow"),
    palette.at("font")
  )
}

// ============================================================================
// section 2: pip count and analytics mathematical engine
// ============================================================================

/// evaluates structural checker arrays to calculate the total pip count for both players
#let calculate-pips(checkers, bar-light, bar-dark, base-light, base-dark, ace-point: "light") = {
  let light-total = if base-light >= 15 { 0 } else {
    let total = bar-light * 25
    for i in range(24) {
      let count = checkers.at(i)
      if count > 0 { 
        let distance = if ace-point == "dark" { 24 - i } else { i + 1 }
        total += (count * distance)
      }
    }
    total
  }

  let dark-total = if base-dark >= 15 { 0 } else {
    let total = bar-dark * 25
    for i in range(24) {
      let count = checkers.at(i)
      if count < 0 { 
        let distance = if ace-point == "dark" { i + 1 } else { 24 - i }
        total += (calc.abs(count) * distance)
      }
    }
    total
  }

  return (light: light-total, dark: dark-total)
}

/// negates all layout array integers to swap checker ownership colours and invert board seating perspectives
#let swap-players(checkers) = {
  return checkers.map(count => -count)
}

// ============================================================================
// section 3: checkers and dice
// ============================================================================

/// draws a single vertical stack of checkers on a point handles maximum visual height limits and numbers overflow counters
#let draw-point-checkers(x, cy-start, count, direction, radius, diameter, show-bg, scale, ch-light, ch-dark, colour-ch-light-border, colour-ch-dark-border, colour-bg, mono-font) = {
  group({
    let is-light = count > 0
    let fill = if is-light { ch-light } else { ch-dark }
    let stroke-colour = if is-light { colour-ch-light-border } else { colour-ch-dark-border }
    let stroke = (1pt * scale) + stroke-colour
    
    // fixed: removed the show-bg check. numbers inside white checkers are now consistently black
    let text-col = if is-light { black } else { ch-light }
    let abs-count = calc.abs(count)
    
    for k in range(calc.min(abs-count, 5)) {
      let cx = x
      let cy = cy-start + direction * (k * diameter)
      circle((cx, cy), radius: radius - 0.015, fill: fill, stroke: stroke)
      
      if abs-count > 5 and k == 4 { 
        content((cx, cy), text(font: mono-font, fill: text-col, weight: "bold", size: 9pt * scale, str(abs-count))) 
      }
    }
  })
}

/// draws a short stack of checkers trapped on the bar column clamping the visual layout height to three pieces
#let draw-bar-checkers(x, cy-start, count, direction, radius, diameter, show-bg, scale, ch-light, ch-dark, colour-ch-light-border, colour-ch-dark-border, colour-bg, mono-font) = {
  group({
    let is-light = count > 0
    let fill = if is-light { ch-light } else { ch-dark }
    let stroke-colour = if is-light { colour-ch-light-border } else { colour-ch-dark-border }
    let stroke = (1pt * scale) + stroke-colour
    
    // fixed: removed the show-bg check. numbers inside white checkers are now consistently black
    let text-col = if is-light { black } else { ch-light }
    let abs-count = calc.abs(count)
    
    for k in range(calc.min(abs-count, 3)) {
      let cx = x
      let cy = cy-start + direction * (k * diameter)
      circle((cx, cy), radius: radius - 0.015, fill: fill, stroke: stroke)
      
      if abs-count > 3 and k == 2 { 
        content((cx, cy), text(font: mono-font, fill: text-col, weight: "bold", size: 9pt * scale, str(abs-count))) 
      }
    }
  })
}


/// renders a single round dot on a die face at the specified canvas coordinates
#let draw-pip(cx, cy, r, fill-col) = {
  circle((cx, cy), radius: r, fill: fill-col, stroke: none)
}

/// draws the active dice block faces and plots individual pip dots based on player turn states
#let draw-dice-blocks(dice, turn, board-h, bar-x2, show-bg, scale, ch-light, ch-dark, colour-bg, colour-text, swap-colours) = {
  group({
    let sorted-dice = dice.sorted().rev()
    let active-turn = if swap-colours {
      if turn == "light" { "dark" } else { "light" }
    } else { turn }
    
    let (dice-bg, dice-pip) = if active-turn == "light" { 
      (ch-light, ch-dark) 
    } else { 
      (ch-dark, ch-light) 
    }
    
    let die-size = 0.70
    let die-y = board-h / 2 - die-size / 2
    let dice-starts = (bar-x2 + 1.2, bar-x2 + 1.2 + die-size + 0.15)
    
    for (idx, val) in sorted-dice.enumerate() {
      let dx = dice-starts.at(idx)
      rect((dx, die-y), (dx + die-size, die-y + die-size), fill: dice-bg, stroke: (1pt * scale) + dice-pip, radius: 0.08)
      let mcx = dx + die-size / 2
      let mcy = die-y + die-size / 2
      let offset = die-size * 0.25
      let pr = 0.045 
      
      // plots internal pip dots according to standard six-sided dice matrix rules
      if calc.odd(val) { draw-pip(mcx, mcy, pr, dice-pip) }
      if val >= 2 { 
        draw-pip(mcx - offset, mcy - offset, pr, dice-pip)
        draw-pip(mcx + offset, mcy + offset, pr, dice-pip)
      }
      if val >= 4 { 
        draw-pip(mcx - offset, mcy + offset, pr, dice-pip)
        draw-pip(mcx + offset, mcy - offset, pr, dice-pip)
      }
      if val == 6 { 
        draw-pip(mcx - offset, mcy, pr, dice-pip)
        draw-pip(mcx + offset, mcy, pr, dice-pip)
      }
    }
  })
}

/// draws doubling cube and positions it vertically based on ownership status
#let draw-doubling-cube(cube, board-w, board-h, scale, cube-bg, cube-text, colour-border, mono-font) = {
  let val-str = str(cube.at("value", default: 1))
  let owner = cube.at("owner", default: none)
  
  let cube-size = 0.45
  let cx = board-w / 2
  let cy = 0.0
  
  // calculates vertical layout coordinates depending on active match ownership tracks
  if owner == none {
    cy = board-h / 2
  } else if owner == "light" {
    cy = -0.4
  } else {
    cy = board-h + 0.4
  }
  
  let elements = (
    rect(
      (cx - cube-size / 2, cy - cube-size / 2),
      (cx + cube-size / 2, cy + cube-size / 2),
      fill: cube-bg,
      stroke: (paint: colour-border, thickness: 1pt * scale),
      radius: 0.04
    ),
    content(
      (cx, cy),
      text(font: mono-font, size: 8.5pt * scale, weight: "bold", fill: cube-text, val-str)
    )
  )
  return elements
}

/// constructs the side tray bars to position borne-off checkers
/// constructs the side tray bars to position borne-off checkers adaptively based on home board seating layouts
#let draw-borne-off-trays(
  base-light, base-dark, swap-colours, scale, get-point-xy, ch-light, ch-dark, 
  colour-ch-light-border, colour-ch-dark-border, show-tray-borders, tray-checker-size,
  ace-point
) = {
  let elements = ()
  let slat-w = 0.24 
  let stroke-thickness = if show-tray-borders { 1pt * scale } else { 0pt }

  let slat-h = 0.30 + (tray-checker-size * 0.38)
  let row-pitch = 0.36 + (tray-checker-size * 0.41)

  let light-is-bottom = (ace-point == "light")
  let top-tray-count = if light-is-bottom { base-dark } else { base-light }
  let top-tray-fill = if light-is-bottom { if swap-colours { ch-light } else { ch-dark } } else { if swap-colours { ch-dark } else { ch-light } }
  let top-tray-stroke = if light-is-bottom { if swap-colours { colour-ch-light-border } else { colour-ch-dark-border } } else { if swap-colours { colour-ch-dark-border } else { colour-ch-light-border } }

  let bot-tray-count = if light-is-bottom { base-light } else { base-dark }
  let bot-tray-fill = if light-is-bottom { if swap-colours { ch-dark } else { ch-light } } else { if swap-colours { ch-light } else { ch-dark } }
  let bot-tray-stroke = if light-is-bottom { if swap-colours { colour-ch-dark-border } else { colour-ch-light-border } } else { if swap-colours { colour-ch-light-border } else { colour-ch-dark-border } }

  // render completely borne off tokens in the top right side slab trays (point index 25)
  if top-tray-count > 0 {
    for k in range(top-tray-count) {
      let row = calc.floor(k / 3)
      let cx = get-point-xy(25, k, true).at(0) 
      let dynamic-cy = 11 * 0.80 - slat-h / 2 - (row * row-pitch)
      elements.push(rect(
        (cx - slat-w / 2, dynamic-cy - slat-h / 2), 
        (cx + slat-w / 2, dynamic-cy + slat-h / 2), 
        fill: top-tray-fill, 
        stroke: (paint: top-tray-stroke, thickness: stroke-thickness)
      ))
    }
  }

  // render completely borne off tokens in the bottom right side slab trays (point index 0)
  if bot-tray-count > 0 {
    for k in range(bot-tray-count) {
      let row = calc.floor(k / 3)
      let cx = get-point-xy(0, k, true).at(0) 
      let dynamic-cy = slat-h / 2 + (row * row-pitch)
      elements.push(rect(
        (cx - slat-w / 2, dynamic-cy - slat-h / 2), 
        (cx + slat-w / 2, dynamic-cy + slat-h / 2), 
        fill: bot-tray-fill, 
        stroke: (paint: bot-tray-stroke, thickness: stroke-thickness)
      ))
    }
  }
  return elements
}

// ============================================================================
// section 4: vector core components rendering blocks
// ============================================================================

/// draws the main background, border and central bar
#let draw-board-frame(
  left-ext, right-ext, top-margin, bot-margin, board-h, bar-x1, bar-x2, show-bg, show-border, scale,
  colour-bg, colour-border, colour-bar, rounded
) = {
  let elements = ()
  // rounded corners or sharp corners based on user toggle
  let rect-radius = if rounded { 0.2 } else { 0.0 }
  
  // solid background behind all components
  if show-bg { 
    elements.push(rect((left-ext, -bot-margin), (right-ext, board-h + top-margin), fill: colour-bg, stroke: none, radius: rect-radius)) 
  }

  // outer border line
  if show-border {
    elements.push(rect((left-ext, -bot-margin), (right-ext, board-h + top-margin), fill: none, stroke: (paint: colour-border, thickness: 2pt * scale), radius: rect-radius))
  }

  // draw the bar
  elements.push(rect((bar-x1, 0), (bar-x2, board-h), fill: colour-bar, stroke: none))
  
  return elements
}

/// renders horizontal accent bars to highlight player home boards
#let draw-homeboard-markers(
  board-w, board-h, tri-w, bar-w, scale, clockwise, ace-point, swap-colours,
  ch-light, ch-dark, show-labels, marker-thickness, label-size
) = {
  let elements = ()
  let visual-light = if swap-colours { ch-dark } else { ch-light }
  let visual-dark = if swap-colours { ch-light } else { ch-dark }
  
  let (x_start, x_end) = if clockwise { (0.0, 6 * tri-w) } else { (6 * tri-w + bar-w, board-w) }
  let proportional-offset = ((label-size * scale) / 1pt) * 0.016
  let bot-y = if show-labels { -0.15 } else { -proportional-offset }
  let top-y = if show-labels { board-h + 0.15 } else { board-h + proportional-offset }
  
  // inverted: ownership colors flipped to match dark orientation intuition
  let bottom-owner-color = if ace-point == "dark" { visual-dark } else { visual-light }
  let top-owner-color = if ace-point == "dark" { visual-light } else { visual-dark }
  
  elements.push(line((x_start + 0.05, bot-y), (x_end - 0.05, bot-y), stroke: (paint: bottom-owner-color, thickness: marker-thickness * scale, cap: "round")))
  elements.push(line((x_start + 0.05, top-y), (x_end - 0.05, top-y), stroke: (paint: top-owner-color, thickness: marker-thickness * scale, cap: "round")))
  return elements
}

/// places pip counts and captured checkers on the bar
#let draw-bar-pips-and-checkers(
  bar-cx, bar-light, bar-dark, board-h, radius, diameter, pips, show-pips, swap-colours, show-bg, scale,
  colour-text, ch-light, ch-dark, colour-ch-light-border, colour-ch-dark-border, colour-bg, mono-font, label-size,
  top-margin, bot-margin, ace-point, colour-light-tri
) = {
  let elements = ()
  
  let light-is-bottom = (ace-point == "dark")
  let bot-y-slot = 0.5
  let top-y-slot = board-h - 0.5
  
  if show-pips {
    let dark-y = if light-is-bottom { bot-y-slot } else { top-y-slot }
    let light-y = if light-is-bottom { top-y-slot } else { bot-y-slot }
    let text-fill = colour-text
    
    elements.push(content((bar-cx, dark-y), text(font: mono-font, fill: text-fill, size: (label-size + 1pt) * scale, weight: "bold", str(pips.dark)), anchor: "center"))
    elements.push(content((bar-cx, light-y), text(font: mono-font, fill: text-fill, size: (label-size + 1pt) * scale, weight: "bold", str(pips.light)), anchor: "center"))
  }
  
  // resolved: cosmetic color swaps mapped to handle checker and border flips seamlessly on the bar
  let active-ch-light = if swap-colours { ch-dark } else { ch-light }
  let active-bd-light = if swap-colours { colour-ch-dark-border } else { colour-ch-light-border }
  let active-ch-dark = if swap-colours { ch-light } else { ch-dark }
  let active-bd-dark = if swap-colours { colour-ch-light-border } else { colour-ch-dark-border }

  if bar-light > 0 {
    let starting-y = if show-pips { 1.2 } else { 0.0 }
    let base-y = if light-is-bottom { radius + starting-y } else { board-h - radius - starting-y }
    let dir = if light-is-bottom { 1.0 } else { -1.0 }
    
    let count-sign = if swap-colours { -bar-light } else { bar-light }
    elements.push(draw-bar-checkers(bar-cx, base-y, count-sign, dir, radius, diameter, show-bg, scale, active-ch-light, active-ch-dark, active-bd-light, active-bd-dark, colour-bg, mono-font))
  }
  
  if bar-dark > 0 {
    let starting-y = if show-pips { 1.2 } else { 0.0 }
    let base-y = if light-is-bottom { board-h - radius - starting-y } else { radius + starting-y }
    let dir = if light-is-bottom { -1.0 } else { 1.0 }
    
    let count-sign = if swap-colours { bar-dark } else { -bar-dark }
    elements.push(draw-bar-checkers(bar-cx, base-y, count-sign, dir, radius, diameter, show-bg, scale, active-ch-light, active-ch-dark, active-bd-light, active-bd-dark, colour-bg, mono-font))
  }
  
  return elements
}

/// draws the alternating point triangles and positioning labels around the board perimeter
#let draw-board-points(
  top-indices, bot-indices, checkers, tri-w, tri-h, bar-w, board-h, radius, diameter,
  show-labels, swap-colours, show-bg, scale, colour-dark-tri, colour-light-tri, colour-text,
  ch-light, ch-dark, colour-ch-light-border, colour-ch-dark-border, colour-bg, mono-font, label-size,
  show-home-markers
) = {
  let elements = ()
  
  let label-fill = if show-bg { colour-text } else { colour-light-tri }
  let base-offset = 0.40
  let clear-offset = if show-home-markers { 0.48 } else { base-offset }

  // resolved: cosmetic color swaps mapped to handle checker and border flips seamlessly on the points
  let active-ch-light = if swap-colours { ch-dark } else { ch-light }
  let active-bd-light = if swap-colours { colour-ch-dark-border } else { colour-ch-light-border }
  let active-ch-dark = if swap-colours { ch-light } else { ch-dark }
  let active-bd-dark = if swap-colours { colour-ch-light-border } else { colour-ch-dark-border }

  // render top points row
  for (k, idx) in top-indices.enumerate() {
    let count = checkers.at(idx - 1)
    let shift-x = if k >= 6 { bar-w } else { 0.0 }
    let cx = (k * tri-w) + (tri-w / 2) + shift-x
    
    let is-even-point = calc.even(idx)
    let tri-fill = if is-even-point { colour-dark-tri } else { colour-light-tri }
    
    elements.push(line((cx - tri-w / 2, board-h), (cx + tri-w / 2, board-h), (cx, board-h - tri-h), close: true, fill: tri-fill, stroke: 0pt))
    
    if show-labels {
      elements.push(content((cx, board-h + clear-offset), text(font: mono-font, size: label-size * scale, fill: label-fill, str(idx)), anchor: "center"))
    }
    if count != 0 {
      elements.push(draw-point-checkers(cx, board-h - radius, count, -1.0, radius, diameter, show-bg, scale, active-ch-light, active-ch-dark, active-bd-light, active-bd-dark, colour-bg, mono-font))
    }
  }

  // render bottom points row
  for (k, idx) in bot-indices.enumerate() {
    let count = checkers.at(idx - 1)
    let shift-x = if k >= 6 { bar-w } else { 0.0 }
    let cx = (k * tri-w) + (tri-w / 2) + shift-x
    
    let is-even-point = calc.even(idx)
    let tri-fill = if is-even-point { colour-dark-tri } else { colour-light-tri }
    
    elements.push(line((cx - tri-w / 2, 0.0), (cx + tri-w / 2, 0.0), (cx, tri-h), close: true, fill: tri-fill, stroke: 0pt))
    
    if show-labels {
      elements.push(content((cx, -clear-offset), text(font: mono-font, size: label-size * scale, fill: label-fill, str(idx)), anchor: "center"))
    }
    if count != 0 {
      elements.push(draw-point-checkers(cx, radius, count, 1.0, radius, diameter, show-bg, scale, active-ch-light, active-ch-dark, active-bd-light, active-bd-dark, colour-bg, mono-font))
    }
  }
  return elements
}


// ============================================================================
// section 5: ghost checkers and bezier arrows
// ============================================================================

/// computes raw horizontal and vertical canvas grid coordinates for points, bar slots, and side tray paths
#let calculate-board-coordinates(
  idx, k, base-light, base-dark, turn, radius, diameter, 
  board-h, board-w, tri-w, bar-w, scale, clockwise
) = {
  if idx == 0 or idx == 25 { 
    let col = calc.rem(k, 3)
    let row = calc.floor(k / 3)
    
    // tracks dynamic tray layout columns depending on clockwise board rotation properties
    let cx = if clockwise {
      -0.24 - (col * 0.28)
    } else {
      board-w + 0.24 + (col * 0.28)
    }
    
    // tracks dynamic tray layout rows relative to the upper and lower playing field halves
    let cy = if idx == 0 {
      0.26 + (row * 0.58)
    } else {
      board-h - 0.26 - (row * 0.58)
    }
    return (cx, cy) 
  }
  
  // calculates geometric coordinates for active points on the board
  let is-top = idx >= 13
  let i = if clockwise { if is-top { 24 - idx } else { idx - 1 } } else { if is-top { idx - 13 } else { 12 - idx } }
  let x-offset = if i < 6 { i * tri-w } else { i * tri-w + bar-w }
  let cx = x-offset + tri-w / 2
  let cy = if is-top { board-h - radius - k * diameter } else { radius + k * diameter }
  return (cx, cy)
}

/// pre-calculates and projects transparent dashed ghost outlines for checkers at destination coordinates
#let draw-ghost-checkers(
  sorted-moves, checkers, turn, swap-colours, radius, scale, base-light, base-dark, total-incoming, get-point-xy, 
  ch-light, ch-dark, colour-ch-light-border, colour-ch-dark-border, tray-checker-size
) = {
  let ghost-counts = (:)
  let source-counts = (:)
  let saved-arrow-data = ()
  let elements = ()
  let slat-w = 0.24 
  
  let slat-h = 0.30 + (tray-checker-size * 0.38)
  let row-pitch = 0.36 + (tray-checker-size * 0.41)

  let is-visually-light = if swap-colours { turn == "dark" } else { turn == "light" }
  let moving-base-colour = if is-visually-light { ch-light } else { ch-dark }
  let ghost-fill = moving-base-colour.transparentize(60%)
  let target-stroke-colour = if is-visually-light { colour-ch-light-border } else { colour-ch-dark-border }

  for mv in sorted-moves {
    let (from-pt, to-pt) = mv
    let src-key = str(from-pt)
    let peeling = source-counts.at(src-key, default: 0)
    
    let base-src-count = if from-pt == 0 or from-pt == 25 { 0 } else { calc.abs(checkers.at(from-pt - 1)) }
    let capped-src-count = calc.min(base-src-count, 5)
    let src-k = calc.max(0, capped-src-count - 1 - peeling)
    
    let start-pt = get-point-xy(from-pt, src-k, false)
    source-counts.insert(src-key, peeling + 1)
    
    let dst-key = str(to-pt)
    let extra = ghost-counts.at(dst-key, default: 0)
    
    let base-dst-count = if to-pt == 0 or to-pt == 25 { 0 } else { calc.abs(checkers.at(to-pt - 1)) }
    let capped-dst-count = calc.min(base-dst-count, 5)
    
    let total-ghosts = total-incoming.at(dst-key, default: 0)
    let dst-k = capped-dst-count + total-ghosts - 1 - extra
    let target-slot-idx = if to-pt == 25 { base-dark + extra } else if to-pt == 0 { base-light + extra } else { dst-k }
    
    if to-pt == 0 or to-pt == 25 {
      let row = calc.floor(target-slot-idx / 3)
      let cx = get-point-xy(to-pt, target-slot-idx, true).at(0) 
      let dynamic-cy = if to-pt == 25 {
        11 * 0.80 - slat-h / 2 - (row * row-pitch)
      } else {
        slat-h / 2 + (row * row-pitch)
      }
      let final-pt = (cx, dynamic-cy)
      
      // draws dashed rectangular outlines for ghost pieces entering side trays
      elements.push(rect((final-pt.at(0) - slat-w / 2, final-pt.at(1) - slat-h / 2), (final-pt.at(0) + slat-w / 2, final-pt.at(1) + slat-h / 2), fill: ghost-fill, stroke: (paint: target-stroke-colour, thickness: 1pt * scale, dash: "dashed")))
      saved-arrow-data.push((start-pt: start-pt, end-pt: final-pt, from-pt: from-pt, to-pt: to-pt, extra: extra))
    } else {
      let end-pt = get-point-xy(to-pt, target-slot-idx, true)
      
      // draws dashed circular outlines for ghost pieces landing on point triangles
      elements.push(circle(end-pt, radius: radius - 0.015, fill: ghost-fill, stroke: (paint: target-stroke-colour, thickness: 1pt * scale, dash: "dashed")))
      saved-arrow-data.push((start-pt: start-pt, end-pt: end-pt, from-pt: from-pt, to-pt: to-pt, extra: extra))
    }
    ghost-counts.insert(dst-key, extra + 1)
  }
  return (elements: elements, arrow-data: saved-arrow-data)
}

/// evaluates trajectory coordinates to determine the optimum vertical control height for bezier movement arcs
#let calculate-ctrl-y(start-pt, end-pt, from-pt, to-pt, idx-count, board-h) = {
  let mx = (start-pt.at(0) + end-pt.at(0)) / 2
  let my = (start-pt.at(1) + end-pt.at(1)) / 2
  let dx = calc.abs(end-pt.at(0) - start-pt.at(0))
  let dynamic-arc = 0.45 + (dx * 0.10) 
  
  // calculates smooth clearance curves depending on tracking zones and stacking depths
  if to-pt == 0 or to-pt == 25 {
    return if start-pt.at(1) > board-h / 2 { my - 0.3 } else { my + 0.3 }
  } else if from-pt <= 12 and to-pt <= 12 { 
    return my + dynamic-arc + (idx-count * 0.15)
  } else if from-pt >= 13 and to-pt >= 13 { 
    return my - dynamic-arc - (idx-count * 0.15)
  } else { 
    return if end-pt.at(1) > start-pt.at(1) { my + dynamic-arc + 0.4 } else { my - dynamic-arc - 0.4 }
  }
}

/// generates sweeping bezier curve strokes equipped with arrowhead marks using calculated control handles
#let render-arrow-paths(saved-arrow-data, board-h, scale, arrow-mark, colour-arrow) = {
  let elements = ()
  for arrow in saved-arrow-data {
    let mx = (arrow.start-pt.at(0) + arrow.end-pt.at(0)) / 2
    let ctrl-y = calculate-ctrl-y(arrow.start-pt, arrow.end-pt, arrow.from-pt, arrow.to-pt, arrow.extra, board-h)
    
    // builds smooth quadratic curves connecting piece source nodes to destination nodes
    elements.push(bezier(
      arrow.start-pt, 
      arrow.end-pt, 
      (mx, ctrl-y), 
      stroke: (cap: "round", paint: colour-arrow, thickness: 2.5pt * scale), 
      mark: (end: arrow-mark, fill: colour-arrow, scale: 0.6 * scale)
    ))
  }
  return elements
}

/// draws checker paths by managing path calculations, ghost checkers, and active arrows
#let draw-movement-arrows(
  moves, checkers, turn, radius, diameter, board-h, tri-w, bar-w, scale,
  arrow-mark: "circle", clockwise: false, borne-off: (0, 0), swap-colours: false,
  colour-arrow: rgb("#FF007F"), ch-light: rgb("#e3e8e9"), ch-dark: rgb("#25373a"),
  colour-ch-light-border: rgb("#101718"), colour-ch-dark-border: rgb("#53777c"),
  show-tray-borders: true, tray-checker-size: 0.0
) = {
  group({
    let total-incoming = (:) 
    let board-w = 12 * tri-w + bar-w
    let (base-light, base-dark) = borne-off
    
    // sort movement vectors to establish layered stacking calculations
    let sorted-moves = moves.sorted(key: (mv) => {
      mv.at(0) * 100 - calc.abs(mv.at(1) - mv.at(0))
    })

    // register checker arrival metrics across destination tracking buffers
    for mv in sorted-moves {
      let dst-key = str(mv.at(1))
      let current = total-incoming.at(dst-key, default: 0)
      total-incoming.insert(dst-key, current + 1)
    }

    // calculates spatial point locations dynamically while processing bar exemptions
    let get-point-xy(idx, k, is-destination) = {
      if (idx == 0 or idx == 25) and not is-destination {
        let bar-cx = (6 * tri-w) + bar-w / 2
        let starting-y = 1.2 
        let cy = if idx == 25 { board-h - radius - starting-y - (k * diameter) } else { radius + starting-y + (k * diameter) }
        return (bar-cx, cy)
      } else {
        return calculate-board-coordinates(idx, k, base-light, base-dark, turn, radius, diameter, board-h, board-w, tri-w, bar-w, scale, clockwise)
      }
    }

    // compile and map transparent dashed checker targets across landing nodes
    let ghost-result = draw-ghost-checkers(
      sorted-moves, checkers, turn, swap-colours, radius, scale, base-light, base-dark, total-incoming, get-point-xy, 
      ch-light, ch-dark, colour-ch-light-border, colour-ch-dark-border, tray-checker-size
    )

    // calculate and inject sweeping curve vectors connecting board positions
    let arrow-elements = render-arrow-paths(ghost-result.arrow-data, board-h, scale, arrow-mark, colour-arrow)

    // draw compiled ghost items and overlay motion lines onto the backgammon board
    group({ for element in ghost-result.elements { element } })
    for element in arrow-elements { element }
  })
}

// ============================================================================
// section 6: main backgammon board master entry call
// ============================================================================

/// draws a complete backgammon board displaying positions pips, trays, dice and movement trajectories
#let backgammon-board(
  checkers, 
  
  // core game configuration and movement rules
  turn: "light", 
  bar: (0, 0), 
  dice: (4, 3), 
  cube: (value: 64, owner: none), 
  borne-off: (0, 0),
  clockwise: false, 
  swap-colours: false, 
  swap-players: false, 
  ace-point: "light",
  moves: (),

  // all visibility and customisable rendering toggles
  show-bg: false, 
  show-border: true, 
  show-pips: true,
  show-labels: true, 
  show-dice: true, 
  show-cube: true, 
  show-home-markers: true,
  show-tray-borders: true, 
  
  // all visual appearance styling and theme configurations
  theme: "default-green", 
  font: none, 
  adjust-theme: (:),
  rounded: true, 
  scale: 1.0, 
  label-size: 9pt,
  marker-thickness: 2.5pt,
  tray-checker-size: 0.0, 
  arrow-mark: "circle"
) = {
  canvas({
    let active-checkers = if swap-players {
      checkers.map(count => -count)
    } else {
      checkers
    }

    // extract theme colour properties and font variables via palette mapping
    let (
      colour-bg, colour-dark-tri, colour-light-tri, colour-text, colour-bar,
      colour-border, ch-light, colour-ch-light-border, ch-dark, colour-ch-dark-border,
      cube-bg, cube-text, colour-arrow, theme-font
    ) = resolve-theme-palette(theme, adjust-theme: adjust-theme)

    let mono-font = if font != none { font } else { theme-font }

    draw.scale(x: scale, y: scale)
    let diameter = 0.80   
    let radius = diameter / 2
    let board-h = 11 * diameter 
    let tri-h = board-h * 0.42  
    let tri-w = 0.82      
    let bar-w = 0.95      
    let board-w = 12 * tri-w + bar-w
    
    let (bar-light, bar-dark) = bar
    let (base-light, base-dark) = borne-off
    
    let pips = calculate-pips(active-checkers, bar-light, bar-dark, base-light, base-dark, ace-point: ace-point)
    
    let baseline-margin = if show-labels { 0.8 } else { 0.4 }
    let top-margin = if show-cube { 0.8 } else { baseline-margin }
    let bot-margin = if show-cube { 0.8 } else { baseline-margin }
    let left-ext = -0.5
    let right-ext = board-w + 0.5
    
    let has-tray-pieces = (base-light > 0) or (base-dark > 0) or moves.any(mv => mv.at(1) == 0 or mv.at(1) == 25)
    if has-tray-pieces {
      if clockwise { left-ext = -1.25 } else { right-ext = board-w + 1.25 }
    }

    let bar-x1 = 6 * tri-w
    let bar-x2 = 6 * tri-w + bar-w
    let frame-elements = draw-board-frame(
      left-ext, right-ext, top-margin, bot-margin, board-h, bar-x1, bar-x2, 
      show-bg, show-border, scale, colour-bg, colour-border, colour-bar, rounded
    )
    for element in frame-elements { element }

    if show-home-markers {
      let marker-elements = draw-homeboard-markers(
        board-w, board-h, tri-w, bar-w, scale, clockwise, ace-point, 
        swap-colours, ch-light, ch-dark, show-labels, marker-thickness, label-size
      )
      for element in marker-elements { element }
    }

    let bar-cx = bar-x1 + bar-w / 2
    let bar-elements = draw-bar-pips-and-checkers(
      bar-cx, bar-light, bar-dark, board-h, radius, diameter, pips, show-pips, 
      swap-colours, show-bg, scale, colour-text, ch-light, ch-dark, colour-ch-light-border, colour-ch-dark-border, 
      colour-bg, mono-font, label-size, top-margin, bot-margin, ace-point, colour-light-tri
    )
    for element in bar-elements { element }

    let top-indices = if clockwise { array(range(13, 25)).rev() } else { array(range(13, 25)) }
    let bot-indices = if clockwise { array(range(1, 13)) } else { array(range(1, 13)).rev() }
    let point-elements = draw-board-points(
      top-indices, bot-indices, active-checkers, tri-w, tri-h, bar-w, board-h, radius, 
      diameter, show-labels, swap-colours, show-bg, scale, colour-dark-tri, 
      colour-light-tri, colour-text, ch-light, ch-dark, colour-ch-light-border, colour-ch-dark-border, colour-bg, mono-font, label-size,
      show-home-markers
    )
    for element in point-elements { element }

    // overlay active dice faces relative to the current player turn
    if show-dice { draw-dice-blocks(dice, turn, board-h, bar-x2, show-bg, scale, ch-light, ch-dark, colour-bg, colour-text, swap-colours) }

    if show-cube {
      let cube-elements = draw-doubling-cube(cube, board-w, board-h, scale, cube-bg, cube-text, colour-border, mono-font)
      for element in cube-elements { element }
    }

    let get-point-xy-tray(idx, k, is-destination) = {
      let bar-cx = (6 * tri-w) + bar-w / 2
      let starting-y = 1.2 
      let cy = if idx == 25 { board-h - radius - starting-y - (k * diameter) } else { radius + starting-y + (k * diameter) }
      if (idx == 0 or idx == 25) and not is-destination { return (bar-cx, cy) } else {
        return calculate-board-coordinates(idx, k, base-light, base-dark, turn, radius, diameter, board-h, board-w, tri-w, bar-w, scale, clockwise)
      }
    }
    
    let tray-elements = draw-borne-off-trays(
      base-light, base-dark, swap-colours, scale, get-point-xy-tray, ch-light, ch-dark, 
      colour-ch-light-border, colour-ch-dark-border, show-tray-borders, tray-checker-size,
      ace-point
    )
    for element in tray-elements { element }

    if moves.len() > 0 {
      draw-movement-arrows(
        moves, active-checkers, turn, radius, diameter, board-h, tri-w, bar-w, scale, 
        arrow-mark: arrow-mark, clockwise: clockwise, borne-off: borne-off, 
        swap-colours: swap-colours, colour-arrow: colour-arrow, ch-light: ch-light, ch-dark: ch-dark,
        colour-ch-light-border: colour-ch-light-border, colour-ch-dark-border: colour-ch-dark-border,
        show-tray-borders: show-tray-borders, tray-checker-size: tray-checker-size
      )
    }
  })
}
