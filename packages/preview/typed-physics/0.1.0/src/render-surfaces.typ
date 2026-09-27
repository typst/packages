// Rendering of straight and curved surfaces and their support hatching.

#import "@preview/cetz:0.5.2"
#import cetz.draw: anchor, arc, group, line
#import "vector.typ"
#import "expression.typ"
#import "render-geometry.typ" as geometry
#import "style.typ": resolve-surface-style

#let render-label = geometry.render-label

#let render-surface-hatching(
  start-position,
  end-position,
  outward-normal-direction,
  surface-style,
) = {
  let surface-span-vector = vector.subtract(end-position, start-position)
  let surface-span-length = vector.magnitude(surface-span-vector)
  if surface-span-length == 0 { return }

  let surface-direction = vector.normalized(surface-span-vector)
  let hatch-direction = vector.normalized(
    vector.add(
      vector.reversed(outward-normal-direction),
      vector.reversed(surface-direction),
    ),
  )
  let hatch-count = calc.max(
    1,
    int(calc.round(surface-span-length / surface-style.hatch-spacing)),
  )
  for hatch-index in range(hatch-count + 1) {
    let distance-along-surface = (
      hatch-index * surface-span-length / hatch-count
    )
    let hatch-base-position = vector.point-along(
      start-position,
      surface-direction,
      distance-along-surface,
    )
    let hatch-tip-position = vector.point-along(
      hatch-base-position,
      hatch-direction,
      surface-style.hatch-length,
    )
    let hatch-tip-distance-along-surface = vector.dot-product(
      vector.subtract(hatch-tip-position, start-position),
      surface-direction,
    )
    let hatch-tip-is-after-start = (
      hatch-tip-distance-along-surface >= -0.000001
    )
    let hatch-tip-is-before-end = (
      hatch-tip-distance-along-surface <= surface-span-length + 0.000001
    )
    let hatch-stays-inside-tangent-span = (
      hatch-tip-is-after-start and hatch-tip-is-before-end
    )
    if hatch-stays-inside-tangent-span {
      line(
        hatch-base-position,
        hatch-tip-position,
        stroke: surface-style.hatch-stroke,
      )
    }
  }
}

// A ramp is a sloped contact drawn over a horizontal foundation, so its
// immovable-support marks belong to the base of its triangle.
#let surface-hatch-span(surface, diagram-style) = {
  if surface.kind == "arc" { return none }
  let surface-style = resolve-surface-style(diagram-style, surface.style)
  let raw-start-position = if surface.kind == "ramp" {
    surface.foot
  } else {
    surface.start
  }
  let raw-end-position = if surface.kind == "ramp" {
    surface.base-corner
  } else {
    surface.end
  }
  let span-vector = vector.subtract(raw-end-position, raw-start-position)
  let is-horizontal-span = (
    calc.abs(span-vector.at(0)) >= calc.abs(span-vector.at(1))
  )
  let runs-in-positive-direction = if is-horizontal-span {
    raw-start-position.at(0) <= raw-end-position.at(0)
  } else {
    raw-start-position.at(1) <= raw-end-position.at(1)
  }
  (
    start: if runs-in-positive-direction {
      raw-start-position
    } else {
      raw-end-position
    },
    end: if runs-in-positive-direction {
      raw-end-position
    } else {
      raw-start-position
    },
    orientation: if is-horizontal-span { "horizontal" } else { "vertical" },
    outward-normal: if surface.kind == "ramp" {
      (0, 1)
    } else {
      surface.outward-normal
    },
    style: (
      hatch-stroke: surface-style.hatch-stroke,
      hatch-spacing: surface-style.hatch-spacing,
      hatch-length: surface-style.hatch-length,
    ),
  )
}

#let coordinate-along-hatch-span(hatch-span, position) = if (
  hatch-span.orientation == "horizontal"
) {
  position.at(0)
} else {
  position.at(1)
}

#let fixed-coordinate-of-hatch-span(hatch-span) = if (
  hatch-span.orientation == "horizontal"
) {
  hatch-span.start.at(1)
} else {
  hatch-span.start.at(0)
}

#let hatch-spans-can-merge(first-span, second-span) = {
  if first-span.orientation != second-span.orientation { return false }
  if first-span.outward-normal != second-span.outward-normal { return false }
  if first-span.style != second-span.style { return false }

  let coordinate-tolerance = 0.000001
  if calc.abs(
    fixed-coordinate-of-hatch-span(first-span)
      - fixed-coordinate-of-hatch-span(second-span),
  ) > coordinate-tolerance {
    return false
  }

  let first-start = coordinate-along-hatch-span(
    first-span,
    first-span.start,
  )
  let first-end = coordinate-along-hatch-span(first-span, first-span.end)
  let second-start = coordinate-along-hatch-span(
    second-span,
    second-span.start,
  )
  let second-end = coordinate-along-hatch-span(second-span, second-span.end)
  let first-span-reaches-second = (
    first-start <= second-end + coordinate-tolerance
  )
  let second-span-reaches-first = (
    second-start <= first-end + coordinate-tolerance
  )
  first-span-reaches-second and second-span-reaches-first
}

#let merge-hatch-spans(first-span, second-span) = (
  start: if coordinate-along-hatch-span(first-span, first-span.start)
    <= coordinate-along-hatch-span(second-span, second-span.start) {
    first-span.start
  } else {
    second-span.start
  },
  end: if coordinate-along-hatch-span(first-span, first-span.end)
    >= coordinate-along-hatch-span(second-span, second-span.end) {
    first-span.end
  } else {
    second-span.end
  },
  orientation: first-span.orientation,
  outward-normal: first-span.outward-normal,
  style: first-span.style,
)

// Collinear foundations with the same hatch style are one physical support,
// even when several declarations contribute overlapping or adjacent pieces.
#let unified-surface-hatch-spans(scene, diagram-style) = {
  let unified-spans = ()
  for surface-name in scene.surface-order {
    let combined-span = surface-hatch-span(
      scene.surfaces.at(surface-name),
      diagram-style,
    )
    if combined-span == none { continue }
    let found-overlapping-span = true
    while found-overlapping-span {
      found-overlapping-span = false
      let separate-spans = ()
      for existing-span in unified-spans {
        if hatch-spans-can-merge(combined-span, existing-span) {
          combined-span = merge-hatch-spans(combined-span, existing-span)
          found-overlapping-span = true
        } else {
          separate-spans.push(existing-span)
        }
      }
      unified-spans = separate-spans
    }
    unified-spans.push(combined-span)
  }
  unified-spans
}

#let render-unified-surface-hatching(scene, diagram-style) = {
  for hatch-span in unified-surface-hatch-spans(scene, diagram-style) {
    render-surface-hatching(
      hatch-span.start,
      hatch-span.end,
      hatch-span.outward-normal,
      hatch-span.style,
    )
  }
}

#let distance-from-point-to-segment(point, segment-start, segment-end) = {
  let segment-vector = vector.subtract(segment-end, segment-start)
  let squared-segment-length = vector.dot-product(
    segment-vector,
    segment-vector,
  )
  if squared-segment-length == 0 {
    return vector.magnitude(vector.subtract(point, segment-start))
  }
  let projected-ratio = vector.dot-product(
    vector.subtract(point, segment-start),
    segment-vector,
  ) / squared-segment-length
  let clamped-ratio = calc.max(0, calc.min(1, projected-ratio))
  let nearest-point = vector.point-along(
    segment-start,
    segment-vector,
    clamped-ratio,
  )
  vector.magnitude(vector.subtract(point, nearest-point))
}

// Straight foundations take visual priority where a curved support meets
// them. A curved hatch begins only when its whole length fits clear of every
// straight span, leaving one readable support pattern at the junction.
#let curved-hatch-has-clearance(
  hatch-base-position,
  curved-surface-style,
  straight-hatch-spans,
) = {
  let required-clearance = curved-surface-style.hatch-length + 0.025
  for straight-hatch-span in straight-hatch-spans {
    let distance-to-straight-span = distance-from-point-to-segment(
      hatch-base-position,
      straight-hatch-span.start,
      straight-hatch-span.end,
    )
    if distance-to-straight-span <= required-clearance {
      return false
    }
  }
  true
}

#let render-curved-surface-hatching(
  surface,
  surface-style,
  straight-hatch-spans,
) = {
  let hatch-count = calc.max(
    2,
    int(calc.round(surface.length / surface-style.hatch-spacing)),
  )
  for hatch-index in range(hatch-count + 1) {
    let position-ratio = hatch-index / hatch-count
    let position-angle = (
      surface.start-angle + surface.sweep-angle * position-ratio
    )
    let radial-direction = vector.direction-from-angle(position-angle)
    let outward-normal-direction = if surface.side == "outside" {
      radial-direction
    } else {
      vector.reversed(radial-direction)
    }
    let hatch-base-position = vector.point-along(
      surface.center,
      radial-direction,
      surface.radius,
    )
    let hatch-tip-position = vector.point-along(
      hatch-base-position,
      vector.reversed(outward-normal-direction),
      surface-style.hatch-length,
    )
    if curved-hatch-has-clearance(
      hatch-base-position,
      surface-style,
      straight-hatch-spans,
    ) {
      line(
        hatch-base-position,
        hatch-tip-position,
        stroke: surface-style.hatch-stroke,
      )
    }
  }
}

// `side` names which edge of the label sits at the position, so a wide label
// can be made to grow away from the figure instead of over it.

#let render-surface(surface, diagram-style) = group(
  name: surface.name,
  {
    let surface-style = resolve-surface-style(diagram-style, surface.style)
    if surface.kind == "ramp" {
      line(
        surface.foot,
        surface.apex,
        surface.base-corner,
        close: true,
        fill: surface-style.fill,
        stroke: surface-style.stroke,
      )
      anchor("foot", surface.foot)
      anchor("apex", surface.apex)
      anchor("base", vector.midpoint(surface.foot, surface.base-corner))
    } else if surface.kind == "arc" {
      arc(
        surface.center,
        start: surface.start-angle,
        stop: surface.end-angle,
        radius: surface.radius,
        anchor: "origin",
        stroke: surface-style.stroke,
      )
      anchor("center", surface.center)
    } else {
      line(surface.start, surface.end, stroke: surface-style.stroke)
    }
    anchor("start", surface.start)
    anchor("end", surface.end)
    anchor("surface", surface.midpoint)
    anchor("default", surface.midpoint)
  },
)

// How long a surface is, written beside it on the side a body never occupies:
// under level ground, inside the triangle of a ramp. A drawn measurement would
// have to be inset at both ends to stay within the triangle, which makes it
// shorter than the length it claims to show.
#let length-label(surface) = {
  let surface-length = surface.length
  let displayed-length = if surface-length == calc.round(surface-length) {
    str(int(surface-length))
  } else {
    expression.format-number(surface-length)
  }
  $ell = #displayed-length$
}

#let render-surface-length(surface, diagram-style) = render-label(
  vector.point-along(
    surface.midpoint,
    vector.reversed(
      if surface.kind == "arc" {
        let midpoint-radial-direction = vector.normalized(
          vector.subtract(surface.midpoint, surface.center),
        )
        if surface.side == "outside" {
          midpoint-radial-direction
        } else {
          vector.reversed(midpoint-radial-direction)
        }
      } else {
        surface.outward-normal
      },
    ),
    diagram-style.length-label-offset,
  ),
  length-label(surface),
  diagram-style.angle-text,
)

// ── Bodies ───────────────────────────────────────────────────────────────────
