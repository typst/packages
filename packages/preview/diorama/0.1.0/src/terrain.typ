// terrain.typ — scene-mountain, scene-tunnel, scene-lake, scene-river,
//   scene-hill, scene-cliff, scene-island, scene-road, scene-valley,
//   scene-beach, scene-cave, scene-path

#import "@preview/cetz:0.5.2"
#import "theme.typ": scene-theme, _f, _s

/// Draw a mountain with optional snow cap
/// - base-left (array): (x, y) left base point
/// - base-right (array): (x, y) right base point
/// - summit (array): (x, y) summit point
/// - bg (color): mountain fill color
/// - line-color (color): mountain stroke color
/// - snow (bool): whether to draw a snow cap
/// - snow-fraction (float): fraction of height for snow cap (default 0.15)
/// - smoothness (int): number of intermediate points on each flank (0 = straight)
/// - variant (string): "default", "rounded", "flat-top", "volcanic"
#let scene-mountain(
  base-left,
  base-right,
  summit,
  bg: auto,
  line-color: auto,
  snow: true,
  snow-fraction: 0.15,
  smoothness: 0,
  variant: "default",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.mountain } else { bg }
  let s = if line-color == auto { scene-theme.mountain-stroke } else { line-color }

  let sx = summit.at(0)
  let sy = summit.at(1)
  let lx = base-left.at(0)
  let ly = base-left.at(1)
  let rx = base-right.at(0)
  let ry = base-right.at(1)

  if variant == "rounded" {
    // Smooth rounded hill using many points along a cosine curve
    let n = 24
    let pts = ()
    for i in range(n + 1) {
      let t = i / n
      let px = lx + (rx - lx) * t
      // Cosine bell shape: rises from base to summit height
      let base-y = ly + (ry - ly) * t
      let peak-offset = (sy - (ly + ry) / 2)
      let py = base-y + peak-offset * (1 + calc.cos(180deg * (2 * t - 1))) / 2
      // Shift peak horizontally toward summit x
      let x-shift = (sx - (lx + rx) / 2) * calc.sin(t * 180deg)
      pts.push((px + x-shift * 0.3, py))
    }
    line(..pts, close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt)

  } else if variant == "flat-top" {
    // Mesa / plateau with flat summit
    let plateau-width = (rx - lx) * 0.2
    let plat-left-x = sx - plateau-width / 2
    let plat-right-x = sx + plateau-width / 2
    line(
      base-left,
      (plat-left-x, sy),
      (plat-right-x, sy),
      base-right,
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt,
    )

  } else if variant == "volcanic" {
    // Crater at the top: V-shaped dip in summit
    let crater-width = (rx - lx) * 0.12
    let crater-depth = (sy - (ly + ry) / 2) * 0.15
    let crater-left = (sx - crater-width, sy)
    let crater-right = (sx + crater-width, sy)
    let crater-bottom = (sx, sy - crater-depth)
    line(
      base-left,
      crater-left,
      crater-bottom,
      crater-right,
      base-right,
      close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt,
    )

  } else {
    // Default variant
    // Build mountain outline
    if smoothness > 0 {
      // Generate intermediate points on each flank with slight random-like offsets
      let left-pts = (base-left,)
      let right-pts = ()

      for i in range(1, smoothness) {
        let t = i / smoothness
        let x = lx + (sx - lx) * t
        let y = ly + (sy - ly) * t
        // Small deterministic wobble based on index
        let wobble = calc.sin(i * 137.5deg) * 0.03 * (sx - lx)
        left-pts.push((x + wobble, y))
      }
      left-pts.push(summit)

      for i in range(1, smoothness) {
        let t = i / smoothness
        let x = sx + (rx - sx) * t
        let y = sy + (ry - sy) * t
        let wobble = calc.sin(i * 97.3deg) * 0.03 * (rx - sx)
        right-pts.push((x + wobble, y))
      }
      right-pts.push(base-right)

      let all-pts = left-pts + right-pts
      line(..all-pts, close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt)
    } else {
      line(base-left, summit, base-right, close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt)
    }
  }

  // Snow cap (for all variants except volcanic, where a crater replaces the peak)
  if snow and variant != "volcanic" {
    let frac = snow-fraction

    if variant == "flat-top" {
      // Snow on the flat top
      let plateau-width = (rx - lx) * 0.2
      let plat-left-x = sx - plateau-width / 2
      let plat-right-x = sx + plateau-width / 2
      let snow-left-x = plat-left-x + (lx - plat-left-x) * frac * 0.5
      let snow-left-y = sy + (ly - sy) * frac * 0.5
      let snow-right-x = plat-right-x + (rx - plat-right-x) * frac * 0.5
      let snow-right-y = sy + (ry - sy) * frac * 0.5
      line(
        (snow-left-x, snow-left-y),
        (plat-left-x, sy), (plat-right-x, sy),
        (snow-right-x, snow-right-y),
        close: true, fill: _f(scene-theme.snow, bw), stroke: none,
      )
    } else if variant == "rounded" {
      // Simple snow circle near the top for rounded variant
      let snow-r = (rx - lx) * frac * 0.5
      let n = 16
      let pts = ()
      for i in range(n + 1) {
        let t = i / n
        let angle = 180deg * t
        let px = sx + snow-r * calc.cos(angle)
        let py = sy - snow-r * 0.3 * calc.sin(angle) + snow-r * 0.3
        pts.push((px, py))
      }
      // Close across the bottom
      pts.push((sx + snow-r, sy - snow-r * 0.15))
      pts.push((sx - snow-r, sy - snow-r * 0.15))
      line(..pts, close: true, fill: _f(scene-theme.snow, bw), stroke: none)
    } else {
      // Default snow cap (triangular)
      let snow-left-x = sx + (lx - sx) * frac
      let snow-left-y = sy + (ly - sy) * frac
      let snow-right-x = sx + (rx - sx) * frac
      let snow-right-y = sy + (ry - sy) * frac

      line(
        (snow-left-x, snow-left-y), summit, (snow-right-x, snow-right-y),
        close: true, fill: _f(scene-theme.snow, bw), stroke: none,
      )
    }
  }

}

/// Draw a tunnel entrance (rectangular opening in a mountain)
/// - entry-left (array): (x, y) bottom-left of tunnel entrance
/// - entry-right (array): (x, y) bottom-right of tunnel entrance
/// - height (float): height of the tunnel opening
/// - bg (color): tunnel fill (dark interior)
#let scene-tunnel(
  entry-left,
  entry-right,
  height: 0.4,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#3d3535") } else { bg }
  let lx = entry-left.at(0)
  let ly = entry-left.at(1)
  let rx = entry-right.at(0)
  let ry = entry-right.at(1)

  // Arch-shaped tunnel entrance
  let mid-x = (lx + rx) / 2
  let w = rx - lx

  // Rectangle body
  rect((lx, ly), (rx, ly + height * 0.7), fill: _f(f, bw), stroke: none)
  // Semicircular arch top
  let arch-y = ly + height * 0.7
  let arch-r = w / 2
  // Approximate arch with line segments
  let n = 12
  let pts = ((lx, ly),)
  for i in range(n + 1) {
    let angle = 180deg - (180deg / n) * i
    let px = mid-x + arch-r * calc.cos(angle)
    let py = arch-y + arch-r * calc.sin(angle)
    pts.push((px, py))
  }
  pts.push((rx, ly))
  line(..pts, close: true, fill: _f(f, bw), stroke: _s(rgb("#2a2a2a"), bw) + 0.5pt)

  // Dashed entry marks
  line((lx, ly), (lx, ly + height), stroke: (dash: "dotted", thickness: 0.8pt, paint: _s(black, bw)))
  line((rx, ly), (rx, ly + height), stroke: (dash: "dotted", thickness: 0.8pt, paint: _s(black, bw)))

}

/// Draw a lake (flat elliptical body of water)
/// - left (float): left x
/// - right (float): right x
/// - y (float): water surface y level (default 0)
/// - depth (float): visual depth of the lake
/// - bg (color): water color
#let scene-lake(
  left,
  right,
  y: 0,
  depth: 0.3,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.water-mid } else { bg }
  let w = right - left
  let mid-x = (left + right) / 2

  // Lake as ellipse approximated with rect + rounded appearance
  rect((left, y - depth), (right, y), fill: _f(f, bw), stroke: none)
  // Surface shimmer line
  line((left, y), (right, y), stroke: _s(rgb("#1565C0"), bw) + 1.5pt)

}

/// Draw a river (trapezoidal blue band)
/// - top-left (array): top-left bank point
/// - top-right (array): top-right bank point
/// - bottom-left (array): bottom-left bank point
/// - bottom-right (array): bottom-right bank point
/// - bg (color): water color
#let scene-river(
  top-left,
  top-right,
  bottom-left,
  bottom-right,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.water-mid } else { bg }

  // River body
  line(top-left, top-right, bottom-right, bottom-left, close: true, fill: _f(f, bw), stroke: none)

  // Bank lines
  line(top-left, bottom-left, stroke: _s(rgb("#1565C0"), bw) + 1.5pt)
  line(top-right, bottom-right, stroke: _s(rgb("#1565C0"), bw) + 1.5pt)

  // Wave lines for visual effect
  let mid-x-top = (top-left.at(0) + top-right.at(0)) / 2
  let mid-y-top = (top-left.at(1) + top-right.at(1)) / 2
  let mid-x-bot = (bottom-left.at(0) + bottom-right.at(0)) / 2
  let mid-y-bot = (bottom-left.at(1) + bottom-right.at(1)) / 2

}

/// Draw a simple rounded hill (half-ellipse dome shape)
/// - base (array): (x, y) center of the hill base
/// - width (float): total width of the hill
/// - height (float): height of the dome
/// - bg (color): hill fill color
/// - line-color (color): hill outline color
#let scene-hill(
  base,
  width: 2.0,
  height: 1.0,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.mountain } else { bg }
  let s = if line-color == auto { scene-theme.mountain-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)
  let hw = width / 2

  // Approximate half-ellipse with many segments
  let n = 24
  let pts = ((bx - hw, by),)
  for i in range(1, n) {
    let t = i / n
    let angle = 180deg * (1 - t)
    let px = bx + hw * calc.cos(angle)
    let py = by + height * calc.sin(angle)
    pts.push((px, py))
  }
  pts.push((bx + hw, by))

  line(..pts, close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt)

}

/// Draw a vertical cliff face
/// - base (array): (x, y) bottom-left corner of the cliff
/// - height (float): cliff height
/// - width (float): cliff horizontal thickness
/// - bg (color): cliff fill color
/// - line-color (color): cliff outline color
/// - variant (string): "straight" (rectangular) or "jagged" (irregular top edge)
#let scene-cliff(
  base,
  height: 3.0,
  width: 0.3,
  bg: auto,
  line-color: auto,
  variant: "straight",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.rock } else { bg }
  let s = if line-color == auto { scene-theme.mountain-stroke } else { line-color }
  let bx = base.at(0)
  let by = base.at(1)

  if variant == "jagged" {
    // Irregular top edge with rocky indentations
    let top-pts = ()
    let segments = 8
    for i in range(segments + 1) {
      let t = i / segments
      let px = bx + width * t
      // Deterministic jag using sin with prime multiplier
      let jag = calc.sin(i * 113.7deg) * height * 0.06
      let py = by + height + jag
      top-pts.push((px, py))
    }
    // Build full outline: bottom-left, up the left side, across jagged top, down the right side
    let pts = ((bx, by),)
    pts.push((bx, by + height))
    for pt in top-pts {
      pts.push(pt)
    }
    pts.push((bx + width, by + height))
    pts.push((bx + width, by))
    line(..pts, close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt)
  } else {
    // Straight rectangular cliff
    rect((bx, by), (bx + width, by + height), fill: _f(f, bw), stroke: _s(s, bw) + 1pt)
  }

  // Rocky texture lines (horizontal cracks)
  let num-cracks = calc.max(2, calc.floor(height / 0.4))
  for i in range(1, num-cracks) {
    let cy = by + i * (height / num-cracks)
    let crack-offset = calc.sin(i * 73.1deg) * width * 0.15
    let crack-len = width * (0.5 + calc.abs(calc.sin(i * 51.3deg)) * 0.4)
    let cx-start = bx + calc.max(0, crack-offset)
    let cx-end = calc.min(bx + width, cx-start + crack-len)
    line(
      (cx-start, cy),
      (cx-end, cy + height * 0.01),
      stroke: _s(s.darken(20%), bw) + 0.4pt,
    )
  }

  // Vertical crack details
  let v-cracks = calc.max(1, calc.floor(width / 0.15))
  for i in range(v-cracks) {
    let vx = bx + (i + 0.5) * (width / (v-cracks + 1))
    let vy-start = by + height * (0.2 + calc.abs(calc.sin(i * 89.3deg)) * 0.3)
    let vy-end = vy-start + height * 0.15
    line(
      (vx, vy-start), (vx + width * 0.03, vy-end),
      stroke: _s(s.darken(15%), bw) + 0.3pt,
    )
  }

}

/// Draw an island (hill sitting in water with a small beach)
/// - base (array): (x, y) center of the island at water level
/// - width (float): total width of the island
/// - height (float): height of the hill above water
/// - bg (color): island land fill color
/// - water-color (color): surrounding water color
#let scene-island(
  base,
  width: 2.0,
  height: 0.8,
  bg: auto,
  water-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.ground } else { bg }
  let wc = if water-color == auto { scene-theme.water-mid } else { water-color }
  let bx = base.at(0)
  let by = base.at(1)
  let hw = width / 2

  // Draw water band behind the island
  let water-extend = width * 0.3
  let water-depth = height * 0.25
  rect(
    (bx - hw - water-extend, by - water-depth),
    (bx + hw + water-extend, by),
    fill: _f(wc, bw), stroke: none,
  )
  // Water surface shimmer
  line(
    (bx - hw - water-extend, by),
    (bx + hw + water-extend, by),
    stroke: _s(wc.darken(20%), bw) + 1.5pt,
  )

  // Sand beach strip (slightly wider than the hill, at water level)
  let beach-hw = hw * 1.05
  let beach-depth = height * 0.08
  let beach-n = 16
  let beach-pts = ()
  for i in range(beach-n + 1) {
    let t = i / beach-n
    let angle = 180deg * (1 - t)
    let px = bx + beach-hw * calc.cos(angle)
    let py = by + beach-depth * calc.sin(angle)
    beach-pts.push((px, py))
  }
  beach-pts.push((bx + beach-hw, by))
  beach-pts.push((bx - beach-hw, by))
  line(..beach-pts, close: true, fill: _f(scene-theme.sand, bw), stroke: none)

  // Hill dome on top
  let n = 20
  let hill-pts = ((bx - hw, by),)
  for i in range(1, n) {
    let t = i / n
    let angle = 180deg * (1 - t)
    let px = bx + hw * calc.cos(angle)
    let py = by + height * calc.sin(angle)
    hill-pts.push((px, py))
  }
  hill-pts.push((bx + hw, by))
  line(..hill-pts, close: true, fill: _f(f, bw), stroke: _s(f.darken(20%), bw) + 0.8pt)

}

/// Draw a road between two points
/// - start (array): (x, y) start point of the road center
/// - end (array): (x, y) end point of the road center
/// - width (float): road width
/// - bg (color): road surface color
/// - line-color (color): road edge/marking color
/// - variant (string): "straight" (plain), "dashed" (with center dashed line)
#let scene-road(
  start,
  end,
  width: 0.3,
  bg: auto,
  line-color: auto,
  variant: "straight",
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#616161") } else { bg }
  let s = if line-color == auto { rgb("#E0E0E0") } else { line-color }
  let ax = start.at(0)
  let ay = start.at(1)
  let ex = end.at(0)
  let ey = end.at(1)

  // Direction and perpendicular
  let dx = ex - ax
  let dy = ey - ay
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }
  let nx = -dy / len * width / 2
  let ny = dx / len * width / 2

  // Road body (parallelogram)
  let p1 = (ax + nx, ay + ny)
  let p2 = (ax - nx, ay - ny)
  let p3 = (ex - nx, ey - ny)
  let p4 = (ex + nx, ey + ny)
  line(p1, p4, p3, p2, close: true, fill: _f(f, bw), stroke: _s(f.darken(30%), bw) + 0.5pt)

  // Edge lines
  line(p1, p4, stroke: _s(s, bw) + 0.8pt)
  line(p2, p3, stroke: _s(s, bw) + 0.8pt)

  if variant == "dashed" {
    // Center dashed line along the road axis
    line(start, end, stroke: (paint: _s(s, bw), dash: "dashed", thickness: 0.8pt))
  }

}

/// Draw a V-shaped valley between two mountain peaks
/// - left-peak (array): (x, y) top of the left ridge
/// - right-peak (array): (x, y) top of the right ridge
/// - bottom (array): (x, y) lowest point of the valley
/// - bg (color): valley fill color
/// - line-color (color): valley outline color
#let scene-valley(
  left-peak,
  right-peak,
  bottom,
  bg: auto,
  line-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.ground.darken(15%) } else { bg }
  let s = if line-color == auto { scene-theme.mountain-stroke } else { line-color }
  let lpx = left-peak.at(0)
  let lpy = left-peak.at(1)
  let rpx = right-peak.at(0)
  let rpy = right-peak.at(1)
  let bx = bottom.at(0)
  let by = bottom.at(1)

  // Valley shape: from left peak, down to bottom, up to right peak,
  // then across the base line to close
  let base-y = calc.min(lpy, rpy, by) - 0.1
  line(
    (lpx, base-y), left-peak, bottom, right-peak, (rpx, base-y),
    close: true, fill: _f(f, bw), stroke: _s(s, bw) + 1pt,
  )

  // Subtle shading lines in the valley bowl
  let depth = calc.max(lpy, rpy) - by
  let shade-lines = 4
  for i in range(1, shade-lines + 1) {
    let t = i / (shade-lines + 1)
    // Interpolate between peaks and bottom
    let sl-lx = lpx + (bx - lpx) * t
    let sl-ly = lpy + (by - lpy) * t
    let sl-rx = rpx + (bx - rpx) * t
    let sl-ry = rpy + (by - rpy) * t
    line(
      (sl-lx, sl-ly), (sl-rx, sl-ry),
      stroke: _s(s.lighten(40%), bw) + 0.3pt,
    )
  }

}

/// Draw a beach (sand strip above water)
/// - left (float): left x boundary
/// - right (float): right x boundary
/// - y (float): beach/water boundary y level
/// - sand-depth (float): vertical depth of the sand strip
/// - water-depth (float): vertical depth of the water below
/// - sand-color (color): sand fill color
/// - water-color (color): water fill color
#let scene-beach(
  left,
  right,
  y: 0,
  sand-depth: 0.3,
  water-depth: 0.5,
  sand-color: auto,
  water-color: auto,
  bw: false,
) = {
  import cetz.draw: *

  let sc = if sand-color == auto { scene-theme.sand } else { sand-color }
  let wc = if water-color == auto { scene-theme.water-mid } else { water-color }

  // Water layer below
  rect((left, y - water-depth), (right, y), fill: _f(wc, bw), stroke: none)

  // Shore line / wave edge
  let wave-n = 16
  let wave-pts = ()
  for i in range(wave-n + 1) {
    let t = i / wave-n
    let px = left + (right - left) * t
    let py = y + calc.sin(t * 360deg * 2) * 0.02
    wave-pts.push((px, py))
  }
  line(..wave-pts, stroke: _s(wc.darken(25%), bw) + 1.2pt)

  // Sand strip above
  rect((left, y), (right, y + sand-depth), fill: _f(sc, bw), stroke: none)

  // Sand texture dots (small marks)
  let dots = 12
  let w = right - left
  for i in range(dots) {
    let t = (i + 0.5) / dots
    let dx = left + w * t
    let dy = y + sand-depth * (0.3 + calc.abs(calc.sin(i * 67.3deg)) * 0.5)
    circle((dx, dy), radius: 0.012, fill: _f(sc.darken(15%), bw), stroke: none)
  }

}

/// Draw a cave entrance (dark arch with stalactites)
/// - base (array): (x, y) center of the cave entrance at ground level
/// - width (float): width of the cave opening
/// - height (float): height of the cave arch
/// - bg (color): cave interior darkness color
#let scene-cave(
  base,
  width: 1.5,
  height: 1.0,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { rgb("#2d2020") } else { bg }
  let bx = base.at(0)
  let by = base.at(1)
  let hw = width / 2

  // Cave arch outline (wider, organic-looking arch)
  let n = 20
  let arch-pts = ((bx - hw, by),)
  for i in range(1, n) {
    let t = i / n
    let angle = 180deg * (1 - t)
    // Slight irregular wobble for organic look
    let wobble = calc.sin(i * 127.3deg) * height * 0.04
    let px = bx + hw * calc.cos(angle)
    let py = by + (height + wobble) * calc.sin(angle)
    arch-pts.push((px, py))
  }
  arch-pts.push((bx + hw, by))

  // Dark interior
  line(..arch-pts, close: true, fill: _f(f, bw), stroke: _s(f.lighten(15%), bw) + 0.8pt)

  // Rock frame around the cave (slightly larger arch)
  let frame-hw = hw * 1.08
  let frame-h = height * 1.06
  let frame-pts = ((bx - frame-hw, by),)
  for i in range(1, n) {
    let t = i / n
    let angle = 180deg * (1 - t)
    let px = bx + frame-hw * calc.cos(angle)
    let py = by + frame-h * calc.sin(angle)
    frame-pts.push((px, py))
  }
  frame-pts.push((bx + frame-hw, by))
  line(..frame-pts, stroke: _s(scene-theme.mountain-stroke, bw) + 1.5pt)

  // Stalactites hanging from the top of the arch
  let stalactite-count = 5
  for i in range(stalactite-count) {
    let t = (i + 1) / (stalactite-count + 1)
    let angle = 180deg * (1 - t)
    let hang-x = bx + hw * 0.85 * calc.cos(angle)
    let hang-y = by + height * 0.9 * calc.sin(angle)
    // Stalactite length varies
    let stl = height * (0.08 + calc.abs(calc.sin(i * 83.7deg)) * 0.12)
    line(
      (hang-x - 0.02, hang-y),
      (hang-x, hang-y - stl),
      (hang-x + 0.02, hang-y),
      close: true, fill: _f(scene-theme.rock, bw), stroke: none,
    )
  }

}

/// Draw a dirt path / trail following arbitrary points
/// - points (array): array of (x, y) waypoints
/// - width (float): visual thickness of the path
/// - bg (color): path color (earthy tone)
#let scene-path(
  points,
  width: 0.15,
  bg: auto,
  bw: false,
) = {
  import cetz.draw: *

  let f = if bg == auto { scene-theme.sand.darken(25%) } else { bg }

  if points.len() < 2 { return }

  // Draw the path as a thick line through all points
  line(..points, stroke: _s(f, bw) + width * 1cm)

  // Overlay a slightly darker thin center line for depth
  line(..points, stroke: _s(f.darken(15%), bw) + width * 0.3cm)

}
