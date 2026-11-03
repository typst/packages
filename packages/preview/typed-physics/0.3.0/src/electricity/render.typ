// CeTZ rendering for placed electrical circuits.

#import "@preview/cetz:0.5.2"
#import cetz.draw: anchor, circle, content, group, line
#import "../shared/expression.typ"
#import "../shared/vector.typ"
#import "style.typ"

#let _displayed-number(value) = if type(value) in (int, float) {
  expression.format-number(value)
} else {
  value
}

#let _component-unit(component) = {
  if component.unit == none { return none }
  if component.unit != auto { return component.unit }
  if component.component-kind == "resistor" { return "Ω" }
  if component.component-kind == "capacitor" { return "F" }
  "V"
}

#let _component-value(component) = {
  let declared-value = if component.component-kind == "resistor" {
    component.resistance
  } else if component.component-kind == "capacitor" {
    component.capacitance
  } else {
    component.voltage
  }
  if declared-value == none { return none }
  let value = _displayed-number(declared-value)
  let unit = _component-unit(component)
  if unit == none { [#value] } else { [#value#h(0.14em)#unit] }
}

#let _component-name(component) = if component.label == auto {
  [#component.name]
} else {
  component.label
}

#let _component-label(component, labels) = {
  let name = _component-name(component)
  let value = _component-value(component)
  if labels == "none" or name == none { return none }
  if labels == "name" { return name }
  if labels == "value" { return value }
  if value == none { return name }
  [#name = #value]
}

#let _point-on-axis(center, direction, distance) = vector.point-along(
  center,
  direction,
  distance,
)

#let _render-label(
  placement,
  component-style,
  diagram-style,
  labels,
  rotate-with-component: false,
  symbol-half-height: 0,
  reserve-symbol-height: false,
) = {
  let label = _component-label(placement.component, labels)
  if label == none { return none }
  let direction = vector.normalized(
    vector.subtract(placement.end, placement.start),
  )
  let normal = vector.scale(
    vector.left-normal(direction),
    placement.label-side,
  )
  let component-angle = vector.angle-of(direction)
  let label-angle = if direction.at(0) < 0 {
    component-angle + if direction.at(1) < 0 { 180deg } else { -180deg }
  } else {
    component-angle
  }
  let label-is-rotated = rotate-with-component and label-angle != 0deg
  let label-distance = diagram-style.label-offset + if label-is-rotated {
    symbol-half-height + 0.18
  } else if reserve-symbol-height {
    symbol-half-height
  } else {
    0
  }
  let label-position = vector.point-along(
    vector.midpoint(placement.start, placement.end),
    normal,
    label-distance,
  )
  let label-anchor = if label-is-rotated {
    "center"
  } else if calc.abs(normal.at(0)) > calc.abs(normal.at(1)) {
    if normal.at(0) > 0 { "west" } else { "east" }
  } else if normal.at(1) > 0 {
    "south"
  } else {
    "north"
  }
  let styled-label = text(..component-style.text, label)
  content(
    label-position,
    if label-is-rotated {
      rotate(-label-angle, reflow: false, styled-label)
    } else {
      styled-label
    },
    anchor: label-anchor,
  )
}

#let _render-resistor(placement, diagram-style, labels) = {
  let component = placement.component
  let component-style = style.resolve-component-style(diagram-style, component)
  let direction = vector.normalized(
    vector.subtract(placement.end, placement.start),
  )
  let normal = vector.left-normal(direction)
  let center = vector.midpoint(placement.start, placement.end)
  let half-body-length = diagram-style.resistor-length / 2
  let half-body-height = diagram-style.resistor-height / 2
  let body-start = _point-on-axis(center, direction, -half-body-length)
  let body-end = _point-on-axis(center, direction, half-body-length)
  let first-corner = vector.point-along(
    body-start,
    normal,
    half-body-height,
  )
  let second-corner = vector.point-along(
    body-end,
    normal,
    half-body-height,
  )
  let third-corner = vector.point-along(
    body-end,
    normal,
    -half-body-height,
  )
  let fourth-corner = vector.point-along(
    body-start,
    normal,
    -half-body-height,
  )

  group(name: component.name, {
    line(placement.start, body-start, stroke: diagram-style.wire-stroke)
    line(body-end, placement.end, stroke: diagram-style.wire-stroke)
    if component-style.symbol == "rectangle" {
      line(
        first-corner,
        second-corner,
        third-corner,
        fourth-corner,
        close: true,
        fill: component-style.fill,
        stroke: component-style.stroke,
      )
    } else {
      let zigzag-points = (body-start,)
      let zigzag-peak-count = 8
      for peak-index in range(1, zigzag-peak-count + 1) {
        let position-along-body = _point-on-axis(
          body-start,
          direction,
          diagram-style.resistor-length
            * peak-index
            / (zigzag-peak-count + 1),
        )
        zigzag-points.push(vector.point-along(
          position-along-body,
          normal,
          if calc.rem(peak-index, 2) == 1 {
            half-body-height
          } else {
            -half-body-height
          },
        ))
      }
      zigzag-points.push(body-end)
      line(..zigzag-points, stroke: component-style.stroke)
    }
    anchor("start", placement.start)
    anchor("end", placement.end)
    anchor("center", center)
    anchor("default", center)
  })
  _render-label(
    placement,
    component-style,
    diagram-style,
    labels,
    rotate-with-component: true,
    symbol-half-height: half-body-height,
  )
}

#let _render-capacitor(placement, diagram-style, labels) = {
  let component = placement.component
  let component-style = style.resolve-component-style(diagram-style, component)
  let direction = vector.normalized(
    vector.subtract(placement.end, placement.start),
  )
  let normal = vector.left-normal(direction)
  let center = vector.midpoint(placement.start, placement.end)
  let half-plate-gap = diagram-style.capacitor-plate-gap / 2
  let half-plate-height = diagram-style.capacitor-plate-height / 2
  let first-plate-center = _point-on-axis(
    center,
    direction,
    -half-plate-gap,
  )
  let second-plate-center = _point-on-axis(
    center,
    direction,
    half-plate-gap,
  )

  group(name: component.name, {
    line(
      placement.start,
      first-plate-center,
      stroke: diagram-style.wire-stroke,
    )
    line(
      second-plate-center,
      placement.end,
      stroke: diagram-style.wire-stroke,
    )
    for plate-center in (first-plate-center, second-plate-center) {
      line(
        vector.point-along(plate-center, normal, half-plate-height),
        vector.point-along(plate-center, normal, -half-plate-height),
        stroke: component-style.stroke,
      )
    }
    anchor("start", placement.start)
    anchor("end", placement.end)
    anchor("first-plate", first-plate-center)
    anchor("second-plate", second-plate-center)
    anchor("center", center)
    anchor("default", center)
  })
  _render-label(
    placement,
    component-style,
    diagram-style,
    labels,
    rotate-with-component: true,
    symbol-half-height: half-plate-height,
    reserve-symbol-height: true,
  )
}

#let _render-voltage-source(placement, diagram-style, labels) = {
  let component = placement.component
  let component-style = style.resolve-component-style(diagram-style, component)
  let direction = vector.normalized(
    vector.subtract(placement.end, placement.start),
  )
  let center = vector.midpoint(placement.start, placement.end)
  let radius = diagram-style.source-radius
  let normal = vector.left-normal(direction)

  group(name: component.name, {
    if component-style.symbol == "circle" {
      let source-start = _point-on-axis(center, direction, -radius)
      let source-end = _point-on-axis(center, direction, radius)
      let sign-offset = radius * 0.42
      line(placement.start, source-start, stroke: diagram-style.wire-stroke)
      line(source-end, placement.end, stroke: diagram-style.wire-stroke)
      circle(
        center,
        radius: radius,
        fill: component-style.fill,
        stroke: component-style.stroke,
      )
      content(
        _point-on-axis(center, direction, sign-offset),
        text(size: 8pt)[+],
        anchor: "center",
      )
      content(
        _point-on-axis(center, direction, -sign-offset),
        text(size: 8pt)[−],
        anchor: "center",
      )
    } else {
      let half-plate-gap = diagram-style.source-plate-gap / 2
      let positive-plate-center = _point-on-axis(
        center,
        direction,
        half-plate-gap,
      )
      let negative-plate-center = _point-on-axis(
        center,
        direction,
        -half-plate-gap,
      )
      let positive-half-length = diagram-style.source-long-plate / 2
      let negative-half-length = diagram-style.source-short-plate / 2
      line(
        placement.start,
        negative-plate-center,
        stroke: diagram-style.wire-stroke,
      )
      line(
        positive-plate-center,
        placement.end,
        stroke: diagram-style.wire-stroke,
      )
      line(
        vector.point-along(
          positive-plate-center,
          normal,
          positive-half-length,
        ),
        vector.point-along(
          positive-plate-center,
          normal,
          -positive-half-length,
        ),
        stroke: component-style.stroke,
      )
      line(
        vector.point-along(
          negative-plate-center,
          normal,
          negative-half-length,
        ),
        vector.point-along(
          negative-plate-center,
          normal,
          -negative-half-length,
        ),
        stroke: component-style.stroke,
      )
    }
    anchor("negative", placement.start)
    anchor("positive", placement.end)
    anchor("center", center)
    anchor("default", center)
  })
  _render-label(placement, component-style, diagram-style, labels)
}

#let render-circuit(placed-circuit, diagram-style, labels: "both") = {
  for wire-path in placed-circuit.wires {
    line(..wire-path, stroke: diagram-style.wire-stroke)
  }
  for placement in placed-circuit.components {
    if placement.component.component-kind == "resistor" {
      _render-resistor(placement, diagram-style, labels)
    } else if placement.component.component-kind == "capacitor" {
      _render-capacitor(placement, diagram-style, labels)
    } else {
      _render-voltage-source(placement, diagram-style, labels)
    }
  }
  if diagram-style.show-junctions {
    for junction in placed-circuit.junctions {
      circle(
        junction,
        radius: 0.055,
        fill: diagram-style.junction-fill,
        stroke: none,
      )
    }
  }
}
