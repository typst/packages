// Container With Most Water - Enhanced visualization
#import "../../helpers.typ": display

#let custom-display(input) = {
  let height = input.height

  // Show raw data first
  [*height:* #display(height)]
  linebreak()

  if height.len() == 0 { return }

  // Find the optimal two lines using two-pointer approach
  let n = height.len()
  let l-ptr = 0
  let r-ptr = n - 1
  let max-area = 0
  let best-left = 0
  let best-right = n - 1

  while l-ptr < r-ptr {
    let h = calc.min(height.at(l-ptr), height.at(r-ptr))
    let area = h * (r-ptr - l-ptr)
    if area > max-area {
      max-area = area
      best-left = l-ptr
      best-right = r-ptr
    }
    if height.at(l-ptr) < height.at(r-ptr) {
      l-ptr += 1
    } else {
      r-ptr -= 1
    }
  }

  let max-height = calc.max(..height)
  let water-level = calc.min(height.at(best-left), height.at(best-right))

  // Visualization parameters
  let chart-width = calc.min(320pt, n * 20pt + 50pt)
  let chart-height = 160pt
  let margin-left = 30pt
  let margin-bottom = 25pt
  let margin-top = 15pt
  let margin-right = 15pt

  let plot-width = chart-width - margin-left - margin-right
  let plot-height = chart-height - margin-bottom - margin-top

  let line-width = 4pt

  // Scale functions
  let scale-x(i) = margin-left + (i + 0.5) * plot-width / n
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
            rgb("#FFF5E6"),
            rgb("#FFFAF0"),
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
          fill: rgb("#C4A77D"),
        ),
      )

      // Draw water area (between the two selected lines)
      let water-y-top = scale-y(water-level)
      let water-y-bottom = scale-y(0)
      let water-x-left = scale-x(best-left)
      let water-x-right = scale-x(best-right)

      // Water fill
      place(
        dx: water-x-left,
        dy: water-y-top,
        rect(
          width: water-x-right - water-x-left,
          height: water-y-bottom - water-y-top,
          fill: gradient.linear(
            rgb("#4A90E2").transparentize(30%),
            rgb("#87CEEB").transparentize(40%),
            angle: 90deg,
          ),
        ),
      )

      // Water surface line with wave effect
      place(
        dx: water-x-left,
        dy: water-y-top,
        rect(
          width: water-x-right - water-x-left,
          height: 3pt,
          fill: gradient.linear(
            white.transparentize(50%),
            rgb("#4A90E2").transparentize(60%),
            white.transparentize(50%),
            angle: 0deg,
          ),
        ),
      )

      // Draw all vertical lines
      for i in range(n) {
        let h = height.at(i)
        if h > 0 {
          let x = scale-x(i)
          let y-top = scale-y(h)
          let y-bottom = scale-y(0)

          let is-selected = i == best-left or i == best-right

          // Line color and width
          let line-color = if is-selected {
            gradient.linear(
              rgb("#E74C3C"),
              rgb("#C0392B"),
              angle: 90deg,
            )
          } else {
            gradient.linear(
              rgb("#7F8C8D"),
              rgb("#95A5A6"),
              angle: 90deg,
            )
          }

          let lw = if is-selected { 6pt } else { line-width }

          // Vertical line
          place(
            dx: x - lw / 2,
            dy: y-top,
            rect(
              width: lw,
              height: y-bottom - y-top,
              fill: line-color,
              radius: 1pt,
            ),
          )

          // Top cap
          place(
            dx: x - lw / 2 - 1pt,
            dy: y-top - 2pt,
            rect(
              width: lw + 2pt,
              height: 3pt,
              fill: if is-selected { rgb("#E74C3C") } else { rgb("#7F8C8D") },
              radius: 1pt,
            ),
          )

          // Selection glow effect
          if is-selected {
            place(
              dx: x - lw / 2 - 3pt,
              dy: y-top,
              rect(
                width: lw + 6pt,
                height: y-bottom - y-top,
                fill: rgb("#E74C3C").transparentize(80%),
                radius: 2pt,
              ),
            )
          }
        }
      }

      // Draw arrows pointing to selected lines
      let arrow-y = margin-top + 5pt

      // Left arrow
      place(
        dx: scale-x(best-left) - 3pt,
        dy: arrow-y,
        text(size: 10pt, fill: rgb("#E74C3C"))[▼],
      )

      // Right arrow
      place(
        dx: scale-x(best-right) - 3pt,
        dy: arrow-y,
        text(size: 10pt, fill: rgb("#E74C3C"))[▼],
      )

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

      // Y-axis labels
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
          place(
            dx: margin-left,
            dy: y,
            line(
              length: plot-width,
              stroke: 0.3pt + rgb("#ddd"),
            ),
          )
        }
        y-val += y-step
      }

      // X-axis labels
      let x-step = calc.max(1, calc.ceil(n / 10))
      for i in range(0, n, step: x-step) {
        let x = scale-x(i)
        place(
          dx: x - 8pt,
          dy: chart-height - margin-bottom + 5pt,
          box(
            width: 16pt,
            align(center, text(size: 7pt, str(i))),
          ),
        )
      }

      // Area label (positioned at bottom center)
      let label-x = chart-width / 2
      place(
        dx: label-x - 25pt,
        dy: chart-height - 12pt,
        box(
          fill: white.transparentize(20%),
          inset: 4pt,
          radius: 3pt,
          stroke: 0.5pt + rgb("#4A90E2"),
          text(
            size: 9pt,
            fill: rgb("#2980B9"),
            weight: "bold",
          )[Area: #max-area],
        ),
      )

      // Legend
      place(
        dx: chart-width - 90pt,
        dy: 5pt,
        box(
          fill: white.transparentize(20%),
          inset: 3pt,
          radius: 2pt,
          {
            box(width: 8pt, height: 8pt, fill: rgb("#E74C3C"), radius: 1pt)
            h(3pt)
            text(size: 6pt)[Selected]
            h(5pt)
            box(width: 8pt, height: 8pt, fill: rgb("#7F8C8D"), radius: 1pt)
            h(3pt)
            text(size: 6pt)[Other]
          },
        ),
      )
    },
  )
}
