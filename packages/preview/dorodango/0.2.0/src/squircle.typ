#import "validation.typ": *
#import "dictionaries.typ": *
#import "geometry.typ": *
#import "corners.typ": *

/// Draws a rectangle with smoothly rounded corners.
///
/// Use `squircle` like `rect` when you want softer, more continuous corner
/// transitions. With `smoothing: 0%`, it has the same geometry as a rounded
/// `rect`.
///
/// -> content
#let squircle(
  /// The squircle's width, relative to its parent container.
  /// -> auto | length | ratio | relative
  width: auto,
  /// The squircle's height, relative to its parent container.
  /// -> auto | length | ratio | relative | fraction
  height: auto,
  /// How to fill the squircle.
  ///
  /// When setting a fill, the default stroke disappears. To create a squircle
  /// with both fill and stroke, you have to configure both.
  /// -> none | color | gradient | tiling
  fill: none,
  /// How to stroke the squircle. This can be:
  ///
  /// - `none` to disable stroking.
  /// - `auto` for a stroke of `1pt + black` if and only if no fill is given.
  /// - Any kind of stroke.
  /// - A dictionary describing the stroke for each side individually. The
  ///   dictionary can contain the following keys in order of precedence:
  ///   - `top`: The top stroke.
  ///   - `right`: The right stroke.
  ///   - `bottom`: The bottom stroke.
  ///   - `left`: The left stroke.
  ///   - `x`: The left and right stroke.
  ///   - `y`: The top and bottom stroke.
  ///   - `rest`: The stroke on all sides except those for which the dictionary
  ///     explicitly sets a stroke.
  ///
  /// All keys are optional. Omitted sides are not stroked.
  /// -> auto | none | length | color | gradient | tiling | stroke | dictionary
  stroke: auto,
  /// How much to round the squircle's corners, relative to the minimum of the
  /// width and height divided by two. This can be:
  ///
  /// - A relative length for a uniform corner radius.
  /// - A dictionary describing the radius for each corner individually. The
  ///   dictionary can contain the following keys in order of precedence:
  ///   - `top-left`: The top-left corner radius.
  ///   - `top-right`: The top-right corner radius.
  ///   - `bottom-right`: The bottom-right corner radius.
  ///   - `bottom-left`: The bottom-left corner radius.
  ///   - `left`: The top-left and bottom-left corner radii.
  ///   - `top`: The top-left and top-right corner radii.
  ///   - `right`: The top-right and bottom-right corner radii.
  ///   - `bottom`: The bottom-left and bottom-right corner radii.
  ///   - `rest`: The radii for all corners except those for which the
  ///     dictionary explicitly sets a radius.
  /// -> length | ratio | relative | dictionary
  radius: 0pt,
  /// How much to pad the squircle's content. See `box`'s `inset` parameter for
  /// more details.
  /// -> length | ratio | relative | dictionary
  inset: 5pt,
  /// How much to expand the squircle's size without affecting the layout. See
  /// `box`'s `outset` parameter for more details.
  /// -> length | ratio | relative | dictionary
  outset: 0pt,
  /// How strongly to smooth the squircle's corners. Smoothing replaces the
  /// ends of each circular corner arc with Bézier transitions whose curvature
  /// gradually changes between the straight edges and the arc. This can be:
  ///
  /// - A relative length for uniform corner smoothing.
  /// - A dictionary describing the smoothing for each corner individually. The
  ///   dictionary can contain the following keys in order of precedence:
  ///   - `top-left`: The top-left corner smoothing.
  ///   - `top-right`: The top-right corner smoothing.
  ///   - `bottom-right`: The bottom-right corner smoothing.
  ///   - `bottom-left`: The bottom-left corner smoothing.
  ///   - `left`: The top-left and bottom-left corner smoothing.
  ///   - `top`: The top-left and top-right corner smoothing.
  ///   - `right`: The top-right and bottom-right corner smoothing.
  ///   - `bottom`: The bottom-left and bottom-right corner smoothing.
  ///   - `rest`: The smoothing for all corners except those for which the
  ///     dictionary explicitly sets smoothing.
  ///
  /// At `0%`, the corner is a quarter circle matching a rounded `rect`. At
  /// `100%`, it is two Bézier transitions with no circular arc.
  /// -> length | ratio | relative | dictionary
  smoothing: 60%,
  /// Whether to preserve the requested smoothing when it exceeds a corner's
  /// available space. This has no effect when the smoothing already fits.
  ///
  /// If `false`, smoothing is reduced to fit, so further increases may not
  /// change the corner. If `true`, its arc and smoothing angles are retained by
  /// shortening Bézier handles, which can make the corner look compressed.
  /// -> bool
  preserve-smoothing: false,
  /// The content to place into the squircle. Strings and symbols are converted
  /// to content.
  ///
  /// When this is omitted, the squircle takes on a default size of at most
  /// `45pt` by `30pt`.
  /// -> none | content | str | symbol
  ..body,
) = {
  _validate-size("width", width)
  _validate-size("height", height, fraction-ok: true)
  _validate-fill(fill)
  stroke = _validate-stroke(stroke)
  _validate-relative-or-dict("radius", radius, _corner-keys)
  _validate-relative-or-dict("inset", inset, _side-keys)
  _validate-relative-or-dict("outset", outset, _side-keys)
  _validate-relative-or-dict("smoothing", smoothing, _corner-keys)
  _expect("preserve-smoothing", preserve-smoothing, (bool,), "boolean")
  body = _validate-body(body)

  // Sides left out of a dictionary fall back to the parameter default, as
  // `rect`'s folding fields do: `inset: (top: 20pt)` still pads the rest 5pt.
  let ins = _resolve-edges(inset, default: 5pt)
  let base-outs = _resolve-edges(outset, default: 0pt)
  let radius-corners = _resolve-corners(radius, default: 0pt)
  let smoothing-corners = _resolve-corners(smoothing, default: 60%)

  // What `rect` strokes each side with, `auto` resolved.
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

  // Precompute argument-dependent values outside `draw`.

  // Half thicknesses, `none` where a side is unstroked. `radius` is the radius
  // of the stroke's outer edge, so the stroked outline is pulled in by one.
  let half = sides
    .pairs()
    .map(((k, v)) => (k, if v == none { none } else { v.thickness / 2 }))
    .to-dict()

  // Resolving against a literal `1pt` makes this a plain 0-to-1 factor.
  let smoothings = _corner-order
    .map(c => (
      c,
      calc.max(
        0.0,
        calc.min(1.0, _resolve-scalar(smoothing-corners.at(c), 1pt) / 1pt),
      ),
    ))
    .to-dict()

  // The two strokes meeting at a corner are drawn as one piece only if they
  // agree. Otherwise the outline is cut open there.
  let same = _corner-order
    .map(c => (
      c,
      _same-stroke(sides.at(_side-ccw.at(c)), sides.at(_side-cw.at(c))),
    ))
    .to-dict()

  // Clockwise runs of sides sharing a pen, cut at each pen-change corner.
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

  // Everything about a run except whether its corners are too tight for the
  // pen, which needs the resolved size. Unstroked runs drop out here.
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

  // Corners where an outline is cut in two, so `_piece` can skip the halves
  // everywhere else. A single closed run is cut nowhere.
  let split-corners = ()
  for s in segments {
    if s.start != s.end {
      for c in (s.start, s.end) {
        if c not in split-corners { split-corners.push(c) }
      }
    }
  }

  // `layout`'s closure is already contextual, so `measure` needs no `context`.
  layout(container-size => {
    let cw = container-size.width
    let ch = container-size.height
    let unbounded(l) = calc.abs(l / 1pt) == calc.inf

    // In an unbounded region `rect` resolves a ratio to zero and keeps only
    // the absolute part of a `relative`.
    let resolve-size(val, basis) = {
      if not unbounded(basis) { _resolve-scalar(val, basis) } else if (
        type(val) == ratio
      ) { 0pt } else if type(val) == relative { val.length } else { val }
    }

    // `measure(body, width: X)` returns tight width `<= X`. Keep the result for
    // auto-height at that width.
    let (w, measured) = if width != auto {
      (resolve-size(width, cw), none)
    } else if body == none {
      // `rect`'s body-less default is `Size::new(45pt, 30pt).min(region.size)`.
      (calc.min(45pt, cw), none)
    } else if unbounded(cw) {
      // Nothing can line-break in an unbounded region, so there is no fixed
      // point to solve.
      let m = measure(body)
      (_resolve-auto-dim(m.width, ins.left, ins.right), m)
    } else if type(ins.left) == length and type(ins.right) == length {
      // Absolute padding does not depend on the box width: lay the body out
      // once in what the region leaves, then add the padding back.
      let m = measure(body, width: calc.max(0pt, cw - ins.left - ins.right))
      (calc.min(m.width + ins.left + ins.right, cw), m)
    } else {
      // A ratio inset resolves against the box's own final size, so the box
      // width and the width fed to `measure` are mutually dependent.
      let w-fp = cw
      // Usually settles in a few steps. The cap catches the oscillation that
      // discrete line breaking can cause.
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

    // Everything below only needs the final box size, which for a fractional
    // height is not known until the shape sits in its region.
    let draw(w, h) = {
      // Outsets resolve against the box size (rect parity).
      let outs = (
        top: _resolve-scalar(base-outs.top, h),
        right: _resolve-scalar(base-outs.right, w),
        bottom: _resolve-scalar(base-outs.bottom, h),
        left: _resolve-scalar(base-outs.left, w),
      )
      let out-w = w + outs.left + outs.right
      let out-h = h + outs.top + outs.bottom

      // `rect` keeps a plain rectangle primitive here, and it is closed, so
      // corners are joined rather than capped.
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

        // Per-corner control points, following `rect`'s `ControlPoints`. The
        // two adjacent half thicknesses set how far the outer and inner edges
        // sit from the corner and how much radius each outline keeps.
        let base-radius = calc.min(calc.abs(out-w), calc.abs(out-h)) / 2
        let control = (:)
        for corner in _corner-order {
          let (edge-in, edge-out, ..) = _corner-geom.at(corner)
          let sb-opt = half.at(_side-ccw.at(corner))
          let sa-opt = half.at(_side-cw.at(corner))
          // A corner between two stroked sides may spend the thinner of them
          // on top of half the short side.
          let both = if sb-opt != none and sa-opt != none {
            calc.min(sb-opt, sa-opt)
          } else { 0pt }
          let corner-max = base-radius + both
          let r-outer = calc.min(
            _resolve-scalar(radius-corners.at(corner), corner-max * 2),
            corner-max,
          )
          // An unstroked side borrows its neighbor's half thickness, but only
          // while the radius is large enough for the cap to keep its shape.
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

        // Builds one rounded outline with its own points, radii, and budgets.
        // `splits` marks `rect` cuts from the outer point. Omitted corners stay whole.
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
          let budget = _budgets(radii, side-lens)
          let out = (:)
          for corner in _corner-order {
            out.insert(corner, _piece(
              corner,
              pts.at(corner),
              // Not `radii`: that is clamped for the budget, and `_piece`
              // needs a negative radius to pull a sharp corner inward.
              control.at(corner).at(r-key),
              _corner-params(
                radii.at(corner),
                smoothings.at(corner),
                budget.at(corner),
                preserve-smoothing,
              ),
              split: splits.at(corner, default: none),
            ))
          }
          out
        }

        // A corner has to be filled rather than stroked when the two pens
        // differ, or when the pen is wider than what is left of the radius.
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

        // A filled ring follows the outer and inner edges, a stroke and the
        // fill the middle one. Only what is read below gets built.
        let need-ring = segs.any(s => s.ring)
        let need-mid = fill != none or segs.any(s => not s.ring)

        // `rect` cuts middle and inner outlines radially toward the outer corner.
        // The outer cut is that ray's intersection with the outer arc.
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

        // One-pen middle-outline run. `rect` leaves it open, so sharp-corner
        // butt ends meet without filling the square between them.
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

        // Draw caps beside unstroked sides. Small radii keep butt ends to avoid
        // distortion.
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
            // Extended by the thickness of the stroke that ends here.
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

        // A run drawn as a filled ring: clockwise along the outer edge, then
        // back counter-clockwise along the inner one.
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
          // The fill stops in the middle of the stroke, so it follows the
          // middle outline.
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
        // Stroked runs go under the filled ones, as `rect` orders them.
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
      // `layout()` reports a fraction's region, not its resolved size. Nesting
      // under `100%` recovers the drawn height for ratio insets.
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
      // Laid out at the resolved width so wrapped text is accounted for, as
      // `rect` does before sizing to its content.
      let h = if height != auto {
        resolve-size(height, ch)
      } else if body == none {
        calc.min(30pt, ch)
      } else if measured != none {
        // Reuse the measurement at the final inner width.
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
