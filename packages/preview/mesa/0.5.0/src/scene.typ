#import "@preview/cetz:0.5.2": draw
#import "kernel.typ" as kernel
#import "fills.typ": resolve as _resolve-fill

#let _grid-height(height) = calc.round(height * kernel.grid-scale) / kernel.grid-scale

#let _validate-volume(volume, index) = {
  assert(
    type(volume) == dictionary,
    message: "volume " + str(index) + " must be a dictionary",
  )
  assert(
    "shapes" in volume,
    message: "volume " + str(index) + " requires shapes",
  )
  assert(
    "bottom" in volume
      and "top" in volume
      and volume.top > volume.bottom,
    message: "volume " + str(index) + " requires top > bottom",
  )
  let sections = volume.at("sections", default: none)
  if sections != none {
    assert(
      type(sections) == array and sections.len() >= 2,
      message: "volume " + str(index) + " sections must contain at least two planes",
    )
    assert(
      sections.first().height == volume.bottom
        and sections.last().height == volume.top,
      message: "volume " + str(index) + " sections must span bottom to top",
    )
    for section in sections {
      assert(
        type(section.shapes) == array,
        message: "volume " + str(index) + " section requires shapes",
      )
    }
  }
}

#let _volume-sections(volume) = {
  let sections = volume.at("sections", default: none)
  if sections == none {
    (
      (height: volume.bottom, shapes: volume.shapes),
      (height: volume.top, shapes: volume.shapes),
    )
  } else {
    sections
  }
}


// A contour only carries a surface across a slice of height where it is present
// at both ends with a matching vertex count: a hole that closes, or a shape that
// opens, does so at one plane and takes no part in the slope on either side of
// it. Keeping just the contours a pair of planes share lets the two sides line
// up even where the outline gains or loses a contour between them, exactly as
// the surfaces themselves are built one contour at a time.
#let _shared-contours(lower, upper) = {
  let reduced-lower = ()
  let reduced-upper = ()
  for shape-index in range(calc.min(lower.len(), upper.len())) {
    let lower-shape = lower.at(shape-index)
    let upper-shape = upper.at(shape-index)
    let lower-contours = ()
    let upper-contours = ()
    for contour-index in range(calc.min(lower-shape.len(), upper-shape.len())) {
      let lower-contour = lower-shape.at(contour-index)
      let upper-contour = upper-shape.at(contour-index)
      if lower-contour.len() == upper-contour.len() {
        lower-contours.push(lower-contour)
        upper-contours.push(upper-contour)
      }
    }
    if lower-contours.len() > 0 {
      reduced-lower.push(lower-contours)
      reduced-upper.push(upper-contours)
    }
  }
  (reduced-lower, reduced-upper)
}

#let _interpolate-shapes(lower, upper, amount) = {
  assert(
    lower.len() == upper.len(),
    message: "contoured volume changes shape topology",
  )
  lower.enumerate().map(((shape-index, lower-shape)) => {
    let upper-shape = upper.at(shape-index)
    assert(
      lower-shape.len() == upper-shape.len(),
      message: "contoured volume changes contour topology",
    )
    lower-shape.enumerate().map(((contour-index, lower-contour)) => {
      let upper-contour = upper-shape.at(contour-index)
      assert(
        lower-contour.len() == upper-contour.len(),
        message: "contoured volume changes polygon topology",
      )
      lower-contour.enumerate().map(((point-index, lower-point)) => {
        let upper-point = upper-contour.at(point-index)
        (
          lower-point.at(0) + (upper-point.at(0) - lower-point.at(0)) * amount,
          lower-point.at(1) + (upper-point.at(1) - lower-point.at(1)) * amount,
        )
      })
    })
  })
}

#let _volume-shapes-at(volume, height, side: "at") = {
  assert(side in ("at", "above", "below"))
  if height < volume.bottom or height > volume.top {
    return ()
  }
  if (
    (side == "above" and height == volume.top)
      or (side == "below" and height == volume.bottom)
  ) {
    return ()
  }
  let sections = _volume-sections(volume)
  for index in range(sections.len() - 1) {
    let lower = sections.at(index)
    let upper = sections.at(index + 1)
    if height >= lower.height and height <= upper.height {
      if lower.shapes == upper.shapes {
        return lower.shapes
      }
      let (lower-shapes, upper-shapes) = _shared-contours(
        lower.shapes,
        upper.shapes,
      )
      return _interpolate-shapes(
        lower-shapes,
        upper-shapes,
        (height - lower.height) / (upper.height - lower.height),
      )
    }
  }
  sections.last().shapes
}

// The edge accent is a bevel carried as a plain amount on the
// volume so that every boolean operation keeps seeing the full footprint. Only
// here, on the way to the renderer, is it turned into real surfaces: the outline
// steps inward over the last sliver of height at the top and bottom. 
// The chamfers fold into whatever profile the volume already has,
//  so a bottom accent can sit under an edge profile that shapes the top.
#let _expand-accents(volumes) = {
  let covered(volume, height, above) = {
    let face = _volume-shapes-at(volume, height)
    if face.len() == 0 { return face }
    let neighbours = ()
    for other in volumes {
      let touches = if above { other.bottom == height } else { other.top == height }
      if not touches { continue }
      let shapes = _volume-shapes-at(other, height)
      if shapes.len() == 0 { continue }
      let continues = (
        other.at("layer", default: none) == volume.at("layer", default: none)
          or (
            other.at("opaque", default: true)
              and kernel.difference(shapes, face).len() > 0
          )
      )
      if continues {
        neighbours += shapes
      }
    }
    if neighbours.len() == 0 { return () }
    kernel.intersection(face, kernel.merge(neighbours))
  }

  // Pull the whole outline in by the accent, then put back the part something
  // stands on, so only the exposed stretch of the outline ends up moving. If
  // nothing moves, the whole face is covered and there is no accent to draw.
  let accent-outline(shapes, covered, accent) = {
    let inset = kernel.merge(kernel.offset(shapes, -accent) + covered)
    if inset.len() == 0 or kernel.difference(shapes, inset).len() == 0 {
      none
    } else {
      inset
    }
  }

  volumes.map(volume => {
  let top-accent = volume.at("top-accent", default: 0)
  let bottom-accent = volume.at("bottom-accent", default: 0)
  if top-accent == 0 and bottom-accent == 0 { return volume }
  let sections = _volume-sections(volume)

  if bottom-accent > 0 {
    let base = sections.first()
    let shoulder = base.height + bottom-accent
    let inset = accent-outline(base.shapes, covered(volume, volume.bottom, false), bottom-accent)
    if inset != none and shoulder < sections.at(1).height {
      sections = (
        (height: base.height, shapes: inset),
        (height: shoulder, shapes: base.shapes),
        ..sections.slice(1),
      )
    }
  }

  if top-accent > 0 {
    let apex = sections.last()
    let shoulder = apex.height - top-accent
    let inset = accent-outline(apex.shapes, covered(volume, volume.top, true), top-accent)
    if inset != none and shoulder > sections.at(sections.len() - 2).height {
      sections = (
        ..sections.slice(0, sections.len() - 1),
        (height: shoulder, shapes: apex.shapes),
        (height: apex.height, shapes: inset),
      )
    }
  }

  let expanded = volume
  expanded.sections = sections
  expanded
  })
}

// Boolean operations are free to start a contour at any vertex and to wind it
// either way, so two outlines of the same shape can disagree on where index 0
// sits. Everything that walks two outlines in step needs them lined up first:
// fix the winding, then rotate the lowest vertex to the front.
#let _canonical-contour(contour, outer) = {
  if contour.len() < 3 { return contour }
  let twice-area = 0.0
  for index in range(contour.len()) {
    let current = contour.at(index)
    let next = contour.at(calc.rem(index + 1, contour.len()))
    twice-area += current.at(0) * next.at(1) - next.at(0) * current.at(1)
  }
  let contour = if (twice-area > 0) != outer { contour.rev() } else { contour }
  let start = 0
  for index in range(1, contour.len()) {
    let candidate = contour.at(index)
    let best = contour.at(start)
    if (
      candidate.at(0) < best.at(0)
        or (candidate.at(0) == best.at(0) and candidate.at(1) < best.at(1))
    ) {
      start = index
    }
  }
  range(contour.len()).map(
    index => contour.at(calc.rem(index + start, contour.len())),
  )
}

#let _canonical-shapes(shapes) = shapes.map(shape => shape.enumerate().map(
  ((index, contour)) => _canonical-contour(contour, index == 0),
))

#let _same-structure(left, right) = {
  if left.len() != right.len() { return false }
  for (shape-index, left-shape) in left.enumerate() {
    let right-shape = right.at(shape-index)
    if left-shape.len() != right-shape.len() { return false }
    for (contour-index, left-contour) in left-shape.enumerate() {
      if left-contour.len() != right-shape.at(contour-index).len() { return false }
    }
  }
  true
}

#let _shapes-match(left, right, tolerance) = {
  if not _same-structure(left, right) { return false }
  for (shape-index, left-shape) in left.enumerate() {
    for (contour-index, left-contour) in left-shape.enumerate() {
      let right-contour = right.at(shape-index).at(contour-index)
      for (point-index, left-point) in left-contour.enumerate() {
        let right-point = right-contour.at(point-index)
        if (
          calc.abs(left-point.at(0) - right-point.at(0)) > tolerance
            or calc.abs(left-point.at(1) - right-point.at(1)) > tolerance
        ) { return false }
      }
    }
  }
  true
}

// A height only belongs to a volume if the volume changes there. Sampling is
// scene-wide, so a volume collects the heights of everything around it: etching
// a coated wire cuts the wire at the heights the coating cares about, and each
// of those cuts would split its wall into two faces meeting along a seam. A
// section whose outline repeats both of its neighbours describes no change and
// is dropped outright.
#let _essential-sections(sections) = {
  if sections.len() < 3 { return sections }
  let result = (sections.first(),)
  for index in range(1, sections.len() - 1) {
    let section = sections.at(index)
    if (
      section.shapes != result.last().shapes
        or section.shapes != sections.at(index + 1).shapes
    ) {
      result.push(section)
    }
  }
  result.push(sections.last())
  result
}

#let _sectioned-volume(sections, template) = {
  let sections = _essential-sections(sections)
  let footprint = ()
  for section in sections { footprint += section.shapes }
  let volume = template
  volume.bottom = sections.first().height
  volume.top = sections.last().height
  volume.shapes = kernel.merge(footprint)
  volume.sections = if sections.all(
    section => section.shapes == sections.first().shapes,
  ) { none } else { sections }
  volume
}

// Deposition and etching sample the scene at every height where anything about
// it changes, which describes the result as a stack of thin bands. Bands whose
// outlines agree where they meet are not separate volumes: they are one volume
// whose outline varies with height. Building them as one keeps a flat slope a
// single surface, instead of a pile of pieces meeting along seams that no
// stroke covers and no fill quite closes. Only a pair of outlines that disagree
// is a real step, and that is where the next volume starts.
//
// Which of the heights in between are real bends is decided per contour when
// the surfaces are built, not here: a conformal shell bends its inner boundary
// where the wire bends and its outer boundary a thickness higher, so no single
// height is a bend for every contour at once.
#let _bands-to-volumes(bands, template: (:)) = {
  let result = ()
  let sections = ()
  for band in bands {
    let lower = _canonical-shapes(band.lower)
    let upper = _canonical-shapes(band.upper)
    let continues = (
      sections.len() > 0
        and sections.last().height == band.bottom
        and _shapes-match(
          sections.last().shapes,
          lower,
          1.5 / kernel.grid-scale,
        )
    )
    if not continues {
      if sections.len() > 1 {
        result.push(_sectioned-volume(sections, template))
      }
      sections = ((height: band.bottom, shapes: lower),)
    }
    sections.push((height: band.top, shapes: upper))
  }
  if sections.len() > 1 {
    result.push(_sectioned-volume(sections, template))
  }
  result
}

#let _scene-shapes-at(volumes, height, side: "at") = {
  let shapes = ()
  for volume in volumes {
    shapes += _volume-shapes-at(volume, height, side: side)
  }
  if shapes.len() == 0 { () } else { kernel.merge(shapes) }
}

#let _clip-volume(volume, clip) = {
  let clipped = volume
  clipped.shapes = kernel.intersection(volume.shapes, clip)
  let sections = volume.at("sections", default: none)
  if sections != none {
    clipped.sections = sections.map(section => (
      height: section.height,
      shapes: kernel.intersection(section.shapes, clip),
    ))
  }
  clipped
}

#let _truncate-volume(volume, top) = {
  let truncated = volume
  let top-shapes = _volume-shapes-at(volume, top)
  truncated.top = top
  let sections = _volume-sections(volume).filter(section => section.height < top)
  sections.push((height: top, shapes: top-shapes))
  truncated.sections = sections
  truncated
}

#let planar-deposit(volumes, shapes, top) = {
  assert(
    volumes.len() > 0,
    message: "planar deposition requires an existing sample",
  )

  let heights = (0, _grid-height(top))
  for volume in volumes {
    for section in _volume-sections(volume) {
      let height = _grid-height(section.height)
      if height < top and height not in heights {
        heights.push(height)
      }
    }
  }
  heights = heights.sorted()
  let result = ()
  for index in range(heights.len() - 1) {
    let bottom = heights.at(index)
    let upper = heights.at(index + 1)
    if upper > bottom {
      let fills = ((bottom, "above"), (upper, "below")).map(sample => {
        let occupied = _scene-shapes-at(
          volumes,
          sample.first(),
          side: sample.last(),
        )
        if occupied.len() == 0 {
          shapes
        } else {
          kernel.difference(shapes, occupied)
        }
      })
      let lower-shapes = fills.first()
      let upper-shapes = fills.last()
      if lower-shapes.len() > 0 and upper-shapes.len() > 0 {
        result.push((
          bottom: bottom,
          top: upper,
          lower: lower-shapes,
          upper: upper-shapes,
        ))
      }
    }
  }
  _bands-to-volumes(result)
}

// The first plane above which any part of `shapes` is not occupied. This is
// only needed to explain a planar deposition that produced no material.
#let planar-minimum-top(volumes, shapes) = {
  let heights = ()
  for volume in volumes {
    for section in _volume-sections(volume) {
      if section.height not in heights {
        heights.push(section.height)
      }
    }
  }
  heights = heights.sorted()
  for height in heights {
    let occupied = _scene-shapes-at(volumes, height, side: "above")
    if occupied.len() == 0 or kernel.difference(shapes, occupied).len() > 0 {
      return height
    }
  }
  heights.last()
}

#let _surface-deposit(
  volumes,
  bounds,
  thickness,
  sidewall-coverage,
  coat-bottoms: false,
) = {
  assert(
    volumes.len() > 0,
    message: "surface deposition requires an existing sample",
  )
  let sidewall-thickness = thickness * (sidewall-coverage / 100%)

  let heights = (0,)
  for volume in volumes {
    let section-heights = _volume-sections(volume).map(section => section.height)
    let profile-heights = section-heights + section-heights.map(height => height + thickness)
    for height in (
      if coat-bottoms { calc.max(0, volume.bottom - thickness) } else { volume.bottom },
      ..profile-heights,
    ) {
      height = _grid-height(height)
      if height not in heights {
        heights.push(height)
      }
    }
  }
  heights = heights.sorted()

  let shell-at(height, side) = {
    let occupied = _scene-shapes-at(volumes, height, side: side)
    let expanded = ()
    for volume in volumes {
      let minimum = if coat-bottoms {
        calc.max(0, volume.bottom - thickness)
      } else {
        volume.bottom
      }
      let maximum = volume.top + thickness
      let active = if side == "above" {
        height >= minimum and height < maximum
      } else {
        height > minimum and height <= maximum
      }
      if active {
        let source-height = calc.max(
          volume.bottom,
          calc.min(volume.top, height - thickness),
        )
        let source = _volume-shapes-at(volume, source-height)
        if source.len() > 0 {
          expanded += kernel.offset(source, sidewall-thickness)
        }
      }
    }
    if expanded.len() == 0 {
      return ()
    }
    let shell = kernel.intersection(kernel.merge(expanded), bounds)
    if occupied.len() > 0 {
      shell = kernel.difference(shell, occupied)
    }
    shell
  }

  let result = ()
  for index in range(heights.len() - 1) {
    let bottom = heights.at(index)
    let top = heights.at(index + 1)
    if top > bottom {
      let lower = shell-at(bottom, "above")
      let upper = shell-at(top, "below")
      if lower.len() > 0 and upper.len() > 0 {
        result.push((bottom: bottom, top: top, lower: lower, upper: upper))
      }
    }
  }

  _bands-to-volumes(result)
}

#let conformal-deposit(volumes, bounds, thickness) = _surface-deposit(
  volumes,
  bounds,
  thickness,
  100%,
  coat-bottoms: true,
)

#let deposit(
  volumes,
  shapes,
  thickness,
  sidewall-coverage: 0%,
) = {
  if volumes.len() == 0 {
    return ((
      shapes: shapes,
      bottom: 0,
      top: thickness,
    ),)
  }
  if sidewall-coverage == 0% {
    let remaining = shapes
    let result = ()
    for volume in volumes.sorted(key: volume => -volume.top) {
      if remaining.len() > 0 {
        let landed = kernel.intersection(
          remaining,
          _volume-shapes-at(volume, volume.top),
        )
        if landed.len() > 0 {
          result.push((
            shapes: landed,
            bottom: volume.top,
            top: volume.top + thickness,
          ))
          remaining = kernel.difference(remaining, landed)
        }
      }
    }
    assert(
      remaining.len() == 0,
      message: "deposition mask extends beyond the existing sample",
    )
    return result
  }
  _surface-deposit(
    volumes,
    shapes,
    thickness,
    sidewall-coverage,
    coat-bottoms: false,
  )
}

#let _etch-selected(volume, layers) = layers == auto or volume.name in layers

#let _etch-blockers(volumes, layers, height) = {
  if layers == auto { return () }
  let blockers = ()
  for volume in volumes {
    if not _etch-selected(volume, layers) and volume.top > height {
      blockers += volume.shapes
    }
  }
  if blockers.len() == 0 { () } else { kernel.merge(blockers) }
}

#let _etch-sources(volumes, mask, layers) = {
  let sources = ()
  for volume in volumes {
    if not _etch-selected(volume, layers) { continue }
    let surface = kernel.intersection(
      _volume-shapes-at(volume, volume.top),
      mask,
    )
    if surface.len() == 0 { continue }
    let covered = _scene-shapes-at(volumes, volume.top, side: "above")
    let exposed = if covered.len() == 0 {
      surface
    } else {
      kernel.difference(surface, covered)
    }
    if exposed.len() > 0 {
      sources.push((
        height: volume.top,
        shapes: exposed,
        layer: volume.at("layer", default: none),
      ))
    }
  }
  sources
}

#let _auto-etch-sources(volumes, sources, layers) = {
  let result = ()
  let sorted = volumes.sorted(key: volume => -volume.top)
  for source in sources {
    let rays = (source.shapes,)
    for volume in sorted {
      if volume.top > source.height or rays.len() == 0 { continue }
      let next-rays = ()
      let selected = _etch-selected(volume, layers)
      let substrate = volume.at("layer", default: none) == 0
      for ray in rays {
        let overlap = kernel.intersection(ray, volume.shapes)
        let bypass = kernel.difference(ray, volume.shapes)
        if bypass.len() > 0 { next-rays.push(bypass) }
        if overlap.len() == 0 { continue }
        if not selected or substrate {
          let depth = _grid-height(source.height - volume.top)
          if depth > 0 {
            result.push(source + (shapes: overlap, depth: depth))
          }
        } else {
          next-rays.push(overlap)
        }
      }
      rays = next-rays
    }
  }
  result
}

#let _etch-tool(source, depth, isotropic, sidewall) = {
  let sections = ()
  if isotropic > 0% {
    // Space facets by surface-normal angle rather than ellipse parameter so
    // non-circular profiles also stay below the binary crease threshold.
    let facets = 7
    let lateral-rate = isotropic / 100%
    for index in range(facets + 1) {
      let normal-angle = 90deg * (facets - index) / facets
      let sine = calc.sin(normal-angle)
      let cosine = calc.cos(normal-angle)
      let denominator = calc.sqrt(
        lateral-rate * lateral-rate * cosine * cosine + sine * sine,
      )
      let height = _grid-height(source.height - depth * sine / denominator)
      let lateral = depth * lateral-rate * lateral-rate * cosine / denominator
      sections.push((
        height: height,
        shapes: kernel.offset(source.shapes, lateral),
      ))
    }
  } else {
    let angle = sidewall
    let lateral = if angle == 90deg {
      0
    } else {
      -depth / calc.tan(angle)
    }
    let lower = kernel.offset(source.shapes, lateral)
    assert(
      lower.len() > 0,
      message: "etch sidewall closes before reaching the requested depth",
    )
    sections = (
      (height: _grid-height(source.height - depth), shapes: lower),
      (height: source.height, shapes: source.shapes),
    )
  }
  let footprint = ()
  for section in sections { footprint += section.shapes }
  (
    shapes: kernel.merge(footprint),
    bottom: sections.first().height,
    top: sections.last().height,
    sections: sections,
  )
}

#let _etch-tools-at(tools, height, side) = {
  let shapes = ()
  for tool in tools {
    shapes += _volume-shapes-at(tool, height, side: side)
  }
  if shapes.len() == 0 { () } else { kernel.merge(shapes) }
}

#let _isotropic-side-tool-at(
  volumes,
  mask,
  layers,
  height,
  side,
  lateral,
) = {
  if lateral <= 0 { return () }
  let scene = _scene-shapes-at(volumes, height, side: side)
  if scene.len() == 0 { return () }

  let selected = ()
  for volume in volumes {
    if _etch-selected(volume, layers) {
      selected += _volume-shapes-at(volume, height, side: side)
    }
  }
  if selected.len() == 0 { return () }
  selected = kernel.merge(selected)

  // A horizontal slice turns every exposed side face into an outline. Use a
  // one-grid-cell strip just inside that outline as the source of the lateral
  // etch front. Inset the mask a little further so the artificial edge of the
  // finite sample is not treated as a physical sidewall.
  let epsilon = 1 / kernel.grid-scale
  let interior = kernel.offset(scene, -epsilon)
  let rim = if interior.len() == 0 {
    scene
  } else {
    kernel.difference(scene, interior)
  }
  let source-domain = kernel.offset(mask, -2 * epsilon)
  if source-domain.len() == 0 { source-domain = mask }
  let source = kernel.intersection(
    kernel.intersection(rim, selected),
    source-domain,
  )
  if source.len() == 0 { return () }

  // The source strip already contributes one grid cell of inward reach.
  kernel.offset(source, calc.max(0, lateral - epsilon))
}

#let _profiled-etch(volumes, mask, depth, layers, isotropic, sidewall) = {
  let sources = _etch-sources(volumes, mask, layers)
  sources = if depth == auto {
    _auto-etch-sources(volumes, sources, layers)
  } else {
    sources.map(source => source + (depth: depth))
  }
  let tools = sources.map(
    source => _etch-tool(source, source.depth, isotropic, sidewall),
  )
  if tools.len() == 0 and not (isotropic > 0% and depth != auto) {
    return volumes
  }

  let heights = ()
  for volume in volumes {
    for section in _volume-sections(volume) {
      let height = _grid-height(section.height)
      if height not in heights { heights.push(height) }
    }
  }
  for tool in tools {
    for section in tool.sections {
      if section.height not in heights { heights.push(section.height) }
    }
  }
  heights = heights.sorted()

  // Equal-time deposition and 100% isotropic removal are exact inverses for
  // an exposed conformal layer. Remove that shell as a layer operation instead
  // of letting independently faceted top and side tools nick its support at
  // their shared boundary.
  let exact-conformal-layers = ()
  if isotropic == 100% and depth != auto {
    let conformal-layers = ()
    for volume in volumes {
      let layer = volume.at("layer", default: none)
      if (
        volume.at("deposition", default: none) == "conformal"
          and layer not in conformal-layers
      ) {
        conformal-layers.push(layer)
      }
    }
    for layer in conformal-layers {
      let pieces = volumes.filter(
        volume => volume.at("layer", default: none) == layer,
      )
      let thickness = pieces.first().at("deposition-thickness", default: none)
      if (
        thickness != none
          and calc.abs(depth - thickness) <= 1 / kernel.grid-scale
          and sources.any(source => source.layer == layer)
          and pieces.all(volume => _volume-sections(volume).all(
            section => kernel.difference(section.shapes, mask).len() == 0,
          ))
      ) {
        exact-conformal-layers.push(layer)
      }
    }
  }
  let exact-conformal-clear = (
    exact-conformal-layers.len() > 0
      and sources.all(source => source.layer in exact-conformal-layers)
  )

  let side-tools = ()
  if isotropic > 0% and depth != auto {
    let lateral = depth * (isotropic / 100%)
    for height in heights {
      side-tools.push((
        height: height,
        above: _isotropic-side-tool-at(
          volumes,
          mask,
          layers,
          height,
          "above",
          lateral,
        ),
        below: _isotropic-side-tool-at(
          volumes,
          mask,
          layers,
          height,
          "below",
          lateral,
        ),
      ))
    }
  }

  let result = ()
  for volume in volumes {
    if exact-conformal-clear {
      if volume.at("layer", default: none) not in exact-conformal-layers {
        result.push(volume)
      }
      continue
    }
    if not _etch-selected(volume, layers) {
      result.push(volume)
      continue
    }
    let pieces = ()
    let volume-heights = heights.filter(
      height => height >= volume.bottom and height <= volume.top,
    )
    for index in range(volume-heights.len() - 1) {
      let bottom = volume-heights.at(index)
      let top = volume-heights.at(index + 1)
      if top <= bottom { continue }
      let kept = ((bottom, "above"), (top, "below")).map(sample => {
        let height = sample.first()
        let side = sample.last()
        let original = _volume-shapes-at(volume, height, side: side)
        let tool = _etch-tools-at(tools, height, side)
        if side-tools.len() > 0 {
          let side-tool = side-tools.find(entry => entry.height == height).at(side)
          if side-tool.len() > 0 {
            tool = if tool.len() == 0 {
              side-tool
            } else {
              kernel.merge(tool + side-tool)
            }
          }
        }
        if tool.len() == 0 { return original }
        kernel.difference(original, tool)
      })
      if kept.first().len() > 0 and kept.last().len() > 0 {
        pieces.push((
          bottom: bottom,
          top: top,
          lower: kept.first(),
          upper: kept.last(),
        ))
      }
    }
    let template = volume
    template.top-accent = 0
    template.bottom-accent = 0
    result += _bands-to-volumes(pieces, template: template)
  }
  result
}

#let _global-etch(volumes, mask, depth, layers) = {
  let scene-top = calc.max(..volumes.map(volume => volume.top))
  let heights = ()
  for volume in volumes {
    for section in _volume-sections(volume) {
      for height in (section.height, section.height - depth) {
        height = _grid-height(height)
        if height >= volume.bottom and height <= volume.top and height not in heights {
          heights.push(height)
        }
      }
    }
    if volume.bottom not in heights { heights.push(volume.bottom) }
    if volume.top not in heights { heights.push(volume.top) }
  }
  heights = heights.sorted()

  let result = ()
  for volume in volumes {
    if not _etch-selected(volume, layers) {
      result.push(volume)
      continue
    }
    let pieces = ()
    let volume-heights = heights.filter(
      height => height >= volume.bottom and height <= volume.top,
    )
    for index in range(volume-heights.len() - 1) {
      let bottom = volume-heights.at(index)
      let top = volume-heights.at(index + 1)
      if top > bottom {
        let kept = ((bottom, "above"), (top, "below")).map(sample => {
          let height = sample.first()
          let side = sample.last()
          let original = _volume-shapes-at(volume, height, side: side)
          let outside = kernel.difference(original, mask)
          let cover-height = height + depth
          let cover = if cover-height > scene-top {
            ()
          } else {
            _scene-shapes-at(volumes, cover-height, side: side)
          }
          let blockers = _etch-blockers(volumes, layers, height)
          let protected = if cover.len() == 0 {
            blockers
          } else if blockers.len() == 0 {
            cover
          } else {
            kernel.merge(cover + blockers)
          }
          let inside = if protected.len() == 0 {
            ()
          } else {
            kernel.intersection(kernel.intersection(original, mask), protected)
          }
          if outside.len() == 0 { inside } else if inside.len() == 0 {
            outside
          } else {
            kernel.merge(outside + inside)
          }
        })
        let lower = kept.first()
        let upper = kept.last()
        if lower.len() > 0 and upper.len() > 0 {
          pieces.push((bottom: bottom, top: top, lower: lower, upper: upper))
        }
      }
    }
    // Bands are gathered per source volume: bands of different volumes carry
    // different materials and must stay apart even where they meet.
    let template = volume
    template.top-accent = 0
    template.bottom-accent = 0
    let face-kept(piece, height) = _shapes-match(
      _canonical-shapes(_volume-shapes-at(piece, height)),
      _canonical-shapes(_volume-shapes-at(volume, height)),
      1.5 / kernel.grid-scale,
    )
    result += _bands-to-volumes(pieces, template: template).map(piece => {
      let restored = piece
      if piece.top == volume.top and face-kept(piece, volume.top) {
        restored.top-accent = volume.at("top-accent", default: 0)
      }
      if piece.bottom == volume.bottom and face-kept(piece, volume.bottom) {
        restored.bottom-accent = volume.at("bottom-accent", default: 0)
      }
      restored
    })
  }
  result
}

#let _selective-etch(volumes, shapes, depth, layers: auto) = {
  // note: snapping heights to the grid avoids floating point comparison errors
  let rays = ((
    shapes: shapes,
    remaining: if depth == auto { auto } else { _grid-height(depth) },
  ),)
  let result = ()

  for volume in volumes.sorted(key: volume => -volume.top) {
    let untouched = volume.shapes
    let next-rays = ()
    let thickness = _grid-height(volume.top - volume.bottom)
    let selected = layers == auto or volume.name in layers
    let substrate = volume.at("layer", default: none) == 0

    for ray in rays {
      let overlap = kernel.intersection(ray.shapes, volume.shapes)
      let bypass = kernel.difference(ray.shapes, volume.shapes)
      if bypass.len() > 0 {
        next-rays.push((
          shapes: bypass,
          remaining: ray.remaining,
        ))
      }
      if overlap.len() > 0 {
        if ray.remaining == auto and substrate {
          // Automatic etches leave the bottommost layer intact.
        } else if not selected {
          // A zero-rate layer remains in place and blocks the etch.
        } else {
          untouched = kernel.difference(untouched, overlap)
          if ray.remaining == auto {
            next-rays.push((
              shapes: overlap,
              remaining: auto,
            ))
          } else if ray.remaining < thickness {
            let etched = _clip-volume(volume, overlap)
            etched = _truncate-volume(
              etched,
              _grid-height(volume.top - ray.remaining),
            )
            etched.top-accent = 0
            if etched.top > etched.bottom {
              result.push(etched)
            }
          } else if ray.remaining > thickness {
            next-rays.push((
              shapes: overlap,
              remaining: _grid-height(ray.remaining - thickness),
            ))
          }
        }
      }
    }

    if untouched.len() > 0 {
      let kept = _clip-volume(volume, untouched)
      result.push(kept)
    }
    rays = next-rays
  }

  result
}

// An etch cuts pieces but never rejoins them, so a seam can survive inside one
// material long after the etch removed the reason for it. Rebuild each layer
// with the rule deposition uses — one layer at a time, or two layers sharing a
// footprint would fuse into one piece and lose a material.
#let _fuse-volumes(volumes) = {
  let layers = (:)
  for volume in volumes {
    let key = str(volume.at("layer", default: 0))
    layers.insert(key, layers.at(key, default: ()) + (volume,))
  }
  let result = ()
  for pieces in layers.values() {
    let bands = ()
    for piece in pieces.sorted(key: piece => piece.bottom) {
      let planes = _volume-sections(piece)
      for index in range(planes.len() - 1) {
        bands.push((
          bottom: planes.at(index).height,
          top: planes.at(index + 1).height,
          lower: planes.at(index).shapes,
          upper: planes.at(index + 1).shapes,
        ))
      }
    }
    result += _bands-to-volumes(bands, template: pieces.first())
  }
  result
}

#let etch(
  volumes,
  shapes,
  depth,
  layers: auto,
  isotropic: 0%,
  sidewall: none,
) = {
  let profiled = isotropic > 0% or sidewall != none
  let etched = if profiled {
    _profiled-etch(
      volumes,
      shapes,
      depth,
      layers,
      isotropic,
      sidewall,
    )
  } else if depth != auto and volumes.any(
    volume => volume.at("sections", default: none) != none,
  ) {
    _global-etch(volumes, shapes, depth, layers)
  } else {
    _selective-etch(volumes, shapes, depth, layers: layers)
  }
  _fuse-volumes(etched)
}

#let _render-faces(faces, volumes, layer-of, render-face: none) = {
  for (index, face) in faces.enumerate() {
    let contours = face.contours.filter(contour => contour.len() >= 3)
    if contours.len() == 0 { continue }
    let volume = volumes.at(face.material)
    draw.on-layer(layer-of(index, face), {
      if render-face == none {
        let fill = _resolve-fill(if face.normal.at(2) > 0 {
          volume.at("top-fill", default: rgb("#b8d6ed"))
        } else {
          volume.at("side-fill", default: rgb("#91b4ce"))
        })
        draw.compound-path({
          for contour in contours {
            draw.line(..contour, close: true)
          }
        }, fill: fill, fill-rule: "even-odd", stroke: none)
      } else {
        let renderable-face = face
        renderable-face.contours = contours
        render-face(renderable-face, volume)
      }
    })
  }
}

// An edge accent is a chamfer Mesa adds for looks, not something the process
// built. Its silhouette — the slant and the true top and bottom of the
// material — is a real outline and is drawn as one. The single edge the accent
// invents is the shoulder: the horizontal line where the cosmetic inset meets
// the rest of the volume, at the height that would not exist without it. Only
// that line is told apart and carries the accent stroke.
#let _accent-edge(edge, volumes) = {
  edge.materials.all(material => {
    let volume = volumes.at(material)
    let at-height(z) = {
      (edge.start, edge.end).all(point => {
        calc.abs(point.at(2) - z) < 1e-6
      })
    }
    let top = volume.at("top-accent", default: 0)
    let bottom = volume.at("bottom-accent", default: 0)
    ((top > 0 and at-height(volume.top - top)) or (
      bottom > 0 and at-height(volume.bottom + bottom)
    ))
  })
}

// Decide how an edge is drawn.
#let _edge-role(edge, volumes) = {
  if edge.kind == "smooth" {
    none
  } else if _accent-edge(edge, volumes) {
    "accent"
  } else if edge.kind == "material" {
    "material"
  } else if edge.kind == "internal" {
    "internal"
  } else {
    "outline"
  }
}

#let _normal-edge-role(edge, volumes) = {
  if edge.visibility == "occluded" { none } else { _edge-role(edge, volumes) }
}

#let _render-edges(edges, volumes, layer-of, render-edge: none) = {
  for edge in edges {
    let role = _normal-edge-role(edge, volumes)
    if role == none { continue }
    draw.on-layer(layer-of(edge), {
      render-edge(edge, volumes, role)
    })
  }
}

#let render(
  volumes,
  view: none,
  toward-light: (0.0, 0.0, 1.0),
  shadows: false,
  crease-angle: 0deg,
  render-face: none,
  render-edge: none,
) = {
  assert(view != none, message: "3D scene rendering requires a view")
  assert(render-edge != none, message: "scene rendering requires an edge renderer")
  let volumes = _expand-accents(volumes)
  for (index, volume) in volumes.enumerate() {
    _validate-volume(volume, index)
  }

  let prepared = kernel.prepare-scene(
    volumes,
    smooth-join-cosine: calc.cos(crease-angle),
  )
  let projected = kernel.project-scene-surfaces(prepared, view)
  let faces = kernel.projected-scene-surfaces(
    projected,
    toward-light,
    shadows: shadows,
  )
  let edges = kernel.prepared-scene-topology(prepared, view)
  // A true back-to-front order over both faces and lines. The faces arrive
  // sorted; a line goes immediately before the first face that stands in front
  // of it without hiding it, which the kernel reports as that line's cover. A
  // line nothing covers goes last, over everything — the ordinary case, since
  // only see-through faces ever cover a line: an opaque one would have hidden
  // it and the line would have been dropped as occluded.
  let first-of-face = (:)
  for (position, face) in faces.enumerate() {
    let key = str(face.source)
    if key not in first-of-face {
      first-of-face.insert(key, position)
    }
  }
  let last = faces.len() + 1
  let place(edge) = {
    let position = last
    for source in edge.cover {
      let key = str(source)
      if key in first-of-face {
        position = calc.min(position, first-of-face.at(key))
      }
    }
    position - .5
  }

  // The canvas keeps its own content at layer 0, so the whole order lives below.
  let span = calc.max(last, 1)
  let layer-at(position) = -2 + 1.9 * position / span

  _render-faces(
    faces,
    volumes,
    (position, face) => layer-at(position),
    render-face: render-face,
  )
  _render-edges(edges, volumes, edge => layer-at(place(edge)), render-edge: render-edge)
}

// Draw the whole scene in one piece, in painter's order, and hand back the
// finished image with the bounds it occupies in grid units.
//
// `volume-style` describes each volume the way the renderer needs it: its fill,
// its edge strokes, and the heights an edge accent invents. It is called after
// the accents have been expanded, so it sees exactly the volumes that are drawn.
#let paint(
  volumes,
  view: none,
  scale: 1.0,
  shading: "flat",
  toward-light: (0.0, 0.0, 1.0),
  intensity: 0.25,
  crease-angle: 0deg,
  volume-style: none,
) = {
  assert(view != none, message: "3D scene rendering requires a view")
  assert(volume-style != none, message: "painting requires a volume style")
  let volumes = _expand-accents(volumes)
  for (index, volume) in volumes.enumerate() {
    _validate-volume(volume, index)
  }
  let prepared = kernel.prepare-scene(
    volumes,
    smooth-join-cosine: calc.cos(crease-angle),
  )
  // Cast shadows are a fact about the shapes and the light, so they are worked
  // out once and reused for every camera angle. The other shading modes have no
  // shadows to work out.
  let shaded = if shading == "fancy" {
    kernel.shade-scene(prepared, toward-light)
  } else {
    bytes(())
  }
  kernel.paint-scene(
    prepared,
    shaded,
    view,
    scale,
    shading,
    toward-light,
    intensity,
    volumes.map(volume-style),
  )
}

// One volume's contribution to a horizontal cross-section: a trapezoid for
// every slice of every surface the plane cuts through. Each slice spans two
// consecutive section heights, so a sloped surface reads as a slanted quad and
// a stepped surface reads as two quads at different depths. Both the finished
// cross-section and its debug view are built from these.
#let _volume-section-quads(volume, y) = {
  let quads = ()
  let planes = _volume-sections(volume)
  for plane-index in range(planes.len() - 1) {
    let lower = planes.at(plane-index)
    let upper = planes.at(plane-index + 1)
    let (lower-shapes, upper-shapes) = _shared-contours(
      lower.shapes,
      upper.shapes,
    )
    let lower-intervals = kernel.cross-section(lower-shapes, y)
    let upper-intervals = kernel.cross-section(upper-shapes, y)
    assert(
      lower-intervals.len() == upper-intervals.len(),
      message: "cross-section topology changes inside a contoured volume",
    )
    for interval-index in range(lower-intervals.len()) {
      let lower-interval = lower-intervals.at(interval-index)
      let upper-interval = upper-intervals.at(interval-index)
      quads.push(((
        (lower-interval.first(), lower.height),
        (lower-interval.last(), lower.height),
        (upper-interval.last(), upper.height),
        (upper-interval.first(), upper.height),
      ),))
    }
  }
  quads
}

#let render-section(volumes, y) = {
  for (index, volume) in volumes.enumerate() {
    _validate-volume(volume, index)
  }

  let sections = (:)
  let order = ()
  for (index, volume) in volumes.sorted(key: volume => volume.bottom).enumerate() {
    let key = str(volume.at("layer", default: index))
    if key not in sections {
      order.push(key)
      sections.insert(key, (
        volume: volume,
        shapes: (),
      ))
    }
    let item = sections.at(key)
    item.shapes += _volume-section-quads(volume, y)
    sections.insert(key, item)
  }

  for key in order {
    let item = sections.at(key)
    let volume = item.volume
    if item.shapes.len() > 0 {
      let shapes = kernel.merge(item.shapes)
      draw.compound-path({
        for shape in shapes {
          for contour in shape {
            draw.line(..contour, close: true)
          }
        }
      },
        fill: _resolve-fill(volume.at(
          "section-fill",
          default: volume.at("side-fill", default: rgb("#91b4ce")),
        )),
        fill-rule: "even-odd",
        stroke: volume.at(
          "stroke",
          default: rgb("#263843") + .5pt,
        ),
      )
    }
  }
}

#let section-debug-styles = (
  // The exterior outline the finished cross-section strokes.
  outline: (
    paint: rgb("#263843"),
    thickness: .8pt,
  ),
  // Where one piece of a layer meets the next. An internal edge the outline
  // covers is a real material boundary or a real step; one left showing inside
  // a single material, away from any step, is a phantom edge.
  internal: (
    paint: black,
    thickness: .45pt,
    dash: "dashed",
  ),
  // Every polygon vertex, so two pieces that fail to meet by a whisker show.
  vertex: rgb("#e98a15"),
)

// Draw the cross-section one piece at a time instead of merging the pieces of a
// layer into one outline. Each piece keeps its own edges and vertices, so the
// stack a deposit or etch produced is laid bare: two pieces that should read as
// one continuous surface show up as two outlines with an internal edge (and,
// where they fail to meet, offset vertices) between them.
#let render-section-debug(volumes, y) = {
  for (index, volume) in volumes.enumerate() {
    _validate-volume(volume, index)
  }
  let pieces = ()
  for volume in volumes.sorted(key: volume => volume.bottom) {
    let quads = _volume-section-quads(volume, y)
    if quads.len() > 0 {
      pieces.push((volume: volume, shapes: kernel.merge(quads)))
    }
  }

  // Fill each piece and draw its edges as internal.
  for (index, piece) in pieces.enumerate() {
    let tint = piece.volume.at(
      "debug-fill",
      default: piece.volume.at("section-fill", default: rgb("#b8d6ed")),
    ).transparentize(70%)
    draw.compound-path({
      for shape in piece.shapes {
        for contour in shape {
          draw.line(..contour, close: true)
        }
      }
    },
      fill: tint,
      fill-rule: "even-odd",
      stroke: section-debug-styles.internal,
    )
  }

  // The exterior outline on top: merge the pieces of each layer the way the
  // finished cross-section does, and stroke that union solid. Wherever this
  // covers an internal edge, that edge was a real boundary or step; an internal
  // edge left showing through is inside one material, i.e. phantom.
  let outlines = (:)
  let order = ()
  for (index, piece) in pieces.enumerate() {
    let key = str(piece.volume.at("layer", default: index))
    if key not in outlines {
      order.push(key)
      outlines.insert(key, ())
    }
    outlines.insert(key, outlines.at(key) + piece.shapes)
  }
  draw.on-layer(50, {
    for key in order {
      for shape in kernel.merge(outlines.at(key)) {
        for contour in shape {
          draw.line(..contour, close: true, stroke: section-debug-styles.outline)
        }
      }
    }
  })

  // Vertices last, so pieces that miss meeting are unmistakable.
  draw.on-layer(100, {
    for piece in pieces {
      for shape in piece.shapes {
        for contour in shape {
          for point in contour {
            draw.circle(
              point,
              radius: .6pt,
              fill: section-debug-styles.vertex,
              stroke: none,
            )
          }
        }
      }
    }
  })
}

#let cut-y(volumes, y, keep: "positive") = {
  let result = ()
  for volume in volumes {
    let shapes = kernel.clip-y(volume.shapes, y, keep: keep)
    if shapes.len() > 0 {
      let clipped = volume
      clipped.shapes = shapes
      let sections = volume.at("sections", default: none)
      if sections != none {
        clipped.sections = sections.map(section => (
          height: section.height,
          shapes: kernel.clip-y(section.shapes, y, keep: keep),
        ))
      }
      result.push(clipped)
    }
  }
  result
}

#let cut-line(volumes, line, keep: "left") = {
  assert(
    type(line) == array and line.len() == 2,
    message: "cut line must contain two points",
  )
  let result = ()
  for volume in volumes {
    let shapes = kernel.clip-line(
      volume.shapes,
      line.first(),
      line.last(),
      keep: keep,
    )
    if shapes.len() > 0 {
      let clipped = volume
      clipped.shapes = shapes
      let sections = volume.at("sections", default: none)
      if sections != none {
        clipped.sections = sections.map(section => (
          height: section.height,
          shapes: kernel.clip-line(
            section.shapes,
            line.first(),
            line.last(),
            keep: keep,
          ),
        ))
      }
      result.push(clipped)
    }
  }
  result
}

#let topology-debug-styles = (
  outline: (
    paint: rgb("#263843"),
    thickness: .8pt,
  ),
  material: (
    paint: rgb("#e98a15"),
    thickness: .6pt,
  ),
  occluded: (
    paint: rgb("#7c3aed"),
    thickness: .45pt,
    dash: "dashed",
  ),
  internal: (
    paint: black,
    thickness: .45pt,
    dash: "dashed",
  ),
  accent: (
    paint: rgb("#0f9d58"),
    thickness: .45pt,
    dash: "dotted",
  ),
  smooth: (
    paint: black.transparentize(75%),
    thickness: .15pt,
  ),
)

#let render-topology-debug(
  volumes,
  view: none,
  crease-angle: 0deg,
) = {
  assert(view != none, message: "topology debug rendering requires a view")
  let volumes = _expand-accents(volumes)
  let debug-volumes = volumes.map(volume => {
    let debug-volume = volume
    debug-volume.stroke = none
    let debug-fill = volume.at(
      "debug-fill",
      default: rgb("#b8d6ed"),
    ).transparentize(45%)
    debug-volume.top-fill = debug-fill
    debug-volume.side-fill = debug-fill
    debug-volume
  })
  let debug-faces = kernel.scene-surfaces(debug-volumes, view, (0.0, 0.0, 1.0))
  _render-faces(
    debug-faces,
    debug-volumes,
    (index, face) => -2 + index / (debug-faces.len() + 1),
  )

  draw.on-layer(100, {
    for edge in kernel.scene-topology(
      volumes,
      view,
      smooth-join-cosine: calc.cos(crease-angle),
    ) {
      let role = if edge.kind == "smooth" {
        "smooth"
      } else if edge.visibility == "occluded" {
        "occluded"
      } else {
        _edge-role(edge, volumes)
      }
      draw.line(
        edge.start,
        edge.end,
        stroke: topology-debug-styles.at(role),
      )
    }
  })
}
