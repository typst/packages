// Rendering for the annotations that state a measured quantity: the angle
// between two directions, and the axes of a frame.

#import "@preview/cetz:0.5.2"
#import cetz.draw: arc, content, line
#import "../../../shared/vector.typ"
#import "../../../shared/expression.typ"
#import "points.typ"
#import "style.typ" as annotation-style

// A sweep is measured counterclockwise from the first direction to the second,
// so the marked angle is the one the declaration order asks for rather than
// whichever of the two is smaller.
#let _counterclockwise-sweep(start-angle, end-angle) = {
  let sweep = calc.rem((end-angle - start-angle).deg() + 360, 360)
  sweep * 1deg
}

#let _render-right-angle(vertex, start-direction, end-direction, marker-size, marker-stroke) = {
  let first-corner = vector.point-along(vertex, start-direction, marker-size)
  let second-corner = vector.point-along(vertex, end-direction, marker-size)
  line(
    first-corner,
    vector.add(first-corner, vector.subtract(second-corner, vertex)),
    second-corner,
    stroke: marker-stroke,
  )
}

#let render-angle-mark(scene, annotation, diagram-style) = {
  let described-as = "angle-mark()"
  let from-direction = points.annotation-direction(
    scene,
    annotation.from,
    described-as + " `from:`",
  )
  let to-direction = points.annotation-direction(
    scene,
    annotation.to,
    described-as + " `to:`",
  )
  let vertex = if annotation.at != auto {
    points.annotation-point(scene, annotation.at, described-as)
  } else {
    assert(
      from-direction.line != none and to-direction.line != none,
      message: (
        "typed-physics: angle-mark() measures from "
          + from-direction.described-as
          + " to "
          + to-direction.described-as
          + ", and a direction given as an angle has no corner to mark; give `at:` the point to mark"
      ),
    )
    points.lines-intersection(
      from-direction.line,
      to-direction.line,
      described-as,
    )
  }

  let start-angle = vector.angle-of(from-direction.direction)
  let swept-angle = _counterclockwise-sweep(
    start-angle,
    vector.angle-of(to-direction.direction),
  )
  let marker-color = annotation-style.annotation-color(diagram-style, annotation)
  let marker-stroke = annotation-style.annotation-stroke(
    diagram-style,
    annotation,
    marker-color,
  )
  let marker-radius = if annotation.radius == auto {
    diagram-style.angle-radius
  } else {
    annotation.radius
  }

  let is-right-angle = if annotation.right-angle == auto {
    calc.abs(swept-angle.deg() - 90) < 0.001
  } else {
    annotation.right-angle
  }
  if is-right-angle {
    _render-right-angle(
      vertex,
      from-direction.direction,
      to-direction.direction,
      diagram-style.right-angle-size,
      marker-stroke,
    )
  } else {
    arc(
      vertex,
      start: start-angle,
      stop: start-angle + swept-angle,
      radius: marker-radius,
      anchor: "origin",
      stroke: marker-stroke,
    )
  }

  if annotation.label == none { return }
  let displayed-label = if annotation.label == auto {
    let displayed-degrees = expression.format-angle(swept-angle.deg())
    $#displayed-degrees$
  } else {
    annotation.label
  }
  let label-distance = if is-right-angle {
    diagram-style.right-angle-size * 2.2
  } else {
    marker-radius * 1.4
  }
  let styled-label = text(
    ..annotation-style.annotation-text-style(
      diagram-style,
      annotation,
      marker-color,
    ),
    displayed-label,
  )
  content(
    vector.add(
      vector.point-along(
        vertex,
        vector.direction-from-angle(start-angle + swept-angle / 2),
        label-distance,
      ),
      annotation.label-offset,
    ),
    if annotation.label-rotation == 0deg {
      styled-label
    } else {
      rotate(annotation.label-rotation, reflow: false, styled-label)
    },
    anchor: "center",
  )
}

#let _render-axis-arm(
  origin,
  arm-direction,
  arm-length,
  arm-label,
  annotation,
  axis-color,
  axis-stroke,
  axis-text-style,
) = {
  let arm-tip = vector.point-along(origin, arm-direction, arm-length)
  line(
    origin,
    arm-tip,
    stroke: axis-stroke,
    mark: (
      end: annotation.arrow-tip,
      fill: axis-color,
      stroke: axis-color,
      scale: annotation.arrow-scale,
    ),
  )
  if arm-label == none { return }
  content(
    vector.point-along(arm-tip, arm-direction, annotation.label-offset),
    text(..axis-text-style, arm-label),
    anchor: "center",
  )
}

#let render-axis(scene, annotation, diagram-style) = {
  let described-as = "axis()"
  let origin = points.annotation-point(scene, annotation.at, described-as)
  let frame-angle = (
    if annotation.along == auto {
      0deg
    } else {
      vector.angle-of(
        points.annotation-direction(
          scene,
          annotation.along,
          described-as + " `along:`",
        ).direction,
      )
    }
      + annotation.angle
  )
  let horizontal-direction = vector.direction-from-angle(frame-angle)
  let vertical-direction = vector.left-normal(horizontal-direction)

  let axis-color = annotation-style.annotation-color(diagram-style, annotation)
  let axis-stroke = annotation-style.annotation-stroke(
    diagram-style,
    annotation,
    axis-color,
  )
  let axis-text-style = annotation-style.annotation-text-style(
    diagram-style,
    annotation,
    axis-color,
  )

  if annotation.quadrants == "both" {
    line(
      vector.point-along(
        origin,
        vector.reversed(horizontal-direction),
        annotation.length,
      ),
      origin,
      stroke: axis-stroke,
    )
    line(
      vector.point-along(
        origin,
        vector.reversed(vertical-direction),
        annotation.length,
      ),
      origin,
      stroke: axis-stroke,
    )
  }

  let axis-label(declared-label, default-label) = if declared-label == auto {
    default-label
  } else {
    declared-label
  }
  _render-axis-arm(
    origin,
    horizontal-direction,
    annotation.length,
    axis-label(annotation.x-label, $x$),
    annotation,
    axis-color,
    axis-stroke,
    axis-text-style,
  )
  _render-axis-arm(
    origin,
    vertical-direction,
    annotation.length,
    axis-label(annotation.y-label, $y$),
    annotation,
    axis-color,
    axis-stroke,
    axis-text-style,
  )
}
