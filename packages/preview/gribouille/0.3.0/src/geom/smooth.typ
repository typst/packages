///! Smoothed trend line with optional confidence ribbon.
///!
///! v1 supports `method: "lm"` only (ordinary least squares, closed-form). The
///! underlying fit is computed by \@stat-smooth, which also returns the
///! pointwise confidence band drawn when `se: true`.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults
#import "../utils/aes-resolve.typ": resolve-channel
#import "../stat/smooth.typ": stat-smooth
#import "../utils/types.typ": parse-number
#import "../utils/group.typ": partition-by-group
#import "../utils/colour-resolve.typ": apply-alpha
#import "../utils/aes-pair.typ": aes-set
#import "../utils/radial.typ": project-point
#import "../utils/band.typ": band-polygon
#import "../utils/late-binding.typ": after-scale-source, apply-after-scale
#import "../scale/train.typ": mapping-ref-col

/// Fitted trend line with an optional confidence ribbon.
///
/// Fits a smoother to `(x, y)` and draws the prediction as a line. When `se` is `true`, the pointwise band is drawn underneath the line.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - method: Smoother method. `"lm"` is the only supported value in v1.
/// - se: Whether to draw the confidence ribbon around the fit.
/// - level: Confidence level for the ribbon (e.g., `0.95`).
/// - stroke: Line thickness (a Typst length).
/// - colour: Fixed line colour. `auto` picks a neutral default.
/// - fill: Fixed ribbon fill. `auto` reuses the line colour.
/// - alpha: Ribbon opacity in `[0, 1]`.
/// - linetype: Dash keyword for the fitted line. `auto` resolves via the linetype scale or defaults to `"solid"`.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `stat-smooth`, `geom-line`, `geom-ribbon`.
///
/// Linear fit through points with the default 95% confidence band.
///
/// ```typst
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
/// Disable the ribbon with `se: false` for a cleaner trend overlay.
///
/// ```typst
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
/// Per-species linear fits on the penguins data: mapping `colour` splits the smoother into one trend per group.
///
/// ```typst
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

  let colour-spec = mapping.at("colour", default: none)
  let fill-spec = mapping.at("fill", default: none)
  let colour-col = mapping-ref-col(after-scale-source(colour-spec))
  let fill-col = mapping-ref-col(after-scale-source(fill-spec))
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
    resolve-geom-colour(resolve-geom-defaults(ctx.theme), role: "accent")
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

    let leader = rows.first()
    let line-base = if colour-pinned {
      layer.params.colour
    } else if colour-col != none and colour-trained != none {
      ((ctx.resolve-colour)(colour-trained, ctx.palette))(
        leader.at(colour-col, default: none),
      )
    } else { default-colour }
    let line-colour = apply-after-scale(line-base, colour-spec, ctx, leader)

    let fill-base = if fill-pinned {
      layer.params.fill
    } else if fill-col != none and fill-trained != none {
      ((ctx.resolve-colour)(fill-trained, ctx.palette))(
        leader.at(fill-col, default: none),
      )
    } else { line-colour }
    let ribbon-colour = apply-after-scale(fill-base, fill-spec, ctx, leader)

    // Confidence ribbon first, so the line draws on top.
    let has-band = (
      layer.params.se and sorted.all(p => p.lo != none and p.hi != none)
    )
    if has-band {
      let pts = band-polygon(ctx, sorted, p => p.hi, p => p.lo)
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
