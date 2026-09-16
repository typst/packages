///! Dodge position adjustment.
///!
///! Shifts grouped marks side by side at each x. Partitions rows by the
///! composite group key (all discrete grouping aesthetics in canonical
///! order) and writes per-row dodge offsets consumed by the rendering
///! geom. When every mark at a given x has the same width, output matches
///! the simple uniform layout. When widths differ, slots are packed
///! side-by-side using each mark's own width, with `padding` between
///! adjacent slots, scaled to fit the bucket.

#import "../utils/group.typ": group-key
#import "../utils/types.typ": parse-number
#import "../scale/train.typ": discrete-slot-width, map-axis

/// Dodge position adjustment: place grouped marks side by side.
///
/// Typically set on a layer as `position: "dodge"` rather than constructed directly; the constructor exists for symmetry with the other positions. When all marks at a given x share the same width, the result matches a simple uniform dodge. When widths differ (per-row `width` column), each mark uses its own width as its slot, with `padding` between slots and a shrink-to-fit if total slot use would exceed the bucket.
///
/// - width: Total width reserved for the dodged group, as a fraction of the category width.
/// - padding: Gap between adjacent dodge slots in mixed-width mode, as a fraction of the bucket.
///
/// Returns: Position dictionary with `name: "dodge"`, consumed by `plot`.
///
/// See also: `position-stack`, `position-fill`, `position-identity`, `position-jitter`.
///
/// Bars dodged side by side per `fill` group within each x slot.
///
/// ```typst
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp", label: "y"),
///   layers: (
///     geom-col(position: "dodge"),
///     geom-label(position: "dodge", size: 14pt),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Increase `padding` to widen the gap between dodged bars.
///
/// ```typst
/// #let d = (
///   (q: "Q1", grp: "a", y: 3),
///   (q: "Q1", grp: "b", y: 5),
///   (q: "Q2", grp: "a", y: 4),
///   (q: "Q2", grp: "b", y: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "q", y: "y", fill: "grp"),
///   layers: (geom-col(position: position-dodge(padding: 0.3)),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let position-dodge(width: 0.9, padding: 0.1) = (
  kind: "position",
  name: "dodge",
  params: (width: width, padding: padding),
)

/// Shift a centre coordinate by this row's dodge offset.
///
/// `bucket` is the canvas span of the dodge bucket the row belongs to (the total width the dodged slots fill collectively).
///
/// - row: Data row carrying `_dodge-offset` written by `apply`.
/// - c: Original centre coordinate on the canvas.
/// - bucket: Canvas span of the dodge bucket for this row.
#let dodge-centre(row, c, bucket) = (
  c + row.at("_dodge-offset", default: 0) * bucket
)

/// Shrink a half-width by this row's dodge slot count.
///
/// - row: Data row carrying `_dodge-n` written by `apply`.
/// - half: Undodged half-width on the canvas.
#let dodge-half(row, half) = half / row.at("_dodge-n", default: 1)

/// Canvas-cm shift to apply to a projected point so it rides its dodge slot.
///
/// For geoms that place marks via `project-point` (point, line, path, text, label, typst, pointrange, linerange) rather than the band math used by the bar geoms. Returns `(dx, dy)` to add to the projected `(cx, cy)`: the shift lands on the category axis (`x`, or `y` under flip) and is zero unless the layer dodges over a discrete category axis in Cartesian coordinates.
///
/// - ctx: Draw context carrying `trained`, `px-range`/`py-range`, `flipped`, and optional `radial`.
/// - layer: Layer dictionary; its `position` field selects dodge and its width.
/// - row: Data row carrying `_dodge-offset` written by `apply`.
///
/// Returns: `(dx, dy)` canvas-cm offset, `(0, 0)` when dodge does not apply.
#let dodge-delta(ctx, layer, row) = {
  let pos = layer.at("position", default: "identity")
  let name = if type(pos) == str { pos } else if pos == none {
    "identity"
  } else { pos.at("name", default: "identity") }
  if name != "dodge" { return (0.0, 0.0) }
  if ctx.at("radial", default: none) != none { return (0.0, 0.0) }

  let width = if type(pos) == dictionary {
    pos.at("params", default: (:)).at("width", default: 0.9)
  } else { 0.9 }

  let flipped = ctx.at("flipped", default: false)
  let cat-trained = ctx.trained.at(
    if flipped { "y" } else { "x" },
    default: none,
  )
  let cat-range = if flipped { ctx.py-range } else { ctx.px-range }
  if cat-trained == none { return (0.0, 0.0) }

  let span = if cat-trained.type == "discrete" {
    discrete-slot-width(cat-trained, cat-range) * width
  } else {
    // Continuous axis: infer slot width from min canvas gap between unique x values.
    let resolve-data = ctx.at("resolve-data", default: none)
    let resolve-mapping = ctx.at("resolve-mapping", default: none)
    if resolve-data == none or resolve-mapping == none { return (0.0, 0.0) }
    let data = resolve-data(layer)
    let mapping = resolve-mapping(layer)
    // resolve-mapping is flip-aware: mapping.at("x") is always the category column.
    let x-col = mapping.at("x", default: none)
    if x-col == none { return (0.0, 0.0) }
    let (d-lo, d-hi) = cat-trained.domain
    if d-hi == d-lo { return (0.0, 0.0) }
    let (cat-lo, cat-hi) = cat-range
    let xs = data
      .map(r => parse-number(r.at(x-col, default: none)))
      .filter(v => v != none)
    let sorted = xs.dedup().sorted()
    if sorted.len() < 2 {
      (cat-hi - cat-lo) / 10 * width
    } else {
      let mapped = sorted.map(v => map-axis(cat-trained, v, cat-range))
      let gaps = range(mapped.len() - 1).map(i => (
        calc.abs(mapped.at(i + 1) - mapped.at(i))
      ))
      calc.min(..gaps) * width
    }
  }

  let shift = row.at("_dodge-offset", default: 0) * span
  if flipped { (0.0, shift) } else { (shift, 0.0) }
}

#let _row-width(row, default-width) = {
  let w = parse-number(row.at("width", default: none))
  if w == none { default-width } else { w }
}

#let apply(data, mapping, params: (:), coord: none) = {
  let x-col = mapping.at("x", default: none)
  if x-col == none { return (data: data, mapping: mapping) }

  let bar-frac = params.at("width", default: 0.9)
  let padding = params.at("padding", default: 0.1)

  // Alphabetic levels so slot order matches the trained discrete domain
  // and the legend. Dedup is dict-keyed for O(n) instead of array-scan
  // O(n^2).
  let buckets = (:)
  let bucket-order = ()
  let level-set = (:)
  for (i, row) in data.enumerate() {
    let key = group-key(row, mapping)
    if key not in level-set { level-set.insert(key, true) }
    let xv = row.at(x-col, default: none)
    let bk = if xv == none { "" } else { str(xv) }
    if bk not in buckets {
      buckets.insert(bk, ())
      bucket-order.push(bk)
    }
    let bucket = buckets.at(bk)
    bucket.push((i: i, row: row, key: key))
    buckets.insert(bk, bucket)
  }
  let levels = level-set.keys().sorted()
  let level-index = (:)
  for (idx, k) in levels.enumerate() { level-index.insert(k, idx) }
  let n-levels = levels.len()
  if n-levels <= 1 { return (data: data, mapping: mapping) }

  let n-data = data.len()
  let offsets = range(n-data).map(_ => 0.0)
  let n-slots = range(n-data).map(_ => 1)

  for bk in bucket-order {
    let entries = buckets
      .at(bk)
      .map(e => (
        i: e.i,
        row: e.row,
        key: e.key,
        w: _row-width(e.row, bar-frac),
      ))
    let first-w = entries.first().w
    let uniform = entries.all(e => e.w == first-w)

    if uniform {
      for entry in entries {
        let idx = level-index.at(entry.key, default: none)
        if idx == none { continue }
        let off = (idx + 0.5) / n-levels - 0.5
        offsets.at(entry.i) = off
        n-slots.at(entry.i) = n-levels
      }
    } else {
      // Mixed-width path walks slots left-to-right via cursor, so entries
      // must be sorted by group key to match the uniform path's slot order.
      let sorted-entries = entries.sorted(key: e => e.key)
      let n = sorted-entries.len()
      let widths-sum = sorted-entries.fold(0.0, (acc, e) => acc + e.w)
      let padding-sum = if n > 1 { (n - 1) * padding } else { 0 }
      let total = widths-sum + padding-sum
      let scale = if total > 1 { 1.0 / total } else { 1.0 }
      let eff-pad = padding * scale
      let cursor = -0.5
      for entry in sorted-entries {
        let w = entry.w * scale
        let centre = cursor + w / 2
        cursor = cursor + w + eff-pad
        let half = w / 2
        let off = if bar-frac == 0 { 0.0 } else { centre / bar-frac }
        let n-equiv = if half == 0 { 1 } else { bar-frac / (2 * half) }
        offsets.at(entry.i) = off
        n-slots.at(entry.i) = n-equiv
      }
    }
  }

  let out = data
    .enumerate()
    .map(((i, row)) => {
      let new-row = row
      new-row.insert("_dodge-offset", offsets.at(i))
      new-row.insert("_dodge-n", n-slots.at(i))
      new-row
    })

  (data: out, mapping: mapping)
}
