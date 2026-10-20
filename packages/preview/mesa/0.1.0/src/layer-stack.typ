#import "@preview/cetz:0.5.2"
#import "palette.typ": default-palette
#import "geometry.typ": (
  add as _add,
  scale as _scale,
  dot as _dot,
  unit as _unit,
  dot-2d as _dot-2d,
  center-2d as _center-2d,
)
#import "lighting.typ": (
  toward-light as _toward-light,
  face-brightness as _face-brightness,
  face-visibility as _face-visibility,
)
#import "projection.typ": (
  device-to-cetz as _device-to-cetz,
  ortho-view as _ortho-view,
  resolve-known-anchor as _resolve-known-anchor,
  project as _project,
  face-horizontal as _face-horizontal,
)
#import "draw.typ" as semi-draw
#import "scene.typ" as _scene
#import "kernel.typ" as _kernel

#let _merge-dictionaries(base, overrides) = {
  let merged = base
  for (key, value) in overrides {
    merged.insert(key, value)
  }
  merged
}

#let _resolve-bevel-value(value, thickness, name) = {
  assert(
    type(value) in (int, float, ratio),
    message: name + " bevel must be a number or ratio",
  )
  let result = if type(value) == ratio {
    thickness * (value / 100%)
  } else {
    value
  }
  assert(result >= 0, message: name + " bevel must be non-negative")
  result
}

#let _bevel-config(value, thickness, width, depth, fade-bottom) = {
  let value = if value == none {
    (top: 0, bottom: 0)
  } else if type(value) in (int, float, ratio) {
    (top: value, bottom: value)
  } else {
    assert(
      type(value) == dictionary,
      message: "bevel must be none, a number, a ratio, or a dictionary",
    )
    value
  }
  let top = _resolve-bevel-value(
    value.at("top", default: 0),
    thickness,
    "top",
  )
  let bottom = if fade-bottom == none {
    _resolve-bevel-value(
      value.at("bottom", default: 0),
      thickness,
      "bottom",
    )
  } else {
    0
  }
  assert(
    top + bottom < thickness,
    message: "top and bottom bevels must leave a positive vertical face",
  )
  assert(
    calc.max(top, bottom) < calc.min(width, depth) / 2,
    message: "bevel is too large for the layer footprint",
  )
  (top: top, bottom: bottom)
}

#let _fade-config(value) = {
  let config = if type(value) == color {
    (start: 70%, end: 95%, color: value)
  } else {
    assert(
      type(value) == dictionary,
      message: "fade-bottom must be a color, dictionary, or none",
    )
    value
  }
  let start = config.at(
    "start",
    default: 100% - config.at("size", default: 30%),
  )
  let end = config.at("end", default: 95%)
  let target = config.at("color", default: white)
  assert(
    type(start) == ratio
      and type(end) == ratio
      and start >= 0%
      and start < end
      and end <= 100%,
    message: "fade-bottom requires 0% <= start < end <= 100%",
  )
  assert(
    type(target) == color,
    message: "fade-bottom color must be a color",
  )
  (start: start, end: end, color: target)
}

#let _mix-color(from, to, amount) = color.mix(
  (from, 100% - amount),
  (to, amount),
)

#let _fade-stops(from, to, start, end) = {
  let span = end - start
  (
    (from, 0%),
    (from, start),
    (_mix-color(from, to, 2.8%), start + span * 10%),
    (_mix-color(from, to, 10.4%), start + span * 20%),
    (_mix-color(from, to, 21.6%), start + span * 30%),
    (_mix-color(from, to, 35.2%), start + span * 40%),
    (_mix-color(from, to, 50%), start + span * 50%),
    (_mix-color(from, to, 64.8%), start + span * 60%),
    (_mix-color(from, to, 78.4%), start + span * 70%),
    (_mix-color(from, to, 89.6%), start + span * 80%),
    (_mix-color(from, to, 97.2%), start + span * 90%),
    (to, end),
    (to, 100%),
  )
}

#let _stroke-with-paint(value, paint) = {
  let base = stroke(value)

  stroke(
    paint: paint,
    thickness: base.thickness,
    cap: base.cap,
    join: base.join,
    dash: base.dash,
    miter-limit: base.miter-limit,
  )
}

#let _automatic-label-z(style) = {
  let fade = style.at("fade-bottom", default: none)
  if fade == none {
    return 50%
  }

  let config = _fade-config(fade)
  let start = config.start / 100%
  let span = (config.end - config.start) / 100%
  let mass = start + span / 2
  let moment = start * start / 2 + span * (
    start / 2 + span * 3 / 20
  )
  (1 - moment / mass) * 100%
}

#let _label-coordinate(layer, value) = {
  if type(value) == str and not value.contains(".") {
    layer + "." + value
  } else if type(value) == dictionary and "to" in value {
    let result = value
    result.to = _label-coordinate(layer, value.to)
    result
  } else {
    value
  }
}

#let _fade-geometry(points, camera, start, end) = {
  let heights = points.map(point => point.at(2))
  let bottom = calc.min(..heights)
  let top = calc.max(..heights)
  let projected = points.map(point => _project(point, camera))
  let projected-top = (
    for (point, projected-point) in points.zip(projected) {
      if point.at(2) == top {
        (projected-point,)
      }
    }
  )
  let projected-bottom = (
    for (point, projected-point) in points.zip(projected) {
      if point.at(2) == bottom {
        (projected-point,)
      }
    }
  )
  let top-center = _center-2d(projected-top)
  let bottom-center = _center-2d(projected-bottom)
  let horizontal = none
  for first in points {
    for second in points {
      let difference = (
        second.at(0) - first.at(0),
        second.at(1) - first.at(1),
      )
      if (
        horizontal == none
        and calc.abs(difference.at(0)) + calc.abs(difference.at(1)) > .000001
      ) {
        horizontal = (first, difference)
      }
    }
  }
  if horizontal == none {
    return (
      angle: 90deg,
      start: start,
      end: end,
    )
  }
  let (origin, direction) = horizontal
  let projected-origin = _project(origin, camera)
  let projected-end = _project((
    origin.at(0) + direction.at(0),
    origin.at(1) + direction.at(1),
    origin.at(2),
  ), camera)
  let edge = (
    projected-end.at(0) - projected-origin.at(0),
    projected-end.at(1) - projected-origin.at(1),
  )
  if calc.abs(edge.at(0)) + calc.abs(edge.at(1)) < .000001 {
    return (
      angle: 90deg,
      start: start,
      end: end,
    )
  }
  let normal = (-edge.at(1), edge.at(0))
  let down = (
    bottom-center.at(0) - top-center.at(0),
    bottom-center.at(1) - top-center.at(1),
  )
  if _dot-2d(normal, down) < 0 {
    normal = (-normal.at(0), -normal.at(1))
  }

  let xs = projected.map(point => point.at(0))
  let ys = projected.map(point => point.at(1))
  let x-min = calc.min(..xs)
  let x-max = calc.max(..xs)
  let y-min = calc.min(..ys)
  let y-max = calc.max(..ys)
  let box-min = normal.at(0) * (
    if normal.at(0) >= 0 { x-min } else { x-max }
  ) + normal.at(1) * (
    if normal.at(1) >= 0 { y-min } else { y-max }
  )
  let box-max = normal.at(0) * (
    if normal.at(0) >= 0 { x-max } else { x-min }
  ) + normal.at(1) * (
    if normal.at(1) >= 0 { y-max } else { y-min }
  )
  let top-position = _dot-2d(top-center, normal)
  let bottom-position = _dot-2d(bottom-center, normal)
  let start-position = top-position + (
    bottom-position - top-position
  ) * (start / 100%)
  let end-position = top-position + (
    bottom-position - top-position
  ) * (end / 100%)
  let span = box-max - box-min

  (
    angle: calc.atan2(normal.at(0), normal.at(1)),
    start: calc.max(0, calc.min(1, (start-position - box-min) / span)) * 100%,
    end: calc.max(0, calc.min(1, (end-position - box-min) / span)) * 100%,
  )
}

#let _draw-faded-outline(points, value, config, camera) = {
  let heights = points.map(point => point.at(2))
  let top = calc.max(..heights)
  let base = stroke(value)
  let paint = if base.paint == auto { black } else { base.paint }
  assert(
    type(paint) == color,
    message: "a face with fade-bottom must use a solid-color stroke",
  )

  for index in range(points.len()) {
    let start = points.at(index)
    let end = points.at(calc.rem(index + 1, points.len()))
    if start.at(2) == top and end.at(2) == top {
      cetz.draw.line(start, end, stroke: base)
    } else if start.at(2) != end.at(2) {
      let low = if start.at(2) < end.at(2) { start } else { end }
      let high = if start.at(2) < end.at(2) { end } else { start }
      let projected-high = _project(high, camera)
      let projected-low = _project(low, camera)
      let direction = (
        projected-low.at(0) - projected-high.at(0),
        projected-low.at(1) - projected-high.at(1),
      )
      let outline-paint = gradient.linear(
        .._fade-stops(
          paint,
          config.color,
          config.start,
          config.end,
        ),
        angle: calc.atan2(direction.at(0), direction.at(1)),
        relative: "self",
      )
      cetz.draw.line(
        high,
        low,
        stroke: _stroke-with-paint(base, outline-paint),
      )
    }
  }
}

#let _draw-faded-edge(high, low, value, config, camera) = {
  let base = stroke(value)
  let paint = if base.paint == auto { black } else { base.paint }
  let projected-high = _project(high, camera)
  let projected-low = _project(low, camera)
  let direction = (
    projected-low.at(0) - projected-high.at(0),
    projected-low.at(1) - projected-high.at(1),
  )
  let outline-paint = gradient.linear(
    .._fade-stops(
      paint,
      config.color,
      config.start,
      config.end,
    ),
    angle: calc.atan2(direction.at(0), direction.at(1)),
    relative: "self",
  )
  cetz.draw.line(
    (projected-high.at(0), -projected-high.at(1), 0),
    (projected-low.at(0), -projected-low.at(1), 0),
    stroke: _stroke-with-paint(base, outline-paint),
  )
}

#let _draw-beveled-outline(
  width,
  depth,
  bottom,
  top,
  top-bevel,
  bottom-bevel,
  style,
  camera,
  draw-top,
) = {
  let value = style.at("stroke", default: 1pt + black)
  let internal-value = style.at("internal-stroke", default: none)
  if internal-value == auto {
    internal-value = value
  }
  if value == none and internal-value == none {
    return
  }
  let top-shoulder = top - top-bevel
  let bottom-shoulder = bottom + bottom-bevel
  let outer = (
    (0, 0),
    (width, 0),
    (width, depth),
    (0, depth),
  )
  let top-ring = (
    (top-bevel, top-bevel, top),
    (width - top-bevel, top-bevel, top),
    (width - top-bevel, depth - top-bevel, top),
    (top-bevel, depth - top-bevel, top),
  )
  let bottom-ring = (
    (bottom-bevel, bottom-bevel, bottom),
    (width - bottom-bevel, bottom-bevel, bottom),
    (width - bottom-bevel, depth - bottom-bevel, bottom),
    (bottom-bevel, depth - bottom-bevel, bottom),
  )
  let fade-bottom = style.at("fade-bottom", default: none)
  let fade-config = if fade-bottom == none {
    none
  } else {
    _fade-config(fade-bottom)
  }
  let project = point => {
    let projected = _project(point, camera)
    (projected.at(0), -projected.at(1), 0)
  }
  let azimuth = camera.at("azimuth", default: 0deg)
  let visible-sides = (
    if calc.sin(azimuth) < 0 { "back" } else { "front" },
    if calc.cos(azimuth) < 0 { "left" } else { "right" },
  )
  let side-edges = (
    front: (0, 1),
    right: (1, 2),
    back: (2, 3),
    left: (3, 0),
  )
  let visible-edges = ()
  let visible-corners = ()
  for side in visible-sides {
    let horizontal = _face-horizontal(camera, side)
    let projected-length = calc.sqrt(_dot-2d(horizontal, horizontal))
    if projected-length > 1e-6 {
      let edge = side-edges.at(side)
      visible-edges.push(edge)
      for corner in edge {
        if corner not in visible-corners {
          visible-corners.push(corner)
        }
      }
    }
  }

  if value != none {
    if draw-top {
      cetz.draw.line(..top-ring.map(project), close: true, stroke: value)
    }
    if fade-config == none {
      for edge in visible-edges {
        cetz.draw.line(
          project(bottom-ring.at(edge.first())),
          project(bottom-ring.at(edge.last())),
          stroke: value,
        )
      }
    }
    for index in visible-corners {
      let corner = outer.at(index)
      let lower = (corner.at(0), corner.at(1), bottom-shoulder)
      let upper = (corner.at(0), corner.at(1), top-shoulder)
      if fade-config == none {
        let points = (
          bottom-ring.at(index),
          lower,
          upper,
          top-ring.at(index),
        )
        cetz.draw.line(..points.map(project), stroke: value)
      } else {
        _draw-faded-edge(upper, lower, value, fade-config, camera)
        let points = (upper, top-ring.at(index))
        cetz.draw.line(..points.map(project), stroke: value)
      }
    }
  }

  if internal-value != none {
    for edge in visible-edges {
      let start = edge.first()
      let end = edge.last()
      if top-bevel > 0 {
        cetz.draw.line(
          project((
            outer.at(start).at(0),
            outer.at(start).at(1),
            top-shoulder,
          )),
          project((
            outer.at(end).at(0),
            outer.at(end).at(1),
            top-shoulder,
          )),
          stroke: internal-value,
        )
        if not draw-top {
          cetz.draw.line(
            project(top-ring.at(start)),
            project(top-ring.at(end)),
            stroke: internal-value,
          )
        }
      }
      if bottom-bevel > 0 {
        cetz.draw.line(
          project((
            outer.at(start).at(0),
            outer.at(start).at(1),
            bottom-shoulder,
          )),
          project((
            outer.at(end).at(0),
            outer.at(end).at(1),
            bottom-shoulder,
          )),
          stroke: internal-value,
        )
      }
    }
  }
}

#let _queue-beveled-outline(
  width,
  depth,
  bottom,
  top,
  top-bevel,
  bottom-bevel,
  style,
  camera,
) = {
  cetz.draw.set-ctx(ctx => {
    ctx.shared-state.semi.outlines.push((
      width: width,
      depth: depth,
      bottom: bottom,
      top: top,
      top-bevel: top-bevel,
      bottom-bevel: bottom-bevel,
      style: style,
      camera: camera,
    ))
    ctx
  })
}

#let _material-style(material, variant, occurrence, local-style, palette) = {
  assert.eq(
    local-style.pos(),
    (),
    message: "layer accepts only named style overrides",
  )

  let family = if material == auto {
    palette.default
  } else {
    if material not in palette {
      panic("unknown material: " + repr(material))
    }
    palette.at(material)
  }

  let variants = if type(family) == array {
    family
  } else {
    (family,)
  }
  assert(variants.len() > 0, message: "material style family cannot be empty")

  let index = if variant == auto {
    calc.rem(occurrence, variants.len())
  } else {
    assert(
      type(variant) == int and variant >= 1 and variant <= variants.len(),
      message: "variant must be between 1 and "
        + str(variants.len())
        + " for material "
        + repr(material),
    )
    variant - 1
  }
  let style = variants.at(index)

  if type(style) == color {
    style = (fill: style)
  }
  assert(
    type(style) == dictionary,
    message: "material variants must be colors or style dictionaries",
  )

  let local-style = local-style.named()
  let result = _merge-dictionaries(style, local-style)
  if "fill" in local-style and "base-color" not in local-style {
    if type(local-style.fill) == color {
      result.base-color = local-style.fill
    } else if "base-color" in result {
      let _ = result.remove("base-color")
    }
  }
  result
}

#let _render-face(
  points,
  normal,
  style,
  shading,
  light,
  camera,
  visibility,
) = {
  let face-style = style
  let fade-bottom = face-style.at("fade-bottom", default: none)
  if "fade-bottom" in face-style {
    let _ = face-style.remove("fade-bottom")
  }
  if "base-color" in face-style {
    let _ = face-style.remove("base-color")
  }
  let fill = face-style.at("fill", default: none)
  let brightness = _face-brightness(
    normal,
    shading,
    light,
    visibility: visibility,
  )
  let outline = style.at("stroke", default: 1pt + black)
  let fades = fade-bottom != none and normal.at(2) == 0
  let config = if fades { _fade-config(fade-bottom) } else { none }
  let geometry = if fades {
    _fade-geometry(points, camera, config.start, config.end)
  } else {
    none
  }
  let shaded-fill = if type(fill) == color {
    fill.darken((1 - brightness) * 100%)
  } else {
    fill
  }

  if fade-bottom != none and normal.at(2) < 0 {
    return
  }

  if fades {
    assert(
      type(shaded-fill) == color,
      message: "a face with fade-bottom must use a solid-color fill",
    )
    face-style.fill = gradient.linear(
      .._fade-stops(
        shaded-fill,
        config.color,
        geometry.start,
        geometry.end,
      ),
      angle: geometry.angle,
      relative: "self",
    )
    face-style.stroke = none
  } else {
    face-style.fill = shaded-fill
    if "stroke" in face-style {
      face-style.stroke = outline
    }
  }

  cetz.draw.line(
    ..points,
    close: true,
    ..face-style,
  )

  if (
    shading in ("flat", "fancy")
    and fill != none
    and type(fill) != color
  ) {
    cetz.draw.line(
      ..points,
      close: true,
      fill: black.transparentize(brightness * 100%),
      stroke: none,
    )
  }

  if fades and outline != none {
    _draw-faded-outline(
      points,
      outline,
      config,
      camera,
    )
  }
}

#let _render-scene-face(face, volume) = {
  let normal = _unit(face.normal)
  let style = volume.style
  let bevel-face = (
    calc.abs(normal.at(2)) > 1e-6
      and (
        calc.abs(normal.at(0)) > 1e-6
          or calc.abs(normal.at(1)) > 1e-6
      )
  )
  let fill = if bevel-face {
    style.at("base-color", default: style.at("fill", default: none))
  } else {
    style.at("fill", default: none)
  }
  let fade-bottom = style.at("fade-bottom", default: none)
  let fades = fade-bottom != none and normal.at(2) == 0
  let brightness = _face-brightness(
    normal,
    volume.shading,
    volume.light,
  )
  let shaded-fill = if type(fill) == color {
    fill.darken((1 - brightness) * 100%)
  } else {
    fill
  }
  let face-fill = if fades {
    let config = _fade-config(fade-bottom)
    let points = ()
    for contour in face.contours {
      points += contour
    }
    let geometry = _fade-geometry(
      points,
      volume.camera,
      config.start,
      config.end,
    )
    gradient.linear(
      .._fade-stops(
        shaded-fill,
        config.color,
        geometry.start,
        geometry.end,
      ),
      angle: geometry.angle,
      relative: "self",
    )
  } else {
    shaded-fill
  }

  cetz.draw.compound-path({
    for contour in face.contours {
      cetz.draw.line(..contour, close: true)
    }
  }, fill: face-fill, fill-rule: "even-odd", stroke: none)

  if (
    volume.shading in ("flat", "fancy")
    and fill != none
    and type(fill) != color
  ) {
    cetz.draw.compound-path({
      for contour in face.contours {
        cetz.draw.line(..contour, close: true)
      }
    }, fill: black.transparentize(brightness * 100%), fill-rule: "even-odd", stroke: none)
  }
}

#let _draw-faded-scene-edge(high, low, value, config, camera) = {
  let base = stroke(value)
  let paint = if base.paint == auto { black } else { base.paint }
  let projected-high = _project(high, camera)
  let projected-low = _project(low, camera)
  let direction = (
    projected-low.at(0) - projected-high.at(0),
    projected-low.at(1) - projected-high.at(1),
  )
  let outline-paint = gradient.linear(
    .._fade-stops(
      paint,
      config.color,
      config.start,
      config.end,
    ),
    angle: calc.atan2(direction.at(0), direction.at(1)),
    relative: "self",
  )
  cetz.draw.line(
    high,
    low,
    stroke: _stroke-with-paint(base, outline-paint),
  )
}

#let _render-scene-edge(edge, volumes, value) = {
  if edge.kind == "bevel" {
    let values = edge.materials.map(
      material => volumes.at(material).style.at(
        "internal-stroke",
        default: none,
      ),
    ).filter(value => value != none)
    if values.len() == 0 {
      return
    }
    value = values.first()
  }
  if edge.materials.len() == 1 {
    let volume = volumes.at(edge.materials.first())
    let fade-bottom = volume.style.at("fade-bottom", default: none)
    if fade-bottom != none {
      let same-height = calc.abs(edge.start.at(2) - edge.end.at(2)) < 1e-6
      if (
        same-height
        and calc.abs(edge.start.at(2) - volume.bottom) < 1e-6
      ) {
        return
      }
      let vertical = (
        calc.abs(edge.start.at(0) - edge.end.at(0)) < 1e-6
          and calc.abs(edge.start.at(1) - edge.end.at(1)) < 1e-6
      )
      if vertical {
        let high = if edge.start.at(2) > edge.end.at(2) {
          edge.start
        } else {
          edge.end
        }
        let low = if edge.start.at(2) > edge.end.at(2) {
          edge.end
        } else {
          edge.start
        }
        _draw-faded-scene-edge(
          high,
          low,
          value,
          _fade-config(fade-bottom),
          volume.camera,
        )
        return
      }
    }
  }
  cetz.draw.line(edge.start, edge.end, stroke: value)
}

#let _face(points, normal, style, shading, light, camera) = {
  if style.at("fade-bottom", default: none) != none and normal.at(2) < 0 {
    return
  }
  cetz.draw.set-ctx(ctx => {
    let state = ctx.shared-state.semi
    state.faces.push((
      layer: state.layers.len(),
      points: points,
      normal: normal,
      style: style,
      shading: shading,
      light: light,
      camera: camera,
    ))
    ctx.shared-state.semi = state
    ctx
  })
}

#let _cut-config(cut) = {
  if cut == none {
    return none
  }
  if type(cut) == array {
    return (plane: cut, keep: "left")
  }
  assert(
    type(cut) == dictionary and "plane" in cut,
    message: "cut must be a plane or a dictionary with plane and keep",
  )
  (
    plane: cut.plane,
    keep: cut.at("keep", default: "left"),
  )
}

#let _horizontal-section(section) = {
  assert(
    type(section) == array and section.len() == 2,
    message: "section must be a plane",
  )
  let (start, end) = section
  assert(
    type(start) == array
      and start.len() == 2
      and type(end) == array
      and end.len() == 2,
    message: "section plane points must be (x, y)",
  )
  assert(
    start.at(1) == end.at(1),
    message: "only face-parallel sections are supported for now",
  )
  start.at(1)
}

#let _draw-scene(debug: none) = {
  cetz.draw.set-ctx(ctx => {
    let state = ctx.shared-state.semi
    let diagnostics = ()
    let layer-names = state.layers.keys()
    for (index, face) in state.faces.enumerate() {
      let visibility = _face-visibility(
        face,
        index,
        state.faces,
        face.shading,
        face.light,
      )
      let cosine = calc.max(0, _dot(
        face.normal,
        _toward-light(face.light),
      ))
      diagnostics.push((
        index: index,
        layer: face.layer,
        layer-name: if face.layer < layer-names.len() {
          layer-names.at(face.layer)
        } else {
          str(face.layer)
        },
        points: face.points,
        center: _scale(
          face.points.fold(
            (0, 0, 0),
            (sum, point) => _add(sum, point),
          ),
          1 / face.points.len(),
        ),
        normal: face.normal,
        cosine: cosine,
        visibility: visibility,
        brightness: _face-brightness(
          face.normal,
          face.shading,
          face.light,
          visibility: visibility,
        ),
      ))
    }
    state.face-diagnostics = diagnostics
    ctx.shared-state.semi = state
    ctx
  })

  cetz.draw.get-ctx(ctx => {
    let state = ctx.shared-state.semi
    let cut = _cut-config(state.cut)
    let volumes = if cut == none {
      state.volumes
    } else {
      _scene.cut-line(
        state.volumes,
        cut.plane,
        keep: cut.keep,
      )
    }
    if debug == "topology" {
      _scene.render-topology-debug(
        volumes,
        view: _ortho-view(
          state.camera.at("elevation", default: 0deg),
          state.camera.at("azimuth", default: 0deg),
        ),
      )
    } else if state.masked {
      _scene.render(
        volumes,
        view: _ortho-view(
          state.camera.at("elevation", default: 0deg),
          state.camera.at("azimuth", default: 0deg),
        ),
        render-face: _render-scene-face,
        render-edge: _render-scene-edge,
      )
    } else {
      cetz.draw.on-layer(-1, {
        for (index, face) in state.faces.enumerate() {
          _render-face(
            face.points,
            face.normal,
            face.style,
            face.shading,
            face.light,
            face.camera,
            state.face-diagnostics.at(index).visibility,
          )
        }
      })
    }
  })
}

#let _draw-section(section) = {
  cetz.draw.get-ctx(ctx => {
    _scene.render-section(
      ctx.shared-state.semi.volumes,
      _horizontal-section(section),
    )
  })
}

#let _draw-outlines() = {
  cetz.draw.get-ctx(ctx => {
    let state = ctx.shared-state.semi
    if not state.masked and state.debug != "topology" {
      cetz.draw.on-layer(-0.5, {
        for (index, outline) in state.outlines.enumerate() {
          _draw-beveled-outline(
            outline.width,
            outline.depth,
            outline.bottom,
            outline.top,
            outline.top-bevel,
            outline.bottom-bevel,
            outline.style,
            outline.camera,
            index == state.outlines.len() - 1,
          )
        }
      })
    }
  })
}

/// Remove material vertically from the current scene.
#let etch(depth: none, mask: auto) = {
  assert(
    type(depth) in (int, float) and depth > 0,
    message: "etch depth must be a positive number",
  )
  assert(
    mask == auto or type(mask) in (array, dictionary),
    message: "etch mask must be polygon geometry, mask.invert geometry, or auto",
  )
  if type(mask) == dictionary {
    assert(
      mask.at("operation", default: none) == "invert"
        and type(mask.at("shapes", default: none)) == array,
      message: "etch mask dictionary must be created with mask.invert",
    )
  }

  cetz.draw.set-ctx(ctx => {
    let state = ctx.shared-state.at("semi", default: none)
    assert(
      state != none,
      message: "etch must be used inside layer-stack",
    )
    let (width, depth-extent) = state.size
    let bounds = (
      (
        ((0, 0), (width, 0), (width, depth-extent), (0, depth-extent)),
      ),
    )
    let footprint = if mask == auto {
      bounds
    } else if type(mask) == dictionary {
      _kernel.difference(bounds, mask.shapes)
    } else {
      mask
    }
    state.volumes = _scene.etch(state.volumes, footprint, depth)
    state.height = if state.volumes.len() == 0 {
      0
    } else {
      calc.max(..state.volumes.map(volume => volume.top))
    }
    state.masked = true
    ctx.shared-state.semi = state
    ctx
  })
}

/// Add a material layer to the current scene.
#let layer(
  name,
  thickness: none,
  material: auto,
  variant: auto,
  label: none,
  label-position: "front",
  label-project: auto,
  label-angle: 0deg,
  label-anchor: none,
  label-name: none,
  bevel: auto,
  internal-stroke: auto,
  mask: auto,
  ..style,
) = {
  assert(type(name) == str, message: "layer name must be a string")
  assert(
    material == auto or type(material) == str,
    message: "material must be a string or auto",
  )
  assert(
    variant == auto or type(variant) == int,
    message: "variant must be an integer or auto",
  )
  assert(
    mask == auto or type(mask) in (array, dictionary),
    message: "layer mask must be polygon geometry, mask.invert geometry, or auto",
  )
  if type(mask) == dictionary {
    assert(
      mask.at("operation", default: none) == "invert"
        and type(mask.at("shapes", default: none)) == array,
      message: "layer mask dictionary must be created with mask.invert",
    )
  }
  assert(
    label-project in (auto, none) or type(label-project) == str,
    message: "label-project must be auto, none, or a layer face anchor",
  )
  assert(
    type(thickness) in (int, float),
    message: "layer thickness must be a number",
  )
  assert(thickness > 0, message: "layer thickness must be positive")

  cetz.draw.get-ctx(ctx => {
    let state = ctx.shared-state.at("semi", default: none)
    assert(
      state != none,
      message: "layer must be used inside layer-stack",
    )

    let (width, depth) = state.size
    let bounds = (
      (
        ((0, 0), (width, 0), (width, depth), (0, depth)),
      ),
    )
    let footprint = if mask == auto {
      bounds
    } else if type(mask) == dictionary {
      _kernel.difference(bounds, mask.shapes)
    } else {
      mask
    }
    let placements = _scene.deposit(state.volumes, footprint, thickness)
    assert(
      placements.len() > 0,
      message: "layer " + repr(name) + " has no supported deposition area",
    )
    let bottom = calc.min(..placements.map(placement => placement.bottom))
    let top = calc.max(..placements.map(placement => placement.top))
    let middle = (bottom + top) / 2
    let family-name = if material == auto { "default" } else { material }
    let occurrence = state.material-counts.at(family-name, default: 0)
    let resolved-style = _material-style(
      material,
      variant,
      occurrence,
      style,
      state.palette,
    )
    resolved-style.insert(
      "internal-stroke",
      if internal-stroke == auto {
        state.internal-stroke
      } else {
        internal-stroke
      },
    )
    let visual-middle = _automatic-label-z(resolved-style)
    let visual-middle-z = bottom + (
      top - bottom
    ) * (visual-middle / 100%)
    let bevel = if state.shading == "fancy" {
      _bevel-config(
        if bevel == auto { state.bevel } else { bevel },
        thickness,
        width,
        depth,
        resolved-style.at("fade-bottom", default: none),
      )
    } else {
      (top: 0, bottom: 0)
    }
    let top-bevel = bevel.top
    let bottom-bevel = bevel.bottom
    let top-shoulder = top - top-bevel
    let bottom-shoulder = bottom + bottom-bevel
    let render-style = resolved-style
    if state.shading == "fancy" {
      render-style.stroke = none
    }
    let bevel-style = render-style
    let bevel-color = resolved-style.at("base-color", default: none)
    if bevel-color != none {
      bevel-style.fill = bevel-color
    }

    cetz.draw.group(
      name: name,
      {
        _face(
          (
            (0, depth, bottom-shoulder),
            (width, depth, bottom-shoulder),
            (width, depth, top-shoulder),
            (0, depth, top-shoulder),
          ),
          (0, 1, 0),
          render-style,
          state.shading,
          state.light,
          state.camera,
        )
        _face(
          (
            (bottom-bevel, bottom-bevel, bottom),
            (bottom-bevel, depth - bottom-bevel, bottom),
            (width - bottom-bevel, depth - bottom-bevel, bottom),
            (width - bottom-bevel, bottom-bevel, bottom),
          ),
          (0, 0, -1),
          render-style,
          state.shading,
          state.light,
          state.camera,
        )
        _face(
          (
            (0, 0, bottom-shoulder),
            (0, 0, top-shoulder),
            (0, depth, top-shoulder),
            (0, depth, bottom-shoulder),
          ),
          (-1, 0, 0),
          render-style,
          state.shading,
          state.light,
          state.camera,
        )
        _face(
          (
            (width, 0, bottom-shoulder),
            (width, depth, bottom-shoulder),
            (width, depth, top-shoulder),
            (width, 0, top-shoulder),
          ),
          (1, 0, 0),
          render-style,
          state.shading,
          state.light,
          state.camera,
        )
        if top-bevel > 0 {
          _face(
            (
              (0, depth, top-shoulder),
              (width, depth, top-shoulder),
              (width - top-bevel, depth - top-bevel, top),
              (top-bevel, depth - top-bevel, top),
            ),
            _unit((0, 1, 1)),
            bevel-style,
            state.shading,
            state.light,
            state.camera,
          )
          _face(
            (
              (0, 0, top-shoulder),
              (top-bevel, top-bevel, top),
              (width - top-bevel, top-bevel, top),
              (width, 0, top-shoulder),
            ),
            _unit((0, -1, 1)),
            bevel-style,
            state.shading,
            state.light,
            state.camera,
          )
          _face(
            (
              (0, 0, top-shoulder),
              (0, depth, top-shoulder),
              (top-bevel, depth - top-bevel, top),
              (top-bevel, top-bevel, top),
            ),
            _unit((-1, 0, 1)),
            bevel-style,
            state.shading,
            state.light,
            state.camera,
          )
          _face(
            (
              (width, 0, top-shoulder),
              (width - top-bevel, top-bevel, top),
              (width - top-bevel, depth - top-bevel, top),
              (width, depth, top-shoulder),
            ),
            _unit((1, 0, 1)),
            bevel-style,
            state.shading,
            state.light,
            state.camera,
          )
        }
        if bottom-bevel > 0 {
          _face(
            (
              (0, depth, bottom-shoulder),
              (bottom-bevel, depth - bottom-bevel, bottom),
              (width - bottom-bevel, depth - bottom-bevel, bottom),
              (width, depth, bottom-shoulder),
            ),
            _unit((0, 1, -1)),
            bevel-style,
            state.shading,
            state.light,
            state.camera,
          )
          _face(
            (
              (0, 0, bottom-shoulder),
              (width, 0, bottom-shoulder),
              (width - bottom-bevel, bottom-bevel, bottom),
              (bottom-bevel, bottom-bevel, bottom),
            ),
            _unit((0, -1, -1)),
            bevel-style,
            state.shading,
            state.light,
            state.camera,
          )
          _face(
            (
              (0, 0, bottom-shoulder),
              (bottom-bevel, bottom-bevel, bottom),
              (bottom-bevel, depth - bottom-bevel, bottom),
              (0, depth, bottom-shoulder),
            ),
            _unit((-1, 0, -1)),
            bevel-style,
            state.shading,
            state.light,
            state.camera,
          )
          _face(
            (
              (width, 0, bottom-shoulder),
              (width, depth, bottom-shoulder),
              (width - bottom-bevel, depth - bottom-bevel, bottom),
              (width - bottom-bevel, bottom-bevel, bottom),
            ),
            _unit((1, 0, -1)),
            bevel-style,
            state.shading,
            state.light,
            state.camera,
          )
        }
        _face(
          (
            (top-bevel, top-bevel, top),
            (width - top-bevel, top-bevel, top),
            (width - top-bevel, depth - top-bevel, top),
            (top-bevel, depth - top-bevel, top),
          ),
          (0, 0, 1),
          render-style,
          state.shading,
          state.light,
          state.camera,
        )
        _face(
          (
            (0, 0, bottom-shoulder),
            (width, 0, bottom-shoulder),
            (width, 0, top-shoulder),
            (0, 0, top-shoulder),
          ),
          (0, -1, 0),
          render-style,
          state.shading,
          state.light,
          state.camera,
        )
        if state.shading == "fancy" {
          _queue-beveled-outline(
            width,
            depth,
            bottom,
            top,
            top-bevel,
            bottom-bevel,
            resolved-style,
            state.camera,
          )
        }

        cetz.draw.anchor("bottom", (width / 2, depth / 2, bottom))
        cetz.draw.anchor("top", (width / 2, depth / 2, top))
        cetz.draw.anchor("center", (width / 2, depth / 2, middle))
        cetz.draw.anchor("front", (width / 2, 0, visual-middle-z))
        cetz.draw.anchor("back", (width / 2, depth, visual-middle-z))
        cetz.draw.anchor("left", (0, depth / 2, visual-middle-z))
        cetz.draw.anchor("right", (width, depth / 2, visual-middle-z))
        cetz.draw.anchor("front-left", (0, 0, middle))
        cetz.draw.anchor("front-right", (width, 0, middle))
        cetz.draw.anchor("back-left", (0, depth, middle))
        cetz.draw.anchor("back-right", (width, depth, middle))
        cetz.draw.anchor("front-left-bottom", (0, 0, bottom))
        cetz.draw.anchor("front-left-top", (0, 0, top))
        cetz.draw.anchor("front-right-bottom", (width, 0, bottom))
        cetz.draw.anchor("front-right-top", (width, 0, top))
        cetz.draw.anchor("back-left-bottom", (0, depth, bottom))
        cetz.draw.anchor("back-left-top", (0, depth, top))
        cetz.draw.anchor("back-right-bottom", (width, depth, bottom))
        cetz.draw.anchor("back-right-top", (width, depth, top))
      },
    )

    cetz.draw.set-ctx(ctx => {
      ctx.shared-state.semi.height = calc.max(
        ctx.shared-state.semi.height,
        top,
      )
      let fill = resolved-style.at("fill", default: none)
      for placement in placements {
        ctx.shared-state.semi.volumes.push((
          shapes: placement.shapes,
          bottom: placement.bottom,
          top: placement.top,
          top-bevel: top-bevel,
          top-fill: fill,
          side-fill: fill,
          section-fill: fill,
          style: resolved-style,
          shading: state.shading,
          light: state.light,
          camera: state.camera,
          debug-fill: resolved-style.at(
            "base-color",
            default: rgb("#b8d6ed"),
          ),
        ))
      }
      ctx.shared-state.semi.masked = (
        ctx.shared-state.semi.masked
          or mask != auto
      )
      ctx.shared-state.semi.material-counts.insert(
        family-name,
        occurrence + 1,
      )
      ctx.shared-state.semi.layers.insert(name, (
        width: width,
        depth: depth,
        bottom: bottom,
        top: top,
        visual-middle: visual-middle,
      ))
      if label != none {
        ctx.shared-state.semi.face-contents.push((
          position: _label-coordinate(name, label-position),
          body: label,
          project: if label-project in (auto, none) {
            label-project
          } else {
            _label-coordinate(name, label-project)
          },
          angle: label-angle,
          anchor: label-anchor,
          name: label-name,
        ))
      }
      ctx
    })
  })
}

/// Draw a semiconductor scene in a CeTZ canvas.
#let layer-stack(
  body,
  size: (80, 50),
  camera: (
    azimuth: 0deg,
    elevation: 0deg,
  ),
  shading: "flat",
  light: (
    azimuth: -45deg,
    elevation: 60deg,
    intensity: 0.25,
  ),
  bevel: (top: 0.5, bottom: 0.25),
  internal-stroke: none,
  palette: (:),
  length: .8mm,
  baseline: none,
  background: none,
  stroke: none,
  padding: none,
  cut: none,
  section: none,
  debug: none,
  canvas-debug: false,
) = {
  assert(
    type(size) == array and size.len() == 2,
    message: "size must be (width, depth)",
  )
  assert(size.all(value => value > 0), message: "size values must be positive")
  assert(type(camera) == dictionary, message: "camera must be a dictionary")
  assert(type(light) == dictionary, message: "light must be a dictionary")
  assert(type(palette) == dictionary, message: "palette must be a dictionary")
  assert(
    cut == none or section == none,
    message: "cut and section cannot be used together",
  )
  assert(
    section == none or debug == none,
    message: "section does not support debug overlays",
  )
  assert(
    type(canvas-debug) == bool,
    message: "canvas-debug must be a boolean",
  )
  assert(
    shading in ("none", "flat", "fancy"),
    message: "unknown shading mode",
  )

  let active-palette = _merge-dictionaries(default-palette, palette)
  let azimuth = camera.at("azimuth", default: 0deg)
  let elevation = camera.at("elevation", default: 0deg)

  cetz.canvas(
    length: length,
    baseline: baseline,
    background: background,
    stroke: stroke,
    padding: padding,
    debug: canvas-debug,
    {
      cetz.draw.set-ctx(ctx => {
        ctx.shared-state.semi = (
          size: size,
          height: 0,
          faces: (),
          face-diagnostics: (),
          outlines: (),
          volumes: (),
          masked: cut != none,
          face-contents: (),
          layers: (:),
          material-counts: (:),
          palette: active-palette,
          shading: shading,
          light: light,
          bevel: bevel,
          internal-stroke: internal-stroke,
          camera: camera,
          debug: debug,
          cut: cut,
        )
        ctx
      })

      if section == none {
        cetz.draw.ortho(
          x: elevation,
          y: azimuth,
          sorted: true,
          cull-face: none,
          {
            cetz.draw.transform(_device-to-cetz)
            cetz.draw.register-coordinate-resolver(_resolve-known-anchor)
            body
            _draw-scene(debug: debug)
            if debug != none and debug != "topology" {
              cetz.draw.on-layer(2, debug)
            }
          },
        )
      } else {
        {
          body
          _draw-section(section)
        }
      }

      if section == none {
        _draw-outlines()
      }

      if section == none and debug != "topology" {
        cetz.draw.on-layer(1, {
          cetz.draw.get-ctx(ctx => {
          for item in ctx.shared-state.semi.face-contents {
            semi-draw.content(
              item.position,
              item.body,
              project: item.project,
              anchor: item.anchor,
              angle: item.angle,
              name: item.name,
            )
          }
          })
        })
      }
    },
  )
}
