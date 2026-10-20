///! Vertical range from `ymin` to `ymax` at each `x`.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../utils/types.typ": parse-number
#import "../utils/radial.typ": project-point
#import "../theme/theme.typ": geom-colour-default, geom-defaults

/// Linerange layer: one vertical line from `ymin` to `ymax` at each `x`.
///
/// Mapping must provide `x`, `ymin`, `ymax`. Colour and linetype may be
/// mapped or set as fixed layer parameters.
///
/// \@category Geoms
/// \@subcategory Intervals and errors
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Must map `x`, `ymin`, `ymax`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param stroke Line thickness (a Typst length).
///
/// \@param colour Fixed line colour. `auto` resolves via the colour scale.
///
/// \@param alpha Line opacity in `[0, 1]`.
///
/// \@param linetype Dash keyword. Defaults to `"solid"`.
///
/// \@param stat Statistical transform name. Usually `"identity"`.
///
/// \@param position Position adjustment name. Usually `"identity"`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Bare vertical ranges, no end caps.
/// ```
/// //| alt: "Five vertical line ranges at x = 1 to 5 spanning lo to hi on the y axis with no end caps."
/// #let d = range(1, 6).map(i => (
///   x: i,
///   lo: i - 0.5,
///   hi: i + 0.5,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi"),
///   layers: (geom-linerange(stroke: 1pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Map `colour` to a categorical column to differentiate ranges
/// per group.
/// ```
/// //| alt: "Five vertical line ranges at x = 1 to 5 spanning lo to hi on y coloured by even/odd category via the colour aesthetic."
/// #let d = range(1, 6).map(i => (
///   x: i, lo: i - 0.5, hi: i + 0.5,
///   k: if calc.rem(i, 2) == 0 { "even" } else { "odd" },
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", ymin: "lo", ymax: "hi", colour: "k"),
///   layers: (geom-linerange(stroke: 1.2pt),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-errorbar, \@geom-pointrange
#let geom-linerange(
  mapping: none,
  data: none,
  stroke: auto,
  colour: auto,
  alpha: auto,
  linetype: "solid",
  stat: "identity",
  position: "identity",
  inherit-aes: true,
) = make-layer(
  "linerange",
  mapping: mapping,
  data: data,
  params: (stroke: stroke, colour: colour, alpha: alpha, linetype: linetype),
  stat: stat,
  position: position,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let ymin-col = mapping.at("ymin", default: none)
  let ymax-col = mapping.at("ymax", default: none)
  if x-col == none or ymin-col == none or ymax-col == none { return }
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }

  let theme-colour = geom-colour-default(geom-defaults(ctx.theme))

  for row in data {
    let xv = row.at(x-col, default: none)
    let lo = parse-number(row.at(ymin-col, default: none))
    let hi = parse-number(row.at(ymax-col, default: none))
    if xv == none or lo == none or hi == none { continue }
    let p-lo = project-point(ctx, xv, lo)
    let p-hi = project-point(ctx, xv, hi)
    if p-lo == none or p-hi == none { continue }
    let (cx-lo, cy-lo) = p-lo
    let (cx-hi, cy-hi) = p-hi

    let final-colour = resolve-channel(
      "colour",
      layer,
      mapping,
      ctx,
      row,
      theme-colour,
    )

    let thickness = resolve-channel(
      "linewidth",
      layer,
      mapping,
      ctx,
      row,
      0.8pt,
    )
    cetz.draw.line(
      (cx-lo, cy-lo),
      (cx-hi, cy-hi),
      stroke: (
        paint: final-colour,
        thickness: thickness,
        dash: layer.params.linetype,
      ),
    )
  }
}
