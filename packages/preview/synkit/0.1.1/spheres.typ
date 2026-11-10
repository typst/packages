// Conditional-semantics sphere diagrams
// Draws a solid sphere of worlds, four dotted concentric guides, and
// labelled parabolic proposition boundaries.

#import "@preview/cetz:0.5.2"

#let _rotate(point, angle) = {
  let (x, y) = point
  let theta = angle * 1deg
  (
    x * calc.cos(theta) - y * calc.sin(theta),
    x * calc.sin(theta) + y * calc.cos(theta),
  )
}

#let _parabola-point(vertex, angle, opening, t) = {
  let offset = _rotate((opening * t * t, t), angle)
  (vertex.at(0) + offset.at(0), vertex.at(1) + offset.at(1))
}

#let _tail-extent(vertex, angle, opening, target-radius, side) = {
  let extent = 0.0
  let point = vertex
  while calc.sqrt(point.at(0) * point.at(0) + point.at(1) * point.at(1)) <= target-radius {
    extent += 0.025
    point = _parabola-point(vertex, angle, opening, side * extent)
    assert(extent < 10, message: "spheres: could not extend parabola beyond the outermost circle")
  }
  extent
}

#let _parabola-points(vertex, angle, opening, negative-extent, positive-extent, steps: 64) = {
  range(steps + 1).map(i => {
    let t = -negative-extent + ((negative-extent + positive-extent) * i / steps)
    _parabola-point(vertex, angle, opening, t)
  })
}

#let _normalize-ids(value) = {
  if value == () {
    ()
  } else if type(value) == str {
    (value,)
  } else {
    value
  }
}

#let _simple-shade-region(id, value) = {
  if type(value) == array {
    assert(value.len() == 2, message: "spheres: shade must be a pair of circle depths")
    (inside: id, band: value)
  } else {
    assert(type(value) == dictionary, message: "spheres: shade must be a pair or dictionary")
    let between = value.at("between")
    let region = (inside: id, band: between)
    if "fill" in value {
      region.insert("fill", value.at("fill"))
    }
    region
  }
}

/// Draw a Lewis-style system of spheres for conditional semantics.
///
/// Four dotted guide circles surround a filled solid sphere: two guides lie
/// inside it and two outside it. The five concentric lines are numbered from
/// the centre outwards, so depth `3` is the solid sphere boundary.
///
/// Each `parabolas` entry is a dictionary with `label`, `angle`, and `depth`.
/// Optional keys are `id`, `touch-angle`, `label-position`, and
/// `label-offset`. Add `shade: (inner, outer)` to shade that parabola between
/// two circle depths. `touch-angle` controls where the vertex sits on the selected
/// circle and defaults to the parabola angle. All parabolas share the same
/// `parabola-opening`. Both tails use the same extent. That extent is the
/// average of the two lengths needed to reach a virtual outer guide set by
/// `parabola-tail-gap`, while still keeping both endpoints outside guide 5.
/// Angles are numeric degrees: `0` opens right and positive values rotate
/// counterclockwise.
///
/// Each `shading` entry may contain `inside`, `outside`, `band`, and `fill`.
/// Named inside regions are intersected, outside regions are subtracted, and
/// the result is clipped to the radial band `(inner-depth, outer-depth)`.
/// Use depth `0` for the centre of the diagram.
#let spheres(
  center-label: $w$,
  parabolas: (),
  shading: (),
  parabola-opening: 4.0,
  parabola-tail-gap: 1.0,
  scale: 1.0,
  circle-fill: luma(88%),
  shading-fill: luma(70%),
  stroke: luma(15%),
  guide-stroke: luma(58%),
  line-width: 1.0,
) = {
  assert(type(scale) == int or type(scale) == float, message: "spheres: scale must be numeric")
  assert(scale > 0, message: "spheres: scale must be greater than zero")
  assert(parabola-opening > 0, message: "spheres: parabola-opening must be greater than zero")
  assert(parabola-tail-gap >= 0, message: "spheres: parabola-tail-gap must be at least zero")

  let ids = ()
  let normalized-parabolas = ()
  for (index, spec) in parabolas.enumerate() {
    assert(type(spec) == dictionary, message: "spheres: every parabola must be a dictionary")
    let id = spec.at("id", default: "__parabola-" + str(index + 1))
    let angle = spec.at("angle")
    let touch-angle = spec.at("touch-angle", default: angle)
    let depth = spec.at("depth")
    assert(type(id) == str and id != "", message: "spheres: a parabola id must be a non-empty string")
    assert(not id in ids, message: "spheres: duplicate parabola id " + repr(id))
    assert(
      (type(angle) == int or type(angle) == float) and angle >= 0 and angle <= 360,
      message: "spheres: parabola angle must be between 0 and 360 degrees",
    )
    assert(
      (type(touch-angle) == int or type(touch-angle) == float) and touch-angle >= 0 and touch-angle <= 360,
      message: "spheres: parabola touch-angle must be between 0 and 360 degrees",
    )
    assert(
      type(depth) == int and depth >= 1 and depth <= 5,
      message: "spheres: parabola depth must be an integer from 1 to 5",
    )
    ids.push(id)
    normalized-parabolas.push((..spec, id: id))
  }

  let shading-regions = shading
  for spec in normalized-parabolas {
    let shade = spec.at("shade", default: none)
    if shade != none {
      let entries = if type(shade) == dictionary {
        (shade,)
      } else if type(shade) == array and shade.len() == 2 and type(shade.at(0)) == int {
        (shade,)
      } else {
        shade
      }
      for entry in entries {
        shading-regions.push(_simple-shade-region(spec.id, entry))
      }
    }
  }

  for region in shading-regions {
    assert(type(region) == dictionary, message: "spheres: every shading region must be a dictionary")
    let inside = _normalize-ids(region.at("inside", default: ()))
    let outside = _normalize-ids(region.at("outside", default: ()))
    assert(inside.len() > 0, message: "spheres: a shading region needs at least one inside parabola")
    for id in inside + outside {
      assert(id in ids, message: "spheres: shading refers to unknown parabola " + repr(id))
    }
    let band = region.at("band", default: (0, 5))
    assert(type(band) == array and band.len() == 2, message: "spheres: a shading band must be a pair")
    let inner = band.at(0)
    let outer = band.at(1)
    assert(
      type(inner) == int and type(outer) == int and inner >= 0 and outer <= 5 and inner < outer,
      message: "spheres: shading bands must satisfy 0 <= inner < outer <= 5",
    )
  }

  let radius-step = 0.55
  let solid-depth = 3
  let solid-radius = solid-depth * radius-step
  let sw = 0.018 * line-width
  let curve-stroke = stroke

  let parabola-data = normalized-parabolas.map(spec => {
    let vertex = _rotate((spec.depth * radius-step, 0), spec.at("touch-angle", default: spec.angle))
    let target-radius = (5 + parabola-tail-gap) * radius-step
    let negative-extent = _tail-extent(
      vertex,
      spec.angle,
      parabola-opening,
      target-radius,
      -1,
    )
    let positive-extent = _tail-extent(
      vertex,
      spec.angle,
      parabola-opening,
      target-radius,
      1,
    )
    let outside-negative = _tail-extent(vertex, spec.angle, parabola-opening, 5 * radius-step, -1)
    let outside-positive = _tail-extent(vertex, spec.angle, parabola-opening, 5 * radius-step, 1)
    let target-average = (negative-extent + positive-extent) / 2
    let extent = calc.max(target-average, outside-negative, outside-positive)
    let points = _parabola-points(
      vertex,
      spec.angle,
      parabola-opening,
      extent,
      extent,
    )
    (
      spec: spec,
      points: points,
      vertex: vertex,
      extent: extent,
    )
  })
  let parabola-map = (:)
  for data in parabola-data {
    parabola-map.insert(data.spec.id, data)
  }

  cetz.canvas(length: scale * 1cm, {
    import cetz.draw: *

    let _parabola-region(id) = {
      let points = parabola-map.at(id).points
      line(..points, close: true, stroke: none, fill: none)
    }

    let _radial-band(inner, outer) = {
      if inner == 0 {
        circle((0, 0), radius: outer * radius-step, stroke: none, fill: none)
      } else {
        boolean(
          { circle((0, 0), radius: outer * radius-step, stroke: none, fill: none) },
          { circle((0, 0), radius: inner * radius-step, stroke: none, fill: none) },
          op: "difference",
          stroke: none,
          fill: none,
        )
      }
    }

    // Base fill.
    circle((0, 0), radius: solid-radius, stroke: none, fill: circle-fill)

    // Declarative shaded intersections.
    for region in shading-regions {
      let inside = _normalize-ids(region.at("inside", default: ()))
      let outside = _normalize-ids(region.at("outside", default: ()))
      let band = region.at("band", default: (0, 5))
      let shape = _parabola-region(inside.first())
      for id in inside.slice(1) {
        shape = boolean(shape, _parabola-region(id), op: "intersection", stroke: none, fill: none)
      }
      for id in outside {
        shape = boolean(shape, _parabola-region(id), op: "difference", stroke: none, fill: none)
      }
      boolean(
        shape,
        _radial-band(band.at(0), band.at(1)),
        op: "intersection",
        stroke: none,
        fill: region.at("fill", default: shading-fill),
      )
    }

    // Dotted guides, then the solid boundary.
    for depth in (1, 2, 4, 5) {
      circle(
        (0, 0),
        radius: depth * radius-step,
        stroke: (paint: guide-stroke, thickness: sw, dash: "dotted"),
        fill: none,
      )
    }
    circle((0, 0), radius: solid-radius, stroke: (paint: guide-stroke, thickness: sw), fill: none)

    // Visible proposition boundaries and their labels.
    for data in parabola-data {
      let spec = data.spec
      line(..data.points, stroke: (paint: curve-stroke, thickness: sw))

      let label-t = spec.at("label-position", default: -0.72)
      let t = label-t * data.extent
      let base = _parabola-point(data.vertex, spec.angle, parabola-opening, t)
      let offset = spec.at("label-offset", default: (0, 0))
      let label-pos = (base.at(0) + offset.at(0), base.at(1) + offset.at(1))
      content(label-pos, spec.at("label"), anchor: "west")
    }

    content((0, 0), center-label, anchor: "center")
  })
}
