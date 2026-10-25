#import "../core/utils.typ" as utils
#import "../core/styles.typ": _deixis-edge-stroke
#import "../core/native.typ": *

/// Defines a reusable connector head. A custom render(request) returns
/// (body: content, trim: length, bounds: (left:, top:, right:, bottom:)).
/// The local tip is (0pt, 0pt), forward is +x, and positive y points down.
/// Native stealth is a filled triangular tip with an open notch;
/// vee is the separate constant-width stroked V. Both accept length/width.
#let deixis-arrowhead(
  /// Native stealth, triangle, vee, circle, diamond or bar. Stealth is a filled tip with a notched rear.
  /// -> str
  shape: "stealth",
  /// Positive head length along the shaft; auto derives a minimum size from shaft thickness.
  /// -> auto | length
  length: auto,
  /// Positive transverse head width; auto derives a minimum size from shaft thickness.
  /// -> auto | length
  width: auto,
  /// Head fill; auto inherits shaft paint. Open vee/bar shapes use strokes.
  /// -> auto | none | color
  fill: auto,
  /// Head outline; auto fills closed shapes and strokes open shapes using shaft styling.
  /// -> auto | none | stroke | color | length | dictionary
  stroke: auto,
  /// Nonnegative shaft shortening at this endpoint; auto uses native/custom renderer trim.
  /// -> auto | length
  trim: auto,
  /// Optional callback(request) returning body, trim and ordered tip-local bounds; can adapt third-party drawing code.
  /// -> none | function
  render: none,
) = {
  assert(shape in ("stealth", "triangle", "vee", "circle", "diamond", "bar"), message: "deixis: Unknown arrowhead shape " + repr(shape))
  assert(render == none or type(render) == function, message: "deixis: Arrowhead render must be a function.")
  (kind: "deixis-arrowhead", shape: shape, length: length, width: width,
    fill: fill, stroke: stroke, trim: trim, render: render)
}

#let _deixis-resolve-stroke(value) = {
  if value == none { return none }
  assert(not _deixis-edge-stroke(value),
    message: "deixis: A connector or arrowhead needs a single stroke, not rectangular edge strokes.")
  let s = _std-stroke(value)
  _std-stroke(paint: if s.paint == auto { black } else { s.paint },
    thickness: if s.thickness == auto { 1pt } else { s.thickness },
    cap: s.cap, join: s.join, dash: s.dash, miter-limit: s.miter-limit)
}

#let _deixis-head-specs(heads, marks, incoming: false, outgoing: false) = {
  let mark = marks in ("mark", "start", "both")
  let body = marks in ("body", "end", "both")
  let specs = if heads == auto {
    (mark: if mark { "stealth" } else { none }, body: if body { "stealth" } else { none })
  } else if heads == none { (mark: none, body: none) }
  else if type(heads) in (str, function) or (type(heads) == dictionary and heads.at("kind", default: none) == "deixis-arrowhead") {
    (mark: none, body: heads)
  } else {
    assert(type(heads) == dictionary and heads.keys().all(k => k in ("mark", "body")),
      message: "deixis: Heads must be a shape, an arrowhead, or (mark: ..., body: ...).")
    (mark: heads.at("mark", default: none), body: heads.at("body", default: none))
  }
  if incoming { specs.mark = none }
  if outgoing { specs.body = none }
  specs
}

#let _deixis-prepare-head(spec, link-stroke, endpoint) = {
  if spec in (none, "none") { return none }
  let head = if type(spec) == str { deixis-arrowhead(shape: spec) }
    else if type(spec) == function { deixis-arrowhead(render: spec) }
    else { spec }
  assert(type(head) == dictionary and head.at("kind", default: none) == "deixis-arrowhead",
    message: "deixis: A head must be a shape name, deixis-arrowhead(..), or a renderer function.")
  // A disabled shaft still has usable head metrics and independent head styling.
  let line-stroke = _deixis-resolve-stroke(if link-stroke == none { black + 1pt } else { link-stroke })
  let thick = utils.resolve-len(line-stroke.thickness)
  let length = if head.length == auto { calc.max(4pt, thick * 4) } else { utils.resolve-len(head.length) }
  let width = if head.width == auto { calc.max(5pt, thick * 5) } else { utils.resolve-len(head.width) }
  assert(length > 0pt and width > 0pt, message: "deixis: Arrowhead length and width must be positive.")
  let fill = if head.fill == auto { line-stroke.paint } else { head.fill }
  let head-stroke = if head.stroke == auto { line-stroke } else if head.stroke == none { none } else { _deixis-resolve-stroke(head.stroke) }
  let request = (length: length, width: width, stroke: head-stroke, fill: fill, endpoint: endpoint,
    tip: (0pt, 0pt), direction: (1.0, 0.0), frame: "tip-local-x-forward-y-down")
  let result = if head.render != none { (head.render)(request) } else {
    let outline = if head.stroke == auto {
      if head.shape in ("vee", "bar") or fill == none { line-stroke } else { none }
    } else { head.stroke }
    let points = if head.shape == "stealth" { ((0pt, 0pt), (-length, -width / 2), (-length * 0.6, 0pt), (-length, width / 2)) }
      else if head.shape == "triangle" { ((0pt, 0pt), (-length, -width / 2), (-length, width / 2)) }
      else if head.shape == "diamond" { ((0pt, 0pt), (-length / 2, -width / 2), (-length, 0pt), (-length / 2, width / 2)) }
      else if head.shape == "vee" { ((-length, -width / 2), (0pt, 0pt), (-length, width / 2)) }
      else { ((0pt, -width / 2), (0pt, width / 2)) }
    let drawing = if head.shape == "circle" {
      // An ellipse allows independent longitudinal length and transverse width.
      place(top + left, dx: -length, dy: -width / 2, ellipse(width: length, height: width, fill: fill, stroke: outline))
    } else {
      let commands = (curve.move(points.first()),) + points.slice(1).map(p => curve.line(p))
      let closed = head.shape in ("stealth", "triangle", "diamond")
      if closed { commands.push(curve.close()) }
      curve(..commands, fill: if closed { fill } else { none }, stroke: outline)
    }
    let trim = if head.shape == "stealth" { calc.max(0pt, length * 0.6 - 0.2pt) }
      else if head.shape in ("triangle", "diamond", "circle") { calc.max(0pt, length - 0.2pt) }
      else { 0pt }
    let padding = if outline == none { 0pt } else {
      let s = _deixis-resolve-stroke(outline)
      let miter = if s.miter-limit == auto { 4 } else { s.miter-limit }
      utils.resolve-len(s.thickness) * calc.max(1, miter) / 2
    }
    (body: drawing, trim: trim, bounds: (left: -length - padding, right: padding,
      top: -width / 2 - padding, bottom: width / 2 + padding))
  }
  assert(type(result) == dictionary and ("body", "trim", "bounds").all(k => k in result),
    message: "deixis: A head renderer must return body, trim, and bounds.")
  let trim = utils.resolve-signed-len(if head.trim == auto { result.trim } else { head.trim })
  assert(trim >= 0pt, message: "deixis: Arrowhead trim cannot be negative.")
  assert(type(result.body) == content, message: "deixis: Arrowhead body must be content.")
  let bounds = result.bounds
  assert(type(bounds) == dictionary and ("left", "right", "top", "bottom").all(k => k in bounds),
    message: "deixis: Arrowhead bounds need left, right, top, and bottom.")
  let resolved-bounds = (:)
  for key in ("left", "right", "top", "bottom") {
    resolved-bounds.insert(key, utils.resolve-signed-len(bounds.at(key)))
  }
  bounds = resolved-bounds
  assert(bounds.left <= bounds.right and bounds.top <= bounds.bottom,
    message: "deixis: Arrowhead bounds must be ordered.")
  result + (trim: trim, bounds: bounds, request: request)
}

#let _deixis-paint-head(head, tip, forward) = {
  if head == none or forward == (0.0, 0.0) { return none }
  let angle = calc.atan2(forward.at(0), forward.at(1))
  place(top + left, dx: tip.at(0), dy: tip.at(1),
    rotate(angle, origin: top + left, reflow: false,
      box(width: 0pt, height: 0pt, baseline: 0pt, place(top + left, head.body))))
}

/// Paints a prepared head from a connector renderer request in its local frame.
/// A none head or a zero direction emits no content.
#let deixis-render-head(
  /// Prepared head from a connector painter request, or none; not a raw head specification.
  /// -> none | dictionary
  head,
  /// Tip position in the current source-local painting plane.
  /// -> array
  tip,
  /// Nonzero forward tangent vector; a zero vector suppresses the head.
  /// -> array
  forward,
) = _deixis-paint-head(head, tip, forward)
