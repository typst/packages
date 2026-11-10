// Rendering and collision-aware extension geometry for dimensions.

#import "@preview/cetz:0.5.2"
#import cetz.draw: content, line
#import "vector.typ"
#import "placement.typ"
#import "render-geometry.typ" as geometry

#let body-corners = geometry.body-corners
#let rod-corners = geometry.rod-corners

#let _dimension-endpoint(scene, endpoint-reference) = {
  let endpoint-is-raw-coordinate = (
    type(endpoint-reference) == array
      and endpoint-reference.len() == 2
      and endpoint-reference.all(
        coordinate => type(coordinate) in (int, float),
      )
  )
  if endpoint-is-raw-coordinate { return endpoint-reference }

  if type(endpoint-reference) == dictionary {
    let connector-name = endpoint-reference.at("on", default: none)
    if scene.connectors.any(connector => connector.name == connector-name) {
      panic(
        "typed-physics: dimension() cannot use an (on:, at:) ratio along connector \""
          + connector-name
          + "\"; use \""
          + connector-name
          + ".start\", \".center\", or \".end\"",
      )
    }
  }

  if type(endpoint-reference) == str {
    let reference-parts = endpoint-reference.split(".")
    assert(
      reference-parts.len() <= 2,
      message: "typed-physics: dimension() endpoint \"" + endpoint-reference + "\" must name one anchor",
    )
    let element-name = reference-parts.first()
    let connector = scene.connectors.find(
      placed-connector => placed-connector.name == element-name,
    )
    if connector != none {
      let anchor-name = if reference-parts.len() == 2 {
        reference-parts.at(1)
      } else {
        "center"
      }
      assert(
        anchor-name in ("start", "end", "center"),
        message: "typed-physics: connector \"" + element-name + "\" has start, end, and center anchors",
      )
      return if anchor-name == "start" {
        connector.start
      } else if anchor-name == "end" {
        connector.end
      } else {
        vector.midpoint(connector.start, connector.end)
      }
    }
  }

  placement.resolve-attachment-point(
    endpoint-reference,
    scene.surfaces,
    scene.bodies,
    scene.pulleys,
    "dimension()",
    placed-structures: scene.structures,
  )
}

#let _dimension-arrow-marks(dimension-annotation, dimension-color) = (
  start: if dimension-annotation.arrows in ("both", "start") {
    dimension-annotation.arrow-tip
  } else {
    none
  },
  end: if dimension-annotation.arrows in ("both", "end") {
    dimension-annotation.arrow-tip
  } else {
    none
  },
  fill: dimension-color,
  stroke: dimension-color,
  scale: dimension-annotation.arrow-scale,
)

#let _projection-segment-intersection-distance(
  projection-start,
  projection-direction,
  projection-length,
  segment-start,
  segment-end,
) = {
  let segment-vector = vector.subtract(segment-end, segment-start)
  let start-to-segment = vector.subtract(segment-start, projection-start)
  let direction-cross-segment = vector.cross-product(
    projection-direction,
    segment-vector,
  )
  if calc.abs(direction-cross-segment) > 0.000001 {
    let distance-along-projection = (
      vector.cross-product(start-to-segment, segment-vector)
        / direction-cross-segment
    )
    let ratio-along-segment = (
      vector.cross-product(start-to-segment, projection-direction)
        / direction-cross-segment
    )
    if (
      distance-along-projection >= 0
        and distance-along-projection <= projection-length
        and ratio-along-segment >= 0
        and ratio-along-segment <= 1
    ) {
      return distance-along-projection
    }
    return none
  }

  let segments-are-collinear = calc.abs(
    vector.cross-product(start-to-segment, projection-direction),
  ) <= 0.000001
  if not segments-are-collinear { return none }
  let first-end-distance = vector.dot-product(
    start-to-segment,
    projection-direction,
  )
  let second-end-distance = vector.dot-product(
    vector.subtract(segment-end, projection-start),
    projection-direction,
  )
  let overlap-start = calc.max(
    0,
    calc.min(first-end-distance, second-end-distance),
  )
  let overlap-end = calc.min(
    projection-length,
    calc.max(first-end-distance, second-end-distance),
  )
  if overlap-start <= overlap-end { overlap-start } else { none }
}

#let _projection-circle-intersection-distance(
  projection-start,
  projection-direction,
  projection-length,
  circle-center,
  circle-radius,
) = {
  let center-to-start = vector.subtract(projection-start, circle-center)
  let signed-center-distance = vector.dot-product(
    center-to-start,
    projection-direction,
  )
  let discriminant = (
    signed-center-distance * signed-center-distance
      - (
        vector.dot-product(center-to-start, center-to-start)
          - circle-radius * circle-radius
      )
  )
  if discriminant < 0 { return none }
  let root = calc.sqrt(discriminant)
  let entry-distance = -signed-center-distance - root
  let exit-distance = -signed-center-distance + root
  if entry-distance >= 0 and entry-distance <= projection-length {
    entry-distance
  } else if exit-distance >= 0 and exit-distance <= projection-length {
    exit-distance
  } else {
    none
  }
}

#let _projection-polygon-intersection-distances(
  projection-start,
  projection-direction,
  projection-length,
  polygon-corners,
) = {
  let intersection-distances = ()
  for corner-index in range(polygon-corners.len()) {
    let intersection-distance = _projection-segment-intersection-distance(
      projection-start,
      projection-direction,
      projection-length,
      polygon-corners.at(corner-index),
      polygon-corners.at(calc.rem(corner-index + 1, polygon-corners.len())),
    )
    if intersection-distance != none {
      intersection-distances.push(intersection-distance)
    }
  }
  intersection-distances
}

#let _nearest-projection-collision-distance(
  scene,
  projection-start,
  measured-point,
) = {
  let projection-vector = vector.subtract(measured-point, projection-start)
  let projection-length = vector.magnitude(projection-vector)
  if projection-length == 0 { return 0 }
  let projection-direction = vector.normalized(projection-vector)
  let collision-distances = ()

  for body-name in scene.body-order {
    let body = scene.bodies.at(body-name)
    if body.shape == "block" {
      collision-distances += _projection-polygon-intersection-distances(
        projection-start,
        projection-direction,
        projection-length,
        body-corners(body),
      )
    } else {
      let collision-distance = _projection-circle-intersection-distance(
        projection-start,
        projection-direction,
        projection-length,
        body.center,
        body.half-extent-along,
      )
      if collision-distance != none {
        collision-distances.push(collision-distance)
      }
    }
  }

  for structure-name in scene.structure-order {
    let placed-structure = scene.structures.at(structure-name)
    if placed-structure.kind == "rod" {
      collision-distances += _projection-polygon-intersection-distances(
        projection-start,
        projection-direction,
        projection-length,
        rod-corners(placed-structure),
      )
    }
  }

  for surface-name in scene.surface-order {
    let surface = scene.surfaces.at(surface-name)
    if surface.kind != "arc" {
      let collision-distance = _projection-segment-intersection-distance(
        projection-start,
        projection-direction,
        projection-length,
        surface.start,
        surface.end,
      )
      if collision-distance != none {
        collision-distances.push(collision-distance)
      }
    }
  }

  if collision-distances.len() == 0 {
    projection-length
  } else {
    calc.min(..collision-distances)
  }
}

#let _render-dimension-extension(
  scene,
  dimension-point,
  measured-point,
  extension-gap,
  extension-stroke,
) = {
  let projection-vector = vector.subtract(measured-point, dimension-point)
  let projection-length = vector.magnitude(projection-vector)
  if projection-length == 0 { return }
  let projection-direction = vector.normalized(projection-vector)
  let collision-distance = _nearest-projection-collision-distance(
    scene,
    dimension-point,
    measured-point,
  )
  let visible-extension-length = calc.max(
    0,
    collision-distance - extension-gap,
  )
  if visible-extension-length > 0 {
    line(
      dimension-point,
      vector.point-along(
        dimension-point,
        projection-direction,
        visible-extension-length,
      ),
      stroke: extension-stroke,
    )
  }
}

#let _dimension-line-geometry(
  measured-start,
  measured-end,
  orientation,
  side,
  offset,
) = {
  if orientation == "horizontal" {
    let horizontal-span = measured-end.at(0) - measured-start.at(0)
    assert(
      calc.abs(horizontal-span) > 0.000001,
      message: "typed-physics: a horizontal dimension needs endpoints with different x coordinates",
    )
    let dimension-height = if side == "above" {
      calc.max(measured-start.at(1), measured-end.at(1)) + offset
    } else {
      calc.min(measured-start.at(1), measured-end.at(1)) - offset
    }
    return (
      start: (measured-start.at(0), dimension-height),
      end: (measured-end.at(0), dimension-height),
    )
  }

  if orientation == "vertical" {
    let vertical-span = measured-end.at(1) - measured-start.at(1)
    assert(
      calc.abs(vertical-span) > 0.000001,
      message: "typed-physics: a vertical dimension needs endpoints with different y coordinates",
    )
    let dimension-horizontal-position = if side == "right" {
      calc.max(measured-start.at(0), measured-end.at(0)) + offset
    } else {
      calc.min(measured-start.at(0), measured-end.at(0)) - offset
    }
    return (
      start: (dimension-horizontal-position, measured-start.at(1)),
      end: (dimension-horizontal-position, measured-end.at(1)),
    )
  }

  let measured-span = vector.subtract(measured-end, measured-start)
  let measured-direction = vector.normalized(measured-span)
  let left-normal-direction = vector.left-normal(measured-direction)
  let dimension-normal-direction = if side in ("above", "left") {
    left-normal-direction
  } else {
    vector.reversed(left-normal-direction)
  }
  (
    start: vector.point-along(
      measured-start,
      dimension-normal-direction,
      offset,
    ),
    end: vector.point-along(
      measured-end,
      dimension-normal-direction,
      offset,
    ),
  )
}

#let render-dimension(scene, dimension-annotation, diagram-style) = {
  let measured-start = _dimension-endpoint(
    scene,
    dimension-annotation.from,
  )
  let measured-end = _dimension-endpoint(scene, dimension-annotation.to)
  let measured-span = vector.subtract(measured-end, measured-start)
  let measured-length = vector.magnitude(measured-span)
  assert(
    measured-length > 0,
    message: "typed-physics: dimension() endpoints must not coincide",
  )

  let dimension-line = _dimension-line-geometry(
    measured-start,
    measured-end,
    dimension-annotation.orientation,
    dimension-annotation.side,
    dimension-annotation.offset,
  )
  let dimension-start = dimension-line.start
  let dimension-end = dimension-line.end
  let dimension-direction = vector.normalized(
    vector.subtract(dimension-end, dimension-start),
  )
  let left-normal-direction = vector.left-normal(dimension-direction)

  let dimension-color = if dimension-annotation.color == auto {
    diagram-style.dimension-color
  } else {
    dimension-annotation.color
  }
  let dimension-stroke = (
    if dimension-annotation.stroke == auto {
      diagram-style.dimension-stroke
    } else {
      dimension-annotation.stroke
    }
  ) + dimension-color

  if dimension-annotation.extensions and dimension-annotation.offset > 0 {
    let declared-extension-stroke = if dimension-annotation.extension-stroke == auto {
      diagram-style.dimension-extension-stroke
    } else {
      dimension-annotation.extension-stroke
    }
    let extension-stroke = if type(declared-extension-stroke) == dictionary {
      declared-extension-stroke + (paint: dimension-color)
    } else {
      declared-extension-stroke + dimension-color
    }
    _render-dimension-extension(
      scene,
      dimension-start,
      measured-start,
      dimension-annotation.extension-gap,
      extension-stroke,
    )
    _render-dimension-extension(
      scene,
      dimension-end,
      measured-end,
      dimension-annotation.extension-gap,
      extension-stroke,
    )
  }

  line(
    dimension-start,
    dimension-end,
    stroke: dimension-stroke,
    mark: _dimension-arrow-marks(dimension-annotation, dimension-color),
  )

  if dimension-annotation.label == none { return }
  let displayed-label = if dimension-annotation.label == auto {
    $L$
  } else {
    dimension-annotation.label
  }
  let dimension-text-style = (
    (fill: dimension-color)
      + diagram-style.dimension-text
      + dimension-annotation.text
  )
  let styled-label = text(..dimension-text-style, displayed-label)
  let label-is-centered = dimension-annotation.label-position == "center"
  let label-body = if label-is-centered {
    box(
      fill: dimension-annotation.label-fill,
      inset: (x: 0.22em, y: 0.06em),
      styled-label,
    )
  } else {
    styled-label
  }
  let label-normal-direction = if dimension-annotation.label-position == "below" {
    vector.reversed(left-normal-direction)
  } else {
    left-normal-direction
  }
  let label-position = if label-is-centered {
    vector.midpoint(dimension-start, dimension-end)
  } else {
    vector.point-along(
      vector.midpoint(dimension-start, dimension-end),
      label-normal-direction,
      dimension-annotation.label-offset,
    )
  }
  content(
    label-position,
    if dimension-annotation.label-rotation == 0deg {
      label-body
    } else {
      rotate(
        dimension-annotation.label-rotation,
        reflow: false,
        label-body,
      )
    },
    anchor: "center",
  )
}

#let render-dimensions(scene, dimensions, diagram-style) = {
  let dimension-annotations = if dimensions == none {
    ()
  } else if type(dimensions) == dictionary {
    (dimensions,)
  } else {
    assert(
      type(dimensions) == array,
      message: "typed-physics: dimensions: must be dimension(...) or an array of them",
    )
    dimensions
  }
  for dimension-annotation in dimension-annotations {
    assert(
      type(dimension-annotation) == dictionary
        and dimension-annotation.at("kind", default: none) == "dimension",
      message: "typed-physics: dimensions: accepts only dimension(...) annotations",
    )
    let dimension-fields = (
      "kind", "from", "to", "orientation", "offset", "side", "label",
      "label-position", "label-offset", "label-rotation", "label-fill",
      "arrows", "arrow-tip", "arrow-scale", "extensions", "extension-gap",
      "extension-stroke", "stroke", "color", "text",
    )
    for field in dimension-annotation.keys() {
      assert(
        field in dimension-fields,
        message: (
          "typed-physics: dimensions: annotation has unknown field `"
            + field
            + ":`; create it with dimension() to validate its arguments"
        ),
      )
    }
    let missing-fields = dimension-fields.filter(
      field => field not in dimension-annotation,
    )
    assert(
      missing-fields.len() == 0,
      message: (
        "typed-physics: dimensions: malformed dimension annotation is missing "
          + missing-fields.map(field => "`" + field + ":`").join(", ")
          + "; create it with dimension()"
      ),
    )
    render-dimension(scene, dimension-annotation, diagram-style)
  }
}

// Which bodies a view argument names: none, one, several, or all of them.
