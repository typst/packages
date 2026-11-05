// Shared draw path for `geom-errorbar` and `geom-errorbarh`.
//
// `axis` selects which axis the bar's length spans:
//   "y" → vertical bar (errorbar): centre column = x, span columns = ymin/ymax
//   "x" → horizontal bar (errorbarh): centre column = y, span columns = xmin/xmax
// `cap-extent` is the user's `width:` (errorbar) or `height:` (errorbarh):
// either a Typst length (cap span in panel units) or a number (data units for
// continuous centre axis, fraction of slot for discrete).

#import "../deps.typ": cetz
#import "../position/apply.typ": layer-position-name
#import "../position/dodge.typ": dodge-centre, dodge-geometry, dodge-half
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/linetype-resolve.typ": resolve-linetype
#import "../coord/project.typ": axis-mapper, project-uvs
#import "../utils/band.typ": axis-band
#import "../utils/flip.typ": user-axis-key
#import "../utils/radial.typ": polar-canvas, radial-arc, radial-tangent-cap
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": apply-alpha
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

// Caps for a numeric cap extent under coord-radial. `band` is the cap span on
// the centre axis and `ends` the two span ends, each in the polar range of its
// axis. A centre on theta gives a spoke spine, so each cap is an arc at the
// radius of its end. A centre on the radius gives an arc spine, so each cap is
// a radial tick at the angle of its end, and stops at the centre.
#let _draw-radial-band-caps(
  radial,
  band,
  centre-is-theta,
  ends,
  stroke-spec,
) = {
  let (lo, hi) = band
  for end in ends {
    if centre-is-theta {
      cetz.draw.line(..radial-arc(lo, hi, end, radial), stroke: stroke-spec)
    } else {
      cetz.draw.line(
        polar-canvas(radial, end, calc.max(0, lo)),
        polar-canvas(radial, end, calc.max(0, hi)),
        stroke: stroke-spec,
      )
    }
  }
}

#let _draw-errorbar-axis(layer, ctx, axis, cap-extent) = {
  // Under coord-flip the mapping swap carries the span onto the other axis,
  // so an errorbar draws as a horizontal bar and an errorbarh as a vertical one.
  axis = user-axis-key(axis, ctx)
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let centre-axis = if axis == "y" { "x" } else { "y" }
  let centre-col = mapping.at(centre-axis, default: none)
  let span-min-col = mapping.at(axis + "min", default: none)
  let span-max-col = mapping.at(axis + "max", default: none)
  if centre-col == none or span-min-col == none or span-max-col == none {
    return
  }
  let centre-trained = ctx.trained.at(centre-axis, default: none)
  let span-trained = ctx.trained.at(axis, default: none)
  if centre-trained == none or span-trained == none { return }

  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))

  let extent-is-length = type(cap-extent) == length
  let half = if extent-is-length {
    (cap-extent / 1cm) / 2
  } else { cap-extent / 2 }

  let centre-range = (ctx.coord.axis-range)(ctx, centre-axis)
  let position-name = layer-position-name(layer)
  // The shared dodge slot is measured on the user's x. A bar whose centre sits
  // on the other axis, as for errorbarh, dodges within its own cap band.
  let dodge = dodge-geometry(ctx, layer)
  if dodge != none and dodge.axis != (if centre-axis == "x" { 0 } else { 1 }) {
    dodge = none
  }
  let map-centre = axis-mapper(ctx, centre-axis)
  let map-span = axis-mapper(ctx, axis)
  let radial = ctx.at("radial", default: none)
  let centre-is-theta = radial != none and radial.theta-axis == centre-axis

  for row in data {
    let raw-centre = row.at(centre-col, default: none)
    let centre-c = map-centre(raw-centre)
    let lo = parse-number(row.at(span-min-col, default: none))
    let hi = parse-number(row.at(span-max-col, default: none))
    if centre-c == none or lo == none or hi == none { continue }
    let span-lo = map-span(lo)
    let span-hi = map-span(hi)
    if span-lo == none or span-hi == none { continue }

    let colour = resolve-channel(
      "colour",
      layer.params,
      mapping,
      ctx,
      row,
      theme-colour,
    )
    let alpha = resolve-channel("alpha", layer.params, mapping, ctx, row, 1)
    let final-colour = apply-alpha(colour, alpha)
    let thickness = resolve-channel(
      "linewidth",
      layer.params,
      mapping,
      ctx,
      row,
      0.8pt,
    )

    let stroke-spec = (
      paint: final-colour,
      thickness: thickness,
      dash: resolve-linetype(layer.params, mapping, ctx, row),
    )

    if radial != none {
      // Dodge moves the centre before projection, so the spine follows the
      // polar grid from its slot. As on the cartesian path, a Typst-length cap
      // has no slot to dodge within.
      let band = if extent-is-length { none } else {
        axis-band(centre-trained, raw-centre, half, centre-range)
      }
      if position-name == "dodge" and band != none {
        let cap-span = band.at(1) - band.at(0)
        centre-c = dodge-centre(dodge, row, centre-c, cap-span)
        let half = dodge-half(row, cap-span / 2)
        band = (centre-c - half, centre-c + half)
      }
      let uvs = if axis == "y" {
        ((centre-c, span-lo), (centre-c, span-hi))
      } else {
        ((span-lo, centre-c), (span-hi, centre-c))
      }
      let path = project-uvs(ctx, uvs)
      cetz.draw.line(..path, stroke: stroke-spec)
      if not extent-is-length {
        if band != none {
          _draw-radial-band-caps(
            radial,
            band,
            centre-is-theta,
            (span-lo, span-hi),
            stroke-spec,
          )
        }
        continue
      }
      let (cx, cy) = radial.centre
      // Each cap is perpendicular to the spine at its own end: radial on an
      // arc, tangent on a spoke. A radial cap stops at the centre rather than
      // cross it.
      for (end, next) in (
        (path.first(), path.at(1)),
        (path.last(), path.at(-2)),
      ) {
        let cap = radial-tangent-cap(end, next, half)
        if cap == none { continue }
        let (sx, sy) = end
        let (nx, ny) = cap
        let tips = ((sx - nx, sy - ny), (sx + nx, sy + ny)).map(((x, y)) => {
          let crosses = (x - cx) * (sx - cx) + (y - cy) * (sy - cy) < 0
          if crosses { (cx, cy) } else { (x, y) }
        })
        cetz.draw.line(..tips, stroke: stroke-spec)
      }
      continue
    }

    let (cap-lo, cap-hi) = if extent-is-length {
      (centre-c - half, centre-c + half)
    } else {
      let band = axis-band(centre-trained, raw-centre, half, centre-range)
      if band == none { (centre-c, centre-c) } else { band }
    }

    // Dodge shifts the centre and shrinks the cap by the dodge slot count.
    // Only the band-derived path has a meaningful "bucket" to dodge within;
    // a pinned Typst-length cap has no relation to the discrete slot, so
    // dodge is left as a no-op there.
    if position-name == "dodge" and not extent-is-length {
      let cap-span = cap-hi - cap-lo
      centre-c = dodge-centre(dodge, row, centre-c, cap-span)
      let half = dodge-half(row, cap-span / 2)
      cap-lo = centre-c - half
      cap-hi = centre-c + half
    }

    if axis == "y" {
      cetz.draw.line(
        (centre-c, span-lo),
        (centre-c, span-hi),
        stroke: stroke-spec,
      )
      cetz.draw.line((cap-lo, span-lo), (cap-hi, span-lo), stroke: stroke-spec)
      cetz.draw.line((cap-lo, span-hi), (cap-hi, span-hi), stroke: stroke-spec)
    } else {
      cetz.draw.line(
        (span-lo, centre-c),
        (span-hi, centre-c),
        stroke: stroke-spec,
      )
      cetz.draw.line((span-lo, cap-lo), (span-lo, cap-hi), stroke: stroke-spec)
      cetz.draw.line((span-hi, cap-lo), (span-hi, cap-hi), stroke: stroke-spec)
    }
  }
}
