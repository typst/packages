// Shared draw path for `geom-hline` and `geom-vline`.
//
// `user-axis` is the axis the intercept refers to in the user's coordinate
// system: `"y"` for hline (intercepts on the y axis), `"x"` for vline.
// Under `coord-flip` the trained scale carrying that user axis sits on the
// opposite renderer axis, so the helper consults the swapped trained slot.

#import "../deps.typ": cetz
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-axis-data
#import "../utils/colour-resolve.typ": apply-alpha
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

#let _draw-axis-lines(intercepts, user-axis, layer, ctx) = {
  let flipped = ctx.at("flipped", default: false)
  let trained-axis = if flipped {
    if user-axis == "x" { "y" } else { "x" }
  } else { user-axis }
  let trained = ctx.trained.at(trained-axis, default: none)
  if trained == none or trained.type != "continuous" { return }

  let values = if intercepts == none {
    return
  } else if type(intercepts) == array { intercepts } else { (intercepts,) }
  if values.len() == 0 { return }

  let colour = if layer.params.colour == auto {
    resolve-geom-colour(resolve-geom-defaults(ctx.theme))
  } else { layer.params.colour }
  let mapping = (ctx.resolve-mapping)(layer)
  let alpha = resolve-channel("alpha", layer, mapping, ctx, (:), 1)
  let fill = apply-alpha(colour, alpha)
  let thickness = resolve-channel(
    "linewidth",
    layer,
    mapping,
    ctx,
    (:),
    0.6pt,
  )
  let stroke-spec = (
    paint: fill,
    thickness: thickness,
    dash: layer.params.linetype,
  )

  let radial = ctx.at("radial", default: none)
  if radial != none {
    let (cx, cy) = radial.centre
    let r-max = radial.r-max
    let on-theta = radial.theta-axis == user-axis
    for v in values {
      if on-theta {
        let theta = map-axis-data(trained, float(v), radial.theta-range)
        cetz.draw.line(
          (cx, cy),
          (cx + r-max * calc.cos(theta), cy + r-max * calc.sin(theta)),
          stroke: stroke-spec,
        )
      } else {
        let r = map-axis-data(trained, float(v), radial.r-range)
        if r > 0 and r <= r-max {
          cetz.draw.circle(
            (cx, cy),
            radius: r,
            fill: none,
            stroke: stroke-spec,
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
    for v in values {
      let cy = map-axis-data(trained, float(v), ctx.py-range)
      cetz.draw.line((px-lo, cy), (px-hi, cy), stroke: stroke-spec)
    }
  } else {
    let (py-lo, py-hi) = ctx.py-range
    for v in values {
      let cx = map-axis-data(trained, float(v), ctx.px-range)
      cetz.draw.line((cx, py-lo), (cx, py-hi), stroke: stroke-spec)
    }
  }
}
