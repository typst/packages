// Rendering for the annotations that comment on a figure: a callout naming a
// point, a brace grouping a span, and an arrow tracing a path.

#import "@preview/cetz:0.5.2"
#import cetz.draw: circle, content, line
#import cetz.decorations: brace
#import "../../../shared/vector.typ"
#import "points.typ"
#import "style.typ" as annotation-style

#let render-callout(scene, annotation, diagram-style) = {
  let described-as = "callout()"
  let named-point = points.annotation-point(scene, annotation.at, described-as)
  let leader-angle = annotation.direction
  let leader-direction = vector.direction-from-angle(leader-angle)
  let label-position = vector.point-along(
    named-point,
    leader-direction,
    annotation.distance,
  )

  let callout-color = annotation-style.annotation-color(
    diagram-style,
    annotation,
  )
  let callout-stroke = annotation-style.annotation-stroke(
    diagram-style,
    annotation,
    callout-color,
  )

  line(
    named-point,
    label-position,
    stroke: callout-stroke,
    mark: if annotation.arrow-tip == none { (:) } else {
      (
        start: annotation.arrow-tip,
        fill: callout-color,
        stroke: callout-color,
        scale: annotation.arrow-scale,
      )
    },
  )
  if annotation.dot {
    circle(
      named-point,
      radius: 0.055,
      fill: callout-color,
      stroke: none,
    )
  }

  let styled-label = text(
    ..annotation-style.annotation-text-style(
      diagram-style,
      annotation,
      callout-color,
    ),
    annotation.label,
  )
  content(
    label-position,
    if annotation.frame {
      box(
        fill: annotation.fill,
        stroke: callout-stroke,
        inset: (x: 0.4em, y: 0.3em),
        radius: 0.2em,
        styled-label,
      )
    } else {
      box(fill: annotation.fill, inset: (x: 0.25em, y: 0.1em), styled-label)
    },
    anchor: annotation-style.anchor-facing(leader-angle + 180deg),
  )
}

// The brace bulges away from the span it groups, on the side the annotation
// names, and its label sits beyond its middle tip.
#let render-brace(scene, annotation, diagram-style) = {
  let described-as = "brace()"
  let span-start = points.annotation-point(
    scene,
    annotation.from,
    described-as,
  )
  let span-end = points.annotation-point(scene, annotation.to, described-as)
  let span = vector.subtract(span-end, span-start)
  assert(
    vector.magnitude(span) > 0.000001,
    message: "typed-physics: brace() endpoints must not coincide",
  )
  let outward-direction = if annotation.side in ("above", "left") {
    vector.left-normal(vector.normalized(span))
  } else {
    vector.right-normal(vector.normalized(span))
  }

  let brace-color = annotation-style.annotation-color(diagram-style, annotation)
  let brace-start = vector.point-along(
    span-start,
    outward-direction,
    annotation.offset,
  )
  let brace-end = vector.point-along(
    span-end,
    outward-direction,
    annotation.offset,
  )
  brace(
    brace-start,
    brace-end,
    amplitude: annotation.amplitude,
    pointiness: annotation.pointiness,
    flip: annotation.side in ("below", "right"),
    fill: brace-color,
    stroke: if annotation.stroke == auto { none } else {
      annotation.stroke + brace-color
    },
  )

  if annotation.label == none { return }
  let styled-label = text(
    ..annotation-style.annotation-text-style(
      diagram-style,
      annotation,
      brace-color,
    ),
    annotation.label,
  )
  content(
    vector.point-along(
      vector.midpoint(brace-start, brace-end),
      outward-direction,
      annotation.amplitude + annotation.label-offset,
    ),
    if annotation.label-rotation == 0deg {
      styled-label
    } else {
      rotate(annotation.label-rotation, reflow: false, styled-label)
    },
    anchor: "center",
  )
}

#let render-arrow(scene, annotation, diagram-style) = {
  let described-as = "arrow()"
  let path-points = (
    (annotation.from,) + annotation.via + (annotation.to,)
  ).map(waypoint => points.annotation-point(scene, waypoint, described-as))
  for waypoint-index in range(path-points.len() - 1) {
    assert(
      vector.magnitude(
        vector.subtract(
          path-points.at(waypoint-index + 1),
          path-points.at(waypoint-index),
        ),
      ) > 0.000001,
      message: (
        "typed-physics: arrow() has two points in a row at the same place; "
          + "every step of a path must go somewhere"
      ),
    )
  }

  let arrow-color = annotation-style.annotation-color(diagram-style, annotation)
  line(
    ..path-points,
    stroke: annotation-style.annotation-stroke(
      diagram-style,
      annotation,
      arrow-color,
    ),
    mark: (
      start: if annotation.arrows in ("both", "start") {
        annotation.arrow-tip
      } else { none },
      end: if annotation.arrows in ("both", "end") {
        annotation.arrow-tip
      } else { none },
      fill: arrow-color,
      stroke: arrow-color,
      scale: annotation.arrow-scale,
    ),
  )

  if annotation.label == none { return }
  // The label sits beside the end of the path it names, offset along the
  // normal of the segment it belongs to so it never lies over the line.
  let label-segment-index = if annotation.label-position == "start" {
    0
  } else if annotation.label-position == "center" {
    int((path-points.len() - 1) / 2)
  } else {
    path-points.len() - 2
  }
  let segment-start = path-points.at(label-segment-index)
  let segment-end = path-points.at(label-segment-index + 1)
  let anchor-point = if annotation.label-position == "start" {
    segment-start
  } else if annotation.label-position == "center" {
    vector.midpoint(segment-start, segment-end)
  } else {
    segment-end
  }
  let styled-label = text(
    ..annotation-style.annotation-text-style(
      diagram-style,
      annotation,
      arrow-color,
    ),
    annotation.label,
  )
  content(
    vector.point-along(
      anchor-point,
      vector.left-normal(
        vector.normalized(vector.subtract(segment-end, segment-start)),
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
