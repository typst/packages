#import "validation.typ": *
#import "dictionaries.typ": *
#import "geometry.typ": *
#import "corners.typ": *

// Shared drawing engine for `squircle`, `superellipse`, and `clothoid`.
// Mirrors `rect` layout and stroke handling, delegating corner construction to `_piece-for`.

#let _draw-shape(
  width: auto,
  height: auto,
  fill: none,
  stroke: auto,
  radius: 0pt,
  inset: 5pt,
  outset: 0pt,
  per-edge-smoothing: false,
  _piece-for,
  body: none,
) = {
  // Missing side keys fall back to defaults, matching rect.
  let ins = _resolve-edges(inset, default: 5pt)
  let base-outs = _resolve-edges(outset, default: 0pt)
  let radius-corners = _resolve-corners(radius, default: 0pt)

  // Resolved stroke for each side.
  let sides = _stroke-sides(stroke, fill != none)
    .pairs()
    .map(((k, v)) => (k, _fixed(v)))
    .to-dict()
  let plain = (
    _corner-order.all(c => _rel-is-zero(radius-corners.at(c)))
      and _fixed-eq(sides.left, sides.top)
      and _fixed-eq(sides.top, sides.right)
      and _fixed-eq(sides.right, sides.bottom)
  )

  // Half thicknesses. Radius measures to the outer stroke edge.
  let half = sides
    .pairs()
    .map(((k, v)) => (k, if v == none { none } else { v.thickness / 2 }))
    .to-dict()

  // Split corners where meeting strokes differ.
  let same = _corner-order
    .map(c => (
      c,
      _same-stroke(sides.at(_side-ccw.at(c)), sides.at(_side-cw.at(c))),
    ))
    .to-dict()

  // Clockwise runs of sides sharing a pen.
  let runs = ()
  let cut = _corner-order.find(c => not same.at(c))
  if cut != none {
    let current = cut
    let last = cut
    for _ in range(4) {
      current = _next-cw.at(current)
      if same.at(current) { continue }
      runs.push((last, current))
      last = current
    }
  } else if sides.top != none {
    runs.push(("top-left", "top-left"))
  }

  // Run properties without tight-corner checks.
  let segments = runs
    .map(((start, end)) => {
      let side-stroke = sides.at(_side-cw.at(start))
      if side-stroke == none { return none }
      let start-cap = side-stroke.cap
      (
        start: start,
        end: end,
        stroke: side-stroke,
        start-cap: start-cap,
        end-cap: {
          let s = sides.at(_side-ccw.at(end))
          if s == none { start-cap } else { s.cap }
        },
        solid: _is-solid(side-stroke),
      )
    })
    .filter(s => s != none)

  // Corners where an outline splits.
  let split-corners = ()
  for s in segments {
    if s.start != s.end {
      for c in (s.start, s.end) {
        if c not in split-corners { split-corners.push(c) }
      }
    }
  }

  // layout is already contextual, so measure needs no context.
  layout(container-size => {
    let cw = container-size.width
    let ch = container-size.height
    let unbounded(l) = calc.abs(l / 1pt) == calc.inf

    // In unbounded regions, rect drops ratio components.
    let resolve-size(val, basis) = {
      if not unbounded(basis) { _resolve-scalar(val, basis) } else if (
        type(val) == ratio
      ) { 0pt } else if type(val) == relative { val.length } else { val }
    }

    // Measure body width, keeping results for auto-height.
    let (w, measured) = if width != auto {
      (resolve-size(width, cw), none)
    } else if body == none {
      // Default size when body is omitted.
      (calc.min(45pt, cw), none)
    } else if unbounded(cw) {
      // Unbounded widths do not line-break.
      let m = measure(body)
      (_resolve-auto-dim(m.width, ins.left, ins.right), m)
    } else if type(ins.left) == length and type(ins.right) == length {
      // Absolute padding does not depend on width.
      let m = measure(body, width: calc.max(0pt, cw - ins.left - ins.right))
      (calc.min(m.width + ins.left + ins.right, cw), m)
    } else {
      // Ratio insets require iterative fixed-point layout.
      let w-fp = cw
      // Break early once width converges.
      for _ in range(40) {
        let pl = _resolve-scalar(ins.left, w-fp)
        let pr = _resolve-scalar(ins.right, w-fp)
        let inner = calc.max(0pt, w-fp - pl - pr)
        let next = measure(body, width: inner).width + pl + pr
        let settled = calc.abs(next - w-fp) < 0.0001pt
        w-fp = next
        if settled { break }
      }
      (calc.min(w-fp, cw), none)
    }

    // Draw once final box dimensions are known.
    let draw(w, h) = {
      // Outsets resolve against box size.
      let outs = (
        top: _resolve-scalar(base-outs.top, h),
        right: _resolve-scalar(base-outs.right, w),
        bottom: _resolve-scalar(base-outs.bottom, h),
        left: _resolve-scalar(base-outs.left, w),
      )
      let out-w = w + outs.left + outs.right
      let out-h = h + outs.top + outs.bottom

      // Unrounded boxes use closed rectangles.
      let shapes = if plain {
        (
          (
            fill: fill,
            stroke: sides.top,
            elems: (
              curve.move((0pt, 0pt)),
              curve.line((out-w, 0pt)),
              curve.line((out-w, out-h)),
              curve.line((0pt, out-h)),
              curve.close(mode: "straight"),
            ),
          ),
        )
      } else {
        let box-corner = (
          top-left: (0pt, 0pt),
          top-right: (out-w, 0pt),
          bottom-right: (out-w, out-h),
          bottom-left: (0pt, out-h),
        )

        // Control points for outer, middle, and inner outlines.
        let base-radius = calc.min(calc.abs(out-w), calc.abs(out-h)) / 2
        let control = (:)
        for corner in _corner-order {
          let (edge-in, edge-out, ..) = _corner-geom.at(corner)
          let sb-opt = half.at(_side-ccw.at(corner))
          let sa-opt = half.at(_side-cw.at(corner))
          // Allow thinner stroke thickness on top of half the short side.
          let both = if sb-opt != none and sa-opt != none {
            calc.min(sb-opt, sa-opt)
          } else { 0pt }
          let corner-max = base-radius + both
          let r-outer = calc.min(
            _resolve-scalar(radius-corners.at(corner), corner-max * 2),
            corner-max,
          )
          // Unstroked sides borrow neighboring stroke width if radius permits.
          let sb = if sb-opt != none { sb-opt } else if (
            sa-opt != none and 2 * sa-opt < r-outer
          ) { sa-opt } else { 0pt }
          let sa = if sa-opt != none { sa-opt } else if (
            sb-opt != none and 2 * sb-opt < r-outer
          ) { sb-opt } else { 0pt }
          let sc = box-corner.at(corner)
          control.insert(corner, (
            sb-set: sb-opt != none,
            sa-set: sa-opt != none,
            sb: sb,
            sa: sa,
            r-outer: r-outer,
            r-mid: calc.max(0pt, r-outer - calc.min(sb, sa)),
            r-inner: calc.max(0pt, r-outer - 2 * calc.max(sb, sa)),
            pt-outer: _vsub(
              sc,
              _vadd(_vscale(edge-out, sb), _vscale(edge-in, sa)),
            ),
            pt-mid: sc,
            pt-inner: _vadd(
              sc,
              _vadd(_vscale(edge-out, sb), _vscale(edge-in, sa)),
            ),
          ))
        }

        // Build one rounded outline.
        let contour(pt-key, r-key, splits) = {
          let pts = (:)
          let radii = (:)
          for corner in _corner-order {
            pts.insert(corner, control.at(corner).at(pt-key))
            radii.insert(corner, calc.max(0pt, control.at(corner).at(r-key)))
          }
          let side-lens = (
            top: calc.abs(pts.top-right.at(0) - pts.top-left.at(0)),
            right: calc.abs(pts.bottom-right.at(1) - pts.top-right.at(1)),
            bottom: calc.abs(pts.bottom-right.at(0) - pts.bottom-left.at(0)),
            left: calc.abs(pts.bottom-left.at(1) - pts.top-left.at(1)),
          )
          let budget = _budgets(radii, side-lens, per-edge-smoothing)
          let out = (:)
          for corner in _corner-order {
            out.insert(corner, _piece-for(
              corner,
              pts.at(corner),
              // Raw radius is passed through for sharp-corner inward pull.
              control.at(corner).at(r-key),
              radii.at(corner),
              budget.at(corner),
              splits.at(corner, default: none),
            ))
          }
          out
        }

        // Fill corner when pens differ or stroke is wider than remaining radius.
        let fill-corner(corner) = {
          let c = control.at(corner)
          let sb-val = if c.sb-set { c.sb } else { none }
          let sa-val = if c.sa-set { c.sa } else { none }
          sb-val != sa-val or c.r-mid < c.sb
        }
        let fill-corners(start, end) = {
          let any = fill-corner(start) or fill-corner(end)
          let cur = _next-cw.at(start)
          while cur != end {
            any = any or fill-corner(cur)
            cur = _next-cw.at(cur)
          }
          any
        }

        let segs = segments.map(s => (
          ..s,
          ring: s.solid and fill-corners(s.start, s.end),
        ))

        // Build outlines needed for rendering.
        let need-ring = segs.any(s => s.ring)
        let need-mid = fill != none or segs.any(s => not s.ring)

        // Radial split points from outer corner.
        let mid-splits = (:)
        let inner-splits = (:)
        let outer-splits = (:)
        for corner in split-corners {
          let c = control.at(corner)
          let (edge-in, edge-out, ..) = _corner-geom.at(corner)
          let diag = _vadd(edge-in, edge-out)
          let o = c.pt-outer
          let along(center, from, r) = {
            let d = _vsub(from, center)
            let h = _hypot(d)
            if h == 0pt { center } else {
              _vadd(center, _vscale(d, r / h))
            }
          }
          if need-mid {
            let center-mid = _vadd(c.pt-mid, _vscale(diag, c.r-mid))
            mid-splits.insert(corner, along(center-mid, o, c.r-mid))
          }
          if need-ring {
            let center-inner = _vadd(c.pt-inner, _vscale(diag, c.r-inner))
            let center-outer = _vadd(c.pt-outer, _vscale(diag, c.r-outer))
            inner-splits.insert(corner, along(center-inner, o, c.r-inner))

            // https://math.stackexchange.com/a/311956
            let d = _vsub(o, center-inner)
            let g = _vsub(center-inner, center-outer)
            let dx = d.at(0) / 1pt
            let dy = d.at(1) / 1pt
            let gx = g.at(0) / 1pt
            let gy = g.at(1) / 1pt
            let qa = dx * dx + dy * dy
            let qb = 2 * (dx * gx + dy * gy)
            let qc = gx * gx + gy * gy - (c.r-outer / 1pt) * (c.r-outer / 1pt)
            let t = if qa == 0 { 1.0 } else {
              (-qb + calc.sqrt(calc.max(0.0, qb * qb - 4 * qa * qc))) / (2 * qa)
            }
            outer-splits.insert(corner, _vadd(center-inner, _vscale(d, t)))
          }
        }

        let outer = if need-ring {
          contour("pt-outer", "r-outer", outer-splits)
        }
        let mid = if need-mid { contour("pt-mid", "r-mid", mid-splits) }
        let inner = if need-ring {
          contour("pt-inner", "r-inner", inner-splits)
        }

        // Open middle stroke run.
        let stroke-segment(start, end) = {
          let out = ()
          let c = mid.at(start)
          if start == end or not c.arc {
            out.push(curve.move(c.end))
          } else {
            out.push(curve.move(c.mid))
            out += _emit(c.second)
          }
          let cur = _next-cw.at(start)
          while cur != end {
            let c = mid.at(cur)
            if c.arc {
              out.push(curve.line(c.start))
              out += _emit(c.full)
            } else { out.push(curve.line(c.end)) }
            cur = _next-cw.at(cur)
          }
          let c = mid.at(end)
          if not c.arc {
            out.push(curve.line(c.start))
          } else if start == end {
            out.push(curve.line(c.start))
            out += _emit(c.full)
          } else {
            out.push(curve.line(c.start))
            out += _emit(c.first)
          }
          out
        }

        // Caps beside unstroked sides.
        let cap-at(corner, cap-type, at-start) = {
          let c = control.at(corner)
          let co = outer.at(corner)
          let ci = inner.at(corner)
          let (butt-start, butt-end) = if at-start {
            (ci.mid, co.mid)
          } else { (co.mid, ci.mid) }
          let neighbor-set = if at-start { c.sb-set } else { c.sa-set }
          let borrow = if at-start { c.sa-set and 2 * c.sa < c.r-outer } else {
            c.sb-set and 2 * c.sb < c.r-outer
          }
          let keep-butt = c.r-outer != 0pt and not borrow
          if cap-type == "butt" or neighbor-set or keep-butt {
            (curve.line(butt-end),)
          } else if cap-type == "square" {
            // Square cap extension.
            let reach = if at-start { c.sa } else { c.sb }
            let off = _vscale(_line-normal(butt-start, butt-end), reach)
            (
              curve.line(_vadd(butt-start, off)),
              curve.line(_vadd(butt-end, off)),
              curve.line(butt-end),
            )
          } else {
            let center = _vadd(
              _vscale(_vadd(butt-start, butt-end), 0.5),
              _vscale(_line-normal(butt-start, butt-end), -_cap-nudge),
            )
            (_arc-through(butt-start, center, butt-end),)
          }
        }

        // Filled ring run.
        let fill-segment(start, end, start-cap, end-cap) = {
          let out = ()
          if start == end {
            out.push(curve.move(inner.at(start).end))
            out.push(curve.line(outer.at(start).end))
          } else {
            let ci = inner.at(start)
            out.push(curve.move(ci.end))
            if ci.arc { out += _emit-rev(ci.second) }
            out += cap-at(start, start-cap, true)
            let co = outer.at(start)
            if co.arc {
              out.push(curve.line(co.mid))
              out += _emit(co.second)
            }
          }

          let cur = _next-cw.at(start)
          while cur != end {
            let co = outer.at(cur)
            if co.arc {
              out.push(curve.line(co.start))
              out += _emit(co.full)
            } else { out.push(curve.line(co.pt)) }
            cur = _next-cw.at(cur)
          }

          if start == end {
            let co = outer.at(end)
            if co.arc {
              out.push(curve.line(co.start))
              out += _emit(co.full)
            } else {
              out.push(curve.line(co.pt))
              out.push(curve.line(co.end))
            }
            let ci = inner.at(end)
            if ci.arc {
              out.push(curve.line(ci.end))
              out += _emit-rev(ci.full)
            } else { out.push(curve.line(ci.pt)) }
          } else {
            let co = outer.at(end)
            if co.arc {
              out.push(curve.line(co.start))
              out += _emit(co.first)
            } else { out.push(curve.line(co.pt)) }
            out += cap-at(end, end-cap, false)
            let ci = inner.at(end)
            if ci.arc {
              out.push(curve.line(ci.mid))
              out += _emit-rev(ci.first)
            }
          }

          let cur = _next-ccw.at(end)
          while cur != start {
            let ci = inner.at(cur)
            if ci.arc {
              out.push(curve.line(ci.end))
              out += _emit-rev(ci.full)
            } else { out.push(curve.line(ci.pt)) }
            cur = _next-ccw.at(cur)
          }

          out + (curve.close(mode: "straight"),)
        }

        let below = ()
        let above = ()
        if fill != none {
          // Fill follows the middle outline.
          let fill-path = {
            let c = mid.top-left
            let out = if c.arc {
              (curve.move(c.start),) + _emit(c.full)
            } else { (curve.move(c.pt),) }
            for corner in ("top-right", "bottom-right", "bottom-left") {
              let c = mid.at(corner)
              if c.arc {
                out += (curve.line(c.start),) + _emit(c.full)
              } else { out += (curve.line(c.pt),) }
            }
            out + (curve.close(mode: "straight"),)
          }
          below.push((fill: fill, stroke: none, elems: fill-path))
        }
        // Render stroked runs under filled runs.
        for s in segs {
          if s.ring {
            above.push((
              fill: s.stroke.paint,
              stroke: none,
              elems: fill-segment(s.start, s.end, s.start-cap, s.end-cap),
            ))
          } else {
            below.push((
              fill: none,
              stroke: s.stroke,
              elems: stroke-segment(s.start, s.end),
            ))
          }
        }
        below + above
      }

      let drawn = shapes.map(s => place(
        top + left,
        dx: -outs.left,
        dy: -outs.top,
        curve(fill: s.fill, stroke: s.stroke, ..s.elems),
      ))

      box(
        width: w,
        height: h,
        drawn.join() + box(width: 100%, height: 100%, inset: ins, body),
      )
    }

    if type(height) == fraction {
      // Fractional heights resolve within container layout.
      block(
        width: w,
        height: height,
        spacing: 0pt,
        block(
          width: 100%,
          height: 100%,
          spacing: 0pt,
          layout(inner => draw(w, inner.height)),
        ),
      )
    } else {
      // Height resolved after width layout.
      let h = if height != auto {
        resolve-size(height, ch)
      } else if body == none {
        calc.min(30pt, ch)
      } else if measured != none {
        // Reuse cached measurement.
        _resolve-auto-dim(measured.height, ins.top, ins.bottom)
      } else {
        let inner-w = calc.max(
          0pt,
          w - _resolve-scalar(ins.left, w) - _resolve-scalar(ins.right, w),
        )
        _resolve-auto-dim(
          measure(body, width: inner-w).height,
          ins.top,
          ins.bottom,
        )
      }
      draw(w, h)
    }
  })
}

