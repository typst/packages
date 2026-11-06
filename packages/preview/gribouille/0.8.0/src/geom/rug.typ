///! Marginal tick marks at observed x and / or y positions.
///!
///! Adds short ticks just outside the panel edges to expose the raw
///! distribution of one or both positional aesthetics.

#import "../position/apply.typ": assert-position
#import "../utils/errors.typ": assert-alpha, fail-type
#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../utils/aes-resolve.typ": resolve-channel
#import "../coord/project.typ": axis-mapper
#import "../utils/types.typ": parse-number
#import "../utils/colour-resolve.typ": apply-alpha
#import "../theme/theme.typ": resolve-geom-colour, resolve-geom-defaults

#let spec = (
  reads: ("x", "y", "colour", "alpha", "linewidth"),
  extents: none,
)

/// Marginal rug ticks at each row's x and / or y position.
///
/// `sides` selects which panel edges receive ticks: any combination of `b` (bottom), `t` (top), `l` (left), `r` (right). Bottom and top sides need an `x` mapping; left and right sides need a `y` mapping. Ticks honour a mapped colour aesthetic when present.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Falls back to the plot mapping when `none`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - sides: String of edge codes among `b`, `t`, `l`, `r` indicating which axes receive ticks.
/// - length: Tick length as a Typst length (e.g., `0.15cm`).
/// - stroke: Tick thickness (a Typst length).
/// - colour: Fixed tick colour. `auto` resolves via the colour scale or theme `ink`.
/// - alpha: Tick opacity in `[0, 1]`.
/// - stat: Statistical transform name or stat object.
/// - position: Position adjustment name. Usually left at `"identity"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `geom-blank`, `geom-function`, `geom-point`.
///
/// Bottom and left rug ticks marking each observation's position.
///
/// ```typst
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
/// Rug on every side, coloured by a categorical column to expose per-group density along both axes.
///
/// ```typst
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
#let geom-rug(
  mapping: none,
  data: none,
  sides: "bl",
  length: 0.15cm,
  stroke: auto,
  colour: auto,
  alpha: auto,
  stat: "identity",
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
) = {
  assert-position("geom-rug", position)
  assert-alpha("geom-rug", alpha)
  if (
    sides != none
      and (
        type(sides) != str
          or sides.clusters().any(c => c not in ("b", "t", "l", "r"))
      )
  ) {
    fail-type(
      "geom-rug",
      "sides",
      sides,
      "a string of the codes `b`, `t`, `l`, `r`, or `none`",
    )
  }
  if type(length) != std.length or length < 0cm {
    fail-type(
      "geom-rug",
      "length",
      length,
      "a non-negative length such as `0.15cm`",
    )
  }
  make-layer(
    "rug",
    mapping: mapping,
    data: data,
    params: (
      sides: sides,
      length: length,
      stroke: stroke,
      colour: colour,
      alpha: alpha,
    )
      + split-aes-params("geom-rug", args, spec.reads),
    stat: stat,
    position: position,
    key: key,
    inherit-aes: inherit-aes,
  )
}

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
  let map-x = axis-mapper(ctx, "x")
  let map-y = axis-mapper(ctx, "y")

  let theme-colour = resolve-geom-colour(resolve-geom-defaults(ctx.theme))

  let (px-lo, px-hi) = (ctx.coord.axis-range)(ctx, "x")
  let (py-lo, py-hi) = (ctx.coord.axis-range)(ctx, "y")
  let len = layer.params.length / 1cm

  let want-bottom = sides.contains("b")
  let want-top = sides.contains("t")
  let want-left = sides.contains("l")
  let want-right = sides.contains("r")

  for row in data {
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
      0.4pt,
    )
    let stroke-spec = (paint: final-colour, thickness: thickness)

    if (want-bottom or want-top) and x-col != none and x-trained != none {
      let cx = map-x(row.at(x-col, default: none))
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
      let cy = map-y(row.at(y-col, default: none))
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
