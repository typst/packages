// 3D axis, grid, and tick drawing.

#import "@preview/cetz:0.5.2" as cetz

#let draw-axes-3d(
  xmin, xmax,
  ymin, ymax,
  zmin, zmax,
  xlabel: $x$,
  ylabel: $y$,
  zlabel: $z$,
  xtick-step: auto,
  ytick-step: auto,
  ztick-step: auto,
  show-grid: true,
  show-frame: false,
  axis-stroke: 0.6pt + black,
  grid-stroke: 0.3pt + luma(200),
  tick-length: 0.1,
) = {
  import cetz.draw: *
  import "../axes.typ": nice-step

  let x-step = if xtick-step != auto { xtick-step }
               else { nice-step((xmax - xmin) / 5) }
  let y-step = if ytick-step != auto { ytick-step }
               else { nice-step((ymax - ymin) / 5) }
  let z-step = if ztick-step != auto { ztick-step }
               else { nice-step((zmax - zmin) / 5) }

  if show-frame {
    // Bottom face edges (z = zmin)
    line((xmin, ymin, zmin), (xmax, ymin, zmin), stroke: axis-stroke)
    line((xmin, ymin, zmin), (xmin, ymax, zmin), stroke: axis-stroke)
    line((xmax, ymin, zmin), (xmax, ymax, zmin), stroke: axis-stroke)
    line((xmin, ymax, zmin), (xmax, ymax, zmin), stroke: axis-stroke)

    // Vertical edges
    line((xmin, ymin, zmin), (xmin, ymin, zmax), stroke: axis-stroke)
    line((xmax, ymin, zmin), (xmax, ymin, zmax), stroke: axis-stroke)
    line((xmax, ymax, zmin), (xmax, ymax, zmax), stroke: axis-stroke)
    line((xmin, ymax, zmin), (xmin, ymax, zmax), stroke: axis-stroke)

    // Top face edges (z = zmax)
    line((xmin, ymin, zmax), (xmax, ymin, zmax), stroke: axis-stroke)
    line((xmin, ymin, zmax), (xmin, ymax, zmax), stroke: axis-stroke)
    line((xmax, ymin, zmax), (xmax, ymax, zmax), stroke: axis-stroke)
    line((xmin, ymax, zmax), (xmax, ymax, zmax), stroke: axis-stroke)
  }

  // Three axis lines (always drawn)
  line((xmin, ymin, zmin), (xmax, ymin, zmin), stroke: axis-stroke)
  line((xmin, ymin, zmin), (xmin, ymax, zmin), stroke: axis-stroke)
  line((xmin, ymin, zmin), (xmin, ymin, zmax), stroke: axis-stroke)

  // Grid lines on the bottom face
  if show-grid {
    let gx = calc.ceil(xmin / x-step) * x-step
    while gx <= xmax + 1e-9 {
      line((gx, ymin, zmin), (gx, ymax, zmin), stroke: grid-stroke)
      gx += x-step
    }
    let gy = calc.ceil(ymin / y-step) * y-step
    while gy <= ymax + 1e-9 {
      line((xmin, gy, zmin), (xmax, gy, zmin), stroke: grid-stroke)
      gy += y-step
    }
  }

  // X-axis ticks along (y=ymin, z=zmin) edge
  let tx = calc.ceil(xmin / x-step) * x-step
  while tx <= xmax + 1e-9 {
    line(
      (tx, ymin, zmin),
      (tx, ymin - tick-length, zmin),
      stroke: axis-stroke,
    )
    content(
      (tx, ymin - tick-length * 2.5, zmin),
      text(size: 7pt)[#calc.round(tx, digits: 2)],
    )
    tx += x-step
  }

  // Y-axis ticks along (x=xmin, z=zmin) edge
  let ty = calc.ceil(ymin / y-step) * y-step
  while ty <= ymax + 1e-9 {
    line(
      (xmin, ty, zmin),
      (xmin - tick-length, ty, zmin),
      stroke: axis-stroke,
    )
    content(
      (xmin - tick-length * 2.5, ty, zmin),
      text(size: 7pt)[#calc.round(ty, digits: 2)],
    )
    ty += y-step
  }

  // Z-axis ticks along (x=xmin, y=ymin) edge
  let tz = calc.ceil(zmin / z-step) * z-step
  while tz <= zmax + 1e-9 {
    line(
      (xmin, ymin, tz),
      (xmin - tick-length, ymin, tz),
      stroke: axis-stroke,
    )
    content(
      (xmin - tick-length * 2.5, ymin, tz),
      text(size: 7pt)[#calc.round(tz, digits: 2)],
    )
    tz += z-step
  }

  // Axis labels
  content(
    ((xmin + xmax) / 2, ymin - tick-length * 5, zmin),
    text(size: 9pt)[#xlabel],
  )
  content(
    (xmin - tick-length * 5, (ymin + ymax) / 2, zmin),
    text(size: 9pt)[#ylabel],
  )
  content(
    (xmin - tick-length * 5, ymin, (zmin + zmax) / 2),
    text(size: 9pt)[#zlabel],
  )
}
