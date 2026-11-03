///! Marginal tick marks at observed x and / or y positions.
///!
///! Adds short ticks just outside the panel edges to expose the raw
///! distribution of one or both positional aesthetics.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-position
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": apply-alpha
#import "../theme/theme.typ": geom-colour-default, geom-defaults

/// Marginal rug ticks at each row's x and / or y position.
///
/// `sides` selects which panel edges receive ticks: any combination of `b`
/// (bottom), `t` (top), `l` (left), `r` (right). Bottom and top sides need
/// an `x` mapping; left and right sides need a `y` mapping. Ticks honour a
/// mapped colour aesthetic when present.
///
/// \@category Geoms
/// \@subcategory Distributions
/// \@stability stable
/// \@since 0.0.1
///
/// \@param mapping Layer-specific aesthetic mapping built with \@aes. Falls back to the plot mapping when `none`.
///
/// \@param data Layer-specific dataset. Falls back to the plot data when `none`.
///
/// \@param sides String of edge codes among `b`, `t`, `l`, `r` indicating which axes receive ticks.
///
/// \@param length Tick length as a Typst length (e.g., `0.15cm`).
///
/// \@param stroke Tick thickness (a Typst length).
///
/// \@param colour Fixed tick colour. `auto` resolves via the colour scale or theme `ink`.
///
/// \@param alpha Tick opacity in `[0, 1]`.
///
/// \@param inherit-aes Whether to merge the plot-level mapping into this layer's mapping.
///
/// \@returns Layer dictionary consumed by \@plot.
///
/// \@examples Bottom and left rug ticks marking each observation's position.
/// ```
/// //| alt: "Scatter of 12 (x, y) points along a sine curve with bottom and left rug ticks marking each observation's x and y."
/// #let d = range(0, 12).map(i => (x: i, y: calc.sin(i * 0.5)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-rug(sides: "bl"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Rug on every side, coloured by a categorical column to expose
/// per-group density along both axes.
/// ```
/// //| alt: "Scatter of two groups (a, b) with rug ticks on top, bottom, left, and right edges coloured by group via colour aesthetic."
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 12) {
///     d.push((x: i + (if grp == "b" { 0.3 } else { 0 }), y: calc.sin(i * 0.5), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "grp", fill: "grp"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-rug(sides: "tblr"),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@geom-blank, \@geom-function, \@geom-point
#let geom-rug(
  mapping: none,
  data: none,
  sides: "bl",
  length: 0.15cm,
  stroke: auto,
  colour: auto,
  alpha: auto,
  inherit-aes: true,
) = make-layer(
  "rug",
  mapping: mapping,
  data: data,
  params: (
    sides: sides,
    length: length,
    stroke: stroke,
    colour: colour,
    alpha: alpha,
  ),
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none or data == none { return }
  let sides = layer.params.sides
  if sides == none or sides == "" { return }
  // Rug tassels are anchored to rectangular panel edges; the axis-edge
  // semantics don't translate to polar, so degrade to a no-op rather than
  // emit confusing ticks.
  if ctx.at("radial", default: none) != none { return }

  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)

  let colour-pinned = layer.params.colour != auto
  let colour-col = mapping.at("colour", default: none)
  let colour-trained = ctx.trained.at("colour", default: none)
  let resolve-colour = if colour-trained != none {
    (ctx.resolve-colour)(colour-trained, ctx.palette)
  } else { none }
  let theme-colour = geom-colour-default(geom-defaults(ctx.theme))

  let (px-lo, px-hi) = ctx.px-range
  let (py-lo, py-hi) = ctx.py-range
  let len = layer.params.length / 1cm

  let want-bottom = sides.contains("b")
  let want-top = sides.contains("t")
  let want-left = sides.contains("l")
  let want-right = sides.contains("r")

  for row in data {
    let colour = if colour-pinned {
      layer.params.colour
    } else if colour-col != none and resolve-colour != none {
      resolve-colour(row.at(colour-col, default: none))
    } else { theme-colour }
    let alpha = resolve-channel("alpha", layer, mapping, ctx, row, 1)
    let final-colour = apply-alpha(colour, alpha)
    let thickness = resolve-channel(
      "linewidth",
      layer,
      mapping,
      ctx,
      row,
      0.4pt,
    )
    let stroke-spec = (paint: final-colour, thickness: thickness)

    if (want-bottom or want-top) and x-col != none and x-trained != none {
      let cx = map-position(
        x-trained,
        row.at(x-col, default: none),
        ctx.px-range,
      )
      if cx != none {
        if want-bottom {
          cetz.draw.line((cx, py-lo), (cx, py-lo + len), stroke: stroke-spec)
        }
        if want-top {
          cetz.draw.line((cx, py-hi - len), (cx, py-hi), stroke: stroke-spec)
        }
      }
    }
    if (want-left or want-right) and y-col != none and y-trained != none {
      let cy = map-position(
        y-trained,
        row.at(y-col, default: none),
        ctx.py-range,
      )
      if cy != none {
        if want-left {
          cetz.draw.line((px-lo, cy), (px-lo + len, cy), stroke: stroke-spec)
        }
        if want-right {
          cetz.draw.line((px-hi - len, cy), (px-hi, cy), stroke: stroke-spec)
        }
      }
    }
  }
}
