#let device-to-cetz = (
  (1, 0, 0, 0),
  (0, 0, 1, 0),
  (0, -1, 0, 0),
  (0, 0, 0, 1),
)

#let _multiply-3(left, right) = (
  (
    left.at(0).at(0) * right.at(0).at(0)
      + left.at(0).at(1) * right.at(1).at(0)
      + left.at(0).at(2) * right.at(2).at(0),
    left.at(0).at(0) * right.at(0).at(1)
      + left.at(0).at(1) * right.at(1).at(1)
      + left.at(0).at(2) * right.at(2).at(1),
    left.at(0).at(0) * right.at(0).at(2)
      + left.at(0).at(1) * right.at(1).at(2)
      + left.at(0).at(2) * right.at(2).at(2),
  ),
  (
    left.at(1).at(0) * right.at(0).at(0)
      + left.at(1).at(1) * right.at(1).at(0)
      + left.at(1).at(2) * right.at(2).at(0),
    left.at(1).at(0) * right.at(0).at(1)
      + left.at(1).at(1) * right.at(1).at(1)
      + left.at(1).at(2) * right.at(2).at(1),
    left.at(1).at(0) * right.at(0).at(2)
      + left.at(1).at(1) * right.at(1).at(2)
      + left.at(1).at(2) * right.at(2).at(2),
  ),
  (
    left.at(2).at(0) * right.at(0).at(0)
      + left.at(2).at(1) * right.at(1).at(0)
      + left.at(2).at(2) * right.at(2).at(0),
    left.at(2).at(0) * right.at(0).at(1)
      + left.at(2).at(1) * right.at(1).at(1)
      + left.at(2).at(2) * right.at(2).at(1),
    left.at(2).at(0) * right.at(0).at(2)
      + left.at(2).at(1) * right.at(1).at(2)
      + left.at(2).at(2) * right.at(2).at(2),
  ),
)

#let ortho-view(x, y, z: 0deg) = {
  let sine-x = calc.sin(x)
  let cosine-x = calc.cos(x)
  let sine-y = calc.sin(y)
  let cosine-y = calc.cos(y)
  let sine-z = calc.sin(z)
  let cosine-z = calc.cos(z)
  let rotate-x = (
    (1, 0, 0),
    (0, cosine-x, -sine-x),
    (0, sine-x, cosine-x),
  )
  let rotate-y = (
    (cosine-y, 0, -sine-y),
    (0, 1, 0),
    (sine-y, 0, cosine-y),
  )
  let rotate-z = (
    (cosine-z, -sine-z, 0),
    (sine-z, cosine-z, 0),
    (0, 0, 1),
  )
  let device-view = (
    (1, 0, 0),
    (0, 0, 1),
    (0, -1, 0),
  )
  _multiply-3(
    _multiply-3(_multiply-3(rotate-x, rotate-y), rotate-z),
    device-view,
  )
}

#let _inverse-transform-point(matrix, point) = {
  let ((a, b, c, tx), (d, e, f, ty), (g, h, i, tz), _) = matrix
  let determinant = (
    a * (e * i - f * h)
      - b * (d * i - f * g)
      + c * (d * h - e * g)
  )
  assert(
    calc.abs(determinant) > 1e-12,
    message: "cannot resolve coordinates through a singular transform",
  )
  let (x, y, z) = (
    point.at(0) - tx,
    point.at(1) - ty,
    point.at(2) - tz,
  )
  (
    (
      (e * i - f * h) * x
        + (c * h - b * i) * y
        + (b * f - c * e) * z
    ) / determinant,
    (
      (f * g - d * i) * x
        + (a * i - c * g) * y
        + (c * d - a * f) * z
    ) / determinant,
    (
      (d * h - e * g) * x
        + (b * g - a * h) * y
        + (a * e - b * d) * z
    ) / determinant,
  )
}

#let resolve-known-anchor(ctx, coordinate) = {
  // CeTZ 0.5.2's generic matrix inverse can select more than one pivot per
  // column. Resolve named nodes through the affine inverse above so anchors
  // remain continuous as the camera rotates.
  let target = if type(coordinate) == str {
    let parts = coordinate.split(".")
    (
      name: parts.first(),
      anchor: if parts.len() == 1 { "default" } else { parts.slice(1) },
    )
  } else if type(coordinate) == dictionary and "name" in coordinate {
    (
      name: coordinate.name,
      anchor: coordinate.at("anchor", default: "default"),
    )
  } else {
    none
  }
  if target == none or target.name not in ctx.nodes {
    return coordinate
  }

  _inverse-transform-point(
    ctx.transform,
    (ctx.nodes.at(target.name).anchors)(target.anchor),
  )
}

#let project(point, camera) = {
  let azimuth = camera.at("azimuth", default: 0deg)
  let elevation = camera.at("elevation", default: 0deg)
  let (x, y, z) = point

  (
    calc.cos(azimuth) * x + calc.sin(azimuth) * y,
    -calc.cos(elevation) * z
      + calc.sin(elevation)
        * (calc.sin(azimuth) * x - calc.cos(azimuth) * y),
  )
}

#let face-basis(camera, face) = {
  let azimuth = camera.at("azimuth", default: 0deg)
  let elevation = camera.at("elevation", default: 0deg)
  if face in ("front", "back") {
    (
      (
        calc.cos(azimuth),
        calc.sin(elevation) * calc.sin(azimuth),
      ),
      (0, calc.cos(elevation)),
    )
  } else if face == "right" {
    (
      (
        calc.sin(azimuth),
        -calc.sin(elevation) * calc.cos(azimuth),
      ),
      (0, calc.cos(elevation)),
    )
  } else if face == "left" {
    (
      (
        -calc.sin(azimuth),
        calc.sin(elevation) * calc.cos(azimuth),
      ),
      (0, calc.cos(elevation)),
    )
  } else {
    (
      (
        calc.cos(azimuth),
        calc.sin(elevation) * calc.sin(azimuth),
      ),
      (
        -calc.sin(azimuth),
        calc.sin(elevation) * calc.cos(azimuth),
      ),
    )
  }
}

#let face-horizontal(camera, face) = face-basis(camera, face).first()

#let _content-origin(anchor) = {
  let anchor = if anchor == none { "center" } else { anchor }
  if anchor == "north-west" {
    left + top
  } else if anchor == "north" {
    center + top
  } else if anchor == "north-east" {
    right + top
  } else if anchor in ("west", "mid-west") {
    left + horizon
  } else if anchor in ("center", "mid") {
    center + horizon
  } else if anchor in ("east", "mid-east") {
    right + horizon
  } else if anchor in ("south-west", "base-west", "text") {
    left + bottom
  } else if anchor in ("south", "base") {
    center + bottom
  } else if anchor in ("south-east", "base-east") {
    right + bottom
  } else {
    panic("unsupported anchor for projected content: " + repr(anchor))
  }
}

#let project-face-content(
  body,
  camera,
  face,
  anchor: none,
) = {
  assert(
    face in ("front", "back", "left", "right", "top", "bottom"),
    message: "unknown projection face: " + repr(face),
  )

  let (u, v) = face-basis(camera, face)
  let origin = _content-origin(anchor)
  let v-length = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1))
  if v-length < 1e-8 {
    return std.scale(x: 0%, y: 0%, body)
  }

  let v-unit = (v.at(0) / v-length, v.at(1) / v-length)
  let x-unit = (v-unit.at(1), -v-unit.at(0))
  let x-scale = u.at(0) * x-unit.at(0) + u.at(1) * x-unit.at(1)
  if calc.abs(x-scale) < 1e-8 {
    return std.scale(x: 0%, y: 0%, body)
  }

  let shear = (
    u.at(0) * v-unit.at(0) + u.at(1) * v-unit.at(1)
  ) / x-scale
  let rotation = calc.atan2(x-unit.at(0), x-unit.at(1))

  std.rotate(
    rotation,
    origin: origin,
    std.skew(
      ay: calc.atan2(1, shear),
      origin: origin,
      std.scale(
        x: x-scale * 100%,
        y: v-length * 100%,
        origin: origin,
        body,
      ),
    ),
  )
}

#let face-content-angle(camera, face) = {
  let (horizontal, _) = face-basis(camera, face)
  let (horizontal-x, horizontal-y) = horizontal
  calc.atan2(horizontal-x, horizontal-y)
}
