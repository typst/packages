#import "../geometry/lib.typ" as geometry
#import "../primitives/lib.typ" as p

#let _draw-grid(x-range, y-range, step, color) = {
  let x-min = x-range.at(0)
  let x-max = x-range.at(1)
  let y-min = y-range.at(0)
  let y-max = y-range.at(1)
  let x-count = calc.floor((x-max - x-min) / step)
  let y-count = calc.floor((y-max - y-min) / step)

  for index in range(x-count + 1) {
    let x = x-min + index * step
    p.line((x, y-min), (x, y-max), stroke: color + 0.35pt)
  }
  for index in range(y-count + 1) {
    let y = y-min + index * step
    p.line((x-min, y), (x-max, y), stroke: color + 0.35pt)
  }
}

#let _draw-axes(
  x-range,
  y-range,
  tick-step,
  tick-labels,
  x-label,
  y-label,
  origin-label,
  theme,
) = {
  let x-min = x-range.at(0)
  let x-max = x-range.at(1)
  let y-min = y-range.at(0)
  let y-max = y-range.at(1)

  p.arrow((x-min, 0), (x-max, 0), color: theme.ink, stroke: 0.8pt)
  p.arrow((0, y-min), (0, y-max), color: theme.ink, stroke: 0.8pt)
  p.label((x-max, 0), x-label, offset: (0.2, -0.18))
  p.label((0, y-max), y-label, offset: (-0.18, 0.2))
  if origin-label != none {
    p.label((0, 0), origin-label, offset: (-0.2, -0.22))
  }

  let x-count = calc.floor((x-max - x-min) / tick-step)
  let y-count = calc.floor((y-max - y-min) / tick-step)
  for index in range(x-count + 1) {
    let x = x-min + index * tick-step
    if calc.abs(x) > 0.0001 {
      p.line((x, -0.07), (x, 0.07), stroke: theme.ink + 0.55pt)
      if tick-labels and calc.abs(x - x-max) > 0.0001 {
        p.label((x, 0), str(x), offset: (0, -0.24))
      }
    }
  }
  for index in range(y-count + 1) {
    let y = y-min + index * tick-step
    if calc.abs(y) > 0.0001 {
      p.line((-0.07, y), (0.07, y), stroke: theme.ink + 0.55pt)
      if tick-labels and calc.abs(y - y-max) > 0.0001 {
        p.label((0, y), str(y), offset: (-0.24, 0))
      }
    }
  }
}

#let _draw-vector(item, theme) = {
  let color = if item.color == none { theme.accent } else { item.color }
  if item.show-components {
    let corner = (item.end.at(0), item.from.at(1))
    p.line(item.from, corner, stroke: theme.surface-ink + 0.55pt)
    p.line(corner, item.end, stroke: theme.surface-ink + 0.55pt)
  }
  p.arrow(item.from, item.end, color: color, stroke: item.stroke)
  if item.label != none {
    let point = geometry.add(
      item.from,
      geometry.scale(item.components, item.label-position / 100%),
    )
    p.label(point, item.label, offset: item.label-offset)
  }
}

/// Render vectors on an optional Cartesian grid and coordinate axes.
#let diagram(
  vectors: (),
  x-range: (-4, 4),
  y-range: (-3, 4),
  grid: true,
  grid-step: 1,
  axes: true,
  tick-step: 1,
  tick-labels: true,
  x-label: [$x$],
  y-label: [$y$],
  origin-label: [$O$],
  theme: p.default-theme,
) = {
  assert(x-range.at(0) < x-range.at(1), message: "Invalid x-range")
  assert(y-range.at(0) < y-range.at(1), message: "Invalid y-range")
  assert(grid-step > 0 and tick-step > 0,
    message: "Grid and tick steps must be positive")

  p.canvas(theme: theme, {
    if grid {
      _draw-grid(x-range, y-range, grid-step, rgb("dce3ea"))
    }
    if axes {
      _draw-axes(
        x-range,
        y-range,
        tick-step,
        tick-labels,
        x-label,
        y-label,
        origin-label,
        theme,
      )
    }
    for item in vectors {
      assert(item.kind == "vector", message: "vectors must contain vector objects")
      _draw-vector(item, theme)
    }
  })
}
