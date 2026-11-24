#import "protocol.typ": request, data, result-data, analysis-model, execution-policy
#import "analysis.typ": analyze, layout, accessibility-annotations, local-accessibility-annotations, topology-annotations
#import "annotations.typ": default-theme, numbering-style, coaxial-annotations, base-annotation, label-annotation, annotation-items, annotation-legends, color-legend, _node-wcag-text-fill
#import "chart.typ": plot-theme, legend-style, compose-legend

#let _annotation-array(annotations) = annotation-items(annotations)

#let _annotation-legend-style(value) = {
  if value == auto or value == true { legend-style() }
  else if value == false or value == none { legend-style(position: none) }
  else if type(value) == dictionary { value }
  else { panic("legend must be auto, true, false, none, or legend-style") }
}

#let _annotation-legend-content(metadata, style, theme) = {
  let panels = metadata.map(entry => {
    if entry.at("kind", default: "") != "color-scale" {
      panic("unsupported annotation legend kind: " + repr(entry.at("kind", default: none)))
    }
    color-legend(
      entry.scale,
      width: entry.width,
      height: entry.height,
      ticks: entry.ticks,
      text-size: entry.at("text-size", default: auto),
      orientation: entry.orientation,
      reverse: entry.reverse,
      format: entry.format,
      theme: theme,
      inset: style.inset,
      fill: style.fill,
      stroke: style.stroke,
      radius: style.radius,
    )
  })
  let columns = if style.columns != auto { calc.max(1, style.columns) }
  else if style.direction == "column" { 1 }
  else if style.max-columns != auto { calc.min(panels.len(), calc.max(1, style.max-columns)) }
  else { calc.max(1, panels.len()) }
  let item-gap = if style.item-gap == auto { theme.legend-item-gap } else { style.item-gap }
  let body = if panels.len() == 1 { panels.first() } else {
    grid(columns: (auto,) * columns, column-gutter: item-gap, row-gutter: style.row-gap, ..panels)
  }
  if style.width == auto { body } else { box(width: style.width, body) }
}

#let _base-style(
  index,
  nucleotide,
  annotations,
  theme,
  node-text-contrast,
  node-contrast-background,
  node-contrast-on-failure,
) = {
  let fill = theme.node-fill
  let colors = theme.base-colors
  if type(colors) == dictionary {
    fill = colors.at(nucleotide, default: colors.at("N", default: fill))
  }
  let style = (
    fill: fill,
    stroke: theme.node-stroke,
    text-fill: theme.text-fill,
  )
  let contrast = if node-text-contrast == auto {
    theme.at("node-text-contrast", default: "aa")
  } else { node-text-contrast }
  let contrast-background = if node-contrast-background == auto {
    theme.at("node-contrast-background", default: auto)
  } else { node-contrast-background }
  let contrast-on-failure = if node-contrast-on-failure == auto {
    theme.at("node-contrast-on-failure", default: "error")
  } else { node-contrast-on-failure }
  let explicit-text-fill = false
  for annotation in annotations {
    if annotation.at("kind", default: "") == "base" and annotation.at("at", default: 0) == index {
      if annotation.at("fill", default: auto) != auto { style.fill = annotation.fill }
      if annotation.at("stroke", default: auto) != auto { style.stroke = annotation.stroke }
      if annotation.at("text-fill", default: auto) != auto {
        style.text-fill = annotation.text-fill
        explicit-text-fill = true
      }
      if annotation.at("text-contrast", default: auto) != auto { contrast = annotation.text-contrast }
      if annotation.at("contrast-background", default: auto) != auto { contrast-background = annotation.contrast-background }
      if annotation.at("contrast-on-failure", default: auto) != auto { contrast-on-failure = annotation.contrast-on-failure }
    }
  }
  if not explicit-text-fill {
    if contrast == auto { contrast = "aa" }
    if contrast == "aa" or contrast == "aaa" {
      style.text-fill = _node-wcag-text-fill(
        index,
        style.fill,
        contrast,
        background-behind: contrast-background,
        on-failure: contrast-on-failure,
      )
    } else if contrast != "fixed" {
      panic("node text contrast must be \"fixed\", \"aa\", or \"aaa\"")
    }
  }
  style
}

#let _pair-key(i, j) = str(calc.min(i, j)) + ":" + str(calc.max(i, j))

#let _probability-map(probabilities) = {
  let entries = if probabilities == none {
    ()
  } else if type(probabilities) == dictionary {
    probabilities.at("pair_probabilities", default: ())
  } else {
    probabilities
  }
  let map = (:)
  for entry in entries {
    map.insert(_pair-key(entry.i, entry.j), entry.probability)
  }
  map
}

#let _pair-style(pair, annotations, theme, probability-map) = {
  let stroke = if pair.canonical { theme.pair-stroke } else { theme.noncanonical-stroke }
  let key = _pair-key(pair.i, pair.j)
  if key in probability-map {
    let p = probability-map.at(key)
    let base = if pair.canonical { rgb("#2855a6") } else { rgb("#8c4f9f") }
    let alpha = 12% + 88% * p
    stroke = if type(stroke) == dictionary {
      stroke + (paint: base.transparentize(100% - alpha), thickness: 0.45pt + 0.9pt * p)
    } else {
      (paint: base.transparentize(100% - alpha), thickness: 0.45pt + 0.9pt * p)
    }
  }
  for annotation in annotations {
    if annotation.at("kind", default: "") == "pair" and _pair-key(
      annotation.at("i", default: 0),
      annotation.at("j", default: 0),
    ) == key and annotation.at("stroke", default: auto) != auto {
      stroke = annotation.stroke
    }
  }
  stroke
}

#let _natural-point(x, y, ratio, rotation, mirror-x, mirror-y) = {
  let x = x * ratio
  let y = y
  if mirror-x { x = ratio - x }
  if mirror-y { y = 1.0 - y }
  let dx = x - ratio / 2
  let dy = y - 0.5
  let cosine = calc.cos(rotation)
  let sine = calc.sin(rotation)
  (
    x: dx * cosine - dy * sine,
    y: dx * sine + dy * cosine,
  )
}

#let _natural-geometry(scene, rotation, mirror-x, mirror-y) = {
  let points = scene.points.map(point => _natural-point(
    point.x,
    point.y,
    scene.aspect_ratio,
    rotation,
    mirror-x,
    mirror-y,
  ))
  let xs = points.map(point => point.x)
  let ys = points.map(point => point.y)
  let min-x = calc.min(..xs)
  let max-x = calc.max(..xs)
  let min-y = calc.min(..ys)
  let max-y = calc.max(..ys)
  (
    points: points,
    min-x: min-x,
    max-x: max-x,
    min-y: min-y,
    max-y: max-y,
    width: calc.max(0.000001, max-x - min-x),
    height: calc.max(0.000001, max-y - min-y),
  )
}

#let _view(scene, geometry, width, height, pad, fit, rotation, mirror-x, mirror-y) = {
  if fit not in ("contain", "cover", "stretch") {
    panic("fit must be \"contain\", \"cover\", or \"stretch\"")
  }
  let pad-x = if type(pad) == dictionary { pad.at("x", default: 0pt) } else { pad }
  let pad-y = if type(pad) == dictionary { pad.at("y", default: 0pt) } else { pad }
  let available-width = calc.max(1pt, width - 2 * pad-x)
  let available-height = calc.max(1pt, height - 2 * pad-y)
  let sx = available-width / geometry.width
  let sy = available-height / geometry.height
  if fit == "contain" {
    let scale = calc.min(sx, sy)
    sx = scale
    sy = scale
  } else if fit == "cover" {
    let scale = calc.max(sx, sy)
    sx = scale
    sy = scale
  }
  let content-width = geometry.width * sx
  let content-height = geometry.height * sy
  (
    scene: scene,
    geometry: geometry,
    scale-x: sx,
    scale-y: sy,
    offset-x: pad-x + (available-width - content-width) / 2,
    offset-y: pad-y + (available-height - content-height) / 2,
    rotation: rotation,
    mirror-x: mirror-x,
    mirror-y: mirror-y,
  )
}

#let _map-natural(view, point) = (
  view.offset-x + (point.x - view.geometry.min-x) * view.scale-x,
  view.offset-y + (point.y - view.geometry.min-y) * view.scale-y,
)

#let _point(view, index) = _map-natural(view, view.geometry.points.at(index))

#let _transform-layout-point(view, x, y) = _map-natural(
  view,
  _natural-point(
    x,
    y,
    view.scene.aspect_ratio,
    view.rotation,
    view.mirror-x,
    view.mirror-y,
  ),
)

#let _curve-lines(lines, stroke) = {
  let parts = ()
  for line-points in lines {
    parts.push(curve.move(line-points.at(0)))
    parts.push(curve.line(line-points.at(1)))
  }
  if parts.len() > 0 { curve(stroke: stroke, ..parts) }
}

#let _backbone-arc(arc, view, stroke) = {
  let start = arc.start_degrees * 1deg
  let end = arc.end_degrees * 1deg
  let delta-degrees = arc.end_degrees - arc.start_degrees
  if arc.clockwise {
    while delta-degrees > 0 { delta-degrees -= 360 }
  } else {
    while delta-degrees < 0 { delta-degrees += 360 }
  }
  let arc-end = start + delta-degrees * 1deg
  let segments = calc.max(1, int(calc.ceil(calc.abs(delta-degrees) / 90)))
  let center-x = arc.center_x * view.scene.aspect_ratio
  let center-y = arc.center_y
  let radius-x = arc.radius_x * view.scene.aspect_ratio
  let radius-y = arc.radius_y
  let parts = ()
  for segment in range(0, segments) {
    let a-angle = start + (arc-end - start) * segment / segments
    let b-angle = start + (arc-end - start) * (segment + 1) / segments
    let delta = b-angle - a-angle
    let factor = 4 / 3 * calc.tan(delta / 4)
    let raw-a = (
      x: center-x + radius-x * calc.cos(a-angle),
      y: center-y + radius-y * calc.sin(a-angle),
    )
    let raw-b = (
      x: center-x + radius-x * calc.cos(b-angle),
      y: center-y + radius-y * calc.sin(b-angle),
    )
    let raw-control-a = (
      x: raw-a.x + factor * (-radius-x * calc.sin(a-angle)),
      y: raw-a.y + factor * ( radius-y * calc.cos(a-angle)),
    )
    let raw-control-b = (
      x: raw-b.x - factor * (-radius-x * calc.sin(b-angle)),
      y: raw-b.y - factor * ( radius-y * calc.cos(b-angle)),
    )
    let transform = point => _map-natural(view, _natural-point(
      point.x / view.scene.aspect_ratio,
      point.y,
      view.scene.aspect_ratio,
      view.rotation,
      view.mirror-x,
      view.mirror-y,
    ))
    let a = transform(raw-a)
    let b = transform(raw-b)
    let control-a = transform(raw-control-a)
    let control-b = transform(raw-control-b)
    if segment == 0 { parts.push(curve.move(a)) }
    parts.push(curve.cubic(control-a, control-b, b))
  }
  curve(stroke: stroke, ..parts)
}

#let _centered-at(point, body) = place(
  top + left,
  dx: point.at(0),
  dy: point.at(1),
  box(width: 0pt, height: 0pt, place(center + horizon, body)),
)

#let _centered-sized-at(point, body, measured) = place(
  top + left,
  dx: point.at(0) - measured.width / 2,
  dy: point.at(1) - measured.height / 2,
  box(
    width: measured.width,
    height: measured.height,
    align(center + horizon, body),
  ),
)

#let _resolved-text-align(value) = if value == "left" { left }
else if value == "center" { center }
else if value == "right" { right }
else { value }

#let _label-body(
  body,
  size,
  fill,
  width: auto,
  text-align: left,
  box-fill: none,
  box-stroke: none,
  box-inset: 0pt,
  box-radius: 0pt,
) = {
  let inner = text(size: size, fill: fill, body)
  let inner = if width == auto {
    box(inner)
  } else {
    box(width: width, align(_resolved-text-align(text-align) + horizon, inner))
  }
  box(
    fill: box-fill,
    stroke: box-stroke,
    inset: box-inset,
    radius: box-radius,
    inner,
  )
}

#let _unit-direction(direction) = {
  let norm = calc.sqrt(direction.x * direction.x + direction.y * direction.y)
  if norm < 0.000001 { (x: 0.0, y: -1.0) }
  else { (x: direction.x / norm, y: direction.y / norm) }
}

#let _direction-from-lengths(dx, dy, fallback) = {
  let x = dx / 1pt
  let y = dy / 1pt
  if calc.abs(x) + calc.abs(y) < 0.000001 { _unit-direction(fallback) }
  else { _unit-direction((x: x, y: y)) }
}

#let _quadratic-point(a, control, b, t) = (
  (1 - t) * (1 - t) * a.at(0) + 2 * (1 - t) * t * control.at(0) + t * t * b.at(0),
  (1 - t) * (1 - t) * a.at(1) + 2 * (1 - t) * t * control.at(1) + t * t * b.at(1),
)

#let _quadratic-curve(a, control, b, stroke) = curve(
  stroke: stroke,
  curve.move(a),
  curve.cubic(
    (
      a.at(0) + 2 / 3 * (control.at(0) - a.at(0)),
      a.at(1) + 2 / 3 * (control.at(1) - a.at(1)),
    ),
    (
      b.at(0) + 2 / 3 * (control.at(0) - b.at(0)),
      b.at(1) + 2 / 3 * (control.at(1) - b.at(1)),
    ),
    b,
  ),
)

#let _leader-end(center, measured, direction, gap) = {
  let direction = _unit-direction(direction)
  let large = 100000pt
  let horizontal = if calc.abs(direction.x) < 0.000001 {
    large
  } else { measured.width / 2 / calc.abs(direction.x) }
  let vertical = if calc.abs(direction.y) < 0.000001 {
    large
  } else { measured.height / 2 / calc.abs(direction.y) }
  let distance = calc.min(horizontal, vertical) + gap
  (
    center.at(0) - direction.x * distance,
    center.at(1) - direction.y * distance,
  )
}

#let _draw-leader(start, end, stroke, bend) = {
  if calc.abs(bend) < 0.000001 {
    line(start: start, end: end, stroke: stroke)
  } else {
    let dx = end.at(0) - start.at(0)
    let dy = end.at(1) - start.at(1)
    let control = (
      (start.at(0) + end.at(0)) / 2 - dy * bend,
      (start.at(1) + end.at(1)) / 2 + dx * bend,
    )
    _quadratic-curve(start, control, end, stroke)
  }
}

#let _bounds(center, width, height, padding: 0pt) = (
  left: center.at(0) - width / 2 - padding,
  right: center.at(0) + width / 2 + padding,
  top: center.at(1) - height / 2 - padding,
  bottom: center.at(1) + height / 2 + padding,
)

#let _overlaps(first, second) = not (
  first.right <= second.left or first.left >= second.right or
  first.bottom <= second.top or first.top >= second.bottom
)

#let _anchor-directions(anchor, outward) = {
  let all = (
    (x: outward.at(0), y: outward.at(1)),
    (x: 0.0, y: -1.0), (x: 1.0, y: -1.0),
    (x: 1.0, y: 0.0), (x: 1.0, y: 1.0),
    (x: 0.0, y: 1.0), (x: -1.0, y: 1.0),
    (x: -1.0, y: 0.0), (x: -1.0, y: -1.0),
  )
  let selected = if anchor == "top" { (x: 0.0, y: -1.0) }
  else if anchor == "top-right" { (x: 1.0, y: -1.0) }
  else if anchor == "right" { (x: 1.0, y: 0.0) }
  else if anchor == "bottom-right" { (x: 1.0, y: 1.0) }
  else if anchor == "bottom" { (x: 0.0, y: 1.0) }
  else if anchor == "bottom-left" { (x: -1.0, y: 1.0) }
  else if anchor == "left" { (x: -1.0, y: 0.0) }
  else if anchor == "top-left" { (x: -1.0, y: -1.0) }
  else if anchor == "auto" { none }
  else { panic("unknown label anchor " + repr(anchor)) }
  if selected == none { all } else { (selected,) + all.filter(direction => direction != selected) }
}

#let _outward-direction(view, index) = {
  let point = view.geometry.points.at(index)
  let center-x = (view.geometry.min-x + view.geometry.max-x) / 2
  let center-y = (view.geometry.min-y + view.geometry.max-y) / 2
  let dx = point.x - center-x
  let dy = point.y - center-y
  let norm = calc.sqrt(dx * dx + dy * dy)
  if norm < 0.000001 { (0.0, -1.0) } else { (dx / norm, dy / norm) }
}

#let _strand-ranges(scene) = {
  let starts = (1,) + scene.strand_breaks.map(position => position + 1)
  let ends = scene.strand_breaks + (scene.points.len(),)
  starts.zip(ends)
}

#let _sequence-chars(sequence) = sequence.clusters().filter(char => char != "&" and char != " " and char != "\n")

#let _render-scene(
  scene,
  width: 10cm,
  height: auto,
  node-radius: 5pt,
  font-size: 6.8pt,
  theme: default-theme,
  node-text-contrast: auto,
  node-contrast-background: auto,
  node-contrast-on-failure: auto,
  annotations: (),
  legend: auto,
  legend-theme: plot-theme(),
  probabilities: none,
  fit: "contain",
  rotation: 0deg,
  mirror-x: false,
  mirror-y: false,
  clip: false,
  detail: auto,
  label-padding: auto,
  numbering: 10,
  start-number: 1,
  show-ends: true,
  show-direction: false,
  show-backbone: true,
  show-pairs: true,
  show-nucleotides: true,
) = context {
  let legend-metadata = annotation-legends(annotations)
  let annotations = _annotation-array(annotations)
  let probability-map = _probability-map(probabilities)
  let label-sizes = annotations
    .filter(annotation => annotation.at("kind", default: "") in ("label", "strand-label"))
    .map(annotation => {
      let fill = if annotation.at("fill", default: auto) == auto { theme.text-fill } else { annotation.fill }
      let size = if annotation.at("size", default: auto) == auto { 7pt } else { annotation.size }
      measure(_label-body(
        annotation.body,
        size,
        fill,
        width: annotation.at("width", default: auto),
        text-align: annotation.at("text-align", default: left),
        box-fill: annotation.at("box-fill", default: none),
        box-stroke: annotation.at("box-stroke", default: none),
        box-inset: annotation.at("box-inset", default: 0pt),
        box-radius: annotation.at("box-radius", default: 0pt),
      ))
    })
  let measured-padding = if label-sizes.len() == 0 { node-radius + 11pt } else {
    let widest = calc.max(..label-sizes.map(size => size.width))
    let tallest = calc.max(..label-sizes.map(size => size.height))
    calc.min(width * 22%, calc.max(widest / 2, tallest / 2) + node-radius + 8pt)
  }
  let pad = if label-padding == auto { measured-padding } else { label-padding }
  let geometry = _natural-geometry(scene, rotation, mirror-x, mirror-y)
  let ratio = geometry.width / geometry.height
  let resolved-height = if height == auto {
    let candidate = (width - 2 * pad) / ratio + 2 * pad
    if candidate < 2.4cm { 2.4cm } else if candidate > 1.35 * width { 1.35 * width } else { candidate }
  } else { height }
  let strand-ranges = _strand-ranges(scene)
  let view-pad = if (
    scene.method == "linear"
    and strand-ranges.len() > 1
    and label-padding == auto
  ) {
    let row-pad-fraction = if strand-ranges.len() == 2 { 29% } else { 18% }
    let row-axis-x = calc.abs(calc.sin(rotation))
    let row-axis-y = calc.abs(calc.cos(rotation))
    (
      x: calc.max(pad, width * row-pad-fraction * row-axis-x),
      y: calc.max(pad, resolved-height * row-pad-fraction * row-axis-y),
    )
  } else { pad }
  let view = _view(scene, geometry, width, resolved-height, view-pad, fit, rotation, mirror-x, mirror-y)
  let chars = _sequence-chars(scene.sequence)
  let breaks = scene.strand_breaks
  let adjacent-distances = range(0, scene.points.len() - 1)
    .filter(index => not ((index + 1) in breaks))
    .map(index => {
      let a = view.geometry.points.at(index)
      let b = view.geometry.points.at(index + 1)
      let dx = (a.x - b.x) * view.scale-x
      let dy = (a.y - b.y) * view.scale-y
      // Typst lengths cannot be squared; this conservative L1-derived bound
      // is sufficient for automatic level-of-detail selection.
      calc.max(calc.abs(dx), calc.abs(dy))
    })
  let minimum-spacing = if adjacent-distances.len() == 0 { width } else { calc.min(..adjacent-distances) }
  let resolved-detail = if detail == auto {
    if minimum-spacing >= 2 * node-radius + 1pt { "full" }
    else if minimum-spacing >= 2.5pt { "nodes" }
    else { "backbone" }
  } else { detail }
  if resolved-detail not in ("full", "nodes", "backbone") {
    panic("detail must be auto, \"full\", \"nodes\", or \"backbone\"")
  }
  let occupied = scene.points.enumerate().map(((index, _)) => _bounds(
    _point(view, index),
    2 * node-radius,
    2 * node-radius,
    padding: 1pt,
  ))
  let drawing = block(width: width, height: resolved-height, clip: clip, {
    // Region highlights sit behind all structural edges.
    for annotation in annotations {
      if annotation.at("kind", default: "") in ("region", "positions") {
        let positions = if annotation.kind == "positions" {
          annotation.at("positions", default: ())
        } else {
          let first = calc.max(1, annotation.at("from", default: 1))
          let last = calc.min(scene.points.len(), annotation.at("to", default: first))
          range(first, last + 1)
        }
        let radius = if annotation.at("radius", default: auto) == auto { node-radius + 2.6pt } else { annotation.radius }
        let fill = if annotation.at("fill", default: auto) == auto { theme.region-fill } else { annotation.fill }
        let stroke = if annotation.at("stroke", default: auto) == auto { theme.region-stroke } else { annotation.stroke }
        for position in positions {
          if position < 1 or position > scene.points.len() { panic("highlight position is out of range") }
          let point = _point(view, position - 1)
          _centered-at(point, circle(radius: radius, fill: fill, stroke: stroke))
        }
      }
    }

    if show-backbone {
      let lines = ()
      let arc-map = (:)
      for arc in scene.at("backbone_arcs", default: ()) {
        arc-map.insert(str(arc.from) + ":" + str(arc.to), arc)
      }
      for index in range(0, scene.points.len() - 1) {
        if not ((index + 1) in breaks) {
          let key = str(index + 1) + ":" + str(index + 2)
          if key in arc-map {
            place(top + left, _backbone-arc(
              arc-map.at(key),
              view,
              theme.backbone-stroke,
            ))
          } else {
            lines.push((
              _point(view, index),
              _point(view, index + 1),
            ))
          }
        }
      }
      place(top + left, _curve-lines(lines, theme.backbone-stroke))
    }

    if show-pairs {
      for pair in scene.pairs {
        let a = _point(view, pair.i - 1)
        let b = _point(view, pair.j - 1)
        let pair-stroke = _pair-style(pair, annotations, theme, probability-map)
        if scene.method == "linear" and pair.at("interstrand", default: false) {
          place(top + left, line(start: a, end: b, stroke: pair-stroke))
        } else if scene.method == "linear" {
          let span = b.at(0) - a.at(0)
          let rise = calc.min(resolved-height * 0.42, calc.max(8pt, calc.abs(span) * 0.31))
          let center-y = resolved-height / 2
          let side = if strand-ranges.len() <= 1 or (a.at(1) + b.at(1)) / 2 <= center-y {
            -1
          } else { 1 }
          place(top + left, curve(
            stroke: pair-stroke,
            curve.move(a),
            curve.cubic(
              (a.at(0) + span * 0.22, a.at(1) + side * rise),
              (b.at(0) - span * 0.22, b.at(1) + side * rise),
              b,
            ),
          ))
        } else {
          place(top + left, line(start: a, end: b, stroke: pair-stroke))
        }
      }
    }

    // User-supplied tertiary contacts and comparison-only pairs.
    for annotation in annotations {
      if annotation.at("kind", default: "") == "interaction" {
        let i = annotation.at("i", default: 0)
        let j = annotation.at("j", default: 0)
        if i < 1 or j < 1 or i > scene.points.len() or j > scene.points.len() or i == j {
          panic("interaction annotation indices must identify two distinct nucleotides")
        }
        let a = _point(view, i - 1)
        let b = _point(view, j - 1)
        let raw-a = view.geometry.points.at(i - 1)
        let raw-b = view.geometry.points.at(j - 1)
        let bend = annotation.at("bend", default: 0.18)
        let raw-control = (
          x: (raw-a.x + raw-b.x) / 2 - (raw-b.y - raw-a.y) * bend,
          y: (raw-a.y + raw-b.y) / 2 + (raw-b.x - raw-a.x) * bend,
        )
        let control = _map-natural(view, raw-control)
        let stroke = if annotation.at("stroke", default: auto) == auto {
          theme.interaction-stroke
        } else { annotation.stroke }
        if calc.abs(bend) < 0.000001 {
          place(top + left, line(start: a, end: b, stroke: stroke))
        } else {
          place(top + left, _quadratic-curve(a, control, b, stroke))
        }
        if annotation.at("label", default: none) != none {
          let position = calc.max(0.0, calc.min(1.0, annotation.at("label-position", default: 0.5)))
          let label-point = _quadratic-point(a, control, b, position)
          label-point = (
            label-point.at(0) + annotation.at("label-dx", default: 0pt),
            label-point.at(1) + annotation.at("label-dy", default: 0pt),
          )
          let label-fill = if annotation.at("label-fill", default: auto) == auto {
            theme.label-fill
          } else { annotation.label-fill }
          let label-size = if annotation.at("label-size", default: auto) == auto {
            5.8pt
          } else { annotation.label-size }
          let label-box-fill = if annotation.at("label-box-fill", default: auto) == auto {
            white.transparentize(12%)
          } else { annotation.label-box-fill }
          let body = _label-body(
            annotation.label,
            label-size,
            label-fill,
            width: annotation.at("label-width", default: auto),
            text-align: annotation.at("label-align", default: center),
            box-fill: label-box-fill,
            box-stroke: annotation.at("label-box-stroke", default: none),
            box-inset: annotation.at("label-box-inset", default: 1pt),
            box-radius: annotation.at("label-box-radius", default: 1pt),
          )
          let measured = measure(body)
          _centered-sized-at(label-point, body, measured)
        }
      }
    }

    for annotation in annotations {
      if annotation.at("kind", default: "") == "coaxial" {
        let indices = (
          annotation.at("first-i", default: 0),
          annotation.at("first-j", default: 0),
          annotation.at("second-i", default: 0),
          annotation.at("second-j", default: 0),
        )
        if indices.all(index => index >= 1 and index <= scene.points.len()) {
          let first-a = _point(view, indices.at(0) - 1)
          let first-b = _point(view, indices.at(1) - 1)
          let second-a = _point(view, indices.at(2) - 1)
          let second-b = _point(view, indices.at(3) - 1)
          let first = ((first-a.at(0) + first-b.at(0)) / 2, (first-a.at(1) + first-b.at(1)) / 2)
          let second = ((second-a.at(0) + second-b.at(0)) / 2, (second-a.at(1) + second-b.at(1)) / 2)
          let stroke = if annotation.at("stroke", default: auto) == auto {
            theme.coaxial-stroke
          } else {
            annotation.stroke
          }
          place(top + left, line(start: first, end: second, stroke: stroke))
        }
      }
    }

    // Direction markers deliberately overlap the nucleotide by 1pt, but are
    // painted underneath it. The overlap removes antialiasing seams while the
    // node fill and outline hide the inward portion of the triangle.
    if show-direction {
      for range in strand-ranges {
        let endpoint = range.at(1) - 1
        let neighbor = calc.max(range.at(0) - 1, endpoint - 1)
        if endpoint != neighbor {
          let point = _point(view, endpoint)
          let raw = view.geometry.points.at(endpoint)
          let prior = view.geometry.points.at(neighbor)
          let dx = raw.x - prior.x
          let dy = raw.y - prior.y
          let norm = calc.max(0.000001, calc.sqrt(dx * dx + dy * dy))
          let ux = dx / norm
          let uy = dy / norm
          let tip = (point.at(0) + ux * (node-radius + 4pt), point.at(1) + uy * (node-radius + 4pt))
          let base = (point.at(0) + ux * (node-radius - 1pt), point.at(1) + uy * (node-radius - 1pt))
          let triangle-left = (base.at(0) - uy * 2.4pt, base.at(1) + ux * 2.4pt)
          let triangle-right = (base.at(0) + uy * 2.4pt, base.at(1) - ux * 2.4pt)
          place(top + left, polygon(tip, triangle-left, triangle-right, fill: theme.direction-fill, stroke: none))
        }
      }
    }

    if show-nucleotides and resolved-detail != "backbone" {
      for (index, nucleotide) in chars.enumerate() {
        let point = _point(view, index)
        let style = _base-style(
          index + 1,
          nucleotide,
          annotations,
          theme,
          node-text-contrast,
          node-contrast-background,
          node-contrast-on-failure,
        )
        let body = if resolved-detail == "full" {
          align(center + horizon, text(size: font-size, weight: "medium", fill: style.text-fill, nucleotide))
        } else { [] }
        _centered-at(point, circle(
          radius: node-radius,
          fill: style.fill,
          stroke: style.stroke,
          inset: 0pt,
          body,
        ))
      }
    }

    if show-ends {
      for range in strand-ranges {
        for endpoint in ((range.at(0) - 1, [5′]), (range.at(1) - 1, [3′])) {
          let index = endpoint.at(0)
          let point = _point(view, index)
          let direction = _outward-direction(view, index)
          let label-point = (
            point.at(0) + direction.at(0) * (node-radius + 7pt),
            point.at(1) + direction.at(1) * (node-radius + 7pt),
          )
          let body = text(size: 5.3pt, fill: theme.label-fill, endpoint.at(1))
          let size = measure(body)
          occupied.push(_bounds(label-point, size.width, size.height, padding: 0.6pt))
          _centered-at(label-point, body)
        }
      }
    }

    if numbering != none {
      let number-style = if type(numbering) == dictionary { numbering }
      else if type(numbering) == array { numbering-style(every: none, positions: numbering) }
      else { numbering-style(every: numbering) }
      let every = number-style.at("every", default: none)
      let explicit = number-style.at("positions", default: ())
      let per-strand = number-style.at("per-strand", default: false)
      let show-first = number-style.at("show-first", default: false)
      let show-last = number-style.at("show-last", default: false)
      let number-size = number-style.at("size", default: 5.3pt)
      let number-fill = if number-style.at("fill", default: auto) == auto { theme.label-fill } else { number-style.fill }
      for index in range(0, scene.points.len()) {
        let position = index + 1
        let current-range = strand-ranges.find(range => position >= range.at(0) and position <= range.at(1))
        let relative = position - current-range.at(0) + 1
        let number = start-number + (if per-strand { relative - 1 } else { index })
        let selected = (
          position in explicit
          or (every != none and every > 0 and calc.rem(number, every) == 0)
          or (show-first and position == current-range.at(0))
          or (show-last and position == current-range.at(1))
        )
        if selected {
          let point = _point(view, index)
          let raw = view.geometry.points.at(index)
          let dx = raw.x - (view.geometry.min-x + view.geometry.max-x) / 2
          let dy = raw.y - (view.geometry.min-y + view.geometry.max-y) / 2
          let norm = calc.sqrt(dx * dx + dy * dy)
          let ux = if norm < 0.05 { 0.0 } else { dx / norm }
          let uy = if norm < 0.05 { -1.0 } else { dy / norm }
          let body = text(size: number-size, fill: number-fill, str(number))
          let size = measure(body)
          let label-point = none
          let offset = node-radius + 5pt + calc.max(size.width, size.height) / 2
          for direction in _anchor-directions("auto", (ux, uy)) {
            if label-point == none {
              let candidate = (
                point.at(0) + direction.x * offset,
                point.at(1) + direction.y * offset,
              )
              let candidate-bounds = _bounds(candidate, size.width, size.height, padding: 0.7pt)
              if not occupied.any(box => _overlaps(box, candidate-bounds)) {
                label-point = candidate
              }
            }
          }
          if label-point == none {
            label-point = (point.at(0) + ux * offset * 1.8, point.at(1) + uy * offset * 1.8)
          }
          occupied.push(_bounds(label-point, size.width, size.height, padding: 0.7pt))
          _centered-at(label-point, body)
        }
      }
    }

    for annotation in annotations {
      if annotation.at("kind", default: "") in ("label", "strand-label") {
        let at = if annotation.kind == "strand-label" {
          let strand = annotation.at("strand", default: 0)
          if strand < 1 or strand > strand-ranges.len() { panic("strand-label strand is out of range") }
          let range = strand-ranges.at(strand - 1)
          if annotation.at("at", default: "start") == "end" { range.at(1) } else { range.at(0) }
        } else { annotation.at("at", default: 0) }
        if at >= 1 and at <= scene.points.len() {
          let point = _point(view, at - 1)
          let fill = if annotation.at("fill", default: auto) == auto { theme.text-fill } else { annotation.fill }
          let size = if annotation.at("size", default: auto) == auto { 7pt } else { annotation.size }
          let body = _label-body(
            annotation.body,
            size,
            fill,
            width: annotation.at("width", default: auto),
            text-align: annotation.at("text-align", default: left),
            box-fill: annotation.at("box-fill", default: none),
            box-stroke: annotation.at("box-stroke", default: none),
            box-inset: annotation.at("box-inset", default: 0pt),
            box-radius: annotation.at("box-radius", default: 0pt),
          )
          let measured = measure(body)
          let outward = _outward-direction(view, at - 1)
          let fixed = annotation.at("dx", default: auto) != auto or annotation.at("dy", default: auto) != auto
          let chosen = none
          let direction = (x: outward.at(0), y: outward.at(1))
          if fixed {
            let dx = if annotation.at("dx", default: auto) == auto { 0pt } else { annotation.dx }
            let dy = if annotation.at("dy", default: auto) == auto { 0pt } else { annotation.dy }
            chosen = (point.at(0) + dx, point.at(1) + dy)
            direction = _direction-from-lengths(dx, dy, (x: outward.at(0), y: outward.at(1)))
          } else {
            let candidates = _anchor-directions(annotation.at("anchor", default: "auto"), outward)
            for candidate in candidates {
              if chosen == none {
                let candidate = _unit-direction(candidate)
                let extent = calc.abs(candidate.x) * measured.width / 2 + calc.abs(candidate.y) * measured.height / 2
                let candidate-center = (
                  point.at(0) + candidate.x * (annotation.at("distance", default: 13pt) + extent),
                  point.at(1) + candidate.y * (annotation.at("distance", default: 13pt) + extent),
                )
                let candidate-bounds = _bounds(candidate-center, measured.width, measured.height, padding: 1.5pt)
                if not occupied.any(box => _overlaps(box, candidate-bounds)) {
                  chosen = candidate-center
                  direction = candidate
                }
              }
            }
            if chosen == none {
              let fallback = _unit-direction(candidates.first())
              let extent = calc.abs(fallback.x) * measured.width / 2 + calc.abs(fallback.y) * measured.height / 2
              chosen = (
                point.at(0) + fallback.x * (annotation.at("distance", default: 13pt) + extent),
                point.at(1) + fallback.y * (annotation.at("distance", default: 13pt) + extent),
              )
              direction = fallback
            }
          }
          let label-bounds = _bounds(chosen, measured.width, measured.height, padding: 1.5pt)
          occupied.push(label-bounds)
          if annotation.at("leader", default: true) {
            direction = _unit-direction(direction)
            let leader-start = (
              point.at(0) + direction.x * (node-radius + annotation.at("leader-start-gap", default: 1pt)),
              point.at(1) + direction.y * (node-radius + annotation.at("leader-start-gap", default: 1pt)),
            )
            let leader-end = _leader-end(
              chosen,
              measured,
              direction,
              annotation.at("leader-end-gap", default: 1pt),
            )
            let leader-stroke = if annotation.at("leader-stroke", default: auto) == auto {
              theme.leader-stroke
            } else { annotation.leader-stroke }
            place(top + left, _draw-leader(
              leader-start,
              leader-end,
              leader-stroke,
              annotation.at("leader-bend", default: 0.0),
            ))
          }
          _centered-sized-at(chosen, body, measured)
        }
      }
    }
  })
  let legend-style = _annotation-legend-style(legend)
  if legend-metadata.len() == 0 or legend-style.position == none { drawing } else {
    compose-legend(
      drawing,
      _annotation-legend-content(legend-metadata, legend-style, legend-theme),
      style: legend-style,
    )
  }
}

/// Draw a supplied structure, or analyze and draw its MFE structure when
/// `structure` is `auto`. Geometry and analysis use the same versioned API.
#let draw(sequence, structure: auto, model: analysis-model(), constraints: none, method: "naview", execution: execution-policy(), ..args) = {
  if structure == auto {
    render(analyze(sequence, model: model, constraints: constraints, execution: execution), method: method, ..args)
  } else {
    let scene = data(layout(sequence, structure, method: method, execution: execution))
    _render-scene(scene, ..args)
  }
}

/// Render layout geometry returned by `layout`, including user-edited point
/// coordinates. This is the escape hatch for hand-tuned publication figures.
#let render-scene(scene, ..args) = _render-scene(result-data(scene), ..args)

/// Classify base pairs shared by or unique to two structures.

#let render(
  response,
  which: "mfe",
  item: 1,
  method: "naview",
  width: 10cm,
  height: auto,
  node-radius: 5pt,
  font-size: 6.8pt,
  theme: default-theme,
  node-text-contrast: auto,
  node-contrast-background: auto,
  node-contrast-on-failure: auto,
  annotations: (),
  legend: auto,
  legend-theme: plot-theme(),
  probabilities: auto,
  fit: "contain",
  rotation: 0deg,
  mirror-x: false,
  mirror-y: false,
  clip: false,
  detail: auto,
  label-padding: auto,
  numbering: 10,
  start-number: 1,
  show-ends: true,
  show-direction: false,
  show-backbone: true,
  show-pairs: true,
  show-nucleotides: true,
) = {
  if type(response) != dictionary or response.at("schema_version", default: 0) != 1 {
    panic("render expects a successful ribon analysis/1 response")
  }
  if not response.at("ok", default: false) {
    panic("render cannot consume an unsuccessful ribon response")
  }
  let kind = response.result.kind
  let data = response.result.data
  let sequence = data.at("sequence", default: none)
  let structure = none
  let inferred-probabilities = none
  let inferred-annotations = ()

  if kind == "analysis" {
    structure = if which == "mfe" { data.mfe_structure }
    else if which == "centroid" { data.centroid_structure }
    else if which == "mea" { data.mea_structure }
    else { panic("which must be \"mfe\", \"centroid\", or \"mea\"") }
    inferred-probabilities = data
  } else if kind == "mfe" {
    structure = data.structure
  } else if kind == "energy" {
    structure = data.structure
    inferred-annotations = coaxial-annotations(data)
  } else if kind == "samples" {
    if item < 1 or item > data.samples.len() { panic("sample item is out of range") }
    structure = data.samples.at(item - 1).structure
  } else if kind == "suboptimal" {
    if item < 1 or item > data.structures.len() { panic("suboptimal item is out of range") }
    structure = data.structures.at(item - 1).structure
  } else if kind == "accessibility" {
    let base = result-data(analyze(
      data.sequence,
      model: response.model,
      constraints: response.constraints,
      execution: response.execution,
    ))
    structure = if which == "mfe" { base.mfe_structure }
    else if which == "centroid" { base.centroid_structure }
    else if which == "mea" { base.mea_structure }
    else { panic("which must be \"mfe\", \"centroid\", or \"mea\"") }
    inferred-probabilities = base
    inferred-annotations = accessibility-annotations(data)
  } else if kind == "local" {
    let base = result-data(analyze(
      data.sequence,
      model: response.model,
      constraints: response.constraints,
      execution: response.execution,
    ))
    structure = if which == "mfe" { base.mfe_structure }
    else if which == "centroid" { base.centroid_structure }
    else if which == "mea" { base.mea_structure }
    else { panic("which must be \"mfe\", \"centroid\", or \"mea\"") }
    inferred-probabilities = data.pair_probabilities
    inferred-annotations = local-accessibility-annotations(data)
  } else if kind == "circular" {
    method = "circular"
    structure = if which == "mfe" { data.mfe_structure }
    else if which == "centroid" { data.centroid_structure }
    else if which == "mea" { data.mea_structure }
    else { panic("which must be \"mfe\", \"centroid\", or \"mea\"") }
    inferred-probabilities = data
  } else if kind == "pseudoknot" {
    structure = if which == "mfe" { data.restricted_mfe_structure }
    else if which == "centroid" { data.restricted_centroid_structure }
    else if which == "mea" { data.restricted_mea_structure }
    else if which == "arbitrary-mfe" { data.exact_arbitrary_ensemble.mfe_structure }
    else if which == "arbitrary-centroid" { data.exact_arbitrary_ensemble.centroid_structure }
    else if which == "arbitrary-mea" { data.exact_arbitrary_ensemble.mea_structure }
    else if which == "hybrid" { data.hybrid_structure }
    else if which == "probknot" { data.structure }
    else if which == "matching-centroid" { data.matching_centroid_structure }
    else if which == "matching-mea" { data.matching_mea_structure }
    else { panic("which must be \"probknot\", \"hybrid\", \"matching-centroid\", \"matching-mea\", \"mfe\", \"centroid\", \"mea\", \"arbitrary-mfe\", \"arbitrary-centroid\", or \"arbitrary-mea\"") }
    inferred-probabilities = if which == "hybrid" { data.hybrid_pairs }
    else if which == "probknot" { data.pairs }
    else if which == "matching-centroid" { data.matching_centroid_pairs }
    else if which == "matching-mea" { data.matching_mea_pairs }
    else if which.starts-with("arbitrary-") { data.exact_arbitrary_ensemble.pair_probabilities }
    else { data.restricted_pair_probabilities }
  } else if kind == "pseudoknot-energy" {
    structure = data.structure
  } else if kind == "conditional-density2" {
    structure = if which == "mfe" { data.mfe_structure }
    else if which == "centroid" { data.centroid_structure }
    else if which == "mea" { data.mea_structure }
    else { panic("which must be \"mfe\", \"centroid\", or \"mea\"") }
    inferred-probabilities = data
  } else if kind == "conditional-density2-energy" {
    structure = data.structure
  } else if kind == "conditional-density2-samples" {
    if item < 1 or item > data.samples.len() { panic("conditional sample item is out of range") }
    structure = data.samples.at(item - 1).structure
    inferred-annotations = topology-annotations(data.samples.at(item - 1).topology)
  } else if kind == "conditional-density2-suboptimal" {
    if item < 1 or item > data.structures.len() { panic("conditional suboptimal item is out of range") }
    structure = data.structures.at(item - 1).structure
    inferred-annotations = topology-annotations(data.structures.at(item - 1).topology)
  } else if kind == "gquad" {
    structure = data.structure
    if structure.contains("+") and data.candidates.len() > 0 {
      inferred-annotations = data.candidates.first().guanine_positions.map(position => base-annotation(
        position,
        fill: rgb("#ffd166"),
        stroke: (paint: rgb("#a05a00"), thickness: 0.8pt),
      ))
    }
  } else if kind == "modified" {
    sequence = data.canonical_sequence
    structure = data.analysis.mfe_structure
    inferred-probabilities = data.analysis
    inferred-annotations = data.modifications.map(entry => label-annotation(
      entry.position,
      entry.symbol,
      dx: 0pt,
      dy: -13pt,
      fill: rgb("#7b2cbf"),
    ))
  } else if kind == "duplex" {
    sequence = data.sequence_a + "&" + data.sequence_b
    structure = data.structure
    method = if method == "naview" { "linear" } else { method }
    inferred-probabilities = data.conditional_pair_probabilities
  } else if kind == "cofold" {
    sequence = data.sequence_a + "&" + data.sequence_b
    structure = data.complex_ab.structure
    method = if method == "naview" { "linear" } else { method }
    inferred-probabilities = data.complex_ab.pair_probabilities
  } else if kind == "comparative" {
    sequence = data.consensus_sequence
    structure = if which == "mfe" { data.analysis.mfe_structure }
    else if which == "centroid" { data.analysis.centroid_structure }
    else if which == "mea" { data.analysis.mea_structure }
    else { panic("which must be \"mfe\", \"centroid\", or \"mea\"") }
    inferred-probabilities = data.analysis
  } else if kind == "landscape" {
    structure = if which == "start" { data.start_structure }
    else if which == "target" or which == "mfe" { data.target_structure }
    else if which == "saddle" {
      data.path.sorted(key: step => step.energy_kcal_mol).last().structure
    } else { panic("which must be \"start\", \"target\", or \"saddle\"") }
  } else if kind == "inverse-design" {
    if data.candidates.len() == 0 { panic("inverse-design result has no candidates") }
    sequence = data.candidates.first().sequence
    structure = if which == "mfe" { data.candidates.first().mfe_structure }
    else if which == "target" { data.target_structure }
    else { panic("which must be \"mfe\" or \"target\"") }
  } else if kind == "ligand" {
    structure = if which == "mfe" { data.mfe_structure }
    else if which == "centroid" { data.centroid_structure }
    else if which == "mea" { data.mea_structure }
    else { panic("which must be \"mfe\", \"centroid\", or \"mea\"") }
    inferred-probabilities = data
    inferred-annotations = data.motifs.filter(motif => motif.sequence_matches).map(motif =>
      label-annotation(
        motif.start,
        motif.id + " p=" + str(calc.round(motif.occupancy_probability * 1000) / 1000),
        fill: rgb("#7b2cbf"),
      )
    )
  } else if kind == "fatgraph-topology" {
    structure = data.structure
    inferred-annotations = topology-annotations(data)
  } else {
    panic("result kind \"" + kind + "\" is not directly renderable")
  }

  if sequence == none or structure == none {
    panic("renderable result is missing sequence or structure")
  }
  let scene-response = request(
    "layout",
    ("sequence": sequence, "structure": structure),
    model: response.model,
    options: ("method": method),
    execution: response.at("execution", default: execution-policy()),
  )
  _render-scene(
    scene-response.result.data,
    width: width,
    height: height,
    node-radius: node-radius,
    font-size: font-size,
    theme: theme,
    node-text-contrast: node-text-contrast,
    node-contrast-background: node-contrast-background,
    node-contrast-on-failure: node-contrast-on-failure,
    annotations: (inferred-annotations, annotations),
    legend: legend,
    legend-theme: legend-theme,
    probabilities: if probabilities == auto { inferred-probabilities } else { probabilities },
    fit: fit,
    rotation: rotation,
    mirror-x: mirror-x,
    mirror-y: mirror-y,
    clip: clip,
    detail: detail,
    label-padding: label-padding,
    numbering: numbering,
    start-number: start-number,
    show-ends: show-ends,
    show-direction: show-direction,
    show-backbone: show-backbone,
    show-pairs: show-pairs,
    show-nucleotides: show-nucleotides,
  )
}
