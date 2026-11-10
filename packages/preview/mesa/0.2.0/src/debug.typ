#import "@preview/cetz:0.5.2"
#import "geometry.typ": (
  add as _add,
  scale as _scale,
  dot as _dot,
  cross as _cross,
  unit as _unit,
)
#import "lighting.typ": direction as _direction
#import "projection.typ": project-face-content
#import "layer-stack.typ": layer-stack as _layer-stack
#import "scene.typ": topology-debug-styles as _topology-debug-styles
#import "kernel.typ" as _kernel

/// Inspect the structure and units of a GDS library.
#let gds(data) = {
  let info = _kernel.gds-info(data)
  let layers = info.layers.map(
    layer => str(layer.first()) + "/" + str(layer.last()),
  )
  table(
    columns: (auto, 1fr),
    column-gutter: 5mm,
    row-gutter: 1.5mm,
    align: (right, left),
    [library], info.library,
    [database unit], str(info.db-unit-meters * 1e9) + " nm",
    [user unit], str(info.user-unit-meters * 1e6) + " µm",
    [cells], info.cells.join(", "),
    [layers], layers.join(", "),
  )
}

/// Render a complete topology diagnostic for a layer stack.
#let topology(body, ..options) = {
  let options = options.named()
  assert("debug" not in options, message: "topology debug controls the debug mode")
  align(center)[
    #text(size: 7pt)[
      #grid(
        columns: 4,
        gutter: 3mm,
        [#line(length: 4mm, stroke: _topology-debug-styles.outline) outline],
        [#line(length: 4mm, stroke: _topology-debug-styles.material) material],
        [#line(length: 4mm, stroke: _topology-debug-styles.occluded) occluded],
        [#line(length: 4mm, stroke: _topology-debug-styles.internal) internal],
      )
    ]
    #v(3mm)
    #_layer-stack(body, debug: "topology", ..options)
  ]
}

#let _state(ctx) = {
  let state = ctx.shared-state.at("semi", default: none)
  assert(state != none, message: "semi.debug helpers must be used inside layer-stack")
  state
}

#let _scene-scale(state) = calc.max(
  state.size.at(0),
  calc.max(state.size.at(1), state.height),
)

#let _debug-placement(state) = {
  let (width, depth) = state.size
  let target = (width / 2, depth / 2, state.height)
  let radius = calc.sqrt(
    width * width + depth * depth + state.height * state.height,
  ) * 0.75
  (
    target: target,
    origin: _add(target, _scale(_direction(state.light), -radius)),
  )
}

#let _number(value) = str(calc.round(value, digits: 2))

#let _intensity(light) = {
  let value = light.at("intensity", default: 0.25)
  if type(value) == ratio {
    value / 100%
  } else {
    value
  }
}

#let _axis-anchor(vector, camera) = {
  let azimuth = camera.at("azimuth", default: 0deg)
  let elevation = camera.at("elevation", default: 0deg)
  let (x, y, z) = vector
  let horizontal = (
    calc.cos(azimuth) * x + calc.sin(azimuth) * y,
    -calc.cos(elevation) * z
      + calc.sin(elevation)
        * (calc.sin(azimuth) * x - calc.cos(azimuth) * y),
  )
  if calc.abs(horizontal.at(0)) >= calc.abs(horizontal.at(1)) {
    if horizontal.at(0) >= 0 { "west" } else { "east" }
  } else {
    if horizontal.at(1) >= 0 { "north" } else { "south" }
  }
}

#let _angle-points(origin, start, stop, point-at, samples: 20) = {
  let points = ()
  for index in range(samples + 1) {
    let amount = index / samples
    let angle = start + (stop - start) * amount
    points.push(_add(origin, point-at(angle)))
  }
  points
}

#let _face-name(normal) = {
  let (x, y, z) = normal
  let side = if calc.abs(x) > calc.abs(y) {
    if x > 0 { "right" } else { "left" }
  } else {
    if y > 0 { "back" } else { "front" }
  }
  if calc.abs(z) > 0.999 {
    if z > 0 { "top" } else { "bottom" }
  } else if calc.abs(z) > 1e-6 {
    side + if z > 0 { "-top-bevel" } else { "-bottom-bevel" }
  } else {
    side
  }
}

#let _selected(name, faces) = (
  faces == "all"
  or (type(faces) == array and name in faces)
  or faces == name
)

/// Draw parallel incoming rays from a directional light at infinity.
#let light(
  rays: 1,
  spread: auto,
  label: true,
  angles: true,
  color: rgb("#d97706"),
  elevation-color: rgb("#7c3aed"),
  value-color: rgb("#c2185b"),
  construction-color: rgb("#6b7280"),
  thickness: .4pt,
  label-size: 6pt,
) = {
  assert(type(rays) == int and rays > 0, message: "rays must be a positive integer")
  cetz.draw.get-ctx(ctx => {
    let state = _state(ctx)
    let scale = _scene-scale(state)
    let spread = if spread == auto { calc.min(..state.size) * 0.12 } else { spread }
    let direction = _direction(state.light)
    let placement = _debug-placement(state)
    let target = placement.target
    let source = placement.origin
    let side = _unit(_cross(direction, (0, 0, 1)))
    if _dot(side, side) == 0 {
      side = (1, 0, 0)
    }
    for index in range(rays) {
      let offset = (index - (rays - 1) / 2) * spread
      let shift = _scale(side, offset)
      let start = _add(source, shift)
      let end = _add(target, shift)
      cetz.draw.line(
        start,
        end,
        mark: (
          end: (
            symbol: "straight",
            pos: 50%,
            anchor: "center",
            length: 3.5pt,
            width: 4pt,
            stroke: color + .45pt,
            fill: none,
            shorten-to: none,
            transform-shape: false,
            reverse: true,
          ),
        ),
        stroke: color + thickness,
      )
    }
    if angles {
      let azimuth = state.light.at("azimuth", default: 0deg)
      let elevation = state.light.at("elevation", default: 0deg)
      let radius = scale * 0.09
      let vector-length = scale * 0.15
      let horizontal = _unit((
        direction.at(0),
        direction.at(1),
        0,
      ))
      let ray-end = _add(source, _scale(direction, vector-length))
      let projection-end = _add(source, (
        direction.at(0) * vector-length,
        direction.at(1) * vector-length,
        0,
      ))
      let reference-end = _add(source, (0, radius, 0))

      cetz.draw.line(
        source,
        projection-end,
        ray-end,
        stroke: (
          paint: construction-color,
          thickness: .35pt,
          dash: "dashed",
        ),
      )
      cetz.draw.line(
        source,
        ray-end,
        stroke: construction-color + .55pt,
      )
      cetz.draw.line(
        source,
        reference-end,
        stroke: (
          paint: construction-color,
          thickness: .35pt,
          dash: "dashed",
        ),
      )

      let azimuth-arc = _angle-points(
        source,
        0deg,
        azimuth,
        angle => _scale((
          calc.sin(angle),
          calc.cos(angle),
          0,
        ), radius),
      )
      let elevation-arc = _angle-points(
        source,
        0deg,
        elevation,
        angle => _scale(_add(
          _scale(horizontal, calc.cos(angle)),
          (0, 0, -calc.sin(angle)),
        ), radius),
      )
      cetz.draw.line(..azimuth-arc, stroke: color + .65pt)
      cetz.draw.line(..elevation-arc, stroke: elevation-color + .65pt)

      cetz.draw.content(
        ray-end,
        text(size: label-size * 80%, fill: construction-color)[D],
        anchor: "south-west",
      )
    }
    if label {
      let azimuth = state.light.at("azimuth", default: 0deg)
      let elevation = state.light.at("elevation", default: 0deg)
      let azimuth-value = repr(azimuth)
      let elevation-value = repr(elevation)
      let intensity = str(calc.round(_intensity(state.light), digits: 2))
      let value = body => text(
        size: label-size,
        font: "DejaVu Sans Mono",
        fill: value-color,
        body,
      )
      let label-position = if angles {
        _add(source, (0, 0, scale * 0.25))
      } else {
        source
      }
      cetz.draw.content(
        label-position,
        box(
          inset: 1.5pt,
          fill: white.transparentize(8%),
          align(right)[
            #text(size: label-size, fill: color)[az=]#value[#azimuth-value]\
            #text(size: label-size, fill: elevation-color)[el=]#value[#elevation-value]\
            #text(size: label-size, fill: color)[I=]#value[#intensity]
          ],
        ),
        anchor: "south",
      )
    }
  })
}

/// Draw the model-space x, y, and z axes.
#let axes(
  origin: auto,
  length: auto,
  labels: true,
  x-color: rgb("#c2410c"),
  y-color: rgb("#15803d"),
  z-color: rgb("#2563eb"),
  thickness: .7pt,
  label-size: 6pt,
) = {
  cetz.draw.get-ctx(ctx => {
    let state = _state(ctx)
    let scale = _scene-scale(state)
    let length = if length == auto { scale * 0.18 } else { length }
    let origin = if origin == auto {
      _debug-placement(state).origin
    } else {
      origin
    }
    for (axis, vector, color) in (
      ("x", (length, 0, 0), x-color),
      ("y", (0, length, 0), y-color),
      ("z", (0, 0, length), z-color),
    ) {
      let end = _add(origin, vector)
      cetz.draw.line(
        origin,
        end,
        mark: (end: ">", fill: color),
        stroke: color + thickness,
      )
      if labels {
        let label-position = _add(origin, _scale(vector, 1.1))
        let anchor = _axis-anchor(vector, state.camera)
        cetz.draw.content(
          label-position,
          text(size: label-size, fill: color)[#axis],
          anchor: anchor,
        )
      }
    }
  })
}

/// Label selected faces with values used by the renderer.
#let face-info(
  faces: auto,
  layers: auto,
  values: ("cosine", "visibility", "brightness"),
  color: rgb("#7c3aed"),
  label-size: 5pt,
) = {
  assert(
    faces in (auto, "all") or type(faces) in (str, array),
    message: "faces must be auto, a face name, an array of face names, or \"all\"",
  )
  assert(
    layers == auto or type(layers) in (str, array),
    message: "layers must be a layer name, an array of layer names, or auto",
  )
  assert(type(values) == array, message: "values must be an array")
  let allowed = ("normal", "cosine", "visibility", "brightness")
  assert(values.all(value => value in allowed), message: "unknown face-info value")

  cetz.draw.get-ctx(ctx => {
    let state = _state(ctx)
    let azimuth = state.camera.at("azimuth", default: 0deg)
    let faces = if faces == auto {
      let visible = (
        if calc.sin(azimuth) < 0 { "back" } else { "front" },
      )
      if calc.abs(calc.sin(azimuth)) > 1e-6 {
        visible.push(if calc.sin(azimuth) > 0 { "right" } else { "left" })
      }
      visible
    } else {
      faces
    }
    for diagnostic in state.face-diagnostics {
      let face = _face-name(diagnostic.normal)
      let selected-layer = (
        layers == auto
        or layers == diagnostic.layer-name
        or (type(layers) == array and diagnostic.layer-name in layers)
      )
      if _selected(face, faces) and selected-layer {
        let parts = ([#diagnostic.layer-name · #face],)
        for value in values {
          parts.push(if value == "normal" {
            [n #repr(diagnostic.normal)]
          } else if value == "cosine" {
            [cos #_number(diagnostic.cosine)]
          } else if value == "visibility" {
            [V #_number(diagnostic.visibility)]
          } else {
            [B #_number(diagnostic.brightness)]
          })
        }
        let line = []
        for (index, part) in parts.enumerate() {
          if index > 0 {
            line += [ · ]
          }
          line += part
        }
        let body = box(
          inset: 1.5pt,
          radius: 1pt,
          fill: white.transparentize(12%),
          stroke: color + .35pt,
          text(size: label-size, fill: color, line),
        )
        if face in ("front", "back", "left", "right") {
          body = project-face-content(body, state.camera, face)
        }
        cetz.draw.content(
          diagnostic.center,
          body,
          anchor: "center",
        )
      }
    }
  })
}

/// Draw the geometric normal of selected faces.
#let normals(
  faces: ("front", "right", "top"),
  layers: auto,
  length: auto,
  color: rgb("#7c3aed"),
  thickness: .6pt,
) = {
  assert(
    layers == auto or type(layers) in (str, array),
    message: "layers must be a layer name, an array of layer names, or auto",
  )
  cetz.draw.get-ctx(ctx => {
    let state = _state(ctx)
    let length = if length == auto { _scene-scale(state) * 0.08 } else { length }
    for diagnostic in state.face-diagnostics {
      let face = _face-name(diagnostic.normal)
      let selected-layer = (
        layers == auto
        or layers == diagnostic.layer-name
        or (type(layers) == array and diagnostic.layer-name in layers)
      )
      if _selected(face, faces) and selected-layer {
        cetz.draw.line(
          diagnostic.center,
          _add(diagnostic.center, _scale(diagnostic.normal, length)),
          mark: (end: ">", fill: color),
          stroke: color + thickness,
        )
      }
    }
  })
}
