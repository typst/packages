// Shared draw path for `geom-hline` and `geom-vline`.
//
// `user-axis` is the axis the intercept refers to in the user's coordinate
// system: `"y"` for hline (intercepts on the y axis), `"x"` for vline.
// Under `coord-flip` the trained scale carrying that user axis sits on the
// opposite renderer axis, so the helper consults the swapped trained slot.
//
// When the layer maps the intercept channel (`aes(xintercept: "col")` for
// vline, `aes(yintercept: "col")` for hline) the helper draws one line per
// data row, resolving colour/alpha/linewidth/linetype per row. Otherwise it
// draws from the scalar/array `intercepts` parameter with a single stroke.

#import "../deps.typ": cetz
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../scale/train.typ": map-axis-data
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

#let _draw-axis-lines(intercepts, user-axis, layer, ctx) = {
  let flipped = ctx.at("flipped", default: false)
  let trained-axis = if flipped {
    if user-axis == "x" { "y" } else { "x" }
  } else { user-axis }
  let trained = ctx.trained.at(trained-axis, default: none)
  if trained == none or trained.type != "continuous" { return }

  let raw-mapping = (ctx.resolve-mapping)(layer)
  let mapping = if raw-mapping == none { (:) } else { raw-mapping }
  let channel = if user-axis == "x" { "xintercept" } else { "yintercept" }
  let mapped-col = mapping.at(channel, default: none)

  let theme-ink = resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  let _stroke-for(row) = (
    paint: resolve-channel("colour", layer, mapping, ctx, row, theme-ink),
    thickness: resolve-channel("linewidth", layer, mapping, ctx, row, 0.6pt),
    dash: resolve-channel("linetype", layer, mapping, ctx, row, "solid"),
  )

  // Each entry pairs an intercept value with the stroke spec to draw it with.
  // Mapped: one entry per data row, per-row stroke. Unmapped: the scalar or
  // array parameter, all sharing a single stroke resolved from an empty row.
  // `parse-number` resolves ISO date/datetime/time strings to the numeric
  // value the active scale trains against; unparseable values are dropped.
  let lines = if mapped-col != none {
    let data = (ctx.resolve-data)(layer)
    data
      .map(row => {
        let v = parse-number(row.at(mapped-col, default: none))
        if v == none { none } else {
          (value: v, stroke: _stroke-for(row))
        }
      })
      .filter(entry => entry != none)
  } else {
    let values = if intercepts == none {
      ()
    } else if type(intercepts) == array { intercepts } else { (intercepts,) }
    let stroke = _stroke-for((:))
    values
      .map(v => {
        let n = parse-number(v)
        if n == none { none } else { (value: n, stroke: stroke) }
      })
      .filter(entry => entry != none)
  }
  if lines.len() == 0 { return }

  let radial = ctx.at("radial", default: none)
  if radial != none {
    let (cx, cy) = radial.centre
    let r-max = radial.r-max
    let on-theta = radial.theta-axis == user-axis
    for line in lines {
      if on-theta {
        let theta = map-axis-data(trained, line.value, radial.theta-range)
        cetz.draw.line(
          (cx, cy),
          (cx + r-max * calc.cos(theta), cy + r-max * calc.sin(theta)),
          stroke: line.stroke,
        )
      } else {
        let r = map-axis-data(trained, line.value, radial.r-range)
        if r > 0 and r <= r-max {
          cetz.draw.circle(
            (cx, cy),
            radius: r,
            fill: none,
            stroke: line.stroke,
          )
        }
      }
    }
    return
  }

  // Cartesian: hline draws horizontal segments unless flipped; vline draws
  // vertical segments unless flipped. Either way, the drawn axis matches the
  // user's mental model after coord-flip.
  let horizontal = (user-axis == "y") != flipped
  if horizontal {
    let (px-lo, px-hi) = ctx.px-range
    for line in lines {
      let cy = map-axis-data(trained, line.value, ctx.py-range)
      cetz.draw.line((px-lo, cy), (px-hi, cy), stroke: line.stroke)
    }
  } else {
    let (py-lo, py-hi) = ctx.py-range
    for line in lines {
      let cx = map-axis-data(trained, line.value, ctx.px-range)
      cetz.draw.line((cx, py-lo), (cx, py-hi), stroke: line.stroke)
    }
  }
}
