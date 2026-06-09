#import "utils.typ" as deixis-utils

#let deixis-waypoint-split = "split"
#let deixis-link-types = ("none", "straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr")

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
  let box-y = mark-y - (t-val * 0.8)
  let box-x = mark-x - 1.5pt
  let actual-box-h = t-val * 0.85

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

// Draw an arrowhead.
#let _deixis-draw-arrowhead(p1, p2, stroke: luma(0)) = {
  let dx = (deixis-utils.resolve-signed-len(p2.at(0)) - deixis-utils.resolve-signed-len(p1.at(0))) / 1pt
  let dy = (deixis-utils.resolve-signed-len(p2.at(1)) - deixis-utils.resolve-signed-len(p1.at(1))) / 1pt

  let angle = calc.atan2(dx, dy)

  let s-obj = std.stroke(stroke)
  let abs-thick = if s-obj.thickness == auto { 1.0 } else { deixis-utils.resolve-len(s-obj.thickness) / 1pt }

  let arrow-length = calc.max(4.0, abs-thick * 4.0)
  let arrow-half-width = calc.max(2.5, abs-thick * 2.5)
  let inset-depth = arrow-length * 0.4

  // push the tip forward mathematically to envelop the flat line cap
  let t-half = abs-thick / 2.0
  let tip-forward = ((t-half * arrow-length) / (arrow-half-width - t-half)) + 0.2

  let tip = (
    p2.at(0) + tip-forward * calc.cos(angle) * 1pt,
    p2.at(1) + tip-forward * calc.sin(angle) * 1pt,
  )

  let p-back = (
    p2.at(0) - arrow-length * calc.cos(angle) * 1pt,
    p2.at(1) - arrow-length * calc.sin(angle) * 1pt,
  )

  let p-inset = (
    p2.at(0) - (arrow-length - inset-depth) * calc.cos(angle) * 1pt,
    p2.at(1) - (arrow-length - inset-depth) * calc.sin(angle) * 1pt,
  )

  let p-left = (
    p-back.at(0) - arrow-half-width * calc.sin(angle) * 1pt,
    p-back.at(1) + arrow-half-width * calc.cos(angle) * 1pt,
  )

  let p-right = (
    p-back.at(0) + arrow-half-width * calc.sin(angle) * 1pt,
    p-back.at(1) - arrow-half-width * calc.cos(angle) * 1pt,
  )

  place(top + left, curve(
    fill: s-obj.paint,
    stroke: none,
    curve.move(tip),
    curve.line(p-left),
    curve.line(p-inset),
    curve.line(p-right),
    curve.close(),
  ))
}

// Corners for right-angle and chamfer links.
#let _deixis-orthogonal-cmds(vertices, radius: 0pt, corner-style: "fillet") = {
  let cmds = ()
  if vertices.len() < 2 { return cmds }

  let abs-radius = deixis-utils.resolve-len(if radius == auto { 0pt } else { radius })

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
    let r = calc.min(abs-radius, len-in / 2.0, len-out / 2.0)

    if r <= 0.05pt or len-in == 0pt or len-out == 0pt {
      cmds.push(curve.line(p-curr))
    } else {
      let p-in = (
        p-curr.at(0) + (dx-in / len-in) * r,
        p-curr.at(1) + (dy-in / len-in) * r,
      )
      let p-out = (
        p-curr.at(0) + (dx-out / len-out) * r,
        p-curr.at(1) + (dy-out / len-out) * r,
      )

      cmds.push(curve.line(p-in))

      if corner-style == "chamfer" {
        cmds.push(curve.line(p-out))
      } else {
        cmds.push(curve.quad(p-curr, p-out))
      }
    }
  }
  cmds.push(curve.line(clean-pts.last()))
  return cmds
}

// Resolves the optimal geometric connection between a set of source and destination ports based on Manhattan or Euclidean distance.
#let _deixis-resolve-best-ports(source-ports, dest-ports, metric: "euclidean") = {
  let best-S = none
  let best-D = none
  let min-cost = 0pt

  for S in source-ports {
    for D in dest-ports {
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
#let _deixis-resolve-waypoints(waypoints, start-x, start-y, m-box, b-box) = {
  if waypoints in (none, auto) { return () }
  let wps = if type(waypoints) == array { waypoints } else { (waypoints,) }

  let resolved = ()

  let current-x = start-x
  let current-y = start-y

  let get-anchor(spec) = {
    if type(spec) != str { return none }

    let is-m = spec.starts-with("mark") or spec in ("source", "start")
    let is-b = spec.starts-with("body") or spec in ("target", "end")
    if not is-m and not is-b { return none }

    let box = if is-m { m-box } else { b-box }
    let res-x = box.center-x
    let res-y = box.center-y

    if "left" in spec { res-x = box.left } else if "right" in spec { res-x = box.right }

    if "top" in spec { res-y = box.top } else if "bottom" in spec { res-y = box.bottom }

    return (res-x, res-y)
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
      let r-val = float(repr(spec).replace("%", "")) / 100.0
      val = (e - s) * r-val
    } else if type(spec) == relative {
      let r-val = float(repr(spec.ratio).replace("%", "")) / 100.0
      val = deixis-utils.resolve-signed-len(spec.length) + (e - s) * r-val
    } else {
      val = deixis-utils.resolve-signed-len(spec)
    }
    return cur + val
  }

  for wp in wps {
    if (
      wp == deixis-waypoint-split
        or wp in deixis-link-types
        or (type(wp) == array and wp.len() > 0 and wp.at(0) == deixis-waypoint-split)
    ) {
      resolved.push(wp)
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

#let _deixis-render-waypoint-path(
  S-x,
  S-y,
  E-x,
  E-y,
  waypoints: (),
  link-type: "straight-line",
  link-stroke: luma(0),
  link-radius: 0pt,
  link-marks: "none",
  source-dir: "vertical",
  target-dir: "horizontal",
) = {
  let end-rel = (E-x - S-x, E-y - S-y)

  let clean-wps = ()
  let cur-pt = (0pt, 0pt)
  for wp in waypoints {
    if type(wp) == str {
      clean-wps.push(wp)
      continue
    }

    let dx = wp.at(0) - cur-pt.at(0)
    let dy = wp.at(1) - cur-pt.at(1)
    let dist-sq = (dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt)

    let edx = wp.at(0) - end-rel.at(0)
    let edy = wp.at(1) - end-rel.at(1)
    let edist-sq = (edx / 1pt) * (edx / 1pt) + (edy / 1pt) * (edy / 1pt)

    if dist-sq > 0.01 and edist-sq > 0.01 {
      clean-wps.push(wp)
      cur-pt = wp
    }
  }

  // chunking
  let raw-points = ()
  let raw-types = ()
  let cur-type = link-type

  for wp in clean-wps {
    if type(wp) == str {
      cur-type = wp
    } else {
      raw-points.push(wp)
      raw-types.push(cur-type)
    }
  }
  raw-points.push(end-rel)
  raw-types.push(cur-type)

  let chunks = ()
  let chunk-start = (0pt, 0pt)
  let current-chunk-wps = ()
  let current-chunk-type = raw-types.first()

  for i in range(raw-points.len()) {
    let pt = raw-points.at(i)
    let typ = raw-types.at(i)

    if typ == current-chunk-type {
      current-chunk-wps.push(pt)
    } else {
      let chunk-end = current-chunk-wps.last()
      let inner-wps = current-chunk-wps.slice(0, -1)
      chunks.push((start: chunk-start, end: chunk-end, wps: inner-wps, type: current-chunk-type))
      chunk-start = chunk-end
      current-chunk-type = typ
      current-chunk-wps = (pt,)
    }
  }
  let chunk-end = current-chunk-wps.last()
  let inner-wps = current-chunk-wps.slice(0, -1)
  chunks.push((start: chunk-start, end: chunk-end, wps: inner-wps, type: current-chunk-type))

  let cmds = (curve.move((0pt, 0pt)),)
  let global-t-start = (0pt, 0pt)
  let global-t-end = (0pt, 0pt)

  // render each chunk independently
  for (i, chunk) in chunks.enumerate() {
    let C-start = chunk.start
    let C-end = chunk.end
    let wps = chunk.wps
    let l-type = chunk.type

    let c-s-dir = if i == 0 { source-dir } else { "none" }
    let c-t-dir = if i == chunks.len() - 1 { target-dir } else { "none" }

    let t-start = (0pt, 0pt)
    let t-end = (0pt, 0pt)

    if l-type in ("none", none) {
      t-start = if wps.len() > 0 { wps.first() } else { C-end }
      t-end = if wps.len() > 0 { wps.last() } else { C-start }
      cmds.push(curve.move(C-end))
    } else if l-type == "straight-line" {
      t-start = if wps.len() > 0 { wps.first() } else { C-end }
      t-end = if wps.len() > 0 { wps.last() } else { C-start }
      for wp in wps { cmds.push(curve.line(wp)) }
      cmds.push(curve.line(C-end))
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

      let stroke-obj = std.stroke(link-stroke)
      let thick = deixis-utils.resolve-len(if stroke-obj.thickness == auto { 1pt } else { stroke-obj.thickness })
      let c-rad = if link-radius == auto { calc.max(3pt, thick * 4) } else { deixis-utils.resolve-len(link-radius) }

      let c-style = if l-type == "chamfer" { "chamfer" } else { "fillet" }
      let r-cmds = _deixis-orthogonal-cmds(pts, radius: c-rad, corner-style: c-style)

      for c in r-cmds { cmds.push(c) }
    } else if l-type in ("curve", "ccr", "ucr") {
      let dx = C-end.at(0) - C-start.at(0)
      let dy = C-end.at(1) - C-start.at(1)
      let eff-s-dir = if c-s-dir == "none" { "vertical" } else { c-s-dir }
      let eff-t-dir = if c-t-dir == "none" { "horizontal" } else { c-t-dir }

      if wps.len() == 0 {
        t-start = if eff-s-dir == "horizontal" { (C-start.at(0) + dx * 0.5, C-start.at(1)) } else {
          (C-start.at(0), C-start.at(1) + dy * 0.5)
        }
        t-end = if eff-t-dir == "horizontal" { (C-start.at(0) + dx * 0.5, C-end.at(1)) } else {
          (C-end.at(0), C-start.at(1) + dy * 0.5)
        }
        cmds.push(curve.cubic(t-start, t-end, C-end))
      } else {
        let pts = (C-start,) + wps + (C-end,)

        let add(p1, p2) = (p1.at(0) + p2.at(0), p1.at(1) + p2.at(1))
        let sub(p1, p2) = (p1.at(0) - p2.at(0), p1.at(1) - p2.at(1))
        let scale(p, s) = (p.at(0) * s, p.at(1) * s)

        let get-pt(idx) = {
          if idx < 0 {
            let p0 = pts.at(0)
            let p1 = pts.at(1)
            (p0.at(0) * 2 - p1.at(0), p0.at(1) * 2 - p1.at(1))
          } else if idx >= pts.len() {
            let pL = pts.last()
            let pP = pts.at(pts.len() - 2)
            (pL.at(0) * 2 - pP.at(0), pL.at(1) * 2 - pP.at(1))
          } else { pts.at(idx) }
        }

        for j in range(pts.len() - 1) {
          let p-prev = get-pt(j - 1)
          let p-curr = get-pt(j)
          let p-next = get-pt(j + 1)
          let p-next2 = get-pt(j + 2)

          let c1 = (0pt, 0pt)
          let c2 = (0pt, 0pt)

          if l-type == "curve" {
            // Weighted Bessel Spline
            let tension = 0.25
            let d-curr-x = p-next.at(0) - p-curr.at(0)
            let d-curr-y = p-next.at(1) - p-curr.at(1)
            let len-curr = calc.sqrt((d-curr-x / 1pt) * (d-curr-x / 1pt) + (d-curr-y / 1pt) * (d-curr-y / 1pt))

            let get-dir(pa, pb) = {
              let dx = (pb.at(0) - pa.at(0)) / 1pt
              let dy = (pb.at(1) - pa.at(1)) / 1pt
              let l = calc.max(1e-5, calc.sqrt(dx * dx + dy * dy))
              (dx / l, dy / l)
            }

            let t1-x = 0
            let t1-y = 0
            if j == 0 {
              if eff-s-dir == "vertical" { t1-y = if d-curr-y > 0pt { 1 } else { -1 } } else {
                t1-x = if d-curr-x > 0pt { 1 } else { -1 }
              }
            } else {
              let dir-in = get-dir(p-prev, p-curr)
              let dir-out = get-dir(p-curr, p-next)
              t1-x = dir-in.at(0) + dir-out.at(0)
              t1-y = dir-in.at(1) + dir-out.at(1)
            }
            let t1-len = calc.max(1e-5, calc.sqrt(t1-x * t1-x + t1-y * t1-y))
            let cp-dist1 = len-curr * tension
            c1 = (
              p-curr.at(0) + deixis-utils.to-length(t1-x / t1-len) * cp-dist1,
              p-curr.at(1) + deixis-utils.to-length(t1-y / t1-len) * cp-dist1,
            )

            let t2-x = 0
            let t2-y = 0
            if j == pts.len() - 2 {
              if eff-t-dir == "vertical" { t2-y = if d-curr-y > 0pt { 1 } else { -1 } } else {
                t2-x = if d-curr-x > 0pt { 1 } else { -1 }
              }
            } else {
              let dir-in = get-dir(p-curr, p-next)
              let dir-out = get-dir(p-next, p-next2)
              t2-x = dir-in.at(0) + dir-out.at(0)
              t2-y = dir-in.at(1) + dir-out.at(1)
            }
            let t2-len = calc.max(1e-5, calc.sqrt(t2-x * t2-x + t2-y * t2-y))
            let cp-dist2 = len-curr * tension
            c2 = (
              p-next.at(0) - deixis-utils.to-length(t2-x / t2-len) * cp-dist2,
              p-next.at(1) - deixis-utils.to-length(t2-y / t2-len) * cp-dist2,
            )
          } else if l-type == "ccr" {
            // Centripetal Catmull-Rom
            let get-dist(pa, pb) = calc.sqrt(
              calc.pow((pa.at(0) - pb.at(0)) / 1pt, 2) + calc.pow((pa.at(1) - pb.at(1)) / 1pt, 2),
            )

            let d1 = calc.sqrt(get-dist(p-prev, p-curr)) + 1e-5
            let d2 = calc.sqrt(get-dist(p-curr, p-next)) + 1e-5
            let d3 = calc.sqrt(get-dist(p-next, p-next2)) + 1e-5

            let d1-sq = d1 * d1
            let d2-sq = d2 * d2
            let d3-sq = d3 * d3

            let off1-x = (
              (d1-sq * (p-next.at(0) - p-curr.at(0)) + d2-sq * (p-curr.at(0) - p-prev.at(0))) / (3.0 * d1 * (d1 + d2))
            )
            let off1-y = (
              (d1-sq * (p-next.at(1) - p-curr.at(1)) + d2-sq * (p-curr.at(1) - p-prev.at(1))) / (3.0 * d1 * (d1 + d2))
            )

            let off2-x = (
              (d2-sq * (p-next2.at(0) - p-next.at(0)) + d3-sq * (p-next.at(0) - p-curr.at(0))) / (3.0 * d3 * (d2 + d3))
            )
            let off2-y = (
              (d2-sq * (p-next2.at(1) - p-next.at(1)) + d3-sq * (p-next.at(1) - p-curr.at(1))) / (3.0 * d3 * (d2 + d3))
            )

            c1 = (p-curr.at(0) + off1-x, p-curr.at(1) + off1-y)
            c2 = (p-next.at(0) - off2-x, p-next.at(1) - off2-y)
          } else {
            // Uniform Catmull-Rom
            let get-tan(idx) = scale(sub(get-pt(idx + 1), get-pt(idx - 1)), 1.0 / 6.0)
            c1 = add(p-curr, get-tan(j))
            c2 = sub(p-next, get-tan(j + 1))
          }

          if j == 0 { t-start = c1 }
          if j == pts.len() - 2 { t-end = c2 }
          cmds.push(curve.cubic(c1, c2, p-next))
        }
      }
    }

    if i == 0 { global-t-start = t-start }
    if i == chunks.len() - 1 { global-t-end = t-end }
  }

  let elements = ()

  elements.push(place(top + left, dx: S-x, dy: S-y, curve(stroke: link-stroke, ..cmds)))

  let abs-t-start = (S-x + global-t-start.at(0), S-y + global-t-start.at(1))
  let abs-t-end = (S-x + global-t-end.at(0), S-y + global-t-end.at(1))

  if link-marks in ("mark", "start", "both") {
    elements.push(_deixis-draw-arrowhead(abs-t-start, (S-x, S-y), stroke: link-stroke))
  }
  if link-marks in ("body", "end", "both") {
    elements.push(_deixis-draw-arrowhead(abs-t-end, (E-x, E-y), stroke: link-stroke))
  }

  return elements
}

#let _deixis-draw-direct-link(
  S-x,
  S-y,
  E-x,
  E-y,
  waypoints: (),
  link-type: "straight-line",
  link-stroke: luma(0),
  link-radius: 0pt,
  link-marks: "none",
  source-dir: "vertical",
  target-dir: "horizontal",
  is-incoming: false,
  is-outgoing: false,
  extra-data: (:),
) = {
  let actual-mark = link-marks
  if is-incoming {
    if actual-mark == "both" { actual-mark = "end" } else if actual-mark == "start" { actual-mark = "none" }
  } else if is-outgoing {
    if actual-mark == "both" { actual-mark = "start" } else if actual-mark == "end" { actual-mark = "none" }
  }

  let elements = ()

  let c-content = if type(link-type) == function {
    let func-args = (
      S-x: S-x,
      S-y: S-y,
      E-x: E-x,
      E-y: E-y,
      waypoints: waypoints,
      stroke: link-stroke,
      radius: link-radius,
      mark: actual-mark,
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
      link-type: link-type,
      link-stroke: link-stroke,
      link-radius: link-radius,
      link-marks: actual-mark,
      source-dir: source-dir,
      target-dir: target-dir,
    )
  }

  for el in c-content { elements.push(el) }

  // draw spill marks
  if is-incoming or is-outgoing {
    let c-obj = std.stroke(link-stroke)
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

// The routing engine for rendering connector lines between marks and bodies.
#let _deixis-route-link(
  data,
  internal-id,
  current-page,
  S-page,
  E-page,
  S-candidates,
  D-candidates,
  c-link: auto,
  c-link-stroke: auto,
  c-link-radius: auto,
  c-link-marks: auto,
  split-default: "source",
  turn-x: auto,
  synthetic-waypoints: auto,
  is-margin: false,
  extra-data: (:),
) = {
  let paths = ()
  let is-cross-page = (S-page != E-page)
  let is-outgoing = (is-cross-page and current-page == S-page)
  let is-incoming = (is-cross-page and current-page == E-page)

  // user link-ports
  let S-candidates = S-candidates
  let D-candidates = D-candidates
  let c-ports = data.at("link-ports", default: auto)
  if type(c-ports) == dictionary {
    if "mark" in c-ports {
      let f-S = S-candidates.filter(p => p.id == c-ports.mark)
      if f-S.len() > 0 { S-candidates = f-S }
    }
    if "body" in c-ports {
      let f-D = D-candidates.filter(p => p.id == c-ports.body)
      if f-D.len() > 0 { D-candidates = f-D }
    }
  }

  let m-cx = S-candidates.first().x
  let m-y = S-candidates.first().y
  let D-top-x = D-candidates.first().x
  let D-top-y = D-candidates.first().y

  let extract-box(candidates) = {
    let xs = candidates.map(c => c.x)
    let ys = candidates.map(c => c.y)
    let min-x = calc.min(..xs)
    let max-x = calc.max(..xs)
    let min-y = calc.min(..ys)
    let max-y = calc.max(..ys)
    return (
      left: min-x,
      right: max-x,
      top: min-y,
      bottom: max-y,
      center-x: (min-x + max-x) / 2.0,
      center-y: (min-y + max-y) / 2.0,
    )
  }
  let m-box = extract-box(S-candidates)
  let b-box = extract-box(D-candidates)

  let raw-waypoints = data.at("link-waypoints", default: auto)
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
    let dry-run = _deixis-resolve-waypoints(pre-wps, m-box.center-x, m-box.center-y, m-box, b-box)
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
      let dry-run = _deixis-resolve-waypoints(pre-wps, m-box.center-x, m-box.center-y, m-box, b-box)
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
  let p-margins = deixis-utils.get-page-margins(current-page)
  let page-h = if type(page.height) == length { page.height } else { 29.7cm }
  let top-bound = deixis-utils.resolve-len(p-margins.top)
  let bottom-bound = deixis-utils.resolve-len(page-h) - deixis-utils.resolve-len(p-margins.bottom)

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

  let resolved-wps = _deixis-resolve-waypoints(active-raw-wps, wps-start-x, wps-start-y, m-box, b-box)

  let safe-wps = resolved-wps.filter(x => type(x) == str or (type(x) == array and x.len() >= 2))
  let coord-wps = safe-wps.filter(x => type(x) == array)

  let S-anchor-x = S-candidates.first().x
  let S-anchor-y = S-candidates.first().y
  let E-anchor-x = D-top-x
  let E-anchor-y = D-top-y
  let source-dir = "vertical"
  let target-dir = "vertical"

  if is-outgoing {
    let virtual-D-ports = ((x: split-x, y: virtual-y-out, dir: "vertical", id: virtual-id-out),)
    if coord-wps.len() > 0 {
      virtual-D-ports = ((x: coord-wps.first().at(0), y: coord-wps.first().at(1), dir: "none", id: "none"),)
    }

    let (best-S, best-D) = _deixis-resolve-best-ports(S-candidates, virtual-D-ports)
    S-anchor-x = best-S.x
    S-anchor-y = best-S.y
    source-dir = best-S.dir
    E-anchor-x = split-x
    E-anchor-y = virtual-y-out
    target-dir = virtual-id-out
  } else if is-incoming {
    let virtual-S-ports = ((x: split-x, y: virtual-y-in, dir: "vertical", id: virtual-id-in),)
    if coord-wps.len() > 0 {
      virtual-S-ports = ((x: coord-wps.last().at(0), y: coord-wps.last().at(1), dir: "none", id: "none"),)
    }

    let (best-S, best-D) = _deixis-resolve-best-ports(virtual-S-ports, D-candidates)
    S-anchor-x = split-x
    S-anchor-y = virtual-y-in
    source-dir = virtual-id-in
    E-anchor-x = best-D.x
    E-anchor-y = best-D.y
    target-dir = best-D.dir
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
  }

  let final-wps = safe-wps.map(wp => if type(wp) == str { wp } else { (wp.at(0) - S-anchor-x, wp.at(1) - S-anchor-y) })

  let call-extra = (dx: E-anchor-x - S-anchor-x, dy: E-anchor-y - S-anchor-y)
  for (k, v) in extra-data { call-extra.insert(k, v) }

  let direct-links = _deixis-draw-direct-link(
    S-anchor-x,
    S-anchor-y,
    E-anchor-x,
    E-anchor-y,
    waypoints: final-wps,
    link-type: c-link,
    link-stroke: c-link-stroke,
    link-radius: c-link-radius,
    link-marks: c-link-marks,
    source-dir: source-dir,
    target-dir: target-dir,
    is-incoming: is-incoming,
    is-outgoing: is-outgoing,
    extra-data: call-extra,
  )

  for el in direct-links { paths.push(el) }
  return paths
}

/// --------------------
/// Margin link
/// --------------------

#let _deixis-render-margin-links(
  all-notes,
  current-page,
  text-bounds,
  top-bound,
  bottom-bound,
) = {
  let paths = ()

  let font-asc = deixis-utils.resolve-len(0.9em)
  let font-desc = deixis-utils.resolve-len(0.1em)
  let box-h = deixis-utils.resolve-len(0.8em)
  let box-y-offset = 0pt
  let actual-box-h = box-h + 2pt

  let track-drops = (:)
  let track-verticals = (:)

  let left-body-notes = all-notes.filter(n => n.side in (left, "left") and not n.at("is-outgoing", default: false))
  let min-gap-l = 20.0
  if left-body-notes.len() > 0 {
    min-gap-l = calc.min(..left-body-notes.map(n => {
      let nx = n.at("attach-x", default: 0pt)
      return calc.max(0.0, (text-bounds.left - nx) / 1pt)
    }))
  }
  let max-v-lines-l = calc.max(1, calc.floor((min-gap-l - 4.0) / 2.5))

  let right-body-notes = all-notes.filter(n => n.side not in (left, "left") and not n.at("is-outgoing", default: false))
  let min-gap-r = 20.0
  if right-body-notes.len() > 0 {
    min-gap-r = calc.min(..right-body-notes.map(n => {
      let nx = n.at("attach-x", default: 0pt)
      return calc.max(0.0, (nx - text-bounds.right) / 1pt)
    }))
  }
  let max-v-lines-r = calc.max(1, calc.floor((min-gap-r - 4.0) / 2.5))

  for n in all-notes.sorted(key: x => x.at("mark-x", default: 0pt)) {
    let is-incoming = n.at("is-incoming", default: false)
    let is-outgoing = n.at("is-outgoing", default: false)

    if not is-incoming and n.at("mark-page", default: current-page) != current-page { continue }

    let link = n.at("link", default: "none")
    if link in (none, false, "none") { continue }

    let link-stroke = n.at("link-stroke", default: none)
    let link-radius = n.at("link-radius", default: 0pt)
    let link-marks = n.at("link-marks", default: "none")
    let link-waypoints = n.at("link-waypoints", default: auto)

    let actual-mark = link-marks
    if is-incoming {
      if actual-mark == "both" { actual-mark = "end" } else if actual-mark == "start" { actual-mark = "none" }
    } else if is-outgoing {
      if actual-mark == "both" { actual-mark = "start" } else if actual-mark == "end" { actual-mark = "none" }
    }

    let is-left = n.side in (left, "left")
    let bound-x = if is-left { text-bounds.left } else { text-bounds.right }

    let marker-width = n.at("marker-width", default: 0pt)
    let mark-x = n.at("mark-x", default: 0pt)
    let mark-y = n.at("mark-y", default: 0pt)
    let mark-center-x = mark-x + (marker-width / 2)

    let text-size = n.at("text-size", default: auto)
    let t-val = deixis-utils.resolve-len(if text-size != auto and type(text-size) == length { text-size } else { 11pt })

    let has-inline-box = n.at("has-inline-box", default: false)

    let box-top = mark-y - (t-val * if has-inline-box { 0.9 } else { 0.8 })
    let box-bottom = mark-y + (t-val * if has-inline-box { 0.2 } else { 0.05 })

    let box-y = mark-y - (t-val * 0.8)
    let box-x = mark-x - 1.5pt
    let actual-box-h = t-val * 0.85

    let n-top = n.at("final-y", default: 0pt)
    let n-h = n.at("h", default: 0pt)
    let n-w = n.at("w", default: 0pt)
    let n-bottom = n-top + n-h
    let n-x = n.at("attach-x", default: 0pt)

    let safe-pad = calc.min(4.0, (n-h / 1pt) / 2.0)
    let clamp-min = (n-top + (safe-pad * 1pt)) / 1pt
    let clamp-max = (n-bottom - (safe-pad * 1pt)) / 1pt

    clamp-max = calc.max(clamp-min, clamp-max)

    let safe-wps = if link-waypoints != none and type(link-waypoints) == array {
      link-waypoints.filter(x => type(x) == array and x.len() >= 2)
    } else { () }

    let m-y-attach = 0pt
    let n-attach-y = 0pt
    let ideal-y = calc.clamp(mark-y / 1pt, clamp-min, clamp-max) * 1pt

    if is-incoming {
      n-attach-y = clamp-min * 1pt
      m-y-attach = top-bound
    } else if is-outgoing {
      m-y-attach = box-bottom
      n-attach-y = bottom-bound
    } else {
      let goes-up = if safe-wps.len() > 0 { safe-wps.first().at(1) < 0pt } else { ideal-y < mark-y }
      m-y-attach = if goes-up { box-top } else { box-bottom }

      let last-source-y = if safe-wps.len() > 0 { m-y-attach + safe-wps.last().at(1) } else { m-y-attach }
      n-attach-y = calc.clamp(last-source-y / 1pt, clamp-min, clamp-max) * 1pt
    }

    // --- HORIZONTAL ANTI-OVERLAP ---

    let route-down = false
    if is-outgoing {
      route-down = true
    } else if is-incoming {
      route-down = false
    } else {
      route-down = (m-y-attach > mark-y)
    }

    let dir-str = if route-down { "d" } else { "u" }
    let line-key = str(calc.round(mark-y / 1pt)) + "-" + dir-str
    let h-count = track-drops.at(line-key, default: 0)
    track-drops.insert(line-key, h-count + 1)

    let h-cycle = calc.rem(h-count, 4)
    let step-size = t-val * 0.04
    let drop-mag = 0pt

    let base-drop = t-val * 0.05
    let max-drop = t-val * 0.25
    drop-mag = base-drop + (h-cycle * step-size)
    drop-mag = calc.min(drop-mag / 1pt, max-drop / 1pt) * 1pt

    let drop-y = m-y-attach + (if route-down { drop-mag } else { -drop-mag })

    // --- VERTICAL ANTI-OVERLAP ---
    let side-key = if is-left { "l" } else { "r" }
    let v-count = track-verticals.at(side-key, default: 0)
    track-verticals.insert(side-key, v-count + 1)

    let max-v = if is-left { max-v-lines-l } else { max-v-lines-r }
    let v-cycle = calc.rem(v-count, max-v)
    let turn-shift = 2.0 + (v-cycle * 2.5)

    let turn-x = if is-left {
      bound-x - turn-shift * 1pt
    } else {
      bound-x + turn-shift * 1pt
    }

    // draw rectangles
    let highlight = _deixis-draw-marker-highlight(
      mark-x,
      mark-y,
      marker-width,
      n.marker-str,
      stroke: link-stroke,
      text-size: t-val,
      has-inline-box: has-inline-box,
      mark-type: n.at("mark-type", default: "inline"),
    )

    if not is-incoming and highlight != none { paths.push(highlight) }

    // anchors & synthetic waypoints
    let mark-type = n.at("mark-type", default: "inline")
    let S-candidates = ()
    let synth-wps = ()

    let c-ports = n.at("link-ports", default: auto)
    let override-mark = if type(c-ports) == dictionary and "mark" in c-ports { c-ports.mark } else { auto }

    if mark-type == "region" and n.r-pins.len() > 0 {
      let r-pins = n.r-pins
      let reg = n.reg
      let min-x = 1e10pt
      let max-x = -1e10pt
      let min-y = 1e10pt
      let max-y = -1e10pt
      let page-pins = r-pins.filter(p => p.location().page() == current-page)

      if page-pins.len() > 0 {
        for p in page-pins {
          let px = deixis-utils.resolve-signed-len(p.location().position().x)
          let py = deixis-utils.resolve-signed-len(p.location().position().y)
          let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))

          let px-l = px - deixis-utils.resolve-signed-len(p-pad.left)
          let px-r = px + deixis-utils.resolve-signed-len(p-pad.right)
          let py-t = py - deixis-utils.resolve-signed-len(p-pad.top)
          let py-b = py + deixis-utils.resolve-signed-len(p-pad.bottom)

          if px-l < min-x { min-x = px-l }
          if px-r > max-x { max-x = px-r }
          if py-t < min-y { min-y = py-t }
          if py-b > max-y { max-y = py-b }
        }
      } else {
        min-x = mark-center-x
        max-x = mark-center-x
        min-y = m-y-attach
        max-y = m-y-attach
      }

      let reg-pad = deixis-utils.get-margins(reg.styles.at("padding", default: 0pt))
      min-x -= deixis-utils.resolve-signed-len(reg-pad.left)
      max-x += deixis-utils.resolve-signed-len(reg-pad.right)
      min-y -= deixis-utils.resolve-signed-len(reg-pad.top)
      max-y += deixis-utils.resolve-signed-len(reg-pad.bottom)

      let sliding-y = calc.clamp(n-attach-y / 1pt, min-y / 1pt, max-y / 1pt) * 1pt
      if sliding-y < min-y { sliding-y = (min-y + max-y) / 2.0 }

      let r-cx = (min-x + max-x) / 2.0
      let r-cy = (min-y + max-y) / 2.0

      // user-provided ports
      if override-mark == "top" {
        S-candidates = ((x: r-cx, y: min-y, dir: "vertical", id: "top"),)
      } else if override-mark == "bottom" {
        S-candidates = ((x: r-cx, y: max-y, dir: "vertical", id: "bottom"),)
      } else if override-mark == "left" {
        S-candidates = ((x: min-x, y: r-cy, dir: "horizontal", id: "left"),)
      } else if override-mark == "right" {
        S-candidates = ((x: max-x, y: r-cy, dir: "horizontal", id: "right"),)
      } else {
        // Fallback to distance-minimizing sliding port
        let out-x = if is-left { min-x } else { max-x }
        let out-id = if is-left { "left" } else { "right" }
        S-candidates = ((x: out-x, y: sliding-y, dir: "horizontal", id: out-id),)
      }

      let S-pt = S-candidates.first()
      let out-x = S-pt.x
      let out-y = S-pt.y

      // prevent backwards folding if user forces a port that points across the text bounds
      if S-pt.id == "left" and min-x < turn-x {
        turn-x = min-x - turn-shift * 1pt
      } else if S-pt.id == "right" and max-x > turn-x {
        turn-x = max-x + turn-shift * 1pt
      }

      if link-waypoints == auto and link in ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr") {
        if S-pt.dir == "vertical" {
          // if port is top/bottom, it must exit vertically into the drop channel first
          if is-outgoing {
            synth-wps = (
              (0pt, drop-y - out-y),
              (turn-x - out-x, 0pt),
              (0pt, bottom-bound - drop-y),
              deixis-waypoint-split,
            )
          } else if is-incoming {
            synth-wps = (deixis-waypoint-split, (0pt, n-attach-y - top-bound))
          } else {
            synth-wps = ((0pt, drop-y - out-y), (turn-x - out-x, 0pt), (0pt, n-attach-y - drop-y))
          }
        } else {
          // horizontal exit
          synth-wps = (
            (turn-x - out-x, 0pt),
            (0pt, n-attach-y - out-y),
          )
        }
      } else {
        if is-outgoing or is-incoming { synth-wps = (deixis-waypoint-split,) }
      }
    } else {
      // inline & phantom mark
      let use-bottom = if override-mark == "bottom" { true } else if override-mark == "top" { false } else {
        route-down
      }
      let out-id = if use-bottom { "bottom" } else { "top" }
      let out-y = if use-bottom { box-bottom } else { box-top }

      S-candidates = (
        (x: mark-center-x, y: out-y, dir: "vertical", id: out-id),
      )

      if link-waypoints == auto and link in ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr") {
        if is-outgoing {
          synth-wps = (
            (0pt, drop-y - out-y),
            (turn-x - mark-center-x, 0pt),
            (0pt, bottom-bound - drop-y),
            deixis-waypoint-split,
          )
        } else if is-incoming {
          synth-wps = (deixis-waypoint-split, (0pt, n-attach-y - top-bound))
        } else {
          synth-wps = ((0pt, drop-y - out-y), (turn-x - mark-center-x, 0pt), (0pt, n-attach-y - drop-y))
        }
      } else {
        if is-outgoing or is-incoming { synth-wps = (deixis-waypoint-split,) }
      }
    }

    let D-candidates = (
      (x: n-x, y: n-attach-y, dir: "horizontal", id: if is-left { "right" } else { "left" }),
    )

    let S-page = current-page
    let E-page = current-page
    if is-outgoing { E-page = current-page + 1 } else if is-incoming { S-page = current-page - 1 }

    let extra = (
      bound-dx: bound-x - mark-center-x,
      turn-dx: turn-x - mark-center-x,
      drop-y: drop-y - m-y-attach,
      side: n.side,
    )

    let link-paths = _deixis-route-link(
      n,
      n.at("id", default: "margin"),
      current-page,
      S-page,
      E-page,
      S-candidates,
      D-candidates,
      c-link: link,
      c-link-stroke: link-stroke,
      c-link-radius: link-radius,
      c-link-marks: actual-mark,
      split-default: "target",
      turn-x: turn-x,
      synthetic-waypoints: synth-wps,
      is-margin: true,
      extra-data: extra,
    )

    for el in link-paths { paths.push(el) }
  }
  return paths.join()
}

/// --------------------
/// Inset link
/// --------------------

#let _deixis-render-inset-link(
  data,
  current-page,
  S-page,
  E-page,
  S,
  D-top,
  reg: none,
  r-pins: (),
  c-link: auto,
  c-link-stroke: auto,
  c-link-radius: auto,
  c-link-marks: auto,
) = {
  let internal-id = data.internal-id
  let mark-type = data.at("mark-type", default: "inline")

  let paths = ()
  let is-cross-page = (S-page != E-page)
  let is-outgoing = (is-cross-page and current-page == S-page)
  let is-incoming = (is-cross-page and current-page == E-page)

  let source-candidates = ()
  let m-cx = S.x
  let mark-y = S.y

  // cross-page bounding boxes
  if mark-type == "region" and r-pins.len() > 0 {
    let sorted-pins = r-pins.sorted(key: p => (p.location().page(), p.location().position().y))
    let first-region-page = sorted-pins.first().location().page()
    let last-region-page = sorted-pins.last().location().page()

    let min-x = 1e10pt
    let max-x = -1e10pt
    for p in r-pins {
      let px = deixis-utils.resolve-signed-len(p.location().position().x)
      let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
      let px-l = px - deixis-utils.resolve-signed-len(p-pad.left)
      let px-r = px + deixis-utils.resolve-signed-len(p-pad.right)
      if px-l < min-x { min-x = px-l }
      if px-r > max-x { max-x = px-r }
    }

    let p-margins = deixis-utils.get-page-margins(S-page)
    let page-h = deixis-utils.resolve-len(if type(page.height) == length { page.height } else { 29.7cm })
    let min-y = deixis-utils.resolve-len(p-margins.top)
    let max-y = page-h - deixis-utils.resolve-len(p-margins.bottom)

    let page-pins = r-pins.filter(p => p.location().page() == S-page)
    if page-pins.len() > 0 {
      let local-min-y = 1e10pt
      let local-max-y = -1e10pt
      for p in page-pins {
        let py = deixis-utils.resolve-signed-len(p.location().position().y)
        let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
        let py-t = py - deixis-utils.resolve-signed-len(p-pad.top)
        let py-b = py + deixis-utils.resolve-signed-len(p-pad.bottom)
        if py-t < local-min-y { local-min-y = py-t }
        if py-b > local-max-y { local-max-y = py-b }
      }
      if S-page == first-region-page { min-y = local-min-y }
      if S-page == last-region-page { max-y = local-max-y }
    }

    let reg-pad = deixis-utils.get-margins(reg.styles.at("padding", default: 0pt))
    min-x -= deixis-utils.resolve-signed-len(reg-pad.left)
    max-x += deixis-utils.resolve-signed-len(reg-pad.right)
    if S-page == first-region-page { min-y -= deixis-utils.resolve-signed-len(reg-pad.top) }
    if S-page == last-region-page { max-y += deixis-utils.resolve-signed-len(reg-pad.bottom) }

    m-cx = (min-x + max-x) / 2.0
    mark-y = min-y

    source-candidates = (
      (x: m-cx, y: min-y, dir: "vertical", id: "top"),
      (x: m-cx, y: max-y, dir: "vertical", id: "bottom"),
      (x: min-x, y: (min-y + max-y) / 2.0, dir: "horizontal", id: "left"),
      (x: max-x, y: (min-y + max-y) / 2.0, dir: "horizontal", id: "right"),
    )
  }

  // inline marker fallback
  if source-candidates.len() == 0 {
    let mm-elems = query(selector(metadata).and(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>))).filter(m => (
      type(m.value) == dictionary
        and m.value.at("internal-id", default: none) != none
        and str(m.value.internal-id) == str(internal-id)
    ))

    let marker-width = data.at("marker-width", default: 0pt)
    let text-size = data.at("text-size", default: 11pt)

    if mm-elems.len() > 0 {
      let mm-val = mm-elems.first().value
      marker-width = mm-val.at("marker-width", default: marker-width)
      text-size = mm-val.at("text-size", default: text-size)
    }

    let t-val = if type(text-size) == length { text-size } else { 11pt }
    let has-inline-box = data.at("has-inline-box", default: false)

    let mark-x = S.x
    mark-y = S.y
    m-cx = S.x + (marker-width / 2)

    if not is-incoming and mark-type != "region" {
      let highlight = _deixis-draw-marker-highlight(
        mark-x,
        mark-y,
        marker-width,
        data.marker-str,
        stroke: c-link-stroke,
        text-size: t-val,
        has-inline-box: has-inline-box,
        mark-type: mark-type,
      )
      if highlight != none { paths.push(highlight) }
    }

    let box-top = mark-y - (t-val * if has-inline-box { 0.9 } else { 0.8 })
    let box-bottom = mark-y + (t-val * if has-inline-box { 0.2 } else { 0.05 })
    let box-horizon = mark-y - (t-val * 0.3)

    source-candidates = (
      (x: m-cx, y: box-top, dir: "vertical", id: "top"),
      (x: m-cx, y: box-bottom, dir: "vertical", id: "bottom"),
    )
    if data.at("marker-width", default: 0pt) == 0pt {
      source-candidates.push(
        (x: mark-x + marker-width + 1.5pt, y: box-horizon, dir: "horizontal", id: "right"),
      )
      source-candidates.push(
        (x: mark-x - 1.5pt, y: box-horizon, dir: "horizontal", id: "left"),
      )
    } else if data.at("marker-position", default: none) in (right, "right") {
      source-candidates.push(
        (x: mark-x + marker-width + 1.5pt, y: box-horizon, dir: "horizontal", id: "right"),
      )
    } else if data.at("marker-position", default: none) in (left, "left") {
      source-candidates.push(
        (x: mark-x - 1.5pt, y: box-horizon, dir: "horizontal", id: "left"),
      )
    }
  }

  let d-bot-elems = query(selector(data.at("dest-bot-lbl", default: data.body-lbl)))
  let d-left-elems = query(selector(data.at("dest-left-lbl", default: data.body-lbl)))
  let d-right-elems = query(selector(data.at("dest-right-lbl", default: data.body-lbl)))

  let D-bot = if d-bot-elems.len() > 0 { d-bot-elems.last().location().position() } else { D-top }
  let D-left = if d-left-elems.len() > 0 { d-left-elems.last().location().position() } else { D-top }
  let D-right = if d-right-elems.len() > 0 { d-right-elems.last().location().position() } else { D-top }

  let dest-candidates = (
    (x: D-top.x, y: D-top.y, dir: "vertical", id: "top"),
    (x: D-bot.x, y: D-bot.y, dir: "vertical", id: "bottom"),
    (x: D-left.x, y: D-left.y, dir: "horizontal", id: "left"),
    (x: D-right.x, y: D-right.y, dir: "horizontal", id: "right"),
  )

  let routed-links = _deixis-route-link(
    data,
    internal-id,
    current-page,
    S-page,
    E-page,
    source-candidates,
    dest-candidates,
    c-link: c-link,
    c-link-stroke: c-link-stroke,
    c-link-radius: c-link-radius,
    c-link-marks: c-link-marks,
    split-default: "source",
    is-margin: false,
  )

  if type(routed-links) == array {
    paths += routed-links
  } else if routed-links != none {
    paths.push(routed-links)
  }

  return paths
}
