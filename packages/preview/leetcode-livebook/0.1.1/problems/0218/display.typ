// The Skyline Problem - Beautiful skyline visualization
#import "../../helpers.typ": display

#let custom-display(input) = {
  let buildings = input.buildings

  // Show raw data
  [*buildings:* #display(buildings)]
  linebreak()

  if buildings.len() == 0 { return }

  // Find bounds
  let min-x = calc.min(..buildings.map(b => b.at(0)))
  let max-x = calc.max(..buildings.map(b => b.at(1)))
  let max-h = calc.max(..buildings.map(b => b.at(2)))

  // Visualization parameters
  let chart-width = 280pt
  let chart-height = 140pt
  let margin-left = 30pt
  let margin-bottom = 20pt
  let margin-top = 10pt
  let margin-right = 10pt

  let plot-width = chart-width - margin-left - margin-right
  let plot-height = chart-height - margin-bottom - margin-top

  // Scale functions
  let scale-x(x) = margin-left + (x - min-x) / (max-x - min-x) * plot-width
  let scale-y(y) = chart-height - margin-bottom - y / max-h * plot-height

  // Building colors (gradient from warm to cool)
  let building-colors = (
    rgb("#FF6B6B"), // coral red
    rgb("#4ECDC4"), // teal
    rgb("#45B7D1"), // sky blue
    rgb("#96CEB4"), // sage green
    rgb("#FFEAA7"), // pale yellow
    rgb("#DDA0DD"), // plum
    rgb("#98D8C8"), // mint
    rgb("#F7DC6F"), // golden
  )

  // Calculate skyline for overlay
  let events = ()
  for (idx, b) in buildings.enumerate() {
    let (left, right, height) = (b.at(0), b.at(1), b.at(2))
    events.push((left, 0, height, idx))
    events.push((right, 1, height, idx))
  }
  events = events.sorted(key: e => {
    let (x, typ, h, _) = e
    if typ == 0 { (x, typ, -h) } else { (x, typ, h) }
  })

  let active = ()
  let skyline-points = ((min-x, 0),)
  let prev-max-height = 0

  for event in events {
    let (x, typ, height, idx) = event
    if typ == 0 {
      let b = buildings.at(idx)
      active.push((height, b.at(1), idx))
      active = active.sorted(key: a => -a.at(0))
    } else {
      let new-active = ()
      for a in active {
        if a.at(2) != idx { new-active.push(a) }
      }
      active = new-active
    }
    let new-active = ()
    for a in active {
      if a.at(1) > x { new-active.push(a) }
    }
    active = new-active

    let curr-max-height = if active.len() > 0 { active.at(0).at(0) } else { 0 }
    if curr-max-height != prev-max-height {
      // Add horizontal segment at previous height, then vertical
      skyline-points.push((x, prev-max-height))
      skyline-points.push((x, curr-max-height))
      prev-max-height = curr-max-height
    }
  }
  skyline-points.push((max-x, 0))

  v(0.5em)

  box(
    width: chart-width,
    height: chart-height,
    {
      // Background gradient (sky)
      place(
        rect(
          width: chart-width,
          height: chart-height - margin-bottom,
          fill: gradient.linear(
            rgb("#87CEEB").lighten(30%),
            rgb("#E0F4FF"),
            angle: 90deg,
          ),
        ),
      )

      // Ground
      place(
        dy: chart-height - margin-bottom,
        rect(
          width: chart-width,
          height: margin-bottom,
          fill: rgb("#8B7355"),
        ),
      )

      // Draw buildings (semi-transparent to show overlap)
      for (idx, b) in buildings.enumerate() {
        let (left, right, height) = (b.at(0), b.at(1), b.at(2))
        let x1 = scale-x(left)
        let x2 = scale-x(right)
        let y-top = scale-y(height)
        let y-bottom = scale-y(0)

        let color = building-colors.at(calc.rem(idx, building-colors.len()))

        // Building body
        place(
          dx: x1,
          dy: y-top,
          rect(
            width: x2 - x1,
            height: y-bottom - y-top,
            fill: color.transparentize(40%),
            stroke: 0.5pt + color.darken(30%),
          ),
        )

        // Windows (decorative)
        let w-width = x2 - x1
        let w-height = y-bottom - y-top
        if w-width > 8pt and w-height > 15pt {
          let window-cols = calc.min(3, calc.floor(w-width / 6pt))
          let window-rows = calc.min(4, calc.floor(w-height / 10pt))
          let win-w = 3pt
          let win-h = 5pt
          let gap-x = (w-width - window-cols * win-w) / (window-cols + 1)
          let gap-y = (w-height - window-rows * win-h) / (window-rows + 1)

          for row in range(window-rows) {
            for col in range(window-cols) {
              let wx = x1 + gap-x * (col + 1) + win-w * col
              let wy = y-top + gap-y * (row + 1) + win-h * row
              place(
                dx: wx,
                dy: wy,
                rect(
                  width: win-w,
                  height: win-h,
                  fill: rgb("#FFFACD").transparentize(30%),
                  stroke: 0.3pt + color.darken(20%),
                ),
              )
            }
          }
        }
      }

      // Draw skyline outline (bold red line)
      let skyline-path-points = skyline-points.map(p => (
        scale-x(p.at(0)),
        scale-y(p.at(1)),
      ))

      if skyline-path-points.len() >= 2 {
        let first = skyline-path-points.at(0)
        let rest = skyline-path-points.slice(1)

        place(
          curve(
            stroke: 2.5pt + rgb("#E74C3C"),
            curve.move((first.at(0), first.at(1))),
            ..rest.map(p => curve.line((p.at(0), p.at(1)))),
          ),
        )
      }

      // Y-axis
      place(
        dx: margin-left,
        dy: margin-top,
        line(
          length: plot-height,
          angle: 90deg,
          stroke: 1pt + black,
        ),
      )

      // X-axis
      place(
        dx: margin-left,
        dy: chart-height - margin-bottom,
        line(
          length: plot-width,
          stroke: 1pt + black,
        ),
      )

      // Y-axis labels
      let y-ticks = (0, calc.floor(max-h / 2), max-h)
      for tick in y-ticks {
        let y = scale-y(tick)
        place(
          dx: 0pt,
          dy: y - 5pt,
          box(
            width: margin-left - 5pt,
            align(right, text(size: 7pt, str(tick))),
          ),
        )
        // Tick mark
        place(
          dx: margin-left - 3pt,
          dy: y,
          line(length: 3pt, stroke: 0.5pt + black),
        )
      }

      // X-axis labels
      let x-step = calc.max(1, calc.floor((max-x - min-x) / 5))
      let x-val = min-x
      while x-val <= max-x {
        let x = scale-x(x-val)
        place(
          dx: x - 8pt,
          dy: chart-height - margin-bottom + 3pt,
          box(
            width: 16pt,
            align(center, text(size: 7pt, str(x-val))),
          ),
        )
        // Tick mark
        place(
          dx: x,
          dy: chart-height - margin-bottom,
          line(length: 3pt, angle: 90deg, stroke: 0.5pt + black),
        )
        x-val += x-step
      }

      // Legend
      place(
        dx: chart-width - 60pt,
        dy: 5pt,
        box(
          fill: white.transparentize(30%),
          inset: 3pt,
          radius: 2pt,
          stroke: 0.5pt + gray,
          {
            box(width: 10pt, height: 2pt, fill: rgb("#E74C3C"))
            h(3pt)
            text(size: 6pt)[Skyline]
          },
        ),
      )
    },
  )
}
