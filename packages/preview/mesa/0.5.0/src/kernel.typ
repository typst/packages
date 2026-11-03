#let geometry-kernel = plugin("plugin/semi_geometry.wasm")

#let protocol-version = 5
#let grid-scale = 1000

#let version() = str(geometry-kernel.kernel_version())

#let gds-info(data) = {
  let (version, info) = cbor(geometry-kernel.gds_info(data))
  assert.eq(version, protocol-version)
  info
}

#let gds-layout(
  data,
  cell,
  layers,
  path-tolerance,
  unit-meters,
  scale,
  scale-x,
  scale-y,
  padding,
) = {
  let (version, result) = cbor(geometry-kernel.gds_layout(
    data,
    cbor.encode((
      cell: cell,
      layers: layers,
      path-tolerance: path-tolerance * 1.0,
      unit-meters: unit-meters,
      scale: scale * 1.0,
      scale-x: scale-x * 1.0,
      scale-y: scale-y * 1.0,
      padding: padding,
    )),
  ))
  assert.eq(version, protocol-version)

  let layout = (
    origin: result.origin,
    size: result.size,
    content-size: result.content-size,
    offset: result.offset,
    padding: result.padding,
    unit-meters: result.unit-meters,
    source-unit-meters: result.source-unit-meters,
    scale: result.scale,
  )
  for (name, shapes) in result.layers {
    layout.insert(name, shapes)
  }
  layout
}

#let _encode-point(point) = point.map(
  component => int(calc.round(component * grid-scale)),
)

#let _decode-point(point) = point.map(
  component => component / grid-scale,
)

#let _encode-shapes(shapes) = shapes.map(
  shape => shape.map(
    contour => contour.map(_encode-point),
  ),
)

#let _decode-shapes(shapes) = shapes.map(
  shape => shape.map(
    contour => contour.map(_decode-point),
  ),
)

#let _encode-volume(volume, material) = (
  shapes: _encode-shapes(volume.shapes),
  bottom: int(calc.round(volume.bottom * grid-scale)),
  top: int(calc.round(volume.top * grid-scale)),
  material: material,
  group: volume.at("layer", default: material),
  top-bevel: int(calc.round(
    volume.at("top-bevel", default: 0) * grid-scale,
  )),
  bottom-bevel: int(calc.round(
    volume.at("bottom-bevel", default: 0) * grid-scale,
  )),
  sections: if volume.at("sections", default: none) == none {
    ()
  } else {
    volume.sections.map(section => (
      height: int(calc.round(section.height * grid-scale)),
      shapes: _encode-shapes(section.shapes),
    ))
  },
)

#let difference(subject, mask) = {
  let result = cbor(geometry-kernel.difference(cbor.encode((
    version: protocol-version,
    subject: _encode-shapes(subject),
    mask: _encode-shapes(mask),
  ))))
  assert.eq(result.version, protocol-version)
  _decode-shapes(result.shapes)
}

#let intersection(subject, mask) = {
  let result = cbor(geometry-kernel.intersection(cbor.encode((
    version: protocol-version,
    subject: _encode-shapes(subject),
    mask: _encode-shapes(mask),
  ))))
  assert.eq(result.version, protocol-version)
  _decode-shapes(result.shapes)
}

#let merge(shapes) = {
  let result = cbor(geometry-kernel.merge(cbor.encode((
    version: protocol-version,
    shapes: _encode-shapes(shapes),
  ))))
  assert.eq(result.version, protocol-version)
  _decode-shapes(result.shapes)
}

#let offset(shapes, distance) = {
  let result = cbor(geometry-kernel.offset(cbor.encode((
    version: protocol-version,
    shapes: _encode-shapes(shapes),
    distance: int(calc.round(distance * grid-scale)),
  ))))
  assert.eq(result.version, protocol-version)
  _decode-shapes(result.shapes)
}

#let cross-section(shapes, y) = {
  let result = cbor(geometry-kernel.cross_section(cbor.encode((
    version: protocol-version,
    shapes: _encode-shapes(shapes),
    y: int(calc.round(y * grid-scale)),
  ))))
  assert.eq(result.version, protocol-version)
  result.intervals.map(interval => interval.map(
    component => component / grid-scale,
  ))
}

#let clip-y(shapes, y, keep: "positive") = {
  assert(
    keep in ("positive", "negative"),
    message: "clip-y keep must be \"positive\" or \"negative\"",
  )
  let result = cbor(geometry-kernel.clip_y(cbor.encode((
    version: protocol-version,
    shapes: _encode-shapes(shapes),
    y: int(calc.round(y * grid-scale)),
    positive: keep == "positive",
  ))))
  assert.eq(result.version, protocol-version)
  _decode-shapes(result.shapes)
}

#let clip-line(shapes, from, to, keep: "left") = {
  assert(
    keep in ("left", "right"),
    message: "clip-line keep must be \"left\" or \"right\"",
  )
  let result = cbor(geometry-kernel.clip_line(cbor.encode((
    version: protocol-version,
    shapes: _encode-shapes(shapes),
    from: _encode-point(from),
    to: _encode-point(to),
    keep_left: keep == "left",
  ))))
  assert.eq(result.version, protocol-version)
  _decode-shapes(result.shapes)
}

#let prepare-scene(volumes, smooth-join-cosine: 1.0) = geometry-kernel.prepare_scene(
  cbor.encode((
    version: protocol-version,
    volumes: volumes.enumerate().map(
      ((index, volume)) => _encode-volume(volume, index),
    ),
    opaque: volumes.map(volume => volume.at("opaque", default: true)),
    smooth-join-cosine: smooth-join-cosine,
  )),
)

#let prepared-scene-topology(prepared, view) = {
  let result = cbor(geometry-kernel.prepared_scene_topology(
    prepared,
    cbor.encode((version: protocol-version, view: view)),
  ))
  assert.eq(result.version, protocol-version)
  result.edges.map(edge => (
    start: _decode-point(edge.start),
    end: _decode-point(edge.end),
    kind: edge.kind,
    interior: edge.interior,
    visibility: edge.visibility,
    faces: edge.faces,
    materials: edge.materials,
    depth: edge.depth,
    cover: edge.cover,
  ))
}

#let scene-topology(volumes, view, smooth-join-cosine: 1.0) = {
  prepared-scene-topology(
    prepare-scene(volumes, smooth-join-cosine: smooth-join-cosine),
    view,
  )
}

#let project-scene-surfaces(prepared, view) = geometry-kernel.project_scene_surfaces(
  prepared,
  cbor.encode((version: protocol-version, view: view)),
)

#let projected-scene-surfaces(
  projected,
  toward-light,
  shadows: false,
  diagnostics: false,
) = {
  let result = cbor(geometry-kernel.projected_scene_surfaces(
    projected,
    cbor.encode((
      version: protocol-version,
      toward-light: if shadows { toward-light } else { (0.0, 0.0, 1.0) },
      shadows: shadows,
      diagnostics: diagnostics,
    )),
  ))
  assert.eq(result.version, protocol-version)
  result.faces.map(face => {
    let decoded = (
      depth: face.depth,
      source: face.source,
      normal: face.normal,
      material: face.material,
      light-visibility: face.light-visibility,
      contours: face.contours.map(
        contour => contour.map(_decode-point),
      ),
    )
    if diagnostics {
      decoded.source = face.source
      decoded.center = _decode-point(face.center)
    }
    decoded
  })
}

// Cut every surface of a prepared scene into the part the light reaches and the
// part it does not. Shadows do not depend on the camera, so this result stands
// for every view of the scene and is reused as the camera turns.
#let shade-scene(prepared, toward-light) = geometry-kernel.shade_scene(
  prepared,
  cbor.encode((version: protocol-version, toward-light: toward-light)),
)

// Draw a prepared scene in one piece. The result carries the finished image and
// the bounds it occupies, in grid units, so it can be placed on the canvas.
// `shaded` comes from `shade-scene`, or is empty for a scene without shadows.
#let paint-scene(
  prepared,
  shaded,
  view,
  scale,
  shading,
  toward-light,
  intensity,
  volumes,
) = {
  let result = cbor(geometry-kernel.paint_scene(
    prepared,
    shaded,
    cbor.encode((
      version: protocol-version,
      view: view,
      scale: scale,
      shading: shading,
      toward-light: toward-light,
      intensity: intensity,
      volumes: volumes,
    )),
  ))
  assert.eq(result.version, protocol-version)
  result
}

#let scene-surfaces(
  volumes,
  view,
  toward-light,
  shadows: false,
  diagnostics: false,
) = {
  let projected = project-scene-surfaces(prepare-scene(volumes), view)
  projected-scene-surfaces(
    projected,
    toward-light,
    shadows: shadows,
    diagnostics: diagnostics,
  )
}
