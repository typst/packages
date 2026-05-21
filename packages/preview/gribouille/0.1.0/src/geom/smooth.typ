///! Smoothed trend line with optional confidence ribbon.
///!
///! v1 supports `method: "lm"` only (ordinary least squares, closed-form). The
///! underlying fit is computed by \@stat-smooth, which also returns the
///! pointwise confidence band drawn when `se: true`.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../theme/theme.typ": geom-colour-default, geom-defaults
#import "../utils/aes-resolve.typ": resolve-channel
#import "../stat/smooth.typ": stat-smooth
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/colour-resolve.typ": apply-alpha
#import "../utils/aes-pair.typ": aes-set
#import "../utils/radial.typ": project-point

/// Fitted trend line with an optional confidence ribbon.
///
/// Fits a smoother to `(x, y)` and draws the prediction as a line. When
/// `se` is `true`, the pointwise band is drawn underneath the line.
///
/// \@category Geoms
/// \@subcategory Areas and ribbons
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param method Smoother method. `"lm"` is the only supported value in v1.
///
/// \@param se Whether to draw the confidence ribbon around the fit.
///
/// \@param level Confidence level for the ribbon (e.g., `0.95`).
///
/// \@param stroke Line thickness (a Typst length).
///
/// \@param colour Fixed line colour. `auto` picks a neutral default.
///
/// \@param fill Fixed ribbon fill. `auto` reuses the line colour.
///
/// \@param alpha Ribbon opacity in `[0, 1]`.
///
/// \@param linetype Dash keyword for the fitted line. `auto` resolves via the linetype scale or defaults to `"solid"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Linear fit through points with the default 95% confidence band.
/// ```
/// //| alt: "Scatter of 20 noisy linear points with a linear-model fit line and a translucent 95% confidence ribbon around it."
/// #let d = range(0, 20).map(i => (
///   x: i,
///   y: i * 0.5 + calc.sin(i * 0.4) * 2,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-smooth(method: "lm"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Disable the ribbon with `se: false` for a cleaner trend overlay.
/// ```
/// //| alt: "Scatter of 20 noisy linear points overlaid with a thicker linear-model fit line and no confidence ribbon."
/// #let d = range(0, 20).map(i => (
///   x: i,
///   y: i * 0.5 + calc.sin(i * 0.4) * 2,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-smooth(method: "lm", se: false, stroke: 1.4pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Per-species linear fits on the penguins data: mapping
/// `colour` splits the smoother into one trend per group.
/// ```
/// //| alt: "Penguin scatter of flipper length against body mass with per-species linear fits and translucent confidence ribbons."
/// #plot(
///   data: penguins,
///   mapping: aes(
///     x: "flipper-len",
///     y: "body-mass",
///     colour: "species",
///     fill: "species",
///   ),
///   layers: (
///     geom-point(size: 2pt, alpha: 0.6),
///     geom-smooth(method: "lm", alpha: 0.2),
///   ),
///   labs: labs(
///     x: "Flipper Length (mm)",
///     y: "Body Mass (g)",
///     colour: "Species",
///     fill: "Species",
///   ),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@stat-smooth, \@geom-line, \@geom-ribbon
#let geom-smooth(
  mapping: none,
  data: none,
  method: "lm",
  se: true,
  level: 0.95,
  stroke: auto,
  colour: auto,
  fill: auto,
  alpha: auto,
  linetype: auto,
  inherit-aes: true,
) = make-layer(
  "smooth",
  mapping: mapping,
  data: data,
  params: (
    method: method,
    se: se,
    level: level,
    stroke: stroke,
    colour: colour,
    fill: fill,
    alpha: alpha,
    linetype: linetype,
  ),
  stat: stat-smooth(method: method, se: se, level: level),
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  if x-col == none or y-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let colour-col = mapping.at("colour", default: none)
  let fill-col = mapping.at("fill", default: none)
  let colour-trained = ctx.trained.at("colour", default: none)
  let fill-trained = ctx.trained.at("fill", default: none)

  let colour-pinned = layer.params.colour != auto
  let fill-pinned = layer.params.fill != auto
  // Exclusive-default rule: when only `fill` is set, the line is suppressed.
  let suppress-line = (
    aes-set(layer, mapping, "fill") and not aes-set(layer, mapping, "colour")
  )
  let default-colour = if colour-pinned {
    layer.params.colour
  } else {
    geom-colour-default(geom-defaults(ctx.theme), role: "accent")
  }

  // Partition by group key (scale-aware: only discrete aesthetics group).
  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    let rows = g.data
    let sorted = rows
      .map(row => (
        x: parse-number(row.at(x-col, default: none)),
        y: parse-number(row.at(y-col, default: none)),
        lo: parse-number(row.at(
          mapping.at("ymin", default: ""),
          default: none,
        )),
        hi: parse-number(row.at(
          mapping.at("ymax", default: ""),
          default: none,
        )),
      ))
      .filter(p => p.x != none and p.y != none)
      .sorted(key: p => p.x)

    if sorted.len() < 2 { continue }

    let line-colour = if colour-pinned {
      layer.params.colour
    } else if colour-col != none and colour-trained != none {
      let sample = rows.first().at(colour-col, default: none)
      ((ctx.resolve-colour)(colour-trained, ctx.palette))(sample)
    } else { default-colour }

    let ribbon-colour = if fill-pinned {
      layer.params.fill
    } else if fill-col != none and fill-trained != none {
      let sample = rows.first().at(fill-col, default: none)
      ((ctx.resolve-colour)(fill-trained, ctx.palette))(sample)
    } else { line-colour }

    // Confidence ribbon first, so the line draws on top.
    let has-band = (
      layer.params.se and sorted.all(p => p.lo != none and p.hi != none)
    )
    if has-band {
      let upper = sorted.map(p => project-point(ctx, p.x, p.hi))
      let lower = sorted.rev().map(p => project-point(ctx, p.x, p.lo))
      let pts = upper + lower
      if pts.all(p => p != none) {
        let alpha = resolve-channel(
          "alpha",
          layer,
          mapping,
          ctx,
          rows.first(),
          0.2,
        )
        let band = apply-alpha(ribbon-colour, alpha)
        cetz.draw.line(..pts, close: true, fill: band, stroke: none)
      }
    }

    let line-pts = sorted
      .map(p => project-point(ctx, p.x, p.y))
      .filter(p => p != none)
    if line-pts.len() >= 2 and not suppress-line {
      let thickness = resolve-channel(
        "linewidth",
        layer,
        mapping,
        ctx,
        rows.first(),
        1pt,
      )
      let dash = resolve-channel(
        "linetype",
        layer,
        mapping,
        ctx,
        rows.first(),
        none,
      )
      cetz.draw.line(
        ..line-pts,
        stroke: (paint: line-colour, thickness: thickness, dash: dash),
      )
    }
  }
}
