///! Overlapping density ridges per y bucket using \@stat-density-ridges.
///!
///! The default `stat = "density-ridges"` smooths each y bucket's x sample
///! into a density curve; the geom draws every curve as a filled ridge
///! rising from its bucket's baseline, back to front so ridges lower on
///! the plot overlap the ones behind them. Under \@coord-radial the layer
///! degrades to a no-op.

#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../stat/density-ridges.typ": stat-density-ridges
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-axis, map-position
#import "../utils/band.typ": axis-band
#import "../utils/group.typ": bucket-by-col, partition-by-group
#import "../utils/types.typ": parse-number
#import "../utils/stroke.typ": resolve-stroke-spec
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
)

/// Ridgeline layer: overlapping filled density curves of x per y bucket.
///
/// Mapping must provide `x` and `y`. The `scale` parameter sets the tallest ridge's height in y-level units: `1` makes it exactly reach the next bucket's baseline, larger values overlap it.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x` and `y`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - scale: Tallest ridge height in y-level units; values above `1` overlap the ridge behind.
/// - bw: Kernel bandwidth. `auto` applies Silverman's rule of thumb; pass a positive number to fix it.
/// - adjust: Bandwidth multiplier: `adjust: 0.5` halves the smoothing, `adjust: 2` doubles it.
/// - n: Number of evenly spaced grid points the density is evaluated at per bucket.
/// - trim: Whether to restrict each ridge to its bucket's x range instead of letting it decay to the baseline.
/// - colour: Fixed outline colour. `auto` resolves via the colour scale, falling back to the theme `ink`.
/// - fill: Fixed ridge fill. `auto` resolves via the fill scale, falling back to the theme `paper`.
/// - stroke: Outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Fill opacity in `[0, 1]`.
/// - stat: Statistical transform. `auto` builds `stat-density-ridges` from the parameters above; pass a stat name or stat object to override.
/// - position: Position adjustment name. Usually `"identity"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `stat-density-ridges`, `geom-density`, `geom-violin`.
///
/// Classic overlapping ridgeline plot of three shifted samples.
///
/// ```typst
/// #let xs = (1, 2, 2, 3, 3, 3, 4, 4, 5, 7)
/// #let d = ()
/// #for (i, grp) in ("a", "b", "c").enumerate() {
///   for x in xs {
///     d.push((grp: grp, x: x * (1 + i * 0.4) + i))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "grp"),
///   layers: (geom-density-ridges(scale: 1.4),),
///   scales: scales(y: scale-discrete(expand: (auto, 45%))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `fill` to the bucket column to colour each ridge.
///
/// ```typst
/// #let xs = (1, 2, 2, 3, 3, 3, 4, 4, 5, 7)
/// #let d = ()
/// #for (i, grp) in ("a", "b", "c").enumerate() {
///   for x in xs {
///     d.push((grp: grp, x: x * (1 + i * 0.4) + i))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "grp", fill: "grp"),
///   layers: (geom-density-ridges(scale: 1.4, alpha: 0.7),),
///   scales: scales(y: scale-discrete(expand: (auto, 45%))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-density-ridges(
  mapping: none,
  data: none,
  scale: 1.8,
  bw: auto,
  adjust: 1,
  n: 512,
  trim: false,
  colour: auto,
  fill: auto,
  stroke: 0.6pt,
  alpha: auto,
  stat: auto,
  position: "identity",
  key: auto,
  inherit-aes: true,
  ..args,
) = make-layer(
  "density-ridges",
  mapping: mapping,
  data: data,
  params: (
    scale: scale,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  )
    + split-aes-params("geom-density-ridges", args),
  stat: if stat == auto {
    stat-density-ridges(bw: bw, adjust: adjust, n: n, trim: trim)
  } else { stat },
  position: position,
  key: key,
  inherit-aes: inherit-aes,
)

#let draw(layer, ctx) = {
  let mapping = (ctx.resolve-mapping)(layer)
  let data = (ctx.resolve-data)(layer)
  if mapping == none { return }
  let x-col = mapping.at("x", default: none)
  let y-col = mapping.at("y", default: none)
  let height-col = mapping.at("height", default: none)
  if x-col == none or y-col == none or height-col == none { return }

  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }
  if x-trained.type != "continuous" { return }
  if ctx.at("radial", default: none) != none { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  // The outline separates overlapping ridges, so the stroke default stands
  // even when fill is mapped or pinned (matching geom-boxplot).
  let default-colour = resolve-geom-colour(g-defaults)
  let default-fill = resolve-geom-fill(g-defaults, role: "paper")
  let scale = layer.params.scale

  // One ridge per (group, y bucket); collect first so they can render back
  // to front (higher baselines first), letting front ridges overlap them.
  let ridges = ()
  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    for rows in bucket-by-col(g.data, y-col) {
      let raw-y = rows.first().at(y-col, default: none)
      let baseline = map-position(y-trained, raw-y, ctx.py-range)
      if baseline == none { continue }
      let band = axis-band(y-trained, raw-y, 0.5, ctx.py-range)
      if band == none { continue }
      let (band-lo, band-hi) = band
      let side = rows
        .map(r => {
          let xv = parse-number(r.at(x-col, default: none))
          let hv = parse-number(r.at(height-col, default: none))
          if xv == none or hv == none { return none }
          (x: xv, height: hv)
        })
        .filter(p => p != none)
        .sorted(key: p => p.x)
      if side.len() < 2 { continue }
      ridges.push((
        baseline: baseline,
        span: band-hi - band-lo,
        side: side,
        leader: rows.first(),
      ))
    }
  }

  for ridge in ridges.sorted(key: r => -r.baseline) {
    let top = ridge.side.map(p => (
      map-axis(x-trained, p.x, ctx.px-range),
      ridge.baseline + ridge.span * scale * p.height,
    ))
    let base = (
      (top.last().at(0), ridge.baseline),
      (top.first().at(0), ridge.baseline),
    )
    let pts = top + base
    if pts.any(p => p.at(0) == none) { continue }

    let final-fill = resolve-channel(
      "fill",
      layer,
      mapping,
      ctx,
      ridge.leader,
      default-fill,
    )
    let resolved-stroke = resolve-stroke-spec(
      layer,
      mapping,
      ctx,
      ridge.leader,
      default-colour,
    )
    cetz.draw.line(
      ..pts,
      close: true,
      fill: final-fill,
      stroke: resolved-stroke,
    )
  }
}
