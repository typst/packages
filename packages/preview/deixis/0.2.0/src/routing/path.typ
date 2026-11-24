#import "../core/utils.typ" as deixis-utils
#import "geometry.typ": *
#import "spill.typ": _deixis-spill-region
#import "heads.typ": *
#import "curves.typ": _deixis-curve-cmds
#import "bspline.typ": _deixis-bspline-cmds
#import "hobby.typ": _deixis-hobby-cmds
#import "spec.typ": deixis-link-types, _deixis-route-name, _deixis-route-spec, _deixis-route-control
#import "gaps.typ": _deixis-path-gaps, _deixis-prepare-gap-marks, _deixis-paint-gap-marks
#import "cuts.typ": _deixis-cut-specs, _deixis-prepare-cuts, _deixis-cut-path
#import "crossings.typ": _deixis-crossing-record, _deixis-apply-crossings
#import "fragments.typ": _deixis-page-fragment, _deixis-continuation-peer
#import "continuations.typ": _deixis-continuation-site, _deixis-counterpart-lookup
#import "continuation-marks.typ": _deixis-prepare-continuation-mark, _deixis-paint-continuation-mark
#import "connector-scene.typ": _deixis-connector-scene, _deixis-connector-scene-plan, _deixis-connector-scene-events
#import "../layout/geometry.typ": _deixis-port-bounds, _deixis-select-port, _deixis-box-bounds, _deixis-inline-bounds
#import "../core/native.typ": *

#let deixis-waypoint-split = "split"

// Absolute numerical geometry needs no layout measurement. Preserve contextual
// resolution at document boundaries for font/relative lengths.
#let _deixis-path-length(value) = {
  if type(value) == length and value.em == 0 { value }
  else { deixis-utils.resolve-len(value) }
}

// Native auto radius depends on shaft width. Scene validation must resolve the
// same value rather than treating auto as sharp and silently skipping smoothing.
#let _deixis-path-radius(value, line-stroke) = {
  if value != auto { return _deixis-path-length(value) }
  let obj = _std-stroke(if line-stroke == none { 1pt } else { line-stroke })
  let thick = _deixis-path-length(if obj.thickness == auto { 1pt } else { obj.thickness })
  calc.max(3pt, thick * 4)
}

// Draw the rectangle around mark marker.
#let _deixis-draw-marker-highlight(
  mark-x,
  mark-y,
  marker-width,
  marker-str,
  stroke: 0.5pt + luma(200),
  text-size: auto,
  has-inline-box: false,
  mark-type: "inline",
) = {
  let t-val = deixis-utils.resolve-len(if text-size != auto and type(text-size) == length { text-size } else { 11pt })
  let bounds = _deixis-inline-bounds(mark-x, mark-y, marker-width, t-val)
  let box-y = bounds.top
  let box-x = bounds.left - 1.5pt
  let actual-box-h = bounds.bottom - bounds.top

  if not has-inline-box {
    if marker-str == none {
      // do nothing
    } else if mark-type == "phantom" or marker-str == "" {
      return place(dx: mark-x, dy: box-y, line(start: (0pt, 0pt), end: (0pt, actual-box-h), stroke: stroke))
    } else if mark-type == "inline" {
      return place(dx: box-x, dy: box-y, box(
        width: marker-width + 3pt,
        height: actual-box-h,
        stroke: stroke,
        radius: 1pt,
      ))
    }
  }
  return none
}

// Compatibility adapter for internal callers; all head geometry lives in heads.typ.
#let _deixis-draw-arrowhead(p1, p2, stroke: luma(0)) = {
  let head = _deixis-prepare-head("stealth", stroke, "body")
  _deixis-paint-head(head, p2, _deixis-unit(_deixis-sub(p2, p1)))
}

// Corners for right-angle and chamfer links.
#let _deixis-orthogonal-cmds(vertices, radius: 0pt, corner-style: "fillet", fixed: ()) = {
  let cmds = ()
  if vertices.len() < 2 { return cmds }

  let abs-radius = _deixis-path-length(if radius == auto { 0pt } else { radius })

  // deduplicate consecutive identical points
  let clean-pts = ()
  for p in vertices {
    if clean-pts.len() == 0 or clean-pts.last() != p { clean-pts.push(p) }
  }
  if clean-pts.len() < 2 { return cmds }

  for i in range(1, clean-pts.len() - 1) {
    let p-prev = clean-pts.at(i - 1)
    let p-curr = clean-pts.at(i)
    let p-next = clean-pts.at(i + 1)

    let dx-in = p-prev.at(0) - p-curr.at(0)
    let dy-in = p-prev.at(1) - p-curr.at(1)
    let len-in = calc.sqrt((dx-in / 1pt) * (dx-in / 1pt) + (dy-in / 1pt) * (dy-in / 1pt)) * 1pt

    let dx-out = p-next.at(0) - p-curr.at(0)
    let dy-out = p-next.at(1) - p-curr.at(1)
    let len-out = calc.sqrt((dx-out / 1pt) * (dx-out / 1pt) + (dy-out / 1pt) * (dy-out / 1pt)) * 1pt

    // shrink the radius/chamfer cut if the line segment is extremely short
    let r = if p-curr in fixed { 0pt } else { calc.min(abs-radius, len-in / 2.0, len-out / 2.0) }

    if r <= 0.05pt or len-in == 0pt or len-out == 0pt {
      cmds.push(_deixis-line(p-curr))
    } else {
      let p-in = (
        p-curr.at(0) + (dx-in / len-in) * r,
        p-curr.at(1) + (dy-in / len-in) * r,
      )
      let p-out = (
        p-curr.at(0) + (dx-out / len-out) * r,
        p-curr.at(1) + (dy-out / len-out) * r,
      )

      cmds.push(_deixis-line(p-in))

      if corner-style == "chamfer" {
        cmds.push(_deixis-line(p-out))
      } else {
        cmds.push(_deixis-quad(p-curr, p-out))
      }
    }
  }
  cmds.push(_deixis-line(clean-pts.last()))
  return cmds
}

// Resolves the optimal geometric connection between a set of source and destination ports based on Manhattan or Euclidean distance.
#let _deixis-resolve-best-ports(source-ports, dest-ports, metric: "euclidean") = {
  let best-S = none
  let best-D = none
  let min-cost = 0pt

  for source in source-ports {
    for dest in dest-ports {
      // Axis-aligned attachment segments are Cartesian intervals. Their closest
      // coordinates are exact; overlapping intervals use a symmetric midpoint.
      let closest(a, b) = {
        if a.last() < b.first() { (a.last(), b.first()) }
        else if b.last() < a.first() { (a.first(), b.last()) }
        else { let p = (calc.max(a.first(), b.first()) + calc.min(a.last(), b.last())) / 2; (p, p) }
      }
      let xs = closest(source.at("x-range", default: (source.x, source.x)), dest.at("x-range", default: (dest.x, dest.x)))
      let ys = closest(source.at("y-range", default: (source.y, source.y)), dest.at("y-range", default: (dest.y, dest.y)))
      let S = source + (x: xs.first(), y: ys.first())
      let D = dest + (x: xs.last(), y: ys.last())
      let sx = deixis-utils.resolve-signed-len(S.x)
      let sy = deixis-utils.resolve-signed-len(S.y)
      let dx = deixis-utils.resolve-signed-len(D.x)
      let dy = deixis-utils.resolve-signed-len(D.y)

      let diff-x = dx - sx
      let diff-y = dy - sy

      let abs-dx = if diff-x < 0pt { -diff-x } else { diff-x }
      let abs-dy = if diff-y < 0pt { -diff-y } else { diff-y }

      let dist = if metric == "euclidean" {
        let diff-x-num = deixis-utils.to-float(diff-x)
        let diff-y-num = deixis-utils.to-float(diff-y)
        calc.sqrt(diff-x-num * diff-x-num + diff-y-num * diff-y-num) * 1pt
      } else {
        abs-dx + abs-dy
      }
      let penalty = 0pt

      if D.id == "top" and sy > dy { penalty += 1e10pt }
      if D.id == "bottom" and sy < dy { penalty += 1e10pt }
      if D.id == "left" and sx > dx { penalty += 1e10pt }
      if D.id == "right" and sx < dx { penalty += 1e10pt }

      if S.id == "top" and dy > sy { penalty += 1e10pt }
      if S.id == "bottom" and dy < sy { penalty += 1e10pt }
      if S.id == "left" and dx > sx { penalty += 1e10pt }
      if S.id == "right" and dx < sx { penalty += 1e10pt }

      let cost = dist + penalty

      if best-S == none or cost < min-cost {
        min-cost = cost
        best-S = S
        best-D = D
      }
    }
  }
  return (best-S, best-D)
}

// Translates user-provided relative waypoints into absolute page coordinates.
#let _deixis-resolve-waypoints(waypoints, start-x, start-y, m-box, b-box, page-bounds: none) = {
  if waypoints in (none, auto) { return () }
  let wps = if type(waypoints) == array { waypoints } else { (waypoints,) }

  let resolved = ()

  let current-x = start-x
  let current-y = start-y

  let get-anchor(spec) = {
    if type(spec) != str { return none }
    let parts = spec.split("-")
    let root = parts.first()
    if root not in ("mark", "body", "source", "start", "target", "end") { return none }
    let suffix = parts.slice(1)
    let valid = ("", "left", "right", "top", "bottom", "center", "horizon",
      "top-left", "top-right", "bottom-left", "bottom-right", "top-center", "bottom-center", "horizon-left", "horizon-right")
    assert(suffix.join("-") in valid, message: "deixis: Invalid waypoint anchor " + repr(spec))
    let bounds = if root in ("mark", "source", "start") { m-box } else { b-box }
    let x = if "left" in suffix { bounds.left } else if "right" in suffix { bounds.right } else { bounds.center-x }
    let y = if "top" in suffix { bounds.top } else if "bottom" in suffix { bounds.bottom } else { bounds.center-y }
    (x, y)
  }

  let resolve-coord(spec, cur, is-x) = {
    // 1. Check if it's an anchor string
    let anchor = get-anchor(spec)
    if anchor != none { return if is-x { anchor.at(0) } else { anchor.at(1) } }

    // 2. Otherwise, resolve relative/ratio logic from the center
    let s = if is-x { m-box.center-x } else { m-box.center-y }
    let e = if is-x { b-box.center-x } else { b-box.center-y }

    let val = 0pt
    if type(spec) == ratio {
      val = (e - s) * spec
    } else if type(spec) == relative {
      val = deixis-utils.resolve-signed-len(spec.length) + (e - s) * spec.ratio
    } else {
      val = deixis-utils.resolve-signed-len(spec)
    }
    return cur + val
  }

  for wp in wps {
    if (
      wp == deixis-waypoint-split
        or wp in deixis-link-types
        or (type(wp) == dictionary and "kind" in wp)
        or (type(wp) == array and wp.len() > 0 and wp.at(0) == deixis-waypoint-split)
    ) {
      if type(wp) == dictionary {
        wp = _deixis-route-spec(wp)
        if type(wp) == dictionary and wp.kind == "b-spline" {
          wp.controls = _deixis-resolve-waypoints(wp.controls, current-x, current-y, m-box, b-box, page-bounds: page-bounds)
        }
      }
      resolved.push(wp)
      continue
    }

    if type(wp) == dictionary {
      if "resolved-pin" in wp {
        current-x = wp.resolved-pin.first()
        current-y = wp.resolved-pin.last()
        resolved.push((current-x, current-y))
        continue
      }
      assert(wp.keys().all(k => k in ("relative-to", "offset", "anchor")), message: "deixis: Unknown waypoint field.")
      let reference = wp.at("relative-to", default: "previous")
      assert(reference in ("mark", "body", "page", "previous"), message: "deixis: Unknown waypoint reference frame.")
      let bounds = if reference == "mark" { m-box } else if reference == "body" { b-box } else if reference == "page" { page-bounds } else { none }
      assert(reference != "page" or bounds != none, message: "deixis: A page waypoint needs page bounds.")
      let origin = if reference == "previous" { (current-x, current-y) }
        else if reference == "page" { (bounds.left, bounds.top) } else { (bounds.center-x, bounds.center-y) }
      if "anchor" in wp {
        assert(reference in ("mark", "body", "page"), message: "deixis: A previous-relative point cannot select a node anchor.")
        let anchor = wp.anchor
        let is-left = anchor in (left, top + left, horizon + left, bottom + left)
        let is-right = anchor in (right, top + right, horizon + right, bottom + right)
        let is-top = anchor in (top, top + left, top + center, top + right)
        let is-bottom = anchor in (bottom, bottom + left, bottom + center, bottom + right)
        assert(type(anchor) == alignment, message: "deixis: Waypoint anchor must be a Typst alignment.")
        origin = (if is-left { bounds.left } else if is-right { bounds.right } else { bounds.center-x },
          if is-top { bounds.top } else if is-bottom { bounds.bottom } else { bounds.center-y })
      }
      let offset = wp.at("offset", default: (0pt, 0pt))
      assert(type(offset) == array and offset.len() == 2, message: "deixis: A waypoint offset needs two coordinates.")
      let basis = if bounds == none { (b-box.center-x - m-box.center-x, b-box.center-y - m-box.center-y) }
        else { (bounds.right - bounds.left, bounds.bottom - bounds.top) }
      let delta(value, basis) = if type(value) == ratio { value * basis }
        else if type(value) == relative { deixis-utils.resolve-signed-len(value.length) + value.ratio * basis }
        else { deixis-utils.resolve-signed-len(value) }
      current-x = origin.at(0) + delta(offset.at(0), basis.at(0))
      current-y = origin.at(1) + delta(offset.at(1), basis.at(1))
      resolved.push((current-x, current-y))
      continue
    }
    let norm-wp = wp
    let anchor = get-anchor(wp)
    if anchor != none {
      norm-wp = (wp, wp) // Both X and Y evaluate to the same anchor object
    } else if type(wp) != array {
      norm-wp = (wp, 0pt)
    }

    let x-spec = if type(norm-wp) == array and norm-wp.len() > 0 { norm-wp.at(0) } else { 0pt }
    let y-spec = if type(norm-wp) == array and norm-wp.len() > 1 { norm-wp.at(1) } else { 0pt }

    // sanity check
    let valid-x = type(x-spec) in (length, ratio, relative) or get-anchor(x-spec) != none
    let valid-y = type(y-spec) in (length, ratio, relative) or get-anchor(y-spec) != none
    if not valid-x or not valid-y {
      panic(
        "deixis: Invalid waypoint coordinate. Must be a length, ratio, relative, link type, or an anchor string. Got: "
          + repr(norm-wp),
      )
    }

    let next-x = resolve-coord(x-spec, current-x, true)
    let next-y = resolve-coord(y-spec, current-y, false)

    resolved.push((next-x, next-y))
    current-x = next-x
    current-y = next-y
  }
  return resolved
}

#let _deixis-waypoint-route(
  S-x,
  S-y,
  E-x,
  E-y,
  waypoints: (),
  fixed-waypoints: (),
  link-type: "straight-line",
  link-stroke: luma(0),
  link-radius: 0pt,
  link-marks: "none",
  source-dir: "vertical",
  target-dir: "horizontal",
  source-normal: auto,
  target-normal: auto,
) = {
  let end-rel = (E-x - S-x, E-y - S-y)

  let clean-wps = ()
  let cur-pt = (0pt, 0pt)
  let clean-policy = _deixis-route-spec(link-type)
  for wp in waypoints {
    if _deixis-route-control(wp) {
      clean-policy = _deixis-route-spec(wp)
      clean-wps.push(clean-policy)
      continue
    }

    let dx = wp.at(0) - cur-pt.at(0)
    let dy = wp.at(1) - cur-pt.at(1)
    let dist-sq = (dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt)

    let tolerance = if wp in fixed-waypoints { 1e-10 } else { 0.01 }
    if dist-sq > tolerance or _deixis-route-name(clean-policy) == "b-spline" {
      clean-wps.push(wp)
      cur-pt = wp
    }
  }

  let path-start = (0pt, 0pt)
  let path-end = end-rel

  // chunking
  let raw-points = ()
  let raw-types = ()
  let raw-sections = ()
  let section = 0
  let cur-type = _deixis-route-spec(link-type)

  for wp in clean-wps {
    if _deixis-route-control(wp) {
      cur-type = _deixis-route-spec(wp)
      section += 1
    } else {
      raw-points.push(wp)
      raw-types.push(cur-type)
      raw-sections.push(section)
    }
  }
  // Drop only the adjacent terminal duplicate. An earlier visit to the same
  // position is meaningful; a route switch there must keep its boundary too.
  let terminal-duplicate = if (raw-points.len() == 0 or raw-types.last() != cur-type or
    (_deixis-route-name(cur-type) in ("b-spline", "hobby") and raw-sections.last() != section)) { false } else {
    let epsilon = if raw-points.last() in fixed-waypoints { 0.00001pt } else { 0.1pt }
    _deixis-distance(raw-points.last(), path-end) <= epsilon
  }
  if terminal-duplicate { raw-points.last() = path-end } else {
    raw-points.push(path-end)
    raw-types.push(cur-type)
    raw-sections.push(section)
  }

  let chunks = ()
  let chunk-start = path-start
  let current-chunk-wps = ()
  let current-chunk-type = raw-types.first()
  let current-section = raw-sections.first()

  for i in range(raw-points.len()) {
    let pt = raw-points.at(i)
    let typ = raw-types.at(i)

    if typ == current-chunk-type and (_deixis-route-name(typ) not in ("b-spline", "hobby") or raw-sections.at(i) == current-section) {
      current-chunk-wps.push(pt)
    } else {
      let chunk-end = current-chunk-wps.last()
      let inner-wps = current-chunk-wps.slice(0, -1)
      chunks.push((start: chunk-start, end: chunk-end, wps: inner-wps, type: current-chunk-type))
      chunk-start = chunk-end
      current-chunk-type = typ
      current-section = raw-sections.at(i)
      current-chunk-wps = (pt,)
    }
  }
  let chunk-end = current-chunk-wps.last()
  let inner-wps = current-chunk-wps.slice(0, -1)
  chunks.push((start: chunk-start, end: chunk-end, wps: inner-wps, type: current-chunk-type))

  // Empty declarations must not steal endpoint directions or manufacture a
  // normal-induced loop. Retain spatial gaps, returning paths and off-curve
  // control polygons; malformed B-spline hard waypoints still diagnose below.
  chunks = chunks.filter(chunk => {
    if chunk.end != chunk.start or chunk.wps.any(p => p != chunk.start) { return true }
    if _deixis-route-name(chunk.type) == "b-spline" {
      if chunk.wps.len() > 0 { return true }
      let controls = if type(chunk.type) == dictionary { chunk.type.controls } else { () }
      return controls.any(p => p != chunk.start)
    }
    false
  })

  let cmds = (_deixis-move((path-start)),)

  // render each chunk independently
  for (i, chunk) in chunks.enumerate() {
    let C-start = chunk.start
    let C-end = chunk.end
    let wps = chunk.wps
    let l-type = _deixis-route-name(chunk.type)
    if l-type in ("right-angle", "chamfer") {
      for normal in (if i == 0 { source-normal } else { auto }, if i == chunks.len() - 1 { target-normal } else { auto }) {
        assert(normal == auto or normal.first() == 0 or normal.last() == 0,
          message: "deixis: Orthogonal endpoint normals must be horizontal or vertical.")
      }
      let distance = calc.max(1pt, calc.min(8pt, _deixis-distance(C-start, C-end) / 4))
      let first = if wps.len() > 0 { wps.first() } else { C-end }
      let last = if wps.len() > 0 { wps.last() } else { C-start }
      if i == 0 and source-normal != auto and source-normal != (0, 0) {
        let delta = _deixis-sub(first, C-start)
        if delta.at(0) * source-normal.at(0) + delta.at(1) * source-normal.at(1) <= 0pt {
          wps = ((C-start.at(0) + source-normal.at(0) * distance, C-start.at(1) + source-normal.at(1) * distance),) + wps
        }
      }
      if i == chunks.len() - 1 and target-normal != auto and target-normal != (0, 0) {
        let delta = _deixis-sub(last, C-end)
        if delta.at(0) * target-normal.at(0) + delta.at(1) * target-normal.at(1) <= 0pt {
          wps += ((C-end.at(0) + target-normal.at(0) * distance, C-end.at(1) + target-normal.at(1) * distance),)
        }
      }
    }

    let c-s-dir = if i == 0 { source-dir } else { "none" }
    let c-t-dir = if i == chunks.len() - 1 { target-dir } else { "none" }

    let t-start = (0pt, 0pt)
    let t-end = (0pt, 0pt)

    if l-type in ("none", none) {
      t-start = if wps.len() > 0 { wps.first() } else { C-end }
      t-end = if wps.len() > 0 { wps.last() } else { C-start }
      cmds.push(_deixis-move(C-end))
    } else if l-type == "straight-line" {
      t-start = if wps.len() > 0 { wps.first() } else { C-end }
      t-end = if wps.len() > 0 { wps.last() } else { C-start }
      for wp in wps { cmds.push(_deixis-line(wp)) }
      cmds.push(_deixis-line(C-end))
    } else if l-type in ("right-angle", "chamfer") {
      let pts = (C-start,)
      let eff-s-dir = if c-s-dir == "none" { "vertical" } else { c-s-dir }
      let eff-t-dir = if c-t-dir == "none" { "horizontal" } else { c-t-dir }

      if wps.len() == 0 {
        let is-same-dir = (eff-s-dir == eff-t-dir)

        if not is-same-dir {
          if eff-s-dir == "vertical" {
            pts.push((C-start.at(0), C-end.at(1)))
            t-start = (C-start.at(0), C-end.at(1))
            t-end = if C-end.at(0) != C-start.at(0) { (C-start.at(0), C-end.at(1)) } else { C-start }
          } else {
            pts.push((C-end.at(0), C-start.at(1)))
            t-start = (C-end.at(0), C-start.at(1))
            t-end = if C-end.at(1) != C-start.at(1) { (C-end.at(0), C-start.at(1)) } else { C-start }
          }
        } else {
          if eff-s-dir == "vertical" {
            if C-end.at(0) == C-start.at(0) {
              t-start = C-end
              t-end = C-start
            } else {
              let mid-y = C-start.at(1) + (C-end.at(1) - C-start.at(1)) / 2.0
              pts.push((C-start.at(0), mid-y))
              pts.push((C-end.at(0), mid-y))
              t-start = (C-start.at(0), mid-y)
              t-end = (C-end.at(0), mid-y)
            }
          } else {
            if C-end.at(1) == C-start.at(1) {
              t-start = C-end
              t-end = C-start
            } else {
              let mid-x = C-start.at(0) + (C-end.at(0) - C-start.at(0)) / 2.0
              pts.push((mid-x, C-start.at(1)))
              pts.push((mid-x, C-end.at(1)))
              t-start = (mid-x, C-start.at(1))
              t-end = (mid-x, C-end.at(1))
            }
          }
        }
        pts.push(C-end)
      } else {
        let current-pt = C-start
        for wp in wps {
          if current-pt == C-start {
            if eff-s-dir == "vertical" {
              t-start = (C-start.at(0), wp.at(1))
              pts.push(t-start)
            } else {
              t-start = (wp.at(0), C-start.at(1))
              pts.push(t-start)
            }
          } else {
            pts.push((current-pt.at(0), wp.at(1)))
          }
          pts.push(wp)
          current-pt = wp
        }
        if eff-t-dir == "horizontal" {
          pts.push((current-pt.at(0), C-end.at(1)))
          t-end = if current-pt.at(0) != C-end.at(0) { (current-pt.at(0), C-end.at(1)) } else { current-pt }
        } else {
          pts.push((C-end.at(0), current-pt.at(1)))
          t-end = if current-pt.at(1) != C-end.at(1) { (C-end.at(0), current-pt.at(1)) } else { current-pt }
        }
        pts.push(C-end)
      }

      let c-rad = _deixis-path-radius(link-radius, link-stroke)

      let c-style = if l-type == "chamfer" { "chamfer" } else { "fillet" }
      let r-cmds = _deixis-orthogonal-cmds(pts, radius: c-rad, corner-style: c-style, fixed: fixed-waypoints)

      for c in r-cmds { cmds.push(c) }
    } else if l-type == "b-spline" {
      assert(wps.len() == 0,
        message: "deixis: A b-spline section has one endpoint and its own controls. Use segments with a route record for each exact waypoint.")
      cmds += _deixis-bspline-cmds(C-start, C-end,
        controls: if type(chunk.type) == dictionary { chunk.type.controls } else { () },
        source-dir: c-s-dir, target-dir: c-t-dir,
        source-normal: if i == 0 { source-normal } else { auto },
        target-normal: if i == chunks.len() - 1 { target-normal } else { auto })
    } else if l-type == "hobby" {
      let spec = if type(chunk.type) == dictionary { chunk.type } else { (:) }
      cmds += _deixis-hobby-cmds((C-start,) + wps + (C-end,),
        tension: spec.at("tension", default: 1), curl: spec.at("curl", default: (mark: 1, body: 1)),
        source-dir: c-s-dir, target-dir: c-t-dir,
        source-normal: if i == 0 { source-normal } else { auto },
        target-normal: if i == chunks.len() - 1 { target-normal } else { auto })
    } else if l-type in ("curve", "ccr", "ucr") {
      cmds += _deixis-curve-cmds((C-start,) + wps + (C-end,), kind: l-type,
        tension: if type(chunk.type) == dictionary { chunk.type.tension } else { 1 },
        source-dir: c-s-dir, target-dir: c-t-dir,
        source-normal: if i == 0 { source-normal } else { auto },
        target-normal: if i == chunks.len() - 1 { target-normal } else { auto })
    }

  }

  let segments = _deixis-path-segments(cmds)
  let starts-here = segments.len() > 0 and segments.first().start == path-start
  let ends-here = segments.len() > 0 and segments.last().end == path-end
  let points = (path-start, path-end)
  for s in segments {
    points += (s.start, s.end)
    if s.kind == "cubic" { points += (s.c1, s.c2) }
  }
  let bounds = _deixis-box-bounds(calc.min(..points.map(p => p.at(0))), calc.min(..points.map(p => p.at(1))),
    calc.max(..points.map(p => p.at(0))), calc.max(..points.map(p => p.at(1))))
  (
    bounds: bounds,
    origin: (S-x, S-y), start: path-start, end: path-end, segments: segments,
    start-tangent: if starts-here { _deixis-segment-tangent(segments.first()) } else { (0.0, 0.0) },
    end-tangent: if ends-here { _deixis-segment-tangent(segments.last(), end: true) } else { (0.0, 0.0) },
    has-start: starts-here, has-end: ends-here,
    gaps: _deixis-path-gaps(segments),
    length: segments.map(s => _deixis-segment-length(s)).fold(0pt, (a, b) => a + b),
  )
}

// Shared native painting. Absolute tips preserve adapter coordinates exactly;
// public painters use the same route in source-local coordinates.
#let _deixis-connector-elements(request, origin: (0pt, 0pt), tips: auto) = {
  let route = request.route
  let heads = request.heads
  let elements = ()
  if request.shaft.len() > 0 {
    elements.push(place(top + left, dx: origin.at(0), dy: origin.at(1),
      curve(stroke: request.stroke, .._deixis-native-path(request.shaft))))
  }
  // Recompute from the supplied shaft, so custom painters can replace/cut it.
  let gap-marks = request.at("gap-marks", default: none)
  if gap-marks != none {
    elements += _deixis-paint-gap-marks(_deixis-path-gaps(request.shaft), gap-marks, origin: origin)
  }
  let (start, end) = if tips == auto {
    (_deixis-add(origin, route.start), _deixis-add(origin, route.end))
  } else { tips }
  if heads.mark != none {
    elements.push(_deixis-paint-head(heads.mark, start, _deixis-scale(route.start-tangent, -1)))
  }
  if heads.body != none {
    elements.push(_deixis-paint-head(heads.body, end, route.end-tangent))
  }
  elements
}

/// Paints a connector renderer request with the native backend, in the request's
/// source-local frame. Paints the trimmed shaft, optional gap marks, then heads;
/// it does not route, measure, trim, cut, or register anything again.
/// Override request.stroke for a second shaft pass, or set heads to
/// (mark: none, body: none) when painting a halo without repeating heads.
/// Also set gap-marks to none for a shaft-only halo pass.
#let deixis-render-connector(
  /// Prepared painter request from deixis-prepare-connector or a connector render callback. Place numeric output at route.origin yourself.
  /// -> dictionary
  request,
) = _deixis-connector-elements(request).join()

#let _deixis-prepare-connector-request(route, link-stroke: luma(0), link-marks: "none",
  link-heads: auto, link-gap-marks: none, link-cuts: (), route-context: (:), endpoint-trim: (mark: 0pt, body: 0pt),
) = {
  let specs = _deixis-head-specs(link-heads, link-marks)
  let start-head = if route.has-start { _deixis-prepare-head(specs.mark, link-stroke, "mark") } else { none }
  let end-head = if route.has-end { _deixis-prepare-head(specs.body, link-stroke, "body") } else { none }
  let start-trim = calc.max(if start-head == none { 0pt } else { start-head.trim }, if route.has-start { endpoint-trim.mark } else { 0pt })
  let end-trim = calc.max(if end-head == none { 0pt } else { end-head.trim }, if route.has-end { endpoint-trim.body } else { 0pt })
  let segments = _deixis-trim-path(route.segments, start: start-trim, end: end-trim)
  let cuts = _deixis-prepare-cuts(_deixis-cut-specs(link-cuts) + route.at("scene-cuts", default: ()), route.length)
  let shaft = if cuts.len() == 0 { segments } else {
    // Head trimming is independent of cuts. Its actual removed prefix may stop
    // at a legacy none gap, so recover that prefix from the original geometry.
    let remaining = _deixis-trim-start(route.segments, start-trim)
    let offset = route.length - remaining.map(s => _deixis-segment-length(s)).fold(0pt, (a, b) => a + b)
    _deixis-cut-path(segments, cuts, offset: offset)
  }
  (route: route + (document: route-context), shaft: shaft, manual-shaft: shaft, uncut-shaft: segments, cuts: cuts, crossings: none,
    stroke: _deixis-resolve-stroke(link-stroke),
    gap-marks: _deixis-prepare-gap-marks(link-gap-marks, link-stroke), gaps: _deixis-path-gaps(shaft),
    heads: (mark: start-head, body: end-head), frame: "source-local-x-right-y-down")
}

#let _deixis-render-waypoint-path(
  S-x, S-y, E-x, E-y, waypoints: (), fixed-waypoints: (), link-type: "straight-line",
  link-stroke: luma(0), link-radius: 0pt, link-marks: "none", link-heads: auto, link-render: none, link-gap-marks: none, link-cuts: (), link-crossings: none, route-context: (:),
  source-dir: "vertical", target-dir: "horizontal", source-normal: auto, target-normal: auto,
  planned-route: none,
  continuation-mark: none, continuation-endpoint: "body",
) = {
  let route = if planned-route != none { planned-route } else { _deixis-waypoint-route(S-x, S-y, E-x, E-y, waypoints: waypoints,
    fixed-waypoints: fixed-waypoints,
    link-type: link-type, link-stroke: link-stroke, link-radius: link-radius,
    source-dir: source-dir, target-dir: target-dir, source-normal: source-normal, target-normal: target-normal) }
  let request = _deixis-prepare-connector-request(route, link-stroke: link-stroke,
    link-marks: link-marks, link-heads: link-heads, link-gap-marks: link-gap-marks,
    link-cuts: link-cuts, route-context: route-context,
    endpoint-trim: if continuation-mark == none { (mark: 0pt, body: 0pt) } else {
      (mark: if continuation-endpoint == "mark" { continuation-mark.trim } else { 0pt },
        body: if continuation-endpoint == "body" { continuation-mark.trim } else { 0pt })
    })
  let paint(request) = {
    let marker = if continuation-mark == none or not (if continuation-endpoint == "mark" { route.has-start } else { route.has-end }) { () }
      else { (_deixis-paint-continuation-mark(continuation-mark,
        if continuation-endpoint == "mark" { (S-x, S-y) } else { (E-x, E-y) }, document: route-context),) }
    if link-render != none {
      return (place(top + left, dx: S-x, dy: S-y, link-render(request)),) + marker
    }
    _deixis-connector-elements(request, origin: (S-x, S-y), tips: ((S-x, S-y), (E-x, E-y))) + marker
  }
  if link-crossings != none {
    let record = _deixis-crossing-record(request, link-crossings)
    // Upstream page/layer selection already removed hidden edges. Keep numeric
    // evidence independent of automatic plans and user painter execution.
    return ([#metadata(record)<deixis-crossing-route>],
      context paint(_deixis-apply-crossings(request, record)).join())
  }
  paint(request)
}

#let _deixis-draw-direct-link(
  S-x,
  S-y,
  E-x,
  E-y,
  waypoints: (),
  fixed-waypoints: (),
  link-type: "straight-line",
  link-stroke: luma(0),
  link-radius: 0pt,
  link-marks: "none",
  link-heads: auto,
  link-render: none,
  link-gap-marks: none,
  link-cuts: (),
  link-crossings: none,
  link-continuation: auto,
  planned-route: none,
  source-dir: "vertical",
  target-dir: "horizontal",
  source-normal: auto,
  target-normal: auto,
  is-incoming: false,
  is-outgoing: false,
  extra-data: (:),
) = {
  let actual-mark = if link-marks == "mark" { "start" } else if link-marks == "body" { "end" } else { link-marks }
  if is-incoming {
    if actual-mark == "both" { actual-mark = "end" } else if actual-mark == "start" { actual-mark = "none" }
  } else if is-outgoing {
    if actual-mark == "both" { actual-mark = "start" } else if actual-mark == "end" { actual-mark = "none" }
  }

  let heads = _deixis-head-specs(link-heads, actual-mark, incoming: is-incoming, outgoing: is-outgoing)
  let elements = ()

  if (is-incoming or is-outgoing) and (type(link-continuation) == function or link-render != none or type(link-type) == function
    or (type(link-continuation) == dictionary and link-continuation.link == "counterpart" and link-stroke != none)) {
    elements.push(_deixis-continuation-site(extra-data.at("edge-identity", default: none),
      extra-data.at("layer", default: none), extra-data.at("continuation", default: none)))
  }

  let c-content = if type(link-type) == function {
    let func-args = (
      S-x: S-x,
      S-y: S-y,
      E-x: E-x,
      E-y: E-y,
      waypoints: waypoints,
      fixed-waypoints: fixed-waypoints,
      stroke: link-stroke,
      radius: link-radius,
      mark: actual-mark,
      gap-marks: link-gap-marks,
      cuts: link-cuts,
      heads: heads,
      source-dir: source-dir,
      target-dir: target-dir,
      is-incoming: is-incoming,
      is-outgoing: is-outgoing,
    )
    for (k, v) in extra-data { func-args.insert(k, v) }
    (place(top + left, dx: S-x, dy: S-y, link-type(func-args)),)
  } else {
    _deixis-render-waypoint-path(
      S-x,
      S-y,
      E-x,
      E-y,
      waypoints: waypoints,
      fixed-waypoints: fixed-waypoints,
      link-type: link-type,
      link-stroke: link-stroke,
      link-radius: link-radius,
      link-marks: actual-mark,
      link-heads: heads,
      link-render: link-render,
      link-gap-marks: link-gap-marks,
      link-cuts: link-cuts,
      link-crossings: link-crossings,
      route-context: extra-data,
      source-dir: source-dir,
      target-dir: target-dir,
      source-normal: source-normal,
      target-normal: target-normal,
      planned-route: planned-route,
      continuation-mark: if is-incoming or is-outgoing { _deixis-prepare-continuation-mark(link-continuation, link-stroke) } else { none },
      continuation-endpoint: if is-incoming { "mark" } else { "body" },
    )
  }

  for el in c-content { elements.push(el) }

  // Page continuations are independent of heads and internal cut indicators.
  // Preserve the old dot by default, while allowing suppression or a painter
  // that can distinguish direction, page and peer. A disabled shaft has no
  // implicit decoration (and must never be passed to std.stroke).
  if (is-incoming or is-outgoing) and type(link-continuation) == function {
    let point = if is-outgoing { (E-x, E-y) } else { (S-x, S-y) }
    let request = extra-data.at("continuation", default: (:)) + (
      stroke: _deixis-resolve-stroke(link-stroke), frame: "continuation-local-x-right-y-down")
    elements.push(place(top + left, dx: point.first(), dy: point.last(), link-continuation(request)))
  } else if (is-incoming or is-outgoing) and link-continuation == auto and link-stroke != none {
    let c-obj = _std-stroke(link-stroke)
    let c-paint = if c-obj.paint == auto { black } else { c-obj.paint }
    let c-rad = if c-obj.thickness == auto { 1.5pt } else { 1.5 * c-obj.thickness }
    let spill-mark = circle(radius: c-rad, fill: c-paint, stroke: none)

    if is-outgoing {
      elements.push(place(top + left, dx: E-x - c-rad, dy: E-y - c-rad, spill-mark))
    } else if is-incoming {
      elements.push(place(top + left, dx: S-x - c-rad, dy: S-y - c-rad, spill-mark))
    }
  }

  return elements
}

// Routing consumes prepared endpoints/options, independently of body placement.
#let _deixis-route-connection(edge, current-page, prepare-only: false) = {
  let S-page = edge.source.page
  let E-page = edge.target.page
  let S-candidates = edge.source.ports
  let D-candidates = edge.target.ports
  let c-link = edge.options.route
  let c-link-stroke = edge.options.stroke
  let c-link-radius = edge.options.radius
  let c-link-marks = edge.options.marks
  let split-default = edge.policy.split-default
  let turn-x = edge.policy.turn-x
  let synthetic-waypoints = edge.policy.synthetic-waypoints
  let is-margin = edge.adapter == "margin"
  let extra-data = edge.routing-context
  let paths = ()
  if c-link in (none, false, "none") { return paths }
  let is-cross-page = (S-page != E-page)
  let is-outgoing = (is-cross-page and current-page == S-page)
  let is-incoming = (is-cross-page and current-page == E-page)

  let m-box = edge.source.bounds
  let b-box = edge.target.bounds
  let c-ports = edge.options.ports
  if type(c-ports) == dictionary {
    if c-ports.at("mark", default: auto) != auto {
      S-candidates = (_deixis-select-port(S-candidates, c-ports.mark, m-box),)
    }
    if c-ports.at("body", default: auto) != auto {
      D-candidates = (_deixis-select-port(D-candidates, c-ports.body, b-box),)
    }
  }
  let m-cx = S-candidates.first().x
  let m-y = S-candidates.first().y
  let D-top-x = D-candidates.first().x
  let D-top-y = D-candidates.first().y

  let page-size = deixis-utils.get-page-size(current-page)
  // Geometry belongs to the physical page, not a connector's captured font.
  // Font-relative native sizes/margins must use the accepted page snapshot.
  let page-frames = if is-cross-page or page-size.width.em != 0 or page-size.height.em != 0 {
    query(<deixis-page-frame>)
  } else { () }
  let current-frame = page-frames.find(f => f.value.page == current-page)
  if current-frame != none {
    page-size = (width: current-frame.value.width, height: current-frame.value.height)
  } else {
    page-size = (width: deixis-utils.resolve-signed-len(page-size.width), height: deixis-utils.resolve-signed-len(page-size.height))
  }
  let physical-page = _deixis-box-bounds(0pt, 0pt, page-size.width, page-size.height)
  let raw-waypoints = edge.options.via
  if raw-waypoints == auto {
    raw-waypoints = if synthetic-waypoints != auto { synthetic-waypoints } else { none }
  }
  let raw-wps = if type(raw-waypoints) == array {
    raw-waypoints
  } else if raw-waypoints != none {
    (raw-waypoints,)
  } else {
    ()
  }

  let split-item = raw-wps.find(x => (
    x == deixis-waypoint-split or (type(x) == array and x.len() > 0 and x.at(0) == deixis-waypoint-split)
  ))

  let explicit-config = if type(split-item) == array and split-item.len() > 1 { split-item.at(1) } else { auto }
  let split-idx = raw-wps.position(x => x == split-item)

  // spill mark coordinates
  let current-x = if split-default == "source" { m-box.center-x } else {
    if turn-x != auto { turn-x } else { b-box.center-x }
  }

  if split-idx != none and split-idx > 0 {
    let pre-wps = raw-wps.slice(0, split-idx)
    let dry-run = _deixis-resolve-waypoints(pre-wps, m-box.center-x, m-box.center-y, m-box, b-box, page-bounds: physical-page)
    let valid-wps = dry-run.filter(x => type(x) == array)
    if valid-wps.len() > 0 { current-x = valid-wps.last().at(0) }
  }

  let split-x = current-x

  if explicit-config != auto {
    if explicit-config == "average" {
      split-x = (m-box.center-x + if turn-x != auto { turn-x } else { b-box.center-x }) / 2.0
    } else if (
      type(explicit-config) == str
        and (
          "mark" in explicit-config or "body" in explicit-config or explicit-config in ("source", "target")
        )
    ) {
      let is-m = explicit-config.starts-with("mark") or explicit-config == "source"
      let box = if is-m { m-box } else { b-box }

      split-x = if explicit-config == "target" and turn-x != auto { turn-x } else { box.center-x }
      if "left" in explicit-config { split-x = box.left } else if "right" in explicit-config { split-x = box.right }
    } else {
      split-x = current-x + deixis-utils.resolve-signed-len(explicit-config)
    }
  } else {
    if split-idx != none and split-idx > 0 {
      let pre-wps = raw-wps.slice(0, split-idx)
      let dry-run = _deixis-resolve-waypoints(pre-wps, m-box.center-x, m-box.center-y, m-box, b-box, page-bounds: physical-page)
      let valid-wps = dry-run.filter(x => type(x) == array)

      if valid-wps.len() > 0 {
        split-x = valid-wps.last().at(0)
      } else {
        split-x = if split-default == "source" { m-box.center-x } else {
          if turn-x != auto { turn-x } else { b-box.center-x }
        }
      }
    } else {
      split-x = if split-default == "source" { m-box.center-x } else {
        if turn-x != auto { turn-x } else { b-box.center-x }
      }
    }
  }

  let goes-forward = S-page < E-page
  let spill-region = none
  if is-cross-page and explicit-config == auto {
    let frame = if current-frame == none {
      (page: current-page, width: page-size.width, height: page-size.height,
        margins: deixis-utils.get-page-margins(current-page))
    } else { current-frame.value }
    spill-region = _deixis-spill-region(edge.options.at("spill", default: auto), frame,
      margin: edge.target.at("margin-context", default: none), page-frames: page-frames)
    // Each physical page owns its interval. Incoming generic edges project the
    // local destination; margin adapters retain their selected lane preference.
    if is-incoming and not is-margin { split-x = b-box.center-x }
    split-x = calc.min(spill-region.right, calc.max(spill-region.left, split-x))
  }
  let p-margins = if current-frame == none { deixis-utils.get-page-margins(current-page) } else { current-frame.value.margins }
  let page-h = page-size.height
  let top-bound = deixis-utils.resolve-len(p-margins.top)
  let bottom-bound = deixis-utils.resolve-len(page-h) - deixis-utils.resolve-len(p-margins.bottom)

  if spill-region != none and spill-region.kind == "margin" {
    top-bound = spill-region.top
    bottom-bound = spill-region.bottom
  }
  let virtual-y-in = if goes-forward { top-bound } else { bottom-bound }
  let virtual-y-out = if goes-forward { bottom-bound } else { top-bound }
  if goes-forward {
    virtual-y-out = calc.max(virtual-y-out, m-box.bottom)
    virtual-y-in = calc.min(virtual-y-in, b-box.top)
  } else {
    virtual-y-out = calc.min(virtual-y-out, m-box.top)
    virtual-y-in = calc.max(virtual-y-in, b-box.bottom)
  }

  let virtual-id-in = if goes-forward { "top" } else { "bottom" }
  let virtual-id-out = if goes-forward { "bottom" } else { "top" }

  if is-margin {
    virtual-y-in = calc.min(top-bound, b-box.top)
    virtual-y-out = calc.max(bottom-bound, m-box.bottom)
    virtual-id-in = "top"
    virtual-id-out = "bottom"
  }

  let active-raw-wps = raw-wps
  let wps-start-x = m-cx
  let wps-start-y = m-y

  if split-idx != none {
    if is-outgoing { active-raw-wps = raw-wps.slice(0, split-idx) } else if is-incoming {
      active-raw-wps = raw-wps.slice(split-idx + 1)
      wps-start-x = split-x
      wps-start-y = virtual-y-in
    } else { active-raw-wps = raw-wps.slice(0, split-idx) + raw-wps.slice(split-idx + 1) }
  } else if is-outgoing or is-incoming {
    if is-outgoing { active-raw-wps = raw-wps } else if is-incoming {
      active-raw-wps = ()
      wps-start-x = split-x
      wps-start-y = virtual-y-in
    }
  }

  let resolved-wps = _deixis-resolve-waypoints(active-raw-wps, wps-start-x, wps-start-y, m-box, b-box, page-bounds: physical-page)

  let safe-wps = resolved-wps.filter(x => _deixis-route-control(x) or (type(x) == array and x.len() >= 2))
  let coord-wps = safe-wps.filter(x => type(x) == array)

  let S-anchor-x = S-candidates.first().x
  let S-anchor-y = S-candidates.first().y
  let E-anchor-x = D-top-x
  let E-anchor-y = D-top-y
  let source-dir = "vertical"
  let target-dir = "vertical"
  let selected-source = none
  let selected-target = none

  if is-outgoing {
    let virtual-D-ports = ((x: split-x, y: virtual-y-out, dir: "vertical", id: virtual-id-out),)
    if coord-wps.len() > 0 {
      virtual-D-ports = ((x: coord-wps.first().at(0), y: coord-wps.first().at(1), dir: "none", id: "none"),)
    }

    let (best-S, best-D) = _deixis-resolve-best-ports(S-candidates, virtual-D-ports)
    S-anchor-x = best-S.x
    S-anchor-y = best-S.y
    source-dir = best-S.dir
    selected-source = best-S
    selected-target = (id: virtual-id-out, normal: if goes-forward { (0, -1) } else { (0, 1) })
    E-anchor-x = split-x
    E-anchor-y = virtual-y-out
    target-dir = "vertical"
  } else if is-incoming {
    let virtual-S-ports = ((x: split-x, y: virtual-y-in, dir: "vertical", id: virtual-id-in),)
    if coord-wps.len() > 0 {
      virtual-S-ports = ((x: coord-wps.last().at(0), y: coord-wps.last().at(1), dir: "none", id: "none"),)
    }

    let (best-S, best-D) = _deixis-resolve-best-ports(virtual-S-ports, D-candidates)
    S-anchor-x = split-x
    S-anchor-y = virtual-y-in
    source-dir = "vertical"
    E-anchor-x = best-D.x
    E-anchor-y = best-D.y
    target-dir = best-D.dir
    selected-source = (id: virtual-id-in, normal: if goes-forward { (0, 1) } else { (0, -1) })
    selected-target = best-D
  } else {
    let virtual-S-ports = S-candidates
    let virtual-D-ports = D-candidates

    if coord-wps.len() > 0 {
      let first-wp = (x: coord-wps.first().at(0), y: coord-wps.first().at(1))
      virtual-D-ports = ((x: first-wp.x, y: first-wp.y, dir: "none", id: "none"),)
    }

    let (best-S, temp-D) = _deixis-resolve-best-ports(S-candidates, virtual-D-ports)

    if coord-wps.len() > 0 {
      let last-wp = (x: coord-wps.last().at(0), y: coord-wps.last().at(1))
      virtual-S-ports = ((x: last-wp.x, y: last-wp.y, dir: "none", id: "none"),)
    }

    let (temp-S, best-D) = _deixis-resolve-best-ports(virtual-S-ports, D-candidates)

    S-anchor-x = best-S.x
    S-anchor-y = best-S.y
    source-dir = best-S.dir
    E-anchor-x = best-D.x
    E-anchor-y = best-D.y
    target-dir = best-D.dir
    selected-source = best-S
    selected-target = best-D
  }

  let local-route(value) = if type(value) == dictionary and value.kind == "b-spline" {
    value + (controls: value.controls.map(p => (p.first() - S-anchor-x, p.last() - S-anchor-y)))
  } else { value }
  let final-wps = safe-wps.map(wp => if _deixis-route-control(wp) { local-route(wp) } else { (wp.at(0) - S-anchor-x, wp.at(1) - S-anchor-y) })
  // Initial controls belong to the source half, like initial waypoints. A route
  // record after split supplies independent controls for the destination half.
  if is-incoming and _deixis-route-name(c-link) == "b-spline" { c-link = "b-spline" }
  if type(c-link) == dictionary and c-link.kind == "b-spline" {
    c-link = local-route(_deixis-resolve-waypoints((c-link,), m-cx, m-y, m-box, b-box, page-bounds: physical-page).first())
  }
  let fixed-wps = active-raw-wps.filter(wp => type(wp) == dictionary and "resolved-pin" in wp)
    .map(wp => (wp.resolved-pin.first() - S-anchor-x, wp.resolved-pin.last() - S-anchor-y))

  let port-normal(p) = p.at("normal", default: (top: (0, -1), bottom: (0, 1), left: (-1, 0), right: (1, 0)).at(p.id, default: (0, 0)))
  let call-extra = (dx: E-anchor-x - S-anchor-x, dy: E-anchor-y - S-anchor-y,
    edge-identity: edge.at("identity", default: none),
    page: current-page, source-page: S-page, target-page: E-page, layer: edge.layer,
    z-index: edge.options.at("z-index", default: 0),
    is-incoming: is-incoming, is-outgoing: is-outgoing,
    nodes: (mark: (bounds: m-box, page: S-page, frame: "page"), body: (bounds: b-box, page: E-page, frame: "page")),
    endpoints: (mark: (point: (S-anchor-x, S-anchor-y), axis: source-dir, normal: port-normal(selected-source),
      role: if is-incoming { "continuation" } else { "mark" }),
      body: (point: (E-anchor-x, E-anchor-y), axis: target-dir, normal: port-normal(selected-target),
        role: if is-outgoing { "continuation" } else { "body" })))
  let fragment = _deixis-page-fragment(edge, current-page, call-extra.endpoints.mark, call-extra.endpoints.body,
    incoming: is-incoming, outgoing: is-outgoing)
  let logical = fragment.logical
  call-extra.fragment = fragment
  call-extra.source-page = if logical.source == none { none } else { logical.source.page }
  call-extra.target-page = if logical.target == none { none } else { logical.target.page }
  let node-info(n) = if n == none { none } else { (bounds: n.bounds, page: n.page, frame: "page") }
  call-extra.nodes = (mark: node-info(logical.source), body: node-info(logical.target))
  call-extra.continuation = if not is-cross-page { none } else {
    let peer = _deixis-continuation-peer(if is-outgoing { logical.target } else { logical.source })
    (direction: if is-outgoing { "outgoing" } else { "incoming" }, page: current-page,
      relay: edge.source.virtual or edge.target.virtual,
      peer-page: if peer == none { none } else { peer.page }, peer: peer, status: fragment.status,
      source-page: call-extra.source-page, target-page: call-extra.target-page,
      point: if is-outgoing { (E-anchor-x, E-anchor-y) } else { (S-anchor-x, S-anchor-y) },
      allocation: (automatic: explicit-config == auto, region: spill-region,
        preferred: if is-outgoing { (E-anchor-x, E-anchor-y) } else { (S-anchor-x, S-anchor-y) }, shifted: false),
      normal: if (if is-outgoing { virtual-id-out } else { virtual-id-in }) == "bottom" { (0, 1) } else { (0, -1) })
  }
  for (k, v) in extra-data { call-extra.insert(k, v) }

  let scene-ports(choices, virtual) = if virtual { () } else {
    choices.map(p => {
      let sliding = p.at("scene-range", default: none)
      for (key, axis) in (("x-range", 0), ("y-range", 1)) {
        let span = p.at(key, default: none)
        if span != none and span.first() != span.last() { sliding = (axis: axis, min: span.first(), max: span.last()) }
      }
      (point: (p.x, p.y), normal: port-normal(p), sliding: sliding)
    })
  }
  let scene-choices = (source: scene-ports(S-candidates, is-incoming),
    target: scene-ports(D-candidates, is-outgoing))
  let scene-boundary = if is-cross-page and explicit-config == auto {
    (left: spill-region.left.pt(), right: spill-region.right.pt(),
      top: 0, bottom: page-size.height.pt(), preferred: split-x.pt(),
      page-bounds: (left: 0, right: page-size.width.pt(), top: 0, bottom: page-size.height.pt()))
  } else { none }
  let planned-route = none
  let scene-option = edge.options.at("scene", default: none)
  if scene-option != none {
    let scene = _deixis-connector-scene(scene-option, call-extra)
    let radius = _deixis-path-radius(c-link-radius, c-link-stroke)
    planned-route = _deixis-connector-scene-plan(scene,
      call-extra.endpoints.mark, call-extra.endpoints.body,
      if edge.options.via == auto { () } else { final-wps }, call-extra, _deixis-route-name(c-link), radius,
      boundary: scene-boundary, ports: scene-choices)
    if planned-route != none and planned-route.status != "ok" {
      return ([#metadata(planned-route)<deixis-scene-route>],)
    }
    if planned-route == none {
      planned-route = _deixis-waypoint-route(S-anchor-x, S-anchor-y, E-anchor-x, E-anchor-y,
        waypoints: final-wps, fixed-waypoints: fixed-wps, link-type: c-link,
        link-stroke: c-link-stroke, link-radius: c-link-radius,
        source-dir: source-dir, target-dir: target-dir,
        source-normal: port-normal(selected-source), target-normal: port-normal(selected-target))
    }
    // Port fallback or an incoming boundary can move the source-local origin.
    // Rebase already-resolved hard visits; do not resolve relative vias again.
    if is-cross-page or "selection" in planned-route {
      let old-source = (S-anchor-x, S-anchor-y)
      S-anchor-x = planned-route.origin.first()
      S-anchor-y = planned-route.origin.last()
      E-anchor-x = S-anchor-x + planned-route.end.first()
      E-anchor-y = S-anchor-y + planned-route.end.last()
      call-extra.dx = E-anchor-x - S-anchor-x
      call-extra.dy = E-anchor-y - S-anchor-y
      call-extra.endpoints.mark.point = (S-anchor-x, S-anchor-y)
      call-extra.endpoints.body.point = (E-anchor-x, E-anchor-y)
      if "selection" in planned-route {
        let selected = planned-route.selection
        // Keep coordinates reconstructed from the actual local geometry above;
        // adding the original absolute port back can differ by a floating ULP.
        call-extra.endpoints.mark += (normal: selected.source.normal, axis: selected.source.axis)
        call-extra.endpoints.body += (normal: selected.target.normal, axis: selected.target.axis)
        source-dir = selected.source.axis
        target-dir = selected.target.axis
        selected-source = (id: "none", normal: selected.source.normal)
        selected-target = (id: "none", normal: selected.target.normal)
        let _ = planned-route.remove("selection")
      }
      let rebase(p) = (p.first() + old-source.first() - S-anchor-x, p.last() + old-source.last() - S-anchor-y)
      if old-source != (S-anchor-x, S-anchor-y) {
        final-wps = final-wps.map(wp => if type(wp) == array { rebase(wp) } else { wp })
        fixed-wps = fixed-wps.map(rebase)
      }
      call-extra.fragment.source = call-extra.endpoints.mark
      call-extra.fragment.target = call-extra.endpoints.body
      if is-cross-page {
        call-extra.continuation.point = if is-outgoing { (E-anchor-x, E-anchor-y) } else { (S-anchor-x, S-anchor-y) }
        let search = planned-route.at("search", default: none)
        call-extra.continuation.allocation.shifted = search != none and search.at("preference", default: 0pt) > 0pt
      }
    }
    planned-route = _deixis-connector-scene-events(planned-route, scene, current-page)
    paths.push([#metadata((status: "ok", page: current-page))<deixis-scene-route>])
  }

  // Remote accepted geometry is a painting-only dependency. Scene callbacks
  // receive preferred fragments above and cannot use it to steer routing.
  if call-extra.continuation != none {
    let c = call-extra.continuation
    call-extra.continuation += (counterpart: _deixis-counterpart-lookup(edge.at("identity", default: none),
      edge.layer, c.direction, c.peer-page))
  }
  let draw = arguments(
    S-anchor-x,
    S-anchor-y,
    E-anchor-x,
    E-anchor-y,
    waypoints: final-wps,
    fixed-waypoints: fixed-wps,
    link-type: c-link,
    link-stroke: c-link-stroke,
    link-radius: c-link-radius,
    link-marks: c-link-marks,
    link-heads: edge.options.heads,
    link-render: edge.options.render,
    link-gap-marks: edge.options.at("gap-marks", default: none),
    link-cuts: edge.options.at("cuts", default: ()),
    link-crossings: edge.options.at("crossings", default: none),
    link-continuation: edge.options.at("continuation", default: auto),
    source-dir: source-dir,
    target-dir: target-dir,
    source-normal: port-normal(selected-source),
    target-normal: port-normal(selected-target),
    is-incoming: is-incoming,
    is-outgoing: is-outgoing,
    extra-data: call-extra,
  )

  // Collection publishes only frozen page geometry and painter arguments.
  // Live heads, custom painters, cuts and continuation output run after the
  // whole page/layer group has accepted its plan.
  if prepare-only {
    assert(_deixis-route-name(c-link) == "right-angle"
      and _deixis-path-radius(c-link-radius, c-link-stroke) == 0pt
      and final-wps.all(wp => type(wp) == array),
      message: "deixis: Collected routing requires sharp orthogonal routes, radius: 0pt and point-only waypoints.")
    return (from: call-extra.endpoints.mark, to: call-extra.endpoints.body,
      via: final-wps.map(p => (p.first() + S-anchor-x, p.last() + S-anchor-y)),
      document: call-extra, draw: draw, choices: scene-choices, boundary: scene-boundary)
  }

  let direct-links = _deixis-draw-direct-link(..draw, planned-route: planned-route)

  for el in direct-links { paths.push(el) }
  return paths
}

#let _deixis-paint-route-fragment(fragment, route, crossing-order: auto) = {
  let options = fragment.draw.named()
  let coordinates = fragment.draw.pos()
  if "selection" in route {
    let original = fragment.document.endpoints.mark.point
    let start = route.origin
    let end = route.origin.zip(route.end).map(((a, b)) => a + b)
    let document = options.extra-data
    let source = document.endpoints.mark + route.selection.source + (point: start)
    let target = document.endpoints.body + route.selection.target + (point: end)
    document.endpoints = (mark: source, body: target)
    document.fragment.source = source
    document.fragment.target = target
    document.dx = end.first() - start.first()
    document.dy = end.last() - start.last()
    if document.continuation != none {
      let point = if document.is-incoming { start } else { end }
      document.continuation.point = point
      document.continuation.allocation.shifted = route.search.at("preference", default: 0pt) > 0pt
    }
    let rebase(p) = p.zip(original).zip(start).map((((v, old), new)) => v + old - new)
    options.waypoints = options.waypoints.map(rebase)
    options.fixed-waypoints = options.fixed-waypoints.map(rebase)
    options.source-dir = source.axis
    options.target-dir = target.axis
    options.source-normal = source.normal
    options.target-normal = target.normal
    options.extra-data = document
    coordinates = (start.first(), start.last(), end.first(), end.last())
  }
  if crossing-order != auto {
    options.extra-data += (crossing-order: crossing-order)
  }
  _deixis-draw-direct-link(..coordinates, ..options, planned-route: route).join()
}
