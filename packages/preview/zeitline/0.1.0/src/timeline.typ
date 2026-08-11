#let default-theme = (
  colors: (
    text: black,
    muted: rgb("#333333"),
    accent: rgb("#c0392b"),
    line: rgb("#aaaaaa"),
  ),
  sizes: (
    date: 11pt,
    body: 10pt,
    dot: 4pt,
    line-width: 2pt,
  ),
  spacing: (
    row: 1em,
    arm: 3em,
  ),
)

/// Merge user theme overrides with defaults
#let merge-theme(overrides) = {
  let theme = default-theme
  if overrides != none {
    if "colors" in overrides {
      for (k, v) in overrides.colors { theme.colors.insert(k, v) }
    }
    if "sizes" in overrides {
      for (k, v) in overrides.sizes { theme.sizes.insert(k, v) }
    }
    if "spacing" in overrides {
      for (k, v) in overrides.spacing { theme.spacing.insert(k, v) }
    }
  }
  theme
}

/// Render a vertical timeline from a list of events.
#let timeline(data, theme: none) = {
  let t = merge-theme(theme)
  let c = t.colors
  let s = t.sizes
  let sp = t.spacing
  let n = data.len()

  // Use layout to determine available width for columns
  layout(size => context {
    let col-gutter = 0.5em
    // Calculate column width for 1fr
    let col-width = (size.width - sp.arm - 2 * col-gutter) / 2

    let cells = ()

    for (i, event) in data.enumerate() {
      let is-left = event.at("side", default: if calc.even(i) { "left" } else { "right" }) == "left"
      let is-first = i == 0
      let is-last = i == n - 1

      // Generate Text Content
      let left-content = if is-left {
        align(right)[
          #text(weight: "bold", size: s.date, fill: c.accent)[#event.date] \
          #text(size: s.body, fill: c.muted)[#event.desc]
        ]
      } else { none }

      let right-content = if not is-left {
        align(left)[
          #text(weight: "bold", size: s.date, fill: c.accent)[#event.date] \
          #text(size: s.body, fill: c.muted)[#event.desc]
        ]
      } else { none }

      // Measure Heights
      // Wrap in a constrained box to ensure text wrapping is accounted for.
      let left-box = box(width: col-width, inset: (y: sp.row / 2), left-content)
      let right-box = box(width: col-width, inset: (y: sp.row / 2), right-content)

      let h-left = measure(left-box).height
      let h-right = measure(right-box).height
      let row-height = calc.max(h-left, h-right)

      // Add Cells
      // Left Cell
      cells.push(left-box)

      // Spine Cell
      // Measure title for vertical centering
      let title-content = text(weight: "bold", size: s.date)[#event.date]
      let title-h = measure(title-content).height
      let dot-y = sp.row / 1.4 + title-h / 1.4

      let spine-cell = align(center + top, box(width: 100%, height: row-height)[
        // Vertical lines (Top/Bottom segments)
        #if not is-first and not is-last {
          place(center, rect(width: s.line-width, height: 100%, fill: c.line))
        } else {
          if not is-first {
            place(top + center, rect(width: s.line-width, height: dot-y, fill: c.line))
          }
          if not is-last {
            place(top + center, dy: dot-y, rect(width: s.line-width, height: 100% - dot-y, fill: c.line))
          }
        }

        // Dot and Arm
        #place(top + center, dy: dot-y - s.dot)[
          #block(height: 0pt)[
            #if not is-left {
              place(left + horizon, box(width: 50%, height: s.line-width, fill: c.accent))
            } else {
              place(right + horizon, box(width: 50%, height: s.line-width, fill: c.accent))
            }
            #place(center + horizon, circle(radius: s.dot, fill: c.accent))
          ]
        ]
      ])
      cells.push(spine-cell)

      // Right Cell
      cells.push(right-box)
    }

    // Render Single Grid
    grid(
      columns: (col-width, sp.arm, col-width),
      column-gutter: col-gutter,
      row-gutter: 0pt,
      ..cells
    )
  })
}
