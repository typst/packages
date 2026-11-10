// Trapping Rain Water - Enhanced visualization
#import "../../helpers.typ": display

#let custom-display(input) = {
  let height = input.height

  // Show raw data first
  [*height:* #display(height)]
  linebreak()

  if height.len() == 0 { return }

  // Calculate water level at each position
  let n = height.len()
  let left-max = height.map(_ => 0)
  let right-max = height.map(_ => 0)

  // Left pass
  left-max.at(0) = height.at(0)
  for i in range(1, n) {
    left-max.at(i) = calc.max(left-max.at(i - 1), height.at(i))
  }

  // Right pass
  right-max.at(n - 1) = height.at(n - 1)
  for i in range(n - 1).rev() {
    right-max.at(i) = calc.max(right-max.at(i + 1), height.at(i))
  }

  // Water at each position
  let water = range(n).map(i => calc.max(
    0,
    calc.min(left-max.at(i), right-max.at(i)) - height.at(i),
  ))
  let max-height = calc.max(..height)
  let total-water = water.sum()

  // Visualization parameters
  let chart-width = calc.min(320pt, n * 18pt + 50pt)
  let chart-height = 160pt
  let margin-left = 30pt
  let margin-bottom = 25pt
  let margin-top = 15pt
  let margin-right = 15pt

  let plot-width = chart-width - margin-left - margin-right
  let plot-height = chart-height - margin-bottom - margin-top

  // Continuous bars - no gap
  let bar-width = plot-width / n

  // Scale functions
  let scale-x(i) = margin-left + i * bar-width
  let scale-y(h) = chart-height - margin-bottom - h / max-height * plot-height

  v(0.5em)

  box(
    width: chart-width,
    height: chart-height,
    {
      // Sky gradient background
      place(
        rect(
          width: chart-width,
          height: chart-height - margin-bottom,
          fill: gradient.linear(
            rgb("#E8F4FD"),
            rgb("#F5FAFF"),
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
          fill: rgb("#D4A574"),
        ),
      )

      // Draw water first (behind bars)
      for i in range(n) {
        let h = height.at(i)
        let w = water.at(i)
        if w > 0 {
          let water-top = h + w
          let x = scale-x(i)
          let y-top = scale-y(water-top)
          let y-bottom = scale-y(h)

          // Water column
          place(
            dx: x,
            dy: y-top,
            rect(
              width: bar-width,
              height: y-bottom - y-top,
              fill: gradient.linear(
                rgb("#4A90E2").transparentize(20%),
                rgb("#87CEEB").transparentize(30%),
                angle: 90deg,
              ),
            ),
          )

          // Water surface highlight
          place(
            dx: x,
            dy: y-top,
            rect(
              width: bar-width,
              height: 2pt,
              fill: white.transparentize(40%),
            ),
          )
        }
      }

      // Draw terrain bars (continuous, no gap)
      for i in range(n) {
        let h = height.at(i)
        if h > 0 {
          let x = scale-x(i)
          let y-top = scale-y(h)
          let y-bottom = scale-y(0)

          // Bar with gradient
          place(
            dx: x,
            dy: y-top,
            rect(
              width: bar-width,
              height: y-bottom - y-top,
              fill: gradient.linear(
                rgb("#2C3E50"),
                rgb("#34495E"),
                angle: 0deg,
              ),
              stroke: (
                left: 0.3pt + rgb("#1a252f"),
                right: 0.3pt + rgb("#4a5a6a"),
                top: 0.5pt + rgb("#4A5568"),
              ),
            ),
          )
        }
      }

      // Y-axis
      place(
        dx: margin-left,
        dy: margin-top,
        line(
          length: plot-height,
          angle: 90deg,
          stroke: 1pt + rgb("#333"),
        ),
      )

      // X-axis
      place(
        dx: margin-left,
        dy: chart-height - margin-bottom,
        line(
          length: plot-width,
          stroke: 1pt + rgb("#333"),
        ),
      )

      // Y-axis labels and ticks
      let y-step = calc.max(1, calc.ceil(max-height / 4))
      let y-val = 0
      while y-val <= max-height {
        let y = scale-y(y-val)
        place(
          dx: 0pt,
          dy: y - 5pt,
          box(
            width: margin-left - 5pt,
            align(right, text(size: 7pt, str(y-val))),
          ),
        )
        if y-val > 0 {
          // Grid line
          place(
            dx: margin-left,
            dy: y,
            line(
              length: plot-width,
              stroke: 0.3pt + rgb("#ccc"),
            ),
          )
        }
        y-val += y-step
      }

      // X-axis labels
      let x-step = calc.max(1, calc.ceil(n / 10))
      for i in range(0, n, step: x-step) {
        let x = scale-x(i) + bar-width / 2
        place(
          dx: x - 8pt,
          dy: chart-height - margin-bottom + 5pt,
          box(
            width: 16pt,
            align(center, text(size: 7pt, str(i))),
          ),
        )
      }

      // Legend at top left
      place(
        dx: margin-left + 5pt,
        dy: 5pt,
        box(
          fill: white.transparentize(20%),
          inset: 3pt,
          radius: 2pt,
          {
            box(width: 8pt, height: 8pt, fill: rgb("#34495E"))
            h(3pt)
            text(size: 6pt)[Terrain]
            h(6pt)
            box(width: 8pt, height: 8pt, fill: rgb("#4A90E2"))
            h(3pt)
            text(size: 6pt)[Water]
          },
        ),
      )

      // Total water label at bottom center
      place(
        dx: (chart-width - 60pt) / 2,
        dy: chart-height - 12pt,
        box(
          fill: rgb("#4A90E2").transparentize(20%),
          inset: 4pt,
          radius: 3pt,
          stroke: 0.5pt + rgb("#4A90E2"),
          text(size: 8pt, fill: white, weight: "bold")[Total: #total-water],
        ),
      )
    },
  )
}
