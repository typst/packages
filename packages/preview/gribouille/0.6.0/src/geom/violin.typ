///! Violin plots from raw observations using \@stat-ydensity.
///!
///! The default `stat = "ydensity"` smooths each x bucket's y sample into a
///! density curve; the geom mirrors that curve around the bucket's x slot
///! as a closed silhouette. Under \@coord-radial the layer degrades to a
///! no-op (mirrored silhouettes do not translate to polar wedges yet).

#import "../deps.typ": cetz
#import "../layer.typ": make-layer, split-aes-params
#import "../stat/ydensity.typ": stat-ydensity
#import "../position/apply.typ": layer-position-name
#import "../position/dodge.typ": dodge-centre, dodge-half
#import "../utils/aes-resolve.typ": resolve-channel
#import "../scale/train.typ": map-axis, map-position
#import "../utils/band.typ": axis-band
#import "../utils/group.typ": partition-by-group
#import "../utils/types.typ": parse-number
#import "../utils/stroke.typ": build-stroke
#import "../theme/theme.typ": (
  resolve-geom-colour, resolve-geom-defaults, resolve-geom-fill,
)

/// Violin layer: mirrored density silhouette of y per x bucket.
///
/// Defaults to `stat = "ydensity"`, so the layer accepts raw observations and estimates each bucket's density internally. The default `position = "identity"` keeps buckets at their categorical x slot; switch to `"dodge"` for side-by-side violins per fill level.
///
/// - mapping: Layer-specific aesthetic mapping built with `aes`. Must map `x` and `y`.
/// - data: Layer-specific dataset, or a function applied to the plot data returning the layer frame. Falls back to the plot data when `none`.
/// - width: Full violin width in x data units at `violinwidth = 1`.
/// - bw: Kernel bandwidth. `auto` applies Silverman's rule of thumb; pass a positive number to fix it.
/// - adjust: Bandwidth multiplier: `adjust: 0.5` halves the smoothing, `adjust: 2` doubles it.
/// - n: Number of evenly spaced grid points the density is evaluated at per bucket.
/// - trim: Whether to restrict each silhouette to its bucket's y range instead of letting the tails decay.
/// - scale: Width normalisation across buckets: `"area"` (default), `"count"`, or `"width"`. See `stat-ydensity`.
/// - colour: Fixed outline colour. `auto` resolves via the colour scale, falling back to the theme `ink`.
/// - fill: Fixed body fill. `auto` resolves via the fill scale, falling back to the theme `paper`.
/// - stroke: Outline thickness (a Typst length) or stroke dictionary; `none` disables the outline.
/// - alpha: Fill opacity in `[0, 1]`.
/// - stat: Statistical transform. `auto` builds `stat-ydensity` from the parameters above; pass a stat name or stat object to override.
/// - position: Position adjustment name. `"identity"` (default) or `"dodge"`.
/// - key: Legend glyph override built with a `draw-key-*` helper. `auto` picks the default for the geom.
/// - inherit-aes: Whether to merge the plot-level mapping into this layer's mapping.
///
/// Returns: Layer dictionary consumed by `plot`.
///
/// See also: `stat-ydensity`, `geom-boxplot`, `geom-density`.
///
/// Violins of a skewed sample per group.
///
/// ```typst
/// #let ys = (1, 2, 2, 3, 3, 3, 4, 4, 5, 7)
/// #let d = ()
/// #for (i, grp) in ("a", "b", "c").enumerate() {
///   for y in ys {
///     d.push((grp: grp, y: y + i))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-violin(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Map `fill` and dodge for side-by-side violins per level; keep the tails with `trim: false`.
///
/// ```typst
/// #let ys = (1, 2, 2, 3, 3, 3, 4, 4, 5, 7)
/// #let d = ()
/// #for grp in ("a", "b") {
///   for lvl in ("u", "v") {
///     for y in ys {
///       d.push((grp: grp, lvl: lvl, y: y + (if lvl == "v" { 2 } else { 0 })))
///     }
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y", fill: "lvl"),
///   layers: (geom-violin(trim: false, position: "dodge", alpha: 0.7),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let geom-violin(
  mapping: none,
  data: none,
  width: 0.9,
  bw: auto,
  adjust: 1,
  n: 512,
  trim: true,
  scale: "area",
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
  "violin",
  mapping: mapping,
  data: data,
  params: (
    width: width,
    colour: colour,
    fill: fill,
    stroke: stroke,
    alpha: alpha,
  )
    + split-aes-params("geom-violin", args),
  stat: if stat == auto {
    stat-ydensity(bw: bw, adjust: adjust, n: n, trim: trim, scale: scale)
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
  if x-col == none or y-col == none { return }

  let x-trained = ctx.trained.at("x", default: none)
  let y-trained = ctx.trained.at("y", default: none)
  if x-trained == none or y-trained == none { return }
  if y-trained.type != "continuous" { return }
  if ctx.at("radial", default: none) != none { return }

  let g-defaults = resolve-geom-defaults(ctx.theme)
  // The outline carries the violin's structure, so the stroke default
  // stands even when fill is mapped or pinned (matching geom-boxplot).
  let default-colour = resolve-geom-colour(g-defaults)
  let default-fill = resolve-geom-fill(g-defaults, role: "paper")
  let half-width = layer.params.width / 2
  let position-name = layer-position-name(layer)

  for g in partition-by-group(data, mapping, trained: ctx.trained) {
    // One silhouette per distinct x bucket within the group, in
    // first-appearance order.
    let buckets = (:)
    let order = ()
    for row in g.data {
      let key = str(row.at(x-col, default: ""))
      if key == "" { continue }
      if key not in buckets { order.push(key) }
      let bucket = buckets.at(key, default: ())
      bucket.push(row)
      buckets.insert(key, bucket)
    }

    for key in order {
      let rows = buckets.at(key)
      let raw-x = rows.first().at(x-col, default: none)
      let cx = map-position(x-trained, raw-x, ctx.px-range)
      if cx == none { continue }
      let band = axis-band(x-trained, raw-x, half-width, ctx.px-range)
      if band == none { continue }
      let (band-lo, band-hi) = band

      let centre = cx
      let canvas-half = (band-hi - band-lo) / 2
      if position-name == "dodge" {
        let leader = rows.first()
        centre = dodge-centre(leader, cx, band-hi - band-lo)
        canvas-half = dodge-half(leader, canvas-half)
      }

      let side = rows
        .map(r => {
          let yv = parse-number(r.at(y-col, default: none))
          let vw = parse-number(r.at("violinwidth", default: none))
          if yv == none or vw == none { return none }
          (y: yv, vw: vw)
        })
        .filter(p => p != none)
        .sorted(key: p => p.y)
      if side.len() < 2 { continue }

      let left = side.map(p => (
        centre - canvas-half * p.vw,
        map-axis(y-trained, p.y, ctx.py-range),
      ))
      let right = side
        .rev()
        .map(p => (
          centre + canvas-half * p.vw,
          map-axis(y-trained, p.y, ctx.py-range),
        ))
      let pts = left + right
      if pts.any(p => p.at(1) == none) { continue }

      let leader = rows.first()
      let final-fill = resolve-channel(
        "fill",
        layer,
        mapping,
        ctx,
        leader,
        default-fill,
      )
      let resolved-stroke = resolve-channel(
        "colour",
        layer,
        mapping,
        ctx,
        leader,
        default-colour,
      )
      cetz.draw.line(
        ..pts,
        close: true,
        fill: final-fill,
        stroke: build-stroke(layer.params.stroke, resolved-stroke),
      )
    }
  }
}
