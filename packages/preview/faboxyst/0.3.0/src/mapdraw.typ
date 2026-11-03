// ===========================================================================
//  sketchbook/mapdraw.typ — a lightweight renderer for very large drawings.
//
//  A map of 69 provinces is ~10 000 roughened segments. Pushing those through
//  CeTZ costs about a gigabyte, because every primitive becomes a full canvas
//  element with its own coordinate resolution. Here we skip CeTZ entirely:
//  the Rough.js port hands back plain point lists, and we pour every polyline
//  that shares a stroke into ONE Typst `curve`, as separate subpaths.
//
//  Same wobble, a fraction of the memory.
// ===========================================================================

#import "engine.typ": rough-points, rough-fill-points, sketch-points

/// Turn a list of polylines into a single `curve` element.
///   pts   list of point lists, in centimetres, y pointing UP
///   flip  the drawing height; y is mirrored so the origin is bottom-left
#let polylines(paths, flip: 0cm, scale: 1.0, closed: false, ..style) = {
  let s = scale
  let f = flip
  let segs = ()
  for path in paths {
    if path.len() < 2 { continue }
    let p0 = path.first()
    segs.push(curve.move((p0.at(0) * s * 1cm, f - p0.at(1) * s * 1cm)))
    for p in path.slice(1) {
      segs.push(curve.line((p.at(0) * s * 1cm, f - p.at(1) * s * 1cm)))
    }
    if closed { segs.push(curve.close(mode: "straight")) }
  }
  if segs.len() == 0 { return none }
  curve(..style, ..segs)
}

/// Fill a set of contours as one region (even-odd, so holes punch through).
#let region(contours, flip: 0cm, scale: 1.0, ..style) = polylines(
  contours, flip: flip, scale: scale, closed: true, fill-rule: "even-odd",
  stroke: none, ..style)

/// The rough outline of one closed contour, as one curve.
#let rough-outline(contours, flip: 0cm, scale: 1.0, seed: 1, roughness: 0.7,
                   bowing: 0.6, ..style) = {
  let paths = ()
  for (i, ct) in contours.enumerate() {
    for pass in rough-points(ct, closed: true, roughness: roughness,
                             bowing: bowing, seed: seed + i * 97) {
      paths.push(pass)
    }
  }
  polylines(paths, flip: flip, scale: scale, fill: none, ..style)
}

/// A rough hatch fill, as one curve.
#let rough-hatch(contours, flip: 0cm, scale: 1.0, style: "hachure",
                 angle: -41, gap: 0.13, seed: 1, roughen: true,
                 roughness: 0.9, ..st) = {
  let lines = rough-fill-points(contours, style: style, angle: angle,
    gap: gap, seed: seed)
  if style == "dots" {
    return polylines(lines, flip: flip, scale: scale, closed: true,
      stroke: none, ..st)
  }
  let paths = ()
  for (i, l) in lines.enumerate() {
    if roughen {
      for p in rough-points(l, roughness: roughness,
                            disable-multi-stroke: true, seed: seed + i) {
        paths.push(p)
      }
    } else {
      paths.push(l)
    }
  }
  polylines(paths, flip: flip, scale: scale, fill: none, ..st)
}

/// A sketched (PGF-decoration) polyline, as one curve.
#let sketched(paths, flip: 0cm, scale: 1.0, seed: 1, amplitude: 0.5,
              ..style) = {
  let out = ()
  for (i, p) in paths.enumerate() {
    out.push(sketch-points(p, seed: seed + i, amplitude: amplitude))
  }
  polylines(out, flip: flip, scale: scale, ..style)
}

/// Absolute placement inside the drawing frame, in data coordinates.
#let at-point(p, body, flip: 0cm, scale: 1.0) = place(top + left,
  dx: p.at(0) * scale * 1cm, dy: flip - p.at(1) * scale * 1cm,
  place(center + horizon, body))
